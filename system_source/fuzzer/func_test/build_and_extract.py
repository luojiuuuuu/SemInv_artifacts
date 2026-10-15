# -*- coding: utf-8 -*-
import os, json, re
from pathlib import Path
from typing import Dict, Any, Tuple, List, Optional

# 复用你现有的工具
from ..utils import settings
from ..utils.utils import compile as sol_compile
from ..utils.utils import get_function_signature_mapping
from ..utils.settings import EVM_VERSION

EMPTY_ABI_OR_NO_EXTERNAL_ENTRY = "empty_abi_or_no_external_entry"
ABSTRACT_OR_BASE_CONTRACT = "abstract_or_base_contract"
NO_DEPLOYABLE_CONTRACT = "no_deployable_contract"

_BASE_LIKE_CONTRACT_NAMES = {
    "ownable",
    "context",
    "safemath",
    "reentrancyguard",
    "erc20interface",
    "ierc20",
    "erc721interface",
    "ierc721",
}


def _bytecode_object(meta: Dict[str, Any], section: str) -> str:
    return str(meta.get("evm", {}).get(section, {}).get("object") or "")


def _is_hex_bytecode(value: str) -> bool:
    value = (value or "").strip()
    if not value:
        return False
    if "__" in value or "$" in value:
        return False
    return bool(re.fullmatch(r"[0-9a-fA-F]+", value))


def _abi_functions(abi: Any) -> List[Dict[str, Any]]:
    if not isinstance(abi, list):
        return []
    return [item for item in abi if isinstance(item, dict) and item.get("type") == "function"]


def _abi_mutating_functions(abi: Any) -> List[Dict[str, Any]]:
    return [
        fn for fn in _abi_functions(abi)
        if fn.get("stateMutability") not in ("view", "pure")
    ]


def _is_base_like_contract(name: str, abi: Any) -> bool:
    lname = (name or "").lower()
    if lname in _BASE_LIKE_CONTRACT_NAMES:
        return True
    funcs = _abi_functions(abi)
    mutating = _abi_mutating_functions(abi)
    return bool(funcs) and not mutating and any(token in lname for token in ("interface", "abstract"))


def _candidate_info(name: str, meta: Dict[str, Any]) -> Dict[str, Any]:
    abi = meta.get("abi") or []
    deploy_bc = _bytecode_object(meta, "bytecode")
    runtime_bc = _bytecode_object(meta, "deployedBytecode")
    funcs = _abi_functions(abi)
    mutating = _abi_mutating_functions(abi)
    has_abi = bool(abi)
    has_external_entry = bool(funcs)
    has_bytecode = _is_hex_bytecode(deploy_bc) and _is_hex_bytecode(runtime_bc)
    deployable = has_abi and has_external_entry and has_bytecode
    return {
        "name": name,
        "has_abi": has_abi,
        "has_external_entry": has_external_entry,
        "has_bytecode": has_bytecode,
        "deployable": deployable,
        "function_count": len(funcs),
        "mutating_function_count": len(mutating),
        "bytecode_len": len(deploy_bc),
        "base_like": _is_base_like_contract(name, abi),
    }


def _rank_deployable(info: Dict[str, Any]) -> Tuple[int, int, int, int]:
    return (
        0 if info.get("base_like") else 1,
        int(info.get("mutating_function_count") or 0),
        int(info.get("function_count") or 0),
        int(info.get("bytecode_len") or 0),
    )


def _contract_selection_error_type(candidates: List[Dict[str, Any]]) -> str:
    if not candidates:
        return NO_DEPLOYABLE_CONTRACT
    if not any(c.get("has_external_entry") for c in candidates):
        return EMPTY_ABI_OR_NO_EXTERNAL_ENTRY
    if any(c.get("has_external_entry") for c in candidates) and not any(c.get("has_bytecode") for c in candidates):
        return ABSTRACT_OR_BASE_CONTRACT
    if all(c.get("base_like") for c in candidates):
        return EMPTY_ABI_OR_NO_EXTERNAL_ENTRY
    return NO_DEPLOYABLE_CONTRACT


