import copy
import re


# def normalize_stds(stds, abi):

#     stds = copy.deepcopy(stds)

#     # -----------------------------
#     # 1️⃣ ABI 索引
#     # -----------------------------
#     func_map = {}
#     has_fallback = False
#     fallback_payable = False

#     for item in abi:
#         if item.get("type") == "function":
#             func_map[item["name"]] = {
#                 "stateMutability": item.get("stateMutability", ""),
#                 "payable": item.get("payable", False),
#             }

#         if item.get("type") in ("fallback", "receive"):
#             has_fallback = True
#             if item.get("payable", False):
#                 fallback_payable = True

#     # -----------------------------
#     # 2️⃣ 合法角色
#     # -----------------------------
#     ALLOWED_ROLES = {"owner", "alice", "bob", "carol"}

#     def norm_role(role):
#         if role in ALLOWED_ROLES:
#             return role
#         return "carol"

#     # -----------------------------
#     # 3️⃣ 主循环
#     # -----------------------------
#     for plan in stds:

#         for seq in plan.get("sequences", []):

#             # 合并 requires
#             seq["steps"] = (seq.get("requires") or []) + (seq.get("steps") or [])
#             seq["requires"] = []

#             new_steps = []

#             for step in seq.get("steps", []):

#                 who = norm_role(step.get("who", "alice"))
#                 call = (step.get("call") or "").strip()
#                 value = (step.get("value") or "0").strip()

#                 fn_name = call.split("(")[0] if call else None
#                 fn_info = func_map.get(fn_name)

#                 # -----------------
#                 # 情况1：函数存在
#                 # -----------------
#                 if fn_info:

#                     state = fn_info.get("stateMutability", "")
#                     payable = fn_info.get("payable", False)

#                     # view/pure 不允许 value
#                     if state in ("view", "pure"):
#                         value = "0"

#                     # 非 payable + 有 value → fallback
#                     if value != "0" and not payable:
#                         if has_fallback and fallback_payable:
#                             call = ""   # 关键修正
#                         else:
#                             continue

#                     step["who"] = who
#                     step["call"] = call
#                     step["value"] = value
#                     new_steps.append(step)
#                     continue

#                 # -----------------
#                 # 情况2：函数不存在
#                 # -----------------
#                 if value != "0" and has_fallback and fallback_payable:
#                     step["who"] = who
#                     step["call"] = ""   # 关键修正
#                     step["value"] = value
#                     new_steps.append(step)
#                     continue

#                 # -----------------
#                 # 情况3：call为空 + 有value
#                 # -----------------
#                 if not call and value != "0" and has_fallback and fallback_payable:
#                     step["who"] = who
#                     step["call"] = ""
#                     step["value"] = value
#                     new_steps.append(step)
#                     continue

#                 # 其它丢弃
#                 continue

#             seq["steps"] = new_steps

#             # -------------------------
#             # 4️⃣ post 中仅替换非法账户标识
#             # -------------------------
#             new_post = []
#             for p in seq.get("post", []):

#                 # 仅替换 attacker 之类完整单词
#                 for token in re.findall(r"\b[A-Za-z_]\w*\b", p):
#                     if token not in ALLOWED_ROLES and token in {"attacker"}:
#                         p = re.sub(rf"\b{token}\b", "carol", p)

#                 new_post.append(p)

#             seq["post"] = new_post

#     return stds

