import re

try:
    from eth_utils import keccak as _eth_keccak
except Exception:
    _eth_keccak = None

def parse_solc_version(solc_version: str):
    """
    输入如: 0.8.0 v0.8.0
    输出: (0, 8, 0)
    """
    if solc_version is None:
        return (0, 8, 0)
    s = str(solc_version).strip().lower()
    if s.startswith("v"):
        s = s[1:]
    parts = s.split(".")
    nums = []
    for p in parts[:3]:
        try:
            nums.append(int(p))
        except:
            nums.append(0)
    while len(nums) < 3:
        nums.append(0)
    return tuple(nums)

def choose_version_profile(solc_version: str):
    """
    三档:
      - modern: >= 0.7.0
      - mid_legacy: 0.5.0 ~ 0.6.1
      - legacy: 0.4.x
    """
    v = parse_solc_version(solc_version)
    if v >= (0, 7, 0):
        return "modern"
    if v >= (0, 5, 0):
        return "mid_legacy"
    return "legacy"

def walk_ast(node):
    if isinstance(node, dict):
        yield node
        for v in node.values():
            yield from walk_ast(v)
    elif isinstance(node, list):
        for x in node:
            yield from walk_ast(x)

def extract_base_contract_name(base_spec: dict):
    """
    兼容 Solidity 0.4 ~ 0.8 不同 AST 结构，提取 base contract 名称。

    base_spec 一般来自 ContractDefinition["baseContracts"] 的元素。
    常见结构：
    - {"baseName": {"nodeType": "IdentifierPath", "name": "Ownable"}}
    - {"baseName": {"nodeType": "UserDefinedTypeName", "namePath": "Ownable"}}
    - {"baseName": {"namePath": "Ownable"}}
    - {"baseName": {"name": "Ownable"}}
    """
    if not isinstance(base_spec, dict):
        return None

    base_name_node = base_spec.get("baseName")
    if not isinstance(base_name_node, dict):
        return None

    # -------- 最常见字段 --------
    for key in ["namePath", "name"]:
        v = base_name_node.get(key)
        if isinstance(v, str) and v.strip():
            return v.strip().split(".")[-1]

    # -------- 某些版本可能带 pathNode / referencedDeclaration 辅助字段 --------
    path_node = base_name_node.get("pathNode")
    if isinstance(path_node, dict):
        for key in ["name", "namePath"]:
            v = path_node.get(key)
            if isinstance(v, str) and v.strip():
                return v.strip().split(".")[-1]

    # -------- 最后兜底：从 typeDescriptions.typeString 提取 --------
    t = base_name_node.get("typeDescriptions", {}).get("typeString", "")
    # 可能形如 "contract Ownable"
    if isinstance(t, str) and t.strip():
        parts = t.strip().split()
        if len(parts) >= 2:
            return parts[-1].split(".")[-1]

    return None

def build_contract_registry(ast):
    """
    收集 AST 中所有 ContractDefinition
    """
    registry = {}

    for node in walk_ast(ast):
        if node.get("nodeType") == "ContractDefinition":
            name = node.get("name")
            if name:
                registry[name] = node

    return registry

def resolve_inheritance_chain(contract_name, registry):
    """
    解析继承链，返回 base -> derived 顺序。
    例如:
      TestSystem -> SimpleERC20 -> Ownable -> Context
    最终返回:
      ["Context", "Ownable", "SimpleERC20", "TestSystem"]
    """
    result = []
    visited = set()

    def dfs(name):
        if not name or name in visited:
            return
        visited.add(name)

        node = registry.get(name)
        if not node:
            return

        for base in node.get("baseContracts", []) or []:
            base_name = extract_base_contract_name(base)
            if base_name:
                dfs(base_name)

        result.append(name)

    dfs(contract_name)
    return result

def build_flattened_contract_view(ast, contract_name, storage_layout=None):
    """
    Step3.1-A:
    构建继承展开后的 unified view
    """
    registry = build_contract_registry(ast)

    print("[AST] contracts:", list(registry.keys()))

    chain = resolve_inheritance_chain(contract_name, registry)

    storage = {}
    functions = {}
    enums = {}

    for cname in chain:
        node = registry.get(cname)
        if not node:
            continue

        s = extract_storage_variables(node)
        f = extract_functions(node)
        e = extract_enums(node)

        # base 先放，derived 后覆盖
        storage.update(s)
        enums.update(e)
        functions.update(f)

    print("===== FLATTEN DEBUG =====")
    print("inheritance chain:", chain)
    print("storage:", storage.keys())
    print("functions:", functions.keys())
    print("enums:", enums.keys())
    print("=========================")

    # 用 storageLayout 补充 slot / offset / type id
    layout_map = build_storage_layout_label_map(storage_layout)
    for name, meta in storage.items():
        item = layout_map.get(name)
        if item:
            meta["slot"] = item.get("slot")
            meta["offset"] = item.get("offset")
            meta["storage_type"] = item.get("type")

    return {
        "storage": storage,
        "functions": functions,
        "enums": enums,
        "inheritance_chain": chain
    }

def extract_storage_layout_entries(storage_layout: dict):
    """
    统一抽取 storageLayout.storage
    兼容 None
    """
    if not isinstance(storage_layout, dict):
        return []

    items = storage_layout.get("storage", [])
    if isinstance(items, list):
        return items
    return []

def build_storage_layout_label_map(storage_layout: dict):
    """
    将 storageLayout 中的 storage 项按 label 建表
    例如:
      {"_balances": {...}, "_owner": {...}}
    """
    out = {}
    for item in extract_storage_layout_entries(storage_layout):
        label = item.get("label")
        if label:
            out[label] = item
    return out

    
def build_storage_layout_slot_map(storage_layout: dict):
    """
    slot -> [entry...]
    仅保留 storageLayout.storage 里的顶层变量
    """
    out = {}
    for item in extract_storage_layout_entries(storage_layout):
        slot = str(item.get("slot"))
        if not slot:
            continue
        out.setdefault(slot, []).append(item)
    return out

def _try_parse_int_literal(x):
    """
    支持:
    - 1
    - 0x01
    返回 int / None
    """
    if x is None:
        return None
    s = str(x).strip()
    if not s:
        return None
    try:
        if s.lower().startswith("0x"):
            return int(s, 16)
        return int(s)
    except:
        return None


def build_mapping_slot_to_name_map(storage: dict):
    """
    只为 mapping 建立 base slot -> mapping var name
    例如:
      _balances.slot = 1
      whitelist.slot = 5
    返回:
      {
        "1": "_balances",
        "0x1": "_balances",
        "5": "whitelist",
        "0x5": "whitelist",
      }
    """
    out = {}
    for name, meta in (storage or {}).items():
        if not meta.get("is_mapping"):
            continue

        slot = meta.get("slot")
        if slot is None:
            continue

        slot_int = _try_parse_int_literal(slot)
        if slot_int is None:
            continue

        out[str(slot_int)] = name
        out[hex(slot_int)] = name

    return out


def _collect_ir_alias_constants(ir_block: str):
    """
    在一个 IR block 中收集非常轻量的别名常量传播:
      let _slot := 0x05
      let _x := 1

    返回:
      {
        "_slot": "0x05",
        "_x": "1"
      }

    只保留字面量常量，避免误传播复杂表达式。
    """
    env = {}
    if not ir_block:
        return env

    for raw_line in ir_block.splitlines():
        line = raw_line.strip()
        if not line:
            continue

        m = re.match(r'let\s+([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*(0x[0-9a-fA-F]+|\d+)\b', line)
        if not m:
            continue

        var = m.group(1)
        val = m.group(2)
        env[var] = val

    return env


def _resolve_alias_to_literal(token: str, alias_env: dict):
    """
    若 token 是字面量，直接返回；
    若 token 是别名且 alias_env 中能解析到字面量，也返回；
    否则返回 None
    """
    if token is None:
        return None

    s = str(token).strip()
    if not s:
        return None

    if re.fullmatch(r'0x[0-9a-fA-F]+|\d+', s):
        return s

    if alias_env and s in alias_env:
        v = alias_env[s]
        if re.fullmatch(r'0x[0-9a-fA-F]+|\d+', str(v).strip()):
            return str(v).strip()

    return None


def _extract_keccak_preimage_slot_candidates(stmt: str, alias_env: dict):
    """
    从单条 IR 语句中尝试恢复 keccak256 preimage 里的 mapping base slot 候选。

    只做“严格识别”，宁可漏报，不可误报。
    目前支持这几类极简模式：

    1) keccak256(0x40, 0x40) 这种无法直接从本行恢复 -> 不认
    2) 行内出现 mstore(..., SLOT) 且随后 sstore(keccak256(...), ...)
       由于当前实现按单行解析，不可靠 -> 不认
    3) keccak256(add(...), 0x40) / keccak256(...)

    当前策略：
    - 优先抓当前 stmt 中出现的明确 slot 常量/别名
    - 只要出现且能唯一映射到 mapping slot，就接受
    - 否则返回 []

    说明：
    这是“最小严格版”，目标是先挡掉误报。
    """
    stmt_n = " ".join(str(stmt).split())

    if "keccak256" not in stmt_n:
        return []

    cands = []

    # 1) 直接抓 keccak256 参数中的字面量
    for m in re.finditer(r'keccak256\s*\((.*?)\)', stmt_n):
        inside = m.group(1)

        # 抓所有 token
        toks = re.findall(r'0x[0-9a-fA-F]+|\b\d+\b|\b[A-Za-z_][A-Za-z0-9_]*\b', inside)
        for tok in toks:
            lit = _resolve_alias_to_literal(tok, alias_env)
            if lit is not None:
                cands.append(lit)

    # 2) 某些 IR 会在同一行里出现 mstore(..., slot) ... sstore(keccak256(...), ...)
    # 这里再额外抓一遍 mstore 的第二个参数
    if "mstore" in stmt_n:
        for m in re.finditer(r'mstore\s*\(\s*[^,]+,\s*([A-Za-z_][A-Za-z0-9_]*|0x[0-9a-fA-F]+|\d+)\s*\)', stmt_n):
            tok = m.group(1)
            lit = _resolve_alias_to_literal(tok, alias_env)
            if lit is not None:
                cands.append(lit)

    # 去重保序
    out = []
    seen = set()
    for x in cands:
        k = str(_try_parse_int_literal(x))
        if k == "None":
            continue
        if k not in seen:
            seen.add(k)
            out.append(x)

    return out


def try_resolve_mapping_target_from_ir_sstore_stmt(stmt: str, storage: dict, alias_env=None):
    """
    严格版 mapping keccak 归属:
    - 仅处理 sstore(keccak256(...), value)
    - 只有当能从 stmt 中恢复出“唯一 mapping base slot”时才返回 target
    - 否则返回 (None, None)

    返回:
      (target_name, index_expr)
    """
    alias_env = alias_env or {}

    stmt_n = " ".join(str(stmt).split())
    if "sstore" not in stmt_n or "keccak256" not in stmt_n:
        return (None, None)

    mapping_slot_to_name = build_mapping_slot_to_name_map(storage)

    slot_cands = _extract_keccak_preimage_slot_candidates(stmt_n, alias_env)

    resolved_targets = []
    for slot_tok in slot_cands:
        slot_int = _try_parse_int_literal(slot_tok)
        if slot_int is None:
            continue

        target = mapping_slot_to_name.get(str(slot_int)) or mapping_slot_to_name.get(hex(slot_int))
        if target:
            resolved_targets.append(target)

    resolved_targets = list(dict.fromkeys(resolved_targets))

    # 必须唯一
    if len(resolved_targets) != 1:
        return (None, None)

    target = resolved_targets[0]

    # index_expr 这里先只保留“未知但存在”的占位，不把脏 token 暴露给上层
    # 因为当前目标是 precision 优先
    return (target, "?")

def get_unique_storage_var_by_slot(storage_layout: dict, slot: str):
    """
    若某 slot 只对应一个 storage 变量，则返回该 label；
    若是 packed slot（多个变量共槽），返回 None。
    """
    slot_map = build_storage_layout_slot_map(storage_layout)
    items = slot_map.get(str(slot), [])

    if len(items) != 1:
        return None

    label = items[0].get("label")
    return label or None

def get_contract_ir_text(compiler_artifacts, contract_name, optimized=True):
    """
    从 compiler_artifacts 中提取某个 contract 的 IR 文本
    优先:
    1) compiler_artifacts["contracts"][contract_name]
    2) 顶层 solc_ir / solc_ir_optimized
    """
    if not isinstance(compiler_artifacts, dict):
        return ""

    contracts = compiler_artifacts.get("contracts")
    if isinstance(contracts, dict) and contract_name in contracts:
        meta = contracts[contract_name]
        if optimized:
            return meta.get("irOptimized", "") or ""
        return meta.get("ir", "") or ""

    if optimized:
        return compiler_artifacts.get("solc_ir_optimized", "") or ""
    return compiler_artifacts.get("solc_ir", "") or ""

def slice_ir_windows_by_function_names(ir_text: str, function_names, window=3500):
    out = {}
    if not ir_text:
        return out

    for fn_name in function_names:
        patterns = [
            f"function {fn_name}(",
            f"function {fn_name} "
        ]

        pos = -1
        for p in patterns:
            pos = ir_text.find(p)
            if pos != -1:
                break

        if pos == -1:
            # fallback: dispatch comment
            p = f"function {fn_name}()"
            pos = ir_text.find(p)

        if pos == -1:
            out[fn_name] = {"text": "", "start": -1, "end": -1}
            continue

        start = max(0, pos - 300)
        end = min(len(ir_text), pos + window)
        out[fn_name] = {
            "text": ir_text[start:end],
            "start": start,
            "end": end,
        }

    return out

def extract_ir_dispatch_helper_calls(ir_block: str):
    """
    只从 dispatch/window 中提取 lowered helper:
    - fun_xxx
    - modifier_xxx
    """
    if not ir_block:
        return []

    helpers = []

    for m in re.finditer(r'\b([A-Za-z_][A-Za-z0-9_]*)\s*\(', ir_block):
        name = m.group(1)

        if not (name.startswith("fun_") or name.startswith("modifier_")):
            continue

        if name not in helpers:
            helpers.append(name)

    return helpers

def slice_ir_windows_by_helper_names_near_pos(ir_text: str, helper_names, anchor_pos: int, search_radius=5000, window=2200):
    """
    从当前 dispatch anchor 附近搜索 helper，避免拿到全局第一次命中
    """
    out = {}

    if not ir_text:
        return out

    lo = max(0, anchor_pos - search_radius)
    hi = min(len(ir_text), anchor_pos + search_radius)
    local_text = ir_text[lo:hi]

    for name in helper_names:
        local_pos = local_text.find(name)
        if local_pos == -1:
            out[name] = ""
            continue

        pos = lo + local_pos
        start = max(0, pos - 250)
        end = min(len(ir_text), pos + window)
        out[name] = ir_text[start:end]

    return out

def build_storage_slot_to_name_map(storage: dict):
    """
    从 flattened storage 中建立 slot -> var_name 映射
    仅对 scalar state variable 可靠，mapping 先不做精确 IR 反解。
    """
    out = {}
    for name, meta in (storage or {}).items():
        slot = meta.get("slot")
        if slot is None:
            continue
        out[str(slot)] = name
        # 兼容 "0x00" / "0x01"
        try:
            out[hex(int(slot))] = name
        except:
            pass
    return out

def normalize_ir_identifier(s: str) -> str:
    if s is None:
        return ""
    return str(s).strip().replace("%", "")


