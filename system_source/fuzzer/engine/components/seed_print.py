# ======= BEGIN: Pretty print initial seed pool helpers (unwrap 'transaction') =======
import binascii
from typing import Any, Dict, List, Optional, Tuple
from eth_utils import keccak

def _safe_hex(data: Any) -> Optional[str]:
    if data is None:
        return None
    if isinstance(data, (bytes, bytearray)):
        return binascii.hexlify(data).decode().lower()
    if isinstance(data, str):
        s = data.lower()
        return s[2:] if s.startswith("0x") else s
    return None

def _first8(sel_hex: Optional[str]) -> Optional[str]:
    if not sel_hex:
        return None
    return sel_hex[:8] if len(sel_hex) >= 8 else None

def _build_selector_to_name_map_from_abi(abi: Optional[List[Dict[str, Any]]]) -> Dict[str, str]:
    """用 ABI 构建 selector(8 hex，不带0x) -> 函数名。"""
    mapping: Dict[str, str] = {}
    if not abi:
        return mapping
    for item in abi:
        if item.get("type") != "function":
            continue
        name = item.get("name", "")
        arg_types = [inp.get("type", "bytes") for inp in item.get("inputs", [])]
        sig_text = f"{name}({','.join(arg_types)})"
        selector_hex = keccak(text=sig_text)[:4].hex()  # keccak256(sig)前4字节
        mapping[selector_hex] = name
    return mapping

def _format_arg(v: Any) -> str:
    if isinstance(v, (bytes, bytearray)):
        hx = binascii.hexlify(v).decode()
        return "0x" + (hx[:8] + "…") if len(hx) > 8 else "0x" + hx
    if isinstance(v, str):
        if v.startswith("0x") and len(v) > 14:
            return v[:14] + "…"
        return v
    if isinstance(v, (list, tuple)):
        return "[" + ", ".join(_format_arg(x) for x in v) + "]"
    if isinstance(v, dict):
        keys = list(v.keys())
        inner = ", ".join(f"{k}={_format_arg(v[k])}" for k in keys[:4])
        if len(keys) > 4:
            inner += ", …"
        return "{" + inner + "}"
    return str(v)

def _name_from_signature_like(sig: str) -> Optional[str]:
    if not isinstance(sig, str) or not sig:
        return None
    p = sig.find("(")
    return sig[:p] if p >= 0 else sig

def _unwrap_tx_layer(tx: Dict[str, Any]) -> Dict[str, Any]:
    """
    下钻一层，把最外层的 {block, environment, global_state, transaction} 解开，
    返回真正承载函数调用信息的交易字典。
    """
    if not isinstance(tx, dict):
        return {}
    # 常见包装：{'block':..., 'environment':..., 'global_state':..., 'transaction': {...}}
    if "transaction" in tx and isinstance(tx["transaction"], dict):
        return tx["transaction"]
    # 个别实现可能用 'message' 或 'call'
    if "message" in tx and isinstance(tx["message"], dict):
        return tx["message"]
    if "call" in tx and isinstance(tx["call"], dict):
        return tx["call"]
    # 已经是扁平交易
    return tx

def _extract_args_from_any(tx_flat: Dict[str, Any]) -> List[Any]:
    """尽可能多地兼容参数字段名。"""
    for k in ("args", "arguments", "params", "parameters"):
        v = tx_flat.get(k)
        if isinstance(v, list):
            return v
    for k in ("arg", "argument"):
        if k in tx_flat:
            return [tx_flat[k]]
    # 有些实现把参数放在 'data_args' / 'decoded' 等字段
    for k in ("data_args", "decoded", "inputs"):
        v = tx_flat.get(k)
        if isinstance(v, list):
            return v
    return []

# —— 新增：判断 data 是否为空（没有 selector）——
def _is_empty_data_hex(tx_flat: Dict[str, Any]) -> bool:
    for k in ("data", "input", "calldata"):
        hx = _safe_hex(tx_flat.get(k))
        if hx is not None:
            # 空、"0x"、"0"、"00"... 都视为无有效 selector
            if len(hx.strip()) < 8:
                return True
            # 长度足够但不是 selector 情况在上层处理
            return False
    # 完全没有 data/input/calldata 也当作空
    return True

# —— 新增：判断 value 是否 > 0（用于区分 receive() vs fallback()）——
def _value_positive(tx_flat: Dict[str, Any]) -> bool:
    v = tx_flat.get("value")
    if v is None:
        return False
    try:
        if isinstance(v, str):
            # 兼容 "0x..." 或 十进制字符串
            vv = int(v, 16) if v.lower().startswith("0x") else int(v)
        else:
            vv = int(v)
        return vv > 0
    except Exception:
        return False
    
