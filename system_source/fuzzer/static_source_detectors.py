#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Source-level evidence detectors for benchmark patterns.

These detectors are intentionally conservative: they only emit findings when a
well-known Solidity anti-pattern is visible in source text. Runtime detectors
still provide the primary evidence; this module preserves strong source-level
labels that can otherwise be hidden by unrelated numeric/DoS events.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

from .reporting.finding_schema import process_finding_cases


SCHEMA_VERSION = "semantic-invariant.finding.v1"


def _write_path(path: Path) -> Path:
    resolved = str(path.resolve())
    if os.name != "nt" or resolved.startswith("\\\\?\\"):
        return Path(resolved)
    if resolved.startswith("\\\\"):
        return Path("\\\\?\\UNC\\" + resolved.lstrip("\\"))
    return Path("\\\\?\\" + resolved)


CLASSIFICATIONS: Dict[str, Dict[str, Any]] = {
    "bad_randomness_dependency": {
        "type": "L4 Bad Randomness Dependency",
        "kind": "bad_randomness_dependency",
        "severity": "Medium",
        "swc_id": 120,
        "invariant_id": "I6.external.bad_randomness_dependency",
        "invariant_category": "I6_EXTERNAL_ENVIRONMENT",
        "trigger_template": "environmental_randomness_taints_payout_or_irreversible_state",
        "benchmark_labels": ["SB Curated:bad_randomness"],
        "summary": "Block/timestamp/hash-derived randomness reaches persistent state or payout selection.",
        "primary_backend": "static_source",
    },
    "approve_race": {
        "type": "L4 ERC20 Approve Race",
        "kind": "approve_race",
        "severity": "Medium",
        "swc_id": 114,
        "invariant_id": "I4.transaction.order_independence",
        "invariant_category": "I4_TRANSACTIONAL_CONSISTENCY",
        "trigger_template": "erc20_approve_overwrites_allowance_without_zero_reset",
        "benchmark_labels": ["SB Curated:front_running"],
        "summary": "ERC20 approve overwrites an existing allowance without a zero-reset or increase/decrease allowance guard.",
        "primary_backend": "static_source",
    },
    "failed_refund_dos": {
        "type": "L4 Failed Refund DoS",
        "kind": "failed_refund_dos",
        "severity": "Medium",
        "swc_id": 128,
        "invariant_id": "I5.resource.bounded_execution",
        "invariant_category": "I5_RESOURCE_EXECUTION",
        "trigger_template": "external_refund_failure_blocks_progress",
        "benchmark_labels": ["SB Curated:denial_of_service"],
        "summary": "A failed refund send is required to succeed before the state transition can progress.",
        "primary_backend": "static_source",
    },
    "unchecked_return_value": {
        "type": "Unchecked Return Value",
        "kind": "unchecked_return_value",
        "severity": "Medium",
        "swc_id": 104,
        "invariant_id": "I6.external.call_return_consistency",
        "invariant_category": "I6_EXTERNAL_ENVIRONMENT",
        "trigger_template": "low_level_call_return_not_checked_before_effect",
        "benchmark_labels": ["SB Curated:unchecked_low_level_calls"],
        "summary": "A low-level send/call return value is ignored or stored but never checked.",
        "primary_backend": "static_source",
    },
}


def _strip_comments(source: str) -> str:
    source = re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), source, flags=re.S)
    source = re.sub(r"//.*", "", source)
    return source


def _line_number(source: str, offset: int) -> int:
    return source.count("\n", 0, max(0, offset)) + 1


def _line_text(source: str, line: int) -> str:
    lines = source.splitlines()
    if 1 <= line <= len(lines):
        return lines[line - 1].strip()
    return ""


def _function_blocks(source: str) -> List[Dict[str, Any]]:
    blocks: List[Dict[str, Any]] = []
    pattern = re.compile(r"\bfunction\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^)]*\)[^{;]*\{", re.S)
    for match in pattern.finditer(source):
        start = match.start()
        brace = source.find("{", match.end() - 1)
        depth = 0
        end = brace
        for pos in range(brace, len(source)):
            ch = source[pos]
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    end = pos + 1
                    break
        blocks.append({
            "name": match.group(1),
            "start": start,
            "end": end,
            "header": source[match.start():brace],
            "body": source[brace + 1:end - 1],
            "line": _line_number(source, start),
        })
    return blocks


def _has_environment_randomness(text: str) -> bool:
    return bool(re.search(r"\b(blockhash|block\.blockhash|block\.number|block\.timestamp|now)\b", text))


