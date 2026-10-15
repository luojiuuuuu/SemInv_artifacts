import re
import json
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Any, Dict, List, Optional

from .invariant_utils import *
from .gen_llm_tests import call_llm
from ..invariants.benchmark_taxonomy import support_matrix, benchmark_taxonomy
from ..invariants.registry import default_invariant_specs, validate_registry
from ..invariants.spec import specs_to_jsonable

# =========================
# LLM candidate completion
# =========================

ALLOWED_TEMPLATE_TYPES = {
    "state_terminal_no_rollback",
    "state_monotonic",
    "state_domain",
    "state_guarded_transition",
    "access_negative_call",
}

ALLOWED_CATEGORIES = {
    "state",
    "access",
}

def _safe_lower(x):
    return str(x).strip().lower() if x is not None else ""

def _dedup_str_list(xs):
    out = []
    seen = set()
    for x in xs or []:
        s = str(x).strip()
        if not s or s in seen:
            continue
        seen.add(s)
        out.append(s)
    return out

def _has_generated_foundry_test_function(lines):
    """Return true if generated Solidity contains at least one Foundry test entry.

    Some legacy targets expose handler-callable functions but none of the
    higher-level semantic miners recover a printable accounting/access/state
    invariant.  Without an explicit test/invariant function Foundry reports an
    empty suite, which makes those targets disappear from L3 evaluation.  This
    helper lets the generator append a conservative reachability test only in
    that empty-suite case.
    """
    return any(re.search(r"\bfunction\s+(?:test_|invariant_)", str(line)) for line in lines)

def _rewrite_pre_06_payable_literals(lines, solc_version):
    """Use Solidity 0.5-compatible payable-address literals in generated tests.

    `payable(address(...))` is accepted by newer compilers but rejected by
    solc 0.5.x.  Historical Trace2Inv targets include several 0.5.x contracts
    whose constructors require `address payable`; for those, the common
    compatibility idiom is `address(uint160(...))`.
    """
    if parse_solc_version_number(solc_version) >= (0, 6, 0):
        return lines
    out = []
    pat = re.compile(r"payable\s*\(\s*address\s*\(([^()]+)\)\s*\)")
    for line in lines:
        out.append(pat.sub(r"address(uint160(\1))", str(line)))
    return out

def _split_top_level_args(s: str) -> List[str]:
    """Split a Solidity argument/parameter list while respecting brackets."""
    parts: List[str] = []
    cur: List[str] = []
    depth = 0
    in_str: Optional[str] = None
    esc = False
    for ch in s or "":
        if in_str:
            cur.append(ch)
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == in_str:
                in_str = None
            continue
        if ch in ("'", '"'):
            in_str = ch
            cur.append(ch)
            continue
        if ch in "([{":
            depth += 1
        elif ch in ")]}" and depth > 0:
            depth -= 1
        if ch == "," and depth == 0:
            parts.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
    tail = "".join(cur).strip()
    if tail:
        parts.append(tail)
    return parts

def _strip_solidity_comments(source_text: str) -> str:
    source_text = re.sub(r"/\*.*?\*/", "", source_text or "", flags=re.S)
    return re.sub(r"//.*?$", "", source_text, flags=re.M)

def _extract_braced_block(source_text: str, open_brace_idx: int) -> str:
    depth = 0
    for i in range(open_brace_idx, len(source_text)):
        ch = source_text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return source_text[open_brace_idx + 1:i]
    return ""

def _extract_contract_block_from_source(source_text: Optional[str], contract_name: str) -> Optional[str]:
    if not source_text or not contract_name:
        return None
    src = _strip_solidity_comments(source_text)
    m = re.search(rf"\b(contract|interface|library)\s+{re.escape(contract_name)}\b[^\{{;]*\{{", src, flags=re.S)
    if not m:
        return None
    open_idx = src.find("{", m.start(), m.end())
    if open_idx < 0:
        return None
    return _extract_braced_block(src, open_idx) or None

def _extract_ctor_param_types_from_source(source_text: Optional[str], contract_name: str) -> Optional[List[str]]:
    if not source_text:
        return None
    src = _extract_contract_block_from_source(source_text, contract_name) or source_text
    patterns = [r"constructor\s*\((.*?)\)"]
    if contract_name:
        patterns.append(rf"function\s+{re.escape(contract_name)}\s*\((.*?)\)")
    m = None
    for pat in patterns:
        m = re.search(pat, src, flags=re.S)
        if m:
            break
    if not m:
        return None
    out: List[str] = []
    for p in _split_top_level_args(m.group(1)):
        toks = p.strip().split()
        if not toks:
            continue
        typ = " ".join(toks[:-1] if len(toks) >= 2 else toks)
        typ = re.sub(r"^(contract|interface)\s+", "", typ.strip())
        out.append(typ)
    return out or None

def _state_var_exists(state_machine, state_var):
    return state_var in set(state_machine.get("states", []) or [])

def _function_exists(functions, fn_name):
    return fn_name in (functions or {})

def _is_externally_callable_fn(functions, fn_name):
    fn = (functions or {}).get(fn_name)
    if not fn:
        return False
    return is_externally_callable_function(fn)

def _candidate_targets_known_functions(functions, target_functions):
    if not target_functions:
        return True
    for fn_name in target_functions:
        if not _function_exists(functions, fn_name):
            return False
    return True

def _candidate_targets_known_state_vars(state_machine, target_vars):
    if not target_vars:
        return True
    for v in target_vars:
        if not _state_var_exists(state_machine, v):
            return False
    return True

def _normalize_state_value_to_str(v):
    if v is None:
        return None
    return str(v).strip()

def _state_terminal_candidate_conflicts_with_known_transitions(candidate, state_machine):
    """
    鏈€灏忓啿绐佽繃婊わ細
    瀵?state_terminal_no_rollback 鍊欓€夛紝鑻ュ凡鏈?transition_facts 鏄庣‘鏄剧ず
    鍚屼竴 state_var 杩樿兘琚祴鍊煎埌鍏朵粬闈?terminal 鍊硷紝鍒欐嫆缁濄€?

    杩欐槸淇濆畧瑙勫垯锛屼笉鍋氬鏉傚彲杈炬€ц瘉鏄庯紝鍙仛鈥滃凡鏈夋樉寮忓弽渚嬧€濊繃婊ゃ€?
    """
    if not isinstance(candidate, dict):
        return False

    if _safe_lower(candidate.get("template_type")) != "state_terminal_no_rollback":
        return False

    target_vars = candidate.get("target_vars", []) or []
    if len(target_vars) != 1:
        return False

    state_var = target_vars[0]
    details = (state_machine.get("details", {}) or {}).get(state_var, {})
    terminal_candidates = {
        _normalize_state_value_to_str(x) for x in (details.get("terminal_candidates", []) or [])
    }
    terminal_candidates.discard(None)

    if not terminal_candidates:
        return False

    for tf in state_machine.get("transition_facts", []) or []:
        if tf.get("state_var") != state_var:
            continue

        to_v = _normalize_state_value_to_str(tf.get("to"))
        if to_v is None:
            continue

        # 宸茬煡瀛樺湪鎶婅鐘舵€佸啓鎴愬叾瀹冨€肩殑 transition锛?
        # 鍒?鈥渢erminal no rollback鈥?鍊欓€変笉绋筹紝鐩存帴瑙嗕负鍐茬獊
        if to_v not in terminal_candidates:
            return True

    return False

def _state_domain_candidate_duplicates_known_fact(candidate, state_machine):
    if not isinstance(candidate, dict):
        return False

    if _safe_lower(candidate.get("template_type")) != "state_domain":
        return False

    target_vars = candidate.get("target_vars", []) or []
    if len(target_vars) != 1:
        return False

    state_var = target_vars[0]
    detail = (state_machine.get("details", {}) or {}).get(state_var, {})
    state_kind = detail.get("state_kind", "")

    # enum / bool / uint 杩欎笁绫讳綘褰撳墠閮藉凡鏈夋湰鍦?domain 妯℃澘
    if state_kind in ["enum", "bool", "uint"]:
        return True

    return False

def _access_candidate_duplicates_known_fact(candidate, access):
    if not isinstance(candidate, dict):
        return False

    if _safe_lower(candidate.get("template_type")) != "access_negative_call":
        return False

    target_functions = _dedup_str_list(candidate.get("target_functions", []))
    if len(target_functions) != 1:
        return False

    fn_name = target_functions[0]

    known = set()
    for item in access or []:
        n = item.get("name")
        if n:
            known.add(str(n).strip())

    return fn_name in known

def build_llm_candidate_prompt(source_code,
                               accounting,
                               state_machine,
                               access,
                               functions,
                               storage,
                               max_candidates: int = 8):
    """
    Step 4 鏈€灏忕増锛?
    鍙厑璁?LLM 浜у嚭 state / access 涓ょ被鍊欓€夛紝
    涓?template_type 蹇呴』鍦ㄧ櫧鍚嶅崟涓€?
    """
    function_names = sorted(list((functions or {}).keys()))
    storage_names = sorted(list((storage or {}).keys()))
    state_vars = state_machine.get("states", []) or []

    prompt = f"""
You are analyzing a Solidity contract and proposing ONLY low-risk, template-friendly invariant candidates.

Contract source:
{source_code}

Known accounting invariants:
{json.dumps(accounting, ensure_ascii=False)}

Known state machine facts:
{json.dumps(state_machine, ensure_ascii=False)}

Known protected access functions:
{json.dumps(access, ensure_ascii=False)}

Known function names:
{json.dumps(function_names, ensure_ascii=False)}

Known storage variables:
{json.dumps(storage_names, ensure_ascii=False)}

Known state variables:
{json.dumps(state_vars, ensure_ascii=False)}

Your task:
Return AT MOST {max_candidates} candidates as a JSON array.

IMPORTANT HARD CONSTRAINTS:
1. Only output JSON. No markdown. No explanation outside JSON.
2. Only propose candidates in these categories:
   - "state"
   - "access"
3. Only use these template_type values:
   - "state_terminal_no_rollback"
   - "state_monotonic"
   - "state_domain"
   - "state_guarded_transition"
   - "access_negative_call"
4. Every candidate must reference ONLY existing function names / state vars from the provided lists.
5. Do not invent variables, functions, roles, or standards.
6. Do not propose accounting candidates in this step.
7. Prefer conservative candidates with confidence "high" or "medium".
8. For "state_guarded_transition":
   - use exactly one target state variable
   - use exactly one target function
   - only propose it when the function is clearly related to a known state transition
9. Do not restate already obvious enum-domain facts unless absolutely necessary.
10. Prefer candidates that are NOT already directly implied by obvious enum-domain checks or known onlyOwner access checks.

Required JSON schema for each element:
{{
  "category": "state",
  "template_type": "state_guarded_transition",
  "name": "phase_activate_only_from_init",
  "natural_language": "activate should only move phase from Init to Active.",
  "target_vars": ["phase"],
  "target_functions": ["activate"],
  "preconditions": ["phase == Init"],
  "confidence": "high",
  "why": "Known transition facts show activate moves phase from Init to Active."
}}

Return [] if no safe candidate exists.
"""
    return prompt

def llm_generate_structured_candidates(source_code,
                                       accounting,
                                       state_machine,
                                       access,
                                       functions,
                                       storage,
                                       api_key,
                                       api_url,
                                       model,
                                       max_candidates: int = 8):
    prompt = build_llm_candidate_prompt(
        source_code=source_code,
        accounting=accounting,
        state_machine=state_machine,
        access=access,
        functions=functions,
        storage=storage,
        max_candidates=max_candidates
    )

    out = call_llm(prompt, api_key, api_url, model)
    print("[Step4] raw llm output:", out[:2000] if isinstance(out, str) else out)

    try:
        data = json.loads(out)
    except Exception:
        return []

    if not isinstance(data, list):
        return []

    normalized = []
    for item in data:
        if not isinstance(item, dict):
            continue

        normalized.append({
            "category": item.get("category"),
            "template_type": item.get("template_type"),
            "name": item.get("name"),
            "natural_language": item.get("natural_language"),
            "target_vars": item.get("target_vars", []),
            "target_functions": item.get("target_functions", []),
            "preconditions": item.get("preconditions", []),
            "confidence": item.get("confidence"),
            "why": item.get("why"),
            "source": "llm",
        })

    return normalized

def filter_llm_candidates(candidates,
                          functions,
                          state_machine,
                          access):
    """
    鏈€灏忚繃婊よ鍒欙細
    - category/template_type 蹇呴』鍦ㄧ櫧鍚嶅崟
    - target_functions / target_vars 蹇呴』瀛樺湪
    - access_negative_call 鐨?target_functions 蹇呴』澶栭儴鍙皟鐢?
    - state 绫诲繀椤诲紩鐢ㄨ嚦灏戜竴涓凡鐭?state_var
    - access 绫诲繀椤诲紩鐢ㄨ嚦灏戜竴涓凡鐭?function
    - confidence=low 鐩存帴涓㈠純
    """
    accepted = []
    rejected = []

    for item in candidates or []:
        if not isinstance(item, dict):
            rejected.append({
                "candidate": item,
                "reason": "not-a-dict"
            })
            continue

        category = _safe_lower(item.get("category"))
        template_type = _safe_lower(item.get("template_type"))
        confidence = _safe_lower(item.get("confidence"))

        target_vars = _dedup_str_list(item.get("target_vars", []))
        target_functions = _dedup_str_list(item.get("target_functions", []))

        if category not in ALLOWED_CATEGORIES:
            rejected.append({"candidate": item, "reason": "category-not-allowed"})
            continue

        if template_type not in ALLOWED_TEMPLATE_TYPES:
            rejected.append({"candidate": item, "reason": "template-type-not-allowed"})
            continue

        if confidence == "low":
            rejected.append({"candidate": item, "reason": "low-confidence"})
            continue

        if not _candidate_targets_known_functions(functions, target_functions):
            rejected.append({"candidate": item, "reason": "unknown-target-function"})
            continue

        # -------- state 绫昏鍒?--------
        if category == "state":
            if not target_vars:
                rejected.append({"candidate": item, "reason": "state-candidate-without-target-var"})
                continue

            if not _candidate_targets_known_state_vars(state_machine, target_vars):
                rejected.append({"candidate": item, "reason": "unknown-target-var"})
                continue

            if template_type == "state_terminal_no_rollback":
                if _state_terminal_candidate_conflicts_with_known_transitions(item, state_machine):
                    rejected.append({"candidate": item, "reason": "conflicts-with-known-transitions"})
                    continue

            if template_type == "state_domain":
                if _state_domain_candidate_duplicates_known_fact(item, state_machine):
                    rejected.append({"candidate": item, "reason": "duplicates-known-state-domain-fact"})
                    continue

            if template_type == "state_guarded_transition":
                if len(target_vars) != 1:
                    rejected.append({"candidate": item, "reason": "guarded-transition-requires-single-target-var"})
                    continue

                if len(target_functions) != 1:
                    rejected.append({"candidate": item, "reason": "guarded-transition-requires-single-target-function"})
                    continue

                fn_name = target_functions[0]
                state_var = target_vars[0]

                detail = (state_machine.get("details", {}) or {}).get(state_var, {})
                transition_functions = _dedup_str_list(detail.get("transition_functions", []))

                if fn_name not in transition_functions:
                    rejected.append({"candidate": item, "reason": "function-not-in-state-transition-functions"})
                    continue

                if not _state_guarded_transition_supported_by_known_facts(item, state_machine):
                    rejected.append({"candidate": item, "reason": "guarded-transition-not-supported-by-known-facts"})
                    continue

                if _state_guarded_transition_duplicates_known_fact(item, state_machine):
                    rejected.append({"candidate": item, "reason": "duplicates-known-guarded-transition-fact"})
                    continue

            if template_type in [
                "state_terminal_no_rollback",
                "state_monotonic",
                "state_domain",
                "state_guarded_transition",
            ]:
                accepted.append({
                    "category": category,
                    "template_type": template_type,
                    "name": item.get("name") or template_type,
                    "natural_language": item.get("natural_language") or "",
                    "target_vars": target_vars,
                    "target_functions": target_functions,
                    "preconditions": _dedup_str_list(item.get("preconditions", [])),
                    "confidence": confidence or "medium",
                    "why": item.get("why") or "",
                    "source": "llm",
                    "status": "accepted",
                })
                continue

        # -------- access 绫昏鍒?--------
        if category == "access":
            if template_type != "access_negative_call":
                rejected.append({"candidate": item, "reason": "access-template-mismatch"})
                continue

            if not target_functions:
                rejected.append({"candidate": item, "reason": "access-candidate-without-target-function"})
                continue

            bad = False
            for fn_name in target_functions:
                if not _is_externally_callable_fn(functions, fn_name):
                    bad = True
                    break
            if bad:
                rejected.append({"candidate": item, "reason": "target-function-not-externally-callable"})
                continue

            if _access_candidate_duplicates_known_fact(item, access):
                rejected.append({"candidate": item, "reason": "duplicates-known-access-fact"})
                continue

            accepted.append({
                "category": category,
                "template_type": template_type,
                "name": item.get("name") or template_type,
                "natural_language": item.get("natural_language") or "",
                "target_vars": target_vars,
                "target_functions": target_functions,
                "preconditions": _dedup_str_list(item.get("preconditions", [])),
                "confidence": confidence or "medium",
                "why": item.get("why") or "",
                "source": "llm",
                "status": "accepted",
            })
            continue

        rejected.append({"candidate": item, "reason": "fell-through"})

    # 鍘婚噸
    uniq = {}
    for item in accepted:
        key = (
            item.get("category"),
            item.get("template_type"),
            tuple(item.get("target_vars", [])),
            tuple(item.get("target_functions", [])),
            item.get("name"),
        )
        uniq[key] = item

    return {
        "accepted": list(uniq.values()),
        "rejected": rejected,
    }

def expand_llm_access_candidates(candidates):
    """
    灏嗕竴涓?access_negative_call + 澶氫釜 target_functions
    鎷嗘垚澶氫釜鍗曞嚱鏁板€欓€夛紝渚夸簬鍚庣画鐩存帴妯℃澘鍖栬惤鍦般€?
    """
    out = []

    for item in candidates or []:
        if not isinstance(item, dict):
            continue

        template_type = _safe_lower(item.get("template_type"))
        if template_type != "access_negative_call":
            out.append(item)
            continue

        target_functions = _dedup_str_list(item.get("target_functions", []))
        if len(target_functions) <= 1:
            out.append(item)
            continue

        for fn_name in target_functions:
            new_item = dict(item)
            new_item["name"] = f"{item.get('name') or 'llm_access'}_{fn_name}"
            new_item["target_functions"] = [fn_name]
            out.append(new_item)

    return out

def fill_ir_with_llm_candidates(ir, llm_result):
    ir["llm"] = _to_jsonable(llm_result)
    return ir

def select_codegenable_llm_candidates(llm_candidates, functions, state_machine, access):
    """
    浠?Step4 accepted candidates 涓啀绛涗竴灞傦紝寰楀埌鈥滃彲瀹夊叏钀藉湴鎴?Solidity 娴嬭瘯鈥濈殑鍊欓€夈€?
    褰撳墠鍙敮鎸侊細
    - access_negative_call
    - state_terminal_no_rollback

    涓旇姹傦細
    - access_negative_call: 鎭板ソ 1 涓?target_function
    - state_terminal_no_rollback: 鎭板ソ 1 涓?target_var锛屼笖璇ョ姸鎬佸凡鏈?handler snapshot 瀛楁
    """
    out = []

    known_access_names = set()
    for item in access or []:
        n = item.get("name")
        if n:
            known_access_names.add(str(n).strip())

    for item in llm_candidates or []:
        if not isinstance(item, dict):
            continue

        template_type = _safe_lower(item.get("template_type"))
        target_vars = _dedup_str_list(item.get("target_vars", []))
        target_functions = _dedup_str_list(item.get("target_functions", []))

        if template_type == "access_negative_call":
            if len(target_functions) != 1:
                continue

            fn_name = target_functions[0]
            if fn_name not in functions:
                continue
            if fn_name in known_access_names:
                # 宸叉湁 access 妯℃澘锛屼笉閲嶅钀藉湴
                continue

            fn = functions.get(fn_name)
            if not fn or not is_externally_callable_function(fn):
                continue

            out.append(item)
            continue

        if template_type == "state_terminal_no_rollback":
            if len(target_vars) != 1:
                continue

            state_var = target_vars[0]
            if state_var not in (state_machine.get("states", []) or []):
                continue

            detail = (state_machine.get("details", {}) or {}).get(state_var, {})
            if not detail:
                continue

            # 蹇呴』瀛樺湪 terminal_candidates锛屼笖褰撳墠鏈湴閫昏緫娌¤鐩栨帀
            terminal_value_indices = resolve_terminal_value_indices(detail)
            if not terminal_value_indices:
                continue

            out.append(item)
            continue

        if template_type == "state_guarded_transition":
            if len(target_vars) != 1:
                continue
            if len(target_functions) != 1:
                continue

            state_var = target_vars[0]
            fn_name = target_functions[0]

            if state_var not in (state_machine.get("states", []) or []):
                continue
            if fn_name not in functions:
                continue
            if not can_generate_direct_handler_call(fn_name, functions):
                continue

            if not _state_guarded_transition_supported_by_known_facts(item, state_machine):
                continue

            # Step5 鏈€灏忔敹绱э細
            # 鍙湁鈥滃瓨鍦ㄦ槑纭?allowed from鈥濈殑杩佺Щ鎵嶅厑璁歌惤鍦颁负 guarded-transition 娴嬭瘯
            matched_facts = []
            for tf in state_machine.get("transition_facts", []) or []:
                if tf.get("state_var") == state_var and tf.get("function") == fn_name:
                    matched_facts.append(tf)

            known_froms = []
            for tf in matched_facts:
                for x in tf.get("from_candidates", []) or []:
                    xs = _normalize_state_symbol_for_compare(x)
                    if xs:
                        known_froms.append(xs.split(".")[-1].strip())

            known_froms = _dedup_str_list(known_froms)

            # 娌℃湁鏄庣‘鍓嶆€佺害鏉燂紝涓嶇敓鎴?guarded-transition 妯℃澘
            if not known_froms:
                continue

            out.append(item)
            continue
    return out

def emit_llm_access_negative_call_test_lines(
        L, candidate, functions, *, check_catalog=None, contract=None,
        suite_suffix="AccessInvariantTest"):
    """
    涓哄崟涓?access_negative_call 鍊欓€夌敓鎴?Solidity invariant 鍑芥暟銆?
    """
    fn_name = _dedup_str_list(candidate.get("target_functions", []))[0]
    fn_def = functions.get(fn_name)
    if not fn_def:
        return

    sig = build_function_signature(fn_def)

    inline_args = build_default_call_args_from_function(fn_def)
    args_plan = build_default_args_plan_from_function_def(fn_def, var_prefix=f"llm_acc_{fn_name}")

    if inline_args is None and args_plan is None:
        inline_args = build_default_call_args(sig)

    test_name = candidate.get("name") or f"llm_access_{fn_name}"
    test_name = _sanitize_sol_var_name(test_name, f"llm_access_{fn_name}")
    if contract:
        _record_access_rejection_check(
            check_catalog,
            contract=contract,
            suite_suffix=suite_suffix,
            test_name=f"invariant_{test_name}",
            function_name=fn_name,
            signature=sig,
            selector=(fn_def or {}).get("selector"),
            argument_source="function_definition_plan" if args_plan is not None else "inline_defaults",
            fact_ref=f"llm_candidate:{candidate.get('name') or test_name}",
        )

    L.append("")
    L.append(f"    function invariant_{test_name}() public {{")

    if args_plan is not None:
        for line in args_plan.get("prelude_lines", []):
            L.append(f"        {line}")

    L.append("        address attacker = address(0xdead);")
    L.append("        vm.prank(attacker);")

    if args_plan is not None:
        call_args = args_plan.get("args_str", "")
        if call_args:
            L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {call_args}));')
        else:
            L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')
    else:
        if inline_args:
            L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {inline_args}));')
        else:
            L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')

    L.append("        assertTrue(!ok);")
    L.append("    }")

def emit_llm_state_terminal_test_lines(
        L, candidate, state_machine, handler_api=None, *, check_catalog=None,
        contract=None, suite_suffix="StateInvariantTest"):
    """
    涓哄崟涓?state_terminal_no_rollback 鍊欓€夌敓鎴?Solidity invariant 鍑芥暟銆?
    澶嶇敤 handler.entered_terminal_x / curr_x 鏈哄埗銆?
    """
    state_var = _dedup_str_list(candidate.get("target_vars", []))[0]
    if not handler_has_terminal_tracker(handler_api, state_var):
        record_dropped_invariant(
            state_machine,
            "llm_state_terminal_no_rollback",
            state_var,
            "missing_handler_tracker",
            {"candidate": candidate.get("name")},
        )
        return
    detail = (state_machine.get("details", {}) or {}).get(state_var, {})
    terminal_value_indices = resolve_terminal_value_indices(detail)

    if not terminal_value_indices:
        return

    cond = " || ".join([f"curr == {x}" for x in terminal_value_indices]) or "true"

    test_name = candidate.get("name") or f"llm_terminal_{state_var}"
    test_name = _sanitize_sol_var_name(test_name, f"llm_terminal_{state_var}")
    if contract:
        _record_state_check(
            check_catalog,
            contract=contract,
            suite_suffix=suite_suffix,
            test_name=f"invariant_{test_name}",
            state_var=state_var,
            predicate="current_state in terminal_values",
            template="state.terminal",
            rule_id="I3.state.terminal_absorbing",
            activation_condition=f"handler.entered_terminal_{state_var}()",
            fact_ref=f"llm_candidate:{candidate.get('name') or test_name}",
            terminal_values=terminal_value_indices,
            spec_basis_kind="llm_candidate_with_recovered_state_summary",
        )

    L.append("")
    L.append(f"    function invariant_{test_name}() public view {{")
    L.append(f"        if(handler.entered_terminal_{state_var}()) {{")
    L.append(f"            uint256 curr = handler.curr_{state_var}();")
    L.append(f"            assertTrue({cond});")
    L.append("        }")
    L.append("    }")

def emit_llm_state_guarded_transition_test_lines(
        L, candidate, functions, state_machine, *, check_catalog=None,
        contract=None, suite_suffix="StateTransitionPropertyTest"):
    """
    涓?state_guarded_transition 鍊欓€夌敓鎴?Solidity property test銆?
    鏈€灏忕増鏈細
    - 璇诲彇璋冪敤鍓嶇姸鎬?beforeV
    - 瀹氬悜璋冪敤鐩爣鍑芥暟
    - 璇诲彇璋冪敤鍚庣姸鎬?afterV
    - 濡傛灉 beforeV 涓嶅湪宸茬煡鍏佽鍓嶆€佷腑锛屽垯涓嶅簲鎴愬姛杩佺Щ鍒板凡鐭ョ洰鏍囨€?
    """
    target_vars = _dedup_str_list(candidate.get("target_vars", []))
    target_functions = _dedup_str_list(candidate.get("target_functions", []))

    if len(target_vars) != 1 or len(target_functions) != 1:
        return

    state_var = target_vars[0]
    fn_name = target_functions[0]

    if fn_name not in functions:
        return

    detail = (state_machine.get("details", {}) or {}).get(state_var, {})
    state_kind = detail.get("state_kind", "")

    matched_facts = []
    for tf in state_machine.get("transition_facts", []) or []:
        if tf.get("state_var") == state_var and tf.get("function") == fn_name:
            matched_facts.append(tf)

    if not matched_facts:
        return

    allowed_froms = []
    target_tos = []

    enum_vals = detail.get("enum_values", []) or []

    for tf in matched_facts:
        for x in tf.get("from_candidates", []) or []:
            xs = _normalize_state_symbol_for_compare(x)
            if xs:
                allowed_froms.append(xs.split(".")[-1].strip())

        to_v = tf.get("to")
        if to_v is not None:
            target_tos.append(str(to_v).strip())

    allowed_froms = _dedup_str_list(allowed_froms)
    target_tos = _dedup_str_list(target_tos)

    allowed_from_indices = []
    target_to_indices = []

    if state_kind == "enum":
        for x in allowed_froms:
            if x in enum_vals:
                allowed_from_indices.append(str(enum_vals.index(x)))
        for x in target_tos:
            if x in enum_vals:
                target_to_indices.append(str(enum_vals.index(x)))
    elif state_kind == "bool":
        for x in allowed_froms:
            xl = str(x).lower()
            if xl == "true":
                allowed_from_indices.append("1")
            elif xl == "false":
                allowed_from_indices.append("0")
        for x in target_tos:
            xl = str(x).lower()
            if xl == "true":
                target_to_indices.append("1")
            elif xl == "false":
                target_to_indices.append("0")
    else:
        for x in allowed_froms:
            if str(x).isdigit():
                allowed_from_indices.append(str(x))
        for x in target_tos:
            if str(x).isdigit():
                target_to_indices.append(str(x))

    if not target_to_indices:
        return

    call_stmt = build_direct_handler_call_stmt(fn_name, functions)
    if not call_stmt:
        return

    read_expr = resolve_state_read_expr(state_var, functions)
    if not read_expr:
        return

    test_name = candidate.get("name") or f"llm_guarded_{state_var}_{fn_name}"
    test_name = _sanitize_sol_var_name(test_name, f"llm_guarded_{state_var}_{fn_name}")

    if state_kind == "bool":
        before_read = f"target.{read_expr} ? 1 : 0"
        after_read = f"target.{read_expr} ? 1 : 0"
    else:
        before_read = f"uint256(target.{read_expr})"
        after_read = f"uint256(target.{read_expr})"

    bad_from_cond = "true"
    if allowed_from_indices:
        bad_from_cond = " && ".join([f"beforeV != {x}" for x in allowed_from_indices])

    to_cond = " || ".join([f"afterV == {x}" for x in target_to_indices]) or "false"

    if contract:
        _record_check_descriptor(
            check_catalog,
            rule_id="I3.state.guarded_transition",
            template="state.guarded_transition",
            suite=f"{contract}{suite_suffix}",
            test_name=f"test_llm_{test_name}",
            predicate="not(after_state in target_values)",
            bindings={
                "state_variable": state_var,
                "state_read": read_expr,
                "action_function": fn_name,
                "action_signature": (functions.get(fn_name) or {}).get("signature") or build_function_signature(functions.get(fn_name) or {}),
                "allowed_from_values": allowed_from_indices,
                "target_values": target_to_indices,
            },
            execution_requirements=[
                "the state reads and generated action complete",
                "the activation condition holds and the assertion executes",
            ],
            semantic_assumptions=[
                "the recovered allowed source states and target states instantiate the selected transition check",
            ],
            spec_basis={
                "kind": "llm_candidate_with_recovered_transition_facts",
                "candidate": candidate.get("name") or test_name,
            },
            observation_sources=["generated test site", "Foundry assertion trace"],
            fact_refs=[f"llm_candidate:{candidate.get('name') or test_name}", f"state_summary:{state_var}"],
            assertion_kind="assertTrue",
            activation_condition=f"({bad_from_cond}) && handler.lastCallOk()",
            rca_included=False,
        )

    L.append("")
    L.append(f"    function test_llm_{test_name}() public {{")
    L.append(f"        uint256 beforeV = {before_read};")
    L.append(call_stmt)
    L.append(f"        uint256 afterV = {after_read};")
    L.append(f"        if(({bad_from_cond}) && handler.lastCallOk()) {{")
    L.append(f"            assertTrue(!({to_cond}));")
    L.append("        }")
    L.append("    }")

def emit_codegenable_llm_invariants(
        L, llm_candidates, functions, state_machine, access, handler_api=None,
        *, check_catalog=None, contract=None, suite_suffix=None):
    """
    灏嗗彲钀藉湴鐨?LLM candidates 杞垚 modern Foundry invariant 娴嬭瘯銆?
    """
    codegenable = select_codegenable_llm_candidates(
        llm_candidates=llm_candidates,
        functions=functions,
        state_machine=state_machine,
        access=access
    )

    for cand in codegenable:
        template_type = _safe_lower(cand.get("template_type"))

        if template_type == "access_negative_call":
            emit_llm_access_negative_call_test_lines(
                L, cand, functions,
                check_catalog=check_catalog,
                contract=contract,
                suite_suffix=suite_suffix or "AccessInvariantTest",
            )
            continue

        if template_type == "state_terminal_no_rollback":
            emit_llm_state_terminal_test_lines(
                L, cand, state_machine, handler_api=handler_api,
                check_catalog=check_catalog,
                contract=contract,
                suite_suffix=suite_suffix or "StateInvariantTest",
            )
            continue

        if template_type == "state_guarded_transition":
            emit_llm_state_guarded_transition_test_lines(
                L, cand, functions, state_machine,
                check_catalog=check_catalog,
                contract=contract,
                suite_suffix=suite_suffix or "StateTransitionPropertyTest",
            )
            continue
    
    
def generate_replay_script(contract, profile, solc_version=None):

    if profile != "modern":
        return ""

    ctor_vis = " public" if need_constructor_public(solc_version) else ""

    L = []

    L.append("// replay helper")
    L.append("contract ReplayHelper is Test {")
    L.append(f"    {contract} target;")

    L.append(f"    constructor(address t){ctor_vis} {{")
    L.append(f"        target = {contract}(payable(t));")
    L.append("    }")

    L.append("    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {")
    L.append("        vm.deal(sender, value);")
    L.append("        vm.startPrank(sender);")
    L.append("        (bool ok,) = address(target).call{value:value}(data);")
    L.append("        vm.stopPrank();")
    L.append("        return ok;")
    L.append("    }")

    L.append("}")

    return "\n".join(L)

