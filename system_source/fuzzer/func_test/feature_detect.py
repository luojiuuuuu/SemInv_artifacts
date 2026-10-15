# -*- coding: utf-8 -*-
from typing import Dict, Any, List

def detect_standards_and_traits(abi: List[dict]) -> Dict[str, Any]:
    """极简 ERC 标准/特性识别（基于名称+完整签名精确匹配）"""
    # 必要函数集合（最小可行，后续可扩展）
    erc20_funcs = {
        "totalSupply()", "balanceOf(address)", "transfer(address,uint256)",
        "approve(address,uint256)", "transferFrom(address,address,uint256)",
        "allowance(address,address)"
    }
    erc20_events = {"Transfer(address,address,uint256)", "Approval(address,address,uint256)"}

    # 收集实际函数/事件签名
    f_sigs, e_sigs = set(), set()
    for item in abi:
        if item.get("type") == "function":
            name = item["name"]
            args = ",".join(i["type"] for i in item.get("inputs", []))
            f_sigs.add(f"{name}({args})")
        elif item.get("type") == "event":
            name = item["name"]
            args = ",".join(i["type"] for i in item.get("inputs", []))
            e_sigs.add(f"{name}({args})")

    standards = []
    if erc20_funcs.issubset(f_sigs) and erc20_events.issubset(e_sigs):
        standards.append("ERC20")

    traits = []
    # 粗粒度可变性/权限/风险提示（可按需增强）
    for item in abi:
        if item.get("type") == "function":
            if item.get("stateMutability") == "payable":
                traits.append("payable-entry")
            if any(arg["type"] == "address" for arg in item.get("inputs", [])):
                traits.append("address-arg")

    return {
        "standards": sorted(set(standards)),
        "traits": sorted(set(traits))
    }