def _has_random_transform(text: str) -> bool:
    return bool(re.search(r"\b(keccak256|sha3|blockhash|block\.blockhash)\b|%", text))


def _new_finding(
    *,
    source_path: Path,
    contract_name: str,
    classification_key: str,
    line: int,
    source_code: str,
    evidence: Dict[str, Any],
) -> Dict[str, Any]:
    classification = dict(CLASSIFICATIONS[classification_key])
    identity = {
        "origin": "static_source_detector",
        "source": str(source_path),
        "contract": contract_name,
        "kind": classification["kind"],
        "line": line,
        "evidence": evidence,
    }
    digest = hashlib.sha1(json.dumps(identity, sort_keys=True, ensure_ascii=False).encode("utf-8")).hexdigest()[:24]
    dedup_key = f"{contract_name}:static:{classification['kind']}:{line}:{digest[:8]}"
    return {
        "schema_version": SCHEMA_VERSION,
        "origin": "fuzzer_detector",
        "id": digest,
        "dedup_key": dedup_key,
        "semantic_fingerprint": hashlib.sha1(dedup_key.encode("utf-8")).hexdigest()[:24],
        "created_at": int(time.time()),
        "contract": {
            "name": contract_name,
            "source": str(source_path),
            "deployed_address": None,
        },
        "classification": classification,
        "location": {
            "pc": f"source:{line}",
            "file": str(source_path),
            "line": line,
            "column": 1,
            "source_code": source_code,
        },
        "trigger": {
            "tx_index": None,
            "failure_reason": classification["type"],
            "detail": {
                "source_detector": classification["kind"],
                "evidence": evidence,
                "classification": classification,
            },
        },
        "trajectory": {"setup": [], "steps": []},
        "reproduction": {
            "mode": "source_pattern",
            "command": None,
            "config": {"source": str(source_path), "contract": contract_name},
            "test_path": None,
            "match_contract": contract_name,
            "match_test": None,
        },
        "trace": {
            "raw_path": None,
            "key_path_lines": [source_code],
            "target_calls": [],
            "handler_calls": [],
            "events": [],
            "revert_detected": False,
            "assert_lines": [],
        },
        "minimization": {
            "unit": "source_pattern",
            "preserve_prefix_until": None,
            "oracle": {
                "kind": "source_static_evidence",
                "expected_type": classification["type"],
            },
        },
        "llm_context": {
            "summary": classification["summary"],
            "evidence_chain": [evidence],
            "evidence_sources": {"source": str(source_path), "line": line},
        },
        "artifacts": {"json": None, "trace": None, "raw_stdout": None, "raw_stderr": None},
    }


def _detect_randomness(source: str, stripped: str, source_path: Path, contract_name: str) -> List[Dict[str, Any]]:
    findings: List[Dict[str, Any]] = []
    blocks = _function_blocks(stripped)
    random_helpers = {
        block["name"]
        for block in blocks
        if _has_environment_randomness(block["body"]) and _has_random_transform(block["body"])
    }
    for block in blocks:
        body = block["body"]
        name = block["name"]
        is_constructor = name == contract_name
        helper_call = any(re.search(r"\b%s\s*\(" % re.escape(helper), body) for helper in random_helpers if helper != name)
        if not ((_has_environment_randomness(body) and _has_random_transform(body)) or helper_call):
            continue
        security_effect = bool(re.search(
            r"\b(answer|winner|random|rand|index|payout|paid|balance|entry|ticket|pot)\b|"
            r"\[[^\]]+\]\s*=|\b(return|send|transfer)\b|=",
            body,
        ))
        if not security_effect:
            continue
        line = block["line"]
        findings.append(_new_finding(
            source_path=source_path,
            contract_name=contract_name,
            classification_key="bad_randomness_dependency",
            line=line,
            source_code=_line_text(source, line),
            evidence={
                "function": name,
                "constructor": is_constructor,
                "random_helpers": sorted(random_helpers),
                "reason": "environmental randomness controls persistent state or payout selection",
            },
        ))
    return findings


def _detect_approve_race(source: str, stripped: str, source_path: Path, contract_name: str) -> List[Dict[str, Any]]:
    findings: List[Dict[str, Any]] = []
    for block in _function_blocks(stripped):
        if block["name"] != "approve":
            continue
        body = block["body"]
        header = block["header"]
        if not re.search(r"\baddress\b", header) or not re.search(r"\buint", header):
            continue
        writes_allowance = bool(re.search(r"\b(_?allowed|allowance|allowed)\s*\[[^\]]+\]\s*\[[^\]]+\]\s*=", body))
        has_zero_guard = bool(re.search(r"(==\s*0|value\s*==\s*0|_value\s*==\s*0).{0,80}(==\s*0|allowance|allowed)", body, flags=re.S))
        if writes_allowance and not has_zero_guard:
            line = block["line"]
            findings.append(_new_finding(
                source_path=source_path,
                contract_name=contract_name,
                classification_key="approve_race",
                line=line,
                source_code=_line_text(source, line),
                evidence={
                    "function": "approve",
                    "reason": "allowance is overwritten without zero-reset guard",
                },
            ))
    return findings