# —— 替换：更智能地从“已下钻”的交易中识别函数名（包含 receive/fallback 规则）——
def _guess_func_name_from_tx_flat(tx_flat: Dict[str, Any], selector_to_name: Dict[str, str]) -> Tuple[str, Optional[str]]:
    """
    返回 (函数名, 选择子前8位或None)。
    识别优先级：
      1) 直接名字字段（name/function/method/...）
      2) selector 字段（selector/method_id/sighash/...）
      3) 从 data/input/calldata 的前4字节取 selector
      4) 若 data 为空：有正 value → receive()；否则 → fallback()
      5) 其余 → unknown
    """
    # 1) 直接名字类字段
    for k in ("name", "function", "method", "fn", "func"):
        v = tx_flat.get(k)
        if isinstance(v, str) and v:
            n = _name_from_signature_like(v)
            if n:
                return n, None
        if isinstance(v, dict):
            vv = v.get("name")
            if isinstance(vv, str) and vv:
                n = _name_from_signature_like(vv)
                if n:
                    return n, None

    # 2) selector 字段
    for k in ("selector", "method_id", "sig_hash", "sighash", "methodSelector"):
        sel8 = _first8(_safe_hex(tx_flat.get(k)))
        if sel8:
            # 关键修正：00000000 当作“无选择子”，转 receive()/fallback
            if sel8 == "00000000":
                return ("receive" if _value_positive(tx_flat) else "fallback"), None
            if sel8 in selector_to_name:
                return selector_to_name[sel8], sel8
            return "unknown", sel8

    # 3) calldata / data / input
    for k in ("calldata", "data", "input"):
        sel8 = _first8(_safe_hex(tx_flat.get(k)))
        if sel8:
            # 同样对 00000000 进行 receive()/fallback 处理
            if sel8 == "00000000":
                return ("receive" if _value_positive(tx_flat) else "fallback"), None
            if sel8 in selector_to_name:
                return selector_to_name[sel8], sel8
            return "unknown", sel8

    # 4) data 为空：receive()/fallback()
    if _is_empty_data_hex(tx_flat):
        return ("receive" if _value_positive(tx_flat) else "fallback"), None

    # 5) 兜底
    return "unknown", None

# —— 替换：unknown 诊断，保留外层/内层键名与 selector 片段（若有）——
def _diagnose_unknown(tx_outer: Dict[str, Any], tx_flat: Dict[str, Any], sel8: Optional[str]) -> str:
    outer_keys = sorted(list(tx_outer.keys()))
    inner_keys = sorted(list(tx_flat.keys()))
    parts = [f"outer_keys={outer_keys}", f"inner_keys={inner_keys}"]
    if sel8:
        parts.append(f"sel={sel8}")
    else:
        # 如果没有 sel8，再提示一下 data 的简况，方便确认是否空 data
        dh = _safe_hex(tx_flat.get("data")) or _safe_hex(tx_flat.get("input")) or _safe_hex(tx_flat.get("calldata"))
        if dh is None:
            parts.append("data=None")
        else:
            parts.append(f"data_len={len(dh)}")
    return " {" + ", ".join(parts) + "}"

def pretty_print_initial_population(population, abi: Optional[List[Dict[str, Any]]] = None, logger=None):
    """
    打印第0代（初始种子池）为：func(arg1, arg2, ...)
    - 仅打印函数名+实参，不打印签名/selector。
    - 会自动下钻 tx['transaction'] 等内层拿字段。
    - 未识别时附带精简诊断（外层/内层键名、selector前8位）。
    """
    selector_to_name = _build_selector_to_name_map_from_abi(abi)
    lines = []
    individuals = getattr(population, "individuals", []) or []
    for idx, individual in enumerate(individuals):
        txs = getattr(individual, "solution", None) or getattr(individual, "chromosome", None) or []
        if not isinstance(txs, list):
            continue
        seq_texts = []
        for tx_outer in txs:
            if not isinstance(tx_outer, dict):
                seq_texts.append("<?>")
                continue
            tx_flat = _unwrap_tx_layer(tx_outer)
            fname, sel8 = _guess_func_name_from_tx_flat(tx_flat, selector_to_name)
            args = _extract_args_from_any(tx_flat)
            arg_str = ", ".join(_format_arg(a) for a in args)
            if fname == "unknown":
                seq_texts.append(f"unknown({arg_str}){_diagnose_unknown(tx_outer, tx_flat, sel8)}")
            else:
                seq_texts.append(f"{fname}({arg_str})")
        lines.append(f"  #{idx+1}: " + "  →  ".join(seq_texts))
    header = "=== Semantic Invariant Fuzz Backend: Initial Seed Pool (Generation 0) ==="
    tail = "=== End of Initial Seed Pool ==="
    text = "\n".join([header] + lines + [tail])
    if logger is not None:
        try:
            logger.info(text)
        except Exception:
            print(text)
    else:
        print(text)
    return text
# ======= END: Pretty print initial seed pool helpers (unwrap 'transaction') =======
