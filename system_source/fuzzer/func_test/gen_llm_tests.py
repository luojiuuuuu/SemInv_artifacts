# -*- coding: utf-8 -*-
import json
import re
import requests
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from .gen_foundry_tests import gen_tests_from_abi, write_foundry_test

# -------------------------------------------------------
# 1) LLM 基础调用：风格与用户示例保持一致
# -------------------------------------------------------
def call_llm(prompt: str,
             api_key: str,
             api_url: str = "https://api.openai.com/v1/chat/completions",
             model: str = "gpt-4.1") -> str:
    """
    调用 LLM 接口，返回模型输出文本（纯字符串）。
    """
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    body = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.2
    }
    resp = requests.post(api_url, headers=headers, json=body, timeout=120)
    resp.raise_for_status()
    data = resp.json()
    return data["choices"][0]["message"]["content"].strip()

# -------------------------------------------------------
# 2) ABI 工具：生成允许的函数签名/事件清单
# -------------------------------------------------------
def _sig_of(item: dict) -> str:
    return f"{item['name']}({','.join(i['type'] for i in item.get('inputs', []))})"

def abi_allowed_functions(abi: List[dict]) -> List[str]:
    return sorted({_sig_of(it) for it in abi if it.get("type") == "function"})

def abi_allowed_events(abi: List[dict]) -> List[str]:
    out = []
    for it in abi:
        if it.get("type") == "event":
            ev = f"{it['name']}({','.join(i['type'] for i in it.get('inputs', []))})"
            out.append(ev)
    return sorted(set(out))

def _arity_map(abi: List[dict]) -> Dict[str, int]:
    # fn name -> possible arities set (用于宽松校验)
    mp: Dict[str, set] = {}
    for it in abi:
        if it.get("type") != "function":
            continue
        mp.setdefault(it["name"], set()).add(len(it.get("inputs", [])))
    return {k: sorted(v)[-1] for k, v in mp.items()}  # 最大实参个数作为“上限”参考

# -------------------------------------------------------
# 3) Prompt 构造（要求 LLM 输出严格 JSON）
# -------------------------------------------------------
# Active prompt builder below is English-only. Legacy non-English prompt builder was replaced during prompt normalization.

def build_sequences_prompt(contract_name: str,
                           abi: List[dict],
                           standards: List[str],
                           source_text: Optional[str] = None,
                           max_sequences: int = 4) -> str:
    allowed_funcs = abi_allowed_functions(abi)
    allowed_events = abi_allowed_events(abi)
    source_note = f"\nContract source:\n{source_text}\n" if source_text else ""
    schema = r"""
{
  "name": "LLM-Plan",
  "sequences": [
    {
      "name": "str",
      "intent": "str",
      "bootstrap": [
        {"kind": "mint_or_transfer_to_alice", "amount": "600"}
      ],
      "steps": [
        {"who": "alice|bob|carol", "call": "fn(arg1, arg2, ...)", "value": "0|<wei>"},
        {"who": "bob", "call": "transferFrom(alice, bob, 60)"}
      ],
      "post": [
        "balance(bob) += 60",
        "balance(alice) -= 60",
        "allowance(alice,bob) == 40",
        "supply conserved",
        "owner() == bob"
      ],
      "events": [
        "Transfer(address,address,uint256)"
      ]
    }
  ]
}
"""
    constraints = f"""
Rules and constraints:
1. Only use the allowed ABI function signatures below. Function names, argument counts, and argument types must match:
   ALLOWED_FUNCTIONS = {json.dumps(allowed_funcs, ensure_ascii=False, indent=2)}
2. If events are needed, only use these ABI events. Events are optional:
   ALLOWED_EVENTS = {json.dumps(allowed_events, ensure_ascii=False, indent=2)}
3. Participants are limited to alice, bob, and carol. Use these identifiers directly instead of raw 0x addresses.
4. Every step's "call" must be a Solidity-embeddable call expression, for example "transfer(bob, 60)".
5. Use "value" only for payable scenarios; use "0" when no ETH transfer is needed.
6. Number of sequences <= {max_sequences}; each sequence should have 1..6 steps and should cover key positive paths plus one boundary path when possible.
7. "post" may only contain downstream-supported assertion fragments:
   - "balance(alice) += N", "balance(bob) += N", "balance(alice) -= N", "balance(bob) -= N"
   - "allowance(alice,bob) == N"
   - "owner() == alice|bob|carol"
   - "supply conserved"
8. Do not output functions outside the ABI, custom helper functions, or pseudo-code.
9. Output exactly one JSON object. Do not use markdown, comments, or ```json fences.
10. When useful, describe the semantic invariant family in "intent": Financial & Accounting, Authorization & Access Control, Protocol State Machine, Transactional Consistency, Resource & Execution Integrity, or External Interaction & Environment.
"""
    task = f"""
You are a Solidity test planner for a semantic-invariant driven vulnerability detector.
Based on the ABI and reference standards, generate a planning JSON for multi-step functional-correctness transaction tests.

Contract name: {contract_name}
Reference standards or traits: {", ".join(standards) if standards else "(not specified)"}

ABI, used both as reference and as a hard constraint:
{json.dumps(abi, ensure_ascii=False, indent=2)}
{source_note}

Output JSON satisfying the schema below. Give every sequence a minimal but clear intent and ensure each step can be rendered directly into Solidity test code.
"""
    return f"{task}\n\n===== Output Schema =====\n{schema}\n===== Constraints =====\n{constraints}\n\nReturn JSON only:"