def _select_contract(
    contracts: Dict[str, Dict[str, Any]],
    contract_name: Optional[str],
) -> Tuple[str, Dict[str, Any], Dict[str, Any]]:
    normalized_contracts: Dict[str, Dict[str, Any]] = {}
    for name, meta in (contracts or {}).items():
        short_name = str(name).split(":")[-1]
        normalized_contracts[short_name if short_name not in normalized_contracts else str(name)] = meta
    contracts = normalized_contracts
    candidates = [_candidate_info(name, meta) for name, meta in contracts.items()]
    by_name = {info["name"]: info for info in candidates}

    requested_info = by_name.get(contract_name) if contract_name else None
    if requested_info and requested_info.get("deployable") and not requested_info.get("base_like"):
        picked_name = requested_info["name"]
        return picked_name, contracts[picked_name], {
            "requested_contract": contract_name,
            "selected_contract": picked_name,
            "fallback_used": False,
            "error_type": "",
            "candidates": candidates,
        }

    deployable = [info for info in candidates if info.get("deployable") and not info.get("base_like")]
    if deployable:
        picked_info = sorted(deployable, key=_rank_deployable, reverse=True)[0]
        picked_name = picked_info["name"]
        return picked_name, contracts[picked_name], {
            "requested_contract": contract_name,
            "selected_contract": picked_name,
            "fallback_used": bool(contract_name and picked_name != contract_name),
            "fallback_reason": "requested_contract_not_deployable_or_not_fuzzable",
            "error_type": "",
            "candidates": candidates,
        }

    error_type = _contract_selection_error_type(candidates)
    details = {
        "requested_contract": contract_name,
        "selected_contract": None,
        "fallback_used": False,
        "error_type": error_type,
        "candidates": candidates,
    }
    raise RuntimeError(
        "[contract_selection_error] "
        f"error_type={error_type} source_has_contracts={len(candidates)} "
        f"requested_contract={contract_name or 'ANY'} candidates={json.dumps(candidates, ensure_ascii=False)}"
    )

# def compile_and_extract(source_path: str, contract_name: str=None,
#                         solc_version: str="v0.8.24",
#                         evm_version: str=EVM_VERSION) -> Dict[str, Any]:
#     """
#     编译 Solidity，抽取 ABI / bytecode / 函数选择子映射。
#     复用现有 utils.compile 与 mapping 方法。
#     """
#     source_path = str(Path(source_path).resolve())
#     out = sol_compile(solc_version, evm_version, source_path)
#     if not out or 'contracts' not in out or source_path not in out['contracts']:
#         raise RuntimeError(f"Compilation failed or no outputs for {source_path}")
    
#     ast_json = None
#     if "sources" in out and source_path in out["sources"]:
#         ast_json = out["sources"][source_path].get("ast")
#     # print(ast_json)

#     contracts = out['contracts'][source_path]
#     picked_name, picked = None, None
#     for name, meta in contracts.items():
#         if contract_name and name != contract_name:
#             continue
#         if meta.get('abi') and meta.get('evm', {}).get('bytecode', {}).get('object') \
#            and meta.get('evm', {}).get('deployedBytecode', {}).get('object'):
#             picked_name, picked = name, meta
#             break
#     if not picked:
#         raise RuntimeError(f"No suitable contract found in {source_path} (contract={contract_name or 'ANY'})")

#     abi = picked['abi']
#     deploy_bc = picked['evm']['bytecode']['object']
#     runtime_bc = picked['evm']['deployedBytecode']['object']
#     sig_map = get_function_signature_mapping(abi)

#     return {
#         "source": source_path,
#         "contract": picked_name,
#         "abi": abi,
#         "bytecode": deploy_bc,
#         "runtime_bytecode": runtime_bc,
#         "function_signature_mapping": sig_map,
#         "ast": ast_json
#     }

def _pick_matching_source_key(obj: dict, source_path: str) -> str:
    """
    在 compile_standard 输出的 sources/contracts key 中，
    兼容绝对路径 / 相对路径 / 仅文件名 三种情况。
    只取“当前给定 sol 文件”对应的 key。
    """
    if not obj:
        return None

    norm_target = str(Path(source_path).resolve()).replace("\\", "/")
    target_name = Path(source_path).name

    # 1) 先精确匹配绝对路径
    for k in obj.keys():
        if str(Path(k).resolve()).replace("\\", "/") == norm_target:
            return k

    # 2) 再匹配规范化字符串
    for k in obj.keys():
        if str(k).replace("\\", "/") == norm_target:
            return k

    # 3) 再按文件名匹配
    for k in obj.keys():
        if Path(k).name == target_name:
            return k

    if len(obj) == 1:
        return next(iter(obj.keys()))

    return None


