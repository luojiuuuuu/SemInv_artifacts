# -*- coding: utf-8 -*-
import hashlib, json, os, re, shutil, subprocess, textwrap, tempfile
from pathlib import Path
from typing import Dict, Any, Optional, List, Tuple

from fuzzer.reporting import save_foundry_findings
from fuzzer.func_test.gen_foundry_tests import (
    _parse_solc_version,
    _read_source_package_declaration_text,
    _repair_target_call_argument_casts,
)


def _benchmark_source_package_root(source_path: Optional[str]) -> Optional[Path]:
    if not source_path:
        return None
    try:
        source = Path(source_path).resolve()
    except Exception:
        return None
    for parent in [source.parent, *source.parents]:
        if parent.parent.name in {"sources", "external_sources"} and parent.parent.parent.name == "seminv_benchmarks":
            return parent
    return None


def _foundry_remappings_for_package(package_root: Optional[Path]) -> List[str]:
    if not package_root:
        return []
    remappings: List[str] = []
    for scope_dir in sorted(package_root.glob("@*")):
        if scope_dir.is_dir():
            remappings.append(f"{scope_dir.name}/={scope_dir.name}/")
    node_modules = package_root / "node_modules"
    if node_modules.exists():
        for scope_dir in sorted(node_modules.glob("@*")):
            if scope_dir.is_dir():
                remappings.append(f"{scope_dir.name}/=node_modules/{scope_dir.name}/")
    packages = package_root / "packages"
    if packages.exists():
        for package_dir in sorted(packages.iterdir()):
            if package_dir.is_dir():
                remappings.append(
                    f"@nomad-xyz/{package_dir.name}/=packages/{package_dir.name}/"
                )
    return remappings


def get_contract_meta_dir(project_root: str, contract: str) -> Path:
    meta_dir = Path(project_root) / f"{contract}_meta"
    meta_dir.mkdir(parents=True, exist_ok=True)
    return meta_dir


def get_test_meta_subdir(project_root: str, contract: str, test_kind: str) -> Path:
    """
    test_kind: functional / invariant
    """
    base_meta = get_contract_meta_dir(project_root, contract)

    if test_kind == "functional":
        subdir = base_meta / "functional_test"
    elif test_kind == "invariant":
        subdir = base_meta / "invariant_test"
    else:
        raise ValueError(f"unknown test_kind: {test_kind}")

    subdir.mkdir(parents=True, exist_ok=True)
    return subdir

# ---------------- 失败类型判定/摘要 ----------------
_ERROR_WORDS = re.compile(r"\b(error|compilation failed|panic|invalid opcode|stack too deep|linker error)\b", re.IGNORECASE)
_RAN_TESTS_SUMMARY = re.compile(r"^\s*Ran\s+\d+\s+tests?\s+for\s+test/.+?:", re.IGNORECASE | re.MULTILINE)

def _looks_like_test_run(diag_text: str) -> bool:
    """是否看上去是完整跑过测试（即有 'Ran N tests for test/xxx:...' 汇总行）"""
    return bool(_RAN_TESTS_SUMMARY.search(diag_text or ""))

def _classify_failure_mode(diag_text: str) -> str:
    """
    返回:
      - 'TEST_RUN' : 日志显示确实跑了测试（即便有失败）
      - 'ERROR'    : 更可能是编译/环境类错误（没跑到测试）
    """
    if _looks_like_test_run(diag_text):
        return "TEST_RUN"
    if _ERROR_WORDS.search(diag_text or ""):
        return "ERROR"
    # 回退：既不像测试汇总，也没明显 error 词，保守视作 ERROR（你也可改为 TEST_RUN）
    return "ERROR"

# # ---------------- 失败用例名与逐用例轨迹提取 ----------------
# _FAIL_LINE = re.compile(r"^\s*\[FAIL\]\s+(test_[A-Za-z0-9_]+)\b", re.MULTILINE)

# def _extract_failed_tests(foundry_json: Dict[str, Any], trace_text: str) -> List[str]:
#     """
#     优先从 JSON 里拿失败函数；若 JSON 缺失，再从 trace 文本的 [FAIL] 行提取。
#     兼容套件结构与 Success/Failure。
#     """
#     failed = []
#     suite_name, suite_obj = _unwrap_foundry_suite(foundry_json)
#     test_results = (suite_obj or {}).get("test_results") or {}
#     for name, info in test_results.items():
#         if not isinstance(info, dict):
#             continue
#         if _normalize_status(info.get("status")) == "fail":
#             failed.append(name)

#     if not failed:
#         failed = list(dict.fromkeys(m.group(1) for m in _FAIL_LINE.finditer(trace_text or "")))
#     return failed

# def _extract_traces_for_failed_tests(trace_text: str, failed_tests: List[str]) -> Dict[str, str]:
#     """
#     尝试按失败函数名切分 trace 片段：
#       以 “[FAIL] test_xxx” 行作为开始，直到下一个 “[PASS]/[FAIL] test_...” 或 “Ran N tests ...” 或 EOF。
#     """
#     lines = (trace_text or "").splitlines()
#     idxs = []
#     pat_any_test = re.compile(r"^\s*\[(PASS|FAIL)\]\s+(test_[A-Za-z0-9_]+)\b")
#     # 定位每个失败用例起点
#     for i, ln in enumerate(lines):
#         m = _FAIL_LINE.match(ln)
#         if m and m.group(1) in failed_tests:
#             idxs.append((i, m.group(1)))
#     # 末尾补一个“终止哨兵”
#     end_pat = re.compile(r"^\s*Ran\s+\d+\s+tests?", re.IGNORECASE)
#     results: Dict[str,str] = {}
#     for k, (start_i, name) in enumerate(idxs):
#         end_i = len(lines)
#         for j in range(start_i+1, len(lines)):
#             if pat_any_test.match(lines[j]) or end_pat.match(lines[j]):
#                 end_i = j
#                 break
#         results[name] = "\n".join(lines[start_i:end_i]).rstrip() + "\n"
#     return results

# ---------------- 失败用例名与逐用例轨迹提取（支持多 suite） ----------------
_FAILING_SUITE_RE = re.compile(
    r"Encountered\s+\d+\s+failing\s+test[s]?\s+in\s+.*:(?P<suite>[A-Za-z_][A-Za-z0-9_]*)",
    re.IGNORECASE
)

# 情况 A：普通失败，测试名和 FAIL 在同一行
_FAILING_TEST_INLINE_RE = re.compile(
    r"^\s*\[FAIL(?::\s*(?P<reason>.*?))?\]\s+(?P<test>[A-Za-z_][A-Za-z0-9_]*)\(\)",
    re.IGNORECASE
)

# 情况 B：invariant replay failure，测试名单独在后续一行
_FAILING_TEST_NAME_ONLY_RE = re.compile(
    r"^\s*(?P<test>[A-Za-z_][A-Za-z0-9_]*)\(\)\s*(?:\(.*\))?\s*$",
    re.IGNORECASE
)

# 仅 FAIL 行，但同一行没有测试名
_FAILING_REASON_ONLY_RE = re.compile(
    r"^\s*\[FAIL(?::\s*(?P<reason>.*?))?\]\s*$",
    re.IGNORECASE
)

_FAILING_SEQ_LINE_RE = re.compile(
    r"sender=(?P<sender>\S+)\s+addr=(?P<addr>\S+)\s+calldata=(?P<calldata>\S+)\s+args=(?P<args>\[.*\])",
    re.IGNORECASE
)


def _parse_failing_tests_section(trace_text: str) -> List[Dict[str, Any]]:
    """
    从 forge -vvvv 输出最后的 'Failing tests:' 汇总区中解析失败项。
    同时兼容两种格式：

    1) 普通失败（单行）
       [FAIL: assertion failed: 1 != 0] test_xxx()

    2) invariant replay failure（两段式）
       [FAIL: invariant_xxx replay failure]
           [Sequence] ...
        invariant_xxx() (runs: 1, calls: 1, reverts: 1)
    """
    lines = (trace_text or "").splitlines()
    results: List[Dict[str, Any]] = []

    in_failing = False
    current_suite: Optional[str] = None
    pending_reason: Optional[str] = None
    current_item: Optional[Dict[str, Any]] = None

    for line in lines:
        s = line.rstrip()

        if s.strip() == "Failing tests:":
            in_failing = True
            continue

        if not in_failing:
            continue

        # 新 suite
        m_suite = _FAILING_SUITE_RE.search(s)
        if m_suite:
            current_suite = m_suite.group("suite")
            pending_reason = None
            current_item = None
            continue

        # 情况 A：FAIL + test_name 同行
        m_inline = _FAILING_TEST_INLINE_RE.search(s.strip())
        if m_inline and current_suite:
            current_item = {
                "suite": current_suite,
                "test_name": m_inline.group("test"),
                "reason": (m_inline.group("reason") or "").strip(),
                "sequence": [],
                "raw_lines": [s],
            }
            results.append(current_item)
            pending_reason = None
            continue

        # 情况 B-1：只有 FAIL reason，没有 test_name
        m_reason = _FAILING_REASON_ONLY_RE.search(s.strip())
        if m_reason and current_suite:
            pending_reason = (m_reason.group("reason") or "").strip()
            current_item = None
            continue

        # 情况 B-2：后续单独一行出现 test_name()
        m_name_only = _FAILING_TEST_NAME_ONLY_RE.search(s.strip())
        if m_name_only and current_suite and pending_reason is not None:
            current_item = {
                "suite": current_suite,
                "test_name": m_name_only.group("test"),
                "reason": pending_reason,
                "sequence": [],
                "raw_lines": [s],
            }
            results.append(current_item)
            pending_reason = None
            continue

        # 收集当前失败项的附加信息（Sequence / raw lines）
        if current_item is not None:
            current_item["raw_lines"].append(s)

            m_seq = _FAILING_SEQ_LINE_RE.search(s.strip())
            if m_seq:
                current_item["sequence"].append({
                    "sender": m_seq.group("sender"),
                    "addr": m_seq.group("addr"),
                    "calldata": m_seq.group("calldata"),
                    "args": m_seq.group("args"),
                })

    return results