def extract_ir_update_facts_from_block(fn_name, ir_block, storage):
    """
    增强版 IR update extractor

    支持：
    1) scalar slot:
       - sstore(slot, value)
       - sstore(slot, add(sload(slot), delta))
       - sstore(slot, sub(sload(slot), delta))

    2) strict mapping ownership:
       - mstore(ptr, key)
       - mstore(add(ptr, 0x20), slot)
       - let h := keccak256(ptr, 0x40)
       - sstore(h, value)

    设计目标：
    - AST 为主，IR 仅保守补强
    - mapping 必须严格归属，不能再把任意 keccak256 乱归到所有 mapping
    """

    if not ir_block:
        return []

    text = _strip_ir_comments(ir_block)
    lines = [x.strip() for x in text.splitlines() if x.strip()]

    results = []

    # -------------------------------------------------
    # 1) scalar slot -> storage var 映射
    # -------------------------------------------------
    slot_to_var = {}
    for var, meta in (storage or {}).items():
        try:
            if meta.get("is_mapping"):
                continue
            slot = _to_int_if_literal(str(meta.get("slot")))
            if slot is None:
                continue
            slot_to_var[str(slot)] = var
            slot_to_var[hex(slot)] = var
        except Exception:
            continue

    # -------------------------------------------------
    # 2) 恢复 strict mapping hash ownership
    #    hash_var -> {"mapping_name": ..., "key_expr": ..., ...}
    # -------------------------------------------------
    recovered_mapping_hashes = _recover_mapping_preimages_from_keccak(lines, storage)

    # -------------------------------------------------
    # 3) 收集局部别名，便于解析 sstore(var, ...)
    # -------------------------------------------------
    assigns = _collect_local_ir_assignments(lines)

    # -------------------------------------------------
    # 4) 遍历 sstore(...)
    # -------------------------------------------------
    for line in lines:
        line_n = _ir_norm(line)

        m = re.search(r'\bsstore\s*\((.*)\)\s*$', line_n)
        if not m:
            continue

        args = _split_top_level_args(m.group(1))
        if len(args) != 2:
            continue

        slot_expr_raw = args[0]
        value_expr_raw = args[1]

        slot_expr = _resolve_ir_alias(slot_expr_raw, assigns)
        value_expr = _resolve_ir_alias(value_expr_raw, assigns)

        slot_expr_n = _ir_strip_parens(slot_expr)
        value_expr_n = _ir_strip_parens(value_expr)

        # =================================================
        # A. scalar slot 写入
        # =================================================

        scalar_target = slot_to_var.get(slot_expr_n)
        if scalar_target:
            upd = _unwrap_ir_numeric_update(value_expr_n, slot_expr_n)

            op = upd["op"]
            delta = upd["delta"]
            assigned_value = upd["assigned_value"]

            if "caller()" in value_expr_n and op == "assign":
                assigned_value = "caller()"
                delta = "caller()"

            results.append({
                "function": fn_name,
                "target": scalar_target,
                "target_kind": "scalar",
                "op": op,
                "delta": delta,
                "assigned_value": assigned_value,
                "index_expr": None,
                "raw": f"sstore({slot_expr_n}, {value_expr_n})",
                "source": "solc-ir"
            })
            continue

        # =================================================
        # B. strict mapping keccak 归属
        #    只有 slot_expr 是某个已恢复 hash_var 时才认
        # =================================================

        if slot_expr_n in recovered_mapping_hashes:
            mapping_info = recovered_mapping_hashes[slot_expr_n]
            mapping_name = mapping_info["mapping_name"]
            key_expr = mapping_info["key_expr"]

            upd = _unwrap_ir_numeric_update(value_expr_n, slot_expr_n)

            results.append({
                "function": fn_name,
                "target": mapping_name,
                "target_kind": "mapping",
                "op": upd["op"],
                "delta": upd["delta"],
                "assigned_value": upd["assigned_value"],
                "index_expr": key_expr,
                "raw": f"mapping_hash={slot_expr_n}; {value_expr_n}",
                "source": "solc-ir"
            })
            continue

        # =================================================
        # C. 不再做旧版弱 mapping 猜测
        # =================================================
        # 故意跳过：任何无法严格归属的 keccak/mapping sstore
        pass

    # -------------------------------------------------
    # 5) 去重
    # -------------------------------------------------
    uniq = {}
    for f in results:
        key = (
            f.get("function"),
            f.get("target"),
            f.get("target_kind"),
            f.get("op"),
            str(f.get("delta")),
            str(f.get("assigned_value")),
            str(f.get("index_expr")),
            str(f.get("raw")),
            f.get("source"),
        )
        uniq[key] = f

    return list(uniq.values())


def should_accept_ir_update_fact(fact, storage):
    """
    IR fact 最后一层保险过滤
    """
    if not isinstance(fact, dict):
        return False

    if fact.get("source") != "solc-ir":
        return True

    target = fact.get("target")
    if not target or target not in (storage or {}):
        return False

    meta = storage.get(target, {})

    if meta.get("is_mapping"):
        idx = fact.get("index_expr")
        raw = str(fact.get("raw", ""))

        # mapping 至少要能证明“存在 key 维度”
        # 可以是恢复出的具体 key，也可以先是 '?'
        if idx is None or str(idx).strip() == "":
            return False

        # 必须来自 keccak / recovered mapping hash
        if "keccak256" not in raw and "mapping_hash" not in raw and "sstore(" not in raw:
            return False

    return True

def _normalize_ir_expr(expr: str) -> str:
    if expr is None:
        return ""
    s = " ".join(str(expr).strip().split())
    s = s.replace("\n", " ").replace("\r", " ")
    s = re.sub(r"\s+", " ", s)
    return s.strip()


def _strip_ir_comments(text: str) -> str:
    """
    去掉 solc IR 中常见的注释，避免干扰正则。
    """
    if not text:
        return ""

    # 删掉 /// @src ... / /// @use-src ...
    text = re.sub(r"///[^\n]*", " ", text)
    # 删掉 /** ... */
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.DOTALL)
    return text


def _find_matching_brace(s: str, open_brace_idx: int) -> int:
    """
    给定 '{' 的位置，返回匹配的 '}' 下标，失败返回 -1
    """
    if open_brace_idx < 0 or open_brace_idx >= len(s) or s[open_brace_idx] != "{":
        return -1

    depth = 0
    for i in range(open_brace_idx, len(s)):
        ch = s[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
    return -1


def _extract_if_blocks(ir_block: str):
    """
    提取所有 if (...) { ... } / if expr { ... } 结构
    返回 [(cond_expr, body_str), ...]
    这里针对 Yul/IR 的 if <expr> { ... } 写法
    """
    out = []
    if not ir_block:
        return out

    s = ir_block
    i = 0
    n = len(s)

    while i < n:
        idx = s.find("if", i)
        if idx < 0:
            break

        # 单词边界粗判，避免匹配到别的字符串
        if idx > 0 and (s[idx - 1].isalnum() or s[idx - 1] == "_"):
            i = idx + 2
            continue
        if idx + 2 < n and (s[idx + 2].isalnum() or s[idx + 2] == "_"):
            i = idx + 2
            continue

        j = idx + 2
        while j < n and s[j].isspace():
            j += 1

        # cond 从 j 开始，到后面第一个与当前层级匹配的 '{' 之前
        depth_paren = 0
        cond_start = j
        brace_pos = -1
        k = j
        while k < n:
            ch = s[k]
            if ch == "(":
                depth_paren += 1
            elif ch == ")":
                if depth_paren > 0:
                    depth_paren -= 1
            elif ch == "{":
                if depth_paren == 0:
                    brace_pos = k
                    break
            k += 1

        if brace_pos < 0:
            i = j
            continue

        cond_expr = s[cond_start:brace_pos].strip()
        body_end = _find_matching_brace(s, brace_pos)
        if body_end < 0:
            i = brace_pos + 1
            continue

        body = s[brace_pos + 1:body_end]
        out.append((_normalize_ir_expr(cond_expr), body))
        i = body_end + 1

    return out


def _extract_require_helper_calls(ir_block: str):
    """
    提取:
      require_helper_xxx(cond)
      require_helper_stringliteral_xxx(cond)
    返回 [cond, ...]
    """
    out = []
    if not ir_block:
        return out

    # 先做轻量注释清理
    s = ir_block

    # 匹配 require_helper...( <expr> )
    # 用非贪婪到右括号，不追求完美 parser，但对当前 IR 基本够用
    pattern = re.compile(
        r"\b(require_helper(?:_[A-Za-z0-9]+)*)\s*\(\s*(.*?)\s*\)",
        re.DOTALL
    )

    for m in pattern.finditer(s):
        fn_name = m.group(1)
        cond = _normalize_ir_expr(m.group(2))

        # 过滤掉奇怪的空匹配
        if not cond:
            continue

        # 只保留 require_helper*
        if not fn_name.startswith("require_helper"):
            continue

        out.append(cond)

    return out


def _contains_revert_like(body: str) -> bool:
    body_n = _normalize_ir_expr(body)
    return ("revert(" in body_n) or ("invalid()" in body_n)


def _pretty_guard_expr(cond: str) -> str:
    """
    对 IR 表达式做轻量格式化，尽量让输出更适合你后续 guard_facts 使用。
    """
    c = _normalize_ir_expr(cond)

    # 常见包装去一层括号
    if c.startswith("(") and c.endswith(")"):
        inner = c[1:-1].strip()
        if inner:
            c = f"({inner})"

    # 把 if iszero(x) { revert } 还原成 not(x) 风格
    m = re.fullmatch(r"iszero\s*\(\s*(.*)\s*\)", c)
    if m:
        inner = _normalize_ir_expr(m.group(1))
        if inner:
            return f"not({inner})"

    return c

def is_abi_guard_expr(expr: str) -> bool:
    s = (expr or "").lower()
    return (
        "calldatasize" in s or
        "callvalue()" in s or
        "abi_decode" in s or
        "slt(add(calldatasize()" in s
    )

def extract_guard_exprs_from_ir_block(ir_block: str):
    """
    从单个函数对应的 IR block 中提取 guard 条件表达式。

    返回:
        List[str]

    能识别:
    1) require_helper_xxx(cond)
    2) if cond { revert(...) }     -> 记为 cond
    3) if iszero(cond) { revert }  -> 记为 not(cond)
    4) 常见 ABI/check guard:
       - callvalue()
       - slt(add(calldatasize(), not(3)), 32)
       等等

    注意:
    - 这里只做“guard expr 抽取”，不做语义分类
    - 结果可直接并入 summary["guards"]
    """
    if not ir_block:
        return []

    text = _strip_ir_comments(ir_block)
    text = _normalize_ir_expr(text)

    guards = []

    # -------------------------------------------------
    # 1) require_helper(...)
    # -------------------------------------------------
    for cond in _extract_require_helper_calls(text):
        pretty = _pretty_guard_expr(cond)
        if pretty:
            guards.append(pretty)

    # -------------------------------------------------
    # 2) if <cond> { revert(...) }
    # -------------------------------------------------
    for cond, body in _extract_if_blocks(text):
        if not _contains_revert_like(body):
            continue

        pretty = _pretty_guard_expr(cond)
        if pretty:
            guards.append(pretty)

    guards = [g for g in guards if not is_abi_guard_expr(g)]

    # -------------------------------------------------
    # 去重，保序
    # -------------------------------------------------
    dedup = []
    seen = set()
    for g in guards:
        key = g.strip()
        if not key:
            continue
        if key in seen:
            continue
        seen.add(key)
        dedup.append(key)

    return dedup


def _ir_norm(s: str) -> str:
    if s is None:
        return ""
    s = str(s).replace("\n", " ").replace("\r", " ")
    s = re.sub(r"\s+", " ", s)
    return s.strip()


def _ir_strip_parens(s: str) -> str:
    s = _ir_norm(s)
    while len(s) >= 2 and s[0] == "(" and s[-1] == ")":
        depth = 0
        ok = True
        for i, ch in enumerate(s):
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0 and i != len(s) - 1:
                    ok = False
                    break
        if ok:
            s = s[1:-1].strip()
        else:
            break
    return s


def _split_top_level_args(s: str):
    """
    将 'a, add(b, 0x20), keccak256(x, 0x40)' 拆成顶层参数列表
    """
    s = _ir_norm(s)
    out = []
    cur = []
    depth = 0

    for ch in s:
        if ch == "(":
            depth += 1
            cur.append(ch)
        elif ch == ")":
            depth -= 1
            cur.append(ch)
        elif ch == "," and depth == 0:
            out.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)

    if cur:
        out.append("".join(cur).strip())

    return out


def _parse_call_like(expr: str):
    """
    解析类似:
      add(x, 0x20)
      keccak256(_1, 0x40)
    返回:
      ("add", ["x", "0x20"])
    失败返回 (None, [])
    """
    expr = _ir_norm(expr)
    m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*\((.*)\)$', expr)
    if not m:
        return None, []

    fn = m.group(1)
    args_str = m.group(2).strip()
    args = _split_top_level_args(args_str)
    return fn, args


def _is_hex_or_int_literal(s: str) -> bool:
    s = _ir_strip_parens(s)
    return bool(re.fullmatch(r'(0x[0-9a-fA-F]+|\d+)', s))


def _to_int_if_literal(s: str):
    s = _ir_strip_parens(s)
    try:
        if s.startswith("0x") or s.startswith("0X"):
            return int(s, 16)
        return int(s)
    except Exception:
        return None


def _same_ir_expr(a: str, b: str) -> bool:
    return _ir_strip_parens(a) == _ir_strip_parens(b)


def _is_add_ptr_32(expr: str, base_ptr: str) -> bool:
    """
    判断 expr 是否等于 add(base_ptr, 0x20) / add(base_ptr, 32)
    """
    expr = _ir_strip_parens(expr)
    fn, args = _parse_call_like(expr)
    if fn != "add" or len(args) != 2:
        return False

    a0 = _ir_strip_parens(args[0])
    a1 = _to_int_if_literal(args[1])

    return a0 == _ir_strip_parens(base_ptr) and a1 == 32


def _build_mapping_slot_candidates(storage):
    """
    只收集 mapping 变量的 base slot 候选
    返回:
      {
        "1": [("_balances", meta)],
        "5": [("whitelist", meta)],
        ...
      }
    """
    out = {}
    for name, meta in (storage or {}).items():
        if not meta.get("is_mapping"):
            continue

        slot = meta.get("slot")
        if slot is None:
            continue

        slot_int = _to_int_if_literal(str(slot))
        if slot_int is None:
            continue

        out.setdefault(str(slot_int), []).append((name, meta))
        out.setdefault(hex(slot_int), []).append((name, meta))

    return out


def _collect_local_ir_assignments(lines):
    """
    收集局部 let / := 绑定
    仅做轻量 SSA-ish 映射，不做跨分支数据流。
    返回:
      assigns[var] = expr
    """
    assigns = {}

    for line in lines:
        line_n = _ir_norm(line)

        # let x := expr
        m = re.match(r'^let\s+([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*(.+)$', line_n)
        if m:
            var = m.group(1)
            expr = m.group(2).strip()
            assigns[var] = expr
            continue

        # x := expr
        m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*(.+)$', line_n)
        if m:
            var = m.group(1)
            expr = m.group(2).strip()
            assigns[var] = expr
            continue

    return assigns