def _detect_failed_refund_dos(source: str, stripped: str, source_path: Path, contract_name: str) -> List[Dict[str, Any]]:
    findings: List[Dict[str, Any]] = []
    pattern = re.compile(r"\brequire\s*\(\s*[^;\n]*\.send\s*\([^)]*\)\s*\)", re.S)
    for match in pattern.finditer(stripped):
        line = _line_number(stripped, match.start())
        findings.append(_new_finding(
            source_path=source_path,
            contract_name=contract_name,
            classification_key="failed_refund_dos",
            line=line,
            source_code=_line_text(source, line),
            evidence={
                "pattern": match.group(0).strip(),
                "reason": "send return is required, so receiver failure can block progress",
            },
        ))
    return findings


def _detect_unchecked_returns(source: str, stripped: str, source_path: Path, contract_name: str) -> List[Dict[str, Any]]:
    findings: List[Dict[str, Any]] = []
    lines = stripped.splitlines()
    for idx, line_text in enumerate(lines, start=1):
        if not re.search(r"\.(send|call|delegatecall)\s*(\.value\s*\([^)]*\))?\s*\(", line_text):
            continue
        if re.search(r"\brequire\s*\(|\bassert\s*\(|\bif\s*\(", line_text):
            continue
        assigned = re.search(r"\bbool\s+([A-Za-z_][A-Za-z0-9_]*)\s*=", line_text)
        if assigned:
            var = assigned.group(1)
            tail = "\n".join(lines[idx: min(len(lines), idx + 12)])
            if re.search(r"\b(if|require|assert)\s*\([^)]*\b%s\b" % re.escape(var), tail):
                continue
        findings.append(_new_finding(
            source_path=source_path,
            contract_name=contract_name,
            classification_key="unchecked_return_value",
            line=idx,
            source_code=_line_text(source, idx),
            evidence={
                "pattern": line_text.strip(),
                "reason": "low-level call return is not checked before execution continues",
            },
        ))
    return findings


def detect_static_source_findings(*, source_path: Path, contract_name: str) -> Dict[str, Any]:
    """Detect source-backed findings without writing or processing report artifacts."""
    source_path = Path(source_path)
    try:
        source = source_path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return {"findings": [], "reason": "source_read_failed"}
    stripped = _strip_comments(source)
    detectors = [
        _detect_randomness,
        _detect_approve_race,
        _detect_failed_refund_dos,
        _detect_unchecked_returns,
    ]
    findings: List[Dict[str, Any]] = []
    for detector in detectors:
        findings.extend(detector(source, stripped, source_path, contract_name))
    return {
        "findings": findings,
        "kinds": sorted({(item.get("classification") or {}).get("kind") for item in findings}),
    }


def emit_static_source_findings(
    *,
    source_path: Path,
    contract_name: str,
    meta_dir: Path,
    validate_minimization: Optional[bool] = None,
    minimization_timeout: Optional[int] = None,
    fp_filter_mode: Optional[str] = None,
) -> Dict[str, Any]:
    source_path = Path(source_path)
    meta_dir = Path(meta_dir)
    detection = detect_static_source_findings(source_path=source_path, contract_name=contract_name)
    findings = detection["findings"]
    if not findings:
        return {"emitted": 0, **({"reason": detection["reason"]} if detection.get("reason") else {})}

    raw_dir = meta_dir / "finding_cases"
    raw_dir.mkdir(parents=True, exist_ok=True)
    for finding in findings:
        fname = f"{finding['id']}_{finding['classification']['kind']}.json"
        out_path = raw_dir / fname
        finding.setdefault("artifacts", {})["json"] = str(out_path)
        _write_path(out_path).write_text(json.dumps(finding, indent=2, ensure_ascii=False), encoding="utf-8")
    process_finding_cases(
        raw_dir,
        validate_minimization=validate_minimization,
        minimization_timeout=minimization_timeout,
        fp_filter_mode=fp_filter_mode,
    )
    return {
        "emitted": len(findings),
        "kinds": sorted({(item.get("classification") or {}).get("kind") for item in findings}),
    }