def generate_handler(contract, functions, access, state_machine, profile, solc_version, storage=None):

    L = []

    use_try_catch = (profile == "modern")
    use_state_snapshot = (profile == "modern")
    readable_states = _readable_state_entries(state_machine, functions, storage=storage) if use_state_snapshot else []
    vm_ref = "vm" if profile == "modern" else "_vm()"
    ctor_vis = " public" if (profile == "modern" and need_constructor_public(solc_version)) else ""

    handler_base = ""
    if profile in ["mid_legacy", "legacy"]:
        handler_base = " is LegacyCheatcodes"

    L.append(f"contract {contract}Handler{handler_base} {{")
    L.append(f"    {contract} public target;")
    if profile == "modern":
        L.append("    Vm public vm;")

    L.append("")
    L.append("    address[] internal actors;")
    L.append("    uint internal nonce;")

    L.append("")

    # tracking
    L.append("    mapping(address=>uint256) public ethSent;")
    L.append("    mapping(address=>uint256) public callCount;")
    L.append("    bool public lastCallOk;")
    L.append("    uint256 public attemptedCalls;")
    L.append("    uint256 public successfulCalls;")
    L.append("    uint256 public revertedCalls;")

    if use_state_snapshot:
        L.append("")
        L.append("    // state snapshot tracking")

        for s, _read_expr in readable_states:
            L.append(f"    uint256 public prev_{s};")
            L.append(f"    uint256 public curr_{s};")
            L.append(f"    bool public seen_{s};")
            L.append(f"    bool public entered_terminal_{s};")

    L.append("")
    if profile == "modern":
        L.append(f"    constructor({contract} _target, Vm _vm){ctor_vis} {{")
    elif profile == "mid_legacy":
        L.append(f"    constructor({contract} _target) public {{")
    else:
        L.append(f"    constructor({contract} _target) public {{")

    L.append("        target = _target;")

    if profile == "modern":
        L.append("        vm = _vm;")

    L.append("")
    L.append("        actors.push(address(0x100));")
    L.append("        actors.push(address(0x200));")
    L.append("        actors.push(address(0x300));")
    L.append("        actors.push(address(0x400));")
    L.append("        actors.push(address(this));")

    L.append("")
    L.append("        for(uint i=0;i<actors.length;i++){")
    L.append(f"            {vm_ref}.deal(actors[i],100 ether);")
    L.append("        }")

    L.append("    }")

    # actor helpers
    L.append("")
    L.append("    function actorCount() public view returns(uint){")
    L.append("        return actors.length;")
    L.append("    }")

    L.append("")
    L.append("    function actor(uint i) public view returns(address){")
    L.append("        return actors[i];")
    L.append("    }")

    # state snapshot helpers
    if use_state_snapshot:
        for s, read_expr in readable_states:
            detail = state_machine.get("details", {}).get(s, {})

            L.append("")
            state_kind = detail.get("state_kind", "enum")

            L.append(f"    function _snapshot_before_{s}() internal {{")
            L.append(f"        if(seen_{s}) {{")
            L.append(f"            prev_{s} = curr_{s};")
            L.append("        } else {")

            if state_kind == "bool":
                L.append(f"            prev_{s} = target.{read_expr} ? 1 : 0;")
            else:
                L.append(f"            prev_{s} = uint(target.{read_expr});")

            L.append(f"            seen_{s} = true;")
            L.append("        }")

            if state_kind == "bool":
                L.append(f"        curr_{s} = target.{read_expr} ? 1 : 0;")
            else:
                L.append(f"        curr_{s} = uint(target.{read_expr});")

            L.append("    }")

            L.append("")

            state_kind = detail.get("state_kind", "enum")

            L.append(f"    function _snapshot_after_{s}() internal {{")

            if state_kind == "bool":
                L.append(f"        curr_{s} = target.{read_expr} ? 1 : 0;")
            else:
                L.append(f"        curr_{s} = uint(target.{read_expr});")

            # -------- terminal tracking --------
            terminal_value_indices = resolve_terminal_value_indices(detail)
            for idx_str in terminal_value_indices:
                L.append(f"        if(curr_{s} == {idx_str}) entered_terminal_{s} = true;")

            # -------- transition evidence tracking --------
            facts = get_transition_facts_for_state(state_machine, s)

            for tf in facts:
                to_v = tf.get("to")
                if to_v is None:
                    continue

                if str(to_v).isdigit():
                    L.append(f"        // observed transition to {to_v}")
                    L.append(f"        if(curr_{s} == {to_v}) seen_{s} = true;")

            L.append("    }")


    for name, f in functions.items():
        if not is_externally_callable_function(f):
            continue
        if f.get("stateMutability") in ["view", "pure"]:
            continue

        kind = f.get("kind", "")

        # special: receive()
        if name == "__receive__" or kind == "receive":
            L.append("")
            L.append("    function call_receive() public {")
            L.append("        nonce++;")
            L.append("        address sender = actors[nonce % actors.length];")
            L.append("        callCount[sender]++;")

            if use_state_snapshot:
                for s, _read_expr in readable_states:
                    L.append(f"        _snapshot_before_{s}();")

            L.append(f"        {vm_ref}.startPrank(sender);")
            L.append("        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;")
            L.append("        ethSent[sender] += value;")

            if profile == "modern":
                L.append('        (bool ok,) = address(target).call{value:value}("");')
            else:
                L.append('        (bool ok,) = address(target).call.value(value)("");')

            # L.append("        ok;")
            L.append("        lastCallOk = ok;")
            L.append(f"        {vm_ref}.stopPrank();")
            L.append("        attemptedCalls++;")
            L.append("        if(lastCallOk) successfulCalls++; else revertedCalls++;")

            if use_state_snapshot:
                for s, _read_expr in readable_states:
                    L.append(f"        _snapshot_after_{s}();")

            L.append("    }")
            continue

        # special: fallback()
        if name == "__fallback__" or kind == "fallback":
            L.append("")
            L.append("    function call_fallback() public {")
            L.append("        nonce++;")
            L.append("        address sender = actors[nonce % actors.length];")
            L.append("        callCount[sender]++;")

            if use_state_snapshot:
                for s, _read_expr in readable_states:
                    L.append(f"        _snapshot_before_{s}();")

            L.append(f"        {vm_ref}.startPrank(sender);")
            L.append("        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;")
            L.append("        ethSent[sender] += value;")

            if profile == 'modern':
                L.append('        (bool ok,) = address(target).call{value:value}(hex"01");')
            else:
                L.append('        (bool ok,) = address(target).call.value(value)(hex"01");')

            L.append("        lastCallOk = ok;")
            L.append(f"        {vm_ref}.stopPrank();")
            L.append("        attemptedCalls++;")
            L.append("        if(lastCallOk) successfulCalls++; else revertedCalls++;")

            if use_state_snapshot:
                for s, _read_expr in readable_states:
                    L.append(f"        _snapshot_after_{s}();")

            L.append("    }")
            continue

        params = f.get("parameters", {}).get("parameters", [])
        mut = f.get("stateMutability", "")

        skip_function = False

        for p in params:
            typ = p.get("typeDescriptions", {}).get("typeString", "")
            # mapping/function 鐪熶笉鏀寔
            if "mapping" in typ or "function" in typ:
                skip_function = True
                break

            # tuple/struct 鍏堜繚瀹堣烦杩?handler wrapper锛岄伩鍏?Solidity 褰㈠弬澹版槑涓嶅吋瀹?
            if "tuple" in typ or "struct " in typ:
                skip_function = True
                break

        if skip_function:
            continue

        param_defs = []
        arg_names = []
        param_types = []

        for i, p in enumerate(params):

            raw_typ = p.get("typeDescriptions", {}).get("typeString", "uint256")
            raw_typ = raw_typ.strip()

            typ = normalize_handler_param_type(raw_typ)

            arg = f"arg{i}"

            param_defs.append(f"{typ} {arg}")
            arg_names.append(arg)
            param_types.append(typ)

        param_str = ",".join(param_defs)
        arg_str = ",".join(arg_names)

        L.append("")
        L.append(f"    function call_{name}({param_str}) public {{")

        owner_functions = [f["name"] for f in access]
        L.append("        nonce++;")
        if name in owner_functions:
            L.append("        address sender = address(this);")
        else:
            L.append("        address sender = actors[nonce % actors.length];")

        L.append("        callCount[sender]++;")

        if use_state_snapshot:
            for s, _read_expr in readable_states:
                L.append(f"        _snapshot_before_{s}();")

        # L.append("        vm.startPrank(sender);")
        L.append(f"        {vm_ref}.startPrank(sender);")

        for i, typ in enumerate(param_types):
            typ_n = _strip_data_location(typ)

            # 鍙鏍囬噺 uint 鍋?bound
            bound_stmt = _integer_bound_assignment(f"arg{i}", typ_n)
            if bound_stmt:
                L.append(f"        {bound_stmt}")

            # 鍙鏍囬噺 address 鍋?actor 鏄犲皠
            if typ_n == "address payable":
                L.append(f"        arg{i} = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg{i}))) % actors.length]));")
            elif typ_n == "address":
                L.append(f"        arg{i} = actors[uint256(keccak256(abi.encodePacked(arg{i}))) % actors.length];")
                
        if mut == "payable":

            L.append("        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;")
            L.append("        ethSent[sender] += value;")

            if use_try_catch:
                if arg_str == "":
                    L.append(f"        try target.{name}{{value:value}}() {{")
                    L.append("            lastCallOk = true;")
                    L.append("        } catch {")
                    L.append("            lastCallOk = false;")
                    L.append("        }")
                else:
                    L.append(f"        try target.{name}({arg_str}){{value:value}} {{")
                    L.append("            lastCallOk = true;")
                    L.append("        } catch {")
                    L.append("            lastCallOk = false;")
                    L.append("        }")
            else:
                # legacy: 浣庣骇璋冪敤鏇夸唬 try/catch
                sig = build_function_signature(f)
                if arg_str == "":
                    L.append(f'        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("{sig}"));')
                else:
                    L.append(f'        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("{sig}", {arg_str}));')
                L.append("        lastCallOk = ok;")

        else:

            if use_try_catch:
                if arg_str == "":
                    L.append(f"        try target.{name}() {{")
                    L.append("            lastCallOk = true;")
                    L.append("        } catch {")
                    L.append("            lastCallOk = false;")
                    L.append("        }")
                else:
                    L.append(f"        try target.{name}({arg_str}) {{")
                    L.append("            lastCallOk = true;")
                    L.append("        } catch {")
                    L.append("            lastCallOk = false;")
                    L.append("        }")
            else:
                sig = build_function_signature(f)
                if arg_str == "":
                    L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')
                else:
                    L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {arg_str}));')
                L.append("        lastCallOk = ok;")

        # L.append("        vm.stopPrank();")
        L.append(f"        {vm_ref}.stopPrank();")
        L.append("        attemptedCalls++;")
        L.append("        if(lastCallOk) successfulCalls++; else revertedCalls++;")
        
        if use_state_snapshot:
            for s, _read_expr in readable_states:
                L.append(f"        _snapshot_after_{s}();")

        L.append("    }")

    L.append("}")

    return L

def build_default_call_args(sig: str):
    """
    鏃х増 fallback锛?
    浠呴€傜敤浜庣畝鍗曟爣閲忕鍚嶅瓧绗︿覆銆?
    瀵?tuple / 宓屽鏁扮粍绛惧悕涓嶅彲闈狅紝鍥犳鍙兘浣滀负 AST 榛樿鍊肩敓鎴愬け璐ユ椂鐨勫厹搴曘€?
    """
    inside = sig[sig.find("(")+1:sig.rfind(")")]
    if inside.strip() == "":
        return ""

    parts = [x.strip() for x in inside.split(",")]
    vals = []

    for t in parts:
        if "address payable" in t:
            vals.append("payable(address(0xdead))")
        elif "address" in t:
            vals.append("address(0xdead)")
        elif "uint" in t or "int" in t:
            vals.append("1")
        elif "bool" in t:
            vals.append("false")
        elif "bytes32" in t:
            vals.append("bytes32(0)")
        elif "bytes" in t:
            vals.append('hex""')
        elif "string" in t:
            vals.append('""')
        else:
            vals.append("0")

    return ", ".join(vals)

def build_default_call_args_from_function(fn):
    """
    浼樺厛浠?AST FunctionDefinition 鐢熸垚榛樿鍙傛暟鍊笺€?
    """
    return build_default_arg_literals_from_function_def(fn)

def _function_param_count(fn):
    if not isinstance(fn, dict):
        return 0
    return len((fn.get("parameters", {}) or {}).get("parameters", []) or [])


def _function_return_count(fn):
    if not isinstance(fn, dict):
        return 0
    returns = (
        (fn.get("returnParameters", {}) or {}).get("parameters", [])
        or (fn.get("returns", {}) or {}).get("parameters", [])
        or fn.get("outputs", [])
        or []
    )
    return len(returns)


def _is_view_or_pure(fn):
    if not isinstance(fn, dict):
        return False
    return fn.get("stateMutability") in ["view", "pure"]


def _has_mapping_getter(functions, name):
    fn = (functions or {}).get(name)
    return bool(fn and _function_param_count(fn) == 1 and _is_view_or_pure(fn))


def _has_scalar_getter(functions, name):
    if str(name).lower() in {"balance"}:
        return False
    fn = (functions or {}).get(name)
    return bool(
        fn
        and _function_param_count(fn) == 0
        and _function_return_count(fn) <= 1
        and _is_view_or_pure(fn)
    )


def _mapping_read_alias(var_name, functions):
    aliases = {
        "_balances": "balanceOf",
    }
    target = aliases.get(var_name)
    if target and _has_mapping_getter(functions, target):
        return target
    if var_name.startswith("_"):
        cand = var_name[1:]
        if _has_mapping_getter(functions, cand):
            return cand
    return None


def is_mapping_readable_from_target(storage, mapping_name, functions):
    meta = (storage or {}).get(mapping_name)
    if not isinstance(meta, dict) or not meta.get("is_mapping"):
        return False
    if meta.get("visibility") == "public":
        return True
    if _has_mapping_getter(functions, mapping_name):
        return True
    return _mapping_read_alias(mapping_name, functions) is not None


def _readable_state_entries(state_machine, functions, storage=None):
    entries = []
    for state_var in (state_machine or {}).get("states", []) or []:
        read_expr = resolve_state_read_expr(state_var, functions, storage=storage)
        if read_expr:
            entries.append((state_var, read_expr))
    return entries


def build_handler_api_table(profile, state_machine, functions, storage=None):
    """
    Describe which public Handler getters will actually exist in generated code.

    Modern handlers declare state snapshot fields for state_machine states. Legacy
    handlers intentionally do not, so terminal invariants must not reference
    handler.entered_terminal_<state>() / handler.curr_<state>() there.
    """
    states = {}
    if profile == "modern":
        for s, read_expr in _readable_state_entries(state_machine, functions, storage=storage):
            states[s] = {
                "entered_terminal": True,
                "curr": True,
                "prev": True,
                "seen": True,
                "read_expr": read_expr,
            }
    return {"profile": profile, "states": states}


def handler_has_terminal_tracker(handler_api, state_var):
    meta = ((handler_api or {}).get("states") or {}).get(state_var) or {}
    return bool(meta.get("entered_terminal") and meta.get("curr"))


def record_dropped_invariant(state_machine, kind, state_var, reason, detail=None):
    if not isinstance(state_machine, dict):
        return
    state_machine.setdefault("dropped_invariants", []).append({
        "kind": kind,
        "state_var": state_var,
        "dropped_reason": reason,
        "detail": detail or {},
    })


def is_scalar_readable_from_target(storage, scalar_name, functions):
    meta = (storage or {}).get(scalar_name)
    if not isinstance(meta, dict) or meta.get("is_mapping"):
        return False
    if meta.get("visibility") == "public":
        return True
    if _has_scalar_getter(functions, scalar_name):
        return True
    aliases = {
        "_totalSupply": "totalSupply",
        "_owner": "owner",
        "_paused": "paused",
    }
    target = aliases.get(scalar_name)
    if target and _has_scalar_getter(functions, target):
        return True
    if scalar_name.startswith("_") and _has_scalar_getter(functions, scalar_name[1:]):
        return True
    return False


def is_accounting_pair_testable(storage, mapping_name, supply_name, functions=None):
    """
    杞婚噺杩囨护锛氬彧瀵规槑鏄惧彲娴嬭瘯鐨?pair 鐢熸垚 anomaly test
    - mapping 蹇呴』鏄?mapping
    - supply 蹇呴』鏄?uint-like scalar
    """
    if mapping_name not in storage or supply_name not in storage:
        return False

    m = storage[mapping_name]
    s = storage[supply_name]

    if not m.get("is_mapping"):
        return False
    if not s.get("is_uint") or s.get("is_mapping"):
        return False

    if functions is not None:
        if not is_mapping_readable_from_target(storage, mapping_name, functions):
            return False
        if not is_scalar_readable_from_target(storage, supply_name, functions):
            return False

    return True

def infer_named_accounting_pairs_from_storage(storage, existing_accounting=None, functions=None):
    """
    Conservative fallback for token-like contracts where update-fact fusion is
    too sparse, especially on legacy Solidity ASTs.

    This only adds sum/supply accounting candidates. It is intentionally called
    after accounting-anomaly inference so name-only pairs do not create directed
    delta anomaly tests.
    """
    existing_accounting = existing_accounting or []
    seen = {
        (item.get("mapping"), item.get("supply"))
        for item in existing_accounting
        if isinstance(item, dict)
    }

    mapping_tokens = ("balance", "balances", "balanceof")
    supply_tokens = ("totalsupply", "supply")

    mappings = []
    supplies = []
    for name, meta in (storage or {}).items():
        if not isinstance(meta, dict):
            continue
        lower = str(name).lower().lstrip("_")
        if meta.get("is_mapping") and meta.get("is_uint") and any(tok in lower for tok in mapping_tokens):
            mappings.append(name)
        elif meta.get("is_uint") and not meta.get("is_mapping") and any(tok in lower for tok in supply_tokens):
            supplies.append(name)

    inferred = []
    for mapping_name in mappings:
        for supply_name in supplies:
            if (mapping_name, supply_name) in seen:
                continue
            if not is_accounting_pair_testable(storage, mapping_name, supply_name, functions):
                continue
            inferred.append({
                "type": "accounting",
                "mapping": mapping_name,
                "supply": supply_name,
                "via_function": "",
                "mapping_op": None,
                "supply_op": None,
                "delta": None,
                "confidence": "name_fallback",
                "evidence_functions": [],
                "evidence_pairs": [{
                    "function": None,
                    "mapping_op": None,
                    "supply_op": None,
                    "delta": None,
                    "confidence": "name_fallback",
                    "source": "storage_name_fallback",
                }],
            })
            seen.add((mapping_name, supply_name))

    return inferred

def resolve_scalar_read_expr(var_name, functions):
    """
    鎶?storage 鍚嶈В鏋愭垚鍙粠 target 璇诲彇鐨勮〃杈惧紡瀛楃涓诧紙涓嶅甫 target. 鍓嶇紑锛?
    浼樺厛瑙勫垯锛?
    1. 濡傛灉瀛樺湪鍚屽悕 0鍙?view/pure/public getter锛屽垯鐩存帴鐢?var_name()
    2. 甯歌鍐呴儴鍙橀噺鍚嶅惎鍙戝紡鏄犲皠锛?
       _totalSupply -> totalSupply()
       _owner -> owner()
       _paused -> paused()
    3. 鏈€鍚庡厹搴曟墠灏濊瘯 var_name()
    """
    # 1) 鍚屽悕 getter
    fn = functions.get(var_name)
    if fn:
        params = fn.get("parameters", {}).get("parameters", [])
        if len(params) == 0 and _function_return_count(fn) == 1 and fn.get("stateMutability") in ["view", "pure"]:
            return f"{var_name}()"

    # 2) 甯歌鍐呴儴鍙橀噺鏄犲皠
    aliases = {
        "_totalSupply": "totalSupply()",
        "_owner": "owner()",
        "_paused": "paused()",
    }
    if var_name in aliases and aliases[var_name].split("(")[0] in functions:
        return aliases[var_name]

    # 3) 鍘诲墠瀵间笅鍒掔嚎灏濊瘯
    if var_name.startswith("_"):
        cand = var_name[1:]
        fn = functions.get(cand)
        if fn:
            params = fn.get("parameters", {}).get("parameters", [])
            if len(params) == 0 and _function_return_count(fn) == 1 and fn.get("stateMutability") in ["view", "pure"]:
                return f"{cand}()"

    return None

def resolve_mapping_read_expr(var_name, arg_expr, functions, storage=None):
    """
    鎶?mapping storage 鍚嶈В鏋愭垚鍙粠 target 璇诲彇鐨勮〃杈惧紡瀛楃涓诧紙涓嶅甫 target. 鍓嶇紑锛?
    渚嬪:
      _balances + a -> balanceOf(a)
    """
    # 1) 鍚屽悕 getter锛坧ublic mapping 鐨勬儏鍐碉級
    if _has_mapping_getter(functions, var_name):
        return f"{var_name}({arg_expr})"

    meta = (storage or {}).get(var_name)
    if isinstance(meta, dict) and meta.get("visibility") == "public" and meta.get("is_mapping"):
        return f"{var_name}({arg_expr})"

    # 2) 甯歌鍐呴儴鍙橀噺鏄犲皠
    alias = _mapping_read_alias(var_name, functions)
    if alias:
        return f"{alias}({arg_expr})"

    # 3) 鍘诲墠瀵间笅鍒掔嚎灏濊瘯
    # 4) fallback
    return None


def resolve_state_read_expr(state_var, functions, storage=None):
    """
    灏嗙姸鎬佸彉閲忓悕瑙ｆ瀽鎴愬彲浠?target 璇诲彇鐨勮〃杈惧紡锛堜笉甯?target. 鍓嶇紑锛?
    鍏煎:
    - public 鐘舵€佸彉閲忚嚜鍔?getter: paused()
    - 鏄惧紡 getter: stage()
    - 鍐呴儴鍙橀噺鍒板閮?getter 鐨勫埆鍚?
        _paused -> paused()
        _owner  -> owner()
        _totalSupply -> totalSupply()
    """
    # 1. 鍚屽悕 getter
    fn = functions.get(state_var)
    if fn:
        params = fn.get("parameters", {}).get("parameters", [])
        if len(params) == 0 and _function_return_count(fn) == 1 and fn.get("stateMutability") in ["view", "pure"]:
            return f"{state_var}()"

    meta = (storage or {}).get(state_var)
    if isinstance(meta, dict) and meta.get("visibility") == "public" and not meta.get("is_mapping"):
        return f"{state_var}()"

    # 2. 甯歌鍐呴儴鍙橀噺鍒悕
    aliases = {
        "_paused": "paused()",
        "_owner": "owner()",
        "_totalSupply": "totalSupply()",
    }
    if state_var in aliases:
        getter_name = aliases[state_var].split("(")[0]
        if getter_name in functions:
            return aliases[state_var]

    # 3. 鍘绘帀鍓嶅涓嬪垝绾垮皾璇?
    if state_var.startswith("_"):
        cand = state_var[1:]
        fn = functions.get(cand)
        if fn:
            params = fn.get("parameters", {}).get("parameters", [])
            if len(params) == 0 and _function_return_count(fn) == 1 and fn.get("stateMutability") in ["view", "pure"]:
                return f"{cand}()"

    return None

def build_default_value_for_abi_type(type_str: str):
    """
    鍚戝悗鍏煎鍏ュ彛锛?
    涓嶅甫 components 鏃讹紝璧板寮虹増鐨勭畝鍖栬矾寰勩€?
    """
    return build_default_value_for_abi_type_ex(type_str, components=None, depth=0)

def _split_tuple_types(inner: str):
    """
    灏?tuple 鍐呴儴绫诲瀷涓叉寜椤跺眰閫楀彿鎷嗗垎銆?
    渚嬪:
      "uint256,address"
      "tuple(uint256,bool),bytes32[]"
    """
    s = (inner or "").strip()
    if not s:
        return []

    parts = []
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
            parts.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)

    if cur:
        parts.append("".join(cur).strip())

    return [p for p in parts if p]


def _strip_data_location(type_str: str) -> str:
    t = (type_str or "").strip()
    for kw in [" memory", " calldata", " storage"]:
        t = t.replace(kw, "")
    return " ".join(t.split())


def _integer_bound_assignment(arg_name: str, type_str: str, bound: int = 1000) -> Optional[str]:
    """
    Build a Solidity assignment that narrows fuzzed integer args without relying
    on implicit casts. Old solc versions widen expressions like uint8 % 1000,
    then reject assigning the widened result back to uint8.
    """
    typ = _strip_data_location(type_str)
    if "[" in typ:
        return None

    m = re.fullmatch(r"(u?int)(\d*)", typ)
    if not m:
        return None

    family = m.group(1)
    bits = int(m.group(2) or "256")
    if bits <= 0 or bits > 256 or bits % 8 != 0:
        bits = 256

    if family == "uint":
        limit = min(bound, 2 ** bits)
        return f"{arg_name} = {typ}(uint256({arg_name}) % {limit});"

    # Keep signed inputs in a small, non-negative range. This is enough to
    # reduce revert noise while compiling cleanly for int8/int16/... on 0.4.x.
    positive_limit = min(bound, 2 ** (bits - 1))
    return f"{arg_name} = {typ}(int256({arg_name}) % int256({positive_limit}));"


def _parse_array_suffixes(type_str: str):
    """
    灏?'uint256[][2]' 鎷嗘垚:
      base='uint256'
      dims=['[]', '[2]']
    """
    t = _strip_data_location(type_str)
    dims = []

    while t.endswith("]"):
        i = t.rfind("[")
        if i == -1:
            break
        dims.insert(0, t[i:])
        t = t[:i].strip()

    return t, dims

def _is_tuple_like_param(param_def: dict) -> bool:
    """
    ABI 閲?struct 鍙傛暟閫氬父琛ㄧ幇涓?
      type = tuple / tuple[]
      internalType = struct Xxx.Yyy / struct Xxx.Yyy[]
      components != []
    """
    if not isinstance(param_def, dict):
        return False

    typ = _strip_data_location(param_def.get("type", "") or "")
    internal_typ = _strip_data_location(param_def.get("internalType", "") or "")
    components = param_def.get("components", []) or []

    if components:
        return True

    base_t, _ = _parse_array_suffixes(typ)
    if base_t == "tuple" or base_t.startswith("tuple("):
        return True

    base_it, _ = _parse_array_suffixes(internal_typ)
    if base_it.startswith("struct "):
        return True

    return False

def _normalize_sol_type_name(type_name: str) -> str:
    """
    灏?ABI/internalType 椋庢牸绫诲瀷鍚嶈浆鎴愬彲鐩存帴鍐欏叆 Solidity 婧愮爜鐨勭被鍨嬪悕銆?

    渚嬪:
      "struct ParamCoverageTest.Pair" -> "ParamCoverageTest.Pair"
      "enum MyC.E" -> "MyC.E"
      "contract Foo" -> "Foo"
      "interface IBar" -> "IBar"
    """
    t = _strip_data_location(type_name or "")

    prefixes = ["struct ", "enum ", "contract ", "interface "]
    for p in prefixes:
        if t.startswith(p):
            return t[len(p):].strip()

    return t

def _solidity_decl_type(type_name: str) -> str:
    """Return a Solidity source-level type name for declarations.

    ABI entries usually expose user-defined contract/interface parameters as
    `address`, while AST/internalType keeps the stronger source type, e.g.
    `contract ComptrollerInterface` or `interface IERC20[]`.  Generated Foundry
    harnesses must declare/cast to the source type when it is available;
    otherwise Solidity rejects address/address[] defaults for contract-typed
    parameters.
    """
    return _normalize_sol_type_name(type_name or "")

def _default_address_literal_for_type(type_name: str) -> str:
    """Default address-like literal compatible with payable and UDT targets."""
    t = _strip_data_location(type_name or "")
    if t == "address payable":
        return "payable(address(0x1001))"
    if t == "address":
        return "address(0x1001)"
    if t.startswith("contract ") or t.startswith("interface "):
        name = _normalize_sol_type_name(t)
        return f"{name}(address(0x1001))" if name else "address(0x1001)"
    builtin_prefixes = ("uint", "int", "bytes", "string", "bool", "tuple", "address")
    if t and t[0].isupper() and not t.startswith(builtin_prefixes):
        return f"{t}(address(0x1001))"
    return "address(0x1001)"

def _is_source_contract_like_type(type_name: str) -> bool:
    t = _strip_data_location(type_name or "")
    if not t or t.startswith(("address", "uint", "int", "bytes")) or t in ("bool", "string"):
        return False
    return bool(re.fullmatch(r"[A-Za-z_][A-Za-z0-9_.]*(?:\[\])*", t))

def _default_ctor_expr_for_source_type(type_name: str, solc_version: str) -> Optional[str]:
    """Default constructor expression from a source-level declaration type."""
    t = _strip_data_location(type_name or "")
    version = parse_solc_version_number(solc_version)
    if t.startswith("address") and "payable" in t:
        return "address(uint160(address(0x1001)))" if version < (0, 6, 0) else "payable(address(0x1001))"
    if t == "address" or t.startswith("address "):
        return "address(0x1001)"
    if _is_source_contract_like_type(t):
        base = t
        while base.endswith("]"):
            i = base.rfind("[")
            if i < 0:
                break
            base = base[:i].strip()
        inner = "address(uint160(address(0x1001)))" if version < (0, 6, 0) else "address(0x1001)"
        return f"{base}({inner})"
    return None

def _build_tuple_decl_type(param_def: dict, rest_dims=None) -> str:
    """
    缁?tuple/struct 鍙傛暟鐢熸垚 Solidity 閲屽彲澹版槑鐨勭被鍨嬪悕銆?
    浼樺厛浣跨敤 internalType 涓殑 struct Xxx.Yyy銆?
    渚嬪:
      internalType = "struct ParamCoverageTest.Pair[]"
      rest_dims = ["[]"]
    -> "ParamCoverageTest.Pair[]"
    """
    rest_dims = rest_dims or []

    internal_typ = _strip_data_location(param_def.get("internalType", "") or "")
    typ = _strip_data_location(param_def.get("type", "") or "")

    base_it, _ = _parse_array_suffixes(internal_typ)
    base_t, _ = _parse_array_suffixes(typ)

    if base_it.startswith("struct "):
        return _normalize_sol_type_name(base_it) + "".join(rest_dims)

    if base_it.startswith("tuple"):
        return _normalize_sol_type_name(base_it) + "".join(rest_dims)

    if base_t.startswith("tuple"):
        return _normalize_sol_type_name(base_t) + "".join(rest_dims)

    return None

def _is_struct_internal_type(type_name: str) -> bool:
    """
    鍒ゆ柇涓€涓被鍨嬪悕鏄惁搴旀寜 Solidity struct 澶勭悊銆?
    鍏煎涓ょ被杈撳叆锛?
    - "struct ParamCoverageTest.Pair"
    - "ParamCoverageTest.Pair"
    """
    t = _strip_data_location(type_name or "")
    if not t:
        return False

    if t.startswith("struct "):
        return True

    # 宸茬粡琚?normalize 鍚庣殑 struct 鍚嶏紝濡?ParamCoverageTest.Pair
    # 鐢ㄨ交閲忓惎鍙戝紡锛氬甫 '.' 涓斾笉鏄熀纭€绫诲瀷鍓嶇紑锛屾寜 struct / user-defined type 澶勭悊
    builtin_prefixes = ("uint", "int", "bytes", "string", "bool", "address", "tuple")
    if "." in t and not t.startswith(builtin_prefixes):
        return True

    return False

def _build_default_array_literal(base_literal: str, dim: str):
    """
    dim:
      []   -> 鍔ㄦ€佹暟缁勶紝缁欎竴涓緢灏忕殑闈炵┖榛樿鍊?
      [2]  -> 瀹氶暱鏁扮粍锛屽睍寮€鎴?2 涓厓绱?
    """
    if base_literal is None:
        return None

    dim = (dim or "").strip()

    # 鍔ㄦ€佹暟缁勶細灏介噺缁欎竴涓暱搴︿负 1 鐨勫皬鏁扮粍锛岄伩鍏嶇┖鏁扮粍缁曡繃閫昏緫
    if dim == "[]":
        return f"[{base_literal}]"

    # 瀹氶暱鏁扮粍
    if dim.startswith("[") and dim.endswith("]"):
        n_str = dim[1:-1].strip()
        if n_str.isdigit():
            n = int(n_str)
            if n < 0 or n > 8:
                return None
            return "[" + ", ".join([base_literal] * n) + "]"

    return None


