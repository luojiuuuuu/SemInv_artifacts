# -*- coding: utf-8 -*-
from typing import Any, Dict, List, Optional, Tuple
import re
import json
from pathlib import Path
try:
    from eth_abi import encode as abi_encode
except ImportError:
    from eth_abi import encode_abi as abi_encode
from eth_utils import keccak
from .gen_foundry_tests import _infer_constructor_value_requirement

# -------- 正则与基础工具 --------
PASS_BLOCK_HDR = re.compile(r"^\[PASS\]\s+([^\(]+)\(\)")
FAIL_BLOCK_HDR = re.compile(r"^\[FAIL[^\]]*\]\s+([^\(]+)\(\)")
NEW_CONTRACT = re.compile(r"→ new\s+([A-Za-z0-9_]+)@0x[0-9A-Fa-f]{40}")
NEW_CONTRACT_WITH_ARGS = re.compile(r"→ new\s+([A-Za-z0-9_]+)\((.*)\)@0x[0-9A-Fa-f]{40}")
VM_START_PRANK = re.compile(r"VM::startPrank\((0x[0-9A-Fa-f]{40})\)")
VM_STOP_PRANK = re.compile(r"VM::stopPrank\(\)")
VM_PRANK = re.compile(r"VM::prank\((0x[0-9A-Fa-f]{40})\)")
FN_CALL = re.compile(r"([A-Za-z0-9_]+)::([A-Za-z0-9_]+)\((.*)\)")
HEX_ADDR = re.compile(r"^0x[0-9A-Fa-f]{40}$", re.IGNORECASE)
INT_WITH_HINT = re.compile(r"^\s*([+-]?(?:0x[0-9A-Fa-f]+|\d[\d_]*))(?:\s*\[[^\]]+\])?\s*$")
HEX_BYTES = re.compile(r"^0x[0-9A-Fa-f]*$")
DEFAULT_SENDER = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

def is_address(x: str) -> bool:
    return bool(HEX_ADDR.match(x.strip()))

def is_bool(x: str) -> bool:
    return x.strip() in ("true", "false")

def is_quoted_string(x: str) -> bool:
    s = x.strip()
    return (len(s) >= 2) and ((s[0] == '"' and s[-1] == '"') or (s[0] == "'" and s[-1] == "'"))

def is_int(x: str) -> bool:
    s = x.strip().lower().replace("_", "")
    m = INT_WITH_HINT.match(s)
    if m:
        s = m.group(1).replace("_", "")
    if s.startswith("0x"):
        return False
    return s.isdigit() or (s.startswith("-") and s[1:].isdigit())

def strip_quotes(x: str) -> str:
    s = x.strip()
    if is_quoted_string(s):
        return s[1:-1]
    return s

def smart_split_args(arg_blob: str) -> List[str]:
    args = []
    cur = []
    in_str = False
    str_ch = None
    escape = False
    for ch in arg_blob:
        if in_str:
            cur.append(ch)
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == str_ch:
                in_str = False
                str_ch = None
        else:
            if ch in ('"', "'"):
                in_str = True
                str_ch = ch
                cur.append(ch)
            elif ch == ',':
                args.append(''.join(cur).strip()); cur = []
            else:
                cur.append(ch)
    if cur:
        args.append(''.join(cur).strip())
    return [a for a in args if a != ""]

def infer_arg_type(v: str) -> str:
    s = v.strip()
    if is_address(s): return "address"
    if is_bool(s):    return "bool"
    if is_quoted_string(s): return "string"
    if is_int(s):     return "uint256"
    return "bytes"

def coerce_arg_value(v: str) -> Any:
    s = v.strip()
    if is_address(s): return s
    if is_bool(s):    return True if s == "true" else False
    if is_quoted_string(s): return strip_quotes(s)
    m = INT_WITH_HINT.match(s)
    if m:
        token = m.group(1).replace("_", "")
        return int(token, 16) if token.lower().startswith(("0x", "+0x", "-0x")) else int(token)
    if is_int(s):     return int(s.replace("_", ""))
    return s

def _clean_address(value: Any) -> Optional[str]:
    if isinstance(value, str) and is_address(value):
        return value
    return None

