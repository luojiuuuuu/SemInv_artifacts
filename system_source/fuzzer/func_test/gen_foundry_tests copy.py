# -*- coding: utf-8 -*-
from pathlib import Path
from typing import Dict, Any, List, Optional, Tuple
import json
import re
import requests

def _parse_solc_version(solc_version: str) -> Tuple[int, int, int]:
    v = solc_version.lstrip("v").strip()
    parts = (v.split("+")[0].split("-")[0]).split(".")
    major = int(parts[0]) if len(parts) > 0 else 0
    minor = int(parts[1]) if len(parts) > 1 else 0
    patch = int(parts[2]) if len(parts) > 2 else 0
    return major, minor, patch

def _version_flags(solc_version: str) -> Dict[str, bool]:
    M, m, _ = _parse_solc_version(solc_version)
    is_04 = (M == 0 and m == 4)
    is_05 = (M == 0 and m == 5)
    is_06_07 = (M == 0 and (m == 6 or m == 7))
    is_08p = (M == 0 and m >= 8) or (M >= 1)
    return {
        "is_04": is_04,
        "is_05": is_05,
        "is_06_07": is_06_07,
        "is_08p": is_08p,          # 仅 0.8+ 使用 forge-std 与 vm.*
    }

# -----------------------
# Name generator (局部变量名/临时数组/结构体名用)
# -----------------------
class _NameGen:
    def __init__(self):
        self.counters = {}

    def new(self, prefix: str) -> str:
        i = self.counters.get(prefix, 0) + 1
        self.counters[prefix] = i
        return f"_{prefix}{i}"

def _sanitize_solidity_identifier(s: str, fallback: str = "seq") -> str:
    if not isinstance(s, str):
        s = str(s or "")
    # 非字母数字下划线 -> 下划线
    s = re.sub(r"[^A-Za-z0-9_]", "_", s)
    # 合并多余下划线并去掉首尾
    s = re.sub(r"_+", "_", s).strip("_")
    # 为空则回退
    if not s:
        s = fallback
    # 首字符必须是字母或下划线
    if not re.match(r"[A-Za-z_]", s[0]):
        s = f"{fallback}_{s}"
    # 避免与少数关键字撞名（可按需扩展）
    reserved = {"function", "contract", "event", "struct", "modifier", "mapping", "fallback", "receive"}
    if s in reserved:
        s = f"{fallback}_{s}"
    return s

# -----------------------
# 源码解析：struct / enum / 形参真实声明（含命名空间）
# -----------------------
def _parse_struct_and_enum_names(source_text: Optional[str]):
    """
    返回:
      structs: Dict[StructName, List[(fieldType, fieldName)]]
      enums:   Set[EnumName]
    说明：
      - 仅做轻量正则解析，足够覆盖常见项目；极端源码可容错退化
      - 支持合约内声明的 Contract.StructName（通过外层合约名抓取）
    """
    if not source_text:
        return {}, set()

    structs = {}
    enums = set()

    # 捕获 "struct Name { T1 f1; T2 f2; ... }"（含换行）
    for m in re.finditer(r"struct\s+([A-Za-z_]\w*)\s*\{(.*?)\}", source_text, flags=re.S):
        sname = m.group(1)
        body = m.group(2)
        fields = []
        for l in re.finditer(r"([A-Za-z_][\w\s\[\]()]*)\s+([A-Za-z_]\w*)\s*;", body):
            ftype = re.sub(r"\s+", " ", l.group(1).strip())
            fname = l.group(2).strip()
            fields.append((ftype, fname))
        if fields:
            structs[sname] = fields

    # 捕获 "enum Name { A, B, C }"
    for m in re.finditer(r"enum\s+([A-Za-z_]\w*)\s*\{([^}]*)\}", source_text, flags=re.S):
        ename = m.group(1).strip()
        enums.add(ename)

    return structs, enums

# 源码事实抽取：modifiers / require / 状态变量 / 常见开关
def _build_source_facts(source_text: Optional[str]) -> Dict[str, Any]:
    facts = {"modifiers": {}, "requires": {}, "reverts": {}, "states": {"mappings": [], "arrays": [], "structs": []}, "switches": set()}
    if not source_text:
        # [ADD] 确保返回可序列化
        facts["switches"] = []
        return facts
    
    # modifiers 用法：function foo(...) <mods> { ... }
    for m in re.finditer(r"function\s+([A-Za-z_]\w*)\s*\([^)]*\)\s*(?:public|external|internal|private)?\s*([^{;]*)\{", source_text, flags=re.S):
        fn, tail = m.group(1), m.group(2)
        mods = re.findall(r"\b([A-Za-z_]\w*)\s*(?:\([^)]*\))?", tail)
        if mods:
            facts["modifiers"].setdefault(fn, list(sorted(set(mods))))

    # require/assert/revert 消息（只抓字面量）
    for m in re.finditer(r"(require|assert)\s*\(\s*([^,;]+)\s*(?:,\s*\"([^\"]*)\")?\s*\)", source_text):
        kind, cond, msg = m.group(1), m.group(2).strip(), (m.group(3) or "")
        facts["requires"].setdefault(kind, []).append({"cond": cond, "msg": msg})
    for m in re.finditer(r"revert\s*\(\s*\"([^\"]*)\"\s*\)\s*;", source_text):
        facts["reverts"].setdefault("revert", []).append({"msg": m.group(1)})

    # 状态变量：mapping / 数组 / struct 声明
    for m in re.finditer(r"mapping\s*\(([^=;]+)\)\s*=>\s*([^\s;]+)\s*\)\s*([A-Za-z_]\w*)\s*;", source_text):
        facts["states"]["mappings"].append(m.group(0))
    for m in re.finditer(r"([A-Za-z_]\w*(?:\[[^\]]*\])+\s+[A-Za-z_]\w*)\s*;", source_text):
        facts["states"]["arrays"].append(m.group(1))

    # 常见开关函数
    for kw in ("pause", "unpause", "setTransferable", "enableTokenTransfer", "releaseTokenTransfer", "openTrading", "freezeAccount"):
        if re.search(rf"\b{kw}\s*\(", source_text):
            facts["switches"].add(kw)

    # 结构体声明名直接复用已有解析
    structs, _ = _parse_struct_and_enum_names(source_text)
    facts["states"]["structs"] = list(structs.keys())

    # 关键：把 set 转成（排序后）list
    facts["switches"] = sorted(list(facts["switches"]))
    return facts

def _map_fn_params_with_decl_names(source_text: Optional[str]):
    """
    返回: { fnName: [declType0, declType1, ...] }，declType 形如：
      - "address payable" / "address" / "Contract.StructName" / "EnumName" / "uint256[3]" / "MyStruct[]" / "tuple-like" 等
    仅用于“猜测 struct/enum 的真实声明名称”，与 ABI 的 components 联动。
    """
    if not source_text:
        return {}

    out = {}
    # function X(T1 a, T2[] memory b, Contract.Struct c, ...)
    for m in re.finditer(r"function\s+([A-Za-z_]\w*)\s*\((.*?)\)", source_text, flags=re.S):
        fn = m.group(1)
        inside = m.group(2).strip()
        if inside == "":
            out.setdefault(fn, []).append([])
            continue

        decls = []
        # 分隔逗号，容错泛型空格
        parts = [p.strip() for p in re.split(r",(?![^()]*\))", inside) if p.strip()]
        for p in parts:
            # 去形参名：最后一个 token 多为形参名
            toks = p.split()
            if len(toks) >= 2:
                t = " ".join(toks[:-1])
            else:
                t = toks[0]
            t = t.strip()
            # 合约/接口前缀规整
            t = re.sub(r"^(contract|interface)\s+", "", t)
            decls.append(t)
        out.setdefault(fn, []).append(decls)
    return out

def _guess_struct_name_for_param(fn_name: str, pidx: int,
                                 src_decl_map: Dict[str, List[List[str]]],
                                 structs: Dict[str, List[tuple]]) -> Optional[str]:
    """
    根据源码真实声明，推断第 pidx 个参数的“结构体类型名”（可能带命名空间，如 Contract.Struct）。
    若找不到或不是 struct，返回 None。
    """
    cands = src_decl_map.get(fn_name) or []
    for decls in cands:
        if pidx < len(decls):
            t = decls[pidx]
            # 可能是 "Contract.StructName" 或 "StructName" 或 "StructName[]"
            bare = t.rstrip().rstrip("]").rstrip("[")
            # 去掉数据位置标注
            bare = bare.replace(" memory", "").replace(" storage", "").replace(" calldata", "").strip()
            # 最后一个标识符作为结构体基名
            base = bare.split(".")[-1]
            if base in structs:
                return t  # 保留可能的命名空间
    return None

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
def build_sequences_prompt(contract_name: str,
                           abi: List[dict],
                           standards: List[str],
                           source_text: Optional[str] = None,
                           max_sequences: int = 4,
                           max_steps: int = 6) -> str:
    allowed_funcs = abi_allowed_functions(abi)
    allowed_events = abi_allowed_events(abi)

    src_note = f"\n源码：\n{source_text}\n" if source_text else ""

    schema = r"""
{
  "name": "LLM-Plan",
  "sequences": [
    {
      "name": "str",                       // 用例名（用于生成测试函数名）
      "intent": "str",                     // 用例意图（覆盖目标的自然语言说明）
      "bootstrap": [                       // 可选：常见初始资金/余额准备（由生成器解释）
        { "kind": "mint_or_transfer_to_alice", "amount": "100" }
      ],
      "prestate": {                        // 可选：状态准备（部署后立即执行）
        "solidity": [ "target.unpause();" ],
        "vm_stores": [
          { "slot": "0x...", "value": "0x...", "note": "set paused=false" }
        ]
      },
      "requires": [                        // ★ 必要前置：严格在 steps 前执行
        { "who": "alice", "call": "approve(bob, 1)", "value": "0" }
      ],
      "steps": [                           // ★ 正式步骤，支持逐步期望
        { "who": "bob", "call": "transferFrom(alice,bob,1)", "value": "0", "expect": "ok" },
        { "who": "alice", "call": "vote(0)", "value": "0", "expect": "revert:already voted" }
      ],
      "array_constraints": {               // ★ 数组/索引长度声明（构造器/步骤参数）
        "constructor.proposals:bytes32[]": 2,
        "vote.arg0:uint256": 1
      },
      "assume": [                          // 非强制检查的路径假设（用于指导前置）
        "paused==false", "allowance(alice,bob)>=1"
      ],
      "covered_branches": [                // 覆盖目标（便于追踪）
        { "fn": "transfer", "branch": "require(balance>=amount) true" }
      ],
      "post": [                            // 断言片段
        "balance(alice) -= 1", "balance(bob) += 1", "supply conserved"
      ],
      "events": []                         // 可选：事件签名列表
    }
  ]
}
"""

    constraints = f"""
强约束（场景规划版）：
1) 仅可调用以下 ABI 函数（函数名与参数型/个数需匹配）：
   ALLOWED_FUNCTIONS = {json.dumps(allowed_funcs, ensure_ascii=False, indent=2)}
2) 仅可引用以下事件名（可省略）：
   ALLOWED_EVENTS = {json.dumps(allowed_events, ensure_ascii=False, indent=2)}
3) 参与者仅限：owner、alice、bob、carol；不要写 0x.. 字面量。
4) steps 每步 "call" 必须是可直接嵌入 Solidity 的调用表达式（例如 "transfer(bob, 1)"）。
5) 如需支付 ETH，请在该步写 "value": "<wei或带单位>"；不写即视为 0。
6) 必要前置请写入 "requires"；生成器将严格在 steps 之前按顺序执行。
7) 所有数组/tuple[] 的最小长度、索引上界或必要元素数量，必须在 "array_constraints" 中显式声明，
   例如 "constructor.proposals:bytes32[]": 3 或 "setList.arg0:address[]": 2。不要依赖生成器推断。
8) 如预期回退，请在该步写 "expect": "revert" 或 "revert:<子串>"；否则默认 "ok"。
9) "post" 仅允许以下断言片段（由下游映射为可执行断言）：
   - "balance(X) += N" / "balance(X) -= N" / "balance(X) == N"（X只能为owner,alice,bob,carol）
   - "allowance(alice,bob) == N"
   - "owner() == alice|bob|carol"
   - "supply conserved"
   - "call:totalSupply() >= 100",
   - "bool:isPaused() == false",
   - "addr:owner() == alice",
   - "approx:getPrice() = 1000 ± 2",
   - "len:getWhitelist() == 3",
   - "has:getWhitelist() CONTAINS alice",
   - "sload:5 == 100",
   - "cmp:totalSupply() == balanceOf(alice) + balanceOf(bob)"
10) 不得使用未出现在 ABI 的函数名、伪代码、或凭空假设的状态改变；若需要状态，请写在 "prestate" 或 "requires"。
11) 序列数量 ≤ {max_sequences}；每条 steps 长度 2~{max_steps}；覆盖 1 条正常路径 + 至少 1 条边界/负路径更佳。
"""

    facts = _build_source_facts(source_text)
    facts_note = f"\n源码事实（解析自源码，供你严格遵守，不要猜测）：\n{json.dumps(facts, ensure_ascii=False, indent=2)}\n" if source_text else ""

    task = f"""
你是 Solidity 测试规划器。请基于给定 ABI 和标准特性，为合约生成多步功能正确性/交易序列测试的“规划 JSON”。

合约名称：{contract_name}
标准特性（参考）：{", ".join(standards) if standards else "（未指定）"}

ABI（仅供参考/约束）：
{json.dumps(abi, ensure_ascii=False, indent=2)}
{src_note}

{facts_note}

请输出满足下述 Schema 的 JSON，对每条序列解释最小但清晰的 intent，并确保每个 step 均可由下游直接渲染为 Solidity 测试代码。
"""

    prompt = f"{task}\n\n===== 输出 Schema =====\n{schema}\n===== 约束 =====\n{constraints}\n\n仅输出 JSON："
    return prompt