def build_default_value_for_abi_type_ex(type_str: str, components: list = None, depth: int = 0):
    """
    澧炲己鐗堥粯璁ゅ弬鏁板瓧闈㈤噺鐢熸垚鍣紝鏀寔锛?
    - 鍩虹绫诲瀷
    - 鍩虹绫诲瀷鏁扮粍
    - tuple / struct(ABI 涓€氬父浠?tuple 鍑虹幇)
    - tuple[]
    - contract/interface
    """
    if depth > 4:
        return None

    t = _strip_data_location(type_str)
    components = components or []

    # -------------------------------------------------
    # 1) 鍏堝鐞嗘暟缁?
    # -------------------------------------------------
    base_t, dims = _parse_array_suffixes(t)
    if dims:
        # 鍏堢敓鎴愭渶鍐呭眰鍏冪礌
        elem_literal = build_default_value_for_abi_type_ex(
            base_t,
            components=components,
            depth=depth + 1
        )
        if elem_literal is None:
            return None

        cur = elem_literal
        for dim in reversed(dims):
            cur = _build_default_array_literal(cur, dim)
            if cur is None:
                return None
        return cur

    # -------------------------------------------------
    # 2) tuple / struct
    # ABI 閲?struct 涓€鑸細鍙樻垚 tuple + components
    # -------------------------------------------------
    if t == "tuple" or t.startswith("tuple("):
        sub_types = []

        if components:
            for c in components:
                ct = (c.get("internalType") or c.get("type") or "").strip()
                cc = c.get("components", [])
                sub_types.append((ct if ct else c.get("type", ""), cc))
        elif t.startswith("tuple(") and t.endswith(")"):
            inner = t[len("tuple("):-1].strip()
            raw_parts = _split_tuple_types(inner)
            sub_types = [(p, []) for p in raw_parts]
        else:
            return None

        vals = []
        for sub_t, sub_comps in sub_types:
            v = build_default_value_for_abi_type_ex(
                sub_t,
                components=sub_comps,
                depth=depth + 1
            )
            if v is None:
                return None
            vals.append(v)

        return "(" + ", ".join(vals) + ")"

    # -------------------------------------------------
    # 3) 鍘熸湁鍩虹閫昏緫
    # -------------------------------------------------
    # 鍘熺敓鍦板潃
    if t == "address" or t == "address payable":
        return _default_address_literal_for_type(t)

    # contract / interface
    if t.startswith("contract "):
        return _default_address_literal_for_type(t)

    if t.startswith("interface "):
        return _default_address_literal_for_type(t)

    builtin_prefixes = ("uint", "int", "bytes", "string", "bool", "tuple", "address")
    if t and t[0].isupper() and not t.startswith(builtin_prefixes):
        return f"{t}(address(0x1001))"

    if t.startswith("uint") or t.startswith("int"):
        return "1"

    if t == "bool":
        return "false"

    if t == "string":
        return '""'

    if t == "bytes":
        return 'hex""'

    m = re.fullmatch(r"bytes(\d+)", t)
    if m:
        n = int(m.group(1))
        if 1 <= n <= 32:
            return f"bytes{n}(0)"
        return None

    return None

def build_constructor_args_from_abi(abi, source_text: Optional[str] = None, contract_name: str = "", solc_version: str = ""):

    if not abi:
        return {
            "prelude_lines": [],
            "args_str": ""
        }
    
    ctor = None
    for item in abi:
        if item.get("type") == "constructor":
            ctor = item
            break

    if ctor is None:
        return {
            "prelude_lines": [],
            "args_str": ""
        }

    prelude_lines = []
    arg_exprs = []
    context_contracts = set()
    context_bindings = []
    context_setup_lines = []
    ctor_decl_types = _extract_ctor_param_types_from_source(source_text, contract_name)
    ctor_inputs = ctor.get("inputs", []) or []

    for idx, inp in enumerate(ctor_inputs):
        pname = inp.get("name") or f"ctor_arg{idx}"
        source_decl_type = ""
        if ctor_decl_types and len(ctor_decl_types) == len(ctor_inputs):
            source_decl_type = ctor_decl_types[idx]

        semantic_plan = _semantic_ctor_param_plan(inp, idx, source_decl_type, solc_version)
        if semantic_plan is not None:
            prelude_lines.extend(semantic_plan.get("prelude_lines", []))
            context_contracts.update(semantic_plan.get("deps", set()) or set())
            context_bindings.extend(semantic_plan.get("context", []) or [])
            context_setup_lines.extend(semantic_plan.get("setup_lines", []) or [])
            arg_exprs.append(semantic_plan["expr"])
            continue

        plan = build_default_param_plan(
            inp,
            var_name=f"ctor_{pname}",
            depth=0
        )
        if plan is None:
            print("[ctor-plan] unsupported input:", {
                "name": pname,
                "type": inp.get("type"),
                "internalType": inp.get("internalType"),
                "components": inp.get("components"),
            })
            return None

        prelude_lines.extend(plan.get("prelude_lines", []))
        expr = plan["expr"]
        if source_decl_type:
            source_expr = _default_ctor_expr_for_source_type(source_decl_type, solc_version)
            if source_expr is not None:
                expr = source_expr
        arg_exprs.append(expr)

    print("[ctor-plan] built args:", {
        "prelude_lines": prelude_lines,
        "args_str": ", ".join(arg_exprs),
        "context_contracts": sorted(context_contracts),
        "context_bindings": context_bindings,
    })

    return {
        "prelude_lines": prelude_lines,
        "args_str": ", ".join(arg_exprs),
        "context_contracts": sorted(context_contracts),
        "context_bindings": context_bindings,
        "context_setup_lines": context_setup_lines,
    }

def _sanitize_sol_var_name(name: str, fallback: str = "arg") -> str:
    s = (name or "").strip()
    if not s:
        s = fallback

    out = []
    for i, ch in enumerate(s):
        if ch.isalnum() or ch == "_":
            if i == 0 and ch.isdigit():
                out.append("_")
            out.append(ch)
        else:
            out.append("_")

    s = "".join(out).strip("_")
    return s or fallback

def normalize_handler_param_type(type_str: str) -> str:
    """
    涓?handler wrapper 鐨勫嚱鏁板弬鏁扮被鍨嬭ˉ瓒?Solidity 鎵€闇€ data location銆?
    鍙鐞嗗弬鏁板０鏄庡満鏅紝涓嶆敼鍙樺熀纭€绫诲瀷銆?
    瑙勫垯锛?
    - 鏁扮粍 / bytes / string / tuple 缁熶竴琛?memory
    - 宸插甫 memory/calldata/storage 鐨勪繚鎸佹竻娲楀悗鍐嶈ˉ memory
    - 鍩虹鍊肩被鍨嬩笉鍙?
    """
    t = _strip_data_location(type_str)
    t = _normalize_sol_type_name(t)

    if not t:
        return "uint256"

    # 寮曠敤绫诲瀷锛氭暟缁?
    if "[" in t and "]" in t:
        return f"{t} memory"

    # 鍔ㄦ€?bytes / string
    if t == "bytes" or t == "string":
        return f"{t} memory"

    # tuple / struct 鍙傛暟锛堝鏋滃悗闈綘鏀惧紑 handler 瀵?tuple/struct 鐨勬敮鎸侊紝涔熻兘鐩存帴澶嶇敤锛?
    if t == "tuple" or t.startswith("tuple"):
        return f"{t} memory"

    return t

def _param_requires_prelude(param_def: dict) -> bool:
    """
    鍒ゆ柇涓€涓弬鏁版槸鍚︿笉閫傚悎浠ュ唴鑱斿瓧闈㈤噺鏂瑰紡鐩存帴鍑虹幇鍦?
    - handler.call_xxx(...)
    - abi.encodeWithSignature(...)

    杩欎簺绫诲瀷鏀圭敤 prelude 涓存椂鍙橀噺鏇寸ǔ锛?
    - 浠绘剰鏁扮粍
    - tuple / struct
    """
    if not isinstance(param_def, dict):
        return False

    typ = (param_def.get("type") or "").strip()
    internal_typ = (param_def.get("internalType") or "").strip()

    if not typ:
        typ = (param_def.get("typeDescriptions", {}) or {}).get("typeString", "").strip()
    if not internal_typ:
        internal_typ = typ

    t1 = _strip_data_location(typ)
    t2 = _strip_data_location(internal_typ)

    if "[" in t1 or "[" in t2:
        return True

    if _is_tuple_like_param(param_def):
        return True

    return False

def build_default_param_plan(param_def: dict, var_name: str = "arg", depth: int = 0):
    """
    杩斿洖:
    {
        "prelude_lines": [...],
        "expr": "..."
    }

    鏀寔:
    - 鏍囬噺
    - 鍔ㄦ€佹暟缁?
    - 瀹氶暱鏁扮粍
    - tuple / struct
    - tuple[] / struct[]
    """
    if depth > 4:
        return None

    if not isinstance(param_def, dict):
        return None

    typ = (param_def.get("type") or "").strip()
    internal_typ = (param_def.get("internalType") or "").strip()
    components = param_def.get("components", []) or []

    if not typ:
        typ = (param_def.get("typeDescriptions", {}) or {}).get("typeString", "").strip()
    if not internal_typ:
        internal_typ = typ

    clean_name = _sanitize_sol_var_name(var_name, "arg")

    abi_full_t = _strip_data_location(typ)
    internal_full_t = _strip_data_location(internal_typ)

    abi_base_t, abi_dims = _parse_array_suffixes(abi_full_t)
    internal_base_t, internal_dims = _parse_array_suffixes(internal_full_t)

    # -------------------------------------------------
    # 1) 鏁扮粍
    # -------------------------------------------------
    if abi_dims or internal_dims:
        dims = abi_dims if abi_dims else internal_dims
        outer = dims[0]
        rest_dims = dims[1:]

        is_tuple_like = _is_tuple_like_param(param_def)

        if is_tuple_like:
            elem_param_def = {
                "type": "tuple" + "".join(rest_dims),
                "internalType": _build_tuple_decl_type(param_def, rest_dims=rest_dims) or ("tuple" + "".join(rest_dims)),
                "components": components,
            }
        else:
            elem_param_def = {
                "type": abi_base_t + "".join(rest_dims),
                "internalType": internal_base_t + "".join(rest_dims),
                "components": components,
            }

        elem_plan = build_default_param_plan(
            elem_param_def,
            var_name=f"{clean_name}_elem0",
            depth=depth + 1
        )
        if elem_plan is None:
            return None

        # prelude = []
        # prelude.extend(elem_plan.get("prelude_lines", []))

        # # 澹版槑绫诲瀷浼樺厛鐢?internalType锛岃繖鏍?struct 鏁扮粍鑳藉啓鎴?
        # # struct ParamCoverageTest.Pair;
        # arr_decl_type = _normalize_sol_type_name(internal_full_t if internal_full_t else abi_full_t)

        # # 鍒嗛厤绫诲瀷涓嶈兘甯?storage/calldata/memory
        # alloc_base_type = None
        # if is_tuple_like:
        #     alloc_base_type = _build_tuple_decl_type(param_def, rest_dims=[])
        # else:
        #     alloc_base_type = internal_base_t if internal_base_t else abi_base_t

        # if alloc_base_type is None:
        #     return None

        # arr_var = clean_name

        # # 鍔ㄦ€佹暟缁?
        # if outer == "[]":
        #     alloc_type = alloc_base_type + "[]"
        #     prelude.append(f"{arr_decl_type} memory {arr_var} = new {alloc_type}(1);")
        #     prelude.append(f"{arr_var}[0] = {elem_plan['expr']};")
        #     return {
        #         "prelude_lines": prelude,
        #         "expr": arr_var
        #     }

        prelude = []
        prelude.extend(elem_plan.get("prelude_lines", []))

        # 澹版槑绫诲瀷锛氬彲甯︾敤鎴疯嚜瀹氫箟绫诲瀷鍚嶏紝浣嗕笉鑳藉甫 struct/enum/interface 鍓嶇紑
        arr_decl_type = _solidity_decl_type(
            internal_full_t if internal_full_t else abi_full_t
        )

        # new 鍒嗛厤绫诲瀷锛氫篃蹇呴』鏄笉甯?struct 鍓嶇紑鐨勭函 Solidity 绫诲瀷鍚?
        alloc_base_type = None
        if is_tuple_like:
            alloc_base_type = _build_tuple_decl_type(param_def, rest_dims=[])
        else:
            alloc_base_type = internal_base_t if internal_base_t else abi_base_t

        if alloc_base_type is None:
            return None

        alloc_base_type = _solidity_decl_type(alloc_base_type)

        arr_var = clean_name

        # 鍔ㄦ€佹暟缁?
        if outer == "[]":
            alloc_type = alloc_base_type + "[]"
            prelude.append(f"{arr_decl_type} memory {arr_var} = new {alloc_type}(1);")
            prelude.append(f"{arr_var}[0] = {elem_plan['expr']};")
            return {
                "prelude_lines": prelude,
                "expr": arr_var
            }

        # 瀹氶暱鏁扮粍
        if outer.startswith("[") and outer.endswith("]"):
            n_str = outer[1:-1].strip()
            if n_str.isdigit():
                n = int(n_str)
                if n < 0 or n > 8:
                    return None

                prelude.append(f"{arr_decl_type} memory {arr_var};")
                for i in range(n):
                    prelude.append(f"{arr_var}[{i}] = {elem_plan['expr']};")

                return {
                    "prelude_lines": prelude,
                    "expr": arr_var
                }

        return None

    # -------------------------------------------------
    # 2) tuple / struct
    # -------------------------------------------------
    if _is_tuple_like_param(param_def):
        vals = []
        prelude = []

        for i, c in enumerate(components):
            sub_plan = build_default_param_plan(
                c,
                var_name=f"{clean_name}_{i}",
                depth=depth + 1
            )
            if sub_plan is None:
                return None
            prelude.extend(sub_plan.get("prelude_lines", []))
            vals.append(sub_plan["expr"])

        # 杩欓噷涓嶈鍙湅 internal_typ锛屽洜涓烘暟缁勯€掑綊鏃?internalType 鍙兘宸茬粡琚鑼冨寲鎴?ParamCoverageTest.Pair
        struct_like_name = _normalize_sol_type_name(internal_typ or typ)

        if _is_struct_internal_type(internal_typ) or _is_struct_internal_type(struct_like_name):
            struct_expr = f"{struct_like_name}(" + ", ".join(vals) + ")"
            return {
                "prelude_lines": prelude,
                "expr": struct_expr
            }

        # 绾?tuple 淇濇寔 tuple literal
        return {
            "prelude_lines": prelude,
            "expr": "(" + ", ".join(vals) + ")"
        }

    # -------------------------------------------------
    # 3) scalar
    # -------------------------------------------------
    literal = build_default_value_for_abi_type_ex(
        internal_full_t or abi_full_t,
        components=components,
        depth=depth + 1
    )
    if literal is None:
        return None

    return {
        "prelude_lines": [],
        "expr": literal
    }

def _extract_components_from_ast_param(param_def: dict):
    """
    灏濊瘯浠?AST parameter 涓仮澶?tuple / struct 鐨?components銆?
    杩欐槸 ABI 涓?components 缂哄け鏃剁殑鍏滃簳鎭㈠銆?

    杩斿洖鏍煎紡灏介噺涓?ABI components 瀵归綈:
    [
        {"type": "...", "internalType": "...", "components": [...]},
        ...
    ]
    """
    if not isinstance(param_def, dict):
        return []

    # 1) ABI 椋庢牸鐜版垚 components
    comps = param_def.get("components", [])
    if isinstance(comps, list) and comps:
        return comps

    type_name = param_def.get("typeName", {})
    if not isinstance(type_name, dict):
        return []

    nt = type_name.get("nodeType", "")

    # 2) tuple / struct 鍙傛暟鍦ㄨ緝鏂?AST 涓父瑙佷负 TupleTypeName
    if nt == "TupleTypeName":
        out = []
        for comp in type_name.get("components", []) or []:
            if not isinstance(comp, dict):
                continue

            sub_type = ""
            sub_internal = ""

            # 浼樺厛 typeDescriptions.typeString
            if "typeDescriptions" in comp:
                sub_type = (comp.get("typeDescriptions", {}) or {}).get("typeString", "") or ""

            # fallback: typeName -> expr_to_str
            if not sub_type and "typeName" in comp:
                sub_type = expr_to_str(comp.get("typeName", {}))

            sub_internal = sub_type

            out.append({
                "type": sub_type,
                "internalType": sub_internal,
                "components": _extract_components_from_ast_param(comp)
            })
        return out

    # 3) struct 鍙傛暟鏈夋椂浼氭槸 UserDefinedTypeName锛岃繖閲屾病鏈夊瓧娈靛垪琛ㄥ彲鎭㈠锛屽彧鑳借繑鍥炵┖
    return []

def build_default_value_from_param_def(param_def: dict):
    """
    浠?ABI input / AST parameter 鑺傜偣鐢熸垚榛樿鍊笺€?
    鍏煎:
    - ABI constructor/function inputs
    - AST parameters.parameters[] 鍏冪礌
    """
    if not isinstance(param_def, dict):
        return None

    typ = (param_def.get("type") or "").strip()
    internal_typ = (param_def.get("internalType") or "").strip()
    components = param_def.get("components", []) or []

    # AST parameter fallback
    if not typ:
        typ = (param_def.get("typeDescriptions", {}) or {}).get("typeString", "").strip()

    if not internal_typ:
        internal_typ = typ

    # 鍏抽敭琛ュ厖锛欰ST 娌℃湁 ABI-style components 鏃讹紝灏濊瘯浠?typeName 鎭㈠
    if not components:
        components = _extract_components_from_ast_param(param_def)

    v = None

    if internal_typ:
        v = build_default_value_for_abi_type_ex(
            internal_typ,
            components=components,
            depth=0
        )

    if v is None and typ:
        v = build_default_value_for_abi_type_ex(
            typ,
            components=components,
            depth=0
        )

    return v

def build_default_arg_literals_from_function_def(fn):
    """
    鍙敓鎴愨€滃彲瀹夊叏鍐呰仈鈥濈殑榛樿鍙傛暟涓层€?
    瀵规暟缁?/ tuple / struct 杩欑被鏇撮€傚悎鍏堝０鏄庝复鏃跺彉閲忕殑鍙傛暟锛岃繑鍥?None銆?

    杩欐牱鍙互閬垮厤鍦ㄤ互涓嬪満鏅紩鍏ユ柊鐨?Solidity 缂栬瘧閿欒锛?
    - handler.call_xxx(...)
    - abi.encodeWithSignature(..., inline_complex_arg)
    """
    if not isinstance(fn, dict):
        return None

    params = fn.get("parameters", {}).get("parameters", []) or []
    vals = []

    for p in params:
        # 澶嶆潅绫诲瀷涓嶅仛鍐呰仈锛屼氦缁?build_default_args_plan_from_function_def()
        if _param_requires_prelude(p):
            return None

        v = build_default_value_from_param_def(p)
        if v is None:
            return None
        vals.append(v)

    return ", ".join(vals)

ROLE_PARAM_KEYWORDS = (
    "owner", "admin", "governance", "governor", "guardian", "operator",
    "manager", "keeper", "timelock", "multisig", "recipient", "beneficiary",
    "treasury", "fee", "collector",
)

TOKEN_PARAM_KEYWORDS = (
    "token", "underlying", "asset", "currency", "collateral", "reward",
    "rewards", "stable", "reserve", "share", "want", "lp",
)

WETH_PARAM_KEYWORDS = ("weth", "wrapped", "ether", "eth")

ORACLE_PARAM_KEYWORDS = (
    "oracle", "price", "feed", "aggregator", "chainlink", "rate", "quote",
)

EXTERNAL_PARAM_KEYWORDS = (
    "router", "factory", "pair", "pool", "vault", "controller", "comptroller",
    "strategy", "model", "gateway", "bridge", "registry", "proxy",
    "implementation", "beacon", "staking", "farm", "distributor",
)

TIME_PARAM_KEYWORDS = (
    "expiry", "expiration", "deadline", "maturity", "unlock", "release",
    "start", "end", "cliff", "duration", "period", "delay",
)

def _ctor_param_label(inp: dict, source_decl_type: str = "") -> str:
    return " ".join([
        str((inp or {}).get("name") or ""),
        str((inp or {}).get("type") or ""),
        str((inp or {}).get("internalType") or ""),
        str(source_decl_type or ""),
    ]).lower()

def _is_address_or_contract_like_ctor_param(inp: dict, source_decl_type: str = "") -> bool:
    typ = _strip_data_location((inp or {}).get("type") or "")
    internal = _strip_data_location((inp or {}).get("internalType") or "")
    decl = _strip_data_location(source_decl_type or "")
    candidates = [typ, internal, decl]
    for t in candidates:
        if not t:
            continue
        base, dims = _parse_array_suffixes(t)
        if dims:
            continue
        if base.startswith("address"):
            return True
        if base.startswith("contract ") or base.startswith("interface "):
            return True
        if _is_source_contract_like_type(base):
            return True
    return False

def _address_like_ctor_base_type(inp: dict, source_decl_type: str = "") -> str:
    typ = _strip_data_location((inp or {}).get("type") or "")
    internal = _strip_data_location((inp or {}).get("internalType") or "")
    decl = _strip_data_location(source_decl_type or "")
    for t in (decl, internal, typ):
        if not t:
            continue
        base, _dims = _parse_array_suffixes(t)
        base = _strip_data_location(base)
        if base.startswith("address"):
            return base
        if base.startswith("contract ") or base.startswith("interface "):
            return _normalize_sol_type_name(base)
        if _is_source_contract_like_type(base):
            return base
    return ""

def _is_address_or_contract_array_ctor_param(inp: dict, source_decl_type: str = "") -> bool:
    typ = _strip_data_location((inp or {}).get("type") or "")
    internal = _strip_data_location((inp or {}).get("internalType") or "")
    decl = _strip_data_location(source_decl_type or "")
    for t in (decl, internal, typ):
        if not t:
            continue
        base, dims = _parse_array_suffixes(t)
        if not dims:
            continue
        base = _strip_data_location(base)
        if base.startswith("address") or base.startswith("contract ") or base.startswith("interface ") or _is_source_contract_like_type(base):
            return True
    return False

def _solidity_ctor_array_decl_type(inp: dict, source_decl_type: str, default_base: str) -> str:
    source_t = _strip_data_location(source_decl_type or (inp or {}).get("internalType") or (inp or {}).get("type") or "")
    source_t = _solidity_decl_type(source_t) if source_t else ""
    base, dims = _parse_array_suffixes(source_t)
    if dims:
        return source_t
    return f"{_solidity_decl_type(default_base)}[]"

def _ctor_context_setup_lines(kind: str, var_name: str) -> List[str]:
    """Generic post-construction environment preparation for constructor mocks.

    These lines execute inside setUp() after handler construction.  They seed
    balances and allowances without assuming a benchmark-specific protocol.
    """
    if kind == "erc20":
        return [
            f"{var_name}.faucet(address(target), 1000000000000000000000000);",
            f"{var_name}.faucet(address(handler), 1000000000000000000000000);",
            f"for(uint256 i_ctx_{var_name}=0; i_ctx_{var_name}<handler.actorCount(); i_ctx_{var_name}++) {{",
            f"    {var_name}.faucet(handler.actor(i_ctx_{var_name}), 1000000000000000000000000);",
            f"    {var_name}.approve(address(target), 1000000000000000000000000);",
            f"}}",
        ]
    if kind == "weth":
        return [
            f"{var_name}.faucet(address(target), 1000000000000000000000000);",
            f"{var_name}.faucet(address(handler), 1000000000000000000000000);",
            f"for(uint256 i_ctx_{var_name}=0; i_ctx_{var_name}<handler.actorCount(); i_ctx_{var_name}++) {{",
            f"    {var_name}.faucet(handler.actor(i_ctx_{var_name}), 1000000000000000000000000);",
            f"    {var_name}.approve(address(target), 1000000000000000000000000);",
            f"}}",
        ]
    if kind == "oracle":
        return [f"{var_name}.setAnswer(1000000000000000000);"]
    if kind == "external":
        return [f"{var_name}.setValue(1000000000000000000);"]
    return []

def _ctor_address_kind(inp: dict, source_decl_type: str = "") -> str:
    label = _ctor_param_label(inp, source_decl_type)
    if any(k in label for k in ORACLE_PARAM_KEYWORDS):
        return "oracle"
    if any(k in label for k in WETH_PARAM_KEYWORDS):
        return "weth"
    if any(k in label for k in TOKEN_PARAM_KEYWORDS):
        return "erc20"
    if any(k in label for k in EXTERNAL_PARAM_KEYWORDS):
        return "external"
    if any(k in label for k in ROLE_PARAM_KEYWORDS):
        return "role"
    internal = _strip_data_location((inp or {}).get("internalType") or "")
    decl = _strip_data_location(source_decl_type or "")
    if internal.startswith(("contract ", "interface ")) or _is_source_contract_like_type(decl):
        return "external"
    return "external"

def _cast_address_expr_for_ctor(expr: str, inp: dict, source_decl_type: str, solc_version: str) -> str:
    abi_t = _strip_data_location((inp or {}).get("type") or "")
    internal_t = _strip_data_location((inp or {}).get("internalType") or "")
    decl = _strip_data_location(source_decl_type or "")
    source_t = decl or internal_t or abi_t
    version = parse_solc_version_number(solc_version)

    if source_t.startswith("contract ") or source_t.startswith("interface "):
        source_t = _normalize_sol_type_name(source_t)

    if _is_source_contract_like_type(source_t) and not source_t.startswith("address"):
        base = source_t
        while base.endswith("]"):
            i = base.rfind("[")
            if i < 0:
                break
            base = base[:i].strip()
        return f"{base}({expr})"

    if "payable" in source_t:
        return f"address(uint160({expr}))" if version < (0, 6, 0) else f"payable({expr})"

    return expr

def _is_time_like_ctor_param(inp: dict, source_decl_type: str = "") -> bool:
    label = _ctor_param_label(inp, source_decl_type)
    typ = _strip_data_location((inp or {}).get("type") or source_decl_type or "")
    return any(k in label for k in TIME_PARAM_KEYWORDS) and (typ.startswith("uint") or typ.startswith("int"))

def _semantic_scalar_ctor_expr(inp: dict, source_decl_type: str = "", solc_version: str = "") -> Optional[str]:
    label = _ctor_param_label(inp, source_decl_type)
    typ = _strip_data_location((inp or {}).get("type") or source_decl_type or "")
    int_match = re.fullmatch(r"u?int(\d*)", typ)
    bit_width = int(int_match.group(1) or "256") if int_match else 256
    if _is_time_like_ctor_param(inp, source_decl_type):
        if bit_width < 64:
            return "1"
        if "duration" in label or "period" in label or "delay" in label:
            return "30 days"
        if any(k in label for k in ("start", "begin")):
            return "block.timestamp"
        return "block.timestamp + 30 days"
    if typ.startswith("uint") or typ.startswith("int"):
        if "decimal" in label:
            return "18" if bit_width >= 8 else "1"
        if "chain" in label and "id" in label:
            return "1"
        if any(k in label for k in ("price", "rate", "ratio", "exchange")):
            if bit_width < 64:
                return "1"
            return "1000000000000000000"
        if any(k in label for k in ("supply", "cap", "amount", "limit")):
            if bit_width < 96:
                return "1000"
            return "1000000000000000000000000"
    return None

def _semantic_ctor_param_plan(inp: dict, idx: int, source_decl_type: str, solc_version: str) -> Optional[dict]:
    if not isinstance(inp, dict):
        return None

    scalar_expr = _semantic_scalar_ctor_expr(inp, source_decl_type, solc_version)
    if scalar_expr is not None:
        return {"prelude_lines": [], "expr": scalar_expr, "deps": set(), "context": [f"scalar:{inp.get('name') or idx}"]}

    is_addr_array = _is_address_or_contract_array_ctor_param(inp, source_decl_type)
    if not _is_address_or_contract_like_ctor_param(inp, source_decl_type) and not is_addr_array:
        return None

    kind = _ctor_address_kind(inp, source_decl_type)
    pname = _sanitize_sol_var_name(inp.get("name") or f"ctor_arg{idx}", f"ctor_arg{idx}")

    if kind == "role" and not is_addr_array:
        expr = _cast_address_expr_for_ctor("address(this)", inp, source_decl_type, solc_version)
        return {"prelude_lines": [], "expr": expr, "deps": set(), "context": [f"role:{pname}"]}

    dep_map = {
        "erc20": ("SemInvMockERC20", "mock_erc20"),
        "weth": ("SemInvMockWETH", "mock_weth"),
        "oracle": ("SemInvMockOracle", "mock_oracle"),
        "external": ("SemInvMockExternal", "mock_external"),
    }
    contract_name, dep_name = dep_map.get(kind, dep_map["external"])
    var_name = _sanitize_sol_var_name(f"seminv_{dep_name}_{idx}_{pname}", f"seminv_ctx_{idx}")
    prelude = [f"{contract_name} {var_name} = new {contract_name}();"]
    setup_lines = _ctor_context_setup_lines(kind, var_name)

    if is_addr_array:
        elem_base = _address_like_ctor_base_type(inp, source_decl_type) or "address"
        arr_type = _solidity_ctor_array_decl_type(inp, source_decl_type, elem_base)
        arr_base, arr_dims = _parse_array_suffixes(arr_type)
        arr_var = _sanitize_sol_var_name(f"{var_name}_arr", f"seminv_ctx_arr_{idx}")
        arr_len = 2
        if arr_dims and arr_dims[0].startswith("[") and arr_dims[0].endswith("]"):
            n_str = arr_dims[0][1:-1].strip()
            if n_str.isdigit():
                arr_len = max(1, min(int(n_str), 4))
        alloc_type = _solidity_decl_type(arr_base) + "[]"
        if arr_dims and arr_dims[0].startswith("[") and arr_dims[0] != "[]":
            prelude.append(f"{arr_type} memory {arr_var};")
        else:
            prelude.append(f"{arr_type} memory {arr_var} = new {alloc_type}({arr_len});")
        elem_cast = _cast_address_expr_for_ctor(f"address({var_name})", {"type": "address", "internalType": elem_base}, elem_base, solc_version)
        for j in range(arr_len):
            prelude.append(f"{arr_var}[{j}] = {elem_cast};")
        return {
            "prelude_lines": prelude,
            "expr": arr_var,
            "deps": {contract_name},
            "context": [f"{kind}-array:{pname}"],
            "setup_lines": setup_lines,
        }

    address_expr = f"address({var_name})"
    expr = _cast_address_expr_for_ctor(address_expr, inp, source_decl_type, solc_version)
    return {
        "prelude_lines": prelude,
        "expr": expr,
        "deps": {contract_name},
        "context": [f"{kind}:{pname}"],
        "setup_lines": setup_lines,
    }

def _ctor_visibility_suffix(solc_version: str) -> str:
    return " public" if parse_solc_version_number(solc_version) < (0, 7, 0) else ""

