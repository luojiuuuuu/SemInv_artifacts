# utils/debug_tools.py
import re
import logging
from typing import Any, List, Dict

_ADDR_RE = re.compile(r"^0x[0-9a-fA-F]{40}$")

def is_hex_addr(x: Any) -> bool:
    try:
        s = x.hex() if isinstance(x, (bytes, bytearray)) else str(x)
        return bool(_ADDR_RE.match(s))
    except Exception:
        return False

def abbrev(x: Any, n: int = 120) -> str:
    if isinstance(x, (bytes, bytearray)):
        s = "0x" + x.hex()
    else:
        s = str(x)
    return s if len(s) <= n else s[:n] + f"...({len(s)} chars)"

def dump_interface_keys(interface: Dict[str, List[str]], logger: logging.Logger, title: str):
    # 仅打印前若干项，避免刷屏
    keys = list(interface.keys())
    head = keys[:12]
    logger.info("[IFACE] %s keys(sample=%d/%d): %s", title, len(head), len(keys), head)

def dump_seeds_quick(seeds: List, logger: logging.Logger, contract_address: str):
    if not seeds:
        logger.info("[SEEDS] no custom seeds")
        return
    logger.info("[SEEDS] total sequences: %d", len(seeds))
    for si, seq in enumerate(seeds[:3]):  # 仅预览前 3 条序列
        if isinstance(seq, dict):  # 你的“高层友好”单对象包装
            logger.info("[SEEDS][%d] high-level dict keys=%s", si, list(seq.keys()))
            continue
        if not isinstance(seq, list):
            logger.info("[SEEDS][%d] type=%s (skip preview)", si, type(seq))
            continue
        for ti, step in enumerate(seq[:3]):  # 每条序列只看前 3 步
            args = step.get("arguments", [])
            func = args[0] if isinstance(args, list) and args else None
            to_field = step.get("contract")
            logger.info("[SEEDS][%d][%d] func=%r  to(raw)=%s  is_addr=%s  is_ctor=%s",
                        si, ti, func, abbrev(to_field, 66), is_hex_addr(to_field), func == "constructor")
    logger.info("[SEEDS] contract_address to be used for normal calls: %s (is_addr=%s)",
                contract_address, is_hex_addr(contract_address))