def build_per_function_prompt(contract_name: str,
                              abi: List[dict],
                              source_text: Optional[str] = None,
                              max_steps: int = 6) -> str:
    """请 LLM 为“每个 ABI 函数”生成一条最小可执行序列，自动补充必要前置，并带基本断言。"""
    allowed_funcs = abi_allowed_functions(abi)
    allowed_events = abi_allowed_events(abi)
    fn_names = sorted({it["name"] for it in abi if it.get("type")=="function"})
    src_note = f"\n源码：\n{source_text}\n" if source_text else ""

    schema = r"""
{
  "name": "LLM-PerFn",
  "sequences": [
    {
      "name": "str",                        // 该条用例名称
      "target_fn": "exact function name",   // ★ 必填：目标函数名（按 ABI name）
      "intent": "str",
      "bootstrap": [                        // 可选：余额/环境准备
        { "kind": "mint_or_transfer_to_alice", "amount": "100" }
      ],
      "prestate": {                         // 可选：部署后立即执行
        "solidity": [],
        "vm_stores": []
      },
      "requires": [                         // ★ 仅放该函数必需的最小前置（如 approve / unpause）
        { "who": "owner", "call": "unpause()", "value": "0" }
      ],
      "steps": [                            // ★ 该函数的一次最小调用（如需要也可两步，但最多 {max_steps}）
        { "who": "alice", "call": "transfer(bob, 1)", "value": "0", "expect": "ok" }
      ],
      "array_constraints": {                // 若该函数有数组参数，声明长度即可（不写则默认 1）
        "transferMany.arg0:address[]": 2
      },
      "post": [                             // 至少 1 条基本断言（若确实无可断言，可留空）
        // "balance(alice) -= 1", "balance(bob) += 1", "supply conserved"
      ],
      "events": []
    }
  ]
}
"""

    constraints = f"""
强约束（逐函数兜底版）：
1) 仅使用以下 ABI 函数签名：{json.dumps(allowed_funcs, ensure_ascii=False)}
2) 事件名仅可取：{json.dumps(allowed_events, ensure_ascii=False)}
3) 覆盖以下每个函数，且每个函数**恰好 1 条**最小序列：{json.dumps(fn_names, ensure_ascii=False)}
4) steps 只需包含对 target_fn 的一次最小可执行调用；如存在必要前置，放入 "requires"。
5) 若 target_fn 含数组/tuple[] 入参，请在 "array_constraints" 指定各参数长度（不写则默认 1）。
6) 如需支付 ETH，请在该步写 "value": "<wei或带单位>"；否则默认 0。
7) 如预期回退，请在该步写 "expect": "revert" 或 "revert:<子串>"；否则默认 "ok"。
8) "post" 至少包含 1 条“基本断言”更佳（从以下枚举选择）：
   - "balance(X) += N" / "balance(X) -= N" / "balance(X) == N"
   - "allowance(alice,bob) == N"
   - "owner() == alice|bob|carol"
   - "supply conserved"（若本序列未改变总供给）
   - "call:totalSupply() >= 100",
   - "bool:isPaused() == false",
   - "addr:owner() == alice",
   - "approx:getPrice() = 1000 ± 2",
   - "len:getWhitelist() == 3",
   - "has:getWhitelist() CONTAINS alice",
   - "sload:5 == 100",
   - "cmp:totalSupply() == balanceOf(alice) + balanceOf(bob)"
9) 参与者仅限 owner、alice、bob、carol；不要写 0x.. 字面量。
10) 严格输出一段 JSON，无 Markdown、无注释、无额外文本。
"""
    
    facts = _build_source_facts(source_text)
    facts_note = f"\n源码事实（解析自源码，供你严格遵守，不要猜测）：\n{json.dumps(facts, ensure_ascii=False, indent=2)}\n" if source_text else ""

    task = f"""
你是 Solidity 测试规划器。请为“每个 ABI 函数”生成一条**最小可执行**序列：自动补充可能需要的前置（如先 mint/approve/unfreeze/unpause/设置 owner 等），并给出至少一条基本断言。合约：{contract_name}

ABI（参考/约束）：
{json.dumps(abi, ensure_ascii=False, indent=2)}
{src_note}

{facts_note}

请按下述 Schema 输出严格 JSON。
"""
    return f"{task}\n===== Schema =====\n{schema}\n===== 约束 =====\n{constraints}\n\n仅输出 JSON："


def llm_plan_per_function_sequences(contract_name: str,
                                    abi: List[dict],
                                    api_key: str,
                                    source_text: Optional[str] = None,
                                    api_url: str = "https://api.openai.com/v1/chat/completions",
                                    model: str = "gpt-4.1",
                                    max_steps: int = 3) -> Dict[str, Any]:
    """
    让 LLM 一次性为每个 ABI 函数返回 1 条“最小兜底序列”，包含前置与基本断言。
    若 LLM 覆盖不全，按简单启发式补齐缺失函数的一条最小序列（保证每个函数都有）。
    """
    def _fn_has_array_input(abi: List[dict], name: str) -> bool:
        for it in abi:
            if it.get("type")=="function" and it["name"]==name:
                if any(t["type"].strip().endswith("[]") for t in it.get("inputs", [])):
                    return True
        return False
    
    # —— want：仅挑选“无数组入参”的函数名
    all_names = sorted({it["name"] for it in abi if it.get("type")=="function"})
    want = [fn for fn in all_names if not _fn_has_array_input(abi, fn)]
    prompt = build_per_function_prompt(contract_name, abi, source_text=source_text, max_steps=max_steps)
    # print(prompt)
    raw = call_llm(prompt, api_key=api_key, api_url=api_url, model=model)
    data = _extract_json_block(raw)
    plan = {"name":"LLM-PerFn","sequences":[]}
    # 过滤 LLM 返回的 per-fn 序列里带数组入参的目标
    if isinstance(data, dict) and "sequences" in data:
        seqs_filtered = []
        for s in data["sequences"]:
            tf = s.get("target_fn")
            if tf and _fn_has_array_input(abi, tf):
                continue
            seqs_filtered.append(s)
        data["sequences"] = seqs_filtered
        plan = _validate_plan_against_abi(data, abi, max_steps=max_steps)

    # ---- 覆盖性补齐（以“函数名”为单位；重载合并为同名一条） ----
    want = sorted({it["name"] for it in abi if it.get("type")=="function"})
    have = set()
    # 统计已有覆盖：看 steps 里是否调用了该函数名
    for s in plan.get("sequences", []):
        called = set()
        for st in s.get("steps", []):
            m = re.match(r"([A-Za-z_][A-Za-z0-9_]*)\s*\(", st.get("call","").strip())
            if m: called.add(m.group(1))
        if called:
            have.update(called)
    missing = [fn for fn in want if fn not in have]

    # 简易字面量/角色启发：与之前的 per-fn 生成一致，但只做单步（必要时自动插入 approve/mint 前置与基本断言）
    def _mk_min_seq_for_fn(fn: str) -> Dict[str, Any]:
        # 找该名下某个原型
        matches = [it for it in abi if it.get("type")=="function" and it["name"]==fn]
        if not matches:
            return None
        # ★ 跳过数组入参函数
        if any(any(inp["type"].strip().endswith("[]") for inp in it.get("inputs", [])) for it in matches):
            return None
        inputs = matches[0].get("inputs", [])
        # inputs = matches[0].get("inputs", []) if matches else []
        arglits = []
        for inp in inputs:
            arglits.append(_solidity_literal(inp["type"], inp.get("name",""), legacy=False))
        args = ", ".join(arglits)

        # 角色与前置
        actor = "owner" if any(k in fn.lower() for k in ["owner","pause","unpause","mint","freeze","change","set"]) else "alice"
        bootstrap = []
        steps = []
        posts = []

        # ERC20 常见特判
        if fn == "transfer" and [x["type"] for x in inputs] == ["address","uint256"]:
            bootstrap = [{"kind":"mint_or_transfer_to_alice","amount":"100"}]
            steps = [{"who":"alice","call":"transfer(bob, 1)","value":"0"}]
            posts = ["balance(alice) -= 1", "balance(bob) += 1", "supply conserved"]
        elif fn == "approve" and [x["type"] for x in inputs] == ["address","uint256"]:
            bootstrap = [{"kind":"mint_or_transfer_to_alice","amount":"1"}]
            steps = [{"who":"alice","call":"approve(bob, 1)","value":"0"}]
            posts = ["allowance(alice,bob) == 1"]
        elif fn == "transferFrom" and [x["type"] for x in inputs] == ["address","address","uint256"]:
            bootstrap = [{"kind":"mint_or_transfer_to_alice","amount":"100"}]
            steps = [
                {"who":"alice","call":"approve(bob, 1)","value":"0"},
                {"who":"bob","call":"transferFrom(alice, bob, 1)","value":"0"}
            ]
            posts = ["allowance(alice,bob) == 0", "balance(bob) += 1", "balance(alice) -= 1", "supply conserved"]
        elif fn in ("mintToken","mint") and len(inputs)==2:
            steps = [{"who":"owner","call":f"{fn}(alice, 1)","value":"0"}]
            posts = ["balance(alice) += 1"]  # 供应变化，故不写 supply conserved
        elif fn == "transferOwnership" and len(inputs)==1 and inputs[0]["type"]=="address":
            steps = [{"who":"owner","call":"transferOwnership(alice)","value":"0"}]
            posts = ["owner() == alice"]
        else:
            # 通用：直接调用，给最小可行参数，角色偏向 owner
            steps = [{"who": actor, "call": f"{fn}({args})", "value": "0"}]
            posts = []  # 通用函数不好断言，交给主计划覆盖；这里允许空

        name = _sanitize_solidity_identifier(f"perfn_{fn}", "perfn")
        return {"name": name, "target_fn": fn, "intent": f"minimal test for {fn}",
                "bootstrap": bootstrap, "steps": steps, "post": posts, "events": []}

    if missing:
        seqs = plan.get("sequences", [])
        for fn in missing:
            m = _mk_min_seq_for_fn(fn)
            if m is not None:
                seqs.append(m)
        plan["sequences"] = seqs

    return plan

# -------------------------------------------------------
# 4) 解析 + 纠错 + 规范化（把 LLM 产物变为我们生成器所需 dict）
# -------------------------------------------------------
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

def _validate_plan_against_abi(plan: Dict[str, Any], abi: List[dict], max_steps: int = 6)-> Dict[str, Any]:
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
            if who not in ("owner", "alice", "bob", "carol"):
                who = "alice"
            st_norm = {"who": who, "call": call2}
            if "value" in st and isinstance(st["value"], (str, int)):
                v = str(st["value"]).strip()
                st_norm["value"] = v if v else "0"
            if "expect" in st and isinstance(st["expect"], str):
                st_norm["expect"] = st["expect"].strip()
            # 规范 value
            if "value" in st and isinstance(st["value"], (str, int)):
                v = str(st["value"]).strip()
                st_norm["value"] = v if v else "0"
            ok_steps.append(st_norm)
        if ok_steps and (len(ok_steps) <= max_steps):
            seq_norm = {
                "name": s.get("name", "seq"),
                "intent": s.get("intent", s.get("name", "sequence")),
                "bootstrap": s.get("bootstrap", []),
                "steps": ok_steps,
                "post": s.get("post", []),
                "events": s.get("events", []),
                "prestate": s.get("prestate", {}),
                "requires": s.get("requires", []),
                "array_constraints": s.get("array_constraints", {}),
                "assume": s.get("assume", []),
                "covered_branches": s.get("covered_branches", [])
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
                       max_sequences: int = 4,
                       max_steps: int = 6) -> Dict[str, Any]:
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
        max_sequences=max_sequences,   # ← 放宽上限
        max_steps=max_steps
    )

    # print(prompt)

    raw = call_llm(prompt, api_key=api_key, api_url=api_url, model=model)
    data = _extract_json_block(raw)
    if not isinstance(data, dict) or "sequences" not in data:
        return {"name": "LLM-Plan", "sequences": []}
    return _validate_plan_against_abi(data, abi, max_steps=max_steps)