def normalize_stds(stds, abi):

    stds = copy.deepcopy(stds)

    # 兜底：允许传入单个对象而不是 list
    if stds is None:
        return []
    if not isinstance(stds, list):
        stds = [stds]

    # -----------------------------
    # 1️⃣ ABI 索引
    # -----------------------------
    func_map = {}
    has_fallback = False
    fallback_payable = False

    for item in abi:
        if item.get("type") == "function":
            func_map[item["name"]] = {
                "stateMutability": item.get("stateMutability", ""),
                "payable": item.get("payable", False),
            }

        if item.get("type") in ("fallback", "receive"):
            has_fallback = True
            if item.get("payable", False):
                fallback_payable = True

    # -----------------------------
    # 2️⃣ 合法角色
    # -----------------------------
    ALLOWED_ROLES = {"owner", "alice", "bob", "carol"}

    def norm_role(role):
        if role in ALLOWED_ROLES:
            return role
        return "carol"

    normalized = []

    # -----------------------------
    # 3️⃣ 主循环
    # -----------------------------
    for plan in stds:

        # [FIX] 字符串标准名直接保留
        if isinstance(plan, str):
            normalized.append(plan)
            continue

        # [FIX] 非 dict 直接丢弃，避免炸流程
        if not isinstance(plan, dict):
            print(f"[normalize_stds] skip invalid std item: {type(plan).__name__} -> {plan!r}")
            continue

        # [FIX] 没有 sequences 的 dict 也跳过
        if "sequences" not in plan:
            print(f"[normalize_stds] skip dict without sequences: {plan!r}")
            continue

        for seq in plan.get("sequences", []):

            # [FIX] seq 不是 dict 时跳过
            if not isinstance(seq, dict):
                print(f"[normalize_stds] skip invalid sequence: {seq!r}")
                continue

            # 合并 requires
            seq["steps"] = (seq.get("requires") or []) + (seq.get("steps") or [])
            seq["requires"] = []

            new_steps = []

            for step in seq.get("steps", []):

                # [FIX] step 不是 dict 时跳过
                if not isinstance(step, dict):
                    print(f"[normalize_stds] skip invalid step: {step!r}")
                    continue

                who = norm_role(step.get("who", "alice"))
                call = (step.get("call") or "").strip()
                value = str(step.get("value") or "0").strip()

                fn_name = call.split("(")[0] if call else None
                fn_info = func_map.get(fn_name)

                # -----------------
                # 情况1：函数存在
                # -----------------
                if fn_info:

                    state = fn_info.get("stateMutability", "")
                    payable = fn_info.get("payable", False)

                    # view/pure 不允许 value
                    if state in ("view", "pure"):
                        value = "0"

                    # 非 payable + 有 value → fallback
                    if value != "0" and not payable:
                        if has_fallback and fallback_payable:
                            call = ""
                        else:
                            continue

                    step["who"] = who
                    step["call"] = call
                    step["value"] = value
                    new_steps.append(step)
                    continue

                # -----------------
                # 情况2：函数不存在
                # -----------------
                if value != "0" and has_fallback and fallback_payable:
                    step["who"] = who
                    step["call"] = ""
                    step["value"] = value
                    new_steps.append(step)
                    continue

                # -----------------
                # 情况3：call为空 + 有value
                # -----------------
                if not call and value != "0" and has_fallback and fallback_payable:
                    step["who"] = who
                    step["call"] = ""
                    step["value"] = value
                    new_steps.append(step)
                    continue

                # 其它丢弃
                continue

            seq["steps"] = new_steps

            # -------------------------
            # 4️⃣ post 中仅替换非法账户标识
            # -------------------------
            new_post = []
            for p in seq.get("post", []):

                if not isinstance(p, str):
                    continue

                # 仅替换 attacker 之类完整单词
                for token in re.findall(r"\b[A-Za-z_]\w*\b", p):
                    if token not in ALLOWED_ROLES and token in {"attacker"}:
                        p = re.sub(rf"\b{token}\b", "carol", p)

                new_post.append(p)

            seq["post"] = new_post

        normalized.append(plan)

    return normalized


import re
from copy import deepcopy
from typing import Any, Dict, List


# -----------------------------------------------------------
# 主入口
# -----------------------------------------------------------

# def resolve_post_conditions_against_abi(
#     stds: List[Any],
#     abi: List[Dict[str, Any]]
# ) -> List[Any]:

#     stds = deepcopy(stds)

#     abi_index = _build_abi_index(abi)

#     for plan in stds:
#         for seq in plan.get("sequences", []):

#             seq["post"] = _resolve_assert_list(
#                 seq.get("post", []),
#                 abi_index
#             )

#             seq["requires"] = _resolve_requires(
#                 seq.get("requires", []),
#                 abi_index
#             )

#     return stds

def resolve_post_conditions_against_abi(
    stds: List[Any],
    abi: List[Dict[str, Any]]
) -> List[Any]:

    stds = deepcopy(stds)

    if stds is None:
        return []
    if not isinstance(stds, list):
        stds = [stds]

    abi_index = _build_abi_index(abi)

    normalized = []

    for plan in stds:

        # 1) 字符串标准名直接保留，例如 "ERC20"
        if isinstance(plan, str):
            normalized.append(plan)
            continue

        # 2) 非 dict 跳过
        if not isinstance(plan, dict):
            print(f"[resolve_post_conditions_against_abi] skip invalid std item: {type(plan).__name__} -> {plan!r}")
            continue

        # 3) 没有 sequences 的 dict 跳过
        if "sequences" not in plan:
            print(f"[resolve_post_conditions_against_abi] skip dict without sequences: {plan!r}")
            normalized.append(plan)
            continue

        seqs = []
        for seq in plan.get("sequences", []):

            # 4) 非 dict sequence 跳过
            if not isinstance(seq, dict):
                print(f"[resolve_post_conditions_against_abi] skip invalid sequence: {seq!r}")
                continue

            seq = deepcopy(seq)

            seq["post"] = _resolve_assert_list(
                seq.get("post", []),
                abi_index
            )

            seq["requires"] = _resolve_requires(
                seq.get("requires", []),
                abi_index
            )

            seqs.append(seq)

        plan["sequences"] = seqs
        normalized.append(plan)

    return normalized