def _unwrap_ir_numeric_update(value_expr: str, slot_expr: str):
    """
    识别 scalar/mapping 的 IR 数值更新模式
    返回:
      {
        "op": "add" | "sub" | "assign",
        "delta": "...",
        "assigned_value": "...",
      }
    """
    value_expr_n = _ir_strip_parens(value_expr)
    slot_expr_n = _ir_strip_parens(slot_expr)

    fn, args = _parse_call_like(value_expr_n)

    # 1) add(sload(slot), delta)
    if fn == "add" and len(args) == 2:
        a0 = _ir_strip_parens(args[0])
        a1 = _ir_strip_parens(args[1])

        fn2, args2 = _parse_call_like(a0)
        if fn2 == "sload" and len(args2) == 1 and _same_ir_expr(args2[0], slot_expr_n):
            return {
                "op": "add",
                "delta": a1,
                "assigned_value": None,
            }

    # 2) sub(sload(slot), delta)
    if fn == "sub" and len(args) == 2:
        a0 = _ir_strip_parens(args[0])
        a1 = _ir_strip_parens(args[1])

        fn2, args2 = _parse_call_like(a0)
        if fn2 == "sload" and len(args2) == 1 and _same_ir_expr(args2[0], slot_expr_n):
            return {
                "op": "sub",
                "delta": a1,
                "assigned_value": None,
            }

    # 3) increment_uint256(sload(slot)) / decrement_uint256(...)
    if fn in ["increment_uint256", "increment_t_uint256", "wrapping_increment_t_uint256"] and len(args) == 1:
        a0 = _ir_strip_parens(args[0])
        fn2, args2 = _parse_call_like(a0)
        if fn2 == "sload" and len(args2) == 1 and _same_ir_expr(args2[0], slot_expr_n):
            return {
                "op": "add",
                "delta": "1",
                "assigned_value": None,
            }

    if fn in ["decrement_uint256", "decrement_t_uint256", "wrapping_decrement_t_uint256"] and len(args) == 1:
        a0 = _ir_strip_parens(args[0])
        fn2, args2 = _parse_call_like(a0)
        if fn2 == "sload" and len(args2) == 1 and _same_ir_expr(args2[0], slot_expr_n):
            return {
                "op": "sub",
                "delta": "1",
                "assigned_value": None,
            }

    # 4) checked_add_t_uint256(sload(slot), x)
    if fn and ("checked_add" in fn or "wrapping_add" in fn) and len(args) == 2:
        a0 = _ir_strip_parens(args[0])
        a1 = _ir_strip_parens(args[1])
        fn2, args2 = _parse_call_like(a0)
        if fn2 == "sload" and len(args2) == 1 and _same_ir_expr(args2[0], slot_expr_n):
            return {
                "op": "add",
                "delta": a1,
                "assigned_value": None,
            }

    # 5) checked_sub_t_uint256(sload(slot), x)
    if fn and ("checked_sub" in fn or "wrapping_sub" in fn) and len(args) == 2:
        a0 = _ir_strip_parens(args[0])
        a1 = _ir_strip_parens(args[1])
        fn2, args2 = _parse_call_like(a0)
        if fn2 == "sload" and len(args2) == 1 and _same_ir_expr(args2[0], slot_expr_n):
            return {
                "op": "sub",
                "delta": a1,
                "assigned_value": None,
            }

    return {
        "op": "assign",
        "delta": value_expr_n,
        "assigned_value": value_expr_n,
    }

def _resolve_ir_alias(expr: str, assigns: dict, max_hops=6):
    """
    把变量别名链解析几步:
      _7 -> _3
      _3 -> add(_1, 0x20)
    """
    cur = _ir_strip_parens(expr)
    for _ in range(max_hops):
        if cur in assigns:
            nxt = _ir_strip_parens(assigns[cur])
            if nxt == cur:
                break
            cur = nxt
        else:
            break
    return cur


def _collect_mstore_facts(lines, assigns):
    """
    收集 mstore 写入:
      mstore(ptr_expr, value_expr)
    返回 list:
      [{"ptr": "...", "value": "...", "line": "..."}]
    """
    out = []

    for line in lines:
        line_n = _ir_norm(line)
        m = re.search(r'\bmstore\s*\((.*)\)\s*$', line_n)
        if not m:
            continue

        args = _split_top_level_args(m.group(1))
        if len(args) != 2:
            continue

        ptr_expr = _resolve_ir_alias(args[0], assigns)
        val_expr = _resolve_ir_alias(args[1], assigns)

        out.append({
            "ptr": _ir_strip_parens(ptr_expr),
            "value": _ir_strip_parens(val_expr),
            "raw": line_n
        })

    return out


def _collect_keccak_bindings(lines, assigns):
    """
    收集:
      let h := keccak256(ptr, 0x40)
      x := keccak256(ptr, 64)
    返回:
      [{"hash_var": "h", "ptr": "...", "size": 64, "raw": "..."}]
    """
    out = []

    for line in lines:
        line_n = _ir_norm(line)

        m = re.match(r'^(?:let\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*keccak256\s*\((.*)\)\s*$', line_n)
        if not m:
            continue

        hash_var = m.group(1)
        args = _split_top_level_args(m.group(2))
        if len(args) != 2:
            continue

        ptr_expr = _resolve_ir_alias(args[0], assigns)
        size_expr = _resolve_ir_alias(args[1], assigns)
        size_int = _to_int_if_literal(size_expr)

        out.append({
            "hash_var": hash_var,
            "ptr": _ir_strip_parens(ptr_expr),
            "size": size_int,
            "raw": line_n
        })

    return out


def _recover_mapping_preimages_from_keccak(lines, storage):
    """
    恢复高置信 mapping preimage:
      mstore(ptr, key)
      mstore(add(ptr, 0x20), slot)
      let h := keccak256(ptr, 0x40)

    返回:
      {
        "h": {
            "mapping_name": "_balances",
            "slot_expr": "1",
            "key_expr": "...",
            "confidence": "high"
        },
        ...
      }
    """
    assigns = _collect_local_ir_assignments(lines)
    mstores = _collect_mstore_facts(lines, assigns)
    keccak_bindings = _collect_keccak_bindings(lines, assigns)
    mapping_slot_candidates = _build_mapping_slot_candidates(storage)

    # ptr -> mstore facts
    ptr_writes = {}
    for item in mstores:
        ptr_writes.setdefault(item["ptr"], []).append(item)

    recovered = {}

    for kb in keccak_bindings:
        # 只认 keccak256(ptr, 0x40)
        if kb["size"] != 64:
            continue

        base_ptr = kb["ptr"]
        writes_at_base = ptr_writes.get(base_ptr, [])
        writes_at_ptr32 = []

        # 找 add(base_ptr, 0x20) 对应写入
        for ptr_key, ws in ptr_writes.items():
            if _is_add_ptr_32(ptr_key, base_ptr):
                writes_at_ptr32.extend(ws)

        # 期望：
        #   mstore(base_ptr, key)
        #   mstore(add(base_ptr, 0x20), slot)
        if len(writes_at_base) != 1:
            continue
        if len(writes_at_ptr32) != 1:
            continue

        key_expr = writes_at_base[0]["value"]
        slot_expr = writes_at_ptr32[0]["value"]

        slot_norm = _ir_strip_parens(slot_expr)
        slot_candidates = mapping_slot_candidates.get(slot_norm, [])

        # 只有唯一 mapping slot 才归属
        if len(slot_candidates) != 1:
            continue

        mapping_name, meta = slot_candidates[0]

        recovered[kb["hash_var"]] = {
            "mapping_name": mapping_name,
            "slot_expr": slot_expr,
            "key_expr": key_expr,
            "confidence": "high",
            "raw_keccak": kb["raw"],
            "raw_key_store": writes_at_base[0]["raw"],
            "raw_slot_store": writes_at_ptr32[0]["raw"],
        }
    
    # print("[IR-MAP-RECOVER]", recovered)

    return recovered

def build_ir_function_summaries(functions, storage, contract_name, compiler_artifacts):
    """
    基于 solc IR 为每个函数建立补充 summary

    设计原则：
    1. IR 只作为 AST summary 的补强，不单独主导调用传播；
    2. IR helper calls 不进入统一 calls 字段，避免 propagate_internal_summaries 污染；
    3. helper block 只在当前 dispatch/window 附近搜索，避免全局第一次命中串函数；
    4. 允许从 dispatch/window 本体和 helper window 两处恢复 updates；
    5. guard_exprs 只作为补充信息，后续是否用于 access guard 仍需上层过滤。
    """
    ir_text = get_contract_ir_text(
        compiler_artifacts=compiler_artifacts,
        contract_name=contract_name,
        optimized=True
    )

    summaries = {}

    # 没有 IR，直接返回空补强 summary
    if not ir_text:
        for fn_name in functions.keys():
            summaries[fn_name] = {
                "updates": [],
                "calls": [],              # 关键：IR 路径不参与调用冒泡
                "guard_exprs": [],
                "transition_hints": [],
                "source": "solc-ir",
                "ir_helper_calls": [],
            }
        return summaries

    # function windows:
    # {
    #   "nextStage": {"text": "...", "start": 123, "end": 456},
    #   ...
    # }
    function_blocks = slice_ir_windows_by_function_names(
        ir_text=ir_text,
        function_names=list(functions.keys()),
        window=3500
    )

    for fn_name in functions.keys():
        block_info = function_blocks.get(fn_name, {}) or {}
        ir_block = block_info.get("text", "") or ""
        anchor_pos = block_info.get("start", -1)

        updates = []
        guard_exprs = []
        ir_helper_calls = []

        # -------------------------------------------------
        # A. 先从 dispatch/function window 本体提取 updates
        # -------------------------------------------------
        if ir_block:
            try:
                direct_updates = extract_ir_update_facts_from_block(
                    fn_name=fn_name,
                    ir_block=ir_block,
                    storage=storage
                )
                if direct_updates:
                    updates.extend(direct_updates)
            except Exception as e:
                print(f"[IR] direct update extraction failed for {fn_name}: {e}")

            # guard 提取可选
            try:
                ir_guards = extract_guard_exprs_from_ir_block(ir_block)
                if ir_guards:
                    guard_exprs.extend(ir_guards)
            except Exception:
                pass

        # -------------------------------------------------
        # B. 再从当前 dispatch window 中抽 helper
        #    注意：helper 仅用于本函数局部补强，不能进入 calls 冒泡
        # -------------------------------------------------
        if ir_block:
            try:
                ir_helper_calls = extract_ir_dispatch_helper_calls(ir_block)
            except Exception as e:
                print(f"[IR] helper extraction failed for {fn_name}: {e}")
                ir_helper_calls = []

        # -------------------------------------------------
        # C. 从当前 anchor 附近定位 helper window，提取 helper 中的 updates
        # -------------------------------------------------
        if ir_helper_calls:
            try:
                helper_blocks = slice_ir_windows_by_helper_names_near_pos(
                    ir_text=ir_text,
                    helper_names=ir_helper_calls,
                    anchor_pos=anchor_pos if isinstance(anchor_pos, int) and anchor_pos >= 0 else 0,
                    search_radius=5000,
                    window=2200
                )
            except Exception as e:
                print(f"[IR] helper slicing failed for {fn_name}: {e}")
                helper_blocks = {}

            for helper_name, helper_block in (helper_blocks or {}).items():
                if not helper_block:
                    continue

                try:
                    helper_updates = extract_ir_update_facts_from_block(
                        fn_name=fn_name,      # 归属当前 Solidity 函数，而不是 helper 名
                        ir_block=helper_block,
                        storage=storage
                    )
                    if helper_updates:
                        updates.extend(helper_updates)
                except Exception as e:
                    print(f"[IR] helper update extraction failed for {fn_name}/{helper_name}: {e}")

                try:
                    helper_guards = extract_guard_exprs_from_ir_block(helper_block)
                    if helper_guards:
                        guard_exprs.extend(helper_guards)
                except Exception:
                    pass

        # -------------------------------------------------
        # D0. IR facts 过滤
        # -------------------------------------------------
        filtered_updates = []
        for u in updates:
            if should_accept_ir_update_fact(u, storage):
                filtered_updates.append(u)
        updates = filtered_updates

        # -------------------------------------------------
        # D. updates 去重
        #    注意：这里保留 source=solc-ir，便于后续 evidence 统计
        # -------------------------------------------------
        uniq_updates = {}
        for u in updates:
            u2 = dict(u)
            u2["function"] = fn_name
            u2["source"] = "solc-ir"

            key = (
                u2.get("target"),
                u2.get("target_kind"),
                u2.get("op"),
                str(u2.get("delta")),
                str(u2.get("index_expr")),
                str(u2.get("assigned_value", "")),
                str(u2.get("raw", "")),
            )
            uniq_updates[key] = u2

        # guards 去重
        guard_exprs = [g for g in guard_exprs if g]
        guard_exprs = list(dict.fromkeys(guard_exprs))

        summaries[fn_name] = {
            "updates": list(uniq_updates.values()),
            "calls": [],   # 关键：绝不把 IR helper calls 暴露给 propagate_internal_summaries
            "guard_exprs": guard_exprs,
            "transition_hints": [],
            "source": "solc-ir",
            "ir_helper_calls": list(dict.fromkeys(ir_helper_calls)),
        }

    return summaries


def merge_function_summaries(ast_summaries, ir_summaries):
    """
    AST 为主，IR 为补充
    - updates 合并去重
    - calls / guard_exprs 先保留 AST 主结果
    - 保留 evidence_sources / evidence_raws，便于后续统计 IR 是否真的产生增益
    """
    out = {}

    all_names = set(ast_summaries.keys()) | set(ir_summaries.keys())

    for fn_name in all_names:
        a = ast_summaries.get(fn_name, {})
        b = ir_summaries.get(fn_name, {})

        updates = []
        updates.extend(a.get("updates", []))
        updates.extend(b.get("updates", []))

        uniq_updates = {}
        for u in updates:
            key = (
                u.get("target"),
                u.get("target_kind"),
                u.get("op"),
                str(u.get("delta")),
                str(u.get("index_expr")),
                str(u.get("assigned_value", "")),
            )

            if key not in uniq_updates:
                item = dict(u)
                src = item.get("source", "unknown")
                raw = item.get("raw")

                item["evidence_sources"] = [src] if src else []
                item["evidence_raws"] = [raw] if raw else []
                uniq_updates[key] = item
            else:
                item = uniq_updates[key]
                src = u.get("source", "unknown")
                raw = u.get("raw")

                if src and src not in item["evidence_sources"]:
                    item["evidence_sources"].append(src)

                if raw and raw not in item["evidence_raws"]:
                    item["evidence_raws"].append(raw)

                # AST 优先作为主 source，若当前不是 AST 而新来的为 AST，则覆盖主展示字段
                if item.get("source") != "ast" and src == "ast":
                    item["source"] = "ast"
                    item["raw"] = u.get("raw", item.get("raw"))

        calls = list(dict.fromkeys((a.get("calls", []) or []) + (b.get("calls", []) or [])))
        guard_exprs = list(dict.fromkeys((a.get("guard_exprs", []) or []) + (b.get("guard_exprs", []) or [])))

        out[fn_name] = {
            "updates": list(uniq_updates.values()),
            "calls": calls,
            "guard_exprs": guard_exprs,
            "transition_hints": []
        }

    return out

def build_unified_function_effects(functions, summaries, storage):
    """
    对标 Slither function summary / side effect view
    """
    out = {}

    for fn_name, fn in functions.items():
        info = summaries.get(fn_name, {})

        writes = []
        reads = set()
        guard_exprs = info.get("guard_exprs", []) or []

        for u in info.get("updates", []):
            tgt = u.get("target")
            if tgt:
                writes.append(tgt)

        for node in walk_ast(fn):
            if node.get("nodeType") == "Identifier":
                var = node.get("name")
                if var in storage:
                    reads.add(var)

        out[fn_name] = {
            "externally_callable": is_externally_callable_function(fn),
            "mutating": fn.get("stateMutability") not in ["view", "pure"],
            "writes": list(dict.fromkeys(writes)),
            "reads": sorted(list(reads)),
            "calls": info.get("calls", []),
            "guard_exprs": guard_exprs,
            "transition_hints": info.get("transition_hints", []),
            "updates": info.get("updates", []),
        }

    return out

def normalize_update_fact(fact):
    """
    将不同来源(AST / propagated / IR)的 update fact 规整成统一形式
    """
    if not isinstance(fact, dict):
        return None

    out = {
        "function": fact.get("function"),
        "target": fact.get("target"),
        "target_kind": fact.get("target_kind"),
        "op": fact.get("op"),
        "delta": fact.get("delta"),
        "assigned_value": fact.get("assigned_value"),
        "index_expr": fact.get("index_expr"),
        "raw": fact.get("raw"),
        "source": fact.get("source", "unknown"),
    }

    if not out["target"] or not out["op"]:
        return None

    return out


