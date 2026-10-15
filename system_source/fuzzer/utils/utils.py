#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
import sys
import json
import shlex
import solcx
import logging
import eth_utils
import subprocess
import time
from typing import Any, Dict, List, Optional, Tuple
from web3 import Web3
from .settings import LOGGING_LEVEL
from eth_utils import keccak

def _long_path(path: str) -> str:
    resolved = os.path.abspath(path)
    if sys.platform != "win32" or resolved.startswith("\\\\?\\"):
        return resolved
    if resolved.startswith("\\\\"):
        return "\\\\?\\UNC\\" + resolved.lstrip("\\")
    return "\\\\?\\" + resolved


def _is_selector_key(k: str) -> bool:
    return isinstance(k, str) and k.lower().startswith("0x") and len(k) == 10

def _sig_from_abi_item(item: Dict[str, Any]) -> str:
    # item: {"type":"function","name": "...","inputs":[{"type":"address"},...]}
    name = item.get("name", "")
    inputs = item.get("inputs", []) or []
    arg_types = ",".join(inp.get("type", "") for inp in inputs)
    return f"{name}({arg_types})"

def _selector_of_signature(sig: str) -> str:
    return "0x" + keccak(text=sig)[:4].hex()

def build_selector_to_signature_map(
    interface: Dict[str, List[str]],
    abi: List[Dict[str, Any]]
) -> Tuple[Dict[str, str], List[str]]:
    """
    返回:
      mapping: { "0x095ea7b3": "approve(address,uint256)", ... }
      warnings: [ ... ]
    """
    warnings: List[str] = []

    # 1) 从 ABI 生成完整映射
    abi_map: Dict[str, str] = {}
    for item in abi:
        if item.get("type") != "function":
            continue
        sig = _sig_from_abi_item(item)  # name(type,...)
        sel = _selector_of_signature(sig)
        # 如果存在重载，会覆盖；若需保留全部，可改为 list
        abi_map[sel] = sig

    # 2) 以 interface 为“白名单”对齐（并补齐未知符号的可读占位签名）
    out_map: Dict[str, str] = {}
    for k, v in interface.items():
        if k in ("constructor", "fallback"):
            continue
        if not _is_selector_key(k):
            # interface 键不是 selector（不符合你当前数据，但兜底一下）
            continue

        if k in abi_map:
            out_map[k] = abi_map[k]
        else:
            # ABI 里没有：用 interface 的参数类型生成一个占位签名
            # e.g. unknown_0xb414d4b6(address,bool)
            arg_types = ",".join(v) if isinstance(v, list) else ""
            out_map[k] = f"unknown_{k}({arg_types})"
            warnings.append(f"[missing-in-abi] selector {k} not found in ABI; "
                            f"using placeholder signature '{out_map[k]}'")

    # 3) 可选：提示 ABI 有但 interface 没列出的 selector
    for sel, sig in abi_map.items():
        if sel not in interface:
            warnings.append(f"[missing-in-interface] selector {sel} '{sig}' is in ABI "
                            f"but not present in interface keys")

    return out_map, warnings

def _to_jsonable(v: Any):
    if v is None:
        return None
    if isinstance(v, (str, int, float, bool)):
        return v
    if isinstance(v, (bytes, bytearray)):
        return "0x" + bytes(v).hex()
    if isinstance(v, list):
        return [_to_jsonable(x) for x in v]
    if isinstance(v, dict):
        return {str(k): _to_jsonable(val) for k, val in v.items()}
    # fallback
    return str(v)

def _resolve_func_name(tok: str, selector_to_sig: Optional[Dict[str, str]] = None) -> str:
    """
    tok: could be 'constructor' / 'fallback' / '0x12345678' / '12345678' / full signature
    """
    if tok == "constructor" or tok == "fallback":
        return tok
    s = tok.lower()
    if s.startswith("0x") and len(s) == 10:  # 0x + 8 hex
        if selector_to_sig and s in selector_to_sig:
            return selector_to_sig[s]
        return s
    if len(s) == 8 and all(c in "0123456789abcdef" for c in s):
        s0 = "0x" + s
        if selector_to_sig and s0 in selector_to_sig:
            return selector_to_sig[s0]
        return s0
    # already a signature like name(type,...)
    return tok