def _extract_failed_tests(foundry_json: Dict[str, Any], trace_text: str) -> List[Dict[str, Any]]:
    """
    优先从 trace 的 'Failing tests:' 汇总区提取 suite+test+reason+sequence。
    若没提取到，再退化到 JSON。
    """
    parsed = _parse_failing_tests_section(trace_text)
    if parsed:
        return parsed

    out: List[Dict[str, Any]] = []

    if not isinstance(foundry_json, dict):
        return out

    # 兼容多 suite 顶层结构
    if "test_results" in foundry_json:
        suite_name = foundry_json.get("suite") or foundry_json.get("contract_name") or "unknown_suite"
        test_results = foundry_json.get("test_results") or {}
        for name, info in test_results.items():
            if not isinstance(info, dict):
                continue
            if _normalize_status(info.get("status")) == "fail":
                out.append({
                    "suite": str(suite_name),
                    "test_name": name,
                    "reason": info.get("reason") or info.get("failure_reason") or info.get("error") or "",
                    "sequence": [],
                    "raw_lines": [],
                })
        return out

    for suite_name, suite_obj in foundry_json.items():
        if not isinstance(suite_obj, dict):
            continue
        test_results = suite_obj.get("test_results") or {}
        for name, info in test_results.items():
            if not isinstance(info, dict):
                continue
            if _normalize_status(info.get("status")) == "fail":
                out.append({
                    "suite": str(suite_name),
                    "test_name": name,
                    "reason": info.get("reason") or info.get("failure_reason") or info.get("error") or "",
                    "sequence": [],
                    "raw_lines": [],
                })

    return out