def _clean_int_token(value: str) -> Optional[int]:
    m = INT_WITH_HINT.match(value)
    if not m:
        return None
    token = m.group(1).replace("_", "")
    try:
        return int(token, 16) if token.lower().startswith(("0x", "+0x", "-0x")) else int(token)
    except ValueError:
        return None

def _hex_string_to_bytes(value: Any) -> Optional[bytes]:
    if not isinstance(value, str):
        return None
    s = value.strip()
    if not HEX_BYTES.match(s):
        return None
    hex_part = s[2:]
    if len(hex_part) % 2:
        hex_part = "0" + hex_part
    try:
        return bytes.fromhex(hex_part)
    except ValueError:
        return None

def _abi_type(t: str) -> str:
    return str(t or "").replace(" storage", "").replace(" memory", "").replace(" calldata", "")

def _function_signature(item: Dict[str, Any]) -> str:
    return f"{item.get('name')}({','.join(_abi_type(inp.get('type')) for inp in item.get('inputs', []))})"

def _find_abi_function(func_token: Any, args: List[Any], abi: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    if not isinstance(func_token, str):
        return None
    token = func_token.strip()
    functions = [item for item in abi if item.get("type") == "function"]
    if "(" in token and token.endswith(")"):
        for item in functions:
            if _function_signature(item) == token:
                return item
    if re.fullmatch(r"(0x)?[0-9A-Fa-f]{8}", token):
        wanted = token[2:] if token.startswith("0x") else token
        for item in functions:
            if keccak(text=_function_signature(item))[:4].hex() == wanted.lower():
                return item
    name = token.split("(", 1)[0]
    cands = [item for item in functions if item.get("name") == name and len(item.get("inputs", [])) == len(args)]
    return cands[0] if len(cands) == 1 else None

def _coerce_for_abi(value: Any, abi_type: str) -> Tuple[bool, Any]:
    t = _abi_type(abi_type)
    if t.endswith("]"):
        base, _, suffix = t.rpartition("[")
        if not suffix.endswith("]"):
            return False, value
        fixed_len = suffix[:-1]
        if not isinstance(value, list):
            return False, value
        if fixed_len:
            try:
                if len(value) != int(fixed_len):
                    return False, value
            except ValueError:
                return False, value
        out = []
        for item in value:
            ok, coerced = _coerce_for_abi(item, base)
            if not ok:
                return False, value
            out.append(coerced)
        return True, out

    if t.startswith("uint") or t.startswith("int"):
        if isinstance(value, bool):
            return False, value
        if isinstance(value, int):
            return True, value
        if isinstance(value, str):
            parsed = _clean_int_token(value)
            if parsed is None:
                return False, value
            return True, parsed
        return False, value

    if t == "address":
        cleaned = _clean_address(value)
        return (True, cleaned) if cleaned else (False, value)

    if t == "bool":
        if isinstance(value, bool):
            return True, value
        if isinstance(value, str) and value.strip() in ("true", "false"):
            return True, value.strip() == "true"
        return False, value

    if t == "string":
        return (True, value) if isinstance(value, str) else (False, value)

    if t.startswith("bytes"):
        # The fuzzer's high-level JSON path later passes JSON values into the
        # ABI encoder. JSON cannot represent Python bytes directly, and passing
        # a hex string causes BytesEncoder errors in the next phase. Keep these
        # calls out of seeds.json until that path has an explicit bytes codec.
        return False, value

    return False, value

def _coerce_seed_value(value: Any) -> Tuple[bool, int]:
    if value is None:
        return True, 0
    if isinstance(value, bool):
        return False, 0
    if isinstance(value, int):
        return (value >= 0), value
    if isinstance(value, str):
        parsed = _clean_int_token(value)
        if parsed is None:
            return False, 0
        return (parsed >= 0), parsed
    return False, 0

def _validate_seed_entry(
    seed: Dict[str, Any],
    abi: List[Dict[str, Any]],
) -> Tuple[Optional[Dict[str, Any]], List[str]]:
    reasons: List[str] = []
    if not isinstance(seed, dict):
        return None, ["seed is not an object"]

    out: Dict[str, Any] = {}
    constructor = seed.get("constructor")
    if constructor:
        ctor_abi = next((item for item in abi if item.get("type") == "constructor"), None)
        ctor_inputs = ctor_abi.get("inputs", []) if ctor_abi else []
        raw_ctor_args = constructor.get("args", []) or []
        if not isinstance(raw_ctor_args, list):
            return None, ["constructor args is not a list"]
        ctor_args = list(raw_ctor_args)
        if len(ctor_args) != len(ctor_inputs):
            return None, ["constructor arg count does not match ABI"]
        coerced_args = []
        for raw, inp in zip(ctor_args, ctor_inputs):
            ok, val = _coerce_for_abi(raw, inp.get("type"))
            if not ok:
                return None, [f"constructor arg is not encodable as {inp.get('type')}"]
            coerced_args.append(val)
        try:
            abi_encode([_abi_type(inp.get("type")) for inp in ctor_inputs], coerced_args)
        except Exception:
            return None, ["constructor args failed ABI encoding"]
        ok_value, ctor_value = _coerce_seed_value(constructor.get("value", 0))
        if not ok_value:
            return None, ["constructor value is not a non-negative integer"]
        out["constructor"] = {
            "args": coerced_args,
            "from": _clean_address(constructor.get("from")) or DEFAULT_SENDER,
            "value": ctor_value,
        }

    steps = []
    for step in seed.get("steps", []) or []:
        if not isinstance(step, dict):
            reasons.append("step is not an object")
            continue
        func = step.get("func")
        ok_value, step_value = _coerce_seed_value(step.get("value", 0))
        if not ok_value:
            reasons.append(f"{func or '<missing func>'}: value is not a non-negative integer")
            continue
        if func in ("fallback", "receive"):
            sender = _clean_address(step.get("from")) or DEFAULT_SENDER
            steps.append({"func": "fallback", "args": [], "from": sender, "value": step_value})
            continue
        raw_args = step.get("args", []) or []
        if not isinstance(raw_args, list):
            reasons.append(f"{func or '<missing func>'}: args is not a list")
            continue
        args = list(raw_args)
        item = _find_abi_function(func, args, abi)
        if not item:
            reasons.append(f"{func or '<missing func>'}: function does not resolve against ABI")
            continue
        inputs = item.get("inputs", [])
        if len(args) != len(inputs):
            reasons.append(f"{_function_signature(item)}: arg count does not match ABI")
            continue
        types = [_abi_type(inp.get("type")) for inp in inputs]
        coerced_args = []
        for raw, inp in zip(args, inputs):
            ok, val = _coerce_for_abi(raw, inp.get("type"))
            if not ok:
                reasons.append(f"{_function_signature(item)}: arg {raw!r} is not encodable as {inp.get('type')}")
                coerced_args = None
                break
            coerced_args.append(val)
        if coerced_args is None:
            continue
        encode_args = []
        for typ, val in zip(types, coerced_args):
            if typ.startswith("bytes") and isinstance(val, str):
                byte_value = _hex_string_to_bytes(val)
                if byte_value is None:
                    raise ValueError("invalid bytes hex")
                encode_args.append(byte_value)
            else:
                encode_args.append(val)
        try:
            abi_encode(types, encode_args)
        except Exception as exc:
            reasons.append(f"{_function_signature(item)}: ABI encoding failed ({type(exc).__name__})")
            continue
        sender = _clean_address(step.get("from")) or DEFAULT_SENDER
        clean = {"func": _function_signature(item), "args": coerced_args, "from": sender}
        if step_value:
            clean["value"] = step_value
        steps.append(clean)

    if not steps:
        if "constructor" in out:
            out["steps"] = []
            return out, reasons
        if not reasons:
            reasons.append("seed has no executable target-contract steps")
        return None, reasons
    out["steps"] = steps
    return out, reasons

def _sanitize_seeds(
    seeds: List[Dict[str, Any]],
    abi: List[Dict[str, Any]],
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]], int]:
    clean: List[Dict[str, Any]] = []
    discarded: List[Dict[str, Any]] = []
    seen = set()
    duplicate_count = 0
    for seed in seeds:
        normalized, reasons = _validate_seed_entry(seed, abi)
        if not normalized:
            discarded.append({"reason": reasons or ["seed failed validation"], "seed": seed})
            continue
        key = repr(normalized)
        if key in seen:
            duplicate_count += 1
            discarded.append({"reason": ["duplicate seed after normalization"], "seed": seed})
            continue
        seen.add(key)
        clean.append(normalized)
    return clean, discarded, duplicate_count