# =========================
# 1) 头部模板（加入HELPERS占位）
# =========================

PRELUDE_04 = """// Foundry cheatcodes binding for Solidity 0.4.x
// 0.4 没有 interface，用抽象合约声明
contract Vm {
    function prank(address) public;
    function startPrank(address) public;
    function stopPrank() public;
    function deal(address, uint256) public;
    function expectRevert() public;
    function expectRevert(bytes) public;
    function store(address, bytes32, bytes32) public;
    function load(address, bytes32) public returns (bytes32);
}
"""

PRELUDE_05_06_07 = """// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}
"""

HEADER_04 = """// SPDX-License-Identifier: MIT
pragma solidity {PRAGMA};
import "../src/{FILENAME}.sol";

{PRELUDE}
contract {CONTRACT}_FunctionalTest {{
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function {CONTRACT}_FunctionalTest() public {{
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }}

    function() public payable {{ }}

{HELPERS}
{TESTS}
}}
"""

HEADER_05 = """// SPDX-License-Identifier: MIT
pragma solidity {PRAGMA};
import "../src/{FILENAME}.sol";

{PRELUDE}
contract {CONTRACT}_FunctionalTest {{
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {{
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }}

    function() external payable {{ }}

{HELPERS}
{TESTS}
}}
"""

HEADER_06_07 = """// SPDX-License-Identifier: MIT
pragma solidity {PRAGMA};
import "../src/{FILENAME}.sol";

{PRELUDE}
contract {CONTRACT}_FunctionalTest {{
    // 绑定 vm（hevm cheatcodes 固定地址）
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {{
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }}

    receive() external payable {{ }}
    fallback() external payable {{ }}

{HELPERS}
{TESTS}
}}
"""

HEADER_08 = """// SPDX-License-Identifier: MIT
pragma solidity ^{PRAGMA};
import "forge-std/Test.sol";
import "../src/{FILENAME}.sol";

{PRELUDE}
contract {CONTRACT}_FunctionalTest is Test {{
    address owner = address(0x0A0A);
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address carol = address(0xCA1CE);

{HELPERS}
{TESTS}
}}
"""

HELPERS_04 = """
    // ---------- Helpers (0.4) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b);
    }
    function _assertTrue(bool ok, string why) internal { require(ok); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string why) internal {
        // op: 0==,1!=,2>=,3<=,4>,5<
        if (op == 0) require(a == b);
        else if (op == 1) require(a != b);
        else if (op == 2) require(a >= b);
        else if (op == 3) require(a <= b);
        else if (op == 4) require(a >  b);
        else if (op == 5) require(a <  b);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string why) internal {
        if (a >= b) require(a - b <= tol); else require(b - a <= tol);
    }
    function _assertEqA(address a, address b) internal { require(a == b); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b); }
    function _assertEqS(string a, string b) internal { if (sha3(a) != sha3(b)) { require(false); } }
"""

HELPERS_PRE08 = """
    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }
"""

HELPERS_08 = """
    // ---------- Helpers (0.8+) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        assertEq(a, b);
    }
    function _delta(int256 after_, int256 before_) internal pure returns (int256) {
        return after_ - before_;
    }
    function _assertTrue(bool ok, string memory why) internal {
        assertTrue(ok, why);
    }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) assertEq(a, b, why);
        else if (op == 1) assertTrue(a != b, why);
        else if (op == 2) assertGe(a, b, why);
        else if (op == 3) assertLe(a, b, why);
        else if (op == 4) assertTrue(a >  b, why);
        else if (op == 5) assertTrue(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        assertLe(d, tol, why);
    }

"""

TEST_TMPL_08 = """
    // @cover-intent {intent}
    function test_{name}_{idx}() public {{
{body}
    }}
"""

TEST_TMPL_04 = """
    // @cover-intent {intent}
    function test_{name}_{idx}() public {{
{body}
    }}
"""

# =========================
# 2) ABI/签名工具
# =========================
# === NEW: ABI helpers ===
def _abi_find_functions(abi: List[dict], name: str) -> List[dict]:
    return [it for it in abi if it.get("type") == "function" and it.get("name") == name]

def _returns_bool(abi: List[dict], fn: str) -> bool:
    for it in _abi_find_functions(abi, fn):
        outs = it.get("outputs", []) or []
        if any((o.get("type") or "").strip().startswith("bool") for o in outs):
            return True
    return False

def _sig_of(item: dict) -> str:
    """function item -> 'name(t1,t2,...)' """
    return f"{item['name']}({','.join(i['type'] for i in item.get('inputs', []))})"

def _has_fn(abi: List[dict], name: str, arg_types: Optional[List[str]] = None) -> bool:
    for it in abi:
        if it.get("type") != "function": continue
        if it["name"] != name: continue
        if arg_types is None: return True
        if [x["type"] for x in it.get("inputs", [])] == arg_types:
            return True
    return False

# =========================
# 3) 字面量生成（修复数组、基本可读性）
# =========================

def _solidity_literal(typ: str, name: str = "", legacy: bool=False):
    t = typ.strip()
    n = (name or "").lower()

    if t.startswith("uint") or t.startswith("int"):
        if "decimal" in n or "decimals" in n: return "18"
        if any(k in n for k in ("amount","supply","value","cap","limit")): return "100"
        if "fee" in n: return "1"
        return "1"

    if t.startswith("bytes") and t != "bytes":
        if t == "bytes32": return "bytes32(uint256(1))"
        return f"{t}(0)"
    if t == "bytes":
        return 'hex"01"'

    if t == "string":
        if "name" in n: return '"Name"'
        if "symbol" in n or "sym" in n: return '"SYM"'
        return '"X"'

    if t.startswith("address"):
        if "to" in n and "from" not in n: return "bob"
        if "owner" in n: return "alice"
        return "alice"

    if t == "bool":
        return "true"

    # 数组字面量不要直接返回 "new T"，由递归器统一处理
    if t.endswith("]"):
        base = _base_of_array(t)
        if _is_static_array(t):
            k = _static_array_len(t)
            return f"{base}[{k}](/* filled by emitter */)"
        return f"{base}[]( /* by emitter */ )"

    # tuple 在 ABI 中不该走这里；递归器会处理
    return "0"

# -----------------------
# ABI 参数递归发射器
# -----------------------

def _is_static_array(t: str) -> bool:
    return bool(re.search(r"\[[0-9]+\]\s*$", t.strip()))

def _static_array_len(t: str) -> int:
    m = re.search(r"\[([0-9]+)\]\s*$", t.strip())
    return int(m.group(1)) if m else 0

def _base_of_array(t: str) -> str:
    return re.sub(r"\[[0-9]*\]\s*$", "", t.strip())

def _short_prim_literal(typ: str, name_hint: str = "") -> str:
    t = typ.strip()
    n = (name_hint or "").lower()
    if t.startswith("uint") or t.startswith("int"):
        if "decimal" in n or "decimals" in n: return "18"
        if any(k in n for k in ("amount","supply","value","cap","limit")): return "100"
        if "fee" in n: return "1"
        return "1"
    if t.startswith("bytes") and t != "bytes":  # bytes1..bytes32
        # 用最简单占位：bytes32(uint256(1)) 风格；按位宽转换
        if t == "bytes32": return "bytes32(uint256(1))"
        # 小于 32 的 bytesN 统一转 cast：bytes4(0x01020304) 太花哨，这里最简
        return f"{t}(0)"
    if t == "bytes":
        return 'hex"01"'
    if t == "string":
        return '"X"'
    if t == "bool":
        return "true"
    if t.startswith("address"):
        return "alice"
    return "0"

def _wrap_actor_for_decl_type(raw: str, decl_t: str, pre_08: bool) -> str:
    """将 owner/alice/bob/carol 包装为期望类型（address payable / 合约类型 / 接口类型）"""
    a = raw.strip()
    if not re.fullmatch(r"(owner|alice|bob|carol)", a):
        return raw

    t = (decl_t or "").strip().replace("  ", " ")
    t = t.replace(" memory","").replace(" storage","").replace(" calldata","").strip()

    # 合约/接口类型（例如 IPinger / MyToken / Other.Contract）
    if t and not t.startswith("address") and not t.startswith("uint") and not t.startswith("int") and not t.startswith("bytes") and t not in ("bool","string"):
        # 取最右的类型名
        type_name = t.split()[-1]
        return f"{type_name}({a})"

    # address payable
    if t.startswith("address") and "payable" in t:
        return f"address(uint160({a}))" if pre_08 else f"payable({a})"

    # 普通 address
    if t.startswith("address"):
        return a

    return a