def _extract_json_block(raw: str) -> Optional[dict]:
    """
    尝试解析严格 JSON；若文本包含 ```json ... ```，也会兼容解析。
    """
    s = raw.strip()
    # 兼容 ```json 包裹
    if "```json" in s:
        s = s.split("```json", 1)[1]
        s = s.split("```", 1)[0]
    # 去掉可能的前后多余字符
    s = s.strip()
    try:
        return json.loads(s)
    except Exception:
        # 尝试提取首尾大括号
        m = re.search(r"\{.*\}", s, flags=re.S)
        if m:
            try:
                return json.loads(m.group(0))
            except Exception:
                return None
        return None

def _sanitize_call(expr: str) -> Optional[str]:
    """
    将 "transfer ( bob , 60 )" 规范为 "transfer(bob, 60)"；若不合法返回 None。
    """
    expr = re.sub(r"\s+", " ", expr.strip())
    # 函数名(参数列表)
    m = re.match(r"([A-Za-z_][A-Za-z0-9_]*)\s*\((.*)\)$", expr)
    if not m:
        return None
    fn, args = m.group(1), m.group(2).strip()
    # 规整逗号与空格
    args = ", ".join([a.strip() for a in args.split(",")]) if args else ""
    return f"{fn}({args})"

def _fn_name(expr: str) -> str:
    return expr.split("(", 1)[0].strip()

def _validate_plan_against_abi(plan: Dict[str, Any], abi: List[dict]) -> Dict[str, Any]:
    """
    宽松校验/清洗：确保 steps 的 call 名在 ABI 中；过不了的序列将被剔除。
    """
    allowed = { _sig_of(it) for it in abi if it.get("type") == "function" }
    name_to_arities = _arity_map(abi)

    sequences = []
    for s in plan.get("sequences", []):
        ok_steps = []
        for st in s.get("steps", []):
            call = st.get("call")
            who  = st.get("who", "alice")
            if not isinstance(call, str):
                continue
            call2 = _sanitize_call(call)
            if not call2:
                continue
            fn = _fn_name(call2)
            if fn not in name_to_arities:
                # 完全不存在该函数名
                continue
            # 粗验参数个数（不核对类型，以免 LLM 输出字面量难以准确映射类型）
            arg_str = call2.split("(", 1)[1].rsplit(")", 1)[0].strip()
            argc = 0 if arg_str == "" else len([x for x in arg_str.split(",")])
            if argc > name_to_arities[fn]:
                # 实参数量明显超过该名下任一重载的最大参数数，剔除
                continue
            # participants 只允许 3 个
            if who not in ("alice", "bob", "carol"):
                who = "alice"
            st_norm = {"who": who, "call": call2}
            # 规范 value
            if "value" in st and isinstance(st["value"], (str, int)):
                v = str(st["value"]).strip()
                st_norm["value"] = v if v else "0"
            ok_steps.append(st_norm)
        if ok_steps:
            seq_norm = {
                "name": s.get("name", "seq"),
                "intent": s.get("intent", s.get("name", "sequence")),
                "bootstrap": s.get("bootstrap", []),
                "steps": ok_steps,
                "post": s.get("post", []),
                "events": s.get("events", [])
            }
            sequences.append(seq_norm)

    return {"name": plan.get("name", "LLM-Plan"), "sequences": sequences}