def _emit_semantic_context_contracts(L: List[str], ctor_plan: Optional[dict], solc_version: str) -> None:
    deps = set((ctor_plan or {}).get("context_contracts") or [])
    if not deps:
        return

    ctor_vis = _ctor_visibility_suffix(solc_version)
    version = parse_solc_version_number(solc_version)
    L.append("")
    L.append("// Generic SemInv context mocks for constructor/environment dependencies.")

    if "SemInvMockERC20" in deps:
        L.extend([
            "contract SemInvMockERC20 {",
            "    string public name;",
            "    string public symbol;",
            "    uint8 public decimals;",
            "    uint256 public totalSupply;",
            "    mapping(address => uint256) public balanceOf;",
            "    mapping(address => mapping(address => uint256)) public allowance;",
            f"    constructor(){ctor_vis} {{",
            '        name = "SemInvMock";',
            '        symbol = "SMI";',
            "        decimals = 18;",
            "        _mint(msg.sender, 1000000000000000000000000000000);",
            "    }",
            "    function _mint(address to, uint256 amount) internal { balanceOf[to] += amount; totalSupply += amount; }",
            "    function mint(address to, uint256 amount) public returns (bool) { _mint(to, amount); return true; }",
            "    function faucet(address to, uint256 amount) public returns (bool) { _mint(to, amount); return true; }",
            "    function setDecimals(uint8 d) public { decimals = d; }",
            "    function approve(address spender, uint256 amount) public returns (bool) { allowance[msg.sender][spender] = amount; return true; }",
            "    function transfer(address to, uint256 amount) public returns (bool) { if (balanceOf[msg.sender] < amount) { _mint(msg.sender, amount); } balanceOf[msg.sender] -= amount; balanceOf[to] += amount; return true; }",
            "    function transferFrom(address from, address to, uint256 amount) public returns (bool) { if (balanceOf[from] < amount) { _mint(from, amount); } if (allowance[from][msg.sender] < amount) { allowance[from][msg.sender] = amount; } allowance[from][msg.sender] -= amount; balanceOf[from] -= amount; balanceOf[to] += amount; return true; }",
            "}",
            "",
        ])

    if "SemInvMockWETH" in deps:
        if version >= (0, 6, 0):
            weth_withdraw = "    function withdraw(uint256 amount) public { if (balanceOf[msg.sender] < amount) { balanceOf[msg.sender] = amount; totalSupply += amount; } balanceOf[msg.sender] -= amount; payable(msg.sender).transfer(amount); }"
        else:
            weth_withdraw = "    function withdraw(uint256 amount) public { if (balanceOf[msg.sender] < amount) { balanceOf[msg.sender] = amount; totalSupply += amount; } balanceOf[msg.sender] -= amount; msg.sender.transfer(amount); }"
        L.extend([
            "contract SemInvMockWETH {",
            "    string public name;",
            "    string public symbol;",
            "    uint8 public decimals;",
            "    uint256 public totalSupply;",
            "    mapping(address => uint256) public balanceOf;",
            "    mapping(address => mapping(address => uint256)) public allowance;",
            f"    constructor(){ctor_vis} {{ name = \"Wrapped Ether\"; symbol = \"WETH\"; decimals = 18; }}",
            "    function _mint(address to, uint256 amount) internal { balanceOf[to] += amount; totalSupply += amount; }",
            "    function mint(address to, uint256 amount) public returns (bool) { _mint(to, amount); return true; }",
            "    function faucet(address to, uint256 amount) public returns (bool) { _mint(to, amount); return true; }",
            "    function deposit() public payable { balanceOf[msg.sender] += msg.value; totalSupply += msg.value; }",
            weth_withdraw,
            "    function approve(address spender, uint256 amount) public returns (bool) { allowance[msg.sender][spender] = amount; return true; }",
            "    function transfer(address to, uint256 amount) public returns (bool) { if (balanceOf[msg.sender] < amount) { balanceOf[msg.sender] = amount; totalSupply += amount; } balanceOf[msg.sender] -= amount; balanceOf[to] += amount; return true; }",
            "    function transferFrom(address from, address to, uint256 amount) public returns (bool) { if (balanceOf[from] < amount) { balanceOf[from] = amount; totalSupply += amount; } if (allowance[from][msg.sender] < amount) { allowance[from][msg.sender] = amount; } allowance[from][msg.sender] -= amount; balanceOf[from] -= amount; balanceOf[to] += amount; return true; }",
        ])
        if version >= (0, 6, 0):
            L.append("    receive() external payable { deposit(); }")
            L.append("    fallback() external payable { deposit(); }")
        else:
            L.append("    function() external payable { deposit(); }")
        L.extend(["}", ""])

    if "SemInvMockOracle" in deps:
        L.extend([
            "contract SemInvMockOracle {",
            "    int256 public answer;",
            f"    constructor(){ctor_vis} {{ answer = 1000000000000000000; }}",
            "    function setAnswer(int256 v) public { answer = v; }",
            "    function decimals() public pure returns (uint8) { return 18; }",
            "    function latestAnswer() public view returns (int256) { return answer; }",
            "    function getPrice(address) public view returns (uint256) { return uint256(answer); }",
            "    function getUnderlyingPrice(address) public view returns (uint256) { return uint256(answer); }",
            "    function price() public view returns (uint256) { return uint256(answer); }",
            "    function consult(address, uint256 amountIn) public view returns (uint256) { return amountIn * uint256(answer) / 1000000000000000000; }",
            "    function read() public view returns (bytes32) { return bytes32(uint256(answer)); }",
            "    function latestRoundData() public view returns (uint80, int256, uint256, uint256, uint80) { return (1, answer, block.timestamp, block.timestamp, 1); }",
            "}",
            "",
        ])

    if "SemInvMockExternal" in deps:
        L.extend([
            "contract SemInvMockExternal {",
            "    uint256 public value;",
            f"    constructor(){ctor_vis} {{ value = 1000000000000000000; }}",
            "    function setValue(uint256 v) public { value = v; }",
            "    function implementation() public view returns (address) { return address(this); }",
            "    function admin() public view returns (address) { return address(this); }",
            "    function oracle() public view returns (address) { return address(this); }",
            "    function factory() public view returns (address) { return address(this); }",
            "    function WETH() public view returns (address) { return address(this); }",
            "    function token0() public view returns (address) { return address(this); }",
            "    function token1() public view returns (address) { return address(this); }",
            "    function getPrice(address) public view returns (uint256) { return value; }",
            "    function getUnderlyingPrice(address) public view returns (uint256) { return value; }",
            "    function isController() public pure returns (bool) { return true; }",
            "    function isComptroller() public pure returns (bool) { return true; }",
            "    function markets(address) public pure returns (bool, uint256, bool) { return (true, 1000000000000000000, false); }",
            "    function mintAllowed(address,address,uint256) public pure returns (uint256) { return 0; }",
            "    function redeemAllowed(address,address,uint256) public pure returns (uint256) { return 0; }",
            "    function borrowAllowed(address,address,uint256) public pure returns (uint256) { return 0; }",
            "    function repayBorrowAllowed(address,address,address,uint256) public pure returns (uint256) { return 0; }",
            "    function liquidateBorrowAllowed(address,address,address,address,uint256) public pure returns (uint256) { return 0; }",
            "    function seizeAllowed(address,address,address,address,uint256) public pure returns (uint256) { return 0; }",
            "    function transferAllowed(address,address,address,uint256) public pure returns (uint256) { return 0; }",
            "    function enterMarkets(address[] memory cTokens) public pure returns (uint256[] memory) { uint256[] memory out = new uint256[](cTokens.length); return out; }",
            "    function claimComp(address) public {}",
            "    function borrowRatePerBlock() public view returns (uint256) { return value / 1000000; }",
            "    function supplyRatePerBlock() public view returns (uint256) { return value / 1000000; }",
            "    function getBorrowRate(uint256,uint256,uint256) public view returns (uint256) { return value / 1000000; }",
            "    function getSupplyRate(uint256,uint256,uint256,uint256) public view returns (uint256) { return value / 1000000; }",
        ])
        if version >= (0, 6, 0):
            L.append("    receive() external payable {}")
            L.append("    fallback() external payable {}")
        else:
            L.append("    function() external payable {}")
        L.extend(["}", ""])

def _emit_constructor_context_setup(L: List[str], ctor_plan: Optional[dict]) -> None:
    setup_lines = list((ctor_plan or {}).get("context_setup_lines") or [])
    if not setup_lines:
        return
    L.append("        // Generic constructor/context synthesis for SemInv mocks.")
    for line in setup_lines:
        L.append(f"        {line}")

def has_transfer_ownership_function(functions):
    """
    鍒ゆ柇鐩爣鍚堢害鏄惁瀛樺湪甯歌鐨?ownership 杞Щ鎺ュ彛銆?
    褰撳墠鍙尮閰?
      transferOwnership(address)
    """
    if not isinstance(functions, dict):
        return False

    fn = functions.get("transferOwnership")
    if not fn:
        return False

    if not is_externally_callable_function(fn):
        return False

    params = fn.get("parameters", {}).get("parameters", []) or []
    if len(params) != 1:
        return False

    typ = (params[0].get("typeDescriptions", {}) or {}).get("typeString", "") or ""
    typ = _strip_data_location(typ)

    return typ in ["address", "address payable"]

def build_default_args_plan_from_function_def(fn, var_prefix: str = "callarg"):
    """
    浠?AST FunctionDefinition 鐢熸垚:
    {
        "prelude_lines": [...],
        "args_str": "a0, a1, ..."
    }

    閫傜敤浜?
    - access property / invariant 涓殑 abi.encodeWithSignature
    - 鍏朵粬鍏佽鍏堝０鏄庝复鏃跺彉閲忓啀璋冪敤鐨勫満鏅?
    """
    if not isinstance(fn, dict):
        return None

    params = fn.get("parameters", {}).get("parameters", []) or []
    prelude_lines = []
    arg_exprs = []

    for idx, p in enumerate(params):
        pname = p.get("name") or f"{var_prefix}_{idx}"

        # 缁熶竴琛?components fallback锛岄伩鍏?AST 娌℃湁 ABI-style components 鏃朵涪澶?tuple/struct 瀛楁
        p2 = dict(p)
        if not p2.get("components"):
            p2["components"] = _extract_components_from_ast_param(p2)

        plan = build_default_param_plan(
            p2,
            var_name=f"{var_prefix}_{pname}",
            depth=0
        )
        if plan is None:
            return None

        prelude_lines.extend(plan.get("prelude_lines", []))
        arg_exprs.append(plan["expr"])

    return {
        "prelude_lines": prelude_lines,
        "args_str": ", ".join(arg_exprs)
    }

def parse_solc_version_number(solc_version: str):
    v = (solc_version or "").strip().lower()
    if v.startswith("v"):
        v = v[1:]
    parts = v.split(".")
    nums = []
    for x in parts[:3]:
        try:
            nums.append(int(x))
        except:
            nums.append(0)
    while len(nums) < 3:
        nums.append(0)
    return tuple(nums)

def need_constructor_public(solc_version: str) -> bool:
    major, minor, patch = parse_solc_version_number(solc_version)
    return (major, minor, patch) < (0, 7, 0)

SEMANTIC_BOOTSTRAP_NAME_PATTERNS = (
    "initialize",
    "init",
    "setup",
    "configure",
    "activate",
    "open",
    "unpause",
    "mint",
    "faucet",
    "approve",
    "increaseallowance",
    "deposit",
)

ASSET_KEYWORDS = (
    "balance",
    "balances",
    "supply",
    "asset",
    "assets",
    "share",
    "shares",
    "debt",
    "borrow",
    "collateral",
    "reserve",
    "liquidity",
    "pool",
    "vault",
    "token",
)

ACCESS_KEYWORDS = (
    "owner",
    "admin",
    "governance",
    "controller",
    "strategy",
    "oracle",
    "router",
    "implementation",
    "proxy",
    "guardian",
    "timelock",
    "operator",
    "manager",
)

STATE_KEYWORDS = (
    "state",
    "status",
    "phase",
    "round",
    "epoch",
    "paused",
    "active",
    "locked",
    "finalized",
)

PLANNER_PHASE_ORDER = {
    "initializer": 0,
    "access": 1,
    "approval": 2,
    "funding": 3,
    "supply": 4,
    "borrow": 5,
    "repay": 6,
    "exit": 7,
    "liquidation": 8,
    "claim": 9,
    "generic": 20,
}

PLANNER_PHASE_KEYWORDS = {
    "initializer": ("initialize", "init", "setup", "configure", "activate", "open", "unpause"),
    "access": ("owner", "admin", "governance", "guardian", "operator", "manager", "controller", "comptroller", "support", "market"),
    "approval": ("approve", "allowance", "permit"),
    "funding": ("mint", "faucet", "deposit", "stake", "fund", "wrap"),
    "supply": ("supply", "lend", "addliquidity", "add_liquidity", "join"),
    "borrow": ("borrow", "draw"),
    "repay": ("repay", "payback"),
    "exit": ("withdraw", "redeem", "unstake", "remove", "exit", "burn"),
    "liquidation": ("liquidate", "seize"),
    "claim": ("claim", "harvest", "collect", "reward"),
}

def _semantic_name_score(name: str) -> int:
    n = (name or "").lower()
    score = 0
    if any(k in n for k in ASSET_KEYWORDS):
        score += 40
    if any(k in n for k in ACCESS_KEYWORDS):
        score += 35
    if any(k in n for k in STATE_KEYWORDS):
        score += 30
    if any(k in n for k in ("initialize", "init", "setup", "configure")):
        score += 45
    if any(k in n for k in ("deposit", "withdraw", "redeem", "borrow", "repay", "liquidate", "mint", "burn", "claim")):
        score += 25
    if any(k in n for k in ("view", "get", "read")):
        score -= 10
    return score

def _semantic_planner_phase(name: str, fn: Optional[dict] = None) -> str:
    """Classify a mutating ABI entry into a coarse, protocol-agnostic phase.

    The planner uses only generic ABI/name signals.  It intentionally avoids
    benchmark-specific transaction recipes; the goal is to put common
    preconditions before dependent calls.
    """
    n = (name or "").lower().replace("_", "")
    if name in ("__receive__", "__fallback__") or (fn or {}).get("kind") in ("receive", "fallback"):
        return "funding"
    for phase, keys in PLANNER_PHASE_KEYWORDS.items():
        if any(k.replace("_", "") in n for k in keys):
            return phase
    return "generic"

def _semantic_planner_sort_key(item: Any):
    name = item[0] if isinstance(item, tuple) else str(item or "")
    fn = item[1] if isinstance(item, tuple) and len(item) > 1 else None
    phase = _semantic_planner_phase(name, fn if isinstance(fn, dict) else None)
    return (PLANNER_PHASE_ORDER.get(phase, PLANNER_PHASE_ORDER["generic"]), -_semantic_name_score(name), str(name or ""))

def _semantic_sort_key_name(name: str):
    return (-_semantic_name_score(name), str(name or ""))

def _semantic_sort_named_items(items: List[Any], name_getter) -> List[Any]:
    return sorted(items or [], key=lambda item: _semantic_sort_key_name(name_getter(item)))

def _function_param_type(fn: dict, idx: int) -> str:
    params = (fn or {}).get("parameters", {}).get("parameters", []) or []
    if idx >= len(params):
        return ""
    p = params[idx] or {}
    typ = (p.get("typeDescriptions", {}) or {}).get("typeString", "") or p.get("type", "") or ""
    return _strip_data_location(typ)

def _is_uint_like_type(typ: str) -> bool:
    typ = _strip_data_location(typ or "")
    return typ.startswith("uint") or typ.startswith("int")

def _is_address_like_type(typ: str) -> bool:
    typ = _strip_data_location(typ or "")
    return typ in ("address", "address payable")

def _has_payable_or_eth_entry(functions: Dict[str, dict]) -> bool:
    for name, fn in (functions or {}).items():
        if (fn or {}).get("stateMutability") == "payable":
            return True
        if name in ("__receive__", "__fallback__") or (fn or {}).get("kind") in ("receive", "fallback"):
            return True
    return False

def _accounting_sort_label(inv: dict) -> str:
    if not isinstance(inv, dict):
        return ""
    return " ".join(str(inv.get(k, "") or "") for k in ("mapping", "supply", "via_function"))

def _state_sort_items(state_machine: dict) -> List[str]:
    return _semantic_sort_named_items((state_machine or {}).get("states", []) or [], lambda s: s)

def _transition_sort_items(items: List[str]) -> List[str]:
    return _semantic_sort_named_items(items or [], lambda s: s)

def _access_sort_items(access: List[dict]) -> List[dict]:
    return _semantic_sort_named_items(access or [], lambda item: (item or {}).get("name", ""))

def _has_erc20_supply_shape(functions: Dict[str, dict]) -> bool:
    """Detect a generic ERC20-like supply surface without relying on storage names."""
    bal = (functions or {}).get("balanceOf")
    sup = (functions or {}).get("totalSupply")
    if not bal or not sup:
        return False
    if not (_is_view_or_pure(bal) and _is_view_or_pure(sup)):
        return False
    if _function_param_count(bal) != 1 or _function_return_count(bal) != 1:
        return False
    if _function_param_count(sup) != 0 or _function_return_count(sup) != 1:
        return False
    return _is_address_like_type(_function_param_type(bal, 0))

def _has_supply_like_accounting(accounting: List[dict]) -> bool:
    for inv in accounting or []:
        label = _accounting_sort_label(inv).lower()
        if "balance" in label and "supply" in label:
            return True
    return False

def _bootstrap_candidate_specs(functions: Dict[str, dict], profile: str) -> List[dict]:
    """Build conservative, generic prestate calls for generated L3 harnesses.

    These calls are not counted as vulnerabilities. They merely make common
    initialization/approval/liquidity states reachable before properties run.
    Failures are ignored by the generated harness.
    """
    specs: List[dict] = []
    for name, fn in _semantic_sort_named_items(list((functions or {}).items()), lambda kv: kv[0]):
        if not isinstance(fn, dict) or not is_externally_callable_function(fn):
            continue
        if fn.get("stateMutability") in ("view", "pure"):
            continue
        lname = (name or "").lower()
        if name in ("__receive__", "__fallback__") or fn.get("kind") in ("receive", "fallback"):
            continue

        params = fn.get("parameters", {}).get("parameters", []) or []
        sig = build_function_signature(fn)
        spec = None

        if lname in ("approve", "increaseallowance") and len(params) == 2:
            t0 = _function_param_type(fn, 0)
            t1 = _function_param_type(fn, 1)
            if _is_address_like_type(t0) and _is_uint_like_type(t1):
                spec = {
                    "signature": sig,
                    "args": "address(handler), 1000000000000000000000000",
                    "actor_loop": True,
                    "value": None,
                }

        elif lname in ("mint", "faucet") or "faucet" in lname:
            if len(params) == 0:
                spec = {"signature": sig, "args": "", "actor_loop": True, "value": None}
            elif len(params) == 1 and _is_address_like_type(_function_param_type(fn, 0)):
                spec = {"signature": sig, "args": "handler.actor(0)", "actor_loop": False, "value": None}
            elif len(params) == 2 and _is_address_like_type(_function_param_type(fn, 0)) and _is_uint_like_type(_function_param_type(fn, 1)):
                spec = {"signature": sig, "args": "handler.actor(0), 1000000000000000000000", "actor_loop": False, "value": None}

        elif lname in ("deposit", "stake") or lname.startswith("deposit") or lname.startswith("stake"):
            plan = build_default_args_plan_from_function_def(fn, var_prefix=f"boot_{name}")
            if plan is not None:
                spec = {
                    "signature": sig,
                    "args": plan.get("args_str", ""),
                    "prelude_lines": plan.get("prelude_lines", []),
                    "actor_loop": True,
                    "value": "1 ether" if fn.get("stateMutability") == "payable" else None,
                }

        elif any(pat in lname for pat in SEMANTIC_BOOTSTRAP_NAME_PATTERNS[:7]):
            plan = build_default_args_plan_from_function_def(fn, var_prefix=f"boot_{name}")
            if plan is not None:
                spec = {
                    "signature": sig,
                    "args": plan.get("args_str", ""),
                    "prelude_lines": plan.get("prelude_lines", []),
                    "actor_loop": False,
                    "value": "1 ether" if fn.get("stateMutability") == "payable" else None,
                }

        if spec is not None:
            spec["name"] = name
            specs.append(spec)
        if len(specs) >= 10:
            break
    return specs

def _emit_low_level_call_lines(L: List[str], signature: str, args: str = "", *, value: Optional[str] = None,
                               profile: str = "modern", indent: str = "        ", ok_var: str = "ok") -> None:
    payload = f'abi.encodeWithSignature("{signature}"' + (f", {args}" if args else "") + ")"
    if profile == "modern":
        if value:
            L.append(f"{indent}(bool {ok_var},) = address(target).call{{value: {value}}}({payload});")
        else:
            L.append(f"{indent}(bool {ok_var},) = address(target).call({payload});")
    elif profile == "mid_legacy":
        if value:
            L.append(f"{indent}(bool {ok_var},) = address(target).call.value({value})({payload});")
        else:
            L.append(f"{indent}(bool {ok_var},) = address(target).call({payload});")
    else:
        if value:
            L.append(f"{indent}bool {ok_var} = address(target).call.value({value})({payload});")
        else:
            L.append(f"{indent}bool {ok_var} = address(target).call({payload});")
    L.append(f"{indent}{ok_var};")

def _emit_semantic_bootstrap_function(L: List[str], functions: Dict[str, dict], profile: str) -> None:
    specs = _bootstrap_candidate_specs(functions, profile)
    L.append("")
    L.append("    function _semantic_bootstrap() internal {")
    L.append("        // Conservative generic prestate setup; failed calls are ignored.")
    if not specs:
        L.append("        return;")
        L.append("    }")
        return

    vm_ref = "vm" if profile == "modern" else "_vm()"
    L.append("        uint256 n = handler.actorCount();")
    for idx, spec in enumerate(specs):
        for line in spec.get("prelude_lines", []) or []:
            L.append(f"        {line}")
        args = spec.get("args", "")
        value = spec.get("value")
        sig = spec.get("signature", "")
        if spec.get("actor_loop"):
            L.append(f"        for(uint256 i_boot_{idx}=0; i_boot_{idx}<n; i_boot_{idx}++) {{")
            L.append(f"            {vm_ref}.startPrank(handler.actor(i_boot_{idx}));")
            _emit_low_level_call_lines(
                L,
                sig,
                args,
                value=value,
                profile=profile,
                indent="            ",
                ok_var=f"ok_boot_{idx}",
            )
            L.append(f"            {vm_ref}.stopPrank();")
            L.append("        }")
        else:
            _emit_low_level_call_lines(
                L,
                sig,
                args,
                value=value,
                profile=profile,
                indent="        ",
                ok_var=f"ok_boot_{idx}",
            )
    L.append("    }")

def _emit_semantic_feedback_prepare_function(L: List[str]) -> None:
    L.append("")
    L.append("    function _semantic_feedback_prepare() internal {")
    L.append("        // Generic revert/reachability feedback: refresh conservative prestate before one retry.")
    L.append("        _semantic_bootstrap();")
    L.append("    }")

def _handler_call_stmt_for_sequence(fn_name: str, functions: Dict[str, dict]) -> Optional[str]:
    stmt = build_direct_handler_call_stmt(fn_name, functions)
    if not stmt:
        return None
    return stmt.strip()

def _semantic_sequence_call_blocks(functions: Dict[str, dict], limit: int = 16) -> List[List[str]]:
    """Return typed, deterministic handler-call blocks with one feedback retry.

    This deliberately reuses generated handler wrappers and default argument
    generation.  It is not an attack rule: the sequence only improves generic
    state reachability before properties are observed.
    """
    blocks: List[List[str]] = []
    candidates = sorted(list((functions or {}).items()), key=_semantic_planner_sort_key)
    for name, _fn in candidates:
        stmt = _handler_call_stmt_for_sequence(name, functions)
        if not stmt:
            continue
        blocks.append([
            stmt,
            "if(!handler.lastCallOk()) {",
            "    _semantic_feedback_prepare();",
            f"    {stmt}",
            "}",
        ])
        if len(blocks) >= limit:
            break
    return blocks

def _semantic_sequence_call_stmts(functions: Dict[str, dict], limit: int = 12) -> List[str]:
    """Compatibility helper for callers that need flat statements."""
    stmts: List[str] = []
    for block in _semantic_sequence_call_blocks(functions, limit=limit):
        stmts.extend(block)
    return stmts

def _emit_semantic_sequence_function(L: List[str], functions: Dict[str, dict], *, name: str = "_run_semantic_sequence") -> None:
    blocks = _semantic_sequence_call_blocks(functions)
    L.append("")
    L.append(f"    function {name}() internal {{")
    if not blocks:
        L.append("        return;")
    else:
        for block in blocks:
            for line in block:
                L.append(f"        {line}")
    L.append("    }")

def _emit_feedback_retry_lines(L: List[str], call_stmt: str, indent: str = "        ") -> None:
    stmt = (call_stmt or "").strip()
    if not stmt:
        return
    L.append(f"{indent}if(!handler.lastCallOk()) {{")
    L.append(f"{indent}    _semantic_feedback_prepare();")
    L.append(f"{indent}    {stmt}")
    L.append(f"{indent}}}")

# =========================
# Step 0: baseline helpers
# =========================