def _emit_value_for_abi_param(
    abi_input: dict,
    fn_name: str,
    pidx: int,
    ng: _NameGen,
    src_text: Optional[str],
    pre_08: bool,
    contract_name: str,
    src_decl_map: Optional[Dict[str, List[List[str]]]] = None,
    structs: Optional[Dict[str, List[tuple]]] = None,
    enums: Optional[set] = None,
    depth: int = 0
) -> Tuple[List[str], str]:
    """
    返回: (prep_lines, expr)
    - 对 tuple/数组/嵌套数组 会生成内存变量/赋值，再返回该变量名作为实参。
    - 对基础类型直接返回字面量，若为地址参与者会按声明类型包成 payable/接口类型。
    - 对 enum：若源码声明为 EnumName，则生成 EnumName(0)。
    """
    prep: List[str] = []
    t = abi_input["type"].strip()
    name_hint = abi_input.get("name", "")

    # 源码声明类型（用于 address payable / 合约类型 / enum 的强制包装）
    src_decl_map = src_decl_map or _map_fn_params_with_decl_names(src_text)
    structs = structs or _parse_struct_and_enum_names(src_text)[0]
    enums = enums or _parse_struct_and_enum_names(src_text)[1]
    decl_t = None
    cands = src_decl_map.get(fn_name) or []
    for decls in cands:
        if pidx < len(decls):
            decl_t = decls[pidx]
            break

    # ---------- 1) tuple / tuple[...] ----------
    if t == "tuple" or t.startswith("tuple["):
        comps = abi_input.get("components", []) or []
        # 猜结构体完整名（可能含命名空间）
        sname = _guess_struct_name_for_param(fn_name, pidx, src_decl_map, structs)
        # 若是数组形式：tuple[] 或 tuple[k]
        if t.endswith("]"):
            # 元素递归构造 struct 或匿名 tuple（优先 struct）
            # 先确定长度：固定长或取一个最小合规长度（默认 1）
            arr_len = 1
            if _is_static_array(t):
                arr_len = _static_array_len(t)
            elem_var_t = None
            if sname:
                elem_var_t = sname  # 例如 "MyContract.MyStruct"
            else:
                # 没有源码类型名时，尝试匿名 tuple → 只能靠 struct 名；匿名 tuple 在跨合约实参**不合法**，
                # 因此这里降级为“跳过该参数”的策略：生成一个零值占位（极端容错），或抛给上层跳过此序列。
                # 为不破坏整体测试生成，这里走最安全 0 值（会触发类型不匹配则剔除用例）
                # 你也可以选择 return ([], "/* TODO tuple[] without struct name */")
                tmp = ng.new("skip_tuple_arr")
                prep.append(f"/* tuple[] param at #{pidx} unresolved (no struct name in source); skipping by zero */")
                return prep, "0"

            arr_name = ng.new("arrS")  # struct array
            prep.append(f"{elem_var_t}[] memory {arr_name} = new {elem_var_t}[]({arr_len});")
            for i in range(arr_len):
                # 为每个元素生成临时 struct，再赋值到数组
                s_var = ng.new("s")
                # 用“声明后赋字段”的模式以兼容 0.5+
                prep.append(f"{elem_var_t} memory {s_var};")
                # 逐字段递归
                for j, c in enumerate(comps):
                    c_prep, c_expr = _emit_value_for_abi_param(c, fn_name, pidx, ng, src_text, pre_08, contract_name, src_decl_map, structs, enums, depth+1)
                    prep.extend(c_prep)
                    fname = c.get("name") or f"f{j}"
                    # 结构字段名可能冲突，做一次标识符规整
                    fname = _sanitize_solidity_identifier(fname, f"f{j}")
                    prep.append(f"{s_var}.{fname} = {c_expr};")
                prep.append(f"{arr_name}[{i}] = {s_var};")
            return prep, arr_name

        # 非数组：单个 tuple → 优先使用 StructName
        if sname:
            s_var_t = sname
            s_var = ng.new("s")
            prep.append(f"{s_var_t} memory {s_var};")
            for j, c in enumerate(comps):
                c_prep, c_expr = _emit_value_for_abi_param(c, fn_name, pidx, ng, src_text, pre_08, contract_name, src_decl_map, structs, enums, depth+1)
                prep.extend(c_prep)
                fname = c.get("name") or f"f{j}"
                fname = _sanitize_solidity_identifier(fname, f"f{j}")
                prep.append(f"{s_var}.{fname} = {c_expr};")
            return prep, s_var
        else:
            # 同上说明：跨合约传递匿名 tuple 缺少类型名将无法通过编译，这里退化为“0”，并在注释中提示
            prep.append(f"/* tuple param at #{pidx} unresolved struct name; fallback 0 */")
            return prep, "0"

    # ---------- 2) 数组 ----------
    if t.endswith("]"):
        # 动态 / 固定长
        base_t = _base_of_array(t)
        if _is_static_array(t):
            n = _static_array_len(t)
            arr_t = f"{base_t}[{n}]"
            arr_name = ng.new("arr")
            prep.append(f"{arr_t} memory {arr_name};")
            for i in range(n):
                fake_comp = {"type": base_t, "name": f"{name_hint}_{i}"}
                c_prep, c_expr = _emit_value_for_abi_param(fake_comp, fn_name, pidx, ng, src_text, pre_08, contract_name, src_decl_map, structs, enums, depth+1)
                prep.extend(c_prep)
                prep.append(f"{arr_name}[{i}] = {c_expr};")
            return prep, arr_name
        else:
            # 动态数组：给长度 1（最小可执行），必须声明并分配内存
            arr_name = ng.new("arr")
            arr_len = 1
            prep.append(f"{base_t}[] memory {arr_name} = new {base_t}[]({arr_len});")
            fake_comp = {"type": base_t, "name": f"{name_hint}_0"}
            c_prep, c_expr = _emit_value_for_abi_param(
                fake_comp, fn_name, pidx, ng, src_text, pre_08,
                contract_name, src_decl_map, structs, enums, depth+1
            )
            prep.extend(c_prep)
            prep.append(f"{arr_name}[0] = {c_expr};")
            return prep, arr_name

    # ---------- 3) enum（ABI 中会呈现为 uint8/uint...；需靠源码声明识别） ----------
    if decl_t:
        base = decl_t.replace(" memory","").replace(" storage","").replace(" calldata","").strip()
        base = base.rstrip("]").rstrip("[")  # 去数组后缀
        base_last = base.split(".")[-1]
        if base_last in (enums or set()):
            # 有命名空间时保留
            enum_t = decl_t
            # 取第 0 个枚举项（最小可执行）
            return prep, f"{enum_t}(0)"

    # ---------- 4) function 类型 ----------
    if t == "function":
        # 最通用的做法：在测试合约里放一个最小可匹配签名的 dummy 函数并取其 selector/address
        # 由于 ABI 仅给 "function" 无参数信息，无法精准选择签名，这里给一个地址+selector 占位。
        # EVM 编码中 function 类型为 address + bytes4。
        ftuple = ng.new("fnptr")
        prep.append(f"(address,{ 'bytes4' }) memory {ftuple};")
        prep.append(f"{ftuple} = (address(target), bytes4(0));  // minimal placeholder")
        return prep, f"{ftuple}"

    # ---------- 5) address / payable / 合约类型 ----------
    if t.startswith("address"):
        lit = _short_prim_literal(t, name_hint)
        # 若源码声明类型为合约/接口或 payable，则做强制包装
        lit = _wrap_actor_for_decl_type(lit, decl_t or t, pre_08)
        return prep, lit

    # ---------- 6) 其它基元 ----------
    return prep, _short_prim_literal(t, name_hint)

def _extract_ctor_param_types_from_source(source_text: Optional[str]) -> Optional[List[str]]:
    """从源码里抓 constructor(...) 的参数类型（不看修饰名），返回每个参数的类型字符串列表。
       例：['address payable','address','IPinger']"""
    if not source_text:
        return None
    m = re.search(r"constructor\s*\((.*?)\)", source_text, flags=re.S)
    if not m:
        return None
    inside = m.group(1)
    parts = [p.strip() for p in inside.split(",") if p.strip()]
    types = []
    for p in parts:
        toks = p.split()
        if not toks:
            continue
        # 最后一个 token 一般是形参名，其余合并为“类型”
        tks = toks[:-1] if len(toks) >= 2 else toks
        t = " ".join(tks)
        # 去掉可选的关键字前缀
        t = re.sub(r"^(contract|interface)\s+", "", t)
        types.append(t.strip())
    return types or None

def _format_ctor_arg_by_type(raw_expr: str, typ: str, pre_08: bool) -> str:
    """根据类型把参与者标识（alice/bob/…）或已有字面量，转换为期望形态。"""
    # 仅对我们认识的地址角色作处理，其它字面量原样返回
    is_actor = re.fullmatch(r"(owner|alice|bob|carol)", raw_expr) is not None
    if not is_actor:
        return raw_expr

    t = typ.strip()
    # 合约/接口类型：如 IPinger
    if t and not t.startswith("address") and not t.startswith("uint") and not t.startswith("int") and not t.startswith("bytes") and t != "bool" and t != "string":
        # 只保留类型名（去掉多余空格）
        type_name = t.split()[-1]
        return f"{type_name}({raw_expr})"

    # address payable：老版本要 address(uint160(x))
    if "address" in t and "payable" in t and pre_08:
        return f"address(uint160({raw_expr}))"

    # 普通 address：直接用
    if t == "address" or t.startswith("address "):
        return raw_expr

    return raw_expr

def _apply_ctor_type_casts(vals: List[str], types: Optional[List[str]], pre_08: bool) -> List[str]:
    if not types or len(types) != len(vals):
        return vals
    out = []
    for v, t in zip(vals, types):
        out.append(_format_ctor_arg_by_type(v.strip(), t, pre_08))
    return out

def _ctor_args_from_abi(abi: list, legacy_04: bool, pre_08: bool, source_text: Optional[str] = None):
    """
    使用 ABI + 源码声明（若有）生成“构造器参数”的声明与表达式。
    返回：字符串形式的参数表达式串（但我们同时在 _mk_new_stmt/_render_sequence 里预先插了 prep 行）
    这里保持向后兼容，仅返回表达式串；prep 行由调用方负责。
    """
    ctor_item = next((it for it in abi if it.get("type") == "constructor"), None)
    if not ctor_item:
        return ""

    ng = _NameGen()
    src_decl_map = _map_fn_params_with_decl_names(source_text)
    structs, enums = _parse_struct_and_enum_names(source_text)

    arg_exprs = []
    prep_accum = []

    for i, inp in enumerate(ctor_item.get("inputs", [])):
        pprep, pexpr = _emit_value_for_abi_param(
            abi_input=inp,
            fn_name="constructor",
            pidx=i,
            ng=ng,
            src_text=source_text,
            pre_08=pre_08,
            contract_name="",  # 构造阶段无需
            src_decl_map=src_decl_map,
            structs=structs,
            enums=enums
        )
        prep_accum.extend(pprep)
        arg_exprs.append(pexpr)

    # 把“prep 行”缓存到一个约定的全局（不理想），或直接在调用方提前渲染。
    # 为尽量少改动，这里将 prep 行返回给调用方：通过附带属性塞回（见下文改动点）。
    _ctor_args_from_abi._last_prep = prep_accum  # type: ignore[attr-defined]

    return ", ".join(arg_exprs)

# =========================
# 4) Standards 内置（ERC20/Ownable）
#    - 若传入 standards 为字符串列表，则匹配/启用对应内置
#    - 若传入 standards 为 dict 列表（LLM 产物），则直接使用
# =========================

STANDARDS_DB: Dict[str, Dict[str, Any]] = {}  # {"Ownable": {...}, "AccessControl": {...}, ...}

def load_standards_json(path: str) -> None:
    """从 JSON 文件加载标准定义，写入全局 STANDARDS_DB"""
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    # 兼容两种外层结构：{"standards": {...}} 或直接 {...}
    if isinstance(data, dict) and "standards" in data:
        STANDARDS_DB.clear()
        STANDARDS_DB.update(data["standards"])
    else:
        STANDARDS_DB.clear()
        STANDARDS_DB.update(data)

def _standard_is_matched(abi: List[dict], std: Dict[str, Any]) -> bool:
    """粗匹配：仅用函数签名（不看事件）"""
    fns = set(_sig_of(it) for it in abi if it.get("type")=="function")
    must = set(std["match"].get("must", []))
    if not must.issubset(fns):
        return False
    anys = set(std["match"].get("any", []))
    # 如果 any 为空或被满足之一即可
    return (len(anys)==0) or (len(fns.intersection(anys))>0)

# =========================
# 5) LLM 产物融合：
#    - 若 standards 传入 dict（包含 "name"/"sequences"），直接用
#    - 否则按字符串激活内置；也可以混合：["ERC20", custom_dict, ...]
# =========================

def _collect_sequences(abi: List[dict], standards: List[Any]) -> List[Dict[str, Any]]:
    """支持两种传参：
    - 字符串：从全局 STANDARDS_DB 取该 standard 并按 match/ requires 过滤后收集 sequences
    - dict：视为 LLM 产物（包含 "sequences"），直接并入
    """
    seqs: List[Dict[str, Any]] = []
    for st in standards or []:
        # 1) 直接字典：LLM 产物/自定义标准
        if isinstance(st, dict) and "sequences" in st:
            seqs.extend(st["sequences"])
            continue
        # 2) 名称：在 STANDARDS_DB 中查找
        if isinstance(st, str):
            std = STANDARDS_DB.get(st)
            if not std:
                continue
            if _standard_is_matched(abi, std):
                for s in std.get("sequences", []):
                    req = s.get("requires", [])
                    ok = True
                    for sig in req:
                        name = sig.split("(")[0]
                        types = sig[sig.find("(")+1:sig.find(")")]
                        arg_types = [] if types=="" else types.split(",")
                        if not _has_fn(abi, name, arg_types):
                            ok = False
                            break
                    if ok:
                        seqs.append(s)
    return seqs

# =========================
# 6) 生成 Solidity 代码（多步序列 + 兜底单步）
# =========================

def _mk_new_stmt(contract_name: str, abi: List[dict], legacy_04: bool, use_vm: bool, pre_08: bool) -> List[str]:
    # 1) 生成构造实参（并由 _ctor_args_from_abi 设置 _last_prep）
    ctor_args = _ctor_args_from_abi(abi, legacy_04, pre_08)
    ctor_prep = getattr(_ctor_args_from_abi, "_last_prep", [])  # 可能为空列表

    # 2) 组装 new 行
    new_line = (
        f"{contract_name} target = new {contract_name}({ctor_args});"
        if ctor_args else
        f"{contract_name} target = new {contract_name}();"
    )

    # 3) 按需渲染 prep 行（必须在 new 之前）
    if use_vm:
        out = ["        vm.startPrank(owner);"]
        out += [f"        {ln}" for ln in ctor_prep]      # ← 就在 new 之前插入
        out += [f"        {new_line}", "        vm.stopPrank();"]
        return out
    else:
        out = [f"        {ln}" for ln in ctor_prep]       # ← 就在 new 之前插入
        out += [f"        {new_line}"]
        return out

