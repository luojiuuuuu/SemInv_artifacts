# -*- coding: utf-8 -*-
import json
import requests
from pathlib import Path
from typing import Dict, Any, List
from ..utils.text_sanitize import sanitize_report_text

def _selector_of(name: str, sig_map: Dict[str,str]) -> str:
    # sig_map: {selector: "func(argtypes)"}
    for sel, sig in sig_map.items():
        if sig.split("(")[0] == name:
            return sel.replace("0x","")
    return None

def heuristic_seeds(contract: str, abi: List[dict], sig_map: Dict[str,str],
                    standards: List[str]) -> Dict[str, Any]:
    """无 LLM 兜底启发：给出 2–3 条多步序列（可立即用）。"""
    seeds = []
    # ERC20 典型多步：mint -> approve -> transferFrom
    if "ERC20" in standards:
        sel_mint = _selector_of("mint", sig_map) or "40c10f19"
        sel_approve = _selector_of("approve", sig_map) or "095ea7b3"
        sel_tf = _selector_of("transferFrom", sig_map) or "23b872dd"
        seeds.append({
            "id": "seed-erc20-approve-xferFrom",
            "label_guess": ["AllowancePath","Transfer","balance[dst]++","balance[src]--"],
            "sequence": [
                {"from":"$OWNER","to":"$DEPLOYED","value":"0","selector":sel_mint,"args":["0xA11CE","1000"]},
                {"from":"0xA11CE","to":"$DEPLOYED","value":"0","selector":sel_approve,"args":["0xB0B","700"]},
                {"from":"0xB0B","to":"$DEPLOYED","value":"0","selector":sel_tf,"args":["0xA11CE","0xB0B","600"]}
            ]
        })
    # 通用：为任意一个非 view/pure 的 external/public 生成 2 步链
    for item in abi:
        if item.get("type")!="function": continue
        if item.get("stateMutability") in ("view","pure"): continue
        name = item["name"]
        sel = _selector_of(name, sig_map)
        if not sel: continue
        arg_vals = []
        for inp in item.get("inputs", []):
            t = inp["type"]
            if t.startswith("uint"): arg_vals.append("1")
            elif t=="address": arg_vals.append("0xB0B")
            elif t=="bool": arg_vals.append("true")
            else: arg_vals.append("0")
        seeds.append({
            "id": f"seed-{name}-basic",
            "label_guess": [f"MayTouch({name})"],
            "sequence": [
                {"from":"$OWNER","to":"$DEPLOYED","value":"0","selector":sel,"args":arg_vals}
            ]
        })
        if len(seeds) >= 3: break

    return {
        "meta": {"contract_name": contract, "version": "1.0.0"},
        "seeds": seeds
    }

def call_llm(prompt: str, api_key: str, api_url: str = "https://api.openai.com/v1/chat/completions",
             model: str = "gpt-4.1") -> str:
    """
    调用 LLM 接口，返回模型输出文本。
    - prompt: 传入的文本
    - api_key: 你的 OpenAI API Key（外部传入，不写死）
    - api_url: LLM 接口地址（默认 OpenAI，可替换成你自己的）
    - model: 使用的模型名称
    """
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    body = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.3
    }
    resp = requests.post(api_url, headers=headers, json=body, timeout=60)
    resp.raise_for_status()
    data = resp.json()
    return data["choices"][0]["message"]["content"].strip()


# Active legacy seed/report LLM entrypoint below is English-only. Legacy non-English prompt entrypoint was replaced during prompt normalization.

def llm_generate_report_and_seeds(contract: str, abi: List[dict], sig_map: Dict[str, str],
                                  standards: List[str], api_key: str) -> Dict[str, Any]:
    """Generate an English functional report and seed suggestions via LLM.

    This legacy helper keeps the original output contract: plain report text
    followed by a ```json fenced seeds object.
    """
    abi_str = json.dumps(abi, indent=2)
    sig_map_str = json.dumps(sig_map, indent=2)
    standards_str = ", ".join(standards)

    prompt = f"""
You are a smart-contract security testing expert. Write in English.

Contract name: {contract}
Reference standards or traits: {standards_str}

ABI:
{abi_str}

Function selector map:
{sig_map_str}

Tasks:
1. Generate a concise functional test report, approximately 300 to 400 words. Explain the functional coverage points and exceptional paths implied by the ABI and standards.
2. Generate multi-step call sequences, preferably 3 to 6 steps when useful, and output a seeds.json-compatible object using this structure:

[
  {{
    "constructor": {{
      "args": [],
      "from": "0x...",
      "value": 0
    }},
    "steps": [
      {{ "func": "approve(address,uint256)", "args": ["0x...", 5000], "from": "0x..." }},
      {{ "func": "transferFrom(address,address,uint256)", "args": ["0x...", "0x...", 100], "from": "0x..." }}
    ]
  }},
  {{
    "steps": [
      {{ "func": "mintToken(address,uint256)", "args": ["0x...", 10000], "from": "0x..." }},
      {{ "func": "freezeAccount(address,bool)", "args": ["0x...", true], "from": "0x..." }}
    ]
  }}
]

Requirements:
- Use ABI function signatures in "func" and keep parameter types consistent with the real interface.
- Use reasonable example addresses and values, such as 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa and 1000.
- Each step sequence should cover important contract logic such as transfers, approvals, minting, freezing, state transitions, or access control when present.
- Include paths that may trigger require/revert checks when they are implied by the ABI or standards.
- When useful, relate the report to the six semantic invariant families: Financial & Accounting, Authorization & Access Control, Protocol State Machine, Transactional Consistency, Resource & Execution Integrity, and External Interaction & Environment.
- Output the functional report first as plain text, then output the seeds object inside a ```json fenced block.
"""
    raw = sanitize_report_text(call_llm(prompt, api_key=api_key))

    report = ""
    seeds_obj = {}
    if "```json" in raw:
        before, after = raw.split("```json", 1)
        report = before.strip()
        json_part = after.split("```", 1)[0]
        seeds_obj = json.loads(json_part)
    else:
        report = raw
        seeds_obj = {"meta": {"contract_name": contract, "version": "1.0.0"}, "seeds": []}

    return {
        "report": report,
        "seeds": seeds_obj
    }


def write_report(project_root: str, testfile_path: str, report: str) -> str:
    """
    将功能测试报告写入独立的 {test_name}_meta/func_test_report.txt
    """
    pr = Path(project_root).resolve()
    test_name = str(Path(testfile_path).stem).split('_')[0]  # 例如 keepMyEther_Functional.t.sol → keepMyEther_Functional
    meta_dir = pr / f"{test_name}_meta"
    meta_dir.mkdir(exist_ok=True)

    outp = meta_dir / "func_test_report.txt"
    outp.write_text(report, encoding="utf-8")
    return str(outp)


def write_seeds(project_root: str, testfile_path: str, seeds_obj: Dict[str, Any]) -> str:
    """
    将 seeds.json 写入独立的 {test_name}_meta/seeds.json
    """
    pr = Path(project_root).resolve()
    test_name = str(Path(testfile_path).stem).split('_')[0]
    seeds_dir = pr / f"{test_name}_meta" 
    seeds_dir.mkdir(parents=True, exist_ok=True)

    outp = seeds_dir / "seeds.json"
    outp.write_text(json.dumps(seeds_obj, indent=2), encoding="utf-8")
    return str(outp)