def convert_gen0_dump_to_highlevel(
    dump_obj: Dict[str, Any],
    *,
    selector_to_sig: Optional[Dict[str, str]] = None,
    merge: bool = True
) -> List[Dict[str, Any]]:
    """
    将 dump_initial_generated_individuals_to_json 的输出结构，转换为高层表达形式。
    返回的结构形如你示例中的 [{constructor?:{...}, steps:[...]} , ...]
    """
    gen = dump_obj.get("generated_individuals", []) or []
    # 提取所有 chromosome->单笔tx
    txs: List[Dict[str, Any]] = []
    for item in gen:
        chrom = (item or {}).get("chromosome") or []
        if not chrom or not isinstance(chrom, list) or not isinstance(chrom[0], dict):
            continue
        txs.append(chrom[0])

    # 构建 constructor（若存在）
    constructor_block: Optional[Dict[str, Any]] = None
    steps: List[Dict[str, Any]] = []

    for tx in txs:
        args = tx.get("arguments", []) or []
        if not args or not isinstance(args, list):
            continue
        head = args[0]
        tail = args[1:]
        head_str = str(head)

        frm = tx.get("account") or tx.get("from")
        if not frm:
            # 尽量继续
            frm = ""

        func_name = _resolve_func_name(head_str, selector_to_sig)

        # constructor 单独处理。其余都进 steps
        if func_name == "constructor":
            # 只保留 "from"、"value"、"args"
            if constructor_block is None:
                constructor_block = {
                    "args": [_to_jsonable(a) for a in tail],
                    "from": frm,
                    "value": tx.get("amount", 0) or 0,
                }
            else:
                # 如果有多个 constructor，保留第一个，其余转成普通 step
                steps.append({
                    "func": func_name,
                    "args": [_to_jsonable(a) for a in tail],
                    "from": frm
                })
        elif func_name == "fallback":
            # 你也可以选择忽略 fallback；这里保留一条可见记录
            steps.append({
                "func": "fallback",
                "args": [],
                "from": frm
            })
        else:
            steps.append({
                "func": func_name,
                "args": [_to_jsonable(a) for a in tail],
                "from": frm
            })

    if merge:
        out_seq = {}
        if constructor_block is not None:
            out_seq["constructor"] = constructor_block
        out_seq["steps"] = steps
        return [out_seq]

    # 不合并：每一笔成为单独条目（constructor 作为第一条的 constructor 字段）
    out: List[Dict[str, Any]] = []
    if constructor_block is not None:
        out.append({"constructor": constructor_block, "steps": []})
    for st in steps:
        out.append({"steps": [st]})
    return out

def convert_gen0_dump_file_to_highlevel(
    in_path: str,
    out_path: str,
    *,
    selector_to_sig: Optional[Dict[str, str]] = None,
    merge: bool = True
) -> str:
    with open(in_path, "r", encoding="utf-8") as f:
        dump_obj = json.load(f)
    hi = convert_gen0_dump_to_highlevel(dump_obj, selector_to_sig=selector_to_sig, merge=merge)
    payload = {
        "sequences": hi,
        "meta": {
            "source": in_path,
            "timestamp": int(time.time()),
            "count": sum(len(item.get("steps", [])) for item in hi),
        },
    }
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    return out_path

def _make_json_serializable(obj: Any):
    """
    Convert common non-serializable objects (bytearray/bytes) to JSON-friendly forms.
    Recurses into lists/dicts.
    """
    if obj is None:
        return None
    if isinstance(obj, (str, int, float, bool)):
        return obj
    if isinstance(obj, (bytes, bytearray)):
        # return hex string
        return "0x" + bytes(obj).hex()
    if isinstance(obj, list) or isinstance(obj, tuple):
        return [_make_json_serializable(v) for v in obj]
    if isinstance(obj, dict):
        return {str(k): _make_json_serializable(v) for k, v in obj.items()}
    # fallback: stringify
    try:
        return str(obj)
    except Exception:
        return None