def _render_bootstrap(abi: List[dict], legacy_04: bool, amount_str: str, use_vm: bool) -> List[str]:
    """
    为 LLM 序列准备初始余额：
      - 若存在 onlyOwner 铸币函数：同时给 alice 与 owner 铸同额，避免后续出现“owner 余额为 0”的转账 revert；
      - 无论是否铸币，都尽量调用常见的“解锁/开关”，并对四个账户做一次解冻；
      - 若既没有铸币也没有任何开关，就兜底 owner -> alice 转一点。
    说明：supply conserved 的断言在我们 snapshot 之后，因此 bootstrap 中的增发不会破坏该断言。
    """
    L: List[str] = []

    def prank_owner():
        if use_vm: L.append("        vm.prank(owner);")

    did_mint = False

    # 1) onlyOwner 铸币：给 alice 和 owner 都铸同额，防后续 owner 首笔转账因余额为 0 而 revert
    if _has_fn(abi, "mintToken", ["address", "uint256"]):
        prank_owner(); L.append(f"        target.mintToken(alice, {amount_str});")
        prank_owner(); L.append(f"        target.mintToken(owner, {amount_str});")
        did_mint = True
    elif _has_fn(abi, "mint", ["address", "uint256"]):
        prank_owner(); L.append(f"        target.mint(alice, {amount_str});")
        prank_owner(); L.append(f"        target.mint(owner, {amount_str});")
        did_mint = True

    # 2) 常见“解锁/开关”——无论是否铸币，都尝试一次
    unlockers = [
        ("unpause", []),
        ("releaseTokenTransfer", []),
        ("enableTokenTransfer", []),
        ("openTrading", []),
        ("setTransferable", ["bool"]),
        ("setAllowTransfer", ["bool"]),
    ]
    for name, args in unlockers:
        if _has_fn(abi, name, args):
            prank_owner()
            if not args:
                L.append(f"        target.{name}();")
            else:
                L.append(f"        target.{name}(true);")

    # 3) 对四个参与者做一次“解冻”（如果合约支持）
    if _has_fn(abi, "freezeAccount", ["address", "bool"]):
        for who in ("owner", "alice", "bob", "carol"):
            prank_owner(); L.append(f"        target.freezeAccount({who}, false);")

    # 4) 若没有铸币函数，兜底从 owner → alice 转入启动资金
    if not did_mint and _has_fn(abi, "transfer", ["address", "uint256"]):
        if use_vm: L.append("        vm.startPrank(owner);")
        L.append(f"        target.transfer(alice, {amount_str});")
        if use_vm: L.append("        vm.stopPrank();")

    return L

# ---------- 小工具：部署者/构造器覆盖（Escrow 等） ----------
_valtmp_counter = {"i": 0}
def _new_valtmp() -> str:
    _valtmp_counter["i"] += 1
    return f"__v{_valtmp_counter['i']}"

def _build_abi_index(abi):
    index = {
        "functions": {},
        "has_balance_function": False
    }
    for item in abi:
        if item.get("type") != "function":
            continue
        name = item["name"]
        inputs = item.get("inputs", [])
        outputs = item.get("outputs", [])

        index["functions"][name] = {
            "inputs": inputs,
            "outputs": outputs
        }
        if name == "balance":
            index["has_balance_function"] = True
    return index


def _prelines_for_value_expr(value_str: str, abi_index) -> Tuple[List[str], str]:
    """
    若 value 形如 'call:fn(args)'，根据 ABI 返回类型生成安全变量声明。
    兼容 Solidity 0.4–0.8。
    """

    s = (str(value_str) or "").strip()
    m = re.match(r"call:([A-Za-z_]\w*)\((.*?)\)$", s)
    if not m:
        return [], s

    fn = m.group(1)
    a  = (m.group(2) or "").strip()

    if not re.fullmatch(r"[A-Za-z0-9_,\s()]*", a):
        a = ""

    if fn not in abi_index["functions"]:
        return [], s

    outputs = abi_index["functions"][fn].get("outputs", [])
    if not outputs:
        return [], s

    ret_type = outputs[0]["type"]

    vn = _new_valtmp()

    # -----------------------------
    # 类型安全生成
    # -----------------------------

    if ret_type.startswith("uint"):
        return [
            f"uint256 {vn} = uint256(target.{fn}({a}));"
        ], vn

    if ret_type.startswith("int"):
        return [
            f"int256 {vn} = int256(target.{fn}({a}));"
        ], vn

    if ret_type == "bool":
        return [
            f"bool {vn} = target.{fn}({a});"
        ], vn

    if ret_type == "address":
        return [
            f"address {vn} = target.{fn}({a});"
        ], vn

    if ret_type.startswith("bytes"):
        return [
            f"bytes memory {vn} = target.{fn}({a});"
        ], vn

    if ret_type.endswith("]"):  # array
        return [
            f"{ret_type} memory {vn} = target.{fn}({a});"
        ], vn

    # fallback（包括 enum 在 0.4–0.8 ABI 中表现为 uint8）
    return [
        f"uint256 {vn} = uint256(target.{fn}({a}));"
    ], vn

def _render_post_asserts(
    abi: List[dict],
    contract_name: str,
    seq: Dict[str,Any],
    legacy_04: bool,
    has_token_balance: bool,
    ctx: Dict[str, Any] = None
) -> List[str]:

    ctx = ctx or {}
    arb_role = ctx.get("arb_role")
    bene_role = ctx.get("bene_role")
    depositor_role = ctx.get("depositor_role")

    posts_raw = [p.strip() for p in seq.get("post", [])]

    # ---------------------------------------------------------
    # balance +=/-= 去重（保持原逻辑）
    # ---------------------------------------------------------
    seen_bal_actor = set()
    filtered_posts = []
    for c in posts_raw:
        m = re.match(r"balance\((alice|bob|carol|owner)\)\s*([+-]=)\s*(\d+)$", c)
        if m:
            who = m.group(1)
            if who in seen_bal_actor:
                continue
            seen_bal_actor.add(who)
        filtered_posts.append(c)

    L = []

    # =========================================================
    # 统一 lowering 入口（所有 fn() 必须经过这里）
    # =========================================================
    def lower_call(fn: str, args: str):
        expr = f"call:{fn}({args})"
        return _prelines_for_value_expr(expr, _build_abi_index(abi))

    # =========================================================
    # cmp 表达式 lowering（支持 fn() / 常数 / a+b / a-b）
    # =========================================================
    def emit_term(expr: str):
        expr = expr.strip()

        # 常数
        if re.fullmatch(r"\d+", expr):
            return [], expr

        # fn()
        m = re.match(r"([A-Za-z_]\w*)\((.*?)\)$", expr)
        if m:
            fnn = m.group(1)
            args2 = (m.group(2) or "").strip()
            if not re.fullmatch(r"[A-Za-z0-9_,\s()]*", args2):
                args2 = ""
            return lower_call(fnn, args2)

        # a+b / a-b
        m2 = re.match(r"(.+?)\s*([\+\-])\s*(.+)$", expr)
        if m2:
            lprep, lval = emit_term(m2.group(1))
            rprep, rval = emit_term(m2.group(3))
            op = m2.group(2)
            tmp = "__tmp_sum"
            code = lprep + rprep + [f"uint256 {tmp} = {lval} {op} {rval};"]
            return code, tmp

        # 不支持表达式
        return [f"uint256 __bad=0;"], "__bad"

    # =========================================================
    # 主循环
    # =========================================================
    for cond in filtered_posts:
        c = cond.strip()

        # ------------------------------------------------------
        # supply conserved
        # ------------------------------------------------------
        if c == "supply conserved":
            if _has_fn(abi, "totalSupply", []):
                L.append("        _assertEqU(target.totalSupply(), supply0);")
            else:
                L.append("        // no totalSupply() in ABI; skip")
            continue

        # ------------------------------------------------------
        # balance += / -=
        # ------------------------------------------------------
        m = re.match(r"balance\((alice|bob|carol|owner)\)\s*([+-]=)\s*(\d+)$", c)
        if m:
            who, op, v = m.group(1), m.group(2), m.group(3)
            sign = "+" if op == "+=" else "-"
            if has_token_balance:
                snap = {"alice":"balA0","bob":"balB0","carol":"balC0","owner":"balO0"}[who]
                L.append(f"        _assertEqU(target.balanceOf({who}), {snap} {sign} {v});")
            else:
                snap = {"alice":"ethA0","bob":"ethB0","carol":"ethC0","owner":"ethO0"}[who]
                L.append(f"        _assertEqU({who}.balance, {snap} {sign} {v});")
            continue

        # ------------------------------------------------------
        # balance == N
        # ------------------------------------------------------
        m = re.match(r"balance\((alice|bob|carol|owner)\)\s*==\s*(\d+)$", c)
        if m:
            who, v = m.group(1), m.group(2)
            if has_token_balance:
                L.append(f"        _assertEqU(target.balanceOf({who}), {v});")
            else:
                L.append(f"        _assertEqU({who}.balance, {v});")
            continue

        # ------------------------------------------------------
        # allowance
        # ------------------------------------------------------
        m = re.match(r"allowance\((alice|bob|carol|owner)\s*,\s*(alice|bob|carol|owner)\)\s*==\s*(\d+)$", c)
        if m:
            a, b, v = m.group(1), m.group(2), m.group(3)
            if _has_fn(abi, "allowance", ["address","address"]):
                L.append(f"        _assertEqU(target.allowance({a}, {b}), {v});")
            else:
                L.append("        // no allowance() in ABI; skip")
            continue

        # ------------------------------------------------------
        # owner()
        # ------------------------------------------------------
        m = re.match(r"owner\(\)\s*==\s*(alice|bob|carol|owner)$", c)
        if m:
            who = m.group(1)
            if _has_fn(abi, "owner", []):
                L.append(
                    f"        _assertEqU(uint160(address(target.owner())), uint160({who}));"
                )
            else:
                L.append("        // owner() not in ABI; skip")
            continue

        # ------------------------------------------------------
        # Escrow roles
        # ------------------------------------------------------
        m = re.match(r"(arbiter|beneficiary|depositor)\(\)\s*==\s*(alice|bob|carol|owner)$", c)
        if m:
            field, who = m.group(1), m.group(2)
            L.append(
                f"        _assertEqU(uint160(address(target.{field}())), uint160({who}));"
            )
            continue

        # ------------------------------------------------------
        # deposited()
        # ------------------------------------------------------
        m = re.match(r"deposited\(\)\s*==\s*(\d+)$", c)
        if m:
            L.append(f"        _assertEqU(target.deposited(), {m.group(1)});")
            continue

        # ------------------------------------------------------
        # call:
        # ------------------------------------------------------
        m = re.match(r"call:([A-Za-z_]\w*)\((.*?)\)\s*(==|!=|>=|<=|>|<)\s*(\d+)$", c)
        if m:
            f, a, op, v = m.group(1), (m.group(2) or "").strip(), m.group(3), m.group(4)
            if not re.fullmatch(r"[A-Za-z0-9_,\s()]*", a):
                a = ""

            codeop = {"==":0,"!=":1,">=":2,"<=":3,">":4,"<":5}[op]
            pre, token = lower_call(f, a)

            L.append("        {")
            for pl in pre:
                L.append(f"            {pl}")
            L.append(
                f"            _assertRelU({token}, {codeop}, {v}, \"call:{f}{op}{v}\");"
            )
            L.append("        }")
            continue

        # ------------------------------------------------------
        # approx:
        # ------------------------------------------------------
        m = re.match(r"approx:([A-Za-z_]\w*)\((.*?)\)\s*=\s*(\d+)\s*±\s*(\d+)$", c)
        if m:
            f, a, v, tol = m.groups()
            if not re.fullmatch(r"[A-Za-z0-9_,\s()]*", a):
                a = ""

            pre, token = lower_call(f, a)

            L.append("        {")
            for pl in pre:
                L.append(f"            {pl}")
            L.append(
                f"            _assertApproxEqU({token}, {v}, {tol}, \"approx:{f}\");"
            )
            L.append("        }")
            continue

        # ------------------------------------------------------
        # eq:
        # ------------------------------------------------------
        m = re.match(r"eq:([A-Za-z_]\w*)\((.*?)\)\s*=\s*(\d+)$", c)
        if m:
            f, a, v = m.groups()
            if not re.fullmatch(r"[A-Za-z0-9_,\s()]*", a):
                a = ""

            pre, token = lower_call(f, a)

            L.append("        {")
            for pl in pre:
                L.append(f"            {pl}")
            L.append(f"            _assertEqU({token}, {v});")
            L.append("        }")
            continue

        # ------------------------------------------------------
        # cmp:
        # ------------------------------------------------------
        m = re.match(r"cmp:(.+?)\s*(==|!=|>=|<=|>|<)\s*(.+)$", c)
        if m:
            lhs, op, rhs = m.group(1), m.group(2), m.group(3)
            lprep, lval = emit_term(lhs)
            rprep, rval = emit_term(rhs)
            codeop = {"==":0,"!=":1,">=":2,"<=":3,">":4,"<":5}[op]

            for ln in lprep + rprep:
                L.append(f"        {ln}")

            L.append(
                f"        _assertRelU({lval}, {codeop}, {rval}, \"cmp\");"
            )
            continue

        # ------------------------------------------------------
        # len:
        # ------------------------------------------------------
        m = re.match(r"len:([A-Za-z_]\w*)\((.*?)\)\s*==\s*(\d+)$", c)
        if m:
            f, a, n = m.group(1), (m.group(2) or "").strip(), m.group(3)
            if not re.fullmatch(r"[A-Za-z0-9_,\s()]*", a):
                a = ""
            L.append(
                f"        {{ uint256[] memory __arr = target.{f}({a}); _assertEqU(__arr.length, {n}); }}"
            )
            continue

        # ------------------------------------------------------
        # sload:
        # ------------------------------------------------------
        m = re.match(r"sload:(0x[0-9a-fA-F]+|\d+)\s*==\s*(0x[0-9a-fA-F]+|\d+)$", c)
        if m:
            slot_s, val_s = m.group(1), m.group(2)

            def to_bytes32(x: str):
                if x.startswith("0x"):
                    hx = x[2:].zfill(64)
                    return f"bytes32(hex\"{hx}\")"
                else:
                    return f"bytes32(uint256({x}))"

            L.append(
                f"        {{ bytes32 __v = vm.load(address(target), {to_bytes32(slot_s)}); "
                f"_assertTrue(__v == {to_bytes32(val_s)}, \"sload slot\"); }}"
            )
            continue

        # 未识别
        L.append(f"        // TODO assert: {c}")

    return L