def sanitize_seeds_for_fuzzer(seeds: List[Dict[str, Any]], abi: List[Dict[str, Any]]) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
    clean, discarded, duplicate_count = _sanitize_seeds(seeds or [], abi)
    report = {
        "candidate_count": len(seeds or []),
        "valid_count": len(clean),
        "discarded_count": max(0, len(seeds or []) - len(clean)),
        "duplicate_count": duplicate_count,
        "discarded": discarded,
        "policy": [
            "only high-level seeds with executable steps or constructor deployment metadata are written",
            "all function calls must resolve against ABI",
            "all args and values must be ABI-encodable",
            "byte-typed calls are discarded on the JSON seed path",
        ],
    }
    return clean, report

def build_signature_from_name_and_args(name: str, raw_args: List[str], abi: List[Dict[str, Any]]) -> str:
    inferred_types = [infer_arg_type(a) for a in raw_args]
    cands = [item for item in abi if item.get("type") == "function" and item.get("name") == name]
    if not cands:
        return f"{name}({','.join(inferred_types)})" if inferred_types else f"{name}()"
    cands = [it for it in cands if len(it.get("inputs", [])) == len(raw_args)]
    if len(cands) == 1:
        return f"{name}({','.join(inp['type'] for inp in cands[0]['inputs'])})"
    def compatible(t_inferred: str, t_abi: str) -> bool:
        if t_inferred == t_abi: return True
        if t_inferred.startswith("uint") and t_abi.startswith("uint"): return True
        if t_inferred == "bytes" and t_abi.startswith("bytes"): return True
        return False
    for it in cands:
        ins = it.get("inputs", [])
        if all(compatible(inferred_types[i], ins[i]["type"]) for i in range(len(ins))):
            return f"{name}({','.join(inp['type'] for inp in it['inputs'])})"
    return f"{name}({','.join(inferred_types)})" if inferred_types else f"{name}()"