def _to_jsonable(obj):
    """
    灏?set / tuple / Path 绛夊璞¤浆鎹负鍙?JSON 搴忓垪鍖栫殑褰㈠紡
    """
    if isinstance(obj, dict):
        return {str(k): _to_jsonable(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_to_jsonable(x) for x in obj]
    if isinstance(obj, tuple):
        return [_to_jsonable(x) for x in obj]
    if isinstance(obj, set):
        return sorted([_to_jsonable(x) for x in obj], key=lambda x: str(x))
    if isinstance(obj, Path):
        return str(obj)
    return obj


def normalize_dfg(dfg):
    """
    灏?dfg 涓殑 set 鍙樻垚鎺掑簭鍚庣殑 list锛屾柟渚夸繚瀛樺拰 diff
    """
    out = {}
    for fn, item in dfg.items():
        out[fn] = {
            "reads": sorted(list(item.get("reads", []))),
            "writes": sorted(list(item.get("writes", []))),
        }
    return out

def build_state_domain_assert_lines_legacy(state_var, detail, contract, functions):
    return []
    lines = []
    state_kind = detail.get("state_kind", "enum")
    enum_name = detail.get("enum_name")
    enum_values = detail.get("enum_values", [])
    read_expr = resolve_state_read_expr(state_var, functions)

    if state_kind == "enum" and enum_name and enum_values:
        lines.append(f"        {contract}.{enum_name} x = target.{read_expr};")
        lines.append("        uint256 v = uint256(x);")
        cond = " || ".join([f"v == {i}" for i in range(len(enum_values))]) or "true"
        lines.append(f"        _assertTrue({cond});")
        return lines

    if state_kind == "bool":
        lines.append(f"        uint256 v = target.{read_expr} ? 1 : 0;")
        lines.append("        _assertTrue(v == 0 || v == 1);")
        return lines

    if state_kind == "uint":
        lines.append(f"        uint256 v = target.{read_expr};")
        lines.append("        _assertTrue(v < 1e30);")
        return lines

    lines.append("        _assertTrue(true);")
    return lines


def build_analysis_result(contract_name,
                          source_path,
                          profile,
                          solc_version,
                          storage,
                          functions,
                          dfg,
                          update_facts,
                          cfg_info,
                          accounting,
                          state_machine,
                          transition_facts,
                          access,
                          sensitive_functions,
                          guard_facts,
                          access_anomalies,
                          cross_relations,
                          accounting_anomalies,
                          llm_invariants,
                          llm_candidates=None,
                          llm_rejected=None):
    """
    缁熶竴鏋勯€?baseline 鍒嗘瀽缁撴灉
    """
    return {
        "meta": {
            "contract_name": contract_name,
            "source_path": str(source_path) if source_path else None,
            "profile": profile,
            "solc_version": solc_version,
            "generated_at": datetime.utcnow().isoformat() + "Z",
        },
        "storage": _to_jsonable(storage),
        "functions": sorted(list(functions.keys())),
        "dfg": _to_jsonable(normalize_dfg(dfg)),
        "update_facts": _to_jsonable(update_facts),
        "cfg": _to_jsonable(cfg_info),
        "accounting": _to_jsonable(accounting),
        "state_machine": _to_jsonable(state_machine),
        "transition_facts": _to_jsonable(transition_facts),
        "access": _to_jsonable(access),
        "sensitive_functions": _to_jsonable(sensitive_functions),
        "guard_facts": _to_jsonable(guard_facts),
        "access_anomalies": _to_jsonable(access_anomalies),
        "cross_relations": _to_jsonable(cross_relations),
        "accounting_anomalies": _to_jsonable(accounting_anomalies),
        "llm_invariants": _to_jsonable(llm_invariants),
        "llm_candidates": _to_jsonable(llm_candidates or []),
        "llm_rejected": _to_jsonable(llm_rejected or []),
    }


def dump_baseline_artifacts(output_dir,
                            analysis_result,
                            foundry_code,
                            foundry_supplement_code=None,
                            prefix=""):
    """
    灏?baseline 浜х墿瀵煎嚭鍒版湰鍦帮紝渚夸簬鍚庣画 diff / 鍥炲綊
    """
    if not output_dir:
        return

    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    analysis_path = out_dir / f"{prefix}analysis.json"
    foundry_path = out_dir / f"{prefix}generated.t.sol"
    supplement_path = out_dir / f"{prefix}generated_supplement.t.sol"

    with open(analysis_path, "w", encoding="utf-8") as f:
        json.dump(analysis_result, f, ensure_ascii=False, indent=2)

    with open(foundry_path, "w", encoding="utf-8") as f:
        f.write(foundry_code)

    if foundry_supplement_code:
        with open(supplement_path, "w", encoding="utf-8") as f:
            f.write(foundry_supplement_code)


def repair_snapshot_helper_mismatches(foundry_code):
    call_re = re.compile(r"^\s*_snapshot_(before|after)_([A-Za-z0-9_]+)\(\);\s*$")
    def_re = re.compile(r"function\s+_snapshot_(before|after)_([A-Za-z0-9_]+)\s*\(")
    defined = {m.group(2) for m in def_re.finditer(foundry_code or "")}
    missing = set()
    repaired_lines = []
    for line in (foundry_code or "").splitlines():
        m = call_re.match(line)
        if m and m.group(2) not in defined:
            missing.add(m.group(2))
            continue
        repaired_lines.append(line)
    if missing:
        repaired_lines.append("")
        repaired_lines.append("// Snapshot helper self-check removed calls without generated helpers:")
        repaired_lines.append("// " + ", ".join(sorted(missing)))
    return "\n".join(repaired_lines) + ("\n" if foundry_code else "")


def inline_foundry_supplement_code(standalone_code):
    """
    Convert a standalone *_InvariantSupplement.t.sol body into code that can be
    appended directly to the generated *_Invariant.t.sol file.

    The standalone generators intentionally emit SPDX/pragma/import headers so
    they can still be tested in isolation. Inline mode strips those file-level
    declarations and keeps only helper/test contracts.
    """
    if not standalone_code:
        return ""

    body = []
    for line in str(standalone_code).splitlines():
        stripped = line.strip()
        if stripped.startswith("// SPDX-License-Identifier:"):
            continue
        if stripped.startswith("pragma solidity "):
            continue
        if stripped.startswith("pragma experimental ABIEncoderV2"):
            continue
        if stripped.startswith("import "):
            continue
        body.append(line)

    return "\n".join(body).strip()

def function_supported_by_handler(fn):
    """
    鍒ゆ柇璇ュ嚱鏁版槸鍚︿細鍦?generate_handler() 涓垚鍔熺敓鎴?call_xxx wrapper銆?
    杩欓噷蹇呴』涓?generate_handler() 鐨?skip 閫昏緫淇濇寔涓€鑷淬€?
    """
    if not is_externally_callable_function(fn):
        return False

    if fn.get("stateMutability") in ["view", "pure"]:
        return False

    kind = fn.get("kind", "")
    if kind in ["receive", "fallback"]:
        return True

    params = fn.get("parameters", {}).get("parameters", []) or []

    for p in params:
        typ = p.get("typeDescriptions", {}).get("typeString", "") or ""
        
        # mapping/function 涓€寰嬩笉鏀寔
        if "mapping" in typ or "function" in typ:
            return False

        # 鏁扮粍 / tuple / struct 鍏堜繚瀹堜笉璧?handler 璺緞锛?
        # 閬垮厤鍦?handler.call_xxx(...) 鎴?direct handler call 鍦烘櫙閲屽紩鍏ユ柊鐨勭紪璇戦棶棰?
        if "[" in typ or "tuple" in typ or "struct " in typ:
            return False

    return True

def collect_supported_handler_selectors(functions):
    """
    杩斿洖褰撳墠鍚堢害鍙敤浜?handler fuzz 鐨?selector 鍚嶅垪琛ㄣ€?
    缁撴灉鍏冪礌涓?generate_foundry_tests_modern() 涓殑 selectors 鏋勯€犱繚鎸佷竴鑷达細
    - receive
    - fallback
    - 鏅€氬嚱鏁板悕
    """
    selectors = []

    for name, f in _semantic_sort_named_items(list((functions or {}).items()), lambda kv: kv[0]):
        if not function_supported_by_handler(f):
            continue

        if name == "__receive__" or f.get("kind") == "receive":
            selectors.append("receive")
        elif name == "__fallback__" or f.get("kind") == "fallback":
            selectors.append("fallback")
        else:
            selectors.append(name)

    return selectors


def _can_read_zero_arg_scalar(var_name, functions):
    fn = (functions or {}).get(var_name)
    if isinstance(fn, dict):
        params = fn.get("parameters", {}).get("parameters", []) or []
        if len(params) == 0 and _function_return_count(fn) == 1 and fn.get("stateMutability") in ["view", "pure"]:
            return True

    aliases = {
        "_totalSupply": "totalSupply",
        "_owner": "owner",
        "_paused": "paused",
    }
    alias = aliases.get(var_name)
    if alias:
        fn = (functions or {}).get(alias)
        if isinstance(fn, dict):
            params = fn.get("parameters", {}).get("parameters", []) or []
            if len(params) == 0 and _function_return_count(fn) == 1 and fn.get("stateMutability") in ["view", "pure"]:
                return True

    if str(var_name).startswith("_"):
        cand = str(var_name)[1:]
        fn = (functions or {}).get(cand)
        if isinstance(fn, dict):
            params = fn.get("parameters", {}).get("parameters", []) or []
            if len(params) == 0 and _function_return_count(fn) == 1 and fn.get("stateMutability") in ["view", "pure"]:
                return True

    return False


def _can_read_mapping(var_name, functions):
    fn = (functions or {}).get(var_name)
    if isinstance(fn, dict):
        params = fn.get("parameters", {}).get("parameters", []) or []
        if len(params) == 1:
            return True

    aliases = {
        "_balances": "balanceOf",
    }
    alias = aliases.get(var_name)
    if alias and alias in (functions or {}):
        return True

    if str(var_name).startswith("_"):
        cand = str(var_name)[1:]
        fn = (functions or {}).get(cand)
        if isinstance(fn, dict):
            params = fn.get("parameters", {}).get("parameters", []) or []
            if len(params) == 1:
                return True

    return False


def _signature_arg_types_string(signature):
    text = str(signature or "")
    if "(" not in text or ")" not in text:
        return ""
    return text.split("(", 1)[1].rsplit(")", 1)[0].strip()


def _default_literal_for_signature_type(type_name):
    t = str(type_name or "").strip()
    if not t:
        return "0"
    if t.startswith("uint") or t.startswith("int"):
        return "1"
    if t == "address" or t == "address payable":
        return _default_address_literal_for_type(t)
    if t.startswith("contract ") or t.startswith("interface "):
        return _default_address_literal_for_type(t)
    if t == "bool":
        return "false"
    if t.startswith("bytes32"):
        return "bytes32(0)"
    if t.startswith("bytes"):
        return 'hex""'
    if t == "string":
        return '""'
    return "0"


def _handler_call_stmt_from_signature(fn_name, signature):
    inner = _signature_arg_types_string(signature)
    if not inner:
        return f"        handler.call_{fn_name}();"
    args = [_default_literal_for_signature_type(x.strip()) for x in inner.split(",") if x.strip()]
    return f"        handler.call_{fn_name}({', '.join(args)});"

def get_transition_facts_for_state(state_machine, state_var):
    facts = []
    for tf in state_machine.get("transition_facts", []):
        if tf.get("state_var") == state_var:
            facts.append(tf)
    return facts


def get_transition_facts_for_function(state_machine, fn_name):
    facts = []
    for tf in state_machine.get("transition_facts", []):
        if tf.get("function") == fn_name:
            facts.append(tf)
    return facts

def _normalize_state_symbol_for_compare(x):
    if x is None:
        return None
    return str(x).strip()

def _candidate_preconditions_to_allowed_froms(candidate, state_machine, state_var):
    """
    鏈€灏忕増锛?
    褰撳墠涓嶇湡姝ｈВ鏋愪换鎰忚〃杈惧紡锛屽彧鍋氶潪甯歌交閲忕殑瀛楃涓插蹇嶃€?
    浼樺厛浠?preconditions 涓娊鍙?
      "phase == Init"
      "phase==Init"
      "Init"
    杩欑褰㈠紡鐨勫彸鍊笺€?
    """
    out = []
    preconditions = candidate.get("preconditions", []) or []

    for p in preconditions:
        s = str(p).strip()
        if not s:
            continue

        if "==" in s:
            left, right = s.split("==", 1)
            left = left.strip()
            right = right.strip()

            if left == state_var or left.endswith(f".{state_var}"):
                out.append(right.split(".")[-1].strip())
                continue

        # fallback: 鍗曠嫭涓€涓鍙峰悕
        if s.isidentifier():
            out.append(s)

    return _dedup_str_list(out)

def _state_guarded_transition_supported_by_known_facts(candidate, state_machine):
    """
    鏈€灏忚鍒欙細
    - 蹇呴』鎭板ソ涓€涓?target_var
    - 蹇呴』鎭板ソ涓€涓?target_function
    - 璇?function 蹇呴』鍦ㄥ搴?state 鐨?transition_facts 涓嚭鐜?
    - 鑻?candidate 缁欎簡 preconditions锛屼笖鑳芥娊鍙栧嚭 allowed froms锛?
      鍒欏畠浠繀椤讳笌宸茬煡 from_candidates 鏈変氦闆?
    """
    if not isinstance(candidate, dict):
        return False

    if _safe_lower(candidate.get("template_type")) != "state_guarded_transition":
        return False

    target_vars = _dedup_str_list(candidate.get("target_vars", []))
    target_functions = _dedup_str_list(candidate.get("target_functions", []))

    if len(target_vars) != 1 or len(target_functions) != 1:
        return False

    state_var = target_vars[0]
    fn_name = target_functions[0]

    matched_facts = []
    for tf in state_machine.get("transition_facts", []) or []:
        if tf.get("state_var") == state_var and tf.get("function") == fn_name:
            matched_facts.append(tf)

    if not matched_facts:
        return False

    cand_froms = _candidate_preconditions_to_allowed_froms(candidate, state_machine, state_var)
    if not cand_froms:
        # 娌″啓鏄庡墠缃潯浠舵椂锛屽彧瑕佹湁 transition fact 灏卞厑璁?
        return True

    known_froms = []
    for tf in matched_facts:
        for x in tf.get("from_candidates", []) or []:
            xs = _normalize_state_symbol_for_compare(x)
            if xs:
                known_froms.append(xs.split(".")[-1].strip())

    known_froms = _dedup_str_list(known_froms)

    # 濡傛灉鏈湴 facts 娌＄粰 from_candidates锛屽氨涓嶅己鎷掔粷
    if not known_froms:
        return True

    return len(set(cand_froms) & set(known_froms)) > 0

def _state_guarded_transition_duplicates_known_fact(candidate, state_machine):
    """
    鏈€灏忛噸澶嶈繃婊わ細
    濡傛灉璇ュ€欓€夊搴旂殑 function/state_var 宸茬粡鏈夋槑纭?transition_fact锛?
    涓?candidate 鐨?precondition 涓?known from_candidates 涓€鑷达紝
    鍒欒涓轰笌鐜版湁鏈湴 transition property 閲嶅銆?
    """
    if not isinstance(candidate, dict):
        return False

    if _safe_lower(candidate.get("template_type")) != "state_guarded_transition":
        return False

    target_vars = _dedup_str_list(candidate.get("target_vars", []))
    target_functions = _dedup_str_list(candidate.get("target_functions", []))

    if len(target_vars) != 1 or len(target_functions) != 1:
        return False

    state_var = target_vars[0]
    fn_name = target_functions[0]

    matched_facts = []
    for tf in state_machine.get("transition_facts", []) or []:
        if tf.get("state_var") == state_var and tf.get("function") == fn_name:
            matched_facts.append(tf)

    if not matched_facts:
        return False

    cand_froms = _candidate_preconditions_to_allowed_froms(candidate, state_machine, state_var)
    if not cand_froms:
        # 娌″啓鍓嶇疆鏉′欢锛屼笉褰撲綔閲嶅锛岀暀缁欏悗闈㈠喅瀹?
        return False

    known_froms = []
    for tf in matched_facts:
        for x in tf.get("from_candidates", []) or []:
            xs = _normalize_state_symbol_for_compare(x)
            if xs:
                known_froms.append(xs.split(".")[-1].strip())

    known_froms = _dedup_str_list(known_froms)
    if not known_froms:
        return False

    return set(cand_froms) == set(known_froms)

def build_state_getter_as_uint_expr(state_var, detail, functions):
    state_kind = detail.get("state_kind", "enum")
    read_expr = resolve_state_read_expr(state_var, functions)
    if not read_expr:
        return None

    if state_kind == "bool":
        return f"(target.{read_expr} ? 1 : 0)"

    if state_kind == "uint":
        return f"uint256(target.{read_expr})"

    # enum / fallback
    return f"uint256(target.{read_expr})"

def build_state_domain_assert_lines(state_var, detail, contract, functions):
    return []
    """
    杩斿洖涓€缁?Solidity 浠ｇ爜琛岋紝鐢ㄤ簬鏂█鐘舵€佸彉閲忓彇鍊煎湪鍚堟硶鍩熷唴
    """
    lines = []
    state_kind = detail.get("state_kind", "enum")
    enum_name = detail.get("enum_name")
    enum_values = detail.get("enum_values", [])
    read_expr = resolve_state_read_expr(state_var, functions)
    if not read_expr:
        return []

    lines.append("        uint256 v;")

    if state_kind == "enum" and enum_name and enum_values:
        lines.append(f"        try target.{read_expr} returns ({contract}.{enum_name} x) {{")
        lines.append("            v = uint256(x);")
        lines.append("        } catch {")
        lines.append("            return;")
        lines.append("        }")
        cond = " || ".join([f"v == {i}" for i in range(len(enum_values))]) or "true"
        lines.append(f"        assertTrue({cond});")
        return lines

    if state_kind == "bool":
        lines.append(f"        v = target.{read_expr} ? 1 : 0;")
        lines.append("        assertTrue(v == 0 || v == 1);")
        return lines

    if state_kind == "uint":
        lines.append(f"        try target.{read_expr} returns (uint256 x) {{")
        lines.append("            v = x;")
        lines.append("        } catch {")
        lines.append("            return;")
        lines.append("        }")
        lines.append("        assertTrue(v < 1e30);")
        return lines

    lines.append("        assertTrue(true);")
    return lines

def resolve_terminal_value_indices(detail):
    """
    鎶?terminal_candidates 鏄犲皠鎴愬彲姣旇緝鐨勬暟鍊煎瓧绗︿覆鍒楄〃:
    - enum: ["Closed"] -> ["2"]
    - bool: ["true"] -> ["1"]
    - uint: ["2"] -> ["2"]
    """
    state_kind = detail.get("state_kind", "enum")
    terminal_candidates = detail.get("terminal_candidates", [])
    enum_values = detail.get("enum_values", [])

    result = []

    if state_kind == "enum":
        for tv in terminal_candidates:
            if tv in enum_values:
                result.append(str(enum_values.index(tv)))
        return result

    if state_kind == "bool":
        for tv in terminal_candidates:
            low = str(tv).lower()
            if low == "true":
                result.append("1")
            elif low == "false":
                result.append("0")
        return result

    if state_kind == "uint":
        for tv in terminal_candidates:
            tvs = str(tv).strip()
            if tvs.isdigit():
                result.append(tvs)
        return result

    return result

def augment_bool_terminal_candidates(state_machine):
    """
    Promote simple one-way bool transitions to terminal-state candidates.

    A common legacy/modern pattern is `sold = true`, `closed = true`, or
    `finalized = true` guarded by `!state`, with no observed write back to
    false. Treating true as terminal lets L3 emit absorbing-state supplements.
    """
    if not isinstance(state_machine, dict):
        return state_machine

    details = state_machine.get("details") or {}
    transition_facts = state_machine.get("transition_facts") or []

    for state_var, detail in details.items():
        if not isinstance(detail, dict) or detail.get("state_kind") != "bool":
            continue
        if detail.get("terminal_candidates"):
            continue

        facts = [tf for tf in transition_facts if tf.get("state_var") == state_var]
        to_values = {str(tf.get("to", "")).strip().lower() for tf in facts}
        has_true_write = "true" in to_values or "1" in to_values
        has_false_write = "false" in to_values or "0" in to_values
        if not has_true_write or has_false_write:
            continue

        guarded_from_false = False
        for tf in facts:
            if str(tf.get("to", "")).strip().lower() not in ("true", "1"):
                continue
            froms = {str(x).strip().lower() for x in (tf.get("from_candidates") or [])}
            guards = " ".join(str(x).replace(" ", "").lower() for x in (tf.get("guard_exprs") or []))
            if "false" in froms or f"!{state_var.lower()}" in guards:
                guarded_from_false = True
                break

        if guarded_from_false:
            detail["terminal_candidates"] = ["true"]
            detail["bool_true_terminal"] = True

    return state_machine

def can_generate_direct_handler_call(fn_name, functions):
    if fn_name not in functions:
        return False

    f = functions[fn_name]
    kind = f.get("kind", "")

    if fn_name in ["__receive__", "__fallback__"]:
        return True
    if kind in ["receive", "fallback"]:
        return True

    if f.get("stateMutability") in ["view", "pure"]:
        return False

    return function_supported_by_handler(f)

def build_direct_handler_call_stmt(fn_name, functions):
    """
    缁?modern invariant/property test 鐢熸垚:
    handler.call_xxx(...);
    """
    if fn_name not in functions:
        return None

    f = functions[fn_name]
    kind = f.get("kind", "")

    if fn_name == "__receive__" or kind == "receive":
        return "        handler.call_receive();"

    if fn_name == "__fallback__" or kind == "fallback":
        return "        handler.call_fallback();"

    if not function_supported_by_handler(f):
        return None
    
    args = build_default_call_args_from_function(f)
    if args is None:
        # handler 璺緞鐜板湪鍙帴鍙椻€滃彲瀹夊叏鍐呰仈鈥濈殑鍙傛暟鍑芥暟
        return None

    if args:
        return f"        handler.call_{fn_name}({args});"
    return f"        handler.call_{fn_name}();"


def _function_signature_from_meta(fn_name, functions):
    fn = (functions or {}).get(fn_name)
    if not fn:
        return None
    return fn.get("signature") or build_function_signature(fn)


def _signature_matches_types(signature, expected_types):
    inner = _signature_arg_types_string(signature)
    parts = [x.strip() for x in inner.split(",") if x.strip()] if inner else []
    if len(parts) != len(expected_types):
        return False
    for actual, expected in zip(parts, expected_types):
        actual_n = _strip_data_location(actual).lower()
        expected_n = expected.lower()
        if expected_n == "uint":
            if not actual_n.startswith("uint"):
                return False
        elif expected_n == "int":
            if not actual_n.startswith("int"):
                return False
        elif actual_n != expected_n:
            return False
    return True


def _record_check_descriptor(
        check_catalog,
        *,
        rule_id,
        template,
        suite,
        test_name,
        predicate,
        bindings,
        execution_requirements=None,
        semantic_assumptions=None,
        spec_basis=None,
        observation_sources=None,
        fact_refs=None,
        assertion_ordinal=0,
        assertion_kind=None,
        activation_condition=None,
        rca_included=True,
):
    """Record the exact oracle emitted at one generated Foundry test site.

    The catalog is side-band provenance only: callers may pass ``None`` and the
    generated Solidity remains byte-for-byte identical.  Stable references are
    derived from the semantic site and bindings rather than generation time.
    """
    if check_catalog is None:
        return None
    descriptor = {
        "schema_version": "con-fuzzius.check_descriptor.v1",
        "rule_id": rule_id,
        "template": template,
        "template_version": 1,
        "backend": "foundry",
        "site": {
            "suite": suite,
            "test": test_name,
            "assertion_ordinal": int(assertion_ordinal),
        },
        "predicate": predicate,
        "bindings": _to_jsonable(bindings or {}),
        "execution_requirements": _to_jsonable(execution_requirements or []),
        "semantic_assumptions": _to_jsonable(semantic_assumptions or []),
        "spec_basis": _to_jsonable(spec_basis or {}),
        "observation_sources": _to_jsonable(observation_sources or []),
        "fact_refs": _to_jsonable(fact_refs or []),
        "binding_status": "resolved",
        "rca_included": bool(rca_included),
    }
    if assertion_kind:
        descriptor["assertion_kind"] = str(assertion_kind)
    if activation_condition:
        descriptor["activation_condition"] = str(activation_condition)
    identity = {
        "rule_id": descriptor["rule_id"],
        "template": descriptor["template"],
        "site": descriptor["site"],
        "bindings": descriptor["bindings"],
        "predicate": descriptor["predicate"],
    }
    digest = hashlib.sha256(
        json.dumps(identity, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode("utf-8")
    ).hexdigest()[:16]
    descriptor["check_ref"] = f"check:{digest}"
    check_catalog.append(descriptor)
    return descriptor["check_ref"]


def _record_accounting_aggregate_check(
        check_catalog,
        *,
        contract,
        suite_suffix,
        test_name,
        account,
        aggregate,
        account_read,
        aggregate_read,
        comparison,
        fact_ref,
        action_signature=None,
        action_selector=None,
):
    template = "accounting.sum_eq" if comparison == "==" else "accounting.sum_le"
    rule_id = (
        "I1.accounting.sum_equals_aggregate"
        if comparison == "=="
        else "I1.accounting.sum_bounded_by_aggregate"
    )
    bindings = {
        "account_storage": account,
        "aggregate_storage": aggregate,
        "account_read": account_read,
        "aggregate_read": aggregate_read,
        "actor_scope": "handler.actors",
        "accumulator": "sum",
        "accumulator_term": f"target.{account_read}",
    }
    if action_signature:
        bindings["action_signature"] = action_signature
    if action_selector:
        bindings["action_selector"] = action_selector
    return _record_check_descriptor(
        check_catalog,
        rule_id=rule_id,
        template=template,
        suite=f"{contract}{suite_suffix}",
        test_name=test_name,
        predicate=f"sum {comparison} target.{aggregate_read}",
        bindings=bindings,
        execution_requirements=[
            "the generated test reaches the assertion",
            "all account and aggregate reads used by the assertion complete",
        ],
        semantic_assumptions=[
            "the tracked actor set matches the scope of the instantiated check",
            "account and aggregate reads use compatible units",
        ],
        spec_basis={"kind": "recovered_accounting_relation"},
        observation_sources=["generated test site", "Foundry assertion trace"],
        fact_refs=[fact_ref],
        assertion_kind="assertEq" if comparison == "==" else "assertTrue",
        rca_included=False,
    )


def _record_eth_bound_check(
        check_catalog,
        *,
        contract,
        suite_suffix,
        test_name,
        predicate,
        bindings,
        fact_ref,
        rule_id="I1.accounting.eth_balance_consistency",
        template="accounting.eth_balance_bound",
):
    return _record_check_descriptor(
        check_catalog,
        rule_id=rule_id,
        template=template,
        suite=f"{contract}{suite_suffix}",
        test_name=test_name,
        predicate=predicate,
        bindings=bindings,
        execution_requirements=["the generated test reaches the assertion"],
        semantic_assumptions=["deployment funding and tracked flows follow the generated harness configuration"],
        spec_basis={"kind": "generated_eth_flow_check"},
        observation_sources=["generated test site", "Foundry assertion trace"],
        fact_refs=[fact_ref],
        assertion_kind="assertTrue",
        rca_included=False,
    )


def _record_access_rejection_check(
        check_catalog,
        *,
        contract,
        suite_suffix,
        test_name,
        function_name,
        signature,
        selector=None,
        argument_source=None,
        fact_ref=None,
):
    return _record_check_descriptor(
        check_catalog,
        rule_id="I2.authorization.selected_caller_rejected",
        template="access.call_rejected",
        suite=f"{contract}{suite_suffix}",
        test_name=test_name,
        predicate="call_success == false",
        bindings={
            "function": function_name,
            "signature": signature,
            "selector": selector,
            "caller": "address(0xdead)",
            "argument_source": argument_source,
        },
        execution_requirements=["the low-level call returns and the generated test reaches the assertion"],
        semantic_assumptions=["the selected caller is expected to be rejected for this instantiated check"],
        spec_basis={"kind": "recovered_access_candidate"},
        observation_sources=["generated test site", "Foundry assertion trace"],
        fact_refs=[fact_ref] if fact_ref else [],
        assertion_kind="assertTrue",
        rca_included=False,
    )


def _record_state_check(
        check_catalog,
        *,
        contract,
        suite_suffix,
        test_name,
        state_var,
        predicate,
        template,
        rule_id,
        activation_condition,
        fact_ref,
        terminal_values=None,
        spec_basis_kind="recovered_state_summary",
):
    bindings = {"state_variable": state_var}
    if terminal_values is not None:
        bindings["terminal_values"] = list(terminal_values)
    return _record_check_descriptor(
        check_catalog,
        rule_id=rule_id,
        template=template,
        suite=f"{contract}{suite_suffix}",
        test_name=test_name,
        predicate=predicate,
        bindings=bindings,
        execution_requirements=["the generated activation condition holds and the assertion executes"],
        semantic_assumptions=["the recovered state summary expresses the intended transition discipline"],
        spec_basis={"kind": spec_basis_kind},
        observation_sources=["generated test site", "Foundry assertion trace"],
        fact_refs=[fact_ref],
        assertion_kind="assertTrue",
        activation_condition=activation_condition,
        rca_included=False,
    )


def _first_storage_name(storage, *, mapping=None, scalar=None):
    for name, meta in (storage or {}).items():
        if not isinstance(meta, dict):
            continue
        low = str(name).lower()
        if mapping is not None:
            if not meta.get("is_mapping"):
                continue
            if all(token in low for token in mapping):
                return name
        if scalar is not None:
            if meta.get("is_mapping") or not meta.get("is_uint"):
                continue
            if all(token in low for token in scalar):
                return name
    return None


def _build_directed_accounting_delta_blocks(
        accounting,
        functions,
        storage,
        *,
        contract=None,
        check_catalog=None,
):
    blocks = []
    seen = set()
    for idx, inv in enumerate(accounting or []):
        bal = inv.get("mapping")
        sup = inv.get("supply")
        if not is_accounting_pair_testable(storage, bal, sup, functions):
            continue
        evidence_pairs = inv.get("evidence_pairs") or []
        for pair_idx, pair in enumerate(evidence_pairs):
            if pair.get("risk") != "delta_mismatch":
                continue
            fn_name = pair.get("function")
            if not fn_name or fn_name not in functions:
                continue
            sig = _function_signature_from_meta(fn_name, functions)
            if not sig or not _signature_matches_types(sig, ["uint"]):
                continue
            key = (bal, sup, fn_name, sig)
            if key in seen:
                continue
            seen.add(key)
            safe_fn = _sanitize_sol_var_name(fn_name, "fn")
            bal_sig = f"{bal}(address)"
            sup_sig = f"{sup}()"
            test_name = f"test_supplement_accounting_delta_mismatch_{idx}_{safe_fn}"
            if contract:
                _record_check_descriptor(
                    check_catalog,
                    rule_id="I1.accounting.delta_consistency",
                    template="accounting.delta_eq",
                    suite=f"{contract}AccountingSupplementTest",
                    test_name=test_name,
                    predicate="user_before - user_after == aggregate_before - aggregate_after",
                    bindings={
                        "action_function": fn_name,
                        "action_signature": sig,
                        "action_selector": (functions.get(fn_name) or {}).get("selector"),
                        "action_amount": 30,
                        "setup_signature": "deposit(uint256)",
                        "setup_amount": 100,
                        "account_getter": bal_sig,
                        "aggregate_getter": sup_sig,
                        "account_key": "address(this)",
                    },
                    execution_requirements=[
                        "setup call succeeds",
                        "pre-state getters succeed",
                        "action call succeeds",
                        "post-state getters succeed",
                    ],
                    semantic_assumptions=[
                        "the account and aggregate getters measure the same accounting unit",
                        "the directed action is expected to debit both quantities consistently",
                    ],
                    spec_basis={
                        "kind": "derived_accounting_relation",
                        "description": "matched per-account and aggregate update evidence",
                    },
                    observation_sources=["foundry assertion trace", "generated test site"],
                    fact_refs=[
                        f"analysis.accounting[{idx}]",
                        f"analysis.accounting[{idx}].evidence_pairs[{pair_idx}]",
                    ],
                )
            blocks.extend([
                "",
                f"    function {test_name}() public {{",
                "        // invariant: I1.accounting.delta_consistency",
                "        // precision-loss signal: paired account and aggregate deltas should match",
                f'        (bool okDeposit,) = address(target).call(abi.encodeWithSignature("deposit(uint256)", uint256(100)));',
                "        if(!okDeposit) return;",
                f'        (bool okUserBefore, uint256 userBefore) = _readUint1Addr("{bal_sig}", address(this));',
                f'        (bool okTotalBefore, uint256 totalBefore) = _readUint0("{sup_sig}");',
                "        if(!okUserBefore || !okTotalBefore) return;",
                f'        (bool okAction,) = address(target).call(abi.encodeWithSignature("{sig}", uint256(30)));',
                "        if(!okAction) return;",
                f'        (bool okUserAfter, uint256 userAfter) = _readUint1Addr("{bal_sig}", address(this));',
                f'        (bool okTotalAfter, uint256 totalAfter) = _readUint0("{sup_sig}");',
                "        if(!okUserAfter || !okTotalAfter) return;",
                "        assertEq(userBefore - userAfter, totalBefore - totalAfter);",
                "    }",
            ])
    return blocks


def _build_directed_rounding_drift_blocks(functions, storage):
    sig = _function_signature_from_meta("swap", functions)
    if not sig or not _signature_matches_types(sig, ["address", "uint"]):
        return []
    scalar = (
        _first_storage_name(storage, scalar=["invariant"])
        or _first_storage_name(storage, scalar=["total"])
    )
    if not scalar:
        return []
    scalar_sig = f"{scalar}()"
    return [
        "",
        "    function test_supplement_swap_rounding_drift_positive_output() public {",
        "        // invariant: I1.accounting.precision_loss",
        "        // weak AMM oracle: a positive swap input should not silently round to zero output while mutating invariant state",
        f'        (bool okBefore, uint256 beforeInvariant) = _readUint0("{scalar_sig}");',
        "        if(!okBefore || beforeInvariant == 0) return;",
        f'        (bool okSwap, bytes memory data) = address(target).call(abi.encodeWithSignature("{sig}", address(0xBEEF), uint256(2)));',
        "        if(!okSwap || data.length < 32) return;",
        "        uint256 amountOut = abi.decode(data, (uint256));",
        f'        (bool okAfter, uint256 afterInvariant) = _readUint0("{scalar_sig}");',
        "        if(!okAfter || afterInvariant == beforeInvariant) return;",
        "        assertTrue(amountOut > 0);",
        "    }",
    ]


# =========================
# Step 1: unified IR
# =========================

def build_initial_ir(contract_name, source_path, profile, solc_version):
    return {
        "meta": {
            "contract_name": contract_name,
            "source_path": str(source_path) if source_path else None,
            "profile": profile,
            "solc_version": solc_version,
        },
        "compiler_artifacts": {
            "storage_layout": None,
            "ir": None,
            "ir_optimized": None,
            "legacy_assembly": None,
            "has_storage_layout": False,
            "has_solc_ir": False,
            "has_solc_ir_optimized": False,
        },
        "storage_vars": [],
        "functions": [],
        "enums": [],
        "guards": [],
        "sensitive_functions": [],
        "access_anomalies": [],
        "state_vars": [],
        "transition_facts": [],
        "updates": [],
        "relations": [],
        "derived": {
            "storage": {},
            "function_map": {},
            "dfg": {},
            "update_facts": [],
            "accounting": [],
            "state_machine": {},
            "transition_facts": [],
            "access": [],
            "sensitive_functions": [],
            "guard_facts": [],
            "access_anomalies": [],
            "cross_relations": [],
            "accounting_anomalies": [],
        }
    }

def fill_ir_with_compiler_artifacts(ir,
                                    storage_layout=None,
                                    solc_ir=None,
                                    solc_ir_optimized=None,
                                    legacy_assembly=None):
    ir.setdefault("compiler_artifacts", {})
    ir["compiler_artifacts"]["storage_layout"] = _to_jsonable(storage_layout)
    ir["compiler_artifacts"]["ir"] = solc_ir
    ir["compiler_artifacts"]["ir_optimized"] = solc_ir_optimized
    ir["compiler_artifacts"]["legacy_assembly"] = _to_jsonable(legacy_assembly)

    ir["compiler_artifacts"]["has_storage_layout"] = storage_layout is not None
    ir["compiler_artifacts"]["has_solc_ir"] = bool(solc_ir)
    ir["compiler_artifacts"]["has_solc_ir_optimized"] = bool(solc_ir_optimized)

    return ir

def fill_ir_from_existing_analysis(ir,
                                   storage,
                                   functions,
                                   enums,
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
                                   accounting_anomalies):
    """
    Step 1 鐗堟湰锛氬厛涓嶉噸鍐欏叏閮ㄥ垎鏋愬櫒锛?
    鑰屾槸鎶婄幇鏈夊垎鏋愮粨鏋滄姇褰卞埌缁熶竴 IR 涓€?
    """

    # -------- storage vars --------
    for name, meta in storage.items():
        ir["storage_vars"].append({
            "name": name,
            "type": meta.get("type", ""),
            "is_mapping": meta.get("is_mapping", False),
            "is_uint": meta.get("is_uint", False),
            "is_address": meta.get("is_address", False),
            "is_enum": meta.get("is_enum", False),
            "visibility": meta.get("visibility", ""),
        })

    # -------- functions --------
    for name, fn in functions.items():
        ir["functions"].append({
            "name": name,
            "kind": fn.get("kind", ""),
            "stateMutability": fn.get("stateMutability", ""),
            "visibility": fn.get("visibility", ""),
            "signature": build_function_signature(fn),
            "modifiers": [
                m.get("modifierName", {}).get("name", "")
                for m in fn.get("modifiers", [])
            ]
        })

    # -------- enums --------
    for enum_name, members in enums.items():
        ir["enums"].append({
            "name": enum_name,
            "members": list(members)
        })

    # -------- explicit update facts --------
    for fact in update_facts:
        ir["updates"].append({
            "kind": "storage-update",
            "function": fact.get("function"),
            "target": fact.get("target"),
            "target_kind": fact.get("target_kind"),
            "op": fact.get("op"),
            "delta": fact.get("delta"),
            "index_expr": fact.get("index_expr"),
            "raw": fact.get("raw"),
        })

    # -------- dfg -> relations --------
    for fn_name, rw in dfg.items():
        for var in rw.get("reads", []):
            ir["relations"].append({
                "kind": "read",
                "function": fn_name,
                "var": var
            })
        for var in rw.get("writes", []):
            ir["relations"].append({
                "kind": "write",
                "function": fn_name,
                "var": var
            })
    
    # -------- guard facts --------
    for item in guard_facts:
        ir["guards"].append({
            "function": item.get("function"),
            "signature": item.get("signature"),
            "kind": item.get("kind"),
            "evidence": item.get("evidence"),
        })

    # -------- sensitive functions --------
    for item in sensitive_functions:
        ir["sensitive_functions"].append({
            "name": item.get("name"),
            "signature": item.get("signature"),
            "reasons": item.get("reasons", []),
            "writes": item.get("writes", []),
            "matched_name_keywords": item.get("matched_name_keywords", []),
            "matched_asset_keywords": item.get("matched_asset_keywords", []),
            "asset_write_targets": item.get("asset_write_targets", []),
            "asset_update_targets": item.get("asset_update_targets", []),
            "visibility": item.get("visibility", ""),
            "stateMutability": item.get("stateMutability", ""),
        })

    # -------- access anomalies --------
    for item in access_anomalies:
        ir["access_anomalies"].append({
            "name": item.get("name"),
            "signature": item.get("signature"),
            "type": item.get("type"),
            "reasons": item.get("reasons", []),
            "writes": item.get("writes", []),
        })

    # -------- state machine -> state vars --------
    for s in state_machine.get("states", []):
        detail = state_machine.get("details", {}).get(s, {})
        ir["state_vars"].append({
            "name": s,
            "enum_name": detail.get("enum_name"),
            "enum_values": detail.get("enum_values", []),
            "initial_candidates": detail.get("initial_candidates", []),
            "terminal_candidates": detail.get("terminal_candidates", [])
        })

    # -------- transition facts --------
    for tf in transition_facts:
        ir["transition_facts"].append({
            "state_var": tf.get("state_var"),
            "state_kind": tf.get("state_kind"),
            "function": tf.get("function"),
            "from_candidates": tf.get("from_candidates", []),
            "to": tf.get("to"),
            "guard_exprs": tf.get("guard_exprs", []),
            "raw": tf.get("raw"),
            "transition_kind": tf.get("transition_kind"),
            "op": tf.get("op"),
            "delta": tf.get("delta"),
        })

    for state_var, to_value in state_machine.get("transitions", []):
        ir["updates"].append({
            "kind": "state-transition",
            "state_var": state_var,
            "to": to_value
        })

    # -------- derived: 鐩存帴淇濈暀鏃х粨鏋勶紝渚涘吋瀹?--------
    ir["derived"]["storage"] = _to_jsonable(storage)
    ir["derived"]["function_map"] = {
        k: {
            "kind": v.get("kind", ""),
            "stateMutability": v.get("stateMutability", ""),
            "visibility": v.get("visibility", ""),
            "signature": build_function_signature(v),
        }
        for k, v in functions.items()
    }
    ir["derived"]["dfg"] = _to_jsonable(normalize_dfg(dfg))
    ir["derived"]["accounting"] = _to_jsonable(accounting)
    ir["derived"]["state_machine"] = _to_jsonable(state_machine)
    ir["derived"]["access"] = _to_jsonable(access)
    ir["derived"]["cross_relations"] = _to_jsonable(cross_relations)
    ir["derived"]["update_facts"] = _to_jsonable(update_facts)
    ir["derived"]["accounting_anomalies"] = _to_jsonable(accounting_anomalies)
    ir["derived"]["sensitive_functions"] = _to_jsonable(sensitive_functions)
    ir["derived"]["guard_facts"] = _to_jsonable(guard_facts)
    ir["derived"]["access_anomalies"] = _to_jsonable(access_anomalies)

    return ir

def derive_legacy_views_from_ir(ir):
    """
    浠庣粺涓€ IR 閲嶆柊瀵煎嚭褰撳墠 generator 浠嶇劧闇€瑕佺殑鏃х粨鏋?
    Step 1 涓厛灏介噺淇濇寔鍏煎
    """
    derived = ir.get("derived", {})

    storage = derived.get("storage", {})
    function_map = derived.get("function_map", {})
    accounting = derived.get("accounting", [])
    state_machine = derived.get("state_machine", {})
    access = derived.get("access", [])
    cross_relations = derived.get("cross_relations", [])

    return {
        "storage": storage,
        "function_map": function_map,
        "accounting": accounting,
        "state_machine": state_machine,
        "access": access,
        "cross_relations": cross_relations,
    }

def build_analysis_result_with_ir(contract_name,
                                  source_path,
                                  profile,
                                  solc_version,
                                  storage,
                                  functions,
                                  dfg,
                                  update_facts,
                                  cfg_info,
                                  accounting,
                                  state_machine,
                                  transition_facts,
                                  access,
                                  sensitive_functions,
                                  guard_facts,
                                  access_anomalies,
                                  cross_relations,
                                  accounting_anomalies,
                                  llm_invariants,
                                  ir,
                                  llm_candidates=None,
                                  llm_rejected=None):
    compiler_artifacts = (ir or {}).get("compiler_artifacts", {}) or {}
    uir_targets = build_uir_fuzzing_targets(
        functions=functions,
        storage=storage,
        dfg=dfg,
        update_facts=update_facts,
        accounting=accounting,
        state_machine=state_machine,
        transition_facts=transition_facts,
        access=access,
        sensitive_functions=sensitive_functions,
        guard_facts=guard_facts,
        access_anomalies=access_anomalies,
        cross_relations=cross_relations,
        accounting_anomalies=accounting_anomalies,
        abi=compiler_artifacts.get("abi"),
    )

    base = build_analysis_result(
        contract_name=contract_name,
        source_path=source_path,
        profile=profile,
        solc_version=solc_version,
        storage=storage,
        functions=functions,
        dfg=dfg,
        update_facts=update_facts,
        cfg_info=cfg_info,
        accounting=accounting,
        state_machine=state_machine,
        transition_facts=transition_facts,
        access=access,
        cross_relations=cross_relations,
        accounting_anomalies=accounting_anomalies,
        sensitive_functions=sensitive_functions,
        guard_facts=guard_facts,
        access_anomalies=access_anomalies,
        llm_invariants=llm_invariants,
        llm_candidates=llm_candidates,
        llm_rejected=llm_rejected,      
    )
    base["ir"] = _to_jsonable(ir)
    base["compiler_artifacts_summary"] = {
        "has_storage_layout": bool(ir.get("compiler_artifacts", {}).get("storage_layout")),
        "has_ir": bool(ir.get("compiler_artifacts", {}).get("ir")),
        "has_ir_optimized": bool(ir.get("compiler_artifacts", {}).get("ir_optimized")),
    }
    base["uir_targets"] = _to_jsonable(uir_targets)
    invariant_specs = default_invariant_specs()
    base["invariant_spec_registry"] = {
        "schema_version": "con-fuzzius.invariant_registry.v1",
        "six_family_taxonomy": _to_jsonable(benchmark_taxonomy()["six_invariant_families"]),
        "registry_summary": _to_jsonable(validate_registry(invariant_specs)),
        "specs": _to_jsonable(specs_to_jsonable(invariant_specs)),
    }
    base["benchmark_invariant_support"] = _to_jsonable(support_matrix())
    return base


def generate_foundry_supplement_tests_modern(contract,
                                             base_test_stem,
                                             solc_version,
                                             accounting,
                                             accounting_anomalies,
                                             state_machine,
                                             access,
                                             functions,
                                             cross_relations,
                                             storage,
                                             check_catalog=None):
    """
    Generate an opt-in supplemental Foundry test file that is intentionally
    separate from the main invariant test.

    The file imports <base_test_stem>_Invariant.t.sol and reuses the generated
    BaseTest/Handler contracts. Generation is conservative: only public/readable
    storage and handler-callable functions are emitted.
    """
    if parse_solc_version_number(solc_version) < (0, 7, 0):
        return ""

    L = []
    L.append("// SPDX-License-Identifier: UNLICENSED")
    L.append("pragma solidity >=0.7.0 <0.9.0;")
    if parse_solc_version_number(solc_version) < (0, 8, 0):
        L.append("pragma experimental ABIEncoderV2;")
    L.append(f'import "./{base_test_stem}_Invariant.t.sol";')
    L.append("")
    L.append("// Supplemental semantic-invariant tests generated separately from the main invariant file.")
    L.append("// These contracts are safe to edit, run, or disable without changing the baseline invariant tests.")
    L.append("")
    L.append(f"abstract contract {contract}SemanticSupplementBase is {contract}BaseTest {{")
    L.append("    function _readUint0(string memory sig) internal view returns (bool, uint256) {")
    L.append("        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig));")
    L.append("        if(!ok || data.length < 32) return (false, 0);")
    L.append("        return (true, abi.decode(data, (uint256)));")
    L.append("    }")
    L.append("")
    L.append("    function _readAddress0(string memory sig) internal view returns (bool, address) {")
    L.append("        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig));")
    L.append("        if(!ok || data.length < 32) return (false, address(0));")
    L.append("        return (true, abi.decode(data, (address)));")
    L.append("    }")
    L.append("")
    L.append("    function _readUint1Addr(string memory sig, address a) internal view returns (bool, uint256) {")
    L.append("        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig, a));")
    L.append("        if(!ok || data.length < 32) return (false, 0);")
    L.append("        return (true, abi.decode(data, (uint256)));")
    L.append("    }")
    L.append("}")

    emitted_any = False

    # ---------------- accounting delta / directed accounting checks ----------------
    accounting_blocks = []
    seen_accounting_keys = set()

    for idx, anom in enumerate(accounting_anomalies or []):
        fn_name = anom.get("function")
        bal = anom.get("mapping")
        sup = anom.get("supply")
        reason = str(anom.get("reason", ""))
        if not fn_name or fn_name not in functions:
            continue
        if not is_accounting_pair_testable(storage, bal, sup, functions):
            continue
        call_stmt = build_direct_handler_call_stmt(fn_name, functions)
        if not call_stmt:
            fn_meta = functions.get(fn_name) or {}
            call_stmt = _handler_call_stmt_from_signature(
                fn_name,
                anom.get("signature") or fn_meta.get("signature") or build_function_signature(fn_meta),
            )
        if not call_stmt:
            continue
        key = (fn_name, bal, sup, reason)
        if key in seen_accounting_keys:
            continue
        seen_accounting_keys.add(key)
        fn_safe = _sanitize_sol_var_name(fn_name, "fn")
        bal_sig = f"{bal}(address)"
        sup_sig = f"{sup}()"
        test_name = f"test_supplement_accounting_delta_{idx}_{fn_safe}"
        _record_check_descriptor(
            check_catalog,
            rule_id="I1.accounting.sum_equals_aggregate",
            template="accounting.sum_eq",
            suite=f"{contract}AccountingSupplementTest",
            test_name=test_name,
            predicate="sum(account[tracked_actors]) == aggregate",
            bindings={
                "action_function": fn_name,
                "action_signature": anom.get("signature") or (functions.get(fn_name) or {}).get("signature"),
                "action_selector": (functions.get(fn_name) or {}).get("selector"),
                "account_getter": bal_sig,
                "aggregate_getter": sup_sig,
                "actor_scope": "handler.actors",
            },
            execution_requirements=[
                "directed handler action completes",
                "all tracked account getters succeed",
                "aggregate getter succeeds",
            ],
            semantic_assumptions=[
                "handler.actors is a closed accounting population for this test",
                "the account and aggregate getters measure the same accounting unit",
            ],
            spec_basis={
                "kind": "candidate_accounting_anomaly",
                "reason": reason,
            },
            observation_sources=["foundry assertion trace", "generated test site"],
            fact_refs=[f"analysis.accounting_anomalies[{idx}]"],
        )
        accounting_blocks.extend([
            "",
            f"    function {test_name}() public {{",
            f"        // invariant: I1.accounting.delta_consistency",
            f"        // anomaly reason: {reason}",
            f"{call_stmt}",
            "        uint256 sum = 0;",
            "        uint256 n = handler.actorCount();",
            "        for(uint256 i = 0; i < n; i++){",
            "            address a = handler.actor(i);",
            f'            (bool okBal, uint256 balValue) = _readUint1Addr("{bal_sig}", a);',
            "            if(!okBal) return;",
            "            sum += balValue;",
            "        }",
            f'        (bool okSupply, uint256 supplyValue) = _readUint0("{sup_sig}");',
            "        if(!okSupply) return;",
            "        assertEq(sum, supplyValue);",
            "    }",
        ])

    accounting_blocks.extend(_build_directed_accounting_delta_blocks(
        accounting,
        functions,
        storage,
        contract=contract,
        check_catalog=check_catalog,
    ))

    if accounting_blocks:
        emitted_any = True
        L.append("")
        L.append(f"contract {contract}AccountingSupplementTest is {contract}SemanticSupplementBase {{")
        L.extend(accounting_blocks)
        L.append("}")

    # ---------------- precision-loss / rounding-drift weak AMM checks ----------------
    rounding_blocks = _build_directed_rounding_drift_blocks(functions, storage)
    if rounding_blocks:
        emitted_any = True
        L.append("")
        L.append(f"contract {contract}RoundingDriftSupplementTest is {contract}SemanticSupplementBase {{")
        L.extend(rounding_blocks)
        L.append("}")

    # ---------------- access non-interference ----------------
    access_blocks = []
    comparable_storage = []
    for var_name, meta in (storage or {}).items():
        if not isinstance(meta, dict) or meta.get("is_mapping"):
            continue
        lower = str(var_name).lower()
        if not any(token in lower for token in ["owner", "admin", "role", "supply", "phase", "state", "status", "implementation"]):
            continue
        comparable_storage.append((var_name, meta))

    for idx, item in enumerate(access or []):
        name = item.get("name")
        sig = item.get("signature")
        if not name or not sig or name not in functions:
            continue
        fn_def = functions.get(name)
        args_plan = build_default_args_plan_from_function_def(fn_def, var_prefix=f"supp_acc_{name}") if fn_def else None
        inline_args = build_default_call_args_from_function(fn_def) if fn_def else None
        if fn_def and not (fn_def.get("parameters", {}) or {}).get("parameters") and _signature_arg_types_string(sig):
            args_plan = None
            inline_args = ", ".join(
                _default_literal_for_signature_type(x.strip())
                for x in _signature_arg_types_string(sig).split(",")
                if x.strip()
            )
        if args_plan is None and inline_args is None:
            inline_args = build_default_call_args(sig)

        snapshots = []
        assertions = []
        for sidx, (var_name, meta) in enumerate(comparable_storage[:6]):
            safe = _sanitize_sol_var_name(var_name, f"s{sidx}")
            storage_sig = f"{var_name}()"
            if meta.get("is_enum"):
                snapshots.append(f'        (bool okPre_{safe}, uint256 pre_{safe}) = _readUint0("{storage_sig}");')
                assertions.append(f'        (bool okPost_{safe}, uint256 post_{safe}) = _readUint0("{storage_sig}");')
                assertions.append(f"        if(okPre_{safe} && okPost_{safe}) assertEq(post_{safe}, pre_{safe});")
            elif meta.get("is_address"):
                snapshots.append(f'        (bool okPre_{safe}, address pre_{safe}) = _readAddress0("{storage_sig}");')
                assertions.append(f'        (bool okPost_{safe}, address post_{safe}) = _readAddress0("{storage_sig}");')
                assertions.append(f"        if(okPre_{safe} && okPost_{safe}) assertEq(post_{safe}, pre_{safe});")
            elif meta.get("is_uint"):
                snapshots.append(f'        (bool okPre_{safe}, uint256 pre_{safe}) = _readUint0("{storage_sig}");')
                assertions.append(f'        (bool okPost_{safe}, uint256 post_{safe}) = _readUint0("{storage_sig}");')
                assertions.append(f"        if(okPre_{safe} && okPost_{safe}) assertEq(post_{safe}, pre_{safe});")

        if not assertions:
            continue

        safe_name = _sanitize_sol_var_name(name, "access_fn")
        access_blocks.append("")
        access_blocks.append(f"    function test_supplement_access_noninterference_{idx}_{safe_name}() public {{")
        access_blocks.append("        // invariant: I2.authorization.access_noninterference")
        access_blocks.extend(snapshots)
        if args_plan is not None:
            for line in args_plan.get("prelude_lines", []):
                access_blocks.append(f"        {line}")
        access_blocks.append("        address attacker = address(0xdead);")
        access_blocks.append("        vm.prank(attacker);")
        if args_plan is not None:
            call_args = args_plan.get("args_str", "")
            if call_args:
                access_blocks.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {call_args}));')
            else:
                access_blocks.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')
        else:
            if inline_args:
                access_blocks.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {inline_args}));')
            else:
                access_blocks.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')
        access_blocks.append("        ok;")
        access_blocks.extend(assertions)
        access_blocks.append("    }")

    if access_blocks:
        emitted_any = True
        L.append("")
        L.append(f"contract {contract}AccessNoninterferenceSupplementTest is {contract}SemanticSupplementBase {{")
        L.extend(access_blocks)
        L.append("}")

    if not emitted_any:
        return ""

    return "\n".join(L) + "\n"