def _render_sequence(
    contract_name: str,
    abi: List[dict],
    seq: Dict[str,Any],
    idx: int,
    legacy_04: bool,
    use_vm: bool,
    pre_08: bool = False,
    source_text: Optional[str] = None,
    use_dot_value: bool = False,  # 0.4/0.5 用 .value(...)；其余用 {value: ...}
) -> str:
    import re
    lines: List[str] = []

    steps = [
        st for st in seq.get("steps", [])
        if st.get("call") and str(st.get("call")).strip() != ""
    ]

    def _has_any_deposit(seq_obj: Dict[str, Any]) -> bool:
        def scan(items):
            for st in items or []:
                if _fn_name(st.get("call","")) == "deposit":
                    return True
            return False
        return scan(seq_obj.get("steps")) or scan(seq_obj.get("requires"))

    no_deposit_in_seq = not _has_any_deposit(seq)

    def _should_suppress_revert_for_release(step: Dict[str, Any]) -> bool:
        fn = _fn_name(step.get("call",""))
        exp = (step.get("expect") or "").lower()
        return (fn == "release") and exp.startswith("revert") and no_deposit_in_seq

    def _max_index_hint_from_steps(seq_obj: Dict[str, Any]) -> Optional[int]:
        """
        从本序列的 steps（以及 requires）里，收集所有顶层参数中的“十进制整数字面量”，
        返回需要的“最小安全数组长度”的索引上界提示：max_literal + 1。
        ——完全通用，不依赖函数名/语义；仅基于调用实参的字面量形态。
        """
        import re
        def scan_calls(calls: List[Dict[str, Any]]) -> int:
            mx = -1
            for st in calls or []:
                call = (st.get("call") or "").strip()
                m = re.match(r"\s*[A-Za-z_]\w*\s*\((.*)\)\s*$", call)
                if not m:
                    continue
                args_s = m.group(1).strip()
                if args_s == "":
                    continue
                # 只分割顶层逗号，不处理括号嵌套（我们约束 steps 里不写复杂表达式）
                args = [a.strip() for a in args_s.split(",")]
                for a in args:
                    # 只认十进制非负整数字面量（如 0、1、2、10）
                    if re.fullmatch(r"[0-9]+", a):
                        v = int(a)
                        if v > mx:
                            mx = v
            return mx

        mx1 = scan_calls(seq_obj.get("steps", []))
        mx2 = scan_calls(seq_obj.get("requires", []))
        mx = max(mx1, mx2)
        return (mx + 1) if mx >= 0 else None

    def _pick_deployer_and_ctor_args(abi, seq):
        deployer = "owner"
        ctor_override = None

        # ---- 通过 ABI 找到所有 payable 的函数名 ----
        PAYABLE_FNS = set()
        for it in abi:
            if it.get("type") == "function" and (it.get("stateMutability") or "").lower() == "payable":
                PAYABLE_FNS.add(it["name"])

        def first_ok_payable_caller(items):
            for st in (items or []):
                call = (st.get("call") or "").strip()
                m = re.match(r"([A-Za-z_]\w*)\s*\(", call)
                if not m:
                    continue
                fn = m.group(1)
                exp = (st.get("expect") or "").lower()
                val = str(st.get("value", "0")).strip()
                if fn in PAYABLE_FNS and exp and exp.startswith("revert"):
                    continue
                # 只要 value>0（包含“wei/ether”字样或纯数字>0）即可视为“带额调用”
                if val and val != "0" and val not in ("0 wei", "0 ether"):
                    return st.get("who", "alice")
            return None

        def first_ok_valued_caller(items):
            for st in (items or []):
                exp = (st.get("expect") or "").lower()
                if exp and exp.startswith("revert"):
                    continue
                val = str(st.get("value", "0")).strip()
                if val and val != "0" and val not in ("0 wei", "0 ether"):
                    return st.get("who", "alice")
            return None

        # ① 优先选：非 revert 的 payable 带额调用者
        depositor_who = (first_ok_payable_caller(seq.get("requires"))
                         or first_ok_payable_caller(seq.get("steps")))
        # ② 次优先：非 revert 的“任意带额调用者”
        if depositor_who is None:
            depositor_who = (first_ok_valued_caller(seq.get("requires"))
                             or first_ok_valued_caller(seq.get("steps")))
        if depositor_who:
            deployer = depositor_who

        # ---- arbiter 推断与构造器覆盖（与之前一致，不依赖具体函数名）----
        # 仍然通过“谁调用了某个无额、且 expect 非 revert 的步骤且在 post 有正向受益一方”来近似，
        # 如果无法唯一确定，回退 "bob"。
        release_callers = []
        for bucket in (seq.get("requires", []), seq.get("steps", [])):
            for st in (bucket or []):
                exp = (st.get("expect") or "").lower()
                val = str(st.get("value","0")).strip()
                if not exp.startswith("revert") and (val in ("", "0", "0 wei", "0 ether")):
                    release_callers.append(st.get("who","alice"))

        # beneficiary 从 post 捕获（balance(X) += N）
        bene = "carol"
        pos_bene_gain = False
        for p in seq.get("post", []):
            mp = re.match(r"balance\((alice|bob|carol|owner)\)\s*\+=\s*(\d+)", p.strip())
            if mp and int(mp.group(2)) > 0:
                bene = mp.group(1)
                pos_bene_gain = True
                break

        arb_role = release_callers[0] if (pos_bene_gain and len(release_callers) == 1) else "bob"

        # 若构造器为 (address,address) 则覆盖为 (arbiter, beneficiary)
        ctor_inputs = []
        for it in abi:
            if it.get("type") == "constructor":
                ctor_inputs = [inp["type"] for inp in it.get("inputs",[])]
                break
        if len(ctor_inputs) == 2 and all((t or "").startswith("address") for t in ctor_inputs):
            ctor_override = f"{arb_role}, {bene}"
        return deployer, ctor_override, arb_role

    deployer, ctor_args_override, arb_role = _pick_deployer_and_ctor_args(abi, seq)

    # 源码里的构造器真实类型（用于 address payable / 接口类型强转）
    ctor_types = _extract_ctor_param_types_from_source(source_text)

    # ========== NEW: 数组长度约束读取 ==========
    arrc = seq.get("array_constraints", {}) or {}

    def _arr_len_for_ctor_param(t_clean: str, name_hint: str, idx_t: int) -> int:
        """
        优先匹配：
          constructor.<参数名>:<类型>   e.g. constructor.proposals:bytes32[]
          constructor.arg<idx>:<类型>   e.g. constructor.arg0:uint256[]
        未命中 → 默认 1
        """
        keys = [
            f"constructor.{name_hint}:{t_clean}",
            f"constructor.arg{idx_t}:{t_clean}",
        ]
        for k in keys:
            if k in arrc:
                try:
                    return int(arrc[k])
                except:
                    pass
        return 1

    def _abi_inputs_for_fn(abi: List[dict], fn: str) -> Optional[List[dict]]:
        for it in abi:
            if it.get("type")=="function" and it["name"]==fn:
                return it.get("inputs", [])
        return None

    def _desired_array_len_for_step(seq_obj: Dict[str, Any], fn: str, pidx: int, t_clean: str) -> Optional[int]:
        """
        允许两种 key：
          "<fn>.arg<pidx>:<类型>"  e.g. transferMany.arg0:address[]
          "<fn>.arg<pidx>:[]"      e.g. transferMany.arg0:[]
        命中返回 int，否则 None
        """
        ac = seq_obj.get("array_constraints", {}) or {}
        key1 = f"{fn}.arg{pidx}:{t_clean}"
        key2 = f"{fn}.arg{pidx}:[]"
        if key1 in ac:
            try: return int(ac[key1])
            except: return None
        if key2 in ac:
            try: return int(ac[key2])
            except: return None
        return None

    # ---------- 构造器参数（本地构造） ----------
    pre_ctor_lines: List[str] = []
    ctor_item = next((it for it in abi if it.get("type")=="constructor"), None)
    # 基于步骤与 requires 中出现的“整数实参”推导一个通用的“索引上界提示”
    need_len_hint = _max_index_hint_from_steps(seq)  # None 或 >=1
    if ctor_item:
        ctor_args_list: List[str] = []
        for idx_t, inp in enumerate(ctor_item.get("inputs", [])):
            t = inp["type"]
            name_hint = (inp.get("name") or "").strip()
            t_clean = re.sub(r"\s*(memory|calldata|storage)\s*$","", t.strip())
            if t_clean.endswith("[]"):
                base = t_clean[:-2].strip()
                var  = f"_ctor_arr_{idx_t}"
                cnt  = _arr_len_for_ctor_param(t_clean, name_hint, idx_t)
                # 若步骤/前置中出现了更大的整数字面量，把构造器任意数组的长度抬到该下限
                if need_len_hint is not None and need_len_hint > cnt:
                    cnt = need_len_hint
                pre_ctor_lines.append(f"{base}[] memory {var} = new {base}[]({cnt});")
                for i in range(cnt):
                    pre_ctor_lines.append(f"{var}[{i}] = {_short_prim_literal(base, name_hint)};")
                ctor_args_list.append(var)
            else:
                ctor_args_list.append(_solidity_literal(t, name_hint, legacy_04))
        # ★ 关键：按源码真实类型矫正（address payable / 合约接口）
        ctor_args_list = _apply_ctor_type_casts(ctor_args_list, ctor_types, pre_08)
        ctor_args_default = ", ".join(ctor_args_list)
    else:
        ctor_args_default = ""

    # 若上层推断了 (arbiter, beneficiary) 的覆盖，优先使用覆盖并做类型矫正
    if ctor_args_override is not None:
        over = [p.strip() for p in ctor_args_override.split(",")]
        over = _apply_ctor_type_casts(over, ctor_types, pre_08)
        ctor_args_use = ", ".join(over)
    else:
        ctor_args_use = ctor_args_default

    # —— ABI 兜底串（含递归构造复杂参数，可能带 prep）——
    ctor_args_from_abi = _ctor_args_from_abi(abi, legacy_04, pre_08, source_text)

    # 先输出我们手工准备的构造器数组（如 bytes32[] proposals）
    for pl in pre_ctor_lines:
        lines.append(f"        {pl}")

    # 选择最终构造器参数：
    # 1) 优先使用已做“类型强转”的 ctor_args_use
    # 2) 若为空，再回退到 _ctor_args_from_abi 的结果，并注入其 prep
    use_ctor_from_abi = False
    if ctor_args_use.strip():
        ctor_args_effective = ctor_args_use
    elif ctor_args_from_abi.strip():
        use_ctor_from_abi = True
        ctor_args_effective = ctor_args_from_abi
        ctor_prep = getattr(_ctor_args_from_abi, "_last_prep", [])
        for pl in ctor_prep:
            lines.append(f"        {pl}")
    else:
        ctor_args_effective = ""

    # ---------- 部署 ----------
    if use_vm:
        lines.append(f"        vm.startPrank({deployer});")
        if ctor_args_effective:
            lines.append(f"        {contract_name} target = new {contract_name}({ctor_args_effective});")
        else:
            lines.append(f"        {contract_name} target = new {contract_name}();")
        lines.append("        vm.stopPrank();")
    else:
        if ctor_args_effective:
            lines.append(f"        {contract_name} target = new {contract_name}({ctor_args_effective});")
        else:
            lines.append(f"        {contract_name} target = new {contract_name}();")

    # ---------- 预置 ETH ----------
    if use_vm:
        lines.append("        vm.deal(owner, 100 ether);")
        lines.append("        vm.deal(alice, 100 ether);")
        lines.append("        vm.deal(bob,   100 ether);")
        lines.append("        vm.deal(carol, 100 ether);")

    # ---------- prestate：solidity / vm_stores ----------
    prestate = seq.get("prestate", {}) or {}
    for line_s in prestate.get("solidity", []):
        line_s = (line_s or "").strip().rstrip(";")
        if line_s:
            lines.append(f"        {line_s};")
    for st in prestate.get("vm_stores", []):
        # 支持已给定 slot/value；mapping 描述仅注释提示
        if "mapping" in st and "key" in st:
            lines.append(f'        // mapping init hint: {st.get("mapping")}[{st.get("key")}] = {st.get("value_uint") or st.get("value")};')
        slot = st.get("slot"); val = st.get("value")
        if slot and val:
            lines.append(f"        vm.store(address(target), {slot}, {val});")

    # ---------- bootstrap ----------
    for b in seq.get("bootstrap", []):
        if b.get("kind") == "mint_or_transfer_to_alice":
            amt = b.get("amount", "100")
            lines.extend(_render_bootstrap(abi, legacy_04, amt, use_vm))

    # ---------- 快照 ----------
    has_token = _has_fn(abi, "balanceOf", ["address"])
    if has_token:
        lines.append("        uint256 balA0 = target.balanceOf(alice);")
        lines.append("        uint256 balB0 = target.balanceOf(bob);")
        lines.append("        uint256 balC0 = target.balanceOf(carol);")
        lines.append("        uint256 balO0 = target.balanceOf(owner);")
    lines.append("        uint256 ethA0 = alice.balance;")
    lines.append("        uint256 ethB0 = bob.balance;")
    lines.append("        uint256 ethC0 = carol.balance;")
    lines.append("        uint256 ethO0 = owner.balance;")
    if _has_fn(abi, "totalSupply", []):
        lines.append("        uint256 supply0 = target.totalSupply();")
    if _has_fn(abi, "allowance", ["address","address"]):
        lines.append("        uint256 allowAB0 = target.allowance(alice,bob);")

    # ---------- 步骤渲染工具 ----------
    def _inject_value_into_call(call_expr: str, value: str) -> str:
        call_expr = call_expr.strip()
        if not value or value in ("0", "0 wei", "0 ether"):
            return call_expr
        i = call_expr.find("(")
        if i == -1:
            return call_expr
        if use_dot_value:
            return f"{call_expr[:i]}.value({value}){call_expr[i:]}"
        else:
            return f"{call_expr[:i]}{{value: {value}}}{call_expr[i:]}"

    def _fix_array_ctor_shorthand(call: str) -> str:
        call = re.sub(r"\bnew\s+address\s*(\(\s*\))?\b",   "new address",   call)
        call = re.sub(r"\bnew\s+bytes32\s*(\(\s*\))?\b",   "new bytes32",   call)
        call = re.sub(r"\bnew\s+uint(?:256)?\s*(\(\s*\))?\b", "new uint256", call)
        return call

    def _lower_inline_arrays_to_temps(call: str):
        # 仅处理两个数组的典型内联形态 [...],[...]
        m = re.match(r"([A-Za-z_]\w*)\s*\(\s*(\[[^\]]*\])\s*,\s*(\[[^\]]*\])\s*\)$", call.strip())
        if not m:
            return None
        fn, arr1, arr2 = m.group(1), m.group(2), m.group(3)

        def parse_items(s):
            inner = s[1:-1].strip()
            if inner == "":
                return []
            return [x.strip() for x in inner.split(",")]

        items1 = parse_items(arr1)
        items2 = parse_items(arr2)

        def is_addr(x: str) -> bool:
            return bool(re.fullmatch(r"(owner|alice|bob|carol|payable\([^)]*\))", x))

        t1 = "address" if all(is_addr(x) for x in items1) else "uint256"
        t2 = "address" if all(is_addr(x) for x in items2) else "uint256"

        prep = []
        prep.append(f"{t1}[] memory _a0 = new {t1}[]({len(items1)});")
        for i, it in enumerate(items1):
            prep.append(f"_a0[{i}] = {it};")
        prep.append(f"{t2}[] memory _a1 = new {t2}[]({len(items2)});")
        for i, it in enumerate(items2):
            prep.append(f"_a1[{i}] = {it};")

        new_call = f"{fn}(_a0, _a1)"
        return prep, new_call

    def _render_step_call(step: Dict[str, Any], legacy_false_mode: bool=False) -> str:
        
        def _safe_target_call(call2: str) -> str:
            call2 = (call2 or "").strip()
            if not call2:
                return "// skip empty call"
            if call2.startswith("."):
                return "// skip malformed call"
            if call2.startswith("("):
                return "// skip malformed call"
            return f"target.{call2};"
        
        call = step.get("call","").strip()
        call = step["call"].strip()
        value_raw = str(step.get("value", "0")).strip()
        pre_lines: List[str] = []

        # 先把 value=call:... 预处理为临时变量
        # pre_val_lines, value_token = _prelines_for_value_expr(value_raw)
        pre_val_lines, value_token = _prelines_for_value_expr(value_raw, _build_abi_index(abi))
        pre_lines.extend(pre_val_lines)

        # [NEW] 基于 array_constraints 的数组参数注入（非内联字面量场景，优先执行）
        m = re.match(r"([A-Za-z_]\w*)\s*\((.*)\)$", call)
        if m:
            fn = m.group(1)
            args_s = m.group(2).strip()
            inputs = _abi_inputs_for_fn(abi, fn) or []
            if any(inp["type"].strip().endswith("[]") for inp in inputs):
                arr_pre = []
                args = [a.strip() for a in args_s.split(",")] if args_s else []
                for pidx, inp in enumerate(inputs):
                    t_clean = re.sub(r"\s*(memory|calldata|storage)\s*$","", inp["type"].strip())
                    if t_clean.endswith("[]"):
                        want_len = _desired_array_len_for_step(seq, fn, pidx, t_clean) or 1
                        base = t_clean[:-2]
                        arrn = f"_a{pidx}"
                        arr_pre.append(f"{base}[] memory {arrn} = new {base}[]({want_len});")
                        for i in range(want_len):
                            arr_pre.append(f"{arrn}[{i}] = {_short_prim_literal(base, inp.get('name',''))};")
                        if pidx < len(args) and args[pidx] != "":
                            args[pidx] = arrn
                        else:
                            while len(args) < pidx:
                                args.append("")
                            if len(args) == pidx:
                                args.append(arrn)
                            else:
                                args[pidx] = arrn
                call2 = f"{fn}({', '.join(a if a != '' else _short_prim_literal((inputs[idx]['type'] if idx < len(inputs) else 'uint256'), '') for idx,a in enumerate(args))})"
                # 注入 value（此时使用 value_token）
                if value_token and value_token not in ("0", "0 wei", "0 ether"):
                    i = call2.find("(")
                    if i != -1:
                        call2 = (
                            f"{call2[:i]}.value({value_token}){call2[i:]}"
                            if use_dot_value else
                            f"{call2[:i]}{{value: {value_token}}}{call2[i:]}"
                        )
                # return "        " + "\n        ".join(pre_lines + arr_pre + [f"target.{call2};"])
                return "        " + "\n        ".join(pre_lines + arr_pre + [_safe_target_call(call2)])

        # 兼容内联数组字面量 → 临时数组
        call = _fix_array_ctor_shorthand(call)
        lowered = _lower_inline_arrays_to_temps(call)
        if lowered is not None:
            prep_lines, call2 = lowered
            if value_token and value_token not in ("0", "0 wei", "0 ether"):
                i = call2.find("(")
                if i != -1:
                    call2 = (
                        f"{call2[:i]}.value({value_token}){call2[i:]}"
                        if use_dot_value else
                        f"{call2[:i]}{{value: {value_token}}}{call2[i:]}"
                    )
            # return "        " + "\n        ".join(pre_lines + prep_lines + [f"target.{call2};"])
            return "        " + "\n        ".join(pre_lines + prep_lines + [_safe_target_call(call2)])

        # 常规 value 注入
        call2 = _inject_value_into_call(call, value_token)
        
        if not call2 or call2.strip() in ("", ".", "()"):
            return "        // skip empty call after value injection"
        
        if legacy_false_mode:
            return "        " + "\n        ".join(
                pre_lines + [f"bool __ok = target.{call2};", "_assertTrue(!__ok, \"expected false\");"]
            )
        # return "        " + "\n        ".join(pre_lines + [f"target.{call2};"])
        return "        " + "\n        ".join(pre_lines + [_safe_target_call(call2)])

    def _fn_and_args(expr: str) -> Tuple[str, List[str]]:
        m = re.match(r"([A-Za-z_][A-Za-z0-9_]*)\s*\((.*)\)$", expr.strip())
        if not m: return expr.strip(), []
        fn = m.group(1)
        a  = m.group(2).strip()
        args = [x.strip() for x in a.split(",")] if a else []
        return fn, args

    steps = seq.get("steps", [])
    supply_mutation = any(_fn_and_args(st.get("call",""))[0] in ("mint","mintToken","burn","burnFrom") for st in steps)

    # ---------- requires（严格先于 steps） ----------
    for r in seq.get("requires", []):
        who_r = r.get("who","alice")
        call_r = r.get("call","").strip()
        val_r  = str(r.get("value","0")).strip()

        # 先处理 value=call:... 形式
        # pre_val_lines, val_token = _prelines_for_value_expr(val_r)
        pre_val_lines, val_token = _prelines_for_value_expr(val_r,_build_abi_index(abi))
        for ln in pre_val_lines:
            lines.append(f"        {ln}")

        if use_vm:
            lines.append(f"        vm.prank({who_r});")

        # 简单注入（此处使用 .value(...) 或 {value: ...} 的现有分支）
        if val_token and val_token not in ("0","0 wei","0 ether"):
            i = call_r.find("(")
            if i != -1:
                call_r = (
                    f"{call_r[:i]}.value({val_token}){call_r[i:]}"
                    if use_dot_value else
                    f"{call_r[:i]}{{value: {val_token}}}{call_r[i:]}"
                )
        lines.append(f"        target.{call_r};")

    def _should_legacy_false_instead_of_revert(step: Dict[str, Any]) -> bool:
        exp = (step.get("expect") or "").lower()
        if not exp.startswith("revert"): return False
        m = re.match(r"([A-Za-z_]\w*)\s*\(", step.get("call","").strip())
        if not m: return False
        fn = m.group(1)
        # 仅在 pre-0.8 并且该函数 outputs 含 bool 时，走“返回 false”兼容
        return (pre_08 and _returns_bool(abi, fn))

    # ---------- 冻结账户/仲裁人负例处理 + 步级 expect ----------
    frozen = set()
    if use_vm:
        i, n = 0, len(steps)
        while i < n:
            who = steps[i].get("who", "alice")
            j = i
            while j < n and steps[j].get("who", "alice") == who:
                j += 1
            run_len = j - i

            if run_len >= 2:
                lines.append(f"        vm.startPrank({who});")
                for k in range(i, j):
                    call_raw = steps[k].get("call","").strip()
                    fn_k, args_k = _fn_and_args(call_raw)

                    # 跟踪 freeze 状态
                    if fn_k == "freezeAccount" and len(args_k) == 2 and args_k[1].lower() in ("true", "1"):
                        frozen.add(args_k[0])

                    # 预判需要 expectRevert 的典型负例
                    need_er = False
                    if fn_k == "transfer" and who in frozen:
                        need_er = True
                    elif fn_k == "transferFrom" and len(args_k) >= 1 and args_k[0] in frozen:
                        need_er = True
                    elif fn_k == "release" and who != arb_role:
                        need_er = True

                    # [NEW] 尊重步级 expect 优先级；legacy-false 优先级最高，直接禁止 expectRevert
                    exp = (steps[k].get("expect") or "").lower()
                    legacy_false = _should_legacy_false_instead_of_revert(steps[k])
                    suppress_rel = _should_suppress_revert_for_release(steps[k])

                    if legacy_false:
                        need_er = False  # ★ 关键：legacy-false 模式下一律不 expectRevert
                    elif exp.startswith("revert") and not suppress_rel:
                        need_er = True

                    if need_er:
                        # 目前统一用无参 expectRevert，带 msg 的可后续扩展
                        lines.append("        vm.expectRevert();")

                    lines.append(_render_step_call(steps[k], legacy_false_mode=legacy_false))
                lines.append("        vm.stopPrank();")
            else:
                call_raw = steps[i].get("call","").strip()
                fn_i, args_i = _fn_and_args(call_raw)
                if fn_i == "freezeAccount" and len(args_i) == 2 and args_i[1].lower() in ("true", "1"):
                    frozen.add(args_i[0])

                need_er = False
                if fn_i == "transfer" and who in frozen:
                    need_er = True
                elif fn_i == "transferFrom" and len(args_i) >= 1 and args_i[0] in frozen:
                    need_er = True
                elif fn_i == "release" and who != arb_role:
                    need_er = True

                exp = (steps[i].get("expect") or "").lower()
                legacy_false = _should_legacy_false_instead_of_revert(steps[i])  # 或 steps[i]
                suppress_rel = _should_suppress_revert_for_release(steps[i])
                if legacy_false:
                    need_er = False  # ★ 关键：legacy-false 模式下一律不 expectRevert
                elif exp.startswith("revert") and not suppress_rel:
                    need_er = True
                if need_er:
                    lines.append("        vm.expectRevert();")
                lines.append(f"        vm.prank({who});")
                lines.append(_render_step_call(steps[i], legacy_false_mode=legacy_false))
            i = j
    else:
        for st in steps:
            lines.append(_render_step_call(st))

    # ---------- 断言 ----------
    lines.extend(_render_post_asserts(
        abi, contract_name, seq, legacy_04, has_token,
        ctx={"arb_role": arb_role}
    ))

    # ---------- 元信息注释（assume / covered_branches） ----------
    meta = []
    for a in seq.get("assume", []):
        meta.append(f"// assume: {a}")
    for cb in seq.get("covered_branches", []):
        if isinstance(cb, dict):
            meta.append(f"// cover: {cb.get('fn')} :: {cb.get('branch')}")
        else:
            meta.append(f"// cover: {cb}")
    body = "\n".join(meta + lines) if meta else "\n".join(lines)

    # ======== 最终安全扫描 ========
    if "target.;" in body:
        body = body.replace("target.;", "// removed invalid call")

    if "target.();" in body:
        body = body.replace("target.();", "// removed invalid call")

    intent = seq.get("intent", seq.get("name","sequence"))
    safe_name = _sanitize_solidity_identifier(seq.get("name","seq"), "seq")
    tmpl = TEST_TMPL_04 if pre_08 else TEST_TMPL_08
    return tmpl.format(intent=intent, name=safe_name, idx=idx, body=body)