def _resolve_trace_call_against_abi(
    name: str,
    raw_args: List[str],
    abi: List[Dict[str, Any]],
) -> Optional[Tuple[str, List[Any]]]:
    cands = [
        item for item in abi or []
        if item.get("type") == "function"
        and item.get("name") == name
        and len(item.get("inputs", []) or []) == len(raw_args or [])
    ]
    for item in cands:
        args: List[Any] = []
        ok_all = True
        for raw, inp in zip(raw_args or [], item.get("inputs", []) or []):
            value = coerce_arg_value(raw)
            ok, coerced = _coerce_for_abi(value, inp.get("type"))
            if not ok:
                ok_all = False
                break
            args.append(coerced)
        if ok_all:
            return _function_signature(item), args
    return None


def _resolve_constructor_args_against_abi(
    raw_args: List[str],
    abi: List[Dict[str, Any]],
) -> Optional[List[Any]]:
    ctor = next((item for item in abi or [] if item.get("type") == "constructor"), None)
    inputs = ctor.get("inputs", []) if ctor else []
    if len(inputs) != len(raw_args or []):
        return None
    args: List[Any] = []
    for raw, inp in zip(raw_args or [], inputs):
        value = coerce_arg_value(raw)
        ok, coerced = _coerce_for_abi(value, inp.get("type"))
        if not ok:
            return None
        args.append(coerced)
    return args

def _parse_trace_blocks(trace_text: str) -> List[Tuple[str, List[str]]]:
    """按 [PASS]/[FAIL] 分块"""
    lines = trace_text.splitlines()
    blocks: List[Tuple[str, List[str]]] = []
    current_status = None
    current_block: List[str] = []
    for line in lines:
        if PASS_BLOCK_HDR.match(line):
            if current_block:
                blocks.append((current_status, current_block)); current_block = []
            current_status = "PASS"; current_block.append(line)
        elif FAIL_BLOCK_HDR.match(line):
            if current_block:
                blocks.append((current_status, current_block)); current_block = []
            current_status = "FAIL"; current_block.append(line)
        else:
            if current_status is not None:
                current_block.append(line)
    if current_block:
        blocks.append((current_status, current_block))
    return blocks