def dump_initial_generated_individuals_to_json(population, path: str = None) -> str:
    """
    Export initial (generation-0) individuals that were *generated by the fuzzer*
    (i.e. NOT custom-injected seeds) into a JSON file.

    :param population: Population instance after population.init() has been called.
                       population.individuals should be a list-like of Individual objects.
    :param path: optional output file path. If None, creates seed_dump_{timestamp}.json in cwd.
    :return: the actual path written.
    """
    if path is None:
        path = f"seed_dump_gen0_{int(time.time())}.json"

    out = {"generated_individuals": [], "meta": {"count": 0, "timestamp": int(time.time())}}

    for idx, indv in enumerate(population.individuals):
        try:
            chrom = getattr(indv, "chromosome", None)
        except Exception:
            chrom = None

        # Defensive: skip if no chromosome
        if not chrom:
            continue

        # Determine whether this individual came from a custom seed:
        # We assume custom seed pipeline marks seed steps with "__origin__"=="seed" or "__seed_id__"
        first_step = None
        if isinstance(chrom, list) and len(chrom) > 0 and isinstance(chrom[0], dict):
            first_step = chrom[0]
        is_seed_origin = False
        if isinstance(first_step, dict):
            if first_step.get("__origin__") == "seed" or ("__seed_id__" in first_step):
                is_seed_origin = True

        # Only include fuzzer-generated individuals (not custom seed origin)
        if is_seed_origin:
            # skip custom seeds
            continue

        entry = {"index": idx}

        # include raw chromosome (serializable)
        try:
            entry["chromosome"] = _make_json_serializable(chrom)
        except Exception:
            entry["chromosome"] = str(chrom)

        # Try to decode into the execution-ready 'solution' (transaction/block/global_state/env)
        try:
            # decode may cache into indv.solution or may call encode — it's okay.
            sol = indv.decode() if getattr(indv, "decode", None) else None
            entry["solution"] = _make_json_serializable(sol)
        except Exception as e:
            # If decode fails, store the error and fallback to chromosome only
            entry["decode_error"] = str(e)
            entry["solution"] = None

        out["generated_individuals"].append(entry)

    out["meta"]["count"] = len(out["generated_individuals"])

    # write json
    # ensure directory exists
    dirname = os.path.dirname(path)
    if dirname:
        os.makedirs(_long_path(dirname), exist_ok=True)

    with open(_long_path(path), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=2, ensure_ascii=False)

    # return path for convenience
    return os.path.abspath(path)

class _MaxLevelFilter(logging.Filter):
    def __init__(self, max_level):
        super().__init__()
        self.max_level = max_level

    def filter(self, record):
        return record.levelno <= self.max_level


def _configure_split_stream_logging():
    root = logging.getLogger()
    if getattr(root, "_semantic_split_stream_configured", False):
        return
    fmt = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.DEBUG)
    stdout_handler.addFilter(_MaxLevelFilter(logging.WARNING))
    stdout_handler.setFormatter(fmt)

    stderr_handler = logging.StreamHandler(sys.stderr)
    stderr_handler.setLevel(logging.ERROR)
    stderr_handler.setFormatter(fmt)

    root.handlers.clear()
    root.addHandler(stdout_handler)
    root.addHandler(stderr_handler)
    root.setLevel(LOGGING_LEVEL)
    root._semantic_split_stream_configured = True


def initialize_logger(name):
    logger = logging.getLogger(name)
    logger.title = lambda *a: logger.info(*[bold(x) for x in a])
    logger_error = logger.error
    logger.error = lambda *a: logger_error(*[red(bold(x)) for x in a])
    logger_warning = logger.warning
    logger.warning = lambda *a: logger_warning(*[red(bold(x)) for x in a])
    logger.setLevel(level=LOGGING_LEVEL)
    _configure_split_stream_logging()
    return logger

def bold(x):
    return "".join(['\033[1m', x, '\033[0m']) if isinstance(x, str) else x

def red(x):
    return "".join(['\033[91m', x, '\033[0m']) if isinstance(x, str) else x

def code_bool(value: bool):
    return str(int(value)).zfill(64)

def code_uint(value):
    return hex(value).replace("0x", "").zfill(64)

def code_int(value):
    return hex(value).replace("0x", "").zfill(64)

def code_address(value):
    return value.zfill(64)

def code_bytes(value):
    return value.ljust(64, "0")

def code_type(value, type):
    if type == "bool":
        return code_bool(value)
    elif type.startswith("uint"):
        return code_uint(value)
    elif type.startswith("int"):
        return code_int(value)
    elif type == "address":
        return code_address(value)
    elif type.startswith("bytes"):
        return code_bytes(value)
    else:
        raise Exception()

def run_command(cmd):
    FNULL = open(os.devnull, 'w')
    p = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=FNULL)
    return p.communicate()[0]