def fuse_update_facts_from_summaries(summaries):
    """
    从 summaries 中统一提取 update facts，并聚合来源证据
    输出的每个 fact 具有:
    - evidence_sources
    - evidence_raws
    """
    fused = {}

    for fn_name, info in summaries.items():
        for fact in info.get("updates", []):
            item = normalize_update_fact(fact)
            if not item:
                continue

            item["function"] = fn_name

            key = (
                item.get("function"),
                item.get("target"),
                item.get("target_kind"),
                item.get("op"),
                str(item.get("delta")),
                str(item.get("assigned_value")),
                str(item.get("index_expr")),
            )

            if key not in fused:
                fused[key] = dict(item)
                fused[key]["evidence_sources"] = [item.get("source", "unknown")]
                fused[key]["evidence_raws"] = [item.get("raw")] if item.get("raw") else []
            else:
                src = item.get("source", "unknown")
                if src not in fused[key]["evidence_sources"]:
                    fused[key]["evidence_sources"].append(src)

                raw = item.get("raw")
                if raw and raw not in fused[key]["evidence_raws"]:
                    fused[key]["evidence_raws"].append(raw)

    return list(fused.values())

def extract_internal_calls(fn, known_function_names=None):
    calls = []
    known_function_names = set(known_function_names or [])

    for node in walk_ast(fn):
        if node.get("nodeType") != "FunctionCall":
            continue

        expr = node.get("expression", {})

        callee = None
        if expr.get("nodeType") == "Identifier":
            callee = expr.get("name")
        elif expr.get("nodeType") == "MemberAccess":
            # 成员调用一般不是 internal solidity function，先忽略
            callee = None

        if not callee:
            continue

        # 只保留已知 Solidity 函数
        if callee in known_function_names:
            calls.append(callee)

    return list(dict.fromkeys(calls))

def build_function_summaries(functions, storage):
    """
    AST summaries:
    - direct updates
    - internal calls
    - guard expressions
    """
    summaries = {}

    for fn_name, fn in functions.items():
        updates = []

        for node in walk_ast(fn):
            if node.get("nodeType") == "Assignment":
                fact = extract_update_from_assignment(node, storage, fn_name)
                if fact:
                    fact["source"] = "ast"
                    updates.append(fact)

            elif node.get("nodeType") == "UnaryOperation":
                fact = extract_update_from_unary_operation(node, storage, fn_name)
                if fact:
                    updates.append(fact)
        known_names = set(functions.keys())
        calls = extract_internal_calls(fn, known_function_names=known_names)
        guard_exprs = extract_guard_exprs_from_function(fn)

        summaries[fn_name] = {
            "updates": updates,
            "calls": calls,
            "guard_exprs": guard_exprs,
            "transition_hints": [],
            "source": "ast"
        }

    return summaries

def propagate_internal_summaries(summaries):
    """
    将 internal callee 的 summary 向 caller 冒泡:
    - updates
    - guard_exprs
    """
    for _ in range(5):
        changed = False

        for fn, info in summaries.items():
            calls = info.get("calls", [])

            for callee in calls:
                if callee not in summaries or callee == fn:
                    continue

                callee_info = summaries[callee]

                for u in callee_info.get("updates", []):
                    if u not in info["updates"]:
                        info["updates"].append(u)
                        changed = True

                for g in callee_info.get("guard_exprs", []):
                    if g not in info["guard_exprs"]:
                        info["guard_exprs"].append(g)
                        changed = True

        if not changed:
            break

    return summaries

def build_transition_hints_from_summaries(summaries, storage, enums):
    """
    从 unified summaries 中预先恢复 state transition hints，
    供 infer_state_machine 使用。
    """
    out = {}

    for fn_name, info in (summaries or {}).items():
        hints = []
        guard_exprs = info.get("guard_exprs", []) or []

        for u in info.get("updates", []):
            target = u.get("target")
            if not target or target not in (storage or {}):
                continue

            typ = storage[target].get("type", "")
            state_kind = infer_state_kind_from_type(typ)

            if not (is_state_like_name(target) or state_kind in ["enum", "bool", "uint"]):
                continue

            enum_values = []
            if state_kind == "enum" and "enum " in typ:
                enum_name = typ.split("enum ", 1)[1].split(".")[-1].strip()
                enum_values = enums.get(enum_name, [])

            related_guards = find_state_related_guards(guard_exprs, target)

            tf = build_transition_fact_from_update(
                state_var=target,
                state_kind=state_kind,
                fn_name=fn_name,
                update_fact=u,
                guard_exprs=related_guards,
                enum_values=enum_values
            )

            tf["evidence_sources"] = u.get("evidence_sources", [u.get("source", "unknown")])
            tf["evidence_raws"] = u.get("evidence_raws", [u.get("raw")] if u.get("raw") else [])

            hints.append(tf)

        out[fn_name] = hints

    return out

def build_transition_fact_from_update(state_var, state_kind, fn_name, update_fact, guard_exprs, enum_values=None):
    """
    根据 update_fact 构造 transition fact
    """
    enum_values = enum_values or []
    op = update_fact.get("op")
    raw = update_fact.get("raw", "")
    assigned_value = update_fact.get("assigned_value")
    delta = update_fact.get("delta")

    from_candidates = infer_from_candidates_from_guards(
        state_var_name=state_var,
        state_kind=state_kind,
        guard_exprs=guard_exprs,
        enum_values=enum_values
    )

    fact = {
        "state_var": state_var,
        "state_kind": state_kind,
        "function": fn_name,
        "from_candidates": from_candidates,
        "guard_exprs": guard_exprs,
        "raw": raw
    }

    # -------- assign(stage + 1) / assign(stage - 1) 识别为 relative --------
    if op == "assign" and state_kind == "uint":
        d = str(delta or "").strip().replace(" ", "")
        sv = str(state_var or "").strip()

        if d == f"{sv}+1" or d == f"({sv}+1)":
            fact["transition_kind"] = "relative"
            fact["op"] = "add"
            fact["delta"] = "1"
            fact["to"] = None
            return fact

        if d == f"{sv}-1" or d == f"({sv}-1)":
            fact["transition_kind"] = "relative"
            fact["op"] = "sub"
            fact["delta"] = "1"
            fact["to"] = None
            return fact

    # -------- absolute assign --------
    if op == "assign":
        to_value = assigned_value if assigned_value is not None else delta

        # bool 只接受 true / false 常量
        if state_kind == "bool":
            low = str(to_value).strip().lower()

            if low in ["true", "false"]:
                fact["transition_kind"] = "absolute"
                fact["to"] = low
                return fact

            # 例如:
            #   lastB = y
            #   lastB = p.b
            #   lastB = arr[0].b
            # 这些不是常量终值，不能生成 afterV == y 这种测试断言
            fact["transition_kind"] = "unknown"
            fact["to"] = None
            fact["delta"] = str(to_value)
            return fact

        # enum 只接受明确成员值
        if state_kind == "enum":
            if assigned_value is not None:
                val = str(assigned_value).strip()
                if val in enum_values:
                    fact["transition_kind"] = "absolute"
                    fact["to"] = val
                    return fact

            fact["transition_kind"] = "unknown"
            fact["to"] = None
            fact["delta"] = str(to_value)
            return fact

        # uint / 其他类型维持原逻辑
        fact["transition_kind"] = "absolute"
        fact["to"] = to_value
        return fact

    # -------- relative uint transition --------
    if state_kind == "uint" and op in ["add", "sub"]:
        fact["transition_kind"] = "relative"
        fact["op"] = op
        fact["delta"] = delta
        fact["to"] = None
        return fact

    # -------- fallback --------
    if state_kind == "bool":
        low = str(delta).lower()
        if low in ["true", "false"]:
            fact["transition_kind"] = "absolute"
            fact["to"] = low
            return fact

    if state_kind == "enum":
        if assigned_value is not None:
            fact["transition_kind"] = "absolute"
            fact["to"] = assigned_value
            return fact

    fact["transition_kind"] = "unknown"
    fact["to"] = assigned_value if assigned_value is not None else delta
    return fact

def find_contract_node(ast, contract_name):
    for node in walk_ast(ast):
        if node.get("nodeType") == "ContractDefinition" and node.get("name") == contract_name:
            return node
    return ast

def extract_functions(contract_node):
    """
    Solidity 0.4 - 0.8 兼容函数提取
    """

    funcs = {}

    nodes = contract_node.get("nodes")

    if nodes:
        candidates = nodes
    else:
        candidates = list(walk_ast(contract_node))

    for node in candidates:

        if node.get("nodeType") != "FunctionDefinition":
            continue

        kind = node.get("kind", "")

        # constructor 不进入 handler
        if kind == "constructor":
            continue

        name = node.get("name")

        if not name:
            if kind == "receive":
                name = "__receive__"
            elif kind == "fallback":
                name = "__fallback__"
            else:
                continue

        funcs[name] = node

    return funcs

def extract_enums(contract_node):
    """
    Solidity 0.4 - 0.8 enum 提取
    """

    enums = {}

    nodes = contract_node.get("nodes")

    if nodes:
        candidates = nodes
    else:
        candidates = list(walk_ast(contract_node))

    for node in candidates:

        if node.get("nodeType") != "EnumDefinition":
            continue

        name = node.get("name")

        members = []

        for m in node.get("members", []):
            members.append(m.get("name"))

        enums[name] = members

    return enums
def extract_storage_variables(contract_node):
    """
    Solidity 0.4 - 0.8 兼容 storage 提取

    支持:
    - mapping
    - uint / int
    - address
    - enum
    """

    storage = {}

    # ---------- 优先使用 contract.nodes ----------
    nodes = contract_node.get("nodes")

    if nodes:
        candidates = nodes
    else:
        # 0.4 fallback
        candidates = list(walk_ast(contract_node))

    for node in candidates:

        if node.get("nodeType") != "VariableDeclaration":
            continue

        # 只保留 state variable
        if not node.get("stateVariable", False):
            continue

        name = node.get("name")
        if not name:
            continue

        # ---------- type 解析 (兼容 0.4 / 0.5+) ----------

        typ = ""

        # 0.5+
        if "typeDescriptions" in node:
            typ = node.get("typeDescriptions", {}).get("typeString", "")

        # 0.4 fallback
        elif "typeName" in node:
            typ = expr_to_str(node["typeName"])

        storage[name] = {
            "type": typ,
            "visibility": node.get("visibility", ""),
            "is_mapping": "mapping" in typ,
            "is_uint": ("uint" in typ or "int" in typ),
            "is_address": "address" in typ,
            "is_enum": "enum" in typ
        }

    return storage

def build_function_dfg(functions, storage):
    result = {}
    for name, f in functions.items():
        reads = set()
        writes = set()
        for node in walk_ast(f):
            if node.get("nodeType") == "Assignment":
                left = node.get("leftHandSide", {})
                if left.get("nodeType") == "Identifier":
                    var = left.get("name")
                    if var in storage:
                        writes.add(var)
                if left.get("nodeType") == "IndexAccess":
                    base = left.get("baseExpression", {})
                    if base.get("nodeType") == "Identifier":
                        var = base.get("name")
                        if var in storage:
                            writes.add(var)
            if node.get("nodeType") == "Identifier":
                var = node.get("name")
                if var in storage:
                    reads.add(var)
        result[name] = {
            "reads": reads,
            "writes": writes
        }
    return result

def expr_to_str(node):
    """
    将常见 AST 表达式节点转成稳定字符串，便于做轻量匹配和调试输出
    这里只做 Step 2.1 所需的最小支持
    """
    if not isinstance(node, dict):
        return ""
    nt = node.get("nodeType", "")
    if nt == "Identifier":
        return node.get("name", "")
    if nt == "Literal":
        return str(node.get("value", ""))
    if nt == "MemberAccess":
        base = expr_to_str(node.get("expression", {}))
        member = node.get("memberName", "")
        if base:
            return f"{base}.{member}"
        return member
    if nt == "IndexAccess":
        base = expr_to_str(node.get("baseExpression", {}))
        idx = expr_to_str(node.get("indexExpression", {}))
        return f"{base}[{idx}]"
    if nt == "FunctionCall":
        expr = expr_to_str(node.get("expression", {}))
        args = [expr_to_str(a) for a in node.get("arguments", [])]
        return f"{expr}({', '.join(args)})"
    if nt == "UnaryOperation":
        op = node.get("operator", "")
        sub = expr_to_str(node.get("subExpression", {}))
        prefix = node.get("prefix", True)
        return f"{op}{sub}" if prefix else f"{sub}{op}"
    if nt == "BinaryOperation":
        left = expr_to_str(node.get("leftExpression", {}))
        op = node.get("operator", "")
        right = expr_to_str(node.get("rightExpression", {}))
        return f"({left} {op} {right})"
    if nt == "TupleExpression":
        comps = [expr_to_str(x) for x in node.get("components", []) if x]
        return "(" + ", ".join(comps) + ")"
    return nt

def parse_storage_lvalue(node, storage):
    """
    解析左值是否对应 storage 中的变量，支持：
    - scalar: totalSupply
    - mapping index: balances[msg.sender]
    返回:
    {
        "target": "...",
        "target_kind": "scalar" | "mapping",
        "index_expr": "..."
    }
    或 None
    """
    if not isinstance(node, dict):
        return None
    nt = node.get("nodeType", "")
    if nt == "Identifier":
        name = node.get("name", "")
        if name in storage:
            return {
                "target": name,
                "target_kind": "mapping" if storage[name].get("is_mapping") else "scalar",
                "index_expr": None
            }
        return None
    if nt == "IndexAccess":
        base = node.get("baseExpression", {})
        if base.get("nodeType") == "Identifier":
            name = base.get("name", "")
            if name in storage and storage[name].get("is_mapping"):
                return {
                    "target": name,
                    "target_kind": "mapping",
                    "index_expr": expr_to_str(node.get("indexExpression", {}))
                }
        return None
    return None

def same_storage_ref(expr_node, lvalue_info):
    """
    判断 expr_node 是否与左值引用的是同一个 storage 目标
    """
    if not lvalue_info or not isinstance(expr_node, dict):
        return False
    target = lvalue_info.get("target")
    target_kind = lvalue_info.get("target_kind")
    index_expr = lvalue_info.get("index_expr")
    nt = expr_node.get("nodeType", "")
    if target_kind == "scalar":
        return nt == "Identifier" and expr_node.get("name") == target
    if target_kind == "mapping":
        if nt != "IndexAccess":
            return False
        base = expr_node.get("baseExpression", {})
        if base.get("nodeType") != "Identifier":
            return False
        if base.get("name") != target:
            return False
        other_idx = expr_to_str(expr_node.get("indexExpression", {}))
        return other_idx == index_expr
    return False