def compile_and_extract(source_path: str,
                        contract_name: str = None,
                        solc_version: str = "v0.8.24",
                        evm_version: str = EVM_VERSION) -> Dict[str, Any]:
    """
    编译 Solidity，抽取 ABI / bytecode / 函数选择子映射。
    保持现有返回格式不变，只增强 source key 兼容匹配。
    """
    source_path = str(Path(source_path).resolve())

    out = sol_compile(solc_version, evm_version, source_path, extra_outputs=True)
    if not out or "contracts" not in out:
        raise RuntimeError(f"Compilation failed for {source_path}")

    # -------- 找到当前 sol 文件在输出中的真实 key --------
    contracts_key = _pick_matching_source_key(out.get("contracts", {}), source_path)
    sources_key = _pick_matching_source_key(out.get("sources", {}), source_path)

    if not contracts_key or contracts_key not in out["contracts"]:
        raise RuntimeError(f"No compiled contracts found for {source_path}")

    # 这里拿到的是整个 SourceUnit AST，而不是某个单独 contract 的 AST
    ast_json = None
    if sources_key and sources_key in out.get("sources", {}):
        ast_json = out["sources"][sources_key].get("ast")

    contracts = out["contracts"][contracts_key]

    picked_name, picked, selection_info = _select_contract(contracts, contract_name)

    abi = picked["abi"]
    deploy_bc = picked["evm"]["bytecode"]["object"]
    runtime_bc = picked["evm"]["deployedBytecode"]["object"]
    sig_map = get_function_signature_mapping(abi)

    storage_layout = picked.get("storageLayout")
    solc_ir = picked.get("ir")
    solc_ir_optimized = picked.get("irOptimized")
    legacy_asm = picked.get("evm", {}).get("legacyAssembly")

    print("=== COMPILE DEBUG ===")
    print("contracts keys:", list(out.get("contracts", {}).keys()))
    print("sources keys:", list(out.get("sources", {}).keys()))
    print("picked contracts key:", contracts_key)
    print("picked sources key:", sources_key)
    print("picked contract:", picked_name)
    if selection_info.get("fallback_used"):
        print(
            "[contract_selection] fallback "
            f"{selection_info.get('requested_contract')} -> {selection_info.get('selected_contract')}"
        )
    print("ast nodeType:", ast_json.get("nodeType") if isinstance(ast_json, dict) else None)
    print("has storageLayout:", storage_layout is not None)
    print("has ir:", bool(solc_ir))
    print("has irOptimized:", bool(solc_ir_optimized))
    print("=====================")

    return {
        "source": source_path,
        "contract": picked_name,
        "abi": abi,
        "bytecode": deploy_bc,
        "runtime_bytecode": runtime_bc,
        "function_signature_mapping": sig_map,
        "ast": ast_json,

        # -------- Step3.2A direct outputs --------
        "storage_layout": storage_layout,
        "solc_ir": solc_ir,
        "solc_ir_optimized": solc_ir_optimized,
        "legacy_assembly": legacy_asm,

        # -------- Step3.2A packed artifacts --------
        "compiler_artifacts": {
            "source_key": contracts_key,
            "sources_key": sources_key,
            "contract_name": picked_name,
            "requested_contract_name": contract_name,
            "contract_selection": selection_info,
            "picked_contract_output": bool(picked),
            "ir_enabled": out.get("_extra_ir_enabled", False),
            "ir_error": out.get("_extra_ir_error"),

            # 当前主 contract 的直接字段（兼容旧调用）
            "storage_layout": storage_layout,
            "solc_ir": solc_ir,
            "solc_ir_optimized": solc_ir_optimized,
            "legacy_assembly": legacy_asm,

            # 关键：保留当前 source 下所有 contract 的编译产物
            "contracts": {
                name: {
                    "storageLayout": meta.get("storageLayout"),
                    "ir": meta.get("ir"),
                    "irOptimized": meta.get("irOptimized"),
                    "legacyAssembly": meta.get("evm", {}).get("legacyAssembly"),
                    "abi": meta.get("abi"),
                }
                for name, meta in contracts.items()
            }
        }
    }