def _rerun_single_failed_test_trace(
    forge: str,
    iso_root: Path,
    match_path: str,
    suite_name: str,
    test_name: str,
    profile: Optional[str] = None
) -> str:
    """
    对单个失败项重新执行 forge test，只保留该 suite + test 的 trace。
    """
    cmd: List[str] = [
        forge, "test",
        "--match-path", match_path,
        "--match-contract", suite_name,
        "--match-test", test_name,
        "-vvvv"
    ]
    if profile:
        cmd = [
            forge, "test", "-p", profile,
            "--match-path", match_path,
            "--match-contract", suite_name,
            "--match-test", test_name,
            "-vvvv"
        ]

    p = subprocess.Popen(
        cmd,
        cwd=str(iso_root),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    out, err = p.communicate()

    txt = (out or b"").decode("utf-8", errors="ignore")
    if not txt.strip():
        txt = (err or b"").decode("utf-8", errors="ignore")
    return txt

# ---------------- forge 定位 & 路径 ----------------
def _which_forge(explicit: Optional[str] = None) -> str:
    if explicit and Path(explicit).exists():
        return str(Path(explicit))
    env_bin = os.getenv("FORGE_BIN")
    if env_bin and Path(env_bin).exists():
        return env_bin
    found = shutil.which("forge")
    if found:
        return found
    home = Path.home()
    for c in [home/".foundry"/"bin"/"forge.exe", home/".foundry"/"bin"/"forge"]:
        if c.exists():
            return str(c)
    raise FileNotFoundError("未找到 forge，可设置 FORGE_BIN 或把 forge 加入 PATH。")

# ---------------- 解析高层轨迹：emit 事件 / Revert ----------------
# 形如： "├─ emit Transfer(...)" 或 "│   ├─ emit Approval(...)"，大小写可能不同
_EVT_LINE = re.compile(r"\bemit\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.IGNORECASE)
# 高层输出里通常没有 opcode 级 SSTORE/CALL；revert 可用关键字兜底
_REVERT_FUZZY = re.compile(r"\b(Revert|revert|REVERT|panic|invalid opcode)\b")

def _parse_highlevel_trace(trace_text: str) -> Dict[str, Any]:
    events = []
    for line in trace_text.splitlines():
        m = _EVT_LINE.search(line)
        if m:
            events.append(m.group(1))
    reverts = bool(_REVERT_FUZZY.search(trace_text))
    return {
        "event_names": list(dict.fromkeys(events)),  # 去重保序
        "reverts": reverts
    }

# ---------------- 把事件名映射到 topic0（尽力而为） ----------------
def _compute_topic0s_from_names(event_names: List[str], abi: List[dict]) -> List[str]:
    """
    根据 ABI 将事件名映射到 topic0。仅用名字匹配（如果一个名字多重载，则取第一个）。
    如果缺少 keccak_256（pysha3/eth_utils），则返回事件名字符串，避免为空。
    """
    # 先收集 ABI 里的事件签名
    name_to_sigs: Dict[str, List[str]] = {}
    for it in abi or []:
        if it.get("type") == "event":
            name = it.get("name")
            args = ",".join(inp.get("type","") for inp in it.get("inputs", []))
            sig = f"{name}({args})"
            name_to_sigs.setdefault(name, []).append(sig)

    topics: List[str] = []
    # 尝试 keccak_256
    keccak_fn = None
    try:
        # 优先 eth_utils
        from eth_utils import keccak as _keccak_bytes
        keccak_fn = lambda s: _keccak_bytes(text=s).hex()
    except Exception:
        try:
            # 次选 pysha3 提供的 keccak_256
            import hashlib
            keccak_fn = lambda s: hashlib.new("keccak256", s.encode("utf-8")).hexdigest()
        except Exception:
            keccak_fn = None

    for name in event_names:
        sigs = name_to_sigs.get(name, [])
        if sigs and keccak_fn:
            topic0 = "0x" + keccak_fn(sigs[0])
            topics.append(topic0)
        else:
            # 退化：保留事件名，避免 events 为空
            topics.append(name)
    return topics

def _unwrap_foundry_suite(foundry_json: Dict[str, Any]) -> Tuple[Optional[str], Dict[str, Any]]:
    """
    兼容两种结构：
    A) 扁平: {"test_results": {...}, "warnings": []}
    B) 套件: {"suite_name:ContractTest": {"test_results": {...}, "warnings": []}}
    返回: (suite_name | None, suite_dict)
    """
    if not isinstance(foundry_json, dict):
        return None, {}

    if "test_results" in foundry_json:
        # 扁平
        return None, foundry_json

    # 套件式：通常只有一个键
    for k, v in foundry_json.items():
        if isinstance(v, dict) and "test_results" in v:
            return k, v

    # 不符合预期
    return None, {}

def _normalize_status(status: Optional[str]) -> str:
    """
    将 Foundry 的 "Success"/"Failure"、"Pass"/"Fail" 等统一为 "pass"/"fail"
    """
    s = (status or "").strip().lower()
    if s.startswith("succ") or s == "pass" or s == "passed":
        return "pass"
    if s.startswith("fail") or s == "failed":
        return "fail"
    # 兜底：未知一律当作 fail 更保守
    return "fail"

# ---------------- 组合最小覆盖签名 ----------------
def minimal_coverage_signature(foundry_json: Dict[str, Any], trace_text: str, abi: Optional[List[dict]] = None) -> Dict[str, Any]:
    """
    覆盖签名：在原有 events/reverts 的基础上，补充：
      - pass/fail 计数、失败函数名（兼容套件结构 + Success/Failure）
      - 粗略提取的被调用函数名（从高层 trace）
      - 模糊提取的 revert 片段（若能找到）
    """
    base = {
        "events": [],
        "reverts": False,
        "edge_bloom": "0x0",
        "edge_hash": "0x0",
        "sstore_slots": [],
        "ext_calls": [],
        "risk_flags": [],
        "tests": {
            "suite": None,
            "total": 0,
            "pass": 0,
            "fail": 0,
            "failed_tests": []
        },
        "calls": []
    }

    # ---- 兼容“套件层”结构 ----
    suite_name, suite_obj = _unwrap_foundry_suite(foundry_json)
    base["tests"]["suite"] = suite_name
    test_results = (suite_obj or {}).get("test_results") or {}

    # ---- 统计 pass/fail 与失败列表 ----
    for name, info in test_results.items():
        if not isinstance(info, dict):
            continue
        st = _normalize_status(info.get("status"))
        if st == "pass":
            base["tests"]["pass"] += 1
        else:
            base["tests"]["fail"] += 1
            base["tests"]["failed_tests"].append(name)
    base["tests"]["total"] = base["tests"]["pass"] + base["tests"]["fail"]

    if base["tests"]["failed_tests"]:
        base["reverts"] = True  # 有失败时保守记为可能含 revert

    # ---- 解析高层轨迹：事件名 + revert 线索 ----
    parsed = _parse_highlevel_trace(trace_text or "")
    base["reverts"] = base["reverts"] or parsed.get("reverts", False)

    # ---- 事件名 → topic0（尽力而为） ----
    event_topics = _compute_topic0s_from_names(parsed.get("event_names", []), abi or [])
    base["events"] = event_topics

    # ---- 粗略提取被调用函数名 / 外部调用 ----
    call_pat = re.compile(r"\bcall\b[^\n]*?\b([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.IGNORECASE)
    calls = list(dict.fromkeys(m.group(1) for m in call_pat.finditer(trace_text or "")))
    base["calls"] = calls
    base["ext_calls"] = calls

    # ---- 模糊提取 revert 片段（若存在，把含关键字的行收集做提示）----
    if base["reverts"]:
        rev_lines = []
        for ln in (trace_text or "").splitlines():
            if _REVERT_FUZZY.search(ln):
                rev_lines.append(ln.strip())
        if rev_lines:
            base["risk_flags"].append("revert_lines_present")

    return base

# def write_signature(project_root: str, testfile_path: str, sig: Dict[str, Any]) -> str:
#     """
#     将 coverage signature 写入独立的 {test_name}_meta/coverage_global.json
#     - project_root: 项目根目录
#     - testfile_path: 当前测试文件路径（用来生成 test_name）
#     - sig: 收集到的覆盖率信息
#     返回: 写入的文件路径（str）
#     """
#     pr = Path(project_root).resolve()
#     test_name = str(Path(testfile_path).stem).split('_')[0]  # 例如 keepMyEther_Functional.t.sol → keepMyEther_Functional
#     meta_dir = pr / f"{test_name}_meta"
#     meta_dir.mkdir(exist_ok=True)

#     outp = meta_dir / "coverage_global.json"
#     outp.write_text(json.dumps(sig, indent=2), encoding="utf-8")
#     return str(outp)

def write_signature(meta_dir: Path, sig: Dict[str, Any]) -> str:
    outp = meta_dir / "coverage_global.json"
    outp.write_text(json.dumps(sig, indent=2, ensure_ascii=False), encoding="utf-8")
    return str(outp)


# =========================================================
# Failure explanation / reproduction helpers
# =========================================================

_HANDLER_CALL_RE = re.compile(r"\bhandler\.(call_[A-Za-z0-9_]+)\s*\(")
_TARGET_CALL_RE = re.compile(r"\btarget\.([A-Za-z_][A-Za-z0-9_]*)\s*\(")
_VM_PRANK_RE = re.compile(r"\b(startPrank|prank)\b", re.IGNORECASE)
_ASSERT_RE = re.compile(r"\b(assertTrue|assertEq|_assertTrue|_assertEq)\b")
_EVENT_LINE_RE = re.compile(r"\bemit\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.IGNORECASE)
_REACHABILITY_LINE_RE = re.compile(
    r"emit\s+SemInvReachability\s*\(\s*attempted:\s*(?P<attempted>\d+),\s*successful:\s*(?P<successful>\d+),\s*reverted:\s*(?P<reverted>\d+)\s*\)",
    re.IGNORECASE,
)


def _is_observability_test_name(*names: str) -> bool:
    low = " ".join(str(name or "") for name in names).lower()
    compact = re.sub(r"[^a-z0-9]+", "", low)
    return (
        "semantic_reachability_report" in low
        or "reachability_report" in low
        or "semanticreachabilityreport" in compact
        or "reachabilityreport" in compact
    )


def _extract_reachability_report(trace_text: str) -> Dict[str, Any]:
    events: List[Dict[str, int]] = []
    for match in _REACHABILITY_LINE_RE.finditer(trace_text or ""):
        events.append(
            {
                "attempted": int(match.group("attempted")),
                "successful": int(match.group("successful")),
                "reverted": int(match.group("reverted")),
            }
        )
    max_attempted = max((item["attempted"] for item in events), default=0)
    max_successful = max((item["successful"] for item in events), default=0)
    max_reverted = max((item["reverted"] for item in events), default=0)
    return {
        "event_count": len(events),
        "max_attempted": max_attempted,
        "max_successful": max_successful,
        "max_reverted": max_reverted,
        "had_successful_call": max_successful > 0,
        "all_observed_calls_reverted": bool(max_attempted > 0 and max_successful == 0),
        "events": events[:20],
    }
_REVERT_LINE_RE = re.compile(r"\b(Revert|revert|panic|invalid opcode|Error\(|Panic\()", re.IGNORECASE)
_STATUS_PASS_RE = re.compile(r"^(ok|pass|passed|success)$", re.IGNORECASE)
_TRACE_HANDLER_CALL_RE = re.compile(
    r"\]\s+(?P<handler>[A-Za-z_][A-Za-z0-9_]*Handler)(?::\s*\[(?P<addr>0x[0-9A-Fa-f]{40})\])?::"
    r"(?P<call>call_[A-Za-z0-9_]+)\((?P<args>.*)\)"
)


def _safe_filename(name: str) -> str:
    s = str(name or "").strip()
    if not s:
        return "unknown"
    return re.sub(r'[^A-Za-z0-9_.-]+', "_", s)


def _extract_path_clues_from_trace(single_trace: str) -> Dict[str, Any]:
    """
    从单个失败 trace 提取“可复现路径线索”：
    - handler 调用链
    - target 调用
    - emit 事件
    - revert
    - assert
    """
    handler_calls: List[str] = []
    target_calls: List[str] = []
    events: List[str] = []
    revert_lines: List[str] = []
    assert_lines: List[str] = []
    key_path_lines: List[str] = []

    for line in single_trace.splitlines():
        s = line.rstrip()

        m1 = _HANDLER_CALL_RE.search(s)
        if m1:
            handler_calls.append(m1.group(1))
            key_path_lines.append(s)

        m2 = _TARGET_CALL_RE.search(s)
        if m2:
            target_calls.append(m2.group(1))
            key_path_lines.append(s)

        m3 = _EVENT_LINE_RE.search(s)
        if m3:
            events.append(m3.group(1))
            key_path_lines.append(s)

        if _REVERT_LINE_RE.search(s):
            revert_lines.append(s)
            key_path_lines.append(s)

        if _ASSERT_RE.search(s):
            assert_lines.append(s)
            key_path_lines.append(s)

    return {
        "handler_calls": list(dict.fromkeys(handler_calls)),
        "target_calls": list(dict.fromkeys(target_calls)),
        "events": list(dict.fromkeys(events)),
        "revert_detected": bool(revert_lines),
        "revert_lines": revert_lines[:20],
        "assert_lines": assert_lines[:20],
        "key_path_lines": key_path_lines[:80],
    }


def _extract_replay_sequence_from_trace(single_trace: str) -> List[Dict[str, Any]]:
    """
    Recover a minimization-friendly handler call sequence from a single failing trace.
    Prefer Foundry's shrunk [Sequence] lines; fall back to explicit Handler::call_xxx(...)
    trace entries for directed tests that do not emit an invariant sequence.
    """
    sequence: List[Dict[str, Any]] = []
    seen_sequence = set()

    for line in (single_trace or "").splitlines():
        m_seq = _FAILING_SEQ_LINE_RE.search(line.strip())
        if m_seq:
            item = {
                "sender": m_seq.group("sender"),
                "addr": m_seq.group("addr"),
                "calldata": m_seq.group("calldata"),
                "args": m_seq.group("args"),
                "source": "foundry_sequence",
            }
            key = (item["sender"], item["addr"], item["calldata"], item["args"])
            if key in seen_sequence:
                continue
            seen_sequence.add(key)
            sequence.append(item)

    if sequence:
        return sequence

    seen = set()
    for line in (single_trace or "").splitlines():
        m_call = _TRACE_HANDLER_CALL_RE.search(line.strip())
        if not m_call:
            continue

        raw_args = (m_call.group("args") or "").strip()
        args_repr = "[]" if not raw_args else f"[{raw_args}]"
        addr = m_call.group("addr") or m_call.group("handler")
        item = {
            "sender": None,
            "addr": addr,
            "calldata": m_call.group("call"),
            "args": args_repr,
            "source": "trace_handler_call",
        }
        key = (item["addr"], item["calldata"], item["args"])
        if key in seen:
            continue
        seen.add(key)
        sequence.append(item)

    return sequence


def _infer_invariant_semantics_from_test_name(test_name: str) -> Dict[str, Any]:
    """
    利用你当前生成器的命名约定，把 failing test 映射回不变量语义。
    """
    name = str(test_name or "").strip()

    # modern invariant / property
    patterns = [
        (
            re.compile(r"^invariant_accounting_(\d+)$"),
            lambda m: {
                "family": "accounting",
                "kind": "sum_equals_supply",
                "summary": "Accounting invariant violated: sum(balances) != supply",
                "targets": {"index": int(m.group(1))}
            }
        ),
        (
            re.compile(r"^invariant_eth_conservation_(\d+)$"),
            lambda m: {
                "family": "accounting",
                "kind": "eth_conservation",
                "summary": "ETH conservation invariant violated: contract balance exceeds tracked sent ETH",
                "targets": {"index": int(m.group(1))}
            }
        ),
        (
            re.compile(r"^test_accounting_anomaly_(\d+)_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "accounting_anomaly",
                "kind": "targeted_function_postcheck",
                "summary": "Directed accounting post-check failed after calling suspicious function",
                "targets": {"index": int(m.group(1)), "function": m.group(2)}
            }
        ),
        (
            re.compile(r"^test_supplement_accounting_delta_(\d+)_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "accounting_anomaly",
                "kind": "supplement_accounting_delta",
                "summary": "Supplemental accounting delta check failed after calling suspicious function",
                "targets": {"index": int(m.group(1)), "function": m.group(2), "invariant_id": "I1.accounting.delta_consistency"}
            }
        ),
        (
            re.compile(r"^test_supplement_accounting_delta_mismatch_(\d+)_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "accounting_anomaly",
                "kind": "supplement_accounting_delta_mismatch",
                "summary": "Supplemental accounting delta mismatch check failed after precision-sensitive function",
                "targets": {"index": int(m.group(1)), "function": m.group(2), "invariant_id": "I1.accounting.delta_consistency"}
            }
        ),
        (
            re.compile(r"^test_supplement_swap_rounding_drift_positive_output$"),
            lambda m: {
                "family": "accounting_anomaly",
                "kind": "supplement_precision_loss_rounding_drift",
                "summary": "Supplemental precision-loss check failed: positive swap input rounded to zero output while state changed",
                "targets": {"function": "swap", "invariant_id": "I1.accounting.delta_consistency"}
            }
        ),
        (
            re.compile(r"^(?:invariant|test)_supplement_accounting_sum_(\d+)$"),
            lambda m: {
                "family": "accounting",
                "kind": "supplement_sum_leq_supply",
                "summary": "Supplemental accounting sum/supply invariant violated",
                "targets": {"index": int(m.group(1)), "invariant_id": "I1.accounting.sum_supply_consistency"}
            }
        ),
        (
            re.compile(r"^test_supplement_eth_balance_bound_(\d+)_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "accounting",
                "kind": "supplement_eth_balance_bound",
                "summary": "Supplemental ETH balance/storage consistency property violated",
                "targets": {"index": int(m.group(1)), "state_var": m.group(2), "invariant_id": "I1.accounting.eth_balance_consistency"}
            }
        ),
        (
            re.compile(r"^test_supplement_receive_no_retained_eth$"),
            lambda m: {
                "family": "transaction",
                "kind": "supplement_receive_no_retained_eth",
                "summary": "Supplemental receive-path ETH non-retention property violated",
                "targets": {"invariant_id": "I4.transaction.receive_no_retained_eth"}
            }
        ),
        (
            re.compile(r"^test_supplement_access_noninterference_(\d+)_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "access",
                "kind": "supplement_access_noninterference",
                "summary": "Supplemental unauthorized non-interference property violated",
                "targets": {"index": int(m.group(1)), "function": m.group(2), "invariant_id": "I2.authorization.access_noninterference"}
            }
        ),
        (
            re.compile(r"^invariant_bool_domain_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "state",
                "kind": "bool_domain",
                "summary": "Boolean state domain invariant violated",
                "targets": {"state_var": m.group(1)}
            }
        ),
        (
            re.compile(r"^invariant_([A-Za-z0-9_]+)_true_terminal_no_rollback$"),
            lambda m: {
                "family": "state",
                "kind": "terminal_no_rollback",
                "summary": "Terminal state rollback violated after entering true terminal state",
                "targets": {"state_var": m.group(1), "terminal_value": "true"}
            }
        ),
        (
            re.compile(r"^invariant_([A-Za-z0-9_]+)_false_terminal_no_rollback$"),
            lambda m: {
                "family": "state",
                "kind": "terminal_no_rollback",
                "summary": "Terminal state rollback violated after entering false terminal state",
                "targets": {"state_var": m.group(1), "terminal_value": "false"}
            }
        ),
        (
            re.compile(r"^invariant_([A-Za-z0-9_]+)_monotonic_uint$"),
            lambda m: {
                "family": "state",
                "kind": "monotonic_uint",
                "summary": "Monotonic uint state invariant violated",
                "targets": {"state_var": m.group(1)}
            }
        ),
        (
            re.compile(r"^invariant_([A-Za-z0-9_]+)_no_rollback_after_terminal$"),
            lambda m: {
                "family": "state",
                "kind": "terminal_no_rollback",
                "summary": "No-rollback-after-terminal invariant violated",
                "targets": {"state_var": m.group(1)}
            }
        ),
        (
            re.compile(r"^(?:invariant|test)_supplement_([A-Za-z0-9_]+)_terminal_absorbing$"),
            lambda m: {
                "family": "state",
                "kind": "supplement_terminal_absorbing",
                "summary": "Supplemental terminal absorbing invariant violated",
                "targets": {"state_var": m.group(1), "invariant_id": "I3.state.terminal_absorbing"}
            }
        ),
        (
            re.compile(r"^invariant_state_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "state",
                "kind": "state_domain",
                "summary": "State domain invariant violated",
                "targets": {"state_var": m.group(1)}
            }
        ),
        (
            re.compile(r"^test_property_transition_([A-Za-z0-9_]+)_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "transition",
                "kind": "state_transition_property",
                "summary": "State transition property violated",
                "targets": {"state_var": m.group(1), "function": m.group(2)}
            }
        ),
        (
            re.compile(r"^test_llm_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "llm_candidate",
                "kind": "llm_generated_transition_or_property",
                "summary": "LLM-generated candidate property violated",
                "targets": {"candidate_name": m.group(1)}
            }
        ),
        (
            re.compile(r"^invariant_access_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "access",
                "kind": "unauthorized_call_must_fail",
                "summary": "Access control invariant violated: unauthorized call unexpectedly succeeded",
                "targets": {"function": m.group(1)}
            }
        ),
        (
            re.compile(r"^invariant_cross_([A-Za-z0-9_]+)_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "cross_function",
                "kind": "cross_function_relation",
                "summary": "Cross-function invariant violated",
                "targets": {"from_function": m.group(1), "to_function": m.group(2)}
            }
        ),
        (
            re.compile(r"^invariant_supplement_cross_([A-Za-z0-9_]+)_([A-Za-z0-9_]+)_(\d+)$"),
            lambda m: {
                "family": "cross_function",
                "kind": "supplement_write_read_consistency",
                "summary": "Supplemental cross-function write-read invariant violated",
                "targets": {"from_function": m.group(1), "to_function": m.group(2), "index": int(m.group(3)), "invariant_id": "I4.transaction.write_read_consistency"}
            }
        ),
        (
            re.compile(r"^invariant_supply_bound$"),
            lambda m: {
                "family": "system",
                "kind": "supply_bound",
                "summary": "System supply bound violated",
                "targets": {}
            }
        ),
        (
            re.compile(r"^invariant_handler_actor_present$"),
            lambda m: {
                "family": "system",
                "kind": "handler_actor_presence",
                "summary": "Handler actor presence invariant violated",
                "targets": {}
            }
        ),
        (
            re.compile(r"^invariant_can_execute_harness$"),
            lambda m: {
                "family": "system",
                "kind": "harness_sanity",
                "summary": "Harness sanity invariant violated",
                "targets": {}
            }
        ),

        # mid_legacy / legacy property names
        (
            re.compile(r"^test_property_accounting_(\d+)$"),
            lambda m: {
                "family": "accounting",
                "kind": "sum_leq_supply_legacy",
                "summary": "Legacy accounting property violated",
                "targets": {"index": int(m.group(1))}
            }
        ),
        (
            re.compile(r"^test_property_eth_conservation_(\d+)$"),
            lambda m: {
                "family": "accounting",
                "kind": "eth_conservation",
                "summary": "ETH conservation property violated",
                "targets": {"index": int(m.group(1))}
            }
        ),
        (
            re.compile(r"^test_property_access_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "access",
                "kind": "unauthorized_call_must_fail",
                "summary": "Access control property violated",
                "targets": {"function": m.group(1)}
            }
        ),
        (
            re.compile(r"^test_property_state_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "state",
                "kind": "state_domain",
                "summary": "State property violated",
                "targets": {"state_var": m.group(1)}
            }
        ),
        (
            re.compile(r"^test_transition_fn_([A-Za-z0-9_]+)_([A-Za-z0-9_]+)$"),
            lambda m: {
                "family": "transition",
                "kind": "state_transition_property",
                "summary": "Legacy state transition property violated",
                "targets": {"state_var": m.group(1), "function": m.group(2)}
            }
        ),
        (
            re.compile(r"^test_property_handler_present$"),
            lambda m: {
                "family": "system",
                "kind": "handler_actor_presence",
                "summary": "Handler presence property violated",
                "targets": {}
            }
        ),
        (
            re.compile(r"^test_property_contract_balance_bound$"),
            lambda m: {
                "family": "system",
                "kind": "contract_balance_bound",
                "summary": "Contract balance bound property violated",
                "targets": {}
            }
        ),
    ]

    for rx, builder in patterns:
        m = rx.match(name)
        if m:
            return builder(m)

    return {
        "family": "unknown",
        "kind": "unknown",
        "summary": "Failed test could not be mapped to a known invariant template",
        "targets": {}
    }

def _build_reproduce_command(
    forge: str,
    iso_root: Path,
    match_path: str,
    suite_name: str,
    test_name: str,
    profile: Optional[str] = None
) -> str:
    cmd = [forge, "test"]
    if profile:
        cmd += ["-p", profile]
    cmd += [
        "--match-path", match_path,
        "--match-contract", suite_name,
        "--match-test", test_name,
        "-vvvv"
    ]
    return " ".join(cmd)


def _build_failure_case_record(
    fail_item: Dict[str, Any],
    single_trace: str,
    forge: str,
    iso_root: Path,
    match_path: str,
    profile: Optional[str]
) -> Dict[str, Any]:
    test_name = fail_item["test_name"]
    suite_name = fail_item.get("suite", "unknown_suite")
    semantics = _infer_invariant_semantics_from_test_name(test_name)
    trace_summary = _extract_path_clues_from_trace(single_trace)
    highlevel = _parse_highlevel_trace(single_trace) if single_trace else {"event_names": [], "reverts": False}
    replay_sequence = fail_item.get("sequence", []) or _extract_replay_sequence_from_trace(single_trace)

    return {
        "suite": suite_name,
        "test_name": test_name,
        "status": fail_item.get("status", "fail"),
        "failure_reason": fail_item.get("reason") or "",
        "invariant_family": semantics["family"],
        "invariant_kind": semantics["kind"],
        "summary": semantics["summary"],
        "targets": semantics["targets"],
        "reproduce_command": _build_reproduce_command(
            forge=forge,
            iso_root=iso_root,
            match_path=match_path,
            suite_name=suite_name,
            test_name=test_name,
            profile=profile,
        ),
        "replay_sequence": replay_sequence,
        "raw_failure_lines": fail_item.get("raw_lines", []),
        "trace_summary": {
            "handler_calls": trace_summary["handler_calls"],
            "target_calls": trace_summary["target_calls"],
            "events": highlevel.get("event_names") or trace_summary["events"],
            "revert_detected": highlevel.get("reverts") or trace_summary["revert_detected"],
            "revert_lines": trace_summary["revert_lines"],
            "assert_lines": trace_summary["assert_lines"],
            "key_path_lines": trace_summary["key_path_lines"],
        },
        "counterexample": fail_item.get("counterexample"),
        "logs": fail_item.get("logs"),
    }


def _render_failure_report_txt(report: Dict[str, Any]) -> str:
    lines: List[str] = []

    lines.append("=== Foundry Failing Tests Report ===")
    suite_val = report.get("suite")
    if isinstance(suite_val, list):
        lines.append(f"Suite: {', '.join(suite_val)}")
    else:
        lines.append(f"Suite: {suite_val}")
    lines.append(f"Total failed: {report.get('fail_count', 0)}")
    lines.append("")

    for i, item in enumerate(report.get("failures", []), 1):
        lines.append(f"[{i}] {item.get('suite', 'unknown_suite')}::{item['test_name']}")
        lines.append(f"  - Invariant family : {item['invariant_family']}")
        lines.append(f"  - Invariant kind   : {item['invariant_kind']}")
        lines.append(f"  - Summary          : {item['summary']}")
        lines.append(f"  - Targets          : {json.dumps(item.get('targets', {}), ensure_ascii=False)}")

        reason = (item.get("failure_reason") or "").strip()
        if reason:
            lines.append(f"  - Failure reason   : {reason}")

        lines.append(f"  - Reproduce        : {item['reproduce_command']}")

        ts = item.get("trace_summary", {})
        if ts.get("handler_calls"):
            lines.append(f"  - Handler calls    : {' -> '.join(ts['handler_calls'])}")
        if ts.get("target_calls"):
            lines.append(f"  - Target calls     : {' -> '.join(ts['target_calls'])}")
        if ts.get("events"):
            lines.append(f"  - Events           : {', '.join(ts['events'])}")
        lines.append(f"  - Revert detected  : {bool(ts.get('revert_detected'))}")

        if ts.get("revert_lines"):
            lines.append("  - Revert lines:")
            for x in ts["revert_lines"][:8]:
                lines.append(f"      {x}")

        if ts.get("key_path_lines"):
            lines.append("  - Key path:")
            for x in ts["key_path_lines"][:12]:
                lines.append(f"      {x}")

        replay_seq = item.get("replay_sequence", [])
        if replay_seq:
            lines.append("  - Replay sequence:")
            for step_idx, step in enumerate(replay_seq, 1):
                lines.append(
                    f"      [{step_idx}] sender={step.get('sender')} "
                    f"calldata={step.get('calldata')} args={step.get('args')}"
                )

        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def _print_failure_report_to_console(report: Dict[str, Any]) -> None:
    fail_count = report.get("fail_count", 0)
    if fail_count == 0:
        print("[FoundryFailReport] no failing tests")
        return

    print("=" * 80)
    print(f"[FoundryFailReport] suite={report.get('suite')} fail_count={fail_count}")
    for item in report.get("failures", []):
        print("-" * 80)
        print(f"test: {item.get('suite', 'unknown_suite')}::{item['test_name']}")
        print(f"type: {item['invariant_family']} / {item['invariant_kind']}")
        print(f"summary: {item['summary']}")
        if item.get("targets"):
            print(f"targets: {item['targets']}")
        if item.get("failure_reason"):
            print(f"reason: {item['failure_reason']}")
        print(f"reproduce: {item['reproduce_command']}")

        ts = item.get("trace_summary", {})
        if ts.get("handler_calls"):
            print(f"path(handler): {' -> '.join(ts['handler_calls'])}")
        if ts.get("target_calls"):
            print(f"path(target): {' -> '.join(ts['target_calls'])}")
        if ts.get("events"):
            print(f"events: {', '.join(ts['events'])}")
        print(f"revert: {bool(ts.get('revert_detected'))}")

        replay_seq = item.get("replay_sequence", [])
        if replay_seq:
            print("replay sequence:")
            for idx, step in enumerate(replay_seq, 1):
                print(f"  [{idx}] sender={step.get('sender')} calldata={step.get('calldata')} args={step.get('args')}")
    print("=" * 80)


def build_failing_tests_report(
    data: Dict[str, Any],
    trace_text: str,
    forge: str,
    iso_root: Path,
    match_path: str,
    profile: Optional[str] = None,
) -> Dict[str, Any]:
    failed_items = _extract_failed_tests(data, trace_text)

    failures: List[Dict[str, Any]] = []
    suite_names = []

    for item in failed_items:
        suite_name = item.get("suite", "unknown_suite")
        test_name = item.get("test_name")
        suite_names.append(suite_name)

        # 对每个失败测试单独 rerun，保证 trace 不串 suite
        single_trace = _rerun_single_failed_test_trace(
            forge=forge,
            iso_root=iso_root,
            match_path=match_path,
            suite_name=suite_name,
            test_name=test_name,
            profile=profile,
        )

        failures.append(
            _build_failure_case_record(
                fail_item=item,
                single_trace=single_trace,
                forge=forge,
                iso_root=iso_root,
                match_path=match_path,
                profile=profile,
            )
        )

    return {
        "suite": sorted(list(dict.fromkeys(suite_names))),
        "fail_count": len(failures),
        "failures": failures,
    }


def save_failing_tests_report(
    meta_dir: Path,
    report: Dict[str, Any],
    *,
    source_path: Optional[str] = None,
    contract_name: Optional[str] = None,
    validate_minimization: Optional[bool] = None,
    minimization_timeout: Optional[int] = None,
) -> None:
    meta_dir.mkdir(exist_ok=True, parents=True)

    (meta_dir / "failure_report.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )
    (meta_dir / "failure_report.txt").write_text(
        _render_failure_report_txt(report),
        encoding="utf-8"
    )

    detailed_dir = meta_dir / "failure_cases"
    detailed_dir.mkdir(exist_ok=True)

    for item in report.get("failures", []):
        suite_name = item.get("suite", "unknown_suite")
        fname = _safe_filename(f"{suite_name}__{item['test_name']}")
        (detailed_dir / f"{fname}.json").write_text(
            json.dumps(item, indent=2, ensure_ascii=False),
            encoding="utf-8"
        )

# ---------------- 运行：一次拿 JSON，一次拿文本轨迹 ---------------- 
    try:
        save_foundry_findings(
            meta_dir,
            report,
            source_path=source_path,
            contract_name=contract_name,
            validate_minimization=validate_minimization,
            minimization_timeout=minimization_timeout,
        )
    except Exception:
        pass

def run_foundry_tests(project_root: str,
                      contract_name: str,
                      testfile_path: str,
                      forge_path: Optional[str] = None,
                      profile: Optional[str] = None,
                      is_invariant_test: bool = False,
                      test_kind: str = "functional",
                      source_path: Optional[str] = None,
                      artifact_name: Optional[str] = None,
                      validate_minimization: Optional[bool] = None,
                      minimization_timeout: Optional[int] = None,
                      solc_version: Optional[str] = None,
                      evm_version: Optional[str] = None) -> Tuple[Dict[str, Any], str]:
    """
    返回: (json_result, trace_text)
    第一次: --json（结构化结果）
    若失败: 回退跑一次 -vv（非 JSON），把完整编译错误保存到 meta/compile_error.txt 并抛出带摘要的异常
    第二次: -vvvv（不带 --json），抓高层 Trace 文本（stdout）

    额外增强：
    - 在 project_root/.func_isolated/ 构建临时 Foundry 工程，仅包含：
        * test/<当前测试文件>
        * src/<测试文件中 import "../src/xxx.sol" 命中的源码（可多条）>
        * lib/（从原工程复制，确保 forge-std 等可用）
      这样可避免编译到无关合约。
    """
    forge = _which_forge(forge_path)
    # meta_dir = Path(project_root) / "meta"
    # meta_dir.mkdir(exist_ok=True)

    # 从测试文件名里提取测试合约名，例如 test/keepMyEther_Functional.t.sol → keepMyEther_Functional
    meta_dir = get_test_meta_subdir(project_root, artifact_name or contract_name, test_kind)

    # ---- 构建隔离工程 ----
    original_root = Path(project_root).resolve()
    test_abs = Path(testfile_path).resolve()
    if not test_abs.exists():
        # 兼容传入绝对/相对路径两种情况
        test_abs = (original_root / testfile_path).resolve()
    if not test_abs.exists():
        raise FileNotFoundError(f"测试文件不存在: {testfile_path}")

    iso_label = artifact_name or contract_name or test_abs.stem
    iso_suffix = hashlib.sha1(str(iso_label).encode("utf-8", errors="ignore")).hexdigest()[:12]
    if test_kind == "functional":
        iso_root = original_root / f".if_{iso_suffix}"
    elif test_kind == "invariant":
        iso_root = original_root / f".ii_{iso_suffix}"
    else:
        raise ValueError(f"unknown test_kind: {test_kind}")
    # 清理并重建
    if iso_root.exists():
        shutil.rmtree(iso_root)
    (iso_root / "src").mkdir(parents=True, exist_ok=True)
    (iso_root / "test").mkdir(parents=True, exist_ok=True)
    (iso_root / "lib").mkdir(parents=True, exist_ok=True)

    def _copy_sol_source_for_iso(src: Path, dst: Path) -> None:
        """Copy a Solidity source into the isolated project.

        Historical benchmark packages sometimes contain flattened verified
        sources with repeated SPDX headers.  Foundry treats that as a parser
        error in an isolated project.  Normalize only the transient copy: keep
        the first SPDX line and demote later SPDX markers to ordinary comments.
        This preserves contract semantics and leaves the original benchmark
        source untouched.
        """
        dst.parent.mkdir(parents=True, exist_ok=True)
        if src.suffix.lower() != ".sol":
            shutil.copy2(src, dst)
            return
        try:
            text = src.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            shutil.copy2(src, dst)
            return
        seen_spdx = False
        out: List[str] = []
        changed = False
        for line in text.splitlines():
            if re.match(r"^\s*//\s*SPDX-License-Identifier\s*:", line):
                if seen_spdx:
                    out.append(re.sub(r"SPDX-License-Identifier", "SPDX-License-Identifier-Removed", line, count=1))
                    changed = True
                    continue
                seen_spdx = True
            out.append(line)
        if changed:
            dst.write_text("\n".join(out) + ("\n" if text.endswith(("\n", "\r\n")) else ""), encoding="utf-8")
        else:
            shutil.copy2(src, dst)

    # 复制测试文件
    test_dst = (iso_root / "test" / test_abs.name)
    shutil.copy2(test_abs, test_dst)
    test_src = test_abs.read_text(encoding="utf-8", errors="ignore")
    if source_path:
        try:
            source_primary = Path(source_path).read_text(encoding="utf-8", errors="ignore")
            decl_text = _read_source_package_declaration_text(source_path, source_primary)
            version_tuple = _parse_solc_version(str(solc_version or ""))
            pre_08 = not (version_tuple[0] >= 1 or version_tuple[1] >= 8)
            repaired_test_src = _repair_target_call_argument_casts(
                test_src,
                decl_text,
                pre_08=pre_08,
                contract_name=contract_name,
            )
            if repaired_test_src != test_src:
                test_dst.write_text(repaired_test_src, encoding="utf-8")
                test_src = repaired_test_src
        except Exception:
            pass

    def _copy_relative_import_tree(src_file: Path, dst_file: Path, seen: Optional[set] = None) -> None:
        if seen is None:
            seen = set()
        try:
            src_file = src_file.resolve()
        except Exception:
            return
        if src_file in seen or not src_file.exists() or not src_file.is_file():
            return
        seen.add(src_file)
        try:
            text = src_file.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            return
        rel_import_re = re.compile(r'^\s*import\s+(?:\{[^;]*\}\s+from\s+)?["\'](\.{1,2}/[^"\']+\.sol)["\'];', re.IGNORECASE)
        for line in text.splitlines():
            match = rel_import_re.search(line)
            if not match:
                continue
            rel_import = match.group(1)
            dep_src = (src_file.parent / rel_import).resolve()
            dep_dst = (dst_file.parent / rel_import).resolve()
            try:
                dep_dst.relative_to(iso_root.resolve())
            except Exception:
                continue
            if dep_src.exists() and dep_src.is_file():
                dep_dst.parent.mkdir(parents=True, exist_ok=True)
                _copy_sol_source_for_iso(dep_src, dep_dst)
                _copy_relative_import_tree(dep_src, dep_dst, seen)

    # Do not recursively resolve the generated test file's ../src imports here:
    # that would read from the shared foundry/src directory, which may contain
    # dependencies from a previous benchmark target.  The explicit
    # imported_units loop below resolves those imports package-locally.
    if source_path:
        try:
            source_abs_for_imports = Path(source_path).resolve()
            _copy_relative_import_tree(source_abs_for_imports, iso_root / "src" / source_abs_for_imports.name)
        except Exception:
            pass
    package_root = _benchmark_source_package_root(source_path)
    package_remappings = _foundry_remappings_for_package(package_root)
    if package_root:
        for scope_dir in sorted(package_root.glob("@*")):
            if scope_dir.is_dir():
                shutil.copytree(scope_dir, iso_root / scope_dir.name, dirs_exist_ok=True)
        for name in ("node_modules", "packages"):
            package_child = package_root / name
            if package_child.exists():
                shutil.copytree(package_child, iso_root / name, dirs_exist_ok=True)
        for name in ("lib", "libs"):
            package_child = package_root / name
            if package_child.exists() and package_child.is_dir():
                shutil.copytree(package_child, iso_root / "lib", dirs_exist_ok=True)
        package_src_root = package_root / "src"
        if package_src_root.exists() and package_src_root.is_dir():
            for name in ("lib", "libs"):
                package_child = package_src_root / name
                if package_child.exists() and package_child.is_dir():
                    shutil.copytree(package_child, iso_root / "lib", dirs_exist_ok=True)
        contracts_root = package_root / "contracts"
        if contracts_root.exists() and contracts_root.is_dir():
            for child in sorted(contracts_root.iterdir()):
                if child.name in {"lib", "libs"} and child.is_dir():
                    shutil.copytree(child, iso_root / "lib", dirs_exist_ok=True)
                    continue
                dst = iso_root / "src" / child.name
                if child.is_dir():
                    shutil.copytree(child, dst, dirs_exist_ok=True)
                elif child.is_file():
                    _copy_sol_source_for_iso(child, dst)

    def _normalize_import_unit_for_iso(import_unit: str) -> str:
        unit = str(import_unit or "").replace("\\", "/").strip()
        while unit.startswith("./"):
            unit = unit[2:]
        while unit.startswith("../"):
            unit = unit[3:]
        return unit.lstrip("/")

    def _find_package_import(import_unit: str) -> Optional[Path]:
        if not package_root:
            return None
        unit = _normalize_import_unit_for_iso(import_unit)
        if not unit or unit.startswith(".") or unit.startswith("@"):
            return None
        direct = package_root / unit
        if direct.exists() and direct.is_file():
            return direct
        contracts_direct = package_root / "contracts" / unit
        if contracts_direct.exists() and contracts_direct.is_file():
            return contracts_direct
        suffix = "/" + unit
        for cand in package_root.rglob(Path(unit).name):
            try:
                if cand.is_file() and cand.as_posix().endswith(suffix):
                    return cand
            except Exception:
                continue
        return None

    def _copy_nonrelative_package_imports() -> None:
        """Copy package imports into iso src/.

        Foundry resolves bare non-scoped imports relative to configured source
        roots/remappings.  Some historical packages use imports like
        `import "libraries/LibSafeMath32.sol";` instead of relative paths.
        Also, when a deep target file is flattened into iso/src, relative
        imports like `../../../libraries/X.sol` may no longer be valid from the
        copied location.  This closure is package-generic: it copies any
        package-local import found in the isolated src tree while preserving a
        normalized import path under iso/src.
        """
        if not package_root:
            return
        import_pat = re.compile(r'^\s*import\s+(?:\{[^;]*\}\s+from\s+)?["\']([^"\']+\.sol)["\'];', re.IGNORECASE)
        seen_units = set()
        changed = True
        while changed:
            changed = False
            for src_file in list((iso_root / "src").rglob("*.sol")):
                try:
                    text = src_file.read_text(encoding="utf-8", errors="ignore")
                except Exception:
                    continue
                for line in text.splitlines():
                    m_imp = import_pat.search(line)
                    if not m_imp:
                        continue
                    raw_unit = m_imp.group(1).replace("\\", "/")
                    if raw_unit.startswith("@"):
                        continue
                    unit = _normalize_import_unit_for_iso(raw_unit)
                    if not unit or unit.startswith("@") or unit in seen_units:
                        continue
                    if raw_unit.startswith("."):
                        local_dep = (src_file.parent / raw_unit).resolve()
                        try:
                            local_dep.relative_to((iso_root / "src").resolve())
                            if local_dep.exists():
                                seen_units.add(unit)
                                continue
                        except Exception:
                            pass
                    dep_src = _find_package_import(unit)
                    if not dep_src:
                        seen_units.add(unit)
                        continue
                    dep_dst = (iso_root / "src" / unit).resolve()
                    try:
                        dep_dst.relative_to((iso_root / "src").resolve())
                    except Exception:
                        seen_units.add(unit)
                        continue
                    if not dep_dst.exists():
                        _copy_sol_source_for_iso(dep_src, dep_dst)
                        changed = True
                    seen_units.add(unit)

    _copy_nonrelative_package_imports()

    def _rewrite_isolated_package_imports() -> None:
        """Normalize package-local relative imports to the isolated src root.

        Directly copied benchmark sources are often flattened from paths like
        `contracts/farm/facets/X.sol` into `src/X.sol`.  Their original imports
        (`../../../libraries/Y.sol`, `../../AppStorage.sol`, etc.) then point
        outside the isolated `src/` tree even though the corresponding package
        files have been copied under `src/libraries/Y.sol` or `src/Y.sol`.
        Rewrite only imports that can be resolved inside the isolated src root.
        """
        src_root = (iso_root / "src").resolve()
        import_pat = re.compile(
            r'(?P<prefix>^\s*import\s+(?:\{[^;]*\}\s+from\s+)?["\'])(?P<unit>[^"\']+\.sol)(?P<suffix>["\'];)',
            re.IGNORECASE | re.MULTILINE,
        )

        def normalize_unit(raw_unit: str) -> Optional[str]:
            raw_unit = (raw_unit or "").replace("\\", "/")
            if raw_unit.startswith("@"):
                return None
            if not raw_unit.startswith("."):
                return raw_unit if (src_root / raw_unit).exists() else None
            unit = _normalize_import_unit_for_iso(raw_unit)
            if unit and (src_root / unit).exists():
                return unit
            base = Path(unit).name
            if base and (src_root / base).exists():
                return base
            return None

        for src_file in list((iso_root / "src").rglob("*.sol")):
            try:
                text = src_file.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                continue
            changed = False

            def repl(match: re.Match) -> str:
                nonlocal changed
                raw_unit = match.group("unit")
                new_unit = normalize_unit(raw_unit)
                if not new_unit or new_unit == raw_unit:
                    return match.group(0)
                changed = True
                return f"{match.group('prefix')}{new_unit}{match.group('suffix')}"

            new_text = import_pat.sub(repl, text)
            if changed:
                src_file.write_text(new_text, encoding="utf-8")

    # Optional supplement tests import the baseline invariant test from the
    # same test directory, e.g. import "./Foo_Invariant.t.sol";. Copy those
    # dependencies into the isolated project when present.
    test_import_re = re.compile(r'^\s*import\s+["\']\./([^"\']+\.t\.sol)["\'];', re.IGNORECASE)
    copied_test_imports = set()
    for line in test_src.splitlines():
        m_test = test_import_re.search(line)
        if not m_test:
            continue
        rel_test_name = m_test.group(1)
        if rel_test_name in copied_test_imports:
            continue
        dep = (test_abs.parent / rel_test_name).resolve()
        if dep.exists() and dep.is_file():
            shutil.copy2(dep, iso_root / "test" / dep.name)
            try:
                test_src += "\n" + dep.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                pass
            copied_test_imports.add(rel_test_name)

    # 解析测试文件中的 import "../src/xxx.sol" 并复制对应源码
    import_re = re.compile(r'^\s*import\s+["\']\.\./src/([^"\']+)\.sol["\'];', re.IGNORECASE)
    imported_units: List[str] = []
    for line in test_src.splitlines():
        m = import_re.search(line)
        if m:
            rel_name = m.group(1)  # 可能包含子目录，如 Foo/Bar
            imported_units.append(rel_name)

    # 去重
    imported_units = list(dict.fromkeys(imported_units))

    # 复制每个 import 的源码（若不存在则跳过并记录）
    missing_sources: List[str] = []
    for unit in imported_units:
        cand = None
        unit_file = Path(unit + ".sol")
        if source_path:
            try:
                source_abs_for_unit = Path(source_path).resolve()
                if source_abs_for_unit.name == unit_file.name:
                    cand = source_abs_for_unit
            except Exception:
                cand = None
        if cand is None and package_root:
            direct_pkg = package_root / unit_file
            contracts_pkg = package_root / "contracts" / unit_file
            if direct_pkg.exists():
                cand = direct_pkg
            elif contracts_pkg.exists():
                cand = contracts_pkg
            else:
                matches = [p for p in package_root.rglob(unit_file.name) if p.is_file()]
                if matches:
                    cand = matches[0]
        if cand is None:
            # Last-resort compatibility fallback. Prefer package-local sources
            # above to avoid stale global foundry/src dependencies leaking
            # between benchmark targets.
            cand = original_root / "src" / unit_file
        if cand.exists():
            # 保持扁平复制（文件名保留最后一段）
            _copy_sol_source_for_iso(cand, iso_root / "src" / cand.name)
            _copy_relative_import_tree(cand, iso_root / "src" / cand.name)
        else:
            missing_sources.append(str(cand))

    _rewrite_isolated_package_imports()
    _copy_nonrelative_package_imports()
    _rewrite_isolated_package_imports()

    # 拷贝 lib/（用于 forge-std 等依赖）
    orig_lib = original_root / "lib"
    if orig_lib.exists():
        # Python 3.8+：dirs_exist_ok=True
        shutil.copytree(orig_lib, iso_root / "lib", dirs_exist_ok=True)

    # 生成最小 foundry.toml（启用自动检测多编译器）
    solc_pin = str(solc_version or "").strip()
    if solc_pin.startswith("v"):
        solc_pin = solc_pin[1:]
    evm_pin = str(evm_version or "byzantium").strip() or "byzantium"
    if solc_pin:
        src_root = iso_root / "src"
        src_remappings: List[str] = []
        for child in sorted(src_root.iterdir()) if src_root.exists() else []:
            if child.is_dir():
                if child.name.lower() in {"lib", "libs", "library"}:
                    continue
                src_remappings.append(f"{child.name}/=src/{child.name}/")
            elif child.is_file() and child.suffix == ".sol":
                src_remappings.append(f"{child.name}=src/{child.name}")
        all_remappings = list(dict.fromkeys(package_remappings + src_remappings))
        foundry_toml = (
            "[profile.default]\n"
            f'solc = "{solc_pin}"\n'
            "auto_detect_solc = false\n"
            f'evm_version = "{evm_pin}"\n'
            'src = "src"\n'
            'test = "test"\n'
            'libs = ["lib"]\n'
        )
        if all_remappings:
            escaped = ", ".join(json.dumps(item) for item in all_remappings)
            foundry_toml += f"remappings = [{escaped}]\n"
        (meta_dir / "foundry_solc_binding.json").write_text(
            json.dumps(
                {
                    "requested_solc": solc_version,
                    "effective_solc": solc_pin,
                    "auto_detect_solc": False,
                    "evm_version": evm_pin,
                    "isolated_project": str(iso_root),
                    "package_root": str(package_root) if package_root else None,
                    "remappings": all_remappings,
                },
                indent=2,
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )
    else:
        foundry_toml = "[profile.default]\nauto_detect_solc = true\n"
    (iso_root / "foundry.toml").write_text(foundry_toml, encoding="utf-8")
    forge_env = os.environ.copy()
    forge_tmp = iso_root / ".tmp"
    forge_tmp.mkdir(parents=True, exist_ok=True)
    forge_env["TMP"] = str(forge_tmp)
    forge_env["TEMP"] = str(forge_tmp)

    # 在隔离目录内的 match-path：只匹配当前测试文件名
    match_path = f"test/{test_abs.name}"

    # 1) 结构化 JSON
    cmd_json: List[str] = [forge, "test", "--match-path", match_path, "--json"]
    if profile:
        cmd_json = [forge, "test", "-p", profile, "--match-path", match_path, "--json"]

    p1 = subprocess.Popen(cmd_json, cwd=str(iso_root), stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=forge_env)
    out1, err1 = p1.communicate()

    if p1.returncode != 0:
        # 回退：跑一次非 JSON，拿到真正的编译或运行日志
        cmd_fallback: List[str] = [forge, "test", "--match-path", match_path, "-vv"]
        if profile:
            cmd_fallback = [forge, "test", "-p", profile, "--match-path", match_path, "-vv"]
        p_fb = subprocess.Popen(cmd_fallback, cwd=str(iso_root), stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=forge_env)
        fb_out, fb_err = p_fb.communicate()
        diag = (fb_out or fb_err).decode("utf-8", errors="ignore")

        # 在日志顶部加入 import 缺失提示
        if missing_sources:
            miss_block = "[func_test] WARNING: 下列 import 未在原工程 src/ 中找到，可能导致编译失败：\n" + \
                         "\n".join(f"  - {p}" for p in missing_sources) + "\n\n"
            diag = miss_block + diag

        # 写入回退诊断（不覆盖后面的 trace 文件）
        (meta_dir / "fallback_diagnostic.txt").write_text(diag, encoding="utf-8")

        if "No tests match the provided pattern" in diag:
            empty_data = {"test_results": {}}
            empty_summary = {
                "suite": [],
                "total": 0,
                "pass": 0,
                "fail": 0,
                "failed_tests": [],
            }
            (meta_dir / "all_test_results.json").write_text(
                json.dumps(empty_data, indent=2, ensure_ascii=False),
                encoding="utf-8"
            )
            (meta_dir / "failed_tests.json").write_text("[]", encoding="utf-8")
            (meta_dir / "summary.json").write_text(
                json.dumps(empty_summary, indent=2, ensure_ascii=False),
                encoding="utf-8"
            )
            (meta_dir / "failure_report.json").write_text(
                json.dumps({"fail_count": 0, "failures": []}, indent=2, ensure_ascii=False),
                encoding="utf-8"
            )
            (meta_dir / "failure_report.txt").write_text(
                "=== Foundry Failing Tests Report ===\nTotal failed: 0\n",
                encoding="utf-8"
            )
            (meta_dir / "finding_report.json").write_text(
                json.dumps(
                    {
                        "schema_version": "con-fuzzius.finding.v1",
                        "origin": "foundry",
                        "fail_count": 0,
                        "finding_ids": [],
                        "findings": [],
                    },
                    indent=2,
                    ensure_ascii=False,
                ),
                encoding="utf-8"
            )
            compile_error = meta_dir / "compile_error.txt"
            if compile_error.exists():
                compile_error.unlink()
            return empty_data, diag

        # —— 关键改动：根据日志“像不像一次真实 test 执行”来决定是否抛异常 —— #
        mode = _classify_failure_mode(diag)
        if mode == "TEST_RUN":
            # 认为是“确实跑了测试（即使有失败）”，不抛异常，继续后续流程
            # 同时也把“回退日志”放到 meta 方便你事后排查
            pass
        else:
            # 确认是编译/环境 ERROR：抛异常（与原行为一致）
            head = "\n".join([ln for ln in diag.splitlines() if ln.strip()][:40])
            (meta_dir / "compile_error.txt").write_text(diag, encoding="utf-8")
            raise RuntimeError(
                "forge test (json) 失败且判定为 ERROR（未进入正常测试流程）。完整诊断见 compile_error.txt\n\n" +
                textwrap.dedent(head)
            )

    # 解析 JSON
    txt = out1.decode("utf-8", errors="ignore").strip()
    start = txt.find("{")
    if start > 0:
        txt = txt[start:]
    end = txt.rfind("}")
    if end > 0:
        txt = txt[:end+1]

    try:
        data = json.loads(txt)
    except Exception:
        (meta_dir / "json_parse_error.txt").write_text(txt, encoding="utf-8")
        raise RuntimeError("forge --json 输出无法解析，原始内容已写入 json_parse_error.txt")

    # --- 保存原始 JSON 结果 & 简要摘要（无论是否有失败） ---
    (meta_dir / "all_test_results.json").write_text(json.dumps(data, indent=2), encoding="utf-8")

    # 2) 高层 Trace：-vvvv（stdout 打印 “Traces:” 块）
    cmd_trace: List[str] = [forge, "test", "--match-path", match_path, "-vvvv"]
    if profile:
        cmd_trace = [forge, "test", "-p", profile, "--match-path", match_path, "-vvvv"]

    p2 = subprocess.Popen(cmd_trace, cwd=str(iso_root), stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=forge_env)
    out2, err2 = p2.communicate()

    # 大多数版本“Traces:”打印在 stdout（out2）
    trace_text = (out2 or b"").decode("utf-8", errors="ignore")

    # 将轨迹/错误写回原工程 meta
    (meta_dir / "last_trace.txt").write_text(trace_text, encoding="utf-8")
    (meta_dir / "last_stderr.txt").write_text((err2 or b"").decode("utf-8", "ignore"), encoding="utf-8")

    # # --- 失败用例名 & 独立轨迹 ---
    # failed_test_details = _extract_failed_tests(data, trace_text)
    # (meta_dir / "failed_test_details.json").write_text(json.dumps(failed_test_details, indent=2, ensure_ascii=False), encoding="utf-8")

    # ft_dir = meta_dir / "failed_traces"
    # ft_dir.mkdir(exist_ok=True)
    # per_fail_traces = _extract_traces_for_failed_tests(trace_text, failed_test_details)
    # for tname, tcontent in per_fail_traces.items():
    #     (ft_dir / f"{tname}.trace.txt").write_text(tcontent, encoding="utf-8")

    # --- 失败用例详情：优先解析 Failing tests: 汇总区 ---
    failed_test_details = _extract_failed_tests(data, trace_text)
    (meta_dir / "failed_test_details.json").write_text(
        json.dumps(failed_test_details, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )

    # --- 为每个失败测试单独 rerun，生成独立 trace ---
    ft_dir = meta_dir / "failed_traces"
    ft_dir.mkdir(exist_ok=True)

    for item in failed_test_details:
        suite_name = item.get("suite", "unknown_suite")
        test_name_one = item.get("test_name", "unknown_test")

        single_trace = _rerun_single_failed_test_trace(
            forge=forge,
            iso_root=iso_root,
            match_path=match_path,
            suite_name=suite_name,
            test_name=test_name_one,
            profile=profile,
        )

        trace_file = ft_dir / f"{_safe_filename(suite_name)}__{_safe_filename(test_name_one)}.trace.txt"
        trace_file.write_text(single_trace, encoding="utf-8")

    # --- 摘要统计（支持多 suite） ---
    pass_cnt = 0
    fail_cnt = 0
    observability_pass_cnt = 0
    observability_fail_cnt = 0
    failed_tests = []
    suite_names = []

    if isinstance(data, dict) and "test_results" in data:
        suite_name = data.get("suite") or data.get("contract_name") or "unknown_suite"
        suite_names.append(suite_name)
        test_results = data.get("test_results") or {}

        for name, info in test_results.items():
            if not isinstance(info, dict):
                continue
            st = _normalize_status(info.get("status"))
            is_obs = _is_observability_test_name(suite_name, name)
            if st == "pass":
                pass_cnt += 1
                if is_obs:
                    observability_pass_cnt += 1
            else:
                fail_cnt += 1
                if is_obs:
                    observability_fail_cnt += 1
                clean_name = str(name).strip()
                if clean_name.endswith("()"):
                    clean_name = clean_name[:-2]

                failed_tests.append({
                    "suite": suite_name,
                    "test_name": clean_name,
                })
    else:
        for suite_name, suite_obj in (data or {}).items():
            if not isinstance(suite_obj, dict):
                continue
            test_results = suite_obj.get("test_results") or {}
            if not test_results:
                continue

            suite_names.append(suite_name)

            for name, info in test_results.items():
                if not isinstance(info, dict):
                    continue
                st = _normalize_status(info.get("status"))
                is_obs = _is_observability_test_name(suite_name, name)
                if st == "pass":
                    pass_cnt += 1
                    if is_obs:
                        observability_pass_cnt += 1
                else:
                    fail_cnt += 1
                    if is_obs:
                        observability_fail_cnt += 1
                    clean_name = str(name).strip()
                    if clean_name.endswith("()"):
                        clean_name = clean_name[:-2]

                    failed_tests.append({
                        "suite": suite_name,
                        "test_name": clean_name,
                    })

    # (meta_dir / "failed_tests.json").write_text(json.dumps(failed_tests, indent=2), encoding="utf-8")

    # summary = {
    #     "suite": suite_name,
    #     "total": pass_cnt + fail_cnt,
    #     "pass": pass_cnt,
    #     "fail": fail_cnt,
    #     "failed_tests": failed_tests,
    # }
    # (meta_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")

    # # --- 独立失败轨迹切分：仍沿用高层文本切分 ---
    # if failed_tests:
    #     ft_dir = meta_dir / "failed_traces"
    #     ft_dir.mkdir(exist_ok=True)
    #     per_fail_traces = _extract_traces_for_failed_tests(trace_text, failed_tests)
    #     for tname, tcontent in per_fail_traces.items():
    #         (ft_dir / f"{tname}.trace.txt").write_text(tcontent, encoding="utf-8")

    # return data, trace_text

    # failed_tests 此处统一只保留“失败测试名列表”
    (meta_dir / "failed_tests.json").write_text(
        json.dumps(failed_tests, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )

    observability_total = observability_pass_cnt + observability_fail_cnt
    reachability_report = _extract_reachability_report(trace_text)
    (meta_dir / "reachability_summary.json").write_text(
        json.dumps(reachability_report, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )

    summary = {
        "suite": sorted(list(dict.fromkeys(suite_names))),
        "total": pass_cnt + fail_cnt,
        "pass": pass_cnt,
        "fail": fail_cnt,
        "observability_total": observability_total,
        "observability_pass": observability_pass_cnt,
        "observability_fail": observability_fail_cnt,
        "semantic_total": max(pass_cnt + fail_cnt - observability_total, 0),
        "semantic_pass": max(pass_cnt - observability_pass_cnt, 0),
        "semantic_fail": max(fail_cnt - observability_fail_cnt, 0),
        "reachability": reachability_report,
        "failed_tests": failed_tests,
    }
    (meta_dir / "summary.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )

    # # --- 独立失败轨迹切分 ---
    # if failed_tests:
    #     ft_dir = meta_dir / "failed_traces"
    #     ft_dir.mkdir(exist_ok=True)
    #     per_fail_traces = _extract_traces_for_failed_tests(trace_text, failed_tests)
    #     for tname, tcontent in per_fail_traces.items():
    #         (ft_dir / f"{_safe_filename(tname)}.trace.txt").write_text(
    #             tcontent, encoding="utf-8"
    #         )
    
    if is_invariant_test==True:
        # --- 失败解释/不变量映射/复现命令/路径线索 ---
        failure_report = build_failing_tests_report(
            data=data,
            trace_text=trace_text,
            forge=forge,
            iso_root=iso_root,
            match_path=match_path,
            profile=profile,
        )
        save_failing_tests_report(
            meta_dir,
            failure_report,
            source_path=source_path,
            contract_name=contract_name,
            validate_minimization=validate_minimization,
            minimization_timeout=minimization_timeout,
        )
        _print_failure_report_to_console(failure_report)

    return data, trace_text