def extract_update_from_assignment(assign_node, storage, function_name):
    """
    从 Assignment 节点中提取 update fact
    支持:
    - x += y
    - x -= y
    - x = x + y
    - x = x - y
    - map[k] += y
    - map[k] -= y
    - map[k] = map[k] + y
    - map[k] = map[k] - y
    - x = true / false / Enum.Member / literal / expr   <-- 新增
    """
    if not isinstance(assign_node, dict):
        return None
    if assign_node.get("nodeType") != "Assignment":
        return None

    lhs = assign_node.get("leftHandSide", {})
    rhs = assign_node.get("rightHandSide", {})
    op = assign_node.get("operator", "")

    lvalue = parse_storage_lvalue(lhs, storage)
    if not lvalue:
        return None

    target = lvalue["target"]
    target_kind = lvalue["target_kind"]
    index_expr = lvalue["index_expr"]

    # 1) 直接复合赋值
    if op == "+=":
        return {
            "function": function_name,
            "target": target,
            "target_kind": target_kind,
            "op": "add",
            "delta": expr_to_str(rhs),
            "index_expr": index_expr,
            "raw": f"{expr_to_str(lhs)} += {expr_to_str(rhs)}"
        }

    if op == "-=":
        return {
            "function": function_name,
            "target": target,
            "target_kind": target_kind,
            "op": "sub",
            "delta": expr_to_str(rhs),
            "index_expr": index_expr,
            "raw": f"{expr_to_str(lhs)} -= {expr_to_str(rhs)}"
        }

    # 2) 展开式：x = x + y / x = x - y
    if op == "=" and isinstance(rhs, dict) and rhs.get("nodeType") == "BinaryOperation":
        bop = rhs.get("operator", "")
        left_expr = rhs.get("leftExpression", {})
        right_expr = rhs.get("rightExpression", {})

        # x = x + y
        if bop == "+" and same_storage_ref(left_expr, lvalue):
            return {
                "function": function_name,
                "target": target,
                "target_kind": target_kind,
                "op": "add",
                "delta": expr_to_str(right_expr),
                "index_expr": index_expr,
                "raw": f"{expr_to_str(lhs)} = {expr_to_str(left_expr)} + {expr_to_str(right_expr)}"
            }

        # x = y + x
        if bop == "+" and same_storage_ref(right_expr, lvalue):
            return {
                "function": function_name,
                "target": target,
                "target_kind": target_kind,
                "op": "add",
                "delta": expr_to_str(left_expr),
                "index_expr": index_expr,
                "raw": f"{expr_to_str(lhs)} = {expr_to_str(left_expr)} + {expr_to_str(right_expr)}"
            }

        # x = x - y
        if bop == "-" and same_storage_ref(left_expr, lvalue):
            return {
                "function": function_name,
                "target": target,
                "target_kind": target_kind,
                "op": "sub",
                "delta": expr_to_str(right_expr),
                "index_expr": index_expr,
                "raw": f"{expr_to_str(lhs)} = {expr_to_str(left_expr)} - {expr_to_str(right_expr)}"
            }

    # 3) 普通赋值：x = rhs
    if op == "=":
        return {
            "function": function_name,
            "target": target,
            "target_kind": target_kind,
            "op": "assign",
            "delta": expr_to_str(rhs),
            "assigned_value": state_rhs_to_value(rhs),
            "index_expr": index_expr,
            "raw": f"{expr_to_str(lhs)} = {expr_to_str(rhs)}"
        }

    return None

def extract_update_from_unary_operation(node, storage, function_name):
    """
    支持:
    - x++
    - ++x
    - x--
    - --x
    - map[k]++
    - map[k]--
    """
    if not isinstance(node, dict):
        return None

    if node.get("nodeType") != "UnaryOperation":
        return None

    op = node.get("operator", "")
    if op not in ["++", "--"]:
        return None

    sub = node.get("subExpression", {})
    lvalue = parse_storage_lvalue(sub, storage)
    if not lvalue:
        return None

    return {
        "function": function_name,
        "target": lvalue["target"],
        "target_kind": lvalue["target_kind"],
        "op": "add" if op == "++" else "sub",
        "delta": "1",
        "assigned_value": None,
        "index_expr": lvalue["index_expr"],
        "raw": f"{expr_to_str(sub)}{op}" if not node.get("prefix", True) else f"{op}{expr_to_str(sub)}",
        "source": "ast"
    }

def extract_update_facts(functions, storage):
    facts = []

    for fn_name, fn in functions.items():
        for node in walk_ast(fn):
            if node.get("nodeType") == "Assignment":
                fact = extract_update_from_assignment(node, storage, fn_name)
                if fact:
                    facts.append(fact)
            elif node.get("nodeType") == "UnaryOperation":
                fact = extract_update_from_unary_operation(node, storage, fn_name)
                if fact:
                    facts.append(fact)

    return facts


def group_update_facts_by_function(update_facts):
    grouped = {}
    for fact in update_facts:
        fn = fact.get("function")
        grouped.setdefault(fn, []).append(fact)
    return grouped

def normalize_delta_expr(delta: str):
    """
    Step 2.1 的轻量规范化：
    - 去空白
    - 去最外层括号
    """
    if delta is None:
        return ""
    s = str(delta).strip()
    while len(s) >= 2 and s[0] == "(" and s[-1] == ")":
        s = s[1:-1].strip()
    return s.replace(" ", "")

def same_delta_expr(d1: str, d2: str) -> bool:
    return normalize_delta_expr(d1) == normalize_delta_expr(d2)

def infer_accounting_invariants_from_updates(storage, update_facts, functions):
    """
    用 update facts 替代粗粒度 dfg 推断 accounting invariants

    当前规则（Step 2.1 + evidence aggregation）：
    - 在同一函数中
    - 存在 mapping(uint-like) 与 scalar(uint-like)
    - 二者执行相同方向更新(add/add 或 sub/sub)
    - 且 delta 表达式一致
    -> 推断二者存在会计守恒关系候选

    与旧版不同：
    - 不再只保留一个 via_function
    - 对同一 (mapping, supply) 聚合多条 evidence
    """
    invariants = []

    grouped = group_update_facts_by_function(update_facts)

    # 标量候选：uint/int 且非 mapping
    scalar_candidates = set()
    mapping_candidates = set()

    for name, meta in storage.items():
        if meta.get("is_mapping") and ("uint" in meta.get("type", "") or "int" in meta.get("type", "")):
            mapping_candidates.add(name)
        elif meta.get("is_uint") and not meta.get("is_mapping"):
            scalar_candidates.add(name)

    for fn_name, facts in grouped.items():
        mapping_updates = []
        scalar_updates = []

        for fact in facts:
            if fact.get("op") not in ["add", "sub"]:
                continue

            tgt = fact.get("target")
            if tgt in mapping_candidates and fact.get("target_kind") == "mapping":
                mapping_updates.append(fact)
            elif tgt in scalar_candidates and fact.get("target_kind") == "scalar":
                scalar_updates.append(fact)

        for mu in mapping_updates:
            for su in scalar_updates:
                # 同方向 + 同 delta，认为是高置信配对
                if mu.get("op") == su.get("op") and same_delta_expr(mu.get("delta"), su.get("delta")):
                    invariants.append({
                        "type": "accounting",
                        "mapping": mu["target"],
                        "supply": su["target"],
                        "via_function": fn_name,
                        "mapping_op": mu.get("op"),
                        "supply_op": su.get("op"),
                        "delta": mu.get("delta"),
                        "confidence": "high"
                    })
                    continue

                # 同方向但 delta 不同，先给 medium 候选
                if mu.get("op") == su.get("op"):
                    invariants.append({
                        "type": "accounting",
                        "mapping": mu["target"],
                        "supply": su["target"],
                        "via_function": fn_name,
                        "mapping_op": mu.get("op"),
                        "supply_op": su.get("op"),
                        "delta": f'{mu.get("delta")} | {su.get("delta")}',
                        "confidence": "medium",
                        "risk": "delta_mismatch",
                        "mapping_delta": mu.get("delta"),
                        "supply_delta": su.get("delta"),
                    })

    # -------- 聚合去重：保留同一 pair 的全部证据 --------
    uniq = {}

    for inv in invariants:
        key = (inv["mapping"], inv["supply"])

        if key not in uniq:
            uniq[key] = {
                "type": "accounting",
                "mapping": inv["mapping"],
                "supply": inv["supply"],

                # 保留一个兼容旧逻辑的代表性字段
                "via_function": inv["via_function"],
                "mapping_op": inv["mapping_op"],
                "supply_op": inv["supply_op"],
                "delta": inv["delta"],
                "confidence": inv["confidence"],

                # 新增：完整证据
                "evidence_functions": [inv["via_function"]],
                "evidence_pairs": [{
                    "function": inv["via_function"],
                    "mapping_op": inv["mapping_op"],
                    "supply_op": inv["supply_op"],
                    "delta": inv["delta"],
                    "confidence": inv["confidence"],
                    "risk": inv.get("risk"),
                    "mapping_delta": inv.get("mapping_delta"),
                    "supply_delta": inv.get("supply_delta"),
                }]
            }
        else:
            item = uniq[key]

            # 去重追加 function
            if inv["via_function"] not in item["evidence_functions"]:
                item["evidence_functions"].append(inv["via_function"])

            pair = {
                "function": inv["via_function"],
                "mapping_op": inv["mapping_op"],
                "supply_op": inv["supply_op"],
                "delta": inv["delta"],
                "confidence": inv["confidence"],
                "risk": inv.get("risk"),
                "mapping_delta": inv.get("mapping_delta"),
                "supply_delta": inv.get("supply_delta"),
            }

            if pair not in item["evidence_pairs"]:
                item["evidence_pairs"].append(pair)

            # 置信度升级
            old_score = 2 if item.get("confidence") == "high" else 1
            new_score = 2 if inv.get("confidence") == "high" else 1

            if new_score > old_score:
                item["via_function"] = inv["via_function"]
                item["mapping_op"] = inv["mapping_op"]
                item["supply_op"] = inv["supply_op"]
                item["delta"] = inv["delta"]
                item["confidence"] = inv["confidence"]

    filtered = []
    for inv in uniq.values():
        if inv["mapping"] == inv["supply"]:
            continue
        filtered.append(inv)

    return filtered

def infer_accounting_anomalies(storage, update_facts, accounting_invariants, functions):
    """
    基于已经识别出的 accounting pair，检测异常更新函数：
    - 某函数更新了 mapping，但没有同步更新对应 supply
    - 或某函数更新了 supply，但没有同步更新对应 mapping

    最小版本：
    - 只要某 pair 已经由其他函数建立为 accounting invariant
    - 某函数只触碰 pair 一侧，就报 anomaly

    输出示例：
    {
        "type": "accounting-anomaly",
        "mapping": "balances",
        "supply": "totalSupply",
        "function": "mint",
        "reason": "updates mapping but not paired supply",
        "mapping_updates": [...],
        "supply_updates": []
    }
    """
    anomalies = []

    grouped = group_update_facts_by_function(update_facts)

    # 已建立的会计关系
    pairs = []
    for inv in accounting_invariants:
        mapping_name = inv.get("mapping")
        supply_name = inv.get("supply")
        if not mapping_name or not supply_name:
            continue

        evidence_functions = set(inv.get("evidence_functions", []))
        if not evidence_functions and inv.get("via_function"):
            evidence_functions = {inv.get("via_function")}

        pairs.append({
            "mapping": mapping_name,
            "supply": supply_name,
            "evidence_functions": evidence_functions
        })

    for fn_name, facts in grouped.items():
        for pair in pairs:
            mapping_name = pair["mapping"]
            supply_name = pair["supply"]
            evidence_functions = pair["evidence_functions"]

            # 可选策略：证据函数不报 anomaly，避免 deposit/withdraw 被重复标记
            if fn_name in evidence_functions:
                continue

            mapping_hits = []
            supply_hits = []

            for fact in facts:
                if fact.get("target") == mapping_name and fact.get("target_kind") == "mapping":
                    mapping_hits.append(fact)
                elif fact.get("target") == supply_name and fact.get("target_kind") == "scalar":
                    supply_hits.append(fact)

            # transfer-like redistribution:
            # 同一 mapping 在一个函数里既有 add 又有 sub，且没有 supply 更新
            # 视为合法重分配，不报 anomaly
            if mapping_hits and not supply_hits:
                hit_ops = {x.get("op") for x in mapping_hits}
                if "add" in hit_ops and "sub" in hit_ops:
                    continue

                anomalies.append({
                    "type": "accounting-anomaly",
                    "mapping": mapping_name,
                    "supply": supply_name,
                    "function": fn_name,
                    "reason": "updates mapping but not paired supply",
                    "mapping_updates": mapping_hits,
                    "supply_updates": []
                })

            # 只更新 supply，不更新 mapping
            elif supply_hits and not mapping_hits:
                anomalies.append({
                    "type": "accounting-anomaly",
                    "mapping": mapping_name,
                    "supply": supply_name,
                    "function": fn_name,
                    "reason": "updates supply but not paired mapping",
                    "mapping_updates": [],
                    "supply_updates": supply_hits
                })

    # 去重
    uniq = {}
    for item in anomalies:
        key = (item["mapping"], item["supply"], item["function"], item["reason"])
        uniq[key] = item

    return list(uniq.values())

def analyze_cfg_paths(cfg):
    transitions = []
    edges = getattr(cfg, "edges", [])
    nodes = []
    # adjacency list
    if isinstance(edges, dict):
        for src, dst_list in edges.items():
            nodes.append(src)
            for dst in dst_list:
                transitions.append((src, dst))
    else:
        nodes = getattr(cfg, "vertices", None)
        if nodes is None:
            nodes = getattr(cfg, "nodes", [])
        for edge in edges:
            if isinstance(edge, (tuple, list)):
                if len(edge) >= 2:
                    transitions.append((edge[0], edge[1]))
            elif hasattr(edge, "src") and hasattr(edge, "dst"):
                transitions.append((edge.src, edge.dst))
    return {
        "nodes": len(nodes),
        "edges": len(transitions),
        "paths": transitions
    }


def infer_accounting_invariants(storage, dfg):
    mapping_candidates = []
    supply_candidates = []
    for name, meta in storage.items():
        if meta["is_mapping"] and "uint" in meta["type"]:
            mapping_candidates.append(name)
        if meta["is_uint"] and not meta["is_mapping"]:
            supply_candidates.append(name)
    invariants = []
    # DFG relation analysis
    for func, rw in dfg.items():
        writes = rw["writes"]
        for m in mapping_candidates:
            if m not in writes:
                continue
            for s in supply_candidates:
                if s not in writes:
                    continue
                invariants.append({
                    "type": "accounting",
                    "mapping": m,
                    "supply": s,
                    "via_function": func
                })
    # 去重
    uniq = {}
    for inv in invariants:
        key = (inv["mapping"], inv["supply"])
        uniq[key] = inv

    filtered = []
    for inv in uniq.values():
        if inv["mapping"] == inv["supply"]:
            continue
        filtered.append(inv)
    return filtered

def infer_cross_function_relations(dfg, functions):
    relations = []
    funcs = list(dfg.keys())

    # ---------- DFG based detection ----------
    for f1 in funcs:
        writes = dfg[f1]["writes"]
        if not writes:
            continue
        for f2 in funcs:
            if f1 == f2:
                continue
            reads = dfg[f2]["reads"]
            shared = writes.intersection(reads)
            if shared:
                relations.append({
                    "from": f1,
                    "to": f2,
                    "vars": list(shared),
                    "type": "dfg"
                })

    # ---------- semantic keyword detection ----------

    semantic_pairs = [
        ("deposit", "withdraw"),
        ("mint", "burn"),
        ("lock", "unlock"),
        ("pause", "unpause"),
        ("open", "close"),
        ("stake", "unstake"),
        ("add", "remove"),
        ("grant", "revoke"),
        ("enable", "disable"),
        ("create", "destroy")
    ]
    func_names = list(functions.keys())
    for f1 in func_names:
        name1 = f1.lower()
        for f2 in func_names:
            if f1 == f2:
                continue
            name2 = f2.lower()
            for a, b in semantic_pairs:
                if a in name1 and b in name2:
                    relations.append({
                        "from": f1,
                        "to": f2,
                        "vars": [],
                        "type": "semantic"
                    })
                if b in name1 and a in name2:
                    relations.append({
                        "from": f1,
                        "to": f2,
                        "vars": [],
                        "type": "semantic"
                    })

    # ---------- remove duplicates ----------
    uniq = {}
    for r in relations:
        key = (r["from"], r["to"])
        uniq[key] = r
    return list(uniq.values())

def is_state_like_name(name: str) -> bool:
    low = (name or "").lower()

    keywords = [
        "state", "phase", "status",
        "stage", "step", "mode",
        "round", "epoch",
        "paused", "pause",
        "closed", "close",
        "finalized", "finalise", "finalized",
        "initialized", "initialised", "init",
        "active", "enabled", "disabled",
        "open"
    ]

    return any(k in low for k in keywords)


def infer_state_kind_from_type(type_str: str) -> str:
    t = (type_str or "").lower().strip()

    if "enum " in t:
        return "enum"
    if t == "bool":
        return "bool"
    if t.startswith("uint") or t.startswith("int"):
        return "uint"
    return "unknown"