# def compile(solc_version, evm_version, source_code_file):
#     out = None
#     source_code = ""
#     with open(source_code_file, 'r', encoding="utf-8") as file:
#         source_code = file.read()
#     try:
#         if not str(solc_version).startswith("v"):
#             solc_version = "v"+str(solc_version.truncate())
#         if not solc_version in solcx.get_installed_solc_versions():
#             solcx.install_solc(solc_version)
#         solcx.set_solc_version(solc_version, True)
#         out = solcx.compile_standard({
#             'language': 'Solidity',
#             'sources': {source_code_file: {'content': source_code}},
#             'settings': {
#                 "optimizer": {
#                     "enabled": True,
#                     "runs": 200
#                 },
#                 "evmVersion": evm_version,
#                 "outputSelection": {
#                     source_code_file: {
#                         "*":
#                             [
#                                 "abi",
#                                 "evm.deployedBytecode",
#                                 "evm.bytecode.object",
#                                 "evm.legacyAssembly",
#                             ],
#                         "": [
#                                 "ast"
#                             ]
#                     }
#                 }
#             }
#         }, allow_paths='.')
#     except Exception as e:
#         print("Error: Solidity compilation failed!")
#         print(e.message)
#     return out

# from pathlib import Path
# import solcx

# def compile(solc_version, evm_version, source_code_file):
#     out = None
#     source_code_file = str(Path(source_code_file).resolve())

#     with open(source_code_file, "r", encoding="utf-8") as file:
#         source_code = file.read()

#     try:
#         # 兼容传入 "0.8.24" / "v0.8.24"
#         solc_version = str(solc_version).strip()
#         if not solc_version.startswith("v"):
#             solc_version = "v" + solc_version

#         installed = [f"v{x}" for x in solcx.get_installed_solc_versions()]
#         if solc_version not in installed:
#             solcx.install_solc(solc_version)

#         solcx.set_solc_version(solc_version, True)

#         out = solcx.compile_standard(
#             {
#                 "language": "Solidity",
#                 "sources": {
#                     source_code_file: {
#                         "content": source_code
#                     }
#                 },
#                 "settings": {
#                     "optimizer": {
#                         "enabled": True,
#                         "runs": 200
#                     },
#                     "evmVersion": evm_version,
#                     "outputSelection": {
#                         source_code_file: {
#                             "*": [
#                                 "abi",
#                                 "evm.deployedBytecode",
#                                 "evm.bytecode.object",
#                                 "evm.legacyAssembly"
#                             ],
#                             "": [
#                                 "ast"
#                             ]
#                         }
#                     }
#                 }
#             },
#             allow_paths=str(Path(source_code_file).parent)
#         )

#     except Exception as e:
#         print("Error: Solidity compilation failed!")
#         print(str(e))

#     return out

from pathlib import Path
import solcx


def _build_output_selection(source_code_file: str, with_ir: bool = True):
    star_outputs = [
        "abi",
        "evm.deployedBytecode",
        "evm.bytecode.object",
        "evm.legacyAssembly",
        "storageLayout",
    ]

    if with_ir:
        star_outputs.extend([
            "ir",
            "irOptimized",
        ])

    return {
        "*": {
            "*": star_outputs,
            "": [
                "ast"
            ]
        }
    }


def _parse_solc_version_tuple(solc_version: str):
    s = str(solc_version).strip().lower()
    if s.startswith("v"):
        s = s[1:]
    parts = s.split(".")
    nums = []
    for p in parts[:3]:
        try:
            nums.append(int(p))
        except Exception:
            nums.append(0)
    while len(nums) < 3:
        nums.append(0)
    return tuple(nums)


def _should_try_ir(solc_version: str, extra_outputs: bool = True) -> bool:
    """
    老版本 solc（尤其 0.8.0 一类）在 modifier / 某些语法上生成 IR 不稳定，
    默认只对较新的版本尝试 IR。
    """
    if not extra_outputs:
        return False

    v = _parse_solc_version_tuple(solc_version)

    # 经验阈值：0.8.13+ 再默认尝试 IR 更稳
    # 你也可以放宽到 0.8.10 或 0.8.6，但 0.8.0 明显不建议
    return v >= (0, 8, 13)