def generate_foundry_supplement_tests_legacy(contract,
                                             base_test_stem,
                                             solc_version,
                                             accounting,
                                             accounting_anomalies,
                                             state_machine,
                                             functions,
                                             storage,
                                             check_catalog=None):
    """
    Generate a conservative supplemental property file for Solidity <0.7.0.

    Old Foundry harnesses in this generator use SimpleAssert/LegacyCheatcodes
    instead of forge-std Test, so this intentionally emits a smaller set of
    supplement properties that can reuse the baseline handler without modern
    try/catch, staticcall return decoding, or ABIEncoderV2 assumptions.
    """
    version = parse_solc_version_number(solc_version)
    if version >= (0, 7, 0):
        return ""

    base_contract = f"{contract}BasePropertyTest" if version >= (0, 5, 0) else f"{contract}LegacyPropertyTest"
    pragma_line = "pragma solidity >=0.5.0 <0.7.0;" if version >= (0, 5, 0) else "pragma solidity >=0.4.22 <0.5.0;"

    L = []
    handler_api = build_handler_api_table("legacy", state_machine, functions)
    L.append("// SPDX-License-Identifier: UNLICENSED")
    L.append(pragma_line)
    L.append(f'import "./{base_test_stem}_Invariant.t.sol";')
    L.append("")
    L.append("// Supplemental semantic-property tests for legacy Solidity harnesses.")
    L.append("// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.")

    emitted_any = False

    accounting_blocks = []
    seen_accounting_keys = set()

    for idx, anom in enumerate(accounting_anomalies or []):
        fn_name = anom.get("function")
        bal = anom.get("mapping")
        sup = anom.get("supply")
        reason = str(anom.get("reason", ""))
        if not fn_name or fn_name not in functions:
            continue
        if not is_accounting_pair_testable(storage, bal, sup, functions):
            continue

        call_stmt = build_direct_handler_call_stmt(fn_name, functions)
        if not call_stmt:
            fn_meta = functions.get(fn_name) or {}
            call_stmt = _handler_call_stmt_from_signature(
                fn_name,
                anom.get("signature") or fn_meta.get("signature") or build_function_signature(fn_meta),
            )
        if not call_stmt:
            continue

        key = (fn_name, bal, sup, reason)
        if key in seen_accounting_keys:
            continue
        seen_accounting_keys.add(key)

        fn_safe = _sanitize_sol_var_name(fn_name, "fn")
        bal_read = resolve_mapping_read_expr(bal, "handler.actor(i)", functions, storage)
        if not bal_read:
            continue
        sup_read = resolve_scalar_read_expr(sup, functions)
        if not sup_read:
            continue
        test_name = f"test_supplement_accounting_delta_{idx}_{fn_safe}"
        _record_accounting_aggregate_check(
            check_catalog,
            contract=contract,
            suite_suffix="LegacyAccountingSupplementTest",
            test_name=test_name,
            account=bal,
            aggregate=sup,
            account_read=bal_read,
            aggregate_read=sup_read,
            comparison="==",
            fact_ref=f"accounting_anomaly:{idx}",
            action_signature=anom.get("signature") or (functions.get(fn_name) or {}).get("signature"),
            action_selector=(functions.get(fn_name) or {}).get("selector"),
        )
        accounting_blocks.extend([
            "",
            f"    function {test_name}() public {{",
            "        // invariant: I1.accounting.delta_consistency",
            f"        // anomaly reason: {reason}",
            f"{call_stmt}",
            "        uint256 sum = 0;",
            "        uint256 n = handler.actorCount();",
            "        for(uint256 i = 0; i < n; i++){",
            f"            sum += target.{bal_read};",
            "        }",
            f"        _assertEq(sum, target.{sup_read});",
            "    }",
        ])

    if accounting_blocks:
        emitted_any = True
        L.append("")
        L.append(f"contract {contract}LegacyAccountingSupplementTest is {base_contract} {{")
        L.extend(accounting_blocks)
        L.append("}")

    terminal_blocks = []
    for s in state_machine.get("states", []) or []:
        if not handler_has_terminal_tracker(handler_api, s):
            record_dropped_invariant(
                state_machine,
                "supplement_terminal_absorbing",
                s,
                "missing_handler_tracker",
                {"profile": "legacy"},
            )
            continue
        detail = state_machine.get("details", {}).get(s, {})
        terminal_value_indices = resolve_terminal_value_indices(detail)
        if not terminal_value_indices:
            continue
        cond = " || ".join([f"curr == {x}" for x in terminal_value_indices]) or "true"
        safe_s = _sanitize_sol_var_name(s, "state")
        test_name = f"test_supplement_{safe_s}_terminal_absorbing"
        _record_state_check(
            check_catalog,
            contract=contract,
            suite_suffix="LegacyTerminalSupplementTest",
            test_name=test_name,
            state_var=s,
            predicate="current_state in terminal_values",
            template="state.terminal",
            rule_id="I3.state.terminal_absorbing",
            activation_condition=f"handler.entered_terminal_{s}()",
            fact_ref=f"state_summary:{s}",
            terminal_values=terminal_value_indices,
        )
        terminal_blocks.extend([
            "",
            f"    function {test_name}() public {{",
            "        // invariant: I3.state.terminal_absorbing",
            "        _run_basic_sequence();",
            f"        if(handler.entered_terminal_{s}()) {{",
            f"            uint256 curr = handler.curr_{s}();",
            f"            _assertTrue({cond});",
            "        }",
            "    }",
        ])

    if terminal_blocks:
        emitted_any = True
        L.append("")
        L.append(f"contract {contract}LegacyTerminalSupplementTest is {base_contract} {{")
        L.extend(terminal_blocks)
        L.append("}")

    # ---------------- legacy ETH-flow supplements ----------------
    eth_blocks = []

    escrow_like_scalars = []
    for var_name, meta in (storage or {}).items():
        if not isinstance(meta, dict) or not meta.get("is_uint") or meta.get("is_mapping"):
            continue
        low = str(var_name).lower()
        if any(token in low for token in ["deposit", "escrow", "locked", "balance", "amount"]):
            escrow_like_scalars.append(var_name)

    if escrow_like_scalars and any(fn in functions for fn in ["deposit", "release", "withdraw", "__fallback__"]):
        for idx, var_name in enumerate(escrow_like_scalars[:3]):
            read_expr = resolve_scalar_read_expr(var_name, functions)
            if not read_expr:
                continue
            safe_v = _sanitize_sol_var_name(var_name, f"escrow_{idx}")
            test_name = f"test_supplement_eth_balance_bound_{idx}_{safe_v}"
            _record_eth_bound_check(
                check_catalog,
                contract=contract,
                suite_suffix="LegacyEthFlowSupplementTest",
                test_name=test_name,
                predicate="tracked_escrow <= contract_balance",
                bindings={"tracked_storage": var_name, "tracked_read": read_expr},
                fact_ref=f"storage:{var_name}",
            )
            eth_blocks.extend([
                "",
                f"    function {test_name}() public {{",
                "        // invariant: I1.accounting.eth_balance_consistency",
                "        _run_basic_sequence();",
                f"        _assertTrue(target.{read_expr} <= address(target).balance);",
                "    }",
            ])

    if "__receive__" in functions:
        _record_eth_bound_check(
            check_catalog,
            contract=contract,
            suite_suffix="LegacyEthFlowSupplementTest",
            test_name="test_supplement_receive_no_retained_eth",
            predicate="contract_balance_after_receive <= contract_balance_before_receive",
            bindings={"action_signature": "receive()"},
            fact_ref="function:receive",
            rule_id="I4.transaction.receive_no_retained_eth",
            template="transaction.receive_balance_nonincrease",
        )
        eth_blocks.extend([
            "",
            "    function test_supplement_receive_no_retained_eth() public {",
            "        // invariant: I4.transaction.receive_no_retained_eth",
            "        uint256 beforeBalance = address(target).balance;",
            "        handler.call_receive();",
            "        _assertTrue(address(target).balance <= beforeBalance);",
            "    }",
        ])

    if eth_blocks:
        emitted_any = True
        L.append("")
        L.append(f"contract {contract}LegacyEthFlowSupplementTest is {base_contract} {{")
        L.extend(eth_blocks)
        L.append("}")

    if not emitted_any:
        return ""

    return "\n".join(L) + "\n"

def generate_foundry_tests_modern(contract,
                           file,
                           abi,
                           accounting,
                           accounting_anomalies,
                           state_machine,
                           access,
                           llm_codegen_candidates,
                           functions,
                           cross_relations,
                           storage,
                           solc_version,
                           source_text: Optional[str] = None,
                           check_catalog=None):

    L = []
    handler_api = build_handler_api_table("modern", state_machine, functions, storage=storage)

    # ctor_args = build_constructor_args_from_abi(abi)

    ctor_plan = build_constructor_args_from_abi(abi, source_text=source_text, contract_name=contract, solc_version=solc_version)

    L.append("// SPDX-License-Identifier: UNLICENSED")
    L.append("pragma solidity >=0.7.0 <0.9.0;")

    if parse_solc_version_number(solc_version) < (0, 8, 0):
        L.append("pragma experimental ABIEncoderV2;")

    L.append('import "forge-std/Test.sol";')

    L.append(f'import "../src/{file}.sol";')
    _emit_semantic_context_contracts(L, ctor_plan, solc_version)

    # ===============================
    # Handler contract
    # ===============================
    handler_lines = generate_handler(contract, functions, access, state_machine, "modern", solc_version, storage=storage)

    for line in handler_lines:
        L.append(line)

    L.append("")

    # ===============================
    # Base test contract
    # ===============================

    L.append(f"contract {contract}BaseTest is Test {{")

    L.append(f"    {contract} target;")
    L.append(f"    {contract}Handler handler;")
    L.append("    event SemInvReachability(uint256 attempted, uint256 successful, uint256 reverted);")

    L.append("")
    L.append("    function setUp() public virtual {")

    if ctor_plan is None:
        L.append('        revert("unsupported constructor args");')
    else:
        for line in ctor_plan.get("prelude_lines", []):
            L.append(f"        {line}")

        ctor_args = ctor_plan.get("args_str", "")
        if ctor_args == "":
            L.append(f"        target = new {contract}();")
        else:
            L.append(f"        target = new {contract}({ctor_args});")

    L.append(f"        handler = new {contract}Handler(target, vm);")
    L.append("        vm.deal(address(handler),100 ether);")
    L.append("        vm.deal(address(this),100 ether);")
    L.append("        vm.deal(address(target),100 ether);")
    _emit_constructor_context_setup(L, ctor_plan)
    L.append("        _semantic_bootstrap();")

    if has_transfer_ownership_function(functions):
        L.append('        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)",address(handler)));')
        L.append("        ok;")

    L.append("        targetContract(address(handler));")

    # selector generation
    selectors = collect_supported_handler_selectors(functions)
    n = len(selectors)

    if n > 0:

        L.append("")
        L.append(f"        bytes4[] memory selectors = new bytes4[]({n});")

        for i, s in enumerate(selectors):
            if s == "receive":
                L.append(f"        selectors[{i}] = handler.call_receive.selector;")
            elif s == "fallback":
                L.append(f"        selectors[{i}] = handler.call_fallback.selector;")
            else:
                L.append(f"        selectors[{i}] = handler.call_{s}.selector;")

        L.append("")
        L.append("        targetSelector(FuzzSelector({")
        L.append("            addr: address(handler),")
        L.append("            selectors: selectors")
        L.append("        }));")

    L.append("    }")
    _emit_semantic_sequence_function(L, functions)
    L.append("")
    L.append("    function _emit_reachability() internal {")
    L.append("        emit SemInvReachability(handler.attemptedCalls(), handler.successfulCalls(), handler.revertedCalls());")
    L.append("    }")
    _emit_semantic_bootstrap_function(L, functions, "modern")
    _emit_semantic_feedback_prepare_function(L)
    L.append("}")

    # ===============================
    # Always-on smoke test
    # 閬垮厤鏋佺畝鍚堢害锛堜粎 constructor / 浠?view锛夊鑷存暣浠芥枃浠舵病鏈変换浣曟祴璇曞嚱鏁?
    # ===============================
    #--------Accounting invariants-----------#
    
    L.append("")
    L.append(f"contract {contract}AccountingInvariantTest is {contract}BaseTest {{")

    for idx, inv in enumerate(_semantic_sort_named_items(accounting, _accounting_sort_label)):

        bal = inv["mapping"]
        sup = inv["supply"]

        bal_read = resolve_mapping_read_expr(bal, "a", functions, storage)
        if not bal_read:
            continue
        sup_read = resolve_scalar_read_expr(sup, functions)
        if not sup_read:
            continue

        test_name = f"invariant_accounting_{idx}"
        _record_accounting_aggregate_check(
            check_catalog,
            contract=contract,
            suite_suffix="AccountingInvariantTest",
            test_name=test_name,
            account=bal,
            aggregate=sup,
            account_read=bal_read,
            aggregate_read=sup_read,
            comparison="==",
            fact_ref=f"accounting_pair:{bal}:{sup}",
        )
        L.append("")
        L.append(f"    function {test_name}() public {{")
        L.append("        uint sum = 0;")
        L.append("        uint n = handler.actorCount();")
        L.append("        for(uint i=0;i<n;i++){")
        L.append("            address a = handler.actor(i);")
        L.append(f"            sum += target.{bal_read};")
        L.append("        }")
        L.append(f"        assertEq(sum,target.{sup_read});")
        L.append("    }")

        if _has_payable_or_eth_entry(functions):
            eth_test_name = f"invariant_eth_conservation_{idx}"
            _record_eth_bound_check(
                check_catalog,
                contract=contract,
                suite_suffix="AccountingInvariantTest",
                test_name=eth_test_name,
                predicate="contract_balance <= sum(handler.ethSent[handler.actors])",
                bindings={"actor_scope": "handler.actors", "flow_read": "handler.ethSent"},
                fact_ref=f"accounting_pair:{bal}:{sup}",
            )
            L.append("")
            L.append(f"    function {eth_test_name}() public {{")
            L.append("        uint n = handler.actorCount();")
            L.append("        uint totalSent = 0;")
            L.append("        for(uint i=0;i<n;i++){")
            L.append("            address a = handler.actor(i);")
            L.append("            totalSent += handler.ethSent(a);")
            L.append("        }")
            L.append("        assertTrue(address(target).balance <= totalSent);")
            L.append("    }")

    if not accounting and _has_erc20_supply_shape(functions):
        _record_accounting_aggregate_check(
            check_catalog,
            contract=contract,
            suite_suffix="AccountingInvariantTest",
            test_name="invariant_token_supply_covers_handler_actors",
            account="balanceOf",
            aggregate="totalSupply",
            account_read="balanceOf(a)",
            aggregate_read="totalSupply()",
            comparison="<=",
            fact_ref="shape:erc20_supply",
        )
        L.append("")
        L.append("    function invariant_token_supply_covers_handler_actors() public {")
        L.append("        uint sum = 0;")
        L.append("        uint n = handler.actorCount();")
        L.append("        for(uint i=0;i<n;i++){")
        L.append("            address a = handler.actor(i);")
        L.append("            sum += target.balanceOf(a);")
        L.append("        }")
        L.append("        assertTrue(sum <= target.totalSupply());")
        L.append("    }")

    L.append("}")

    #--------Accounting Anomaly-----------#

    if accounting_anomalies:
        L.append("")
        L.append(f"contract {contract}AccountingAnomalyTest is {contract}BaseTest {{")

        # 涓洪伩鍏嶅悓涓€ function 琚笉鍚?pair 閲嶅鐢熸垚锛屽厛鍘婚噸
        seen_anomaly_keys = set()

        for idx, anom in enumerate(accounting_anomalies):
            fn_name = anom.get("function")
            bal = anom.get("mapping")
            sup = anom.get("supply")
            reason = anom.get("reason", "")

            if not fn_name or fn_name not in functions:
                continue
            if not is_accounting_pair_testable(storage, bal, sup, functions):
                continue

            key = (fn_name, bal, sup, reason)
            if key in seen_anomaly_keys:
                continue
            seen_anomaly_keys.add(key)

            f = functions[fn_name]
            kind = f.get("kind", "")

            if fn_name not in ["__receive__", "__fallback__"] and not function_supported_by_handler(f):
                continue

            # 鍙敮鎸佸凡缁忕敓鎴愪簡 handler 鍖呰鐨勫嚱鏁?
            # __receive__ / __fallback__ 鍗曠嫭鏄犲皠
            if fn_name == "__receive__" or kind == "receive":
                call_stmt = "handler.call_receive();"
            elif fn_name == "__fallback__" or kind == "fallback":
                call_stmt = "handler.call_fallback();"
            else:
                args = build_default_call_args_from_function(f)
                if args is None:
                    args = build_default_call_args(build_function_signature(f))

                if args == "":
                    call_stmt = f"handler.call_{fn_name}();"
                else:
                    call_stmt = f"handler.call_{fn_name}({args});"

            # 缁熶竴鐢熸垚鈥滃畾鍚戣皟鐢ㄥ悗妫€鏌ユ€昏处鏄惁浠嶅畧鎭掆€濈殑娴嬭瘯
            bal_read = resolve_mapping_read_expr(bal, "a", functions, storage)
            if not bal_read:
                continue
            sup_read = resolve_scalar_read_expr(sup, functions)
            if not sup_read:
                continue
            test_name = f"test_accounting_anomaly_{idx}_{fn_name}"
            _record_accounting_aggregate_check(
                check_catalog,
                contract=contract,
                suite_suffix="AccountingAnomalyTest",
                test_name=test_name,
                account=bal,
                aggregate=sup,
                account_read=bal_read,
                aggregate_read=sup_read,
                comparison="==",
                fact_ref=f"accounting_anomaly:{idx}",
                action_signature=(f or {}).get("signature") or build_function_signature(f),
                action_selector=(f or {}).get("selector"),
            )
            L.append("")
            L.append(f"    function {test_name}() public {{")
            L.append(f"        // anomaly reason: {reason}")
            L.append(f"        // accounting pair: {bal} ~ {sup}")
            L.append(f"        {call_stmt}")
            L.append("        uint256 sum = 0;")
            L.append("        uint256 n = handler.actorCount();")
            L.append("        for(uint256 i = 0; i < n; i++){")
            L.append("            address a = handler.actor(i);")
            L.append(f"            sum += target.{bal_read};")
            L.append("        }")
            L.append(f"        assertEq(sum, target.{sup_read});")
            L.append("    }")

        L.append("}")

    #--------State Machine-----------#

    L.append("")
    L.append(f"contract {contract}StateInvariantTest is {contract}BaseTest {{")

    # -------- bool one-way / terminal invariants --------
    for s in _state_sort_items(state_machine):
        detail = state_machine.get("details", {}).get(s, {})
        state_kind = detail.get("state_kind", "")

        if state_kind != "bool":
            continue

        terminal_candidates = detail.get("terminal_candidates", [])
        transition_functions = detail.get("transition_functions", [])

        # 1) bool 鍩熷悎娉曟€?
        L.append("")
        # dropped: bool domain is guaranteed by Solidity's type system
        read_expr = resolve_state_read_expr(s, functions, storage=storage)
        # dropped: bool domain is guaranteed by Solidity's type system
        # dropped: bool domain is guaranteed by Solidity's type system
        # dropped: bool domain is guaranteed by Solidity's type system

        # 2) 鑻?true 琚瘑鍒负 terminal锛屽垯涓€鏃﹁繘鍏?true 涓嶅簲鍥炲埌 false
        if False:
            L.append("")
            # dropped: duplicate of generic terminal no-rollback invariant
            # dropped: duplicate of generic terminal no-rollback invariant
            # dropped: duplicate of generic terminal no-rollback invariant
            # dropped: duplicate of generic terminal no-rollback invariant
            L.append("        }")
            L.append("    }")

        # 3) 鑻?false 琚瘑鍒负 terminal锛屽垯涓€鏃﹁繘鍏?false 涓嶅簲鍥炲埌 true
        if False:
            L.append("")
            # dropped: duplicate of generic terminal no-rollback invariant
            L.append(f"        if(handler.entered_terminal_{s}()) {{")
            L.append(f"            uint256 curr = handler.curr_{s}();")
            L.append("            assertTrue(curr == 0);")
            L.append("        }")
            L.append("    }")

    # -------- uint monotonic stage invariants --------
    for s in _state_sort_items(state_machine):
        detail = state_machine.get("details", {}).get(s, {})
        state_kind = detail.get("state_kind", "")
        is_mono = detail.get("is_monotonic_uint_candidate", False)

        if not (state_kind == "uint" and is_mono):
            continue

        test_name = f"invariant_{s}_monotonic_uint"
        _record_state_check(
            check_catalog,
            contract=contract,
            suite_suffix="StateInvariantTest",
            test_name=test_name,
            state_var=s,
            predicate="current_state >= previous_state",
            template="state.monotonic",
            rule_id="I3.state.monotonic",
            activation_condition=f"handler.seen_{s}()",
            fact_ref=f"state_summary:{s}",
        )
        L.append("")
        L.append(f"    function {test_name}() public view {{")
        L.append(f"        if(handler.seen_{s}()) {{")
        L.append(f"            uint256 prev = handler.prev_{s}();")
        L.append(f"            uint256 curr = handler.curr_{s}();")
        L.append("            assertTrue(curr >= prev);")
        L.append("        }")
        L.append("    }")

    # -------- generic terminal no-rollback invariants --------
    for s in _state_sort_items(state_machine):
        detail = state_machine.get("details", {}).get(s, {})
        terminal_value_indices = resolve_terminal_value_indices(detail)

        if terminal_value_indices:
            if not handler_has_terminal_tracker(handler_api, s):
                record_dropped_invariant(
                    state_machine,
                    "state_terminal_no_rollback",
                    s,
                    "missing_handler_tracker",
                    {"profile": "modern"},
                )
                continue
            cond = " || ".join([f"curr == {x}" for x in terminal_value_indices]) or "true"

            test_name = f"invariant_{s}_no_rollback_after_terminal"
            _record_state_check(
                check_catalog,
                contract=contract,
                suite_suffix="StateInvariantTest",
                test_name=test_name,
                state_var=s,
                predicate="current_state in terminal_values",
                template="state.terminal",
                rule_id="I3.state.terminal_absorbing",
                activation_condition=f"handler.entered_terminal_{s}()",
                fact_ref=f"state_summary:{s}",
                terminal_values=terminal_value_indices,
            )
            L.append("")
            L.append(f"    function {test_name}() public view {{")
            L.append(f"        if(handler.entered_terminal_{s}()) {{")
            L.append(f"            uint256 curr = handler.curr_{s}();")
            L.append(f"            assertTrue({cond});")
            L.append("        }")
            L.append("    }")

    L.append("}")

    #--------State Transition Property Test-----------#

    L.append("")
    L.append(f"contract {contract}StateTransitionPropertyTest is {contract}BaseTest {{")

    for s in _state_sort_items(state_machine):

        detail = state_machine.get("details", {}).get(s, {})
        transition_functions = _transition_sort_items(detail.get("transition_functions", []))
        state_kind = detail.get("state_kind", "")

        for fn_name in transition_functions:

            if not can_generate_direct_handler_call(fn_name, functions):
                continue

            call_stmt = build_direct_handler_call_stmt(fn_name, functions)
            if not call_stmt:
                continue

            facts = get_transition_facts_for_function(state_machine, fn_name)

            L.append("")
            L.append(f"    function test_property_transition_{s}_{fn_name}() public {{")

            read_expr = resolve_state_read_expr(s, functions, storage=storage)
            if not read_expr:
                L.append("        return;")
                L.append("    }")
                continue
            if state_kind == "bool":
                L.append(f"        uint256 beforeV = target.{read_expr} ? 1 : 0;")
            else:
                L.append(f"        uint256 beforeV = uint256(target.{read_expr});")

            L.append(call_stmt)

            if state_kind == "bool":
                L.append(f"        uint256 afterV = target.{read_expr} ? 1 : 0;")
            else:
                L.append(f"        uint256 afterV = uint256(target.{read_expr});")

            # -------- transition fact based assertions --------
            emitted_assert = False

            for tf in facts:

                if tf.get("state_var") != s:
                    continue

                transition_kind = tf.get("transition_kind", "absolute")
                from_candidates = tf.get("from_candidates", [])

                if transition_kind == "relative" and state_kind == "uint":
                    op = tf.get("op")
                    delta = str(tf.get("delta", "")).strip()

                    if delta.isdigit():
                        if op == "add":
                            expr = f"afterV == beforeV + {delta}"
                        elif op == "sub":
                            expr = f"afterV + {delta} == beforeV"
                        else:
                            expr = "true"

                        normalized_froms = []
                        for fval in from_candidates:
                            fv = str(fval)
                            if fv.isdigit():
                                normalized_froms.append(fv)

                        if normalized_froms:
                            for fv in normalized_froms:
                                L.append(f"        if(beforeV == {fv} && handler.lastCallOk()) {{")
                                L.append(f"            assertTrue({expr});")
                                L.append("        }")
                                emitted_assert = True
                        else:
                            L.append("        if(handler.lastCallOk()) {")
                            L.append(f"            assertTrue({expr});")
                            L.append("        }")
                            emitted_assert = True

                    continue

                # -------- absolute transition --------
                to_v = tf.get("to")
                if to_v is None:
                    continue

                if isinstance(to_v, str) and not to_v.isdigit():
                    enum_vals = detail.get("enum_values", [])

                    if to_v in enum_vals:
                        to_v = str(enum_vals.index(to_v))
                    elif to_v.lower() == "true":
                        to_v = "1"
                    elif to_v.lower() == "false":
                        to_v = "0"
                    else:
                        # 闈炲父閲忕洰鏍囧€硷紙濡?y / b / expr锛夛紝璺宠繃鍏蜂綋 absolute 鏂█
                        continue

                normalized_froms = []

                for fval in from_candidates:
                    fv = fval
                    if isinstance(fv, str) and not fv.isdigit():
                        enum_vals = detail.get("enum_values", [])
                        if fv in enum_vals:
                            fv = str(enum_vals.index(fv))
                        elif fv.lower() == "true":
                            fv = "1"
                        elif fv.lower() == "false":
                            fv = "0"

                    if str(fv).isdigit():
                        normalized_froms.append(str(fv))

                if normalized_froms:
                    for fv in normalized_froms:
                        L.append(f"        if(beforeV == {fv} && handler.lastCallOk()) {{")
                        L.append(f"            assertTrue(afterV == {to_v});")
                        L.append("        }")
                        emitted_assert = True
                else:
                    L.append("        if(handler.lastCallOk()) {")
                    L.append(f"            assertTrue(afterV == {to_v});")
                    L.append("        }")
                    emitted_assert = True

            L.append("    }")

    emit_codegenable_llm_invariants(
        L=L,
        llm_candidates=[
            x for x in (llm_codegen_candidates or [])
            if _safe_lower(x.get("template_type")) == "state_guarded_transition"
        ],
        functions=functions,
        state_machine=state_machine,
        access=access,
        handler_api=handler_api,
        check_catalog=check_catalog,
        contract=contract,
        suite_suffix="StateTransitionPropertyTest",
    )

    L.append("}")

    #--------Access Control-----------#

    L.append("")
    L.append(f"contract {contract}AccessInvariantTest is {contract}BaseTest {{")

    for f in _access_sort_items(access):
        name = f["name"]
        sig = f["signature"]

        fn_def = functions.get(name)

        inline_args = build_default_call_args_from_function(fn_def) if fn_def else None
        args_plan = build_default_args_plan_from_function_def(fn_def, var_prefix=f"acc_{name}") if fn_def else None

        if inline_args is None and args_plan is None:
            inline_args = build_default_call_args(sig)

        test_name = f"invariant_access_{name}"
        _record_access_rejection_check(
            check_catalog,
            contract=contract,
            suite_suffix="AccessInvariantTest",
            test_name=test_name,
            function_name=name,
            signature=sig,
            selector=(fn_def or {}).get("selector"),
            argument_source="function_definition_plan" if args_plan is not None else "inline_defaults",
            fact_ref=f"access:{name}:{sig}",
        )
        L.append("")
        L.append(f"    function {test_name}() public {{")

        if args_plan is not None:
            for line in args_plan.get("prelude_lines", []):
                L.append(f"        {line}")

        L.append("        address attacker = address(0xdead);")
        L.append("        vm.prank(attacker);")

        if args_plan is not None:
            call_args = args_plan.get("args_str", "")
            if call_args:
                L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {call_args}));')
            else:
                L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')
        else:
            if inline_args:
                L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {inline_args}));')
            else:
                L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')

        L.append("        assertTrue(!ok);")
        L.append("    }")

    L.append("}")

    replay_code = generate_replay_script(contract, "modern", solc_version)
    if replay_code:
        L.append(replay_code)

    if not _has_generated_foundry_test_function(L):
        L.append("")
        L.append(f"contract {contract}SemanticReachabilityTest is {contract}BaseTest {{")
        L.append("    function test_semantic_setup_reachable() public {")
        L.append("        assertTrue(address(target) != address(0));")
        L.append("    }")
        L.append("}")

    L.append("")
    L.append(f"contract {contract}SemanticReachabilityReportTest is {contract}BaseTest {{")
    L.append("    function test_semantic_reachability_report() public {")
    L.append("        _run_semantic_sequence();")
    L.append("        _emit_reachability();")
    L.append("        assertTrue(address(target) != address(0));")
    L.append("    }")
    L.append("}")

    return "\n".join(L)