# -------------------------------------------------------
# 5) LLM 规划主函数：返回可直接传给 gen_tests_from_abi 的 dict
# -------------------------------------------------------
def llm_plan_sequences(contract_name: str,
                       abi: List[dict],
                       standards: List[str],
                       api_key: str,
                       source_text: Optional[str] = None,
                       api_url: str = "https://api.openai.com/v1/chat/completions",
                       model: str = "gpt-4.1",
                       max_sequences: int = 4) -> Dict[str, Any]:
    """
    调用 LLM 生成多步交易序列规划，并校验/清洗为：
      {"name": "...", "sequences":[{name,intent,bootstrap,steps,post,events}, ...]}
    若解析失败，返回 {"name":"LLM-Plan","sequences":[]}（上层可降级到内置 standards）。
    """
    prompt = build_sequences_prompt(
        contract_name=contract_name,
        abi=abi,
        standards=standards,
        source_text=source_text,
        max_sequences=max_sequences
    )
    raw = call_llm(prompt, api_key=api_key, api_url=api_url, model=model)
    data = _extract_json_block(raw)
    if not isinstance(data, dict) or "sequences" not in data:
        return {"name": "LLM-Plan", "sequences": []}
    return _validate_plan_against_abi(data, abi)

# -------------------------------------------------------
# 6) 便捷入口：一条龙（LLM 规划 -> 生成测试 -> 写文件）
# -------------------------------------------------------
def generate_tests_with_llm(contract_name: str,
                            abi: List[dict],
                            standards: List[str],
                            solc_version: str,
                            source_path: Optional[str],
                            api_key: str,
                            out_dir: str = "test",
                            api_url: str = "https://api.openai.com/v1/chat/completions",
                            model: str = "gpt-4.1",
                            include_builtin: bool = True,
                            source_text: Optional[str] = None) -> Tuple[str, Dict[str, Any]]:
    """
    - 使用 LLM 产生多步序列 plan（dict），作为“标准项”注入 gen_tests_from_abi。
    - 若 LLM 失败，则仅使用 standards（如 ["ERC20","Ownable"]）。
    - 返回：(写入的测试文件路径, 使用的 LLM plan dict)
    """
    # 1) 调 LLM 生成 plan
    llm_plan = llm_plan_sequences(
        contract_name=contract_name,
        abi=abi,
        standards=standards,
        api_key=api_key,
        source_text=source_text,
        api_url=api_url,
        model=model
    )

    # 2) 组合 standards 列表：内置字符串 + LLM 产物 dict
    stds: List[Any] = []
    if include_builtin:
        stds.extend(standards or [])
    if llm_plan.get("sequences"):
        stds.append(llm_plan)

    # 3) 生成测试源码并写入
    content = gen_tests_from_abi(
        contract_name=contract_name,
        abi=abi,
        standards=stds,
        solc_version=solc_version,
        source_path=source_path
    )
    path = write_foundry_test(Path(out_dir), contract_name, content)
    return path, llm_plan