def _apply_legacy_source_compatibility(source_code_file: str, source_code: str, solc_version: str) -> str:
    """
    Keep historically important 0.4.x benchmarks usable with py-solc-x.

    Some old SB/Parity samples pin solc 0.4.9, which py-solc-x cannot install on
    Windows. The target contract used by our experiments is WalletLibrary, but
    the same file also contains later wallet wrapper contracts with inline
    assembly that fails on 0.4.11+. Trimming the wrappers preserves the target
    benchmark contract and avoids compiling unreachable incompatible code.
    """
    path_l = str(source_code_file or "").replace("\\", "/").lower()
    source_code = _deduplicate_spdx_license_identifiers(source_code, source_code_file)
    if (
        path_l.endswith("parity_wallet_bug_1.sol")
        and "contract WalletLibrary" in source_code
        and "\ncontract Wallet is WalletEvents" in source_code
    ):
        source_code = re.sub(
            r"\bpragma\s+solidity\s+0\.4\.9\s*;",
            "pragma solidity >=0.4.11 <0.5.0;",
            source_code,
            count=1,
        )
        split_at = source_code.find("\ncontract Wallet is WalletEvents")
        if split_at > 0:
            source_code = source_code[:split_at].rstrip() + "\n"
            print("[compile] legacy compatibility: trimmed parity wallet wrappers after WalletLibrary")
    if path_l.endswith("governmental_survey.sol") and "contract Governmental" in source_code:
        updated = source_code
        updated = re.sub(
            r"\bfunction\s+Governmental\s*\(\s*\)\s*\{",
            "function Governmental() payable {",
            updated,
            count=1,
        )
        updated = re.sub(
            r"\bfunction\s+invest\s*\(\s*\)\s*\{",
            "function invest() payable {",
            updated,
            count=1,
        )
        if updated != source_code:
            source_code = updated
            print("[compile] legacy compatibility: added payable to Governmental value-entry functions")
    return source_code


def read_source_with_legacy_compatibility(source_code_file: str, solc_version: str = "") -> str:
    with open(source_code_file, "r", encoding="utf-8") as file:
        source_code = file.read()
    return _apply_legacy_source_compatibility(source_code_file, source_code, solc_version)


def _deduplicate_spdx_license_identifiers(source_code: str, source_code_file: str = "") -> str:
    """Keep concatenated historical sources compilable without editing them.

    Several Trace2Inv public sources are flattened files assembled from many
    contracts.  Newer solc releases reject more than one SPDX identifier in a
    single standard-json source.  For analysis we keep the first SPDX line and
    turn later SPDX declarations into ordinary comments in the in-memory
    compilation input only.
    """
    seen = False
    changed = False
    lines = []
    for line in source_code.splitlines(keepends=True):
        if re.match(r"^\s*//\s*SPDX-License-Identifier\s*:", line):
            if seen:
                line = re.sub(
                    r"SPDX-License-Identifier\s*:",
                    "flattened license identifier:",
                    line,
                    count=1,
                )
                changed = True
            else:
                seen = True
        lines.append(line)
    if changed:
        print(f"[compile] source compatibility: deduplicated SPDX identifiers for {source_code_file}")
    return "".join(lines)


def _normalize_legacy_standard_json_keys(out: Dict[str, Any], source_code_file: str) -> Dict[str, Any]:
    if not isinstance(out, dict):
        return out
    canonical = str(Path(source_code_file).resolve())
    contracts = out.get("contracts")
    if isinstance(contracts, dict) and canonical not in contracts and len(contracts) == 1:
        only_key = next(iter(contracts.keys()))
        out["contracts"] = {canonical: contracts[only_key]}
        contracts = out.get("contracts")
    if isinstance(contracts, dict):
        for source_key, source_contracts in list(contracts.items()):
            if not isinstance(source_contracts, dict):
                continue
            normalized_contracts: Dict[str, Any] = {}
            changed = False
            for contract_key, meta in source_contracts.items():
                short_name = str(contract_key).split(":")[-1]
                if short_name != contract_key and short_name not in source_contracts:
                    normalized_contracts[short_name] = meta
                    changed = True
                else:
                    normalized_contracts[contract_key] = meta
            if changed:
                contracts[source_key] = normalized_contracts
    return out


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _benchmark_source_package_root(source_code_file: str) -> Optional[Path]:
    source = Path(source_code_file).resolve()
    for parent in [source.parent, *source.parents]:
        if parent.parent.name in {"sources", "external_sources"} and parent.parent.parent.name == "seminv_benchmarks":
            return parent
    return None


def _compile_allow_paths(source_code_file: str) -> str:
    root = _repo_root()
    package_root = _benchmark_source_package_root(source_code_file)
    candidates = [
        Path(source_code_file).resolve().parent,
        package_root,
        package_root / "node_modules" if package_root else None,
        package_root / "packages" if package_root else None,
        root,
        root / "src",
        root / "src" / "test",
        root / "foundry" / "lib",
    ]
    if package_root:
        candidates.extend(sorted((package_root / "packages").glob("*")))
    paths = []
    for candidate in candidates:
        if candidate and candidate.exists():
            value = candidate.as_posix()
            if value not in paths:
                paths.append(value)
    return ",".join(paths)