def _parse_trace_for_pass_tests(
    trace_text: str,
    contract_name: str,
    abi: List[Dict[str, Any]],
    source_text: Optional[str] = None,
) -> List[Dict[str, Any]]:
    blocks = _parse_trace_blocks(trace_text)
    seeds: List[Dict[str, Any]] = []
    inferred_ctor_value = _infer_constructor_value_requirement(source_text, contract_name)
    ctor_value_wei = inferred_ctor_value[1] if inferred_ctor_value else 0
    for status, block in blocks:
        if status != "PASS":
            continue
        current_sender: Optional[str] = None
        one_shot_sender: Optional[str] = None
        constructor_added = False
        constructor_obj: Optional[Dict[str, Any]] = None
        steps: List[Dict[str, Any]] = []

        for raw in block:
            line = raw.strip()
            m = VM_START_PRANK.search(line)
            if m:
                current_sender = m.group(1); continue
            if VM_STOP_PRANK.search(line):
                current_sender = None; continue
            m = VM_PRANK.search(line)
            if m:
                one_shot_sender = m.group(1); continue

            m = NEW_CONTRACT_WITH_ARGS.search(line)
            if m and m.group(1) == contract_name:
                raw_args = m.group(2).strip()
                arg_list = smart_split_args(raw_args) if raw_args else []
                args_val = _resolve_constructor_args_against_abi(arg_list, abi)
                if args_val is None:
                    continue
                constructor_obj = {
                    "args": args_val,
                    "from": current_sender or "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    "value": ctor_value_wei
                }
                constructor_added = True
                continue

            m = NEW_CONTRACT.search(line)
            if m and m.group(1) == contract_name:
                if not constructor_added:
                    constructor_obj = {
                        "args": [],
                        "from": current_sender or "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                        "value": ctor_value_wei
                    }
                continue

            m = FN_CALL.search(line)
            if m:
                c_name, fn_name, raw_args_blob = m.group(1), m.group(2), m.group(3)
                if c_name != contract_name:
                    continue
                raw_args = smart_split_args(raw_args_blob) if raw_args_blob.strip() else []
                sender = one_shot_sender or current_sender or "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                one_shot_sender = None
                resolved = _resolve_trace_call_against_abi(fn_name, raw_args, abi)
                if not resolved:
                    continue
                signature, args_val = resolved
                steps.append({"func": signature, "args": args_val, "from": sender})

        if not steps:
            continue
        seed_entry: Dict[str, Any] = {}
        if constructor_obj and (constructor_obj.get("args") or constructor_obj.get("value")):
            seed_entry["constructor"] = constructor_obj
        seed_entry["steps"] = steps
        seeds.append(seed_entry)
    return seeds

def _fallback_constructor_seed_from_source(
    contract_name: str,
    abi: List[Dict[str, Any]],
    source_text: Optional[str],
) -> List[Dict[str, Any]]:
    inferred_ctor_value = _infer_constructor_value_requirement(source_text, contract_name)
    if not inferred_ctor_value:
        return []
    ctor_abi = next((item for item in abi or [] if item.get("type") == "constructor"), None)
    if not ctor_abi:
        return []
    is_payable = bool(ctor_abi.get("payable")) or ctor_abi.get("stateMutability") == "payable"
    if not is_payable or ctor_abi.get("inputs"):
        return []
    return [{
        "constructor": {
            "args": [],
            "from": DEFAULT_SENDER,
            "value": inferred_ctor_value[1],
        },
        "steps": [],
    }]

# ========= 你要的可调用函数 =========
def _extract_success_seeds_from_foundry(
    trace_text: str,
    comp: Dict[str, Any],
    source_text: Optional[str] = None
) -> List[Dict[str, Any]]:
    """
    参数:
      - trace_text: Foundry 测试输出全文(例如 last_trace.txt 的内容)
      - comp: 包含 {"contract": str, "abi": [...], "function_signature_mapping": {...}} 的对象
      - source_text: 可选，合约源码文本（当前实现未强依赖，仅作预留）
    返回: seeds 列表 (List[dict])，形如:
      [{"constructor": {...}, "steps": [{"func": "...", "args": [...], "from": "0x..."}]}, ...]
    """
    contract_name = comp.get("contract") or "RemiCoin"
    abi = comp.get("abi") or []
    # NOTE: 当前解析流程不依赖 source_text；若需要更强的类型推断，可在此利用源码做增强。
    raw_seeds = _parse_trace_for_pass_tests(trace_text, contract_name, abi, source_text)
    if not raw_seeds:
        raw_seeds = _fallback_constructor_seed_from_source(contract_name, abi, source_text)
    clean_seeds, _ = sanitize_seeds_for_fuzzer(raw_seeds, abi)
    return clean_seeds