def generate_foundry_tests_mid_legacy(contract,
                                      file,
                                      abi,
                                      accounting,
                                      accounting_anomalies,
                                      state_machine,
                                      access,
                                      llm_invariants,
                                      functions,
                                      cross_relations,
                                      storage,
                                      solc_version,
                                      source_text: Optional[str] = None,
                                      check_catalog=None):

    def _default_arg_literals_from_fn(fn):
        return build_default_arg_literals_from_function_def(fn)

    def _iter_supported_mutating_functions():
        out = []
        for name, f in functions.items():
            if not function_supported_by_handler(f):
                continue

            args = _default_arg_literals_from_fn(f)
            if args is None:
                continue

            out.append((name, f, args))
        return out

    mutating_funcs = _semantic_sort_named_items(
        _iter_supported_mutating_functions(),
        lambda item: item[0],
    )

    L = []

    # ctor_args = build_constructor_args_from_abi(abi)
    ctor_plan = build_constructor_args_from_abi(abi, source_text=source_text, contract_name=contract, solc_version=solc_version)

    L.append("// SPDX-License-Identifier: UNLICENSED")
    L.append("pragma solidity >=0.5.0 <0.7.0;")
    L.append("pragma experimental ABIEncoderV2;")
    L.append(f'import "../src/{file}.sol";')
    _emit_semantic_context_contracts(L, ctor_plan, solc_version)

    L.append("")
    L.append("interface Vm {")
    L.append("    function deal(address who, uint256 newBalance) external;")
    L.append("    function startPrank(address) external;")
    L.append("    function stopPrank() external;")
    L.append("}")
    L.append("")
    L.append("contract LegacyCheatcodes {")
    L.append("    function _vm() internal pure returns (Vm) {")
    L.append('        return Vm(address(uint160(uint256(keccak256("hevm cheat code")))));')
    L.append("    }")
    L.append("}")

    L.append("")
    L.append("contract SimpleAssert {")
    L.append("    function _assertTrue(bool x) internal pure { require(x, \"assertTrue failed\"); }")
    L.append("    function _assertEq(uint256 a, uint256 b) internal pure { require(a == b, \"assertEq failed\"); }")
    L.append("}")

    handler_lines = generate_handler(contract, functions, access, state_machine, "mid_legacy", solc_version)
    for line in handler_lines:
        L.append(line)

    # ===============================
    # Base property test
    # ===============================
    L.append("")
    L.append(f"contract {contract}BasePropertyTest is SimpleAssert, LegacyCheatcodes {{")
    L.append(f"    {contract} target;")
    L.append(f"    {contract}Handler handler;")
    L.append("    event SemInvReachability(uint256 attempted, uint256 successful, uint256 reverted);")
    L.append("")
    L.append("    function setUp() public {")

    if ctor_plan is None:
        L.append('        revert("unsupported constructor args");')
    else:
        for line in ctor_plan.get("prelude_lines", []):
            L.append(f"        {line}")

        ctor_args = ctor_plan.get("args_str", "")
        if ctor_args == "":
            L.append(f"        target = new {contract}();")
        else:
            L.append(f"        target = new {contract}({ctor_args});")
        
    L.append(f"        handler = new {contract}Handler(target);")
    L.append("        _vm().deal(address(handler), 100 ether);")
    L.append("        _vm().deal(address(this), 100 ether);")
    L.append("        _vm().deal(address(target), 100 ether);")
    _emit_constructor_context_setup(L, ctor_plan)
    L.append("        _semantic_bootstrap();")

    # 灏濊瘯鎶?owner 杞粰 handler锛涘け璐ヤ笉褰卞搷
    # L.append('        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));')
    # 浠呭綋鐩爣鍚堢害瀛樺湪 transferOwnership(address) 鏃舵墠灏濊瘯杞Щ owner
    if has_transfer_ownership_function(functions):
        L.append('        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));')
    
    L.append("    }")
    _emit_semantic_bootstrap_function(L, functions, "mid_legacy")
    _emit_semantic_feedback_prepare_function(L)

    L.append("")
    L.append("    function _run_basic_sequence() internal {")

    for name, f, args in mutating_funcs:
        kind = f.get("kind", "")

        if name == "__receive__" or kind == "receive":
            call_stmt = "handler.call_receive();"
            L.append(f"        {call_stmt}")
            _emit_feedback_retry_lines(L, call_stmt)
            continue

        if name == "__fallback__" or kind == "fallback":
            call_stmt = "handler.call_fallback();"
            L.append(f"        {call_stmt}")
            _emit_feedback_retry_lines(L, call_stmt)
            continue

        if args == "":
            call_stmt = f"handler.call_{name}();"
        else:
            call_stmt = f"handler.call_{name}({args});"
        L.append(f"        {call_stmt}")
        _emit_feedback_retry_lines(L, call_stmt)

    L.append("    }")
    L.append("")
    L.append("    function _emit_reachability() internal {")
    L.append("        emit SemInvReachability(handler.attemptedCalls(), handler.successfulCalls(), handler.revertedCalls());")
    L.append("    }")
    L.append("}")

    # ===============================
    # Accounting properties
    # ===============================
    if accounting or _has_erc20_supply_shape(functions):
        L.append("")
        L.append(f"contract {contract}AccountingPropertyTest is {contract}BasePropertyTest {{")

        for idx, inv in enumerate(_semantic_sort_named_items(accounting, _accounting_sort_label)):
            bal = inv["mapping"]
            sup = inv["supply"]

            bal_read = resolve_mapping_read_expr(bal, "a", functions, storage)
            if not bal_read:
                continue
            sup_read = resolve_scalar_read_expr(sup, functions)
            if not sup_read:
                continue

            test_name = f"test_property_accounting_{idx}"
            _record_accounting_aggregate_check(
                check_catalog,
                contract=contract,
                suite_suffix="AccountingPropertyTest",
                test_name=test_name,
                account=bal,
                aggregate=sup,
                account_read=bal_read,
                aggregate_read=sup_read,
                comparison="<=",
                fact_ref=f"accounting_pair:{bal}:{sup}",
            )
            L.append("")
            L.append(f"    function {test_name}() public {{")
            L.append("        _run_basic_sequence();")
            L.append("        uint256 sum = 0;")
            L.append("        uint256 n = handler.actorCount();")
            L.append("        for(uint256 i = 0; i < n; i++){")
            L.append("            address a = handler.actor(i);")
            L.append(f"            sum += target.{bal_read};")
            L.append("        }")
            L.append(f"        _assertTrue(sum <= target.{sup_read});")
            L.append("    }")

            if _has_payable_or_eth_entry(functions):
                eth_test_name = f"test_property_eth_conservation_{idx}"
                _record_eth_bound_check(
                    check_catalog,
                    contract=contract,
                    suite_suffix="AccountingPropertyTest",
                    test_name=eth_test_name,
                    predicate="contract_balance <= sum(handler.ethSent[handler.actors])",
                    bindings={"actor_scope": "handler.actors", "flow_read": "handler.ethSent"},
                    fact_ref=f"accounting_pair:{bal}:{sup}",
                )
                L.append("")
                L.append(f"    function {eth_test_name}() public {{")
                L.append("        _run_basic_sequence();")
                L.append("        uint256 totalSent = 0;")
                L.append("        uint256 n = handler.actorCount();")
                L.append("        for(uint256 i = 0; i < n; i++){")
                L.append("            totalSent += handler.ethSent(handler.actor(i));")
                L.append("        }")
                L.append("        _assertTrue(address(target).balance <= totalSent);")
                L.append("    }")

        if not accounting and _has_erc20_supply_shape(functions):
            _record_accounting_aggregate_check(
                check_catalog,
                contract=contract,
                suite_suffix="AccountingPropertyTest",
                test_name="test_property_token_supply_covers_handler_actors",
                account="balanceOf",
                aggregate="totalSupply",
                account_read="balanceOf(handler.actor(i))",
                aggregate_read="totalSupply()",
                comparison="<=",
                fact_ref="shape:erc20_supply",
            )
            L.append("")
            L.append("    function test_property_token_supply_covers_handler_actors() public {")
            L.append("        _run_basic_sequence();")
            L.append("        uint256 sum = 0;")
            L.append("        uint256 n = handler.actorCount();")
            L.append("        for(uint256 i = 0; i < n; i++){")
            L.append("            sum += target.balanceOf(handler.actor(i));")
            L.append("        }")
            L.append("        _assertTrue(sum <= target.totalSupply());")
            L.append("    }")

        L.append("}")

    # ===============================
    # Accounting anomaly properties
    # ===============================
    if accounting_anomalies:
        L.append("")
        L.append(f"contract {contract}AccountingAnomalyPropertyTest is {contract}BasePropertyTest {{")

        seen_anomaly_keys = set()

        for idx, anom in enumerate(accounting_anomalies):
            fn_name = anom.get("function")
            bal = anom.get("mapping")
            sup = anom.get("supply")
            reason = anom.get("reason", "")

            if not fn_name or fn_name not in functions:
                continue
            if not is_accounting_pair_testable(storage, bal, sup, functions):
                continue

            key = (fn_name, bal, sup, reason)
            if key in seen_anomaly_keys:
                continue
            seen_anomaly_keys.add(key)

            f = functions[fn_name]
            kind = f.get("kind", "")

            if fn_name == "__receive__" or kind == "receive":
                call_stmt = "        handler.call_receive();"
            elif fn_name == "__fallback__" or kind == "fallback":
                call_stmt = "        handler.call_fallback();"
            else:
                args = _default_arg_literals_from_fn(f)
                if args is None:
                    continue
                if args == "":
                    call_stmt = f"        handler.call_{fn_name}();"
                else:
                    call_stmt = f"        handler.call_{fn_name}({args});"

            bal_read = resolve_mapping_read_expr(bal, "handler.actor(i)", functions, storage)
            if not bal_read:
                continue
            sup_read = resolve_scalar_read_expr(sup, functions)
            if not sup_read:
                continue

            test_name = f"test_property_accounting_anomaly_{idx}_{fn_name}"
            _record_accounting_aggregate_check(
                check_catalog,
                contract=contract,
                suite_suffix="AccountingAnomalyPropertyTest",
                test_name=test_name,
                account=bal,
                aggregate=sup,
                account_read=bal_read,
                aggregate_read=sup_read,
                comparison="==",
                fact_ref=f"accounting_anomaly:{idx}",
                action_signature=(f or {}).get("signature") or build_function_signature(f),
                action_selector=(f or {}).get("selector"),
            )
            L.append("")
            L.append(f"    function {test_name}() public {{")
            L.append(f"        // anomaly reason: {reason}")
            L.append(call_stmt)
            L.append("        uint256 sum = 0;")
            L.append("        uint256 n = handler.actorCount();")
            L.append("        for(uint256 i = 0; i < n; i++){")
            L.append(f"            sum += target.{bal_read};")
            L.append("        }")
            L.append(f"        _assertEq(sum, target.{sup_read});")
            L.append("    }")

        L.append("}")

    # ===============================
    # State transition properties
    # ===============================
    if state_machine.get("states"):
        L.append("")
        L.append(f"contract {contract}StateTransitionPropertyTest is {contract}BasePropertyTest {{")

        emitted_transition_fn_tests = set()

        for s in _state_sort_items(state_machine):
            detail = state_machine.get("details", {}).get(s, {})
            transition_functions = _transition_sort_items(detail.get("transition_functions", []))
            state_kind = detail.get("state_kind", "")
            is_mono_uint = detail.get("is_monotonic_uint_candidate", False)

            for fn_name in transition_functions:
                if fn_name not in functions:
                    continue
                if not can_generate_direct_handler_call(fn_name, functions):
                    continue

                key = (s, fn_name)
                if key in emitted_transition_fn_tests:
                    continue
                emitted_transition_fn_tests.add(key)

                f = functions[fn_name]
                kind = f.get("kind", "")

                if fn_name == "__receive__" or kind == "receive":
                    call_stmt = "        handler.call_receive();"
                elif fn_name == "__fallback__" or kind == "fallback":
                    call_stmt = "        handler.call_fallback();"
                else:
                    args = _default_arg_literals_from_fn(f)
                    if args is None:
                        continue
                    if args == "":
                        call_stmt = f"        handler.call_{fn_name}();"
                    else:
                        call_stmt = f"        handler.call_{fn_name}({args});"

                L.append("")
                L.append(f"    function test_transition_fn_{s}_{fn_name}() public {{")
                L.append(call_stmt)

                L.append("    }")

        L.append("}")

    # ===============================
    # Access properties
    # ===============================
    if access:
        L.append("")
        L.append(f"contract {contract}AccessPropertyTest is {contract}BasePropertyTest {{")

        for item in _access_sort_items(access):
            name = item["name"]
            sig = item["signature"]

            fn_def = functions.get(name)

            inline_args = build_default_call_args_from_function(fn_def) if fn_def else None
            args_plan = build_default_args_plan_from_function_def(fn_def, var_prefix=f"acc_{name}") if fn_def else None

            if inline_args is None and args_plan is None:
                inline_args = build_default_call_args(sig)

            test_name = f"test_property_access_{name}"
            _record_access_rejection_check(
                check_catalog,
                contract=contract,
                suite_suffix="AccessPropertyTest",
                test_name=test_name,
                function_name=name,
                signature=sig,
                selector=(fn_def or {}).get("selector"),
                argument_source="function_definition_plan" if args_plan is not None else "inline_defaults",
                fact_ref=f"access:{name}:{sig}",
            )
            L.append("")
            L.append(f"    function {test_name}() public {{")

            if args_plan is not None:
                for line in args_plan.get("prelude_lines", []):
                    L.append(f"        {line}")

            L.append("        address attacker = address(0xdead);")
            L.append("        _vm().startPrank(attacker);")

            if args_plan is not None:
                call_args = args_plan.get("args_str", "")
                if call_args:
                    L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {call_args}));')
                else:
                    L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')
            else:
                if inline_args:
                    L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}", {inline_args}));')
                else:
                    L.append(f'        (bool ok,) = address(target).call(abi.encodeWithSignature("{sig}"));')

            L.append("        _vm().stopPrank();")
            L.append("        _assertTrue(!ok);")
            L.append("    }")

        L.append("}")

    if not _has_generated_foundry_test_function(L):
        L.append("")
        L.append(f"contract {contract}SemanticReachabilityTest is {contract}BasePropertyTest {{")
        L.append("    function test_semantic_basic_sequence_reachable() public {")
        L.append("        _run_basic_sequence();")
        L.append("        _assertTrue(address(target) != address(0));")
        L.append("    }")
        L.append("}")

    L.append("")
    L.append(f"contract {contract}SemanticReachabilityReportTest is {contract}BasePropertyTest {{")
    L.append("    function test_semantic_reachability_report() public {")
    L.append("        _run_basic_sequence();")
    L.append("        _emit_reachability();")
    L.append("        _assertTrue(address(target) != address(0));")
    L.append("    }")
    L.append("}")

    L = _rewrite_pre_06_payable_literals(L, solc_version)
    return "\n".join(L)

def generate_foundry_tests_legacy(contract,
                                  file,
                                  abi,
                                  accounting,
                                  accounting_anomalies,
                                  state_machine,
                                  access,
                                  llm_invariants,
                                  functions,
                                  cross_relations,
                                  storage,
                                  solc_version,
                                  source_text: Optional[str] = None,
                                  check_catalog=None):
    
    def _default_arg_literals_from_fn(fn):
        return build_default_arg_literals_from_function_def(fn)
    
    def _iter_supported_mutating_functions():
        out = []
        for name, f in functions.items():
            if not function_supported_by_handler(f):
                continue

            args = _default_arg_literals_from_fn(f)
            if args is None:
                continue

            out.append((name, f, args))
        return out

    mutating_funcs = _semantic_sort_named_items(
        _iter_supported_mutating_functions(),
        lambda item: item[0],
    )

    L = []

    # ctor_args = build_constructor_args_from_abi(abi)
    ctor_plan = build_constructor_args_from_abi(abi, source_text=source_text, contract_name=contract, solc_version=solc_version)

    L.append("// SPDX-License-Identifier: UNLICENSED")
    version = parse_solc_version_number(solc_version)
    if version < (0, 4, 22):
        L.append(f"pragma solidity {str(solc_version).lstrip('v')};")
    else:
        L.append("pragma solidity >=0.4.22 <0.5.0;")
    L.append(f'import "../src/{file}.sol";')
    _emit_semantic_context_contracts(L, ctor_plan, solc_version)

    L.append("")
    L.append("interface Vm {")
    L.append("    function deal(address who, uint256 newBalance) external;")
    L.append("    function startPrank(address) external;")
    L.append("    function stopPrank() external;")
    L.append("}")
    L.append("")
    L.append("contract LegacyCheatcodes {")
    L.append("    function _vm() internal pure returns (Vm) {")
    L.append('        return Vm(address(uint160(uint256(keccak256("hevm cheat code")))));')
    L.append("    }")
    L.append("}")

    L.append("")
    L.append("contract SimpleAssert {")
    L.append("    function _assertTrue(bool x) internal pure { require(x); }")
    L.append("    function _assertEq(uint256 a, uint256 b) internal pure { require(a == b); }")
    L.append("}")

    handler_lines = generate_handler(contract, functions, access, state_machine, "legacy", solc_version)
    for line in handler_lines:
        L.append(line)

    # ===============================
    # Legacy minimal property test
    # ===============================
    L.append("")
    L.append(f"contract {contract}LegacyPropertyTest is SimpleAssert, LegacyCheatcodes {{")
    L.append(f"    {contract} target;")
    L.append(f"    {contract}Handler handler;")
    L.append("    event SemInvReachability(uint256 attempted, uint256 successful, uint256 reverted);")

    L.append("")
    L.append("    function setUp() public {")


    if ctor_plan is None:
        L.append('        revert("unsupported constructor args");')
    else:
        for line in ctor_plan.get("prelude_lines", []):
            L.append(f"        {line}")

        ctor_args = ctor_plan.get("args_str", "")
        if ctor_args == "":
            L.append(f"        target = new {contract}();")
        else:
            L.append(f"        target = new {contract}({ctor_args});")

    L.append(f"        handler = new {contract}Handler(target);")
    L.append("        _vm().deal(address(handler), 100 ether);")
    L.append("        _vm().deal(address(this), 100 ether);")
    L.append("        _vm().deal(address(target), 100 ether);")
    _emit_constructor_context_setup(L, ctor_plan)
    L.append("        _semantic_bootstrap();")
    
    # L.append('        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));')
    if has_transfer_ownership_function(functions):
        L.append('        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));')
    
    L.append("    }")
    _emit_semantic_bootstrap_function(L, functions, "legacy")
    _emit_semantic_feedback_prepare_function(L)

    L.append("")
    L.append("    function _run_basic_sequence() internal {")

    for name, f, args in mutating_funcs:
        kind = f.get("kind", "")

        if name == "__receive__" or kind == "receive":
            call_stmt = "handler.call_receive();"
            L.append(f"        {call_stmt}")
            _emit_feedback_retry_lines(L, call_stmt)
            continue

        if name == "__fallback__" or kind == "fallback":
            call_stmt = "handler.call_fallback();"
            L.append(f"        {call_stmt}")
            _emit_feedback_retry_lines(L, call_stmt)
            continue

        if args == "":
            call_stmt = f"handler.call_{name}();"
        else:
            call_stmt = f"handler.call_{name}({args});"
        L.append(f"        {call_stmt}")
        _emit_feedback_retry_lines(L, call_stmt)

    L.append("    }")
    L.append("")
    L.append("    function _emit_reachability() internal {")
    L.append("        emit SemInvReachability(handler.attemptedCalls(), handler.successfulCalls(), handler.revertedCalls());")
    L.append("    }")

    # ---------- accounting ----------
    if accounting or _has_erc20_supply_shape(functions):
        for idx, inv in enumerate(_semantic_sort_named_items(accounting, _accounting_sort_label)):
            bal = inv["mapping"]
            sup = inv["supply"]

            bal_read = resolve_mapping_read_expr(bal, "handler.actor(i)", functions, storage)
            if not bal_read:
                continue
            sup_read = resolve_scalar_read_expr(sup, functions)
            if not sup_read:
                continue

            test_name = f"test_property_accounting_{idx}"
            _record_accounting_aggregate_check(
                check_catalog,
                contract=contract,
                suite_suffix="LegacyPropertyTest",
                test_name=test_name,
                account=bal,
                aggregate=sup,
                account_read=bal_read,
                aggregate_read=sup_read,
                comparison="<=",
                fact_ref=f"accounting_pair:{bal}:{sup}",
            )
            L.append("")
            L.append(f"    function {test_name}() public {{")
            L.append("        _run_basic_sequence();")
            L.append("        uint256 sum = 0;")
            L.append("        uint256 n = handler.actorCount();")
            L.append("        for(uint256 i = 0; i < n; i++){")
            L.append(f"            sum += target.{bal_read};")
            L.append("        }")
            L.append(f"        _assertTrue(sum <= target.{sup_read});")
            L.append("    }")

            if _has_payable_or_eth_entry(functions):
                eth_test_name = f"test_property_eth_conservation_{idx}"
                _record_eth_bound_check(
                    check_catalog,
                    contract=contract,
                    suite_suffix="LegacyPropertyTest",
                    test_name=eth_test_name,
                    predicate="contract_balance <= sum(handler.ethSent[handler.actors])",
                    bindings={"actor_scope": "handler.actors", "flow_read": "handler.ethSent"},
                    fact_ref=f"accounting_pair:{bal}:{sup}",
                )
                L.append("")
                L.append(f"    function {eth_test_name}() public {{")
                L.append("        _run_basic_sequence();")
                L.append("        uint256 totalSent = 0;")
                L.append("        uint256 n = handler.actorCount();")
                L.append("        for(uint256 i = 0; i < n; i++){")
                L.append("            totalSent += handler.ethSent(handler.actor(i));")
                L.append("        }")
                L.append("        _assertTrue(address(target).balance <= totalSent);")
                L.append("    }")

        if not accounting and _has_erc20_supply_shape(functions):
            _record_accounting_aggregate_check(
                check_catalog,
                contract=contract,
                suite_suffix="LegacyPropertyTest",
                test_name="test_property_token_supply_covers_handler_actors",
                account="balanceOf",
                aggregate="totalSupply",
                account_read="balanceOf(handler.actor(i))",
                aggregate_read="totalSupply()",
                comparison="<=",
                fact_ref="shape:erc20_supply",
            )
            L.append("")
            L.append("    function test_property_token_supply_covers_handler_actors() public {")
            L.append("        _run_basic_sequence();")
            L.append("        uint256 sum = 0;")
            L.append("        uint256 n = handler.actorCount();")
            L.append("        for(uint256 i = 0; i < n; i++){")
            L.append("            sum += target.balanceOf(handler.actor(i));")
            L.append("        }")
            L.append("        _assertTrue(sum <= target.totalSupply());")
            L.append("    }")

    # ---------- accounting anomaly ----------
    if accounting_anomalies:
        seen_anomaly_keys = set()

        for idx, anom in enumerate(accounting_anomalies):
            fn_name = anom.get("function")
            bal = anom.get("mapping")
            sup = anom.get("supply")
            reason = anom.get("reason", "")

            if not fn_name or fn_name not in functions:
                continue
            if not is_accounting_pair_testable(storage, bal, sup, functions):
                continue

            key = (fn_name, bal, sup, reason)
            if key in seen_anomaly_keys:
                continue
            seen_anomaly_keys.add(key)

            f = functions[fn_name]
            kind = f.get("kind", "")

            if fn_name == "__receive__" or kind == "receive":
                call_stmt = "        handler.call_receive();"
            elif fn_name == "__fallback__" or kind == "fallback":
                call_stmt = "        handler.call_fallback();"
            else:
                args = _default_arg_literals_from_fn(f)
                if args is None:
                    continue
                if args == "":
                    call_stmt = f"        handler.call_{fn_name}();"
                else:
                    call_stmt = f"        handler.call_{fn_name}({args});"

            bal_read = resolve_mapping_read_expr(bal, "handler.actor(i)", functions, storage)
            if not bal_read:
                continue
            sup_read = resolve_scalar_read_expr(sup, functions)
            if not sup_read:
                continue

            test_name = f"test_property_accounting_anomaly_{idx}_{fn_name}"
            _record_accounting_aggregate_check(
                check_catalog,
                contract=contract,
                suite_suffix="LegacyPropertyTest",
                test_name=test_name,
                account=bal,
                aggregate=sup,
                account_read=bal_read,
                aggregate_read=sup_read,
                comparison="==",
                fact_ref=f"accounting_anomaly:{idx}",
                action_signature=(f or {}).get("signature") or build_function_signature(f),
                action_selector=(f or {}).get("selector"),
            )
            L.append("")
            L.append(f"    function {test_name}() public {{")
            L.append(f"        // anomaly reason: {reason}")
            L.append(call_stmt)
            L.append("        uint256 sum = 0;")
            L.append("        uint256 n = handler.actorCount();")
            L.append("        for(uint256 i = 0; i < n; i++){")
            L.append(f"            sum += target.{bal_read};")
            L.append("        }")
            L.append(f"        _assertEq(sum, target.{sup_read});")
            L.append("    }")

    # ---------- access ----------
    if access:
        for item in _access_sort_items(access):
            name = item["name"]
            sig = item["signature"]

            fn_def = functions.get(name)

            inline_args = build_default_call_args_from_function(fn_def) if fn_def else None
            args_plan = build_default_args_plan_from_function_def(fn_def, var_prefix=f"acc_{name}") if fn_def else None

            if inline_args is None and args_plan is None:
                inline_args = build_default_call_args(sig)

            test_name = f"test_property_access_{name}"
            _record_access_rejection_check(
                check_catalog,
                contract=contract,
                suite_suffix="LegacyPropertyTest",
                test_name=test_name,
                function_name=name,
                signature=sig,
                selector=(fn_def or {}).get("selector"),
                argument_source="function_definition_plan" if args_plan is not None else "inline_defaults",
                fact_ref=f"access:{name}:{sig}",
            )
            L.append("")
            L.append(f"    function {test_name}() public {{")

            if args_plan is not None:
                for line in args_plan.get("prelude_lines", []):
                    L.append(f"        {line}")

            L.append("        address attacker = address(0xdead);")
            L.append("        _vm().startPrank(attacker);")

            if args_plan is not None:
                call_args = args_plan.get("args_str", "")
                if call_args:
                    L.append(f'        bool ok = address(target).call(abi.encodeWithSignature("{sig}", {call_args}));')
                else:
                    L.append(f'        bool ok = address(target).call(abi.encodeWithSignature("{sig}"));')
            else:
                if inline_args:
                    L.append(f'        bool ok = address(target).call(abi.encodeWithSignature("{sig}", {inline_args}));')
                else:
                    L.append(f'        bool ok = address(target).call(abi.encodeWithSignature("{sig}"));')

            L.append("        _vm().stopPrank();")
            L.append("        _assertTrue(!ok);")
            L.append("    }")

    # ---------- state transition ----------
    if state_machine.get("states"):
        emitted_transition_fn_tests = set()

        for s in _state_sort_items(state_machine):
            detail = state_machine.get("details", {}).get(s, {})
            transition_functions = _transition_sort_items(detail.get("transition_functions", []))
            state_kind = detail.get("state_kind", "")
            is_mono_uint = detail.get("is_monotonic_uint_candidate", False)

            for fn_name in transition_functions:
                if fn_name not in functions:
                    continue
                if not can_generate_direct_handler_call(fn_name, functions):
                    continue

                key = (s, fn_name)
                if key in emitted_transition_fn_tests:
                    continue
                emitted_transition_fn_tests.add(key)

                f = functions[fn_name]
                kind = f.get("kind", "")

                if fn_name == "__receive__" or kind == "receive":
                    call_stmt = "        handler.call_receive();"
                elif fn_name == "__fallback__" or kind == "fallback":
                    call_stmt = "        handler.call_fallback();"
                else:
                    args = _default_arg_literals_from_fn(f)
                    if args is None:
                        continue
                    if args == "":
                        call_stmt = f"        handler.call_{fn_name}();"
                    else:
                        call_stmt = f"        handler.call_{fn_name}({args});"

                L.append("")
                L.append(f"    function test_transition_fn_{s}_{fn_name}() public {{")
                L.append(call_stmt)

                L.append("    }")

    L.append("}")

    if not _has_generated_foundry_test_function(L):
        L.append("")
        L.append(f"contract {contract}SemanticReachabilityTest is {contract}LegacyPropertyTest {{")
        L.append("    function test_semantic_basic_sequence_reachable() public {")
        L.append("        _run_basic_sequence();")
        L.append("        _assertTrue(address(target) != address(0));")
        L.append("    }")
        L.append("}")

    L.append("")
    L.append(f"contract {contract}SemanticReachabilityReportTest is {contract}LegacyPropertyTest {{")
    L.append("    function test_semantic_reachability_report() public {")
    L.append("        _run_basic_sequence();")
    L.append("        _emit_reachability();")
    L.append("        _assertTrue(address(target) != address(0));")
    L.append("    }")
    L.append("}")

    L = _rewrite_pre_06_payable_literals(L, solc_version)
    return "\n".join(L)