# -----------------------------------------------------------
# ABI 解析
# -----------------------------------------------------------

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


# -----------------------------------------------------------
# 处理 post 断言
# -----------------------------------------------------------

def _resolve_assert_list(asserts, abi_index):

    resolved = []

    for raw in asserts:

        if not isinstance(raw, str):
            continue

        raw = raw.strip()

        # 过滤自然语言
        if not _looks_like_assertion(raw):
            continue

        parsed = _parse_assertion(raw)

        if not parsed:
            continue

        fn = parsed.get("fn")

        # balance 特判
        if parsed["kind"] == "balance":
            new_expr = _resolve_balance(parsed, abi_index)
            if new_expr:
                resolved.append(new_expr)
            continue

        # call 特判
        if parsed["kind"] == "call":
            new_expr = _resolve_call(parsed, abi_index)
            if new_expr:
                resolved.append(new_expr)
            continue

        # 普通比较
        resolved.append(raw)

    return resolved


# -----------------------------------------------------------
# 处理 requires
# -----------------------------------------------------------

def _resolve_requires(reqs, abi_index):

    resolved = []

    for r in reqs:
        if not isinstance(r, dict):
            continue

        fn = r.get("call")
        if not fn:
            continue

        name = fn.split("(")[0]

        if name not in abi_index["functions"]:
            continue

        resolved.append(r)

    return resolved


# -----------------------------------------------------------
# DSL 解析
# -----------------------------------------------------------

def _looks_like_assertion(s: str) -> bool:

    if "==" in s:
        return True
    if ">=" in s:
        return True
    if "<=" in s:
        return True
    if s.startswith("call:"):
        return True
    if s.startswith("balance("):
        return True

    return False


def _parse_assertion(s: str):

    # balance(x) == y
    m = re.match(r"balance\((.*?)\)\s*(==|>=|<=)\s*(.+)", s)
    if m:
        return {
            "kind": "balance",
            "actor": m.group(1),
            "op": m.group(2),
            "rhs": m.group(3)
        }

    # call:fn(args) == y
    m = re.match(r"call:(\w+)\((.*?)\)\s*(==|>=|<=)\s*(.+)", s)
    if m:
        return {
            "kind": "call",
            "fn": m.group(1),
            "args": m.group(2),
            "op": m.group(3),
            "rhs": m.group(4)
        }

    return None


# -----------------------------------------------------------
# balance 处理
# -----------------------------------------------------------

def _resolve_balance(parsed, abi_index):

    actor = parsed["actor"]
    op = parsed["op"]
    rhs = parsed["rhs"]

    # 如果 ABI 有 balance(address) 函数
    if abi_index["has_balance_function"]:
        return f"call:balance({actor}) {op} {rhs}"

    # 否则用 EVM balance
    if actor in ("this", "contract"):
        return f"address(target).balance {op} {rhs}"

    return f"{actor}.balance {op} {rhs}"


# -----------------------------------------------------------
# call 处理
# -----------------------------------------------------------

def _resolve_call(parsed, abi_index):

    name = parsed["fn"]
    args = parsed["args"]
    op = parsed["op"]
    rhs = parsed["rhs"]

    if name not in abi_index["functions"]:
        return None

    fn_meta = abi_index["functions"][name]
    outputs = fn_meta.get("outputs", [])

    if len(outputs) == 0:
        return None

    ret_type = outputs[0]["type"]

    expr = f"call:{name}({args}) {op} {rhs}"

    # enum 处理（ABI 里 enum 表现为 uint8/uintX）
    if ret_type.startswith("uint") and "Phase" in name.lower():
        return {
            "__expr__": expr,
            "__cast__": "uint256"
        }

    # bool 类型
    if ret_type == "bool":
        return expr

    # address 类型
    if ret_type == "address":
        if rhs.isdigit():
            return None

    return expr