# =========================
# 7) 旧的“逐函数最小测试”做兜底（可选保留）
# =========================

def _render_minimal_per_function_tests(
    contract_name: str,
    abi: List[dict],
    legacy_04: bool,
    use_vm: bool,
    pre_08: bool,
    start_idx: int
) -> Tuple[List[str], int]:
    tests: List[str] = []
    idx = start_idx

    # 小工具：按 0.4–0.7 / 0.8+ 注入 value
    def _with_value(expr: str, value: str) -> str:
        expr = expr.strip()
        if not value or value in ("0", "0 wei", "0 ether"):
            return expr
        i = expr.find("(")
        if i == -1:
            return expr
        if pre_08:
            return f"{expr[:i]}.value({value}){expr[i:]}"
        else:
            return f"{expr[:i]}{{value: {value}}}{expr[i:]}"

    # Heuristics：哪些函数更可能需要 owner
    OWNER_LIKE = {
        "mint", "mintToken", "burn", "burnFrom",
        "freezeAccount", "unfreezeAccount",
        "changeName", "changeSymbol", "changeDecimals",
        "transferOwnership", "pause", "unpause",
        "setOwner"
    }

    # 简单名匹配
    def _prefer_owner(fn: str) -> bool:
        if fn in OWNER_LIKE: return True
        fn_l = fn.lower()
        if fn_l.startswith("set") or "owner" in fn_l:
            return True
        return False

    # 针对 ERC20 三大函数做特殊前置
    def _erc20_bootstrap(lines: List[str], need_for: str):
        if _has_fn(abi, "mintToken", ["address","uint256"]):
            if use_vm: lines.append("        vm.startPrank(owner);")
            lines.append("        target.mintToken(alice, 100);")
            if use_vm: lines.append("        vm.stopPrank();")
        elif _has_fn(abi, "mint", ["address","uint256"]):
            if use_vm: lines.append("        vm.startPrank(owner);")
            lines.append("        target.mint(alice, 100);")
            if use_vm: lines.append("        vm.stopPrank();")
        else:
            # 无铸币函数时，尝试 owner -> alice 转一点（可能在某些合约会被锁，这只是兜底）
            if _has_fn(abi, "transfer", ["address","uint256"]):
                if use_vm: lines.append("        vm.startPrank(owner);")
                lines.append("        target.transfer(alice, 100);")
                if use_vm: lines.append("        vm.stopPrank();")

        # transferFrom 需要 allowance
        if need_for == "transferFrom" and _has_fn(abi, "approve", ["address","uint256"]):
            if use_vm: lines.append("        vm.prank(alice);")
            lines.append("        target.approve(bob, 100);")

    for it in abi:
        if it.get("type") != "function":
            continue

        name = it["name"]
        inputs = it.get("inputs", [])
        mut = (it.get("stateMutability") or "").lower()

        # 组装 new 语句
        body_lines: List[str] = []
        for ln in _mk_new_stmt(contract_name, abi, legacy_04, use_vm, pre_08):
            body_lines.append(ln)

        # 预置 ETH 以免 payable 测试阻塞
        if use_vm:
            body_lines.append("        vm.deal(owner, 100 ether);")
            body_lines.append("        vm.deal(alice, 100 ether);")
            body_lines.append("        vm.deal(bob,   100 ether);")
            body_lines.append("        vm.deal(carol, 100 ether);")

        # ERC20 常见函数：加前置
        if name in ("transfer", "approve", "transferFrom"):
            _erc20_bootstrap(body_lines, name)

        # 构造参数
        # 对少数特例直接给“更合理”的参数，以减少 revert 概率
        if name == "transfer" and [x["type"] for x in inputs] == ["address", "uint256"]:
            args = "bob, 1"
            actor = "alice"
        elif name == "approve" and [x["type"] for x in inputs] == ["address", "uint256"]:
            args = "bob, 1"
            actor = "alice"
        elif name == "transferFrom" and [x["type"] for x in inputs] == ["address","address","uint256"]:
            args = "alice, bob, 1"
            actor = "bob"   # 由 spender 发起
        elif name in ("mintToken", "mint") and len(inputs) == 2:
            # mint(owner-only)
            args = "alice, 1"
            actor = "owner"
        elif name == "freezeAccount" and [x["type"] for x in inputs] == ["address","bool"]:
            args = "alice, true"
            actor = "owner"
        elif name == "transferOwnership" and len(inputs) == 1 and inputs[0]["type"] == "address":
            args = "alice"
            actor = "owner"
        elif name == "changeName" and len(inputs) == 1 and inputs[0]["type"] == "string":
            args = '"RemiCoin"'
            actor = "owner"
        elif name == "changeSymbol" and len(inputs) == 1 and inputs[0]["type"] == "string":
            args = '"RMC"'
            actor = "owner"
        elif name == "changeDecimals" and len(inputs) == 1 and inputs[0]["type"].startswith("uint"):
            args = "18"
            actor = "owner"
        else:
            # 通用参数：用字面量生成器
            arglits = []
            for inp in inputs:
                arglits.append(_solidity_literal(inp["type"], inp.get("name",""), legacy_04))
            args = ", ".join(arglits)
            actor = "owner" if _prefer_owner(name) else "alice"

        # 拼接调用
        call = f"target.{name}({args});"

        # 纯/视图：直接调用
        if mut in ("view", "pure"):
            body_lines.append(f"        {call}")
            intent = f"invoke {name} (read-only)"
        else:
            if use_vm:
                body_lines.append(f"        vm.prank({actor});")
            body_lines.append(f"        {call}")
            intent = f"invoke {name} (state change)"

        body = "\n".join(body_lines)

        # ======== 最终安全扫描 ========
        if "target.;" in body:
            body = body.replace("target.;", "// removed invalid call")

        if "target.();" in body:
            body = body.replace("target.();", "// removed invalid call")

        tmpl = TEST_TMPL_04 if legacy_04 else TEST_TMPL_08
        safe_name = _sanitize_solidity_identifier(f"perfn_{name}", "fn")
        tests.append(tmpl.format(intent=intent, name=safe_name, idx=idx, body=body))
        idx += 1

    return tests, idx