def _compile_remappings(source_code_file: str = "") -> List[str]:
    root = _repo_root()
    forge_std_src = root / "foundry" / "lib" / "forge-std" / "src"
    remappings: List[str] = []
    if forge_std_src.exists():
        remappings.append(f"forge-std/={forge_std_src.as_posix()}/")
    package_root = _benchmark_source_package_root(source_code_file) if source_code_file else None
    if package_root:
        for scope_dir in sorted(package_root.glob("@*")):
            if scope_dir.is_dir():
                remappings.append(f"{scope_dir.name}/={scope_dir.as_posix()}/")
        node_modules = package_root / "node_modules"
        if node_modules.exists():
            for scope_dir in sorted(node_modules.glob("@*")):
                if scope_dir.is_dir():
                    remappings.append(f"{scope_dir.name}/={scope_dir.as_posix()}/")
        packages = package_root / "packages"
        if packages.exists():
            for package_dir in sorted(packages.iterdir()):
                if package_dir.is_dir():
                    remappings.append(
                        f"@nomad-xyz/{package_dir.name}/={package_dir.as_posix()}/"
                    )
    return remappings


def _version_tuple(version: str) -> Optional[tuple]:
    m = re.match(r"^v?(\d+)\.(\d+)\.(\d+)$", str(version).strip())
    if not m:
        return None
    return tuple(int(x) for x in m.groups())


def _select_installed_patch_fallback(requested: str, installed_versions: List[str]) -> Optional[str]:
    req = _version_tuple(requested)
    if not req:
        return None
    same_minor = []
    for item in installed_versions:
        vt = _version_tuple(item)
        if vt and vt[0] == req[0] and vt[1] == req[1] and vt[2] >= req[2]:
            same_minor.append((vt, item if str(item).startswith("v") else "v" + str(item)))
    if not same_minor:
        return None
    same_minor.sort()
    return same_minor[0][1]


def _relax_exact_patch_pragma_for_fallback(source_code: str, requested: str, fallback: str) -> str:
    req = _version_tuple(requested)
    fb = _version_tuple(fallback)
    if not req or not fb or req[:2] != fb[:2]:
        return source_code
    exact = f"{req[0]}.{req[1]}.{req[2]}"
    upper = f"{req[0]}.{req[1] + 1}.0"
    relaxed = f">={exact} <{upper}"
    pattern = re.compile(rf"(\bpragma\s+solidity\s+){re.escape(exact)}(\s*;)")
    updated, n = pattern.subn(rf"\1{relaxed}\2", source_code)
    if n:
        print(f"[compile] source compatibility: relaxed exact pragma {exact} to {relaxed} for installed {fallback}")
    return updated


def _build_standard_json_sources(
    source_code_file: str,
    primary_source_code: str,
    requested_solc: str,
    effective_solc: str,
) -> Dict[str, Dict[str, str]]:
    """Build standard-json sources with package-wide compatibility overlays.

    py-solc-x applies the in-memory compatibility rewrite only to sources we
    pass in standard-json.  Imported package files otherwise come from disk
    unchanged.  When we use an installed patch-compatible fallback compiler
    (e.g. requested 0.7.5, installed 0.7.6), exact pragmas in imported files can
    reject the fallback even though the code is patch-compatible.  Include
    package-local Solidity files as in-memory sources and apply the same
    non-persistent compatibility rewrite to each of them.
    """
    source_key = Path(source_code_file).resolve().as_posix()
    sources: Dict[str, Dict[str, str]] = {
        source_key: {"content": primary_source_code}
    }

    req = _version_tuple(requested_solc)
    eff = _version_tuple(effective_solc)
    if not req or not eff or req == eff or req[:2] != eff[:2]:
        return sources

    package_root = _benchmark_source_package_root(source_code_file)
    if not package_root or not package_root.exists():
        return sources

    for path in package_root.rglob("*.sol"):
        try:
            key = path.resolve().as_posix()
            if key == source_key:
                continue
            text = read_source_with_legacy_compatibility(str(path), requested_solc)
            text = _relax_exact_patch_pragma_for_fallback(text, requested_solc, effective_solc)
            sources[key] = {"content": text}
        except Exception:
            continue
    return sources


def compile(solc_version, evm_version, source_code_file, extra_outputs=True):

    print("[compile] using file:", __file__)
    print("[compile] extra_outputs:", extra_outputs)

    out = None
    source_code_file = str(Path(source_code_file).resolve())

    try:
        solc_version = str(solc_version).strip()
        if not solc_version.startswith("v"):
            solc_version = "v" + solc_version
        requested_solc_version = solc_version
        source_code = read_source_with_legacy_compatibility(source_code_file, solc_version)

        installed = [f"v{x}" for x in solcx.get_installed_solc_versions()]
        if solc_version not in installed:
            fallback_solc = _select_installed_patch_fallback(solc_version, installed)
            if fallback_solc:
                source_code = _relax_exact_patch_pragma_for_fallback(
                    source_code,
                    solc_version,
                    fallback_solc,
                )
                print(f"[compile] using installed patch-compatible solc {fallback_solc} instead of missing {solc_version}")
                solc_version = fallback_solc
            else:
                solcx.install_solc(solc_version)

        solcx.set_solc_version(solc_version, True)

        base_input = {
            "language": "Solidity",
            "sources": _build_standard_json_sources(
                source_code_file,
                source_code,
                requested_solc_version,
                solc_version,
            ),
            "settings": {
                "optimizer": {
                    "enabled": True,
                    "runs": 200
                },
                "evmVersion": evm_version,
            }
        }
        remappings = _compile_remappings(source_code_file)
        if remappings:
            base_input["settings"]["remappings"] = remappings

        allow_paths = _compile_allow_paths(source_code_file)

        try_ir = _should_try_ir(solc_version, extra_outputs=extra_outputs)

        # -------------------------------------------------
        # 第一轮：按版本条件尝试带 IR
        # -------------------------------------------------
        if try_ir:
            try:
                input_json = dict(base_input)
                input_json["settings"] = dict(base_input["settings"])
                input_json["settings"]["outputSelection"] = _build_output_selection(
                    source_code_file,
                    with_ir=True
                )

                out = solcx.compile_standard(
                    input_json,
                    allow_paths=allow_paths
                )

                out = _normalize_legacy_standard_json_keys(out, source_code_file)
                out["_extra_ir_enabled"] = True
                return out

            except Exception as e1:
                err_text = str(e1)
                print("[compile] IR-enabled compile failed, fallback without IR.")
                print("[compile] reason:", err_text)

                # 继续降级到无 IR
                input_json = dict(base_input)
                input_json["settings"] = dict(base_input["settings"])
                input_json["settings"]["outputSelection"] = _build_output_selection(
                    source_code_file,
                    with_ir=False
                )

                out = solcx.compile_standard(
                    input_json,
                    allow_paths=allow_paths
                )

                out = _normalize_legacy_standard_json_keys(out, source_code_file)
                out["_extra_ir_enabled"] = False
                out["_extra_ir_error"] = err_text
                return out

        # -------------------------------------------------
        # 不尝试 IR：直接走无 IR
        # -------------------------------------------------
        input_json = dict(base_input)
        input_json["settings"] = dict(base_input["settings"])
        input_json["settings"]["outputSelection"] = _build_output_selection(
            source_code_file,
            with_ir=False
        )

        out = solcx.compile_standard(
            input_json,
            allow_paths=allow_paths
        )

        out = _normalize_legacy_standard_json_keys(out, source_code_file)
        out["_extra_ir_enabled"] = False
        out["_extra_ir_error"] = "IR disabled by version gate or extra_outputs=False"
        return out

    except Exception as e:
        print("Error: Solidity compilation failed!")
        print(str(e))
        return None

def get_interface_from_abi(abi):
    interface = {}
    for field in abi:
        if field['type'] == 'function':
            function_name = field['name']
            function_inputs = []
            signature = function_name + '('
            for i in range(len(field['inputs'])):
                input_type = field['inputs'][i]['type']
                function_inputs.append(input_type)
                signature += input_type
                if i < len(field['inputs']) - 1:
                    signature += ','
            signature += ')'
            hash = keccak(text=signature)[0:4].hex()
            interface[hash] = function_inputs
        elif field['type'] == 'constructor':
            function_inputs = []
            for i in range(len(field['inputs'])):
                input_type = field['inputs'][i]['type']
                function_inputs.append(input_type)
            interface['constructor'] = function_inputs
    if not "fallback" in interface:
        interface["fallback"] = []
    return interface

def get_function_signature_mapping(abi):
    mapping = {}
    for field in abi:
        if field['type'] == 'function':
            function_name = field['name']
            function_inputs = []
            signature = function_name + '('
            for i in range(len(field['inputs'])):
                input_type = field['inputs'][i]['type']
                signature += input_type
                if i < len(field['inputs']) - 1:
                    signature += ','
            signature += ')'
            hash = keccak(text=signature)[0:4].hex()
            mapping[hash] = signature
    if not "fallback" in mapping:
        mapping["fallback"] = "fallback"
    return mapping