def state_rhs_to_value(rhs):
    """
    从状态赋值右值中恢复目标值
    支持:
    - enum member: Phase.Closed -> Closed
    - bool literal: true / false
    - uint literal: 0 / 1 / 2 ...
    - fallback: expr string
    """
    if not isinstance(rhs, dict):
        return None

    nt = rhs.get("nodeType", "")

    if nt == "MemberAccess":
        return rhs.get("memberName")

    if nt == "Literal":
        val = rhs.get("value")
        if val is not None:
            return str(val)

    if nt == "Identifier":
        return rhs.get("name")

    # 其它复杂表达式先退化为字符串
    s = expr_to_str(rhs)
    return s if s else None


def state_assignment_matches_var(lhs, state_var_name):
    if not isinstance(lhs, dict):
        return False
    return lhs.get("nodeType") == "Identifier" and lhs.get("name") == state_var_name


def extract_guard_exprs_from_function(fn):
    """
    轻量提取函数中的 guard-like 条件表达式
    主要抓:
    - require(...)
    - assert(...)
    - if (...)
    返回字符串列表
    """
    guards = []

    for node in walk_ast(fn):
        nt = node.get("nodeType", "")

        if nt == "FunctionCall":
            call_name = function_call_name(node).lower()
            if call_name in ["require", "assert"]:
                args = node.get("arguments", [])
                if args:
                    guards.append(expr_to_str(args[0]))

        elif nt == "IfStatement":
            cond = node.get("condition", {})
            if cond:
                guards.append(expr_to_str(cond))

    # 去重且去空
    guards = [g for g in guards if g]
    return list(dict.fromkeys(guards))


def find_state_related_guards(guard_exprs, state_var_name):
    """
    从 guard 列表中过滤出与特定状态变量相关的 guard
    """
    low_name = (state_var_name or "").lower()
    out = []

    for g in guard_exprs:
        low = (g or "").lower()
        if low_name in low:
            out.append(g)

    return list(dict.fromkeys(out))


def infer_from_candidates_from_guards(state_var_name, state_kind, guard_exprs, enum_values=None):
    """
    根据 guard 条件恢复 from-candidates
    轻量版:
    - enum: 如果 guard 里出现某个 enum value 名，认为是 from candidate
    - bool: 如果 guard 里出现 stateVar / !stateVar / == true/false，则推断
    - uint: 如果 guard 里出现 stateVar == 常量，提取常量
    """
    enum_values = enum_values or []
    out = []
    low_name = (state_var_name or "").lower()

    for g in guard_exprs:
        gl = (g or "").lower()

        if state_kind == "enum":
            for ev in enum_values:
                if ev.lower() in gl and ev not in out:
                    out.append(ev)

        elif state_kind == "bool":
            # paused
            if f"!{low_name}" in gl or f"(!{low_name})" in gl:
                if "false" not in out:
                    out.append("false")
            if low_name in gl and f"!{low_name}" not in gl:
                # stateVar 作为条件出现，偏向 true
                if "true" not in out:
                    out.append("true")
            if f"{low_name} == true" in gl or f"true == {low_name}" in gl:
                if "true" not in out:
                    out.append("true")
            if f"{low_name} == false" in gl or f"false == {low_name}" in gl:
                if "false" not in out:
                    out.append("false")

        elif state_kind == "uint":
            # 很轻量地抓 "stage == 1"
            patterns = [
                f"{low_name} == ",
                f"== {low_name}"
            ]
            if patterns[0] in gl:
                tail = gl.split(patterns[0], 1)[1].strip()
                token = tail.split()[0].strip("()")
                if token.isdigit() and token not in out:
                    out.append(token)

    return out

def infer_bool_terminal_candidates(state_var_name, transition_facts):
    """
    基于 bool 状态转移 + 函数名，推断 true/false 是否偏终态

    修正版：
    - 如果同一 bool 状态变量同时能被置为 true 和 false，
      默认视为 toggle state，不判定 terminal
    - 只有单向收敛时才判定为 terminal
    """
    true_terminal_score = 0
    false_terminal_score = 0

    seen_true = False
    seen_false = False

    for fact in transition_facts:
        if fact.get("state_var") != state_var_name:
            continue
        if fact.get("state_kind") != "bool":
            continue

        fn = (fact.get("function") or "").lower()
        to_val = str(fact.get("to", "")).lower()

        if to_val == "true":
            seen_true = True

            if any(k in fn for k in ["pause", "close", "final", "disable", "lock", "terminate"]):
                true_terminal_score += 2
            elif any(k in fn for k in ["init", "initialize"]):
                true_terminal_score += 1

        elif to_val == "false":
            seen_false = True

            if any(k in fn for k in ["unpause", "open", "enable", "unlock", "reset"]):
                false_terminal_score += 1

    # -------- 关键修正：同时存在 true/false 写入 => toggle，不视为 terminal --------
    if seen_true and seen_false:
        return {
            "bool_true_terminal": False,
            "bool_false_terminal": False,
        }
    
    true_term = (true_terminal_score >= 2)
    false_term = (false_terminal_score >= 2)

    # 如果 true / false 两边都像“终态”，更可能其实是可逆开关，不应判为 terminal
    if true_term and false_term:
        true_term = False
        false_term = False

    return {
        "bool_true_terminal": true_term,
        "bool_false_terminal": false_term,
    }

def infer_uint_monotonicity(transition_facts, state_var_name):
    vals = []
    relative_adds = []

    for fact in transition_facts:
        if fact.get("state_var") != state_var_name:
            continue
        if fact.get("state_kind") != "uint":
            continue

        if fact.get("transition_kind") == "relative":
            if fact.get("op") == "add":
                d = str(fact.get("delta", "")).strip()
                if d.isdigit():
                    relative_adds.append(int(d))

        else:
            to_v = str(fact.get("to", "")).strip()
            if to_v.isdigit():
                vals.append(int(to_v))

    # 只要出现相对 add 常数，就可视为 monotonic 候选
    if relative_adds:
        return True

    vals = sorted(set(vals))
    if len(vals) < 2:
        return False

    return vals == list(range(min(vals), max(vals) + 1))

def collect_transition_functions_from_summaries(state_var, functions, summaries):
    """
    从 Step3.1-B 的 summary 中恢复“哪些 externally callable 函数最终会修改 state_var”
    例如:
      activate -> _activate -> phase = Active
    则把 activate 识别为 transition function
    """
    out = []

    for fn_name, fn in functions.items():
        if not is_externally_callable_function(fn):
            continue
        if fn.get("stateMutability") in ["view", "pure"]:
            continue

        info = summaries.get(fn_name, {})
        for u in info.get("updates", []):
            if u.get("target") == state_var:
                out.append(fn_name)
                break

    return list(dict.fromkeys(out))

def infer_state_machine(ast, cfg, flattened=None, summaries=None):
    """
    Step 2.3 + Step3.1-A/B:
    - 若提供 flattened/summaries，则优先基于继承展开视图恢复状态机
    - 否则回退到原始 contract AST 扫描
    """
    summaries = summaries or {}

    if flattened is not None:
        storage_view = flattened.get("storage", {})
        enums = flattened.get("enums", {})
        functions_view = flattened.get("functions", {})
    else:
        storage_view = extract_storage_variables(ast)
        enums = extract_enums(ast)
        functions_view = extract_functions(ast)

    state_details = {}
    transition_facts = []
    states = []
    transitions = []

    # -------------------------------
    # 第一轮：从 flattened storage 中识别状态变量
    # -------------------------------
    for name, meta in storage_view.items():
        typ = meta.get("type", "")
        state_kind = infer_state_kind_from_type(typ)

        if not (is_state_like_name(name) or state_kind in ["enum", "bool"]):
            continue

        enum_name = None
        enum_values = []

        if state_kind == "enum" and "enum " in typ:
            enum_name = typ.split("enum ", 1)[1].split(".")[-1].strip()
            if enum_name in enums:
                enum_values = enums[enum_name]

        state_details[name] = {
            "type": typ,
            "state_kind": state_kind,
            "enum_name": enum_name,
            "enum_values": enum_values,
            "initial_candidates": [],
            "terminal_candidates": [],
            "transition_functions": [],
            "bool_true_terminal": False,
            "bool_false_terminal": False,
            "is_monotonic_uint_candidate": False,
        }

    # -------------------------------
    # 第二轮：优先用 summaries 恢复 transition facts
    # -------------------------------
    if summaries:

        for fn_name, info in summaries.items():
            hints = info.get("transition_hints", []) or []

            if hints:
                for fact in hints:
                    state_var = fact.get("state_var")
                    if state_var not in state_details:
                        continue

                    transition_facts.append(fact)

                    if fact.get("transition_kind") == "absolute":
                        transitions.append((state_var, fact.get("to")))

                    states.append(state_var)
                continue

            # fallback: 老逻辑
            guard_exprs_all = info.get("guard_exprs", []) or []

            if not guard_exprs_all:
                fn_node = functions_view.get(fn_name)
                if fn_node:
                    guard_exprs_all = extract_guard_exprs_from_function(fn_node)

            for u in info.get("updates", []):
                state_var = u.get("target")
                if state_var not in state_details:
                    continue

                detail = state_details[state_var]
                state_kind = detail.get("state_kind", "unknown")
                enum_values = detail.get("enum_values", [])

                related_guards = find_state_related_guards(guard_exprs_all, state_var)

                fact = build_transition_fact_from_update(
                    state_var=state_var,
                    state_kind=state_kind,
                    fn_name=fn_name,
                    update_fact=u,
                    guard_exprs=related_guards,
                    enum_values=enum_values
                )

                transition_facts.append(fact)

                # 只对 absolute transition 保留旧 transitions 兼容视图
                if fact.get("transition_kind") == "absolute":
                    transitions.append((state_var, fact.get("to")))

                states.append(state_var)

        # externally callable 的入口函数重建
        for s in state_details.keys():
            state_details[s]["transition_functions"] = collect_transition_functions_from_summaries(
                state_var=s,
                functions=functions_view,
                summaries=summaries
            )

            if state_details[s]["transition_functions"] and s not in states:
                states.append(s)

    else:
        # -------------------------------
        # 回退：使用原始 AST 扫描
        # -------------------------------
        for node in walk_ast(ast):
            if node.get("nodeType") != "FunctionDefinition":
                continue

            kind = node.get("kind", "")
            if kind == "constructor":
                continue

            fn_name = node.get("name")
            if not fn_name:
                if kind == "receive":
                    fn_name = "__receive__"
                elif kind == "fallback":
                    fn_name = "__fallback__"
                else:
                    fn_name = ""

            guard_exprs_all = extract_guard_exprs_from_function(node)

            for sub in walk_ast(node):
                if sub.get("nodeType") != "Assignment":
                    continue

                lhs = sub.get("leftHandSide", {})
                if lhs.get("nodeType") != "Identifier":
                    continue

                state_var = lhs.get("name", "")
                if state_var not in state_details:
                    continue

                rhs = sub.get("rightHandSide", {})
                state_kind = state_details[state_var].get("state_kind", "unknown")
                enum_values = state_details[state_var].get("enum_values", [])

                to_value = state_rhs_to_value(rhs)
                related_guards = find_state_related_guards(guard_exprs_all, state_var)
                from_candidates = infer_from_candidates_from_guards(
                    state_var_name=state_var,
                    state_kind=state_kind,
                    guard_exprs=related_guards,
                    enum_values=enum_values
                )

                fact = {
                    "state_var": state_var,
                    "state_kind": state_kind,
                    "function": fn_name,
                    "from_candidates": from_candidates,
                    "to": to_value,
                    "guard_exprs": related_guards,
                    "raw": expr_to_str(sub)
                }

                transition_facts.append(fact)
                transitions.append((state_var, to_value))
                states.append(state_var)

                if fn_name and fn_name not in state_details[state_var]["transition_functions"]:
                    state_details[state_var]["transition_functions"].append(fn_name)

    # 去重
    states = list(dict.fromkeys(states))
    transitions = list(dict.fromkeys(transitions))

    uniq_tf = {}
    for tf in transition_facts:
        key = (
            tf.get("state_var"),
            tf.get("function"),
            str(tf.get("to")),
            tuple(tf.get("from_candidates", [])),
            tuple(tf.get("guard_exprs", [])),
            tf.get("raw")
        )
        uniq_tf[key] = tf
    transition_facts = list(uniq_tf.values())

    # -------------------------------
    # 第三轮：推断初态 / 终态 / 单调性
    # -------------------------------
    for s in state_details.keys():
        detail = state_details[s]
        state_kind = detail.get("state_kind", "unknown")
        enum_values = detail.get("enum_values", [])

        initial_candidates = []
        terminal_candidates = []

        if state_kind == "enum":
            if not enum_values and len(enums) == 1:
                enum_name = list(enums.keys())[0]
                enum_values = enums[enum_name]
                detail["enum_name"] = enum_name
                detail["enum_values"] = enum_values

            for idx, val in enumerate(enum_values):
                low = val.lower()

                if idx == 0 or any(k in low for k in ["init", "initial", "open", "unset", "pending"]):
                    if val not in initial_candidates:
                        initial_candidates.append(val)

                if any(k in low for k in ["closed", "close", "ended", "final", "done", "finished", "terminated"]):
                    if val not in terminal_candidates:
                        terminal_candidates.append(val)

        elif state_kind == "bool":
            initial_candidates.append("false")

            bool_term = infer_bool_terminal_candidates(s, transition_facts)
            detail["bool_true_terminal"] = bool_term["bool_true_terminal"]
            detail["bool_false_terminal"] = bool_term["bool_false_terminal"]

            if detail["bool_true_terminal"]:
                terminal_candidates.append("true")
            if detail["bool_false_terminal"]:
                terminal_candidates.append("false")

        elif state_kind == "uint":
            initial_candidates.append("0")
            detail["is_monotonic_uint_candidate"] = infer_uint_monotonicity(transition_facts, s)

            for tf in transition_facts:
                if tf.get("state_var") != s:
                    continue
                to_v = str(tf.get("to", "")).strip()
                fn_low = (tf.get("function") or "").lower()
                guard_low = " ".join(tf.get("guard_exprs", [])).lower()

                if to_v.isdigit():
                    if any(k in fn_low for k in ["close", "final", "finish", "terminate", "end"]) or \
                       any(k in guard_low for k in ["close", "final", "finish", "terminate", "end"]):
                        if to_v not in terminal_candidates:
                            terminal_candidates.append(to_v)

        detail["initial_candidates"] = initial_candidates
        detail["terminal_candidates"] = terminal_candidates

    return {
        "states": states,
        "transitions": transitions,
        "transition_facts": transition_facts,
        "enums": enums,
        "details": state_details
    }

def is_externally_callable_function(fn):
    """
    只把 public / external / receive / fallback 视为可直接从外部攻击者触达，
    避免 internal/private 函数进入 access invariant 生成，造成编译或语义问题。
    """
    visibility = fn.get("visibility", "")
    kind = fn.get("kind", "")
    if visibility in ["public", "external"]:
        return True
    if kind in ["receive", "fallback"]:
        return True
    return False


def extract_written_storage_targets(function_node, storage):
    """
    提取函数中被写入的 storage 变量名（不限于 += / -=）
    用于识别 owner / admin / paused / state 等敏感写入。
    """
    targets = []

    for node in walk_ast(function_node):
        if node.get("nodeType") != "Assignment":
            continue

        lhs = node.get("leftHandSide", {})
        info = parse_storage_lvalue(lhs, storage)
        if info:
            targets.append(info.get("target"))

    # 去重并保持顺序
    return list(dict.fromkeys([x for x in targets if x]))


def function_call_name(call_node):
    """
    提取 FunctionCall 的调用名，兼容:
    - require(...)
    - hasRole(...)
    - authority.canCall(...)
    - _checkOwner()
    """
    if not isinstance(call_node, dict):
        return ""

    if call_node.get("nodeType") != "FunctionCall":
        return ""

    expr = call_node.get("expression", {})

    if expr.get("nodeType") == "Identifier":
        return expr.get("name", "")

    if expr.get("nodeType") == "MemberAccess":
        base = expr_to_str(expr.get("expression", {}))
        member = expr.get("memberName", "")
        if base:
            return f"{base}.{member}"
        return member

    return expr_to_str(expr)