# =========================
# 8) 对外主函数：gen_tests_from_abi（接口不变）
#    standards: 可以是 ["ERC20","Ownable"] 或者 LLM 产物的 dict 列表
# =========================

def gen_tests_from_abi(
    contract_name: str,
    abi: List[dict],
    standards: List[Any],
    solc_version: str = "0.8.24",
    source_path: str = None
) -> str:
    flags = _version_flags(solc_version)
    is_04 = flags["is_04"]
    is_05 = flags["is_05"]
    is_06_07 = flags["is_06_07"]
    is_08p = flags["is_08p"]

    pragma = solc_version.lstrip("v")
    filename = Path(source_path).stem if source_path else contract_name

    src_text = None
    if source_path:
        try:
            src_text = Path(source_path).read_text(encoding="utf-8")
        except Exception:
            src_text = None

    # 选择 Header / Helpers / Prelude
    if is_08p:
        header_tpl = HEADER_08
        helpers = HELPERS_08
        prelude = ""  # 0.8+ 用 forge-std，自带 vm
    elif is_06_07:
        header_tpl = HEADER_06_07
        helpers = HELPERS_PRE08
        prelude = PRELUDE_05_06_07
    elif is_05:
        header_tpl = HEADER_05
        helpers = HELPERS_PRE08
        prelude = PRELUDE_05_06_07
    else:  # 0.4.x
        header_tpl = HEADER_04
        helpers = HELPERS_04
        prelude = PRELUDE_04

    legacy_04 = is_04
    pre_08 = not is_08p
    use_vm = True  # ★ 所有版本都启用 vm/cheatcodes

    # 新增：只有 0.4/0.5 用 .value(...)，其它版本都用 {value: ...}
    use_dot_value = is_04 or is_05

    tests: List[str] = []
    idx = 0

    seqs = _collect_sequences(abi, standards)

    # --- 在 gen_tests_from_abi 末尾、拼接 TESTS 前 ---
    def _greedy_min_cover(tests_with_cov: List[tuple]):
        # tests_with_cov: [(test_src, set(function_names)), ...]
        universe=set()
        for _,cov in tests_with_cov: universe |= cov
        chosen=[]
        covered=set()
        remaining = list(tests_with_cov)
        while covered != universe and remaining:
            best=max(remaining, key=lambda x: len(x[1]-covered))
            chosen.append(best)
            covered |= best[1]
            remaining.remove(best)
        return chosen
    # 你在生成每条 test 时，顺便返回该 test 的 "覆盖的函数名集合"（解析 steps 的 fn）

    for s in seqs:
        tests.append(_render_sequence(
            contract_name, abi, s, idx, legacy_04, use_vm, pre_08,  # 现有参数
            # 新增命名参数，便于不影响你已有调用
            source_text=src_text,
            use_dot_value=use_dot_value,   # ★ 传下去
        ))
        idx += 1


    # # ★ 追加“每函数兜底测试”——保证再多出 `函数数目` 个
    # perfn_tests, idx = _render_minimal_per_function_tests(
    #     contract_name, abi, legacy_04, use_vm, pre_08, idx
    # )
    # tests.extend(perfn_tests)

    return header_tpl.format(
        PRAGMA=pragma,
        FILENAME=filename,
        CONTRACT=contract_name,
        PRELUDE=prelude,
        HELPERS=helpers,
        TESTS="".join(tests),
    )


# =========================
# 9) 写文件：接口保持不变
# =========================

def write_foundry_test(out_dir: Path, contract: str, content: str) -> str:
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{contract}_Functional.t.sol"
    out_path.write_text(content, encoding="utf-8")
    return str(out_path)

# -------------------------------------------------------
# 便捷入口：一条龙（LLM 规划 -> 生成测试 -> 写文件）
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

    # 1.5) 每函数最小兜底计划（由 LLM 产出，必要时我们补齐少数缺失）
    perfn_plan = llm_plan_per_function_sequences(
        contract_name=contract_name,
        abi=abi,
        api_key=api_key,
        source_text=source_text,
        api_url=api_url,
        model=model
    )

    # 2) 组合 standards 列表：内置字符串 + LLM 主计划 + LLM 每函数计划
    stds: List[Any] = []
    if include_builtin:
        stds.extend(standards or [])
    if llm_plan.get("sequences"):
        stds.append(llm_plan)
    if perfn_plan.get("sequences"):
        stds.append(perfn_plan)

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