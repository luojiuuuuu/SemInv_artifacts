#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import re
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

from fuzzer.func_test.gen_foundry_tests import call_llm
from fuzzer.utils.env_config import get_llm_config
from fuzzer.utils.text_sanitize import sanitize_jsonable, sanitize_report_text


def _jsonable(value: Any) -> Any:
    if value is None or isinstance(value, (str, int, float, bool)):
        return value
    if isinstance(value, (bytes, bytearray)):
        return "0x" + bytes(value).hex()
    if isinstance(value, (list, tuple, set)):
        return [_jsonable(v) for v in value]
    if isinstance(value, dict):
        return {str(k): _jsonable(v) for k, v in value.items()}
    return str(value)


def _read_json(path: Path) -> Optional[Dict[str, Any]]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None
    return data if isinstance(data, dict) else None


def _read_text(path: Optional[Path], max_chars: int) -> Optional[str]:
    if path is None or not path.exists():
        return None
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return None
    if max_chars and len(text) > max_chars:
        return text[:max_chars] + "\n/* ... truncated ... */"
    return text


def _strip_solidity_comments(source_text: Optional[str]) -> Optional[str]:
    if not source_text:
        return source_text
    text = re.sub(r"/\*.*?\*/", "", source_text, flags=re.S)
    text = re.sub(r"//.*?$", "", text, flags=re.M)
    return text


def _extract_json_object(text: str) -> Optional[Dict[str, Any]]:
    raw = (text or "").strip()
    if not raw:
        return None
    try:
        data = json.loads(raw)
        return data if isinstance(data, dict) else None
    except Exception:
        pass

    fenced = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", raw, flags=re.S)
    if fenced:
        try:
            data = json.loads(fenced.group(1))
            return data if isinstance(data, dict) else None
        except Exception:
            pass

    start = raw.find("{")
    end = raw.rfind("}")
    if start >= 0 and end > start:
        try:
            data = json.loads(raw[start:end + 1])
            return data if isinstance(data, dict) else None
        except Exception:
            return None
    return None


def _analysis_candidates(contract_name: str, source_path: Optional[str]) -> List[Path]:
    contract = Path(str(contract_name or "contract")).stem
    cwd = Path.cwd()
    candidates = [
        cwd / f"{contract}_meta" / "analysis.json",
        cwd / f"{contract}_meta" / "baseline_analysis.json",
        cwd / "foundry" / f"{contract}_meta" / "invariant_test" / "analysis.json",
        cwd / "foundry" / f"{contract}_meta" / "functional_test" / "analysis.json",
        cwd / "debug_out" / contract / "baseline_analysis.json",
    ]
    if source_path:
        stem = Path(str(source_path)).stem
        candidates.append(cwd / "debug_out" / stem / "baseline_analysis.json")
    return candidates


def _load_contract_analysis(contract_name: str, source_path: Optional[str]) -> Optional[Dict[str, Any]]:
    seen = set()
    for path in _analysis_candidates(contract_name, source_path):
        key = str(path)
        if key in seen:
            continue
        seen.add(key)
        data = _read_json(path)
        if data:
            data["_artifact_path"] = str(path)
            return data
    return None


def build_contract_context(
    *,
    contract_name: str,
    source_path: Optional[str] = None,
    abi: Optional[List[Dict[str, Any]]] = None,
    max_source_chars: int = 40000,
) -> Dict[str, Any]:
    source_file = Path(source_path) if source_path else None
    analysis = _load_contract_analysis(contract_name, source_path)
    source_text = _strip_solidity_comments(_read_text(source_file, max_chars=max_source_chars))
    context: Dict[str, Any] = {
        "name": Path(str(contract_name or "contract")).stem,
        "source_path": str(source_file) if source_file else None,
        "source_code": source_text,
        "abi": _jsonable(abi or []),
        "analysis": None,
    }
    if analysis:
        context["analysis"] = {
            "artifact_path": analysis.get("_artifact_path"),
            "meta": analysis.get("meta"),
            "storage": analysis.get("storage"),
            "functions": analysis.get("functions"),
            "dfg": analysis.get("dfg"),
            "update_facts": analysis.get("update_facts"),
        }
    return sanitize_jsonable(_jsonable(context))


_REPORT_ONLY_FINDING_FIELDS = {
    "check_ref",
    "predicate",
    "bindings",
    "spec_basis",
    "observation_status",
    "evidence_mode",
    "applicability",
    "interpretation_reason",
    "check_resolution",
    "reporting_evidence",
    "pattern_id",
    "guard_direction",
    "report_disposition",
    "return_handling",
    "return_check_statement",
}


def _project_root_cause_input(finding: Dict[str, Any]) -> Dict[str, Any]:
    """Keep report-only check provenance outside the optional RCA prompt."""
    out = json.loads(json.dumps(finding, ensure_ascii=False))
    for field in _REPORT_ONLY_FINDING_FIELDS:
        out.pop(field, None)

    violation = out.get("violation")
    if isinstance(violation, dict):
        root_cause_property = violation.pop("root_cause_property", None)
        if root_cause_property is not None:
            violation["property"] = root_cause_property

    llm_context = out.get("llm_context")
    if isinstance(llm_context, dict):
        root_cause_property = llm_context.pop("root_cause_property", None)
        if root_cause_property is not None:
            llm_context["violated_property"] = root_cause_property

    def normalize(value: Any) -> None:
        if isinstance(value, dict):
            if value.get("kind") == "assertion_observation":
                value["kind"] = "failed_assertion"
            if value.get("kind") in ("assertEq", "assertTrue") and "raw" in value:
                value.pop("outcome", None)
            for nested in value.values():
                normalize(nested)
        elif isinstance(value, list):
            for nested in value:
                normalize(nested)

    normalize(out)
    return out


def build_root_cause_prompt(finding: Dict[str, Any], contract_context: Dict[str, Any]) -> str:
    finding = _project_root_cause_input(finding)
    output_schema = {
        "root_cause": "concise root cause statement",
        "bug_pattern": "known pattern or invariant class",
        "vulnerable_function": "function name/signature or null",
        "vulnerable_state": ["state variable names"],
        "trigger_sequence": ["normalized calls in order"],
        "violated_property": "property or detector condition",
        "evidence_chain": [
            {
                "kind": "dynamic|static|source|oracle",
                "evidence": "specific evidence from the inputs",
                "supports": "what this evidence proves"
            }
        ],
        "why_sequence_triggers_bug": "causal explanation from sequence to violation",
        "minimal_fix_principle": "minimal repair principle, not a full patch",
        "confidence": "high|medium|low",
        "uncertainties": ["remaining evidence gaps, if any"]
    }
    return (
        "You are a smart-contract root-cause analysis engine.\n"
        "You will receive exactly two inputs:\n"
        "A. Finding Evidence Package: one finding_cases_pro JSON.\n"
        "B. Contract Context: source/ABI/static-analysis facts for the same contract.\n\n"
        "Rules:\n"
        "1. Use only A and B. Do not introduce external facts.\n"
        "2. Treat the finding JSON as the primary evidence.\n"
        "3. The root cause must be supported by dynamic evidence and static/source evidence when available.\n"
        "4. Distinguish the trigger sequence from the root cause.\n"
        "5. If evidence is incomplete, report uncertainties instead of guessing.\n"
        "6. Return strict JSON only, with no markdown or commentary.\n"
        "7. Ignore source-code comments and do not quote comments as evidence. If a source snippet contains mojibake or unreadable non-English text, ignore that text and rely on executable code, dynamic evidence, and static facts.\n\n"
        "Reasoning protocol:\n"
        "1. Identify the violated property from classification and llm_context.violated_property.\n"
        "2. Recover the minimal trigger path from trajectory and llm_context.trigger_functions.\n"
        "3. Use llm_context.static_facts, touched_state, and Contract Context to identify the state update rule.\n"
        "4. Cross-check source/location snippets against the static facts.\n"
        "5. Apply a counterfactual check: would the same trigger stop violating the property if this root cause were fixed?\n\n"
        "Output schema:\n"
        f"{json.dumps(output_schema, indent=2, ensure_ascii=False)}\n\n"
        "A. Finding Evidence Package:\n"
        f"{json.dumps(finding, indent=2, ensure_ascii=False)}\n\n"
        "B. Contract Context:\n"
        f"{json.dumps(contract_context, indent=2, ensure_ascii=False)}\n"
    )


def analyze_finding_with_llm(
    finding: Dict[str, Any],
    contract_context: Dict[str, Any],
    *,
    api_key: str,
    api_url: str,
    model: str,
) -> Dict[str, Any]:
    prompt = build_root_cause_prompt(sanitize_jsonable(finding), contract_context)
    started = int(time.time())
    raw = call_llm(prompt, api_key=api_key, api_url=api_url, model=model)
    parsed = _extract_json_object(raw)
    if parsed is None:
        return {
            "status": "parse_error",
            "created_at": started,
            "finding_id": finding.get("id"),
            "semantic_fingerprint": finding.get("semantic_fingerprint"),
            "raw_response": sanitize_report_text(raw),
        }
    parsed.setdefault("status", "ok")
    parsed.setdefault("created_at", started)
    parsed["finding_id"] = finding.get("id")
    parsed["semantic_fingerprint"] = finding.get("semantic_fingerprint")
    parsed["dedup_key"] = finding.get("dedup_key")
    return sanitize_jsonable(_jsonable(parsed))


def _load_deduplicated_violation_events(pro_dir: Path) -> List[Dict[str, Any]]:
    events_path = pro_dir / "violation_events.json"
    data = _read_json(events_path)
    if not data:
        return []
    events = data.get("events")
    if not isinstance(events, list):
        return []
    out: List[Dict[str, Any]] = []
    for event in events:
        if isinstance(event, dict):
            item = sanitize_jsonable(event)
            item.setdefault("id", item.get("event_id") or item.get("finding_id"))
            item.setdefault("semantic_fingerprint", item.get("semantic_fingerprint") or item.get("event_id"))
            out.append(item)
    return out


def generate_root_cause_report(
    finding_cases_pro_dir: Path,
    *,
    contract_name: str,
    source_path: Optional[str] = None,
    abi: Optional[List[Dict[str, Any]]] = None,
    api_key: Optional[str] = None,
    api_url: Optional[str] = None,
    model: Optional[str] = None,
    env_file: Optional[str] = None,
    max_source_chars: int = 40000,
) -> Dict[str, Any]:
    pro_dir = Path(finding_cases_pro_dir)
    llm_config = get_llm_config(env_file=env_file, api_key=api_key, api_url=api_url, model=model)
    api_key = llm_config.get("api_key")
    api_url = llm_config.get("api_url")
    model = llm_config.get("model")

    report: Dict[str, Any] = {
        "schema_version": "semantic-invariant.root_cause.v1",
        "created_at": int(time.time()),
        "contract": {
            "name": Path(str(contract_name or "contract")).stem,
            "source_path": source_path,
        },
        "finding_cases_pro_dir": str(pro_dir),
        "model": model,
        "api_url": api_url,
        "status": "ok",
        "results": [],
        "errors": [],
    }
    out_path = pro_dir / "llm_root_cause_report.json"

    if not pro_dir.exists():
        report["status"] = "skipped"
        report["errors"].append({"reason": "missing_finding_cases_pro_dir"})
        return report
    if not api_key or not api_url or not model:
        report["status"] = "skipped"
        report["errors"].append({"reason": "missing_llm_config"})
        out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
        return report

    context = build_contract_context(
        contract_name=contract_name,
        source_path=source_path,
        abi=abi,
        max_source_chars=max_source_chars,
    )
    report["contract_context_summary"] = {
        "has_source": bool(context.get("source_code")),
        "has_abi": bool(context.get("abi")),
        "has_analysis": bool(context.get("analysis")),
        "analysis_artifact": ((context.get("analysis") or {}).get("artifact_path")),
    }

    dedup_events = _load_deduplicated_violation_events(pro_dir)
    report["input_mode"] = "deduplicated_violation_events" if dedup_events else "finding_cases_pro_files"
    report["input_count"] = len(dedup_events)
    if dedup_events:
        finding_items = [
            (f"{pro_dir / 'violation_events.json'}#{event.get('event_id')}", event)
            for event in dedup_events
        ]
    else:
        finding_paths = [
            path for path in sorted(pro_dir.glob("*.json"))
            if path.name not in ("finding_index.json", "llm_root_cause_report.json", "violation_events.json")
        ]
        finding_items = []
        for path in finding_paths:
            finding = _read_json(path)
            if not finding:
                report["errors"].append({"path": str(path), "reason": "invalid_finding_json"})
                continue
            finding_items.append((str(path), sanitize_jsonable(finding)))
        report["input_count"] = len(finding_items)

    for path_label, finding in finding_items:
        try:
            result = analyze_finding_with_llm(
                finding,
                context,
                api_key=api_key,
                api_url=api_url,
                model=model,
            )
            result["finding_path"] = str(path_label)
            report["results"].append(result)
        except Exception as exc:
            report["errors"].append({
                "path": str(path_label),
                "finding_id": finding.get("id"),
                "semantic_fingerprint": finding.get("semantic_fingerprint"),
                "reason": str(exc),
            })

    if report["errors"] and not report["results"]:
        report["status"] = "failed"
    elif report["errors"]:
        report["status"] = "partial"

    report = sanitize_jsonable(_jsonable(report))
    out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    return report