def expr_contains_msg_sender(node):
    """
    判断任意表达式子树中是否出现 msg.sender
    """
    for sub in walk_ast(node):
        if sub.get("nodeType") == "MemberAccess" and sub.get("memberName") == "sender":
            exp = sub.get("expression", {})
            if exp.get("nodeType") == "Identifier" and exp.get("name") == "msg":
                return True
    return False


def node_contains_guard_keyword(node, keywords):
    """
    轻量关键字匹配：看表达式字符串中是否出现 guard 相关关键词
    """
    s = expr_to_str(node).lower()
    return any(k in s for k in keywords)


def dedup_dict_list(items, key_fields):
    uniq = {}
    for item in items:
        key = tuple(item.get(k) for k in key_fields)
        uniq[key] = item
    return list(uniq.values())

def find_matched_keywords(text, keywords):
    """
    返回 text 中命中的所有 keyword，按出现顺序去重
    """
    s = (text or "").lower()
    matched = []

    for kw in keywords:
        if kw in s and kw not in matched:
            matched.append(kw)

    return matched

def is_asset_related_storage_name(name: str) -> bool:
    """
    轻量判断某个 storage 名是否像资产/账本相关变量
    """
    low = (name or "").lower()

    keywords = [
        "balance", "balances",
        "supply", "totalsupply",
        "share", "shares",
        "debt", "rewarddebt",
        "stake", "stakes",
        "vault", "asset", "assets",
        "collateral", "liquidity",
        "deposit", "escrow"
    ]

    return any(k in low for k in keywords)


def function_has_asset_accounting_impact(fn_name, writes, update_facts_for_fn):
    """
    收窄版：
    只把“特权型资产操作”视为 access-sensitive 的资产影响证据，
    避免把普通开放业务函数（deposit/withdraw/claim/transfer）误判为 access anomaly。

    当前保留：
    - mint
    - burn
    - seize
    - rescue
    - sweep

    注意：
    - 这里只服务于 Step 2.2 的 access-sensitive 检测
    - 不等价于“所有资产相关函数”检测
    """
    name_low = (fn_name or "").lower()

    # 只保留特权资产操作，避免误把普通业务函数拉入 access 分析
    privileged_asset_action_keywords = [
        "mint",
        "burn",
        "seize",
        "rescue",
        "sweep"
    ]

    matched_action_keywords = find_matched_keywords(name_low, privileged_asset_action_keywords)

    # 只有名称已经像“特权资产操作”时，才进一步把资产 storage/update 作为增强理由
    # 避免 deposit / withdraw / transferOwnership 之类因为写 balance / 包含 transfer 而被误报
    asset_write_targets = []
    asset_update_targets = []

    if matched_action_keywords:
        for w in writes or []:
            if is_asset_related_storage_name(w):
                asset_write_targets.append(w)

        for fact in update_facts_for_fn or []:
            tgt = fact.get("target")
            if tgt and is_asset_related_storage_name(tgt):
                asset_update_targets.append(tgt)

    asset_write_targets = list(dict.fromkeys(asset_write_targets))
    asset_update_targets = list(dict.fromkeys(asset_update_targets))

    has_impact = bool(matched_action_keywords or asset_write_targets or asset_update_targets)

    return {
        "has_impact": has_impact,
        "matched_action_keywords": matched_action_keywords,
        "asset_write_targets": asset_write_targets,
        "asset_update_targets": asset_update_targets,
    }

def infer_sensitive_functions(functions, storage, update_facts, state_machine):
    """
    识别“敏感函数”：
    - 函数名语义敏感
    - 写 critical storage
    - 写状态机变量
    - 发生关键权限/配置变更

    只把 externally callable 的函数作为 access 检测主对象。
    """
    sensitive_name_keywords = [
        "owner", "admin", "role", "gov", "operator", "auth",
        "mint", "burn", "pause", "unpause",
        "upgrade", "initialize", "init",
        "grant", "revoke",
        "whitelist", "blacklist",
        "rescue", "sweep", "emergency",
        "setfee", "set_fee", "setoracle", "set_oracle",
        "settreasury", "set_treasury",
        "transferownership", "renounceownership"
    ]

    critical_storage_keywords = [
        "owner", "admin", "role", "gov", "operator", "auth",
        "implementation", "impl", "beacon",
        "treasury", "oracle", "fee",
        "pause", "paused",
        "guardian", "minter",
        "state", "phase", "status"
    ]

    update_grouped = group_update_facts_by_function(update_facts)
    state_vars = set(state_machine.get("states", []))

    results = []

    for fn_name, fn in functions.items():
        if not is_externally_callable_function(fn):
            continue

        if fn.get("stateMutability") in ["view", "pure"]:
            continue

        reasons = []
        writes = []

        name_low = (fn_name or "").lower()
        sig = build_function_signature(fn)

        # 1) 名称敏感
        matched_name_keywords = find_matched_keywords(name_low, sensitive_name_keywords)
        for kw in matched_name_keywords:
            reasons.append(f"name matches sensitive keyword: {kw}")

        # 2) summary/update facts 作为主写集（可覆盖 internal helper 冒泡后的 effect）
        for fact in update_grouped.get(fn_name, []):
            tgt = fact.get("target")
            if tgt:
                writes.append(tgt)

        # 3) 再补 AST 本体直接写
        written_targets = extract_written_storage_targets(fn, storage)
        writes.extend(written_targets)

        writes = list(dict.fromkeys(writes))

        for tgt in writes:
            low = (tgt or "").lower()
            meta = storage.get(tgt, {})

            if tgt in state_vars:
                reasons.append(f"writes state variable: {tgt}")

            if any(k in low for k in critical_storage_keywords):
                reasons.append(f"writes critical storage: {tgt}")

            # 某些 address 类型配置变量改动也视为敏感
            if meta.get("is_address") and any(k in low for k in [
                "owner", "admin", "treasury", "oracle", "implementation", "impl", "beacon", "guardian"
            ]):
                reasons.append(f"writes critical address storage: {tgt}")

        # 4) 资产/账本影响型敏感理由（仅作为增强理由，不单独触发普通业务函数进入 sensitive）
        asset_impact = function_has_asset_accounting_impact(
            fn_name=fn_name,
            writes=writes,
            update_facts_for_fn=update_grouped.get(fn_name, [])
        )

        # 只有当已经有其它敏感依据，或者命中了特权资产动作词时，才追加资产理由
        if reasons or asset_impact["matched_action_keywords"]:
            for kw in asset_impact["matched_action_keywords"]:
                reasons.append(f"name matches asset-sensitive keyword: {kw}")

            for tgt in asset_impact["asset_write_targets"]:
                reasons.append(f"writes asset-related storage: {tgt}")

            for tgt in asset_impact["asset_update_targets"]:
                reasons.append(f"updates asset-related storage: {tgt}")

        # 去重
        reasons = list(dict.fromkeys(reasons))

        if reasons:
            results.append({
                "name": fn_name,
                "signature": sig,
                "visibility": fn.get("visibility", ""),
                "stateMutability": fn.get("stateMutability", ""),
                "reasons": reasons,
                "writes": writes,
                "matched_name_keywords": matched_name_keywords,
                "matched_asset_keywords": asset_impact.get("matched_action_keywords", []),
                "asset_write_targets": asset_impact.get("asset_write_targets", []),
                "asset_update_targets": asset_impact.get("asset_update_targets", []),
                "externally_callable": True
            })

    return results
    


def infer_guard_facts(functions, storage, summaries=None):

    summaries = summaries or {}
    """
    识别 guard 证据：
    - modifier-based guard
    - require/assert + msg.sender + owner/admin/role/auth/... 关键词
    - hasRole / canCall / isAuthorized / _checkOwner / _authorizeUpgrade 等 helper/call
    - roles[msg.sender] / admins[msg.sender] 这类索引访问
    """
    guard_modifier_keywords = [
        "onlyowner", "onlyadmin", "onlyrole", "onlygov", "onlygovernance",
        "onlyoperator", "onlyauth", "authorized", "auth", "governance",
        "admin", "owner", "role", "operator", "guardian"
    ]

    guard_expr_keywords = [
        "owner", "admin", "role", "gov", "governance",
        "operator", "auth", "authorized", "guardian",
        "permission", "authority", "cancall", "isauthorized"
    ]

    guard_call_keywords = [
        "hasrole", "checkrole", "_checkrole",
        "_checkowner", "owner", "_authorizeupgrade",
        "cancall", "isauthorized", "_isauthorized",
        "_onlyowner", "_onlyadmin", "_onlygov", "_onlyoperator",
        "authorize", "authority"
    ]

    facts = []

    for fn_name, fn in functions.items():
        if not is_externally_callable_function(fn):
            continue

        sig = build_function_signature(fn)

        # -------- 0) summary propagated guards --------
        summary_info = summaries.get(fn_name, {})
        for g in summary_info.get("guard_exprs", []) or []:
            gl = str(g).lower()

            summary_guard_hit = (
                any(k in gl for k in guard_expr_keywords)
                or "caller()" in gl
                or "msg.sender" in gl
                or "_msgsender" in gl
                or "iszero" in gl
                or "paused" in gl
                or "owner" in gl
            )

            if summary_guard_hit:
                facts.append({
                    "function": fn_name,
                    "signature": sig,
                    "kind": "summary-guard-expr",
                    "evidence": g
                })

        # -------- 1) modifier guard --------
        for m in fn.get("modifiers", []):
            mod_name = m.get("modifierName", {}).get("name", "")
            mod_low = mod_name.lower()

            if any(k in mod_low for k in guard_modifier_keywords):
                facts.append({
                    "function": fn_name,
                    "signature": sig,
                    "kind": "modifier-guard",
                    "evidence": mod_name
                })

        # -------- 2) require/assert with guard semantics --------
        for node in walk_ast(fn):
            nt = node.get("nodeType", "")

            # 2.1 require/assert(...) 中出现 msg.sender + guard 关键词
            if nt == "FunctionCall":
                call_name = function_call_name(node).lower()
                raw = expr_to_str(node)

                if any(k in call_name for k in guard_call_keywords):
                    facts.append({
                        "function": fn_name,
                        "signature": sig,
                        "kind": "guard-call",
                        "evidence": raw
                    })

                elif call_name in ["require", "assert"]:
                    if expr_contains_msg_sender(node) and node_contains_guard_keyword(node, guard_expr_keywords):
                        facts.append({
                            "function": fn_name,
                            "signature": sig,
                            "kind": "require-msgsender-guard",
                            "evidence": raw
                        })
                    elif node_contains_guard_keyword(node, [
                        "hasrole", "checkrole", "cancall", "isauthorized", "_checkowner", "_authorizeupgrade"
                    ]):
                        facts.append({
                            "function": fn_name,
                            "signature": sig,
                            "kind": "require-auth-helper",
                            "evidence": raw
                        })

            # 2.2 msg.sender == owner/admin/... 这类二元比较
            elif nt == "BinaryOperation":
                op = node.get("operator", "")
                if op in ["==", "!="]:
                    left = node.get("leftExpression", {})
                    right = node.get("rightExpression", {})

                    left_has_sender = expr_contains_msg_sender(left)
                    right_has_sender = expr_contains_msg_sender(right)

                    if left_has_sender or right_has_sender:
                        other = right if left_has_sender else left
                        if node_contains_guard_keyword(other, guard_expr_keywords):
                            facts.append({
                                "function": fn_name,
                                "signature": sig,
                                "kind": "msgsender-binary-guard",
                                "evidence": expr_to_str(node)
                            })

            # 2.3 roles[msg.sender] / admins[msg.sender]
            elif nt == "IndexAccess":
                base = expr_to_str(node.get("baseExpression", {})).lower()
                idx = node.get("indexExpression", {})
                if expr_contains_msg_sender(idx) and any(k in base for k in [
                    "role", "admin", "owner", "auth", "operator", "guardian", "whitelist", "permission"
                ]):
                    facts.append({
                        "function": fn_name,
                        "signature": sig,
                        "kind": "role-index-guard",
                        "evidence": expr_to_str(node)
                    })

    facts = dedup_dict_list(facts, ["function", "kind", "evidence"])
    return facts


def infer_access_control_v2(functions, storage, update_facts, state_machine, summaries=None):
    """
    Step 2.2:
    access = sensitive functions ∩ guarded functions
    同时输出:
    - sensitive_functions
    - guard_facts
    - access_anomalies (敏感但无 guard)
    """
    sensitive_functions = infer_sensitive_functions(
        functions=functions,
        storage=storage,
        update_facts=update_facts,
        state_machine=state_machine
    )

    guard_facts = infer_guard_facts(
        functions=functions,
        storage=storage,
        summaries=summaries
    )

    guards_by_function = {}
    for g in guard_facts:
        guards_by_function.setdefault(g["function"], []).append(g)

    protected_sensitive = []
    access_anomalies = []

    for item in sensitive_functions:
        fn_name = item["name"]
        sig = item["signature"]
        fn_guards = guards_by_function.get(fn_name, [])

        if fn_guards:
            protected_sensitive.append({
                # 保持与旧 generator 兼容的关键字段
                "name": fn_name,
                "signature": sig,

                # Step 2.2 新增解释性字段
                "reasons": item.get("reasons", []),
                "guard_kinds": [g.get("kind") for g in fn_guards],
                "guard_evidence": [g.get("evidence") for g in fn_guards],
                "writes": item.get("writes", []),
            })
        else:
            access_anomalies.append({
                "name": fn_name,
                "signature": sig,
                "reasons": item.get("reasons", []),
                "writes": item.get("writes", []),
                "type": "unguarded-sensitive-function"
            })

    protected_sensitive = dedup_dict_list(protected_sensitive, ["name", "signature"])
    access_anomalies = dedup_dict_list(access_anomalies, ["name", "signature"])

    return {
        "access": protected_sensitive,
        "sensitive_functions": sensitive_functions,
        "guard_facts": guard_facts,
        "access_anomalies": access_anomalies,
    }


def infer_access_control(functions, storage=None, update_facts=None, state_machine=None):
    """
    向后兼容 wrapper：
    - 若提供了 Step 2.2 所需上下文，则走 v2
    - 否则退回旧逻辑的简化近似
    """
    if storage is not None and update_facts is not None and state_machine is not None:
        return infer_access_control_v2(
            functions=functions,
            storage=storage,
            update_facts=update_facts,
            state_machine=state_machine
        )["access"]

    # fallback: 兼容旧调用
    protected = []

    keywords = [
        "owner",
        "admin",
        "role",
        "gov",
        "operator",
        "auth"
    ]

    for name, f in functions.items():
        if not is_externally_callable_function(f):
            continue

        sig = build_function_signature(f)

        for m in f.get("modifiers", []):
            mod_name = m.get("modifierName", {}).get("name", "").lower()
            if any(k in mod_name for k in keywords):
                protected.append({
                    "name": name,
                    "signature": sig
                })
                break

        for node in walk_ast(f):
            if node.get("nodeType") == "BinaryOperation":
                left = node.get("leftExpression", {})
                right = node.get("rightExpression", {})
                if expr_contains_msg_sender(left) or expr_contains_msg_sender(right):
                    other = right if expr_contains_msg_sender(left) else left
                    if node_contains_guard_keyword(other, keywords):
                        protected.append({
                            "name": name,
                            "signature": sig
                        })
                        break

    uniq = {}
    for p in protected:
        uniq[p["name"]] = p

    return list(uniq.values())

def build_function_signature(fn):
    name = fn.get("name")
    params = fn.get("parameters", {}).get("parameters", [])
    types = []
    for p in params:
        typ = p.get("typeDescriptions", {}).get("typeString", "")
        types.append(_canonical_abi_type(typ, p.get("typeDescriptions", {}).get("typeIdentifier", "")))
    return name + "(" + ",".join(types) + ")"