def generate_foundry_tests(contract,
                           file,
                           abi,
                           accounting,
                           accounting_anomalies,
                           state_machine,
                           access,
                           llm_codegen_candidates,
                           functions,
                           cross_relations,
                           storage,
                           profile,
                           solc_version,
                           source_text: Optional[str] = None,
                           check_catalog=None):

    if profile == "modern":
        return generate_foundry_tests_modern(
            contract,
            file,
            abi,
            accounting,
            accounting_anomalies,
            state_machine,
            access,
            llm_codegen_candidates,
            functions,
            cross_relations,
            storage,
            solc_version,
            source_text=source_text,
            check_catalog=check_catalog,
        )

    if profile == "mid_legacy":
        return generate_foundry_tests_mid_legacy(
            contract,
            file,
            abi,
            accounting,
            accounting_anomalies,
            state_machine,
            access,
            llm_codegen_candidates,
            functions,
            cross_relations,
            storage,
            solc_version,
            source_text=source_text,
            check_catalog=check_catalog,
        )

    return generate_foundry_tests_legacy(
        contract,
        file,
        abi,
        accounting,
        accounting_anomalies,
        state_machine,
        access,
        llm_codegen_candidates,
        functions,
        cross_relations,
        storage,
        solc_version,
        source_text=source_text,
        check_catalog=check_catalog,
    )

def fill_ir_with_summary_layer(ir, summaries, function_effects):
    ir["summary_layer"] = {
        "summaries": _to_jsonable(summaries),
        "function_effects": _to_jsonable(function_effects),
    }
    return ir

# def gen_invariant_tests(
#         contract_name, 
#         source_path,
#         source_code, 
#         abi, 
#         ast, 
#         cfg, 
#         solc_version: str,
#         api_key: str,
#         api_url: str = "https://api.openai.com/v1/chat/completions",
#         model: str = "gpt-4.1",
#         dump_dir: str = None,
#         dump_prefix: str = "",
#         return_analysis: bool = False,
#         storage_layout: dict = None,
#         solc_ir: str = None,
#         solc_ir_optimized: str = None,
#         legacy_assembly: dict = None,
#         compiler_artifacts: dict = None,):
    
#     if compiler_artifacts is None:
#         compiler_artifacts = {
#             "storage_layout": storage_layout,
#             "solc_ir": solc_ir,
#             "solc_ir_optimized": solc_ir_optimized,
#             "legacy_assembly": legacy_assembly,
#         }
#     else:
#         if storage_layout is None:
#             storage_layout = compiler_artifacts.get("storage_layout")
#         if solc_ir is None:
#             solc_ir = compiler_artifacts.get("solc_ir")
#         if solc_ir_optimized is None:
#             solc_ir_optimized = compiler_artifacts.get("solc_ir_optimized")
#         if legacy_assembly is None:
#             legacy_assembly = compiler_artifacts.get("legacy_assembly")

#     # 鍐嶇粺涓€鍐欏洖锛岄伩鍏嶅瓧鍏搁噷鍙湁鍏冧俊鎭?
#     compiler_artifacts["storage_layout"] = storage_layout
#     compiler_artifacts["solc_ir"] = solc_ir
#     compiler_artifacts["solc_ir_optimized"] = solc_ir_optimized
#     compiler_artifacts["legacy_assembly"] = legacy_assembly
    
#     filename = Path(source_path).stem if source_path else contract_name
#     profile = choose_version_profile(solc_version)

#     print("[InvariantGen] Starting analysis")
#     print("[InvariantGen] profile:", profile)

#     flattened = build_flattened_contract_view(ast, contract_name, storage_layout=storage_layout)

#     print("===== FLATTEN DEBUG =====")
#     print("storage:", flattened["storage"])
#     print("functions:", flattened["functions"].keys())
#     print("enums:", flattened["enums"])
#     print("=========================")

#     storage = flattened["storage"]
#     functions = flattened["functions"]
#     enums = flattened["enums"]

#     contract_ast = find_contract_node(ast, contract_name)

#     dfg = build_function_dfg(functions, storage)

#     ast_summaries = build_function_summaries(functions, storage)

#     ir_summaries = build_ir_function_summaries(
#         functions=functions,
#         storage=storage,
#         contract_name=contract_name,
#         compiler_artifacts=compiler_artifacts
#     )

#     if solc_ir_optimized:
#         print("[Step3.2B] solc_ir_optimized length:", len(solc_ir_optimized))
#         # print("[Step3.2B] solc_ir_optimized preview:")
#         # print(solc_ir_optimized[:2000])

#     summaries = merge_function_summaries(ast_summaries, ir_summaries)
#     summaries = propagate_internal_summaries(summaries)

#     transition_hints_by_fn = build_transition_hints_from_summaries(
#         summaries=summaries,
#         storage=storage,
#         enums=enums
#     )
#     for fn_name, hints in transition_hints_by_fn.items():
#         summaries.setdefault(fn_name, {})
#         summaries[fn_name]["transition_hints"] = hints

#     function_effects = build_unified_function_effects(
#         functions=functions,
#         summaries=summaries,
#         storage=storage
#     )

#     update_facts = fuse_update_facts_from_summaries(summaries)

#     print("[Step3-Fusion] AST summaries:", len(ast_summaries))
#     print("[Step3-Fusion] IR summaries:", len(ir_summaries))
#     print("[Step3-Fusion] merged summaries:", len(summaries))
#     print("[Step3-Fusion] fused update facts:", len(update_facts))

#     ir_nonempty = 0
#     for fn_name, info in ir_summaries.items():
#         if info.get("updates"):
#             ir_nonempty += 1
#     print("[Step3.2B] ir summaries with updates:", ir_nonempty)

#     ast_only = 0
#     ir_only = 0
#     ast_ir_both = 0

#     for u in update_facts:
#         srcs = set(u.get("evidence_sources", []))
#         if srcs == {"ast"}:
#             ast_only += 1
#         elif srcs and "ast" not in srcs:
#             ir_only += 1
#         elif "ast" in srcs and len(srcs) >= 2:
#             ast_ir_both += 1

#     print("[Step3.2B] evidence stats:", {
#         "ast_only": ast_only,
#         "ir_only": ir_only,
#         "ast_ir_both": ast_ir_both,
#     })

#     ir_only_preview = []
#     for u in update_facts:
#         srcs = set(u.get("evidence_sources", []))
#         if srcs and "ast" not in srcs:
#             ir_only_preview.append({
#                 "function": u.get("function"),
#                 "target": u.get("target"),
#                 "op": u.get("op"),
#                 "delta": u.get("delta"),
#                 "source": u.get("source"),
#                 "raw": u.get("raw"),
#             })

#     print("[Step3.2B] ir-only preview:", ir_only_preview[:10])

#     for fn_name in list(summaries.keys())[:10]:
#         info = summaries[fn_name]
#         print(f"[Step3-Fusion] {fn_name}: updates={len(info.get('updates', []))}, calls={len(info.get('calls', []))}, guards={len(info.get('guard_exprs', []))}")
            
#     cfg_info = analyze_cfg_paths(cfg)
#     accounting = infer_accounting_invariants_from_updates(storage, update_facts, functions)
#     accounting_anomalies = infer_accounting_anomalies(storage=storage, 
#                                                       update_facts=update_facts,
#                                                       accounting_invariants=accounting,
#                                                       functions=functions)

#     if profile in ["mid_legacy", "legacy"]:
#         filtered_accounting = []
#         for inv in accounting:
#             via = inv.get("via_function", "")
#             # legacy 涓鏋?via_function 鐪嬭捣鏉ュ儚鏋勯€犲嚱鏁版垨绌猴紝浼樺厛闄嶇骇淇濈暀
#             # 杩欓噷鍙仛杞婚噺杩囨护锛氬繀椤绘潵鑷櫘閫氳繍琛屾湡鍑芥暟
#             if via and via in functions:
#                 filtered_accounting.append(inv)
#         accounting = filtered_accounting

#     # state_machine = infer_state_machine(contract_ast, cfg)
#     state_machine = infer_state_machine(
#         contract_ast,
#         cfg,
#         flattened=flattened,
#         summaries=summaries
#     )
#     transition_facts = state_machine.get("transition_facts", [])

#     access_result = infer_access_control_v2(
#         functions=functions,
#         storage=storage,
#         update_facts=update_facts,
#         state_machine=state_machine,
#         summaries=summaries
#     )

#     access = access_result["access"]
#     sensitive_functions = access_result["sensitive_functions"]
#     guard_facts = access_result["guard_facts"]
#     access_anomalies = access_result["access_anomalies"]

#     cross_relations = infer_cross_function_relations(dfg, functions)

#     llm_candidates = []
#     llm_rejected = []
#     llm_codegen_candidates = []

#     # ---------- Step 1: build unified IR ----------
#     ir = build_initial_ir(
#         contract_name=contract_name,
#         source_path=source_path,
#         profile=profile,
#         solc_version=solc_version
#     )

#     ir = fill_ir_with_compiler_artifacts(
#         ir=ir,
#         storage_layout=storage_layout,
#         solc_ir=solc_ir,
#         solc_ir_optimized=solc_ir_optimized,
#         legacy_assembly=legacy_assembly,
#     )

#     ir = fill_ir_from_existing_analysis(
#         ir=ir,
#         storage=storage,
#         functions=functions,
#         enums=enums,
#         dfg=dfg,
#         update_facts=update_facts,
#         accounting=accounting,
#         state_machine=state_machine,
#         transition_facts=transition_facts,
#         access=access,
#         sensitive_functions=sensitive_functions,
#         guard_facts=guard_facts,
#         access_anomalies=access_anomalies,
#         cross_relations=cross_relations,
#         accounting_anomalies=accounting_anomalies
#     )

#     ir = fill_ir_with_summary_layer(
#         ir=ir,
#         summaries=summaries,
#         function_effects=function_effects
#     )

#     legacy_views = derive_legacy_views_from_ir(ir)
#     storage = legacy_views["storage"]
#     accounting = legacy_views["accounting"]
#     state_machine = legacy_views["state_machine"]
#     access = legacy_views["access"]
#     cross_relations = legacy_views["cross_relations"]

#     if profile == "mid_legacy":
#         # 涓棿鐗堟湰闄嶇骇: 涓嶇敓鎴愬鏉?cross invariant
#         cross_relations = []
#         # LLM 缁撴灉淇濈暀鍒嗘瀽锛屼絾榛樿涓嶈惤鍦版垚 Solidity invariant
#         # 杩欓噷鍏堜笉鍔?llm_invariants锛屽悗闈㈢敓鎴愭椂鎺у埗

#     if profile == "legacy":
#         # 鑰佺増鏈瀬绠€妯″紡: 杩涗竴姝ラ檷绾?
#         cross_relations = []
#         # 鍏抽棴澶嶆潅鐘舵€佹満缁嗚妭锛屽彧淇濈暀鏈€鍩烘湰 state 淇℃伅
#         state_machine["details"] = {}


#     if profile == "modern":
#         raw_llm_candidates = llm_generate_structured_candidates(
#             source_code=source_code,
#             accounting=accounting,
#             state_machine=state_machine,
#             access=access,
#             functions=functions,
#             storage=storage,
#             api_key=api_key,
#             api_url=api_url,
#             model=model,
#             max_candidates=8,
#         )

#         expanded_llm_candidates = expand_llm_access_candidates(raw_llm_candidates)

#         llm_result = filter_llm_candidates(
#             candidates=expanded_llm_candidates,
#             functions=functions,
#             state_machine=state_machine,
#             access=access
#         )

#         llm_candidates = llm_result.get("accepted", [])
#         llm_rejected = llm_result.get("rejected", [])

#         llm_codegen_candidates = select_codegenable_llm_candidates(
#             llm_candidates=llm_candidates,
#             functions=functions,
#             state_machine=state_machine,
#             access=access
#         )

#     else:
#         llm_codegen_candidates = []
#         llm_candidates = []
#         llm_rejected = []

#     ir = fill_ir_with_llm_candidates(
#         ir=ir,
#         llm_result={
#             "accepted": llm_candidates,
#             "rejected": llm_rejected,
#         }
#     )

#     foundry_code = generate_foundry_tests(
#         contract_name,
#         filename,
#         abi,
#         accounting,
#         accounting_anomalies,
#         state_machine,
#         access,
#         llm_codegen_candidates,
#         functions,
#         cross_relations,
#         storage,
#         profile,
#         solc_version
#     )

#     analysis_result = build_analysis_result_with_ir(
#         contract_name=contract_name,
#         source_path=source_path,
#         profile=profile,
#         solc_version=solc_version,
#         storage=storage,
#         functions=functions,
#         dfg=dfg,
#         update_facts=update_facts,
#         cfg_info=cfg_info,
#         accounting=accounting,
#         state_machine=state_machine,
#         transition_facts=transition_facts,
#         access=access,
#         sensitive_functions=sensitive_functions,
#         guard_facts=guard_facts,
#         access_anomalies=access_anomalies,
#         cross_relations=cross_relations,
#         accounting_anomalies=accounting_anomalies,
#         llm_invariants=llm_codegen_candidates,
#         ir=ir,
#         llm_candidates=llm_candidates,
#         llm_rejected=llm_rejected,
#     )

#     dump_baseline_artifacts(
#         output_dir=dump_dir,
#         analysis_result=analysis_result,
#         foundry_code=foundry_code,
#         prefix=dump_prefix
#     )

#     print("[InvariantGen] storage:", storage)
#     print("[InvariantGen] functions:", list(functions.keys()))
#     print("[InvariantGen] update_facts:", update_facts)
#     print("[InvariantGen] accounting:", accounting)
#     print("[InvariantGen] accounting_anomalies:", accounting_anomalies)
#     print("[InvariantGen] state_machine:", state_machine)
#     print("[InvariantGen] transition_facts:", transition_facts)
#     print("[InvariantGen] access:", access)
#     print("[InvariantGen] sensitive_functions:", sensitive_functions)
#     print("[InvariantGen] guard_facts:", guard_facts)
#     print("[InvariantGen] access_anomalies:", access_anomalies)
#     print("[Step4] llm accepted candidates:", llm_candidates)
#     print("[Step4] llm rejected:", llm_rejected[:10])
#     print("[Step4] llm rejected count:", len(llm_rejected))
#     print("[Step4] llm codegen candidates:", llm_codegen_candidates)
#     print("[InvariantGen] IR summary:",
#           {
#               "storage_vars": len(ir.get("storage_vars", [])),
#               "functions": len(ir.get("functions", [])),
#               "guards": len(ir.get("guards", [])),
#               "sensitive_functions": len(ir.get("sensitive_functions", [])),
#               "access_anomalies": len(ir.get("access_anomalies", [])),
#               "state_vars": len(ir.get("state_vars", [])),
#               "transition_facts": len(ir.get("transition_facts", [])),
#               "updates": len(ir.get("updates", [])),
#               "relations": len(ir.get("relations", [])),
#           })
#     print("[InvariantGen] baseline dump dir:", dump_dir)

#     print("[Step3.1A] inheritance:", flattened["inheritance_chain"])
#     print("[Step3.1A] storage:", list(storage.keys()))

#     print("[Step3.2A] has storage_layout:", storage_layout is not None)
#     print("[Step3.2A] has solc_ir:", bool(solc_ir))
#     print("[Step3.2A] has solc_ir_optimized:", bool(solc_ir_optimized))
#     print("[Step3.2A] compiler_artifacts keys:",
#         list(compiler_artifacts.keys()) if isinstance(compiler_artifacts, dict) else None)

#     print("[InvariantGen] Done")

#     if return_analysis:
#         return {
#             "foundry_code": foundry_code,
#             "analysis": analysis_result,
#         }

#     return foundry_code

def build_contract_ir(
        contract_name,
        source_path,
        source_code,
        abi,
        ast,
        cfg,
        solc_version,
        storage_layout=None,
        solc_ir=None,
        solc_ir_optimized=None,
        legacy_assembly=None,
        compiler_artifacts=None,
):
    if compiler_artifacts is None:
        compiler_artifacts = {
            "storage_layout": storage_layout,
            "solc_ir": solc_ir,
            "solc_ir_optimized": solc_ir_optimized,
            "legacy_assembly": legacy_assembly,
        }
    else:
        if storage_layout is None:
            storage_layout = compiler_artifacts.get("storage_layout")
        if solc_ir is None:
            solc_ir = compiler_artifacts.get("solc_ir")
        if solc_ir_optimized is None:
            solc_ir_optimized = compiler_artifacts.get("solc_ir_optimized")
        if legacy_assembly is None:
            legacy_assembly = compiler_artifacts.get("legacy_assembly")

    compiler_artifacts["storage_layout"] = storage_layout
    compiler_artifacts["abi"] = abi or []
    compiler_artifacts["solc_ir"] = solc_ir
    compiler_artifacts["solc_ir_optimized"] = solc_ir_optimized
    compiler_artifacts["legacy_assembly"] = legacy_assembly

    filename = Path(source_path).stem if source_path else contract_name
    profile = choose_version_profile(solc_version)

    print("[InvariantGen] Starting IR build")
    print("[InvariantGen] profile:", profile)

    flattened = build_flattened_contract_view(ast, contract_name, storage_layout=storage_layout)

    print("===== FLATTEN DEBUG =====")
    print("storage:", flattened["storage"])
    print("functions:", flattened["functions"].keys())
    print("enums:", flattened["enums"])
    print("=========================")

    storage = flattened["storage"]
    functions = flattened["functions"]
    enums = flattened["enums"]
    contract_ast = find_contract_node(ast, contract_name)

    dfg = build_function_dfg(functions, storage)

    ast_summaries = build_function_summaries(functions, storage)
    ir_summaries = build_ir_function_summaries(
        functions=functions,
        storage=storage,
        contract_name=contract_name,
        compiler_artifacts=compiler_artifacts
    )

    summaries = merge_function_summaries(ast_summaries, ir_summaries)
    summaries = propagate_internal_summaries(summaries)

    transition_hints_by_fn = build_transition_hints_from_summaries(
        summaries=summaries,
        storage=storage,
        enums=enums
    )
    for fn_name, hints in transition_hints_by_fn.items():
        summaries.setdefault(fn_name, {})
        summaries[fn_name]["transition_hints"] = hints

    function_effects = build_unified_function_effects(
        functions=functions,
        summaries=summaries,
        storage=storage
    )

    update_facts = fuse_update_facts_from_summaries(summaries)

    ir = build_initial_ir(
        contract_name=contract_name,
        source_path=source_path,
        profile=profile,
        solc_version=solc_version
    )

    ir = fill_ir_with_compiler_artifacts(
        ir=ir,
        storage_layout=storage_layout,
        solc_ir=solc_ir,
        solc_ir_optimized=solc_ir_optimized,
        legacy_assembly=legacy_assembly,
    )
    ir.setdefault("compiler_artifacts", {})["abi"] = _to_jsonable(abi or [])

    return {
        "filename": filename,
        "profile": profile,
        "compiler_artifacts": compiler_artifacts,
        "flattened": flattened,
        "contract_ast": contract_ast,
        "storage": storage,
        "functions": functions,
        "enums": enums,
        "dfg": dfg,
        "ast_summaries": ast_summaries,
        "ir_summaries": ir_summaries,
        "summaries": summaries,
        "function_effects": function_effects,
        "update_facts": update_facts,
        "ir": ir,
    }

def recover_invariants(
        contract_name,
        source_path,
        cfg,
        solc_version,
        ir_build_result,
):
    profile = ir_build_result["profile"]
    flattened = ir_build_result["flattened"]
    contract_ast = ir_build_result["contract_ast"]
    storage = ir_build_result["storage"]
    functions = ir_build_result["functions"]
    enums = ir_build_result["enums"]
    dfg = ir_build_result["dfg"]
    summaries = ir_build_result["summaries"]
    function_effects = ir_build_result["function_effects"]
    update_facts = ir_build_result["update_facts"]
    ir = ir_build_result["ir"]

    cfg_info = analyze_cfg_paths(cfg)

    accounting = infer_accounting_invariants_from_updates(storage, update_facts, functions)
    accounting_anomalies = infer_accounting_anomalies(
        storage=storage,
        update_facts=update_facts,
        accounting_invariants=accounting,
        functions=functions
    )

    if profile in ["mid_legacy", "legacy"]:
        filtered_accounting = []
        for inv in accounting:
            via = inv.get("via_function", "")
            if via and via in functions:
                filtered_accounting.append(inv)
        accounting = filtered_accounting

    accounting.extend(infer_named_accounting_pairs_from_storage(storage, accounting, functions))
    accounting = [
        inv for inv in accounting
        if is_accounting_pair_testable(storage, inv.get("mapping"), inv.get("supply"), functions)
    ]

    state_machine = infer_state_machine(
        contract_ast,
        cfg,
        flattened=flattened,
        summaries=summaries
    )
    state_machine = augment_bool_terminal_candidates(state_machine)
    transition_facts = state_machine.get("transition_facts", [])

    access_result = infer_access_control_v2(
        functions=functions,
        storage=storage,
        update_facts=update_facts,
        state_machine=state_machine,
        summaries=summaries
    )

    access = access_result["access"]
    sensitive_functions = access_result["sensitive_functions"]
    guard_facts = access_result["guard_facts"]
    access_anomalies = access_result["access_anomalies"]

    cross_relations = infer_cross_function_relations(dfg, functions)

    ir = fill_ir_from_existing_analysis(
        ir=ir,
        storage=storage,
        functions=functions,
        enums=enums,
        dfg=dfg,
        update_facts=update_facts,
        accounting=accounting,
        state_machine=state_machine,
        transition_facts=transition_facts,
        access=access,
        sensitive_functions=sensitive_functions,
        guard_facts=guard_facts,
        access_anomalies=access_anomalies,
        cross_relations=cross_relations,
        accounting_anomalies=accounting_anomalies
    )

    ir = fill_ir_with_summary_layer(
        ir=ir,
        summaries=summaries,
        function_effects=function_effects
    )

    legacy_views = derive_legacy_views_from_ir(ir)
    storage = legacy_views["storage"]
    accounting = legacy_views["accounting"]
    state_machine = legacy_views["state_machine"]
    access = legacy_views["access"]
    cross_relations = legacy_views["cross_relations"]

    if profile == "mid_legacy":
        cross_relations = []

    if profile == "legacy":
        cross_relations = []
        state_machine["details"] = {}

    return {
        "profile": profile,
        "storage": storage,
        "functions": functions,
        "enums": enums,
        "dfg": dfg,
        "summaries": summaries,
        "function_effects": function_effects,
        "update_facts": update_facts,
        "cfg_info": cfg_info,
        "accounting": accounting,
        "accounting_anomalies": accounting_anomalies,
        "state_machine": state_machine,
        "transition_facts": transition_facts,
        "access": access,
        "sensitive_functions": sensitive_functions,
        "guard_facts": guard_facts,
        "access_anomalies": access_anomalies,
        "cross_relations": cross_relations,
        "ir": ir,
    }

def complete_invariants_with_llm(
        source_code,
        api_key,
        api_url,
        model,
        invariant_result,
):
    profile = invariant_result["profile"]
    storage = invariant_result["storage"]
    functions = invariant_result["functions"]
    state_machine = invariant_result["state_machine"]
    access = invariant_result["access"]
    ir = invariant_result["ir"]

    llm_candidates = []
    llm_rejected = []
    llm_codegen_candidates = []

    if profile == "modern":
        raw_llm_candidates = llm_generate_structured_candidates(
            source_code=source_code,
            accounting=invariant_result["accounting"],
            state_machine=state_machine,
            access=access,
            functions=functions,
            storage=storage,
            api_key=api_key,
            api_url=api_url,
            model=model,
            max_candidates=8,
        )

        expanded_llm_candidates = expand_llm_access_candidates(raw_llm_candidates)

        llm_result = filter_llm_candidates(
            candidates=expanded_llm_candidates,
            functions=functions,
            state_machine=state_machine,
            access=access
        )

        llm_candidates = llm_result.get("accepted", [])
        llm_rejected = llm_result.get("rejected", [])

        llm_codegen_candidates = select_codegenable_llm_candidates(
            llm_candidates=llm_candidates,
            functions=functions,
            state_machine=state_machine,
            access=access
        )

    ir = fill_ir_with_llm_candidates(
        ir=ir,
        llm_result={
            "accepted": llm_candidates,
            "rejected": llm_rejected,
        }
    )

    invariant_result = dict(invariant_result)
    invariant_result["ir"] = ir
    invariant_result["llm_candidates"] = llm_candidates
    invariant_result["llm_rejected"] = llm_rejected
    invariant_result["llm_codegen_candidates"] = llm_codegen_candidates

    return invariant_result

def generate_foundry_invariant_tests(
        contract_name,
        source_path,
        abi,
        solc_version,
        invariant_result,
        dump_dir=None,
        dump_prefix="",
        return_analysis=False,
        supplement_base_stem=None,
):
    filename = Path(source_path).stem if source_path else contract_name
    source_text = None
    if source_path:
        try:
            source_text = Path(source_path).read_text(encoding="utf-8", errors="ignore")
        except Exception:
            source_text = None

    profile = invariant_result["profile"]
    storage = invariant_result["storage"]
    functions = invariant_result["functions"]
    dfg = invariant_result["dfg"]
    update_facts = invariant_result["update_facts"]
    cfg_info = invariant_result["cfg_info"]
    accounting = invariant_result["accounting"]
    accounting_anomalies = invariant_result["accounting_anomalies"]
    state_machine = invariant_result["state_machine"]
    transition_facts = invariant_result["transition_facts"]
    access = invariant_result["access"]
    sensitive_functions = invariant_result["sensitive_functions"]
    guard_facts = invariant_result["guard_facts"]
    access_anomalies = invariant_result["access_anomalies"]
    cross_relations = invariant_result["cross_relations"]
    ir = invariant_result["ir"]
    llm_candidates = invariant_result.get("llm_candidates", [])
    llm_rejected = invariant_result.get("llm_rejected", [])
    llm_codegen_candidates = invariant_result.get("llm_codegen_candidates", [])

    check_catalog = []
    foundry_code = generate_foundry_tests(
        contract_name,
        filename,
        abi,
        accounting,
        accounting_anomalies,
        state_machine,
        access,
        llm_codegen_candidates,
        functions,
        cross_relations,
        storage,
        profile,
        solc_version,
        source_text=source_text,
        check_catalog=check_catalog,
    )

    supplement_base_stem = supplement_base_stem or contract_name
    standalone_supplement_code = ""
    if profile == "modern":
        standalone_supplement_code = generate_foundry_supplement_tests_modern(
            contract=contract_name,
            base_test_stem=supplement_base_stem,
            solc_version=solc_version,
            accounting=accounting,
            accounting_anomalies=accounting_anomalies,
            state_machine=state_machine,
            access=access,
            functions=functions,
            cross_relations=cross_relations,
            storage=storage,
            check_catalog=check_catalog,
        )
    elif profile in ("mid_legacy", "legacy"):
        standalone_supplement_code = generate_foundry_supplement_tests_legacy(
            contract=contract_name,
            base_test_stem=supplement_base_stem,
            solc_version=solc_version,
            accounting=accounting,
            accounting_anomalies=accounting_anomalies,
            state_machine=state_machine,
            functions=functions,
            storage=storage,
            check_catalog=check_catalog,
        )

    inline_supplement_code = inline_foundry_supplement_code(standalone_supplement_code)
    if inline_supplement_code:
        foundry_code = (
            foundry_code.rstrip()
            + "\n\n// ===============================\n"
            + "// L3 supplemental semantic invariants\n"
            + "// ===============================\n"
            + inline_supplement_code
            + "\n"
        )

    foundry_code = repair_snapshot_helper_mismatches(foundry_code)

    analysis_result = build_analysis_result_with_ir(
        contract_name=contract_name,
        source_path=source_path,
        profile=profile,
        solc_version=solc_version,
        storage=storage,
        functions=functions,
        dfg=dfg,
        update_facts=update_facts,
        cfg_info=cfg_info,
        accounting=accounting,
        state_machine=state_machine,
        transition_facts=transition_facts,
        access=access,
        sensitive_functions=sensitive_functions,
        guard_facts=guard_facts,
        access_anomalies=access_anomalies,
        cross_relations=cross_relations,
        accounting_anomalies=accounting_anomalies,
        llm_invariants=llm_codegen_candidates,
        ir=ir,
        llm_candidates=llm_candidates,
        llm_rejected=llm_rejected,
    )
    checks_by_test = {}
    checks_by_selector = {}
    checks_by_template = {}
    for check in check_catalog:
        site = check.get("site") or {}
        site_key = "%s::%s" % (site.get("suite"), site.get("test"))
        checks_by_test.setdefault(site_key, []).append(check.get("check_ref"))
        selector = (check.get("bindings") or {}).get("action_selector")
        if selector:
            checks_by_selector.setdefault(str(selector), []).append(check.get("check_ref"))
        template = check.get("template")
        if template:
            checks_by_template.setdefault(str(template), []).append(check.get("check_ref"))
    cataloged_templates = sorted(checks_by_template)
    analysis_result["check_catalog"] = _to_jsonable(check_catalog)
    analysis_result["check_catalog_status"] = {
        "schema_version": "con-fuzzius.check_catalog.v1",
        "coverage": "emitted_single_assertion_sites",
        "cataloged_check_count": len(check_catalog),
        "cataloged_templates": cataloged_templates,
        "unresolved_policy": "multi_assertion_or_ambiguous_sites",
        "note": "Generated single-assertion sites with explicit predicate and program bindings are cataloged; ambiguous sites retain their backend evidence without a generated-check descriptor.",
    }
    analysis_result["check_index"] = {
        "by_test": _to_jsonable(checks_by_test),
        "by_selector": _to_jsonable(checks_by_selector),
        "by_template": _to_jsonable(checks_by_template),
    }

    dump_baseline_artifacts(
        output_dir=dump_dir,
        analysis_result=analysis_result,
        foundry_code=foundry_code,
        foundry_supplement_code=None,
        prefix=dump_prefix
    )

    if return_analysis:
        return {
            "foundry_code": foundry_code,
            "foundry_supplement_code": "",
            "foundry_supplement": {
                "enabled": bool(inline_supplement_code),
                "base_test_stem": supplement_base_stem,
                "mode": "inline_appended_to_invariant_file" if inline_supplement_code else "not_generated",
            },
            "analysis": analysis_result,
        }

    return foundry_code

def gen_invariant_tests(
        contract_name, 
        source_path,
        source_code, 
        abi, 
        ast, 
        cfg, 
        solc_version: str,
        api_key: str,
        api_url: str = "https://api.openai.com/v1/chat/completions",
        model: str = "gpt-4.1",
        dump_dir: str = None,
        dump_prefix: str = "",
        return_analysis: bool = False,
        storage_layout: dict = None,
        solc_ir: str = None,
        solc_ir_optimized: str = None,
        legacy_assembly: dict = None,
        compiler_artifacts: dict = None,
    ):

    ir_result = build_contract_ir(
        contract_name=contract_name,
        source_path=source_path,
        source_code=source_code,
        abi=abi,
        ast=ast,
        cfg=cfg,
        solc_version=solc_version,
        storage_layout=storage_layout,
        solc_ir=solc_ir,
        solc_ir_optimized=solc_ir_optimized,
        legacy_assembly=legacy_assembly,
        compiler_artifacts=compiler_artifacts,
    )

    invariant_result = recover_invariants(
        contract_name=contract_name,
        source_path=source_path,
        cfg=cfg,
        solc_version=solc_version,
        ir_build_result=ir_result,
    )

    completed_result = complete_invariants_with_llm(
        source_code=source_code,
        api_key=api_key,
        api_url=api_url,
        model=model,
        invariant_result=invariant_result,
    )

    result = generate_foundry_invariant_tests(
        contract_name=contract_name,
        source_path=source_path,
        abi=abi,
        solc_version=solc_version,
        invariant_result=completed_result,
        dump_dir=dump_dir,
        dump_prefix=dump_prefix,
        return_analysis=return_analysis,
    )

    print("[InvariantGen] Done")
    return result