def remove_swarm_hash(bytecode):
    if isinstance(bytecode, str):
        if bytecode.endswith("0029"):
            bytecode = re.sub(r"a165627a7a72305820\S{64}0029$", "", bytecode)
        if bytecode.endswith("0033"):
            bytecode = re.sub(r"5056fe.*?0033$", "5056", bytecode)
    return bytecode

def get_pcs_and_jumpis(bytecode):
    bytecode = bytes.fromhex(remove_swarm_hash(bytecode).replace("0x", ""))
    i = 0
    pcs = []
    jumpis = []
    while i < len(bytecode):
        opcode = bytecode[i]
        pcs.append(i)
        if opcode == 87: # JUMPI
            jumpis.append(hex(i))
        if opcode >= 96 and opcode <= 127: # PUSH
            size = opcode - 96 + 1
            i += size
        i += 1
    if len(pcs) == 0:
        pcs = [0]
    return (pcs, jumpis)

def convert_stack_value_to_int(stack_value):
    if stack_value[0] == int:
        return stack_value[1]
    elif stack_value[0] == bytes:
        return int.from_bytes(stack_value[1], "big")
    else:
        raise Exception("Error: Cannot convert stack value to int. Unknown type: " + str(stack_value[0]))

def convert_stack_value_to_hex(stack_value):
    if stack_value[0] == int:
        return hex(stack_value[1]).replace("0x", "").zfill(64)
    elif stack_value[0] == bytes:
        return stack_value[1].hex().zfill(64)
    else:
        raise Exception("Error: Cannot convert stack value to hex. Unknown type: " + str(stack_value[0]))

def is_fixed(value):
    return isinstance(value, int)

def split_len(seq, length):
    return [seq[i:i + length] for i in range(0, len(seq), length)]

def print_individual_solution_as_transaction(logger, individual_solution, color="", function_signature_mapping={}, transaction_index=None):
    for index, input in enumerate(individual_solution):
        transaction = input["transaction"]
        if not transaction["to"] == None:
            if transaction["data"].startswith("0x"):
                hash = transaction["data"][0:10]
            else:
                hash = transaction["data"][0:8]
            if len(individual_solution) == 1 or (transaction_index != None and transaction_index == 0):
                if hash in function_signature_mapping:
                    logger.title(color+"Transaction - " + function_signature_mapping[hash] + ":")
                else:
                    logger.title(color+"Transaction:")
            else:
                if hash in function_signature_mapping:
                    logger.title(color+"Transaction " + str(index + 1) + " - " + function_signature_mapping[hash] + ":")
                else:
                    logger.title(color+"Transaction " + str(index + 1) + ":")
            logger.title(color+"-----------------------------------------------------")
            logger.title(color+"From:      " + transaction["from"])
            logger.title(color+"To:        " + str(transaction["to"]))
            logger.title(color+"Value:     " + str(transaction["value"]) + " Wei")
            logger.title(color+"Gas Limit: " + str(transaction["gaslimit"]))
            i = 0
            for data in split_len("0x" + transaction["data"].replace("0x", ""), 42):
                if i == 0:
                    logger.title(color+"Input:     " + str(data))
                else:
                    logger.title(color+"           " + str(data))
                i += 1
            logger.title(color+"-----------------------------------------------------")
            if transaction_index != None and index + 1 > transaction_index:
                break

def normalize_32_byte_hex_address(value):
    as_bytes = eth_utils.to_bytes(hexstr=value)
    return eth_utils.to_normalized_address(as_bytes[-20:])

#--------------new---------------#
# ==================================
# SWC-132 helper funcs
# ==================================

from z3 import is_app, is_const, is_expr

def detect_balance_in_expr(expr):
    """
    Detect whether a Z3 expression depends on contract balance.
    Specifically checks for:
        - BALANCE opcode symbolic variables
        - address(this).balance patterns
        - variable names containing 'balance'
    """

    found = False

    def traverse(e):
        nonlocal found

        if not is_expr(e) or found:
            return

        # Check constant symbolic variable
        if is_const(e):
            name = str(e)

            # Heuristic matching
            if any(keyword in name.lower() for keyword in [
                "balance",
                "this.balance",
                "address(this)",
                "bal_",
                "balance_"
            ]):
                found = True
                return

        # Recursively inspect children
        if is_app(e):
            for child in e.children():
                traverse(child)

    traverse(expr)
    return found