def _canonical_abi_type(type_string, type_identifier=""):
    """Normalize a Solidity AST type string to its canonical ABI spelling."""
    typ = (type_string or "").strip()
    typ = re.sub(r"\s+(memory|storage|calldata)(\s+ref)?$", "", typ)
    typ = typ.replace(" payable", "")
    # Contract and interface values are encoded as addresses in the ABI.
    typ = re.sub(r"\b(contract|interface)\s+[A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*)*", "address", typ)
    # Enum ABI representation is the compiler-selected uint width. The AST
    # identifier carries it in modern solc; uint8 is the Solidity default.
    if typ.startswith("enum "):
        match = re.search(r"_([0-9]+)$", type_identifier or "")
        typ = "uint" + (match.group(1) if match else "8")
    typ = re.sub(r"\buint\b", "uint256", typ)
    typ = re.sub(r"\bint\b", "int256", typ)
    # ABI tuples require component metadata, which is available in ABI entries;
    # leave AST tuple/struct strings recognizable but avoid hashing a bad alias.
    return typ


def _abi_parameter_type(parameter):
    """Return a canonical selector type from a compiler ABI parameter."""
    typ = str((parameter or {}).get("type", ""))
    if not typ.startswith("tuple"):
        return typ
    suffix = typ[len("tuple"):]
    components = (parameter or {}).get("components", []) or []
    return "(" + ",".join(_abi_parameter_type(item) for item in components) + ")" + suffix


def _uir_jsonable(obj):
    if isinstance(obj, dict):
        return {str(k): _uir_jsonable(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_uir_jsonable(x) for x in obj]
    if isinstance(obj, tuple):
        return [_uir_jsonable(x) for x in obj]
    if isinstance(obj, set):
        return sorted([_uir_jsonable(x) for x in obj], key=lambda x: str(x))
    return obj


def _uir_selector_for_signature(signature):
    if not signature or signature in ("receive", "fallback"):
        return signature
    if _eth_keccak is None:
        return None
    try:
        return "0x" + _eth_keccak(text=signature)[:4].hex()
    except Exception:
        return None


def _uir_add_unique(container, key, value):
    if value is None or value == "":
        return
    container.setdefault(key, [])
    if value not in container[key]:
        container[key].append(value)


def _uir_function_key(item):
    if not isinstance(item, dict):
        return None, None
    name = item.get("name") or item.get("function") or item.get("from") or item.get("source")
    signature = item.get("signature")
    return name, signature


def _uir_collect_strings(obj, keys):
    out = []
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key in keys:
                if isinstance(value, str):
                    out.append(value)
                elif isinstance(value, list):
                    for item in value:
                        if isinstance(item, str):
                            out.append(item)
                        else:
                            out.extend(_uir_collect_strings(item, keys))
                else:
                    out.extend(_uir_collect_strings(value, keys))
            else:
                out.extend(_uir_collect_strings(value, keys))
    elif isinstance(obj, list):
        for value in obj:
            out.extend(_uir_collect_strings(value, keys))
    return out


def build_uir_fuzzing_targets(functions,
                              storage,
                              dfg,
                              update_facts,
                              accounting,
                              state_machine,
                              transition_facts,
                              access,
                              sensitive_functions,
                              guard_facts,
                              access_anomalies,
                              cross_relations,
                              accounting_anomalies,
                              abi=None):
    """
    Build a side-channel UIR target map for later coverage-preserving semantic
    fuzzing. This function only normalizes existing static/UIR facts; it does
    not change analysis results or fuzzing behavior.
    """
    functions = functions or {}
    storage = storage or {}
    dfg = dfg or {}
    update_facts = update_facts or []
    accounting = accounting or []
    state_machine = state_machine or {}
    transition_facts = transition_facts or []
    access = access or []
    sensitive_functions = sensitive_functions or []
    guard_facts = guard_facts or []
    access_anomalies = access_anomalies or []
    cross_relations = cross_relations or []
    accounting_anomalies = accounting_anomalies or []

    name_to_selectors = {}
    signature_to_selector = {}
    functions_by_selector = {}
    abi_function_selectors = set()
    for item in abi or []:
        if isinstance(item, dict) and item.get("type") == "function" and item.get("name"):
            inputs = item.get("inputs", []) or []
            sig = f"{item['name']}({','.join(_abi_parameter_type(x) for x in inputs)})"
            sel = _uir_selector_for_signature(sig)
            if sel:
                abi_function_selectors.add(sel)

    for fn_name, fn in functions.items():
        kind = fn.get("kind", "")
        if kind == "constructor":
            continue
        if kind in ("receive", "fallback"):
            signature = kind
            selector = kind
        else:
            signature = build_function_signature(fn)
            selector = _uir_selector_for_signature(signature)

        # For callable functions the compiler ABI is the source of truth. This
        # prevents a malformed AST type spelling from leaving a phantom selector
        # alongside its canonical ABI selector.
        if (abi and fn.get("visibility") in ("public", "external")
                and selector not in abi_function_selectors):
            continue

        if not selector:
            selector = signature or fn_name

        name_to_selectors.setdefault(fn_name, set()).add(selector)
        signature_to_selector.setdefault(signature, selector)
        functions_by_selector[selector] = {
            "selector": selector,
            "name": fn_name,
            "signature": signature,
            "kind": kind,
            "visibility": fn.get("visibility", ""),
            "stateMutability": fn.get("stateMutability", ""),
            "categories": [],
            "reads": [],
            "writes": [],
            "guards": [],
            "transition_facts": [],
            "risk_tags": [],
            "source_facts": [],
        }

    # The name-keyed analysis view intentionally remains backward-compatible,
    # but it cannot represent overloads or compiler-generated public getters.
    # Add those interfaces from the authoritative compiler ABI as a sidecar.
    for item in abi or []:
        if not isinstance(item, dict) or item.get("type") != "function":
            continue
        fn_name = item.get("name")
        inputs = item.get("inputs", []) or []
        signature = f"{fn_name}({','.join(_abi_parameter_type(x) for x in inputs)})"
        selector = _uir_selector_for_signature(signature)
        if not fn_name or not selector:
            continue
        name_to_selectors.setdefault(fn_name, set()).add(selector)
        signature_to_selector[signature] = selector
        if selector not in functions_by_selector:
            is_getter = fn_name in storage
            functions_by_selector[selector] = {
                "selector": selector,
                "name": fn_name,
                "signature": signature,
                "kind": "getter" if is_getter else "abi_function",
                "visibility": "external",
                "stateMutability": item.get("stateMutability", ""),
                "abi_only": True,
                "observation_only": is_getter or item.get("stateMutability") in ("view", "pure"),
                "categories": ["interface"] + (["getter"] if is_getter else []),
                "reads": [fn_name] if is_getter else [],
                "writes": [],
                "guards": [],
                "transition_facts": [],
                "risk_tags": [],
                "source_facts": ["compiler_abi"],
            }

    # Preserve name-based resolution only where the name is unambiguous.
    name_to_selector = {name: next(iter(selectors)) for name, selectors in name_to_selectors.items() if len(selectors) == 1}

    def resolve_selector(name=None, signature=None):
        if signature in signature_to_selector:
            return signature_to_selector[signature]
        if name in name_to_selector:
            return name_to_selector[name]
        if isinstance(signature, str) and signature:
            return _uir_selector_for_signature(signature) or signature
        return None

    def annotate_function(name=None, signature=None, category=None, risk_tag=None, source_fact=None):
        selector = resolve_selector(name=name, signature=signature)
        if not selector or selector not in functions_by_selector:
            return None
        item = functions_by_selector[selector]
        _uir_add_unique(item, "categories", category)
        _uir_add_unique(item, "risk_tags", risk_tag)
        if source_fact:
            fact_name = source_fact if isinstance(source_fact, str) else source_fact.get("type") or source_fact.get("kind")
            _uir_add_unique(item, "source_facts", fact_name)
        return selector

    for fn_name, rw in dfg.items():
        selector = annotate_function(name=fn_name, category="dfg")
        if not selector:
            continue
        for var in rw.get("reads", []) or []:
            _uir_add_unique(functions_by_selector[selector], "reads", var)
        for var in rw.get("writes", []) or []:
            _uir_add_unique(functions_by_selector[selector], "writes", var)

    for fact in update_facts:
        fn_name = fact.get("function")
        selector = annotate_function(name=fn_name, category="state_update", source_fact=fact)
        if selector:
            _uir_add_unique(functions_by_selector[selector], "writes", fact.get("target"))

    for item in sensitive_functions:
        name, signature = _uir_function_key(item)
        selector = annotate_function(
            name=name,
            signature=signature,
            category="sensitive",
            risk_tag="sensitive_function",
            source_fact="sensitive_functions",
        )
        if selector:
            for var in item.get("writes", []) or []:
                _uir_add_unique(functions_by_selector[selector], "writes", var)

    for item in access:
        name, signature = _uir_function_key(item)
        annotate_function(
            name=name,
            signature=signature,
            category="access_guarded",
            risk_tag="guarded_sensitive",
            source_fact="access",
        )

    for item in access_anomalies:
        name, signature = _uir_function_key(item)
        selector = annotate_function(
            name=name,
            signature=signature,
            category="access_anomaly",
            risk_tag="unguarded_sensitive",
            source_fact="access_anomalies",
        )
        if selector:
            for var in item.get("writes", []) or []:
                _uir_add_unique(functions_by_selector[selector], "writes", var)

    for item in guard_facts:
        name, signature = _uir_function_key(item)
        selector = annotate_function(
            name=name,
            signature=signature,
            category="guarded",
            source_fact="guard_facts",
        )
        if selector:
            guard = {
                "kind": item.get("kind"),
                "evidence": item.get("evidence"),
            }
            if guard not in functions_by_selector[selector]["guards"]:
                functions_by_selector[selector]["guards"].append(guard)

    for fact in transition_facts:
        fn_name = fact.get("function")
        selector = annotate_function(
            name=fn_name,
            category="state_transition",
            risk_tag="state_machine",
            source_fact="transition_facts",
        )
        if selector:
            compact = {
                "state_var": fact.get("state_var"),
                "state_kind": fact.get("state_kind"),
                "from_candidates": fact.get("from_candidates", []),
                "to": fact.get("to"),
                "transition_kind": fact.get("transition_kind"),
                "op": fact.get("op"),
                "delta": fact.get("delta"),
            }
            if compact not in functions_by_selector[selector]["transition_facts"]:
                functions_by_selector[selector]["transition_facts"].append(compact)
            _uir_add_unique(functions_by_selector[selector], "writes", fact.get("state_var"))

    accounting_function_names = set(_uir_collect_strings(
        accounting,
        {"function", "functions", "evidence_function", "evidence_functions", "source", "target"},
    ))
    for fn_name in accounting_function_names:
        annotate_function(
            name=fn_name,
            category="accounting",
            risk_tag="accounting_relation",
            source_fact="accounting",
        )

    for item in accounting_anomalies:
        name, signature = _uir_function_key(item)
        if not name:
            funcs = _uir_collect_strings(item, {"function", "functions", "evidence_function", "evidence_functions"})
        else:
            funcs = [name]
        for fn_name in funcs:
            annotate_function(
                name=fn_name,
                signature=signature if fn_name == name else None,
                category="accounting_anomaly",
                risk_tag="accounting_anomaly",
                source_fact="accounting_anomalies",
            )

    relation_targets = []

    def add_relation(kind, from_name=None, to_name=None, storage_var=None, reason=None, raw=None):
        from_selector = resolve_selector(name=from_name)
        to_selector = resolve_selector(name=to_name)
        relation = {
            "kind": kind,
            "from_function": from_name,
            "from_selector": from_selector,
            "to_function": to_name,
            "to_selector": to_selector,
            "storage_var": storage_var,
            "reason": reason,
            "raw": _uir_jsonable(raw),
        }
        key = (kind, from_selector, to_selector, storage_var, reason)
        for old in relation_targets:
            old_key = (old.get("kind"), old.get("from_selector"), old.get("to_selector"), old.get("storage_var"), old.get("reason"))
            if old_key == key:
                return
        relation_targets.append(relation)

    for writer, rw in dfg.items():
        writes = set(rw.get("writes", []) or [])
        if not writes:
            continue
        for reader, rrw in dfg.items():
            if writer == reader:
                continue
            shared = writes.intersection(set(rrw.get("reads", []) or []))
            for var in sorted(shared, key=lambda x: str(x)):
                add_relation(
                    kind="uir_write_read",
                    from_name=writer,
                    to_name=reader,
                    storage_var=var,
                    reason="dfg write->read",
                )

    for rel in cross_relations:
        if not isinstance(rel, dict):
            continue
        from_name = rel.get("from") or rel.get("source") or rel.get("writer") or rel.get("from_function")
        to_name = rel.get("to") or rel.get("target") or rel.get("reader") or rel.get("to_function")
        storage_var = rel.get("var") or rel.get("storage") or rel.get("storage_var")
        add_relation(
            kind=rel.get("type") or rel.get("kind") or "cross_relation",
            from_name=from_name,
            to_name=to_name,
            storage_var=storage_var,
            reason=rel.get("reason") or rel.get("type") or "cross_relation",
            raw=rel,
        )

    invariant_targets = []
    for item in accounting:
        invariant_targets.append({
            "type": "accounting",
            "related_functions": sorted(set(_uir_collect_strings(
                item,
                {"function", "functions", "evidence_function", "evidence_functions"},
            ))),
            "related_storage": sorted(set(_uir_collect_strings(
                item,
                {"mapping", "supply", "target", "state_var", "storage_var"},
            ))),
            "raw": _uir_jsonable(item),
        })
    for item in accounting_anomalies:
        invariant_targets.append({
            "type": "accounting_anomaly",
            "related_functions": sorted(set(_uir_collect_strings(
                item,
                {"function", "functions", "evidence_function", "evidence_functions"},
            ))),
            "related_storage": sorted(set(_uir_collect_strings(
                item,
                {"mapping", "supply", "target", "state_var", "storage_var"},
            ))),
            "raw": _uir_jsonable(item),
        })
    for state_var in state_machine.get("states", []) or []:
        detail = (state_machine.get("details", {}) or {}).get(state_var, {})
        invariant_targets.append({
            "type": "state_machine",
            "state_var": state_var,
            "terminal_candidates": detail.get("terminal_candidates", []),
            "raw": _uir_jsonable(detail),
        })

    coverage_goals = {
        "sensitive_functions": len([x for x in functions_by_selector.values() if "sensitive" in x["categories"]]),
        "access_guarded_functions": len([x for x in functions_by_selector.values() if "access_guarded" in x["categories"]]),
        "access_anomalies": len([x for x in functions_by_selector.values() if "access_anomaly" in x["categories"]]),
        "accounting_functions": len([x for x in functions_by_selector.values() if "accounting" in x["categories"]]),
        "accounting_anomalies": len([x for x in functions_by_selector.values() if "accounting_anomaly" in x["categories"]]),
        "state_transition_functions": len([x for x in functions_by_selector.values() if "state_transition" in x["categories"]]),
        "storage_vars": len(storage),
        "write_read_relations": len([x for x in relation_targets if x.get("kind") == "uir_write_read"]),
        "cross_relations": len(cross_relations),
        "invariant_targets": len(invariant_targets),
    }

    return {
        "version": "1.0",
        "purpose": "side-channel targets for coverage-preserving UIR-guided fuzzing",
        "function_name_to_selector": _uir_jsonable(name_to_selector),
        "function_name_to_selectors": {name: sorted(selectors) for name, selectors in sorted(name_to_selectors.items())},
        "signature_to_selector": _uir_jsonable(signature_to_selector),
        "functions_by_selector": _uir_jsonable(functions_by_selector),
        "relation_targets": _uir_jsonable(relation_targets),
        "invariant_targets": _uir_jsonable(invariant_targets),
        "coverage_goals": _uir_jsonable(coverage_goals),
    }