# =========（可选）便捷包装：接受文件路径 =========
# def extract_success_seeds_from_files(project_root: str, testfile_path: str, comp_obj_or_path, source_path: Optional[str] = None) -> List[Dict[str, Any]]:    
#     """
#     便捷函数：传入路径也行
#     comp_obj_or_path 可直接给 dict，或 JSON 文件路径
#     """
#     import json, io, os

#     pr = Path(project_root).resolve()
#     test_name = str(Path(testfile_path).stem).split('_')[0]
#     seeds_dir = pr / f"{test_name}_meta" 
#     trace_path = seeds_dir / "last_trace.txt"

#     with open(trace_path, "r", encoding="utf-8", errors="ignore") as f:
#         trace_text = f.read()
#     if isinstance(comp_obj_or_path, dict):
#         comp = comp_obj_or_path
#     else:
#         with open(comp_obj_or_path, "r", encoding="utf-8") as f:
#             comp = json.load(f)
#     source_text = None
#     if source_path and os.path.exists(source_path):
#         with open(source_path, "r", encoding="utf-8", errors="ignore") as f:
#             source_text = f.read()
#     return _extract_success_seeds_from_foundry(trace_text, comp, source_text)

def extract_success_seeds_from_files(
    project_root: str,
    testfile_path: str,
    comp_obj_or_path,
    source_path: Optional[str] = None,
    meta_dir: Optional[str] = None,
    test_kind: str = "functional",
) -> List[Dict[str, Any]]:
    """
    便捷函数：传入路径也行
    comp_obj_or_path 可直接给 dict，或 JSON 文件路径

    新版路径规则：
    1) 若显式传入 meta_dir，则直接使用
    2) 否则默认使用：
       project_root/{contract_name}_meta/{functional_test|invariant_test}
    """
    import json
    import os

    pr = Path(project_root).resolve()

    # 先拿 contract_name，用于拼新 meta 路径
    if isinstance(comp_obj_or_path, dict):
        comp = comp_obj_or_path
    else:
        with open(comp_obj_or_path, "r", encoding="utf-8") as f:
            comp = json.load(f)

    contract_name = comp.get("contract")
    if not contract_name:
        # 兜底：从 test 文件名取前缀
        contract_name = str(Path(testfile_path).stem).split("_")[0]

    # 优先使用显式 meta_dir
    if meta_dir is not None:
        seeds_dir = Path(meta_dir).resolve()
    else:
        if test_kind == "functional":
            seeds_dir = pr / f"{contract_name}_meta" / "functional_test"
        elif test_kind == "invariant":
            seeds_dir = pr / f"{contract_name}_meta" / "invariant_test"
        else:
            raise ValueError(f"unknown test_kind: {test_kind}")

    trace_path = seeds_dir / "last_trace.txt"
    if not trace_path.exists():
        raise FileNotFoundError(f"trace file not found: {trace_path}")

    with open(trace_path, "r", encoding="utf-8", errors="ignore") as f:
        trace_text = f.read()

    source_text = None
    if source_path and os.path.exists(source_path):
        with open(source_path, "r", encoding="utf-8", errors="ignore") as f:
            source_text = f.read()

    raw_seeds = _parse_trace_for_pass_tests(trace_text, comp.get("contract") or contract_name, comp.get("abi") or [], source_text)
    if not raw_seeds:
        raw_seeds = _fallback_constructor_seed_from_source(
            comp.get("contract") or contract_name,
            comp.get("abi") or [],
            source_text,
        )
    clean_seeds, report = sanitize_seeds_for_fuzzer(raw_seeds, comp.get("abi") or [])

    try:
        report_path = seeds_dir / "discarded_seeds.json"
        report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    except Exception:
        pass

    return clean_seeds
