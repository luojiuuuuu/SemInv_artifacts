#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
import tempfile
import time
from functools import lru_cache
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from ..invariants.benchmark_taxonomy import SIX_INVARIANT_FAMILIES, enrich_classification

SCHEMA_VERSION = "semantic-invariant.finding.v1"
LEGACY_SCHEMA_VERSION = "con-fuzzius.finding.v1"
VIOLATION_EVENT_SCHEMA_VERSION = "semantic-invariant.violation_event.v1"
LEGACY_VIOLATION_EVENT_SCHEMA_VERSION = "con-fuzzius.violation_event.v1"
HYBRID_REPLAY_SCHEMA_VERSION = "semantic-invariant.hybrid_replay.v1"
LEGACY_HYBRID_REPLAY_SCHEMA_VERSION = "con-fuzzius.hybrid_replay.v1"
SEMANTIC_REPORT_SCHEMA_VERSION = "semantic-invariant.report.v1"
FP_FILTER_OFF = "off"
FP_FILTER_EVIDENCE_SAFE = "evidence-safe"
FP_FILTER_MODES = (FP_FILTER_OFF, FP_FILTER_EVIDENCE_SAFE)


def _filesystem_path(path: Path) -> Path:
    resolved = str(Path(path).resolve())
    if os.name != "nt" or resolved.startswith("\\\\?\\"):
        return Path(resolved)
    if resolved.startswith("\\\\"):
        return Path("\\\\?\\UNC\\" + resolved.lstrip("\\"))
    return Path("\\\\?\\" + resolved)


def _write_text(path: Path, content: str) -> None:
    destination = _filesystem_path(path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=str(destination.parent),
                                         prefix=".seminv-", suffix=".tmp", delete=False) as handle:
            temporary = Path(handle.name)
            handle.write(content)
        os.replace(str(temporary), str(destination))
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()
_FOUNDRY_SEQ_LINE_RE = re.compile(
    r"sender=(?P<sender>\S+)\s+addr=(?P<addr>\S+)\s+calldata=(?P<calldata>\S+)\s+args=(?P<args>\[.*\])",
    re.IGNORECASE,
)
_TRACE_HANDLER_CALL_RE = re.compile(
    r"\]\s+(?P<handler>[A-Za-z_][A-Za-z0-9_]*Handler)(?::\s*\[(?P<addr>0x[0-9A-Fa-f]{40})\])?::"
    r"(?P<call>call_[A-Za-z0-9_]+)\((?P<args>.*)\)"
)


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


def _safe_filename(name: str) -> str:
    value = str(name or "").strip()
    if not value:
        return "unknown"
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", value)


def _stable_id(payload: Dict[str, Any]) -> str:
    raw = json.dumps(payload, sort_keys=True, ensure_ascii=True, default=str)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()[:24]


def _stable_key(parts: List[Any]) -> str:
    return "|".join(str(p) for p in parts if p is not None and str(p) != "")


def _count_by(items: List[Dict[str, Any]], getter) -> Dict[str, int]:
    counts: Dict[str, int] = {}
    for item in items or []:
        key = getter(item)
        key = str(key or "unknown")
        counts[key] = counts.get(key, 0) + 1
    return dict(sorted(counts.items()))


def normalize_fp_filter_mode(value: Any) -> str:
    text = str(value or FP_FILTER_OFF).strip().lower().replace("_", "-")
    aliases = {
        "0": FP_FILTER_OFF,
        "false": FP_FILTER_OFF,
        "disabled": FP_FILTER_OFF,
        "1": FP_FILTER_EVIDENCE_SAFE,
        "true": FP_FILTER_EVIDENCE_SAFE,
        "on": FP_FILTER_EVIDENCE_SAFE,
        "safe": FP_FILTER_EVIDENCE_SAFE,
    }
    text = aliases.get(text, text)
    if text not in FP_FILTER_MODES:
        raise ValueError(
            "unsupported FP filter mode %r; expected one of %s"
            % (value, ", ".join(FP_FILTER_MODES))
        )
    return text


def fp_filter_decision(event: Dict[str, Any], mode: Any = FP_FILTER_OFF) -> Dict[str, Any]:
    """Return a report-only retention decision for one violation event."""
    normalized_mode = normalize_fp_filter_mode(mode)
    if normalized_mode == FP_FILTER_OFF:
        return {"retain": True, "reason": "filter_disabled", "rule_id": None}

    evidence = event.get("reporting_evidence") or {}
    if (
        evidence.get("pattern_id") == "withdraw_guard_direction"
        and evidence.get("applicability") == "false"
        and evidence.get("report_disposition") == "counterevidence"
    ):
        return {
            "retain": False,
            "reason": "the recovered guard contradicts the reversed-withdraw-guard diagnostic",
            "rule_id": "R1.withdraw_guard_counterevidence",
        }

    if (
        str(event.get("origin") or "").startswith("foundry")
        and evidence.get("check_ref")
        and evidence.get("observation_status") == "predicate_passed"
        and evidence.get("evidence_mode") == "same_check"
    ):
        return {
            "retain": False,
            "reason": "the uniquely matched generated predicate evaluated to true",
            "rule_id": "R2.executed_check_passed",
        }

    classification = event.get("classification") or {}
    if (
        classification.get("kind") == "unchecked_return_value"
        and evidence.get("pattern_id") == "low_level_return_handling"
        and evidence.get("return_handling") == "checked_by_branch"
        and evidence.get("report_disposition") == "counterevidence"
    ):
        return {
            "retain": False,
            "reason": "the low-level call result is consumed directly by a conditional check",
            "rule_id": "R4.checked_low_level_return",
        }

    trigger_detail = (((event.get("violation") or {}).get("trigger") or {}).get("detail") or {})
    detector_summary = str((trigger_detail.get("classification") or {}).get("summary") or "").strip()
    if (
        classification.get("kind") == "access_noninterference"
        and detector_summary == "Successful execution of an unguarded sensitive function"
    ):
        return {
            "retain": False,
            "reason": "successful execution alone does not establish a protected-state authorization violation",
            "rule_id": "R3.generic_sensitive_execution_only",
        }

    return {"retain": True, "reason": "no_safe_suppression_rule_matched", "rule_id": None}


def apply_fp_filter(events: List[Dict[str, Any]], mode: Any = FP_FILTER_OFF) -> Dict[str, Any]:
    normalized_mode = normalize_fp_filter_mode(mode)
    retained: List[Dict[str, Any]] = []
    suppressed: List[Dict[str, Any]] = []
    for event in events or []:
        decision = fp_filter_decision(event, normalized_mode)
        if decision["retain"]:
            retained.append(event)
            continue
        suppressed.append({
            "event_id": event.get("event_id"),
            "finding_id": event.get("finding_id"),
            "semantic_fingerprint": event.get("semantic_fingerprint"),
            "origin": event.get("origin"),
            "kind": (event.get("classification") or {}).get("kind"),
            "rule_id": decision.get("rule_id"),
            "reason": decision.get("reason"),
        })
    return {
        "mode": normalized_mode,
        "input_event_count": len(events or []),
        "reported_event_count": len(retained),
        "suppressed_event_count": len(suppressed),
        "suppressed_by_rule": _count_by(suppressed, lambda item: item.get("rule_id")),
        "events": retained,
        "suppressed": suppressed,
    }


def _family_code(category: Any, invariant_id: Any = None) -> str:
    text = str(category or "")
    if text.startswith("I") and "_" in text:
        return text.split("_", 1)[0]
    inv = str(invariant_id or "")
    m = re.match(r"^(I[1-6])\.", inv)
    return m.group(1) if m else "I?"


def _backend_display_name(backend: Any) -> str:
    backend = str(backend or "unknown")
    return {
        "foundry": "Foundry Property Backend",
        "fuzz": "Semantic Fuzz Backend",
        "fuzzer_detector": "Semantic Fuzz Backend",
        "detector": "Semantic Fuzz Backend",
        "unknown": "Unknown Backend",
    }.get(backend, backend)


def _kind_label(kind: Any) -> str:
    text = str(kind or "violation").replace("_", " ").strip()
    return " ".join(part[:1].upper() + part[1:] for part in text.split())


def _semantic_summary(classification: Dict[str, Any], backend: Any = None) -> str:
    family = classification.get("invariant_family") or "Semantic Invariant"
    category = classification.get("invariant_category")
    invariant_id = classification.get("invariant_id")
    code = _family_code(category, invariant_id)
    kind = _kind_label(classification.get("kind") or classification.get("type"))
    backend_name = _backend_display_name(backend or classification.get("primary_backend"))
    return "%s %s violation: %s observed by %s" % (code, family, kind, backend_name)


def _semantic_display(classification: Dict[str, Any], backend: Any = None) -> Dict[str, Any]:
    category = classification.get("invariant_category")
    invariant_id = classification.get("invariant_id")
    code = _family_code(category, invariant_id)
    family = classification.get("invariant_family") or "Semantic Invariant"
    family_meta = SIX_INVARIANT_FAMILIES.get(str(category or ""))
    family_zh = (family_meta or {}).get("zh") or classification.get("invariant_family_zh")
    kind = classification.get("kind") or classification.get("type") or "violation"
    backend_name = _backend_display_name(backend or classification.get("primary_backend"))
    title = "%s %s: %s Violation" % (code, family, _kind_label(kind))
    return {
        "title": title,
        "summary": _semantic_summary(classification, backend=backend),
        "invariant_code": code,
        "invariant_id": invariant_id,
        "invariant_family": family,
        "invariant_family_zh": family_zh,
        "backend": backend or classification.get("primary_backend"),
        "backend_label": backend_name,
        "trigger_templates": classification.get("trigger_templates") or [],
        "benchmark_labels": classification.get("benchmark_labels") or [],
        "legacy": {
            "type": classification.get("type"),
            "swc_id": classification.get("swc_id"),
            "family": classification.get("family"),
        },
    }


def _normalize_classification_display(classification: Dict[str, Any], backend: Any = None) -> Dict[str, Any]:
    out = dict(classification or {})
    disable_label_preservation = os.environ.get(
        "SEMINV_ABLATION_NO_LABEL_PRESERVATION",
        "",
    ).strip().lower() in {"1", "true", "yes", "on"}
    if disable_label_preservation:
        out.pop("benchmark_labels", None)
        out.pop("trigger_templates", None)
    family_meta = SIX_INVARIANT_FAMILIES.get(str(out.get("invariant_category") or ""))
    if family_meta:
        out["invariant_family"] = family_meta.get("name") or out.get("invariant_family")
        out["invariant_family_zh"] = family_meta.get("zh") or out.get("invariant_family_zh")
        out["primary_backend"] = out.get("primary_backend") or family_meta.get("primary_backend")
    if out.get("invariant_id") or out.get("invariant_family"):
        out["summary"] = _semantic_summary(out, backend=backend)
    out["display"] = _semantic_display(out, backend=backend)
    return out


def _selector_from_data(data: Any) -> str:
    if data is None:
        return ""
    text = str(data)
    if text.startswith("0x"):
        return text[:10] if len(text) >= 10 else text
    if re.match(r"^[A-Za-z_][A-Za-z0-9_]*\s*(?:\(|$)", text):
        return ""
    return "0x" + text[:8] if len(text) >= 8 else text


def _normalize_selector(selector: Any) -> str:
    text = str(selector or "").strip()
    if not text:
        return ""
    if text.startswith("0x"):
        return text[:10] if len(text) >= 10 else text
    if re.fullmatch(r"[0-9A-Fa-f]{8}", text):
        return "0x" + text
    return text


def _signature_types_from_source_arglist(arglist: str) -> str:
    types: List[str] = []
    for raw_arg in (arglist or "").split(","):
        arg = raw_arg.strip()
        if not arg:
            continue
        parts = [
            p for p in re.split(r"\s+", arg)
            if p and p not in ("memory", "storage", "calldata", "payable")
        ]
        if not parts:
            continue
        typ = parts[0]
        if len(parts) >= 2 and parts[1].startswith("["):
            typ += parts[1]
        types.append(typ)
    return ",".join(types)


def _signature_arg_types(signature: Any) -> List[str]:
    text = str(signature or "").strip()
    if "(" not in text or ")" not in text:
        return []
    inner = text.split("(", 1)[1].rsplit(")", 1)[0].strip()
    if not inner:
        return []
    types: List[str] = []
    current: List[str] = []
    depth = 0
    for ch in inner:
        if ch == "," and depth == 0:
            item = "".join(current).strip()
            if item:
                types.append(item)
            current = []
            continue
        if ch in "([":
            depth += 1
        elif ch in ")]" and depth > 0:
            depth -= 1
        current.append(ch)
    item = "".join(current).strip()
    if item:
        types.append(item)
    return types


def _decode_calldata_args(signature: Any, calldata: Any) -> List[Any]:
    types = _signature_arg_types(signature)
    text = str(calldata or "").strip()
    if not types or not text.startswith("0x") or len(text) < 10:
        return []
    payload = text[10:]
    if not payload:
        return []
    try:
        from eth_abi import decode as abi_decode
        values = abi_decode(types, bytes.fromhex(payload))
    except Exception:
        return []
    out: List[Any] = []
    for value in values:
        if isinstance(value, (bytes, bytearray)):
            out.append("0x" + bytes(value).hex())
        elif isinstance(value, tuple):
            out.append(_jsonable(list(value)))
        else:
            out.append(_jsonable(value))
    return out


def _keccak_selector(signature: str) -> Optional[str]:
    try:
        from eth_utils import keccak
        return "0x" + keccak(text=signature)[0:4].hex()
    except Exception:
        return None


def _selector_signature_map_from_source(source_path: Any) -> Dict[str, str]:
    if not source_path:
        return {}
    path = Path(str(source_path))
    if not path.exists():
        return {}
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return {}

    mapping: Dict[str, str] = {}
    func_re = re.compile(
        r"\bfunction\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*\((?P<args>[^)]*)\)",
        re.MULTILINE,
    )
    for m in func_re.finditer(text):
        sig = "%s(%s)" % (
            m.group("name"),
            _signature_types_from_source_arglist(m.group("args")),
        )
        selector = _keccak_selector(sig)
        if selector:
            mapping[selector] = sig
            mapping[selector.replace("0x", "")] = sig
    return mapping


def _enrich_trajectory_selectors(
    trajectory: Dict[str, Any],
    selector_to_signature: Optional[Dict[str, str]] = None,
) -> Dict[str, Any]:
    out = json.loads(json.dumps(trajectory or {}, ensure_ascii=False))
    sigs = selector_to_signature or {}
    for section in ("setup", "steps"):
        for step in out.get(section) or []:
            selector = _normalize_selector(step.get("selector")) or _selector_from_data(step.get("calldata"))
            selector = _normalize_selector(selector)
            if selector:
                step["selector"] = selector
            if not step.get("signature") and selector:
                step["signature"] = sigs.get(selector) or sigs.get(selector.replace("0x", ""))
            if not step.get("signature"):
                foundry_sig = _signature_from_foundry_calldata(step.get("calldata"))
                if foundry_sig:
                    step["signature"] = foundry_sig
            if not step.get("args") and step.get("signature"):
                decoded_args = _decode_calldata_args(step.get("signature"), step.get("calldata"))
                if decoded_args:
                    step["args"] = decoded_args
    return out


def _signature_from_foundry_calldata(calldata: Any) -> Optional[str]:
    text = str(calldata or "").strip()
    if not text or text.startswith("0x"):
        return None
    return text


def _args_from_foundry_step(step: Dict[str, Any]) -> Any:
    args = step.get("args")
    if args is None:
        return []
    if isinstance(args, list):
        return args
    text = str(args).strip()
    if not text:
        return []
    return text


def _source_sibling_meta_dir(source_path: Optional[Any], contract_name: Optional[str]) -> Optional[Path]:
    if not source_path:
        return None
    try:
        source = Path(str(source_path))
    except Exception:
        return None
    if not str(source).strip():
        return None
    name = Path(str(contract_name or source.stem or "contract")).stem
    parent = source.parent if str(source.parent) not in ("", ".") else Path.cwd()
    return parent / f"{name}_meta"


def _contract_meta_dir(contract_name: Optional[str], source_path: Optional[Any] = None) -> Path:
    source_meta = _source_sibling_meta_dir(source_path, contract_name)
    if source_meta is not None:
        return source_meta
    name = Path(str(contract_name or "contract")).stem
    return Path.cwd() / f"{name}_meta"


def _canonical_contract_meta_dir(contract_name: Optional[str], source_path: Optional[Any] = None) -> Path:
    return _contract_meta_dir(contract_name, source_path=source_path)


def _contract_name_from_meta_dir(meta_dir: Optional[Path], fallback: Optional[str] = None) -> str:
    if fallback:
        return Path(str(fallback)).stem
    if meta_dir is None:
        return "contract"

    path = Path(meta_dir)
    for part in reversed(path.parts):
        if part.endswith("_meta"):
            return part[:-5] or "contract"
    name = path.name
    if name in ("functional_test", "invariant_test") and path.parent.name.endswith("_meta"):
        return path.parent.name[:-5] or "contract"
    return name.replace("_meta", "") or "contract"


def _source_location(source_map: Any, pc: Any, error: Dict[str, Any]) -> Dict[str, Any]:
    loc: Dict[str, Any] = {
        "pc": pc,
        "file": None,
        "line": error.get("line"),
        "column": error.get("column"),
        "source_code": error.get("source_code"),
    }
    try:
        if source_map is not None and getattr(source_map, "source", None) is not None:
            loc["file"] = getattr(source_map.source, "filename", None)
    except Exception:
        pass
    return loc


def _function_sequence(trajectory: Dict[str, Any]) -> List[str]:
    seq: List[str] = []
    for step in trajectory.get("steps") or []:
        sig = step.get("signature") or step.get("selector") or step.get("calldata")
        if sig:
            seq.append(str(sig).split("[", 1)[0].strip())
    return seq


def _split_trace_call_args(line: str, call_name: str) -> Optional[List[str]]:
    """Return top-level call arguments without interpreting arbitrary expressions."""
    marker = "%s(" % call_name
    start = str(line).find(marker)
    if start < 0:
        return None
    index = start + len(marker)
    depth = 0
    quote: Optional[str] = None
    escaped = False
    current: List[str] = []
    args: List[str] = []
    while index < len(line):
        char = line[index]
        index += 1
        if quote is not None:
            current.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in ('"', "'"):
            quote = char
            current.append(char)
        elif char in "([{":
            depth += 1
            current.append(char)
        elif char in ")]}" and depth:
            depth -= 1
            current.append(char)
        elif char == ")" and depth == 0:
            args.append("".join(current).strip())
            return args
        elif char == "," and depth == 0:
            args.append("".join(current).strip())
            current = []
        else:
            current.append(char)
    return None


def _trace_literal(value: str) -> Tuple[bool, Any]:
    text = str(value or "").strip()
    lowered = text.lower()
    if lowered == "true":
        return True, True
    if lowered == "false":
        return True, False
    if re.fullmatch(r"-?\d+", text):
        try:
            return True, int(text, 10)
        except ValueError:
            return False, None
    if re.fullmatch(r"0x[0-9a-fA-F]+", text):
        try:
            return True, int(text, 16)
        except ValueError:
            return False, None
    if len(text) >= 2 and text[0] == text[-1] and text[0] in ('"', "'"):
        return True, text[1:-1]
    return False, None


def _assert_values(lines: List[str]) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for line in lines or []:
        args = _split_trace_call_args(line, "assertEq")
        if args is not None and len(args) >= 2:
            left_known, left_value = _trace_literal(args[0])
            right_known, right_value = _trace_literal(args[1])
            outcome = "unknown"
            if left_known and right_known:
                outcome = "passed" if left_value == right_value else "failed"
            out.append({
                "kind": "assertEq",
                "left": args[0],
                "right": args[1],
                "outcome": outcome,
                "raw": line,
            })
            continue
        args = _split_trace_call_args(line, "assertTrue")
        if args is not None and args:
            known, value = _trace_literal(args[0])
            outcome = "passed" if known and value is True else "failed" if known and value is False else "unknown"
            out.append({
                "kind": "assertTrue",
                "expr": args[0],
                "outcome": outcome,
                "raw": line,
            })
    return out


def _read_json_file(path: Path) -> Optional[Dict[str, Any]]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None
    return data if isinstance(data, dict) else None


def _load_static_analysis(
    meta_dir: Optional[Path],
    contract_name: Optional[str] = None,
    *,
    allow_fallback: bool = True,
) -> Dict[str, Any]:
    candidates: List[Path] = []
    if meta_dir is not None:
        root = Path(meta_dir)
        candidates += [root / "analysis.json", root / "baseline_analysis.json"]

    contract = Path(str(contract_name or "")).stem
    if contract and allow_fallback:
        cwd = Path.cwd()
        candidates += [
            cwd / "foundry" / f"{contract}_meta" / "invariant_test" / "analysis.json",
            cwd / "foundry" / f"{contract}_meta" / "functional_test" / "analysis.json",
            cwd / "debug_out" / contract / "baseline_analysis.json",
            cwd / f"{contract}_meta" / "analysis.json",
            cwd / f"{contract}_meta" / "baseline_analysis.json",
        ]

    seen = set()
    for path in candidates:
        key = str(path)
        if key in seen:
            continue
        seen.add(key)
        data = _read_json_file(path)
        if data:
            artifact_contract = Path(str((data.get("meta") or {}).get("contract_name") or "")).stem
            if contract and artifact_contract and artifact_contract != contract:
                continue
            data.setdefault("_artifact_path", str(path))
            return data
    return {}


class _ReportContext:
    """Batch-local artifact view used to avoid cross-run evidence upgrades."""

    def __init__(self, meta_dir: Optional[Path], contract_name: Optional[str] = None):
        self.meta_dir = Path(meta_dir) if meta_dir is not None else None
        self.analysis = _load_static_analysis(
            self.meta_dir,
            contract_name=contract_name,
            allow_fallback=False,
        )
        self.check_catalog = list(self.analysis.get("check_catalog") or [])
        self._checks_by_test: Dict[Tuple[str, str], List[Dict[str, Any]]] = {}
        for item in self.check_catalog:
            site = item.get("site") or {}
            key = (str(site.get("suite")), str(site.get("test")))
            self._checks_by_test.setdefault(key, []).append(item)
        self._trace_text_cache: Dict[str, str] = {}

    def read_trace(self, path: Path) -> str:
        key = str(Path(path).resolve())
        if key not in self._trace_text_cache:
            self._trace_text_cache[key] = Path(path).read_text(encoding="utf-8", errors="ignore")
        return self._trace_text_cache[key]

    def resolve_check(self, suite: Any, test_name: Any) -> Dict[str, Any]:
        matches = self._checks_by_test.get((str(suite), str(test_name)), [])
        if len(matches) == 1:
            return {"status": "resolved", "descriptor": matches[0], "match_count": 1}
        return {
            "status": "ambiguous" if matches else "missing",
            "descriptor": None,
            "match_count": len(matches),
        }


def _function_name_from_signature(value: Any) -> Optional[str]:
    text = str(value or "").strip()
    if not text:
        return None
    text = text.split("[", 1)[0].strip()
    name = text.split("(", 1)[0].strip()
    if not name:
        return None
    if name.startswith("call_"):
        name = name[5:]
    if name in ("receive", "fallback"):
        return "__receive__"
    return name


def _trigger_functions_from_trajectory(trajectory: Dict[str, Any]) -> List[Dict[str, Any]]:
    seen = set()
    out: List[Dict[str, Any]] = []
    for step in trajectory.get("steps") or []:
        identity = step.get("signature") or step.get("calldata") or step.get("selector")
        raw_name = _function_name_from_signature(identity)
        if not raw_name:
            continue
        key = (str(identity), raw_name)
        if key in seen:
            continue
        seen.add(key)
        out.append({
            "step_index": step.get("index"),
            "call": identity,
            "function": raw_name,
            "source": step.get("source"),
        })
    return out


def _analysis_storage_names(analysis: Dict[str, Any]) -> List[str]:
    storage = analysis.get("storage") or {}
    if isinstance(storage, dict):
        return [str(k) for k in storage.keys()]
    return []


def _infer_property_expression(
    classification: Dict[str, Any],
    trigger: Dict[str, Any],
    analysis: Dict[str, Any],
    check_descriptor: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    kind = classification.get("kind")
    family = classification.get("family")
    targets = (trigger.get("detail") or {}).get("targets") or {}
    storage = analysis.get("storage") or {}

    if check_descriptor:
        bindings = check_descriptor.get("bindings") or {}
        state_variables = []
        for key in (
            "account_getter",
            "aggregate_getter",
            "state_getter",
            "protected_getter",
            "account_storage",
            "aggregate_storage",
            "state_variable",
            "tracked_storage",
        ):
            value = bindings.get(key)
            if value:
                state_variables.append(str(value).split("(", 1)[0])
        return {
            "name": check_descriptor.get("template") or check_descriptor.get("rule_id"),
            "expression": check_descriptor.get("predicate"),
            "state_variables": list(dict.fromkeys(state_variables)),
            "source": "executed_check_catalog",
            "check_ref": check_descriptor.get("check_ref"),
            "bindings": bindings,
            "spec_basis": check_descriptor.get("spec_basis") or {},
        }

    if kind == "sum_equals_supply":
        mappings = [
            name for name, meta in storage.items()
            if isinstance(meta, dict) and meta.get("is_mapping") and meta.get("is_uint")
        ]
        supply_names = [
            name for name, meta in storage.items()
            if isinstance(meta, dict)
            and not meta.get("is_mapping")
            and meta.get("is_uint")
            and "supply" in str(name).lower()
        ]
        lhs = " + ".join("sum(%s[observed_actors])" % name for name in mappings) or "sum(mapping[observed_actors])"
        rhs = supply_names[0] if supply_names else "aggregate_supply"
        return {
            "name": kind or family,
            "expression": "%s == %s" % (lhs, rhs),
            "state_variables": mappings + supply_names,
            "source": "classification+static_analysis",
        }

    if family in ("accounting", "accounting_anomaly"):
        return {
            "name": kind or family,
            "expression": None,
            "state_variables": [],
            "source": "unresolved",
            "resolution_reason": "No unique generated-check descriptor matched this finding; the accounting family alone does not determine a predicate.",
        }

    if kind == "terminal_no_rollback":
        state_var = targets.get("state_var") or "state"
        return {
            "name": kind,
            "expression": "%s must not move from a terminal value back to an earlier value" % state_var,
            "state_variables": [state_var],
            "source": "classification+trigger_targets",
        }

    return {
        "name": kind or family or classification.get("type"),
        "expression": classification.get("summary"),
        "state_variables": [str(v) for v in targets.values() if isinstance(v, str)],
        "source": "classification",
    }


def _related_state_variables(
    classification: Dict[str, Any],
    trigger: Dict[str, Any],
    analysis: Dict[str, Any],
    function_names: List[str],
) -> List[str]:
    related = []
    prop = _infer_property_expression(classification, trigger, analysis)
    for name in prop.get("state_variables") or []:
        if name and name not in related:
            related.append(str(name))

    dfg = analysis.get("dfg") or {}
    for fn in function_names:
        facts = dfg.get(fn) or {}
        for field in ("reads", "writes"):
            for name in facts.get(field) or []:
                if name and name not in related:
                    related.append(str(name))

    known = set(_analysis_storage_names(analysis))
    return [name for name in related if not known or name in known]


def _static_facts_for_functions(
    analysis: Dict[str, Any],
    function_names: List[str],
    related_state: List[str],
) -> List[Dict[str, Any]]:
    dfg = analysis.get("dfg") or {}
    updates = analysis.get("update_facts") or []
    related = set(related_state or [])
    out: List[Dict[str, Any]] = []
    seen = set()

    for fn in function_names:
        if not fn or fn in seen:
            continue
        seen.add(fn)
        rw = dfg.get(fn) or {}
        fn_updates = [
            {
                "target": item.get("target"),
                "target_kind": item.get("target_kind"),
                "op": item.get("op"),
                "delta": item.get("delta"),
                "assigned_value": item.get("assigned_value"),
                "index_expr": item.get("index_expr"),
                "raw": item.get("raw"),
                "source": item.get("source"),
            }
            for item in updates
            if isinstance(item, dict) and item.get("function") == fn
        ]
        writes = [str(v) for v in (rw.get("writes") or [])]
        reads = [str(v) for v in (rw.get("reads") or [])]
        fact: Dict[str, Any] = {
            "function": fn,
            "reads": reads,
            "writes": writes,
            "updates": fn_updates,
            "evidence_source": "static_analysis",
        }
        if related:
            fact["writes_related_state"] = [name for name in writes if name in related]
            fact["related_state_not_written"] = [name for name in related if name not in writes]
        out.append(fact)
    return out


def _merge_source_location_updates(
    static_facts: List[Dict[str, Any]],
    location: Dict[str, Any],
    related_state: List[str],
    function_names: List[str],
) -> List[Dict[str, Any]]:
    source_code = str((location or {}).get("source_code") or "")
    if not source_code or not related_state or not function_names:
        return static_facts

    out = json.loads(json.dumps(static_facts, ensure_ascii=False))
    by_function = {item.get("function"): item for item in out if isinstance(item, dict)}
    for fn in function_names:
        fact = by_function.get(fn)
        if fact is None:
            fact = {
                "function": fn,
                "reads": [],
                "writes": [],
                "updates": [],
                "evidence_source": "source_location",
            }
            out.append(fact)
            by_function[fn] = fact

        writes = list(fact.get("writes") or [])
        updates = list(fact.get("updates") or [])
        for var in related_state:
            pattern = re.escape(str(var))
            op = None
            if re.search(pattern + r"\s*\.\s*push\s*\(", source_code):
                op = "push"
            elif re.search(pattern + r"\s*(?:\[[^\]]+\]\s*)?\+=", source_code):
                op = "add"
            elif re.search(pattern + r"\s*(?:\[[^\]]+\]\s*)?-=", source_code):
                op = "sub"
            elif re.search(pattern + r"\s*(?:\[[^\]]+\]\s*)?=", source_code):
                op = "assign"
            if not op:
                continue
            if var not in writes:
                writes.append(var)
            if not any(item.get("target") == var and item.get("source") == "source_location" for item in updates):
                updates.append({
                    "target": var,
                    "target_kind": "unknown",
                    "op": op,
                    "delta": None,
                    "assigned_value": None,
                    "index_expr": None,
                    "raw": source_code,
                    "source": "source_location",
                    "file": location.get("file"),
                    "line": location.get("line"),
                })

        fact["writes"] = writes
        fact["updates"] = updates
        if related_state:
            fact["writes_related_state"] = [name for name in writes if name in set(related_state)]
            fact["related_state_not_written"] = [name for name in related_state if name not in writes]
    return out


def _dynamic_facts_from_finding(finding: Dict[str, Any]) -> List[Dict[str, Any]]:
    trajectory = finding.get("trajectory") or {}
    trace = finding.get("trace") or {}
    out: List[Dict[str, Any]] = []
    for step in trajectory.get("steps") or []:
        out.append({
            "kind": "transaction_step",
            "step_index": step.get("index"),
            "call": step.get("signature") or step.get("calldata") or step.get("selector"),
            "args": step.get("args"),
            "from": step.get("from"),
            "to": step.get("to"),
            "source": step.get("source"),
        })
    assertions = _assert_values(trace.get("assert_lines") or [])
    if assertions:
        out.append({"kind": "assertion_observation", "assertions": assertions})
    if trace.get("revert_detected"):
        out.append({
            "kind": "revert",
            "lines": trace.get("revert_lines") or [],
        })
    return out


def _evidence_chain(
    finding: Dict[str, Any],
    static_facts: List[Dict[str, Any]],
    dynamic_facts: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    classification = finding.get("classification") or {}
    chain = [
        {
            "kind": "violated_property",
            "summary": classification.get("summary"),
            "family": classification.get("family"),
            "invariant_kind": classification.get("kind"),
        }
    ]
    if dynamic_facts:
        chain.append({
            "kind": "fuzzing_trace",
            "summary": "The minimized trajectory and observed assertion or revert lines record the executed outcome.",
            "facts": dynamic_facts,
        })
    if static_facts:
        chain.append({
            "kind": "static_analysis",
            "summary": "Read/write and update facts identify which state variables the trigger functions modify.",
            "facts": static_facts,
        })
    return chain


def _check_evidence_fields(
    finding: Dict[str, Any],
    report_context: Optional[_ReportContext],
) -> Dict[str, Any]:
    detail = ((finding.get("trigger") or {}).get("detail") or {})
    resolution = report_context.resolve_check(detail.get("suite"), detail.get("test_name")) if report_context else {
        "status": "missing",
        "descriptor": None,
        "match_count": 0,
    }
    descriptor = resolution.get("descriptor")
    assert_lines = ((finding.get("trace") or {}).get("assert_lines") or [])
    parsed_assertions = _assert_values(assert_lines)
    expected_assertion_kind = descriptor.get("assertion_kind") if descriptor else None
    matched_assertions = (
        [item for item in parsed_assertions if item.get("kind") == expected_assertion_kind]
        if expected_assertion_kind
        else parsed_assertions
    )
    reason = str((finding.get("trigger") or {}).get("failure_reason") or "").lower()
    revert_detected = bool((finding.get("trace") or {}).get("revert_detected"))

    failed_assertions = [item for item in matched_assertions if item.get("outcome") == "failed"]
    passed_assertions = [item for item in matched_assertions if item.get("outcome") == "passed"]
    unknown_assertions = [item for item in matched_assertions if item.get("outcome") == "unknown"]

    if descriptor and failed_assertions:
        observation_status = "predicate_failed"
        evidence_mode = "same_check"
        interpretation_reason = "The uniquely matched generated check site contains an assertion whose concrete operands evaluate to false."
    elif descriptor and matched_assertions and passed_assertions and not unknown_assertions:
        observation_status = "predicate_passed"
        evidence_mode = "same_check"
        interpretation_reason = "Every parsed assertion observed at the uniquely matched generated check site evaluates to true."
    elif descriptor and matched_assertions:
        observation_status = "ambiguous"
        evidence_mode = "same_category"
        interpretation_reason = "The generated check site matched, but at least one assertion operand is not a supported concrete literal."
    elif descriptor and parsed_assertions:
        observation_status = "ambiguous"
        evidence_mode = "same_category"
        interpretation_reason = "The generated check site matched, but the observed assertion kind does not match the cataloged assertion."
    elif descriptor and ("assert" in reason or assert_lines):
        observation_status = "ambiguous"
        evidence_mode = "same_category"
        interpretation_reason = "The generated check site matched, but the trace does not expose parseable assertion operands."
    elif descriptor and (revert_detected or "panic" in reason or "revert" in reason):
        observation_status = "not_observed"
        evidence_mode = "none"
        interpretation_reason = "Execution reverted before the cataloged assertion was observed; the revert is not treated as a predicate failure."
    elif descriptor:
        observation_status = "ambiguous"
        evidence_mode = "structural"
        interpretation_reason = "The generated check site matched, but the trace does not establish that its assertion executed."
    else:
        observation_status = "ambiguous" if resolution.get("status") == "ambiguous" else "not_observed"
        evidence_mode = "structural" if (finding.get("classification") or {}).get("family") else "none"
        interpretation_reason = (
            "Multiple generated-check descriptors matched this site, so no predicate was selected."
            if resolution.get("status") == "ambiguous"
            else "No generated-check descriptor matched this artifact-local suite and test."
        )

    return {
        "check_ref": descriptor.get("check_ref") if descriptor else None,
        "predicate": descriptor.get("predicate") if descriptor else None,
        "bindings": (descriptor.get("bindings") or {}) if descriptor else {},
        "spec_basis": (descriptor.get("spec_basis") or {}) if descriptor else {},
        "observation_status": observation_status,
        "evidence_mode": evidence_mode,
        "applicability": "unknown",
        "interpretation_reason": interpretation_reason,
        "check_resolution": {
            "status": resolution.get("status"),
            "match_count": resolution.get("match_count", 0),
            "expected_assertion_kind": expected_assertion_kind,
            "matched_assertion_count": len(matched_assertions),
        },
        "descriptor": descriptor,
    }


def _iter_text_values(value: Any):
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for nested in value.values():
            yield from _iter_text_values(nested)
    elif isinstance(value, (list, tuple)):
        for nested in value:
            yield from _iter_text_values(nested)


def _withdraw_guard_interpretation(finding: Dict[str, Any], analysis: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    summary = str((finding.get("classification") or {}).get("summary") or "")
    if "Withdrawal guard permits requested amount greater than or equal to the caller balance" not in summary:
        return None

    texts = []
    detail = ((finding.get("trigger") or {}).get("detail") or {})
    texts.extend(_iter_text_values(detail.get("guards") or detail.get("guard") or []))
    trigger_functions = {
        item.get("function")
        for item in _trigger_functions_from_trajectory(finding.get("trajectory") or {})
        if item.get("function")
    }
    for fact in analysis.get("guard_facts") or []:
        if not isinstance(fact, dict):
            continue
        if trigger_functions and fact.get("function") not in trigger_functions:
            continue
        texts.extend(_iter_text_values(fact.get("evidence") or fact.get("guard") or []))
    candidates = []
    seen = set()
    for raw in texts:
        compact = re.sub(r"\s+", "", str(raw).lower())
        if "amount" in compact and "balance" in compact and any(op in compact for op in (">=", "<=")):
            if compact in seen:
                continue
            seen.add(compact)
            candidates.append((raw, compact))

    if len(candidates) != 1 or any(token in candidates[0][1] for token in ("&&", "||", "?")):
        return {
            "pattern_id": "withdraw_guard_direction",
            "applicability": "unknown",
            "interpretation_reason": "The withdrawal guard could not be reduced to one unambiguous amount/balance comparison.",
            "guard_direction": "ambiguous",
        }

    raw, compact = candidates[0]
    normal = bool(
        re.search(r"balance[^<>=;]*>=?[^<>=;]*amount", compact)
        or re.search(r"amount[^<>=;]*<=?[^<>=;]*balance", compact)
    )
    reversed_guard = bool(
        re.search(r"amount[^<>=;]*>=?[^<>=;]*balance", compact)
        or re.search(r"balance[^<>=;]*<=?[^<>=;]*amount", compact)
    )
    if normal and not reversed_guard:
        return {
            "pattern_id": "withdraw_guard_direction",
            "applicability": "false",
            "interpretation_reason": "The observed guard enforces balance >= amount (equivalently amount <= balance), which contradicts this reversed-withdraw-guard diagnostic.",
            "guard_direction": "balance_covers_amount",
            "guard": raw,
            "report_disposition": "counterevidence",
        }
    if reversed_guard and not normal:
        return {
            "pattern_id": "withdraw_guard_direction",
            "applicability": "true",
            "interpretation_reason": "The observed guard places amount on the permissive side of the balance comparison and supports this diagnostic.",
            "guard_direction": "amount_covers_balance",
            "guard": raw,
            "report_disposition": "candidate",
        }
    return {
        "pattern_id": "withdraw_guard_direction",
        "applicability": "unknown",
        "interpretation_reason": "The withdrawal comparison direction remains ambiguous after normalization.",
        "guard_direction": "ambiguous",
        "guard": raw,
    }


@lru_cache(maxsize=256)
def _read_source_lines(source_path: str) -> Tuple[str, ...]:
    return tuple(Path(source_path).read_text(encoding="utf-8", errors="ignore").splitlines())


def _source_line_for_finding(finding: Dict[str, Any]) -> Optional[str]:
    """Return the exact reported source line without using benchmark metadata."""
    location = finding.get("location") or {}
    source_value = location.get("file") or (finding.get("contract") or {}).get("source")
    if not source_value:
        return None
    source_path = Path(str(source_value))
    if not source_path.is_absolute():
        source_path = Path.cwd() / source_path
    try:
        line_number = int(location.get("line") or 0)
        lines = _read_source_lines(str(source_path.resolve()))
    except (OSError, TypeError, ValueError):
        return None
    if line_number < 1 or line_number > len(lines):
        return None
    statement = re.sub(r"//.*$", "", lines[line_number - 1]).strip()
    return statement or None


def _low_level_return_interpretation(finding: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Recognize direct branch consumption as conclusive unchecked-call counterevidence."""
    if (finding.get("classification") or {}).get("kind") != "unchecked_return_value":
        return None
    statement = _source_line_for_finding(finding)
    if not statement:
        return None
    checked = re.search(
        r"\b(?:require|assert|if)\s*\([^;]*(?:\.send\s*\(|\.call\b|\.delegatecall\b)",
        statement,
        flags=re.IGNORECASE,
    )
    if not checked:
        return None
    return {
        "pattern_id": "low_level_return_handling",
        "return_handling": "checked_by_branch",
        "return_check_statement": statement,
        "applicability": "false",
        "interpretation_reason": (
            "The low-level call result is consumed directly by if, require, or assert on the reported source line."
        ),
        "report_disposition": "counterevidence",
    }


def _augment_llm_context_with_evidence(
    finding: Dict[str, Any],
    *,
    meta_dir: Optional[Path] = None,
    report_context: Optional[_ReportContext] = None,
) -> Dict[str, Any]:
    out = json.loads(json.dumps(finding, ensure_ascii=False))
    contract_name = ((out.get("contract") or {}).get("name"))
    report_context = report_context or _ReportContext(meta_dir, contract_name=contract_name)
    analysis = report_context.analysis
    classification = out.get("classification") or {}
    trigger = out.get("trigger") or {}
    trajectory = out.get("trajectory") or {}

    trigger_functions = _trigger_functions_from_trajectory(trajectory)
    function_names = [item["function"] for item in trigger_functions if item.get("function")]
    related_state = _related_state_variables(classification, trigger, analysis, function_names) if analysis else []
    static_facts = _static_facts_for_functions(analysis, function_names, related_state) if analysis else []
    static_facts = _merge_source_location_updates(static_facts, out.get("location") or {}, related_state, function_names)
    dynamic_facts = _dynamic_facts_from_finding(out)
    evidence = _check_evidence_fields(out, report_context)
    descriptor = evidence.pop("descriptor", None)
    root_cause_property = _infer_property_expression(classification, trigger, analysis, None)
    violated_property = _infer_property_expression(classification, trigger, analysis, descriptor)
    if not descriptor or descriptor.get("rca_included", True):
        root_cause_property = violated_property
    assertions = _assert_values(((out.get("trace") or {}).get("assert_lines") or []))
    if assertions:
        violated_property["observed_assertions"] = assertions

    guard_interpretation = _withdraw_guard_interpretation(out, analysis)
    if guard_interpretation:
        evidence.update(guard_interpretation)
    return_interpretation = _low_level_return_interpretation(out)
    if return_interpretation:
        evidence.update(return_interpretation)
    out.update(_jsonable(evidence))

    llm_context = dict(out.get("llm_context") or {})
    llm_context.setdefault("facts", [])
    llm_context["violated_property"] = violated_property
    llm_context["root_cause_property"] = root_cause_property
    llm_context["trigger_functions"] = trigger_functions
    llm_context["touched_state"] = related_state
    llm_context["static_facts"] = static_facts
    llm_context["dynamic_facts"] = dynamic_facts
    llm_context["evidence_chain"] = _evidence_chain(out, static_facts, dynamic_facts)
    llm_context["evidence_sources"] = {
        "fuzzing": [
            "trajectory",
            "trace.key_path_lines",
            "trace.assert_lines",
            "trace.revert_lines",
        ],
        "static_analysis": [analysis.get("_artifact_path") or "analysis.json"] if analysis else [],
        "contract": {
            "name": ((out.get("contract") or {}).get("name")),
            "source": (analysis.get("meta") or {}).get("source_path") if analysis else ((out.get("contract") or {}).get("source")),
        },
    }
    llm_context["noise_filtered"] = True
    llm_context["rca_input_contract"] = (
        "This finding is intended to be analyzed together with contract source/context. "
        "Do not infer root causes from data outside this JSON and the contract context."
    )
    out["llm_context"] = _jsonable(llm_context)
    return out


def _build_detector_run_config(args: Any, contract_name: Optional[str]) -> Dict[str, Any]:
    if args is None:
        return {}

    def pick(name: str) -> Any:
        return _jsonable(getattr(args, name, None))

    config = {
        "source": pick("source"),
        "abi": pick("abi"),
        "contract": contract_name or pick("contract"),
        "blockchain_state": pick("blockchain_state"),
        "solc_version": pick("solc_version"),
        "evm_version": pick("evm_version"),
        "generations": pick("generations"),
        "global_timeout": pick("global_timeout"),
        "population_size": pick("population_size"),
        "seed": pick("seed"),
        "seeds": pick("seeds"),
        "seed_strategy": pick("seed_strategy"),
        "validate_minimization": pick("validate_minimization"),
        "minimization_timeout": pick("minimization_timeout"),
        "data_dependency": pick("data_dependency"),
        "constraint_solving": pick("constraint_solving"),
        "environmental_instrumentation": pick("environmental_instrumentation"),
        "max_individual_length": pick("max_individual_length"),
        "max_symbolic_execution": pick("max_symbolic_execution"),
    }
    return {k: v for k, v in config.items() if v is not None}


def _build_detector_command(config: Dict[str, Any]) -> Optional[str]:
    if not config:
        return None
    parts = ["python", "-m", "fuzzer.main"]
    option_map = [
        ("source", "-s"),
        ("contract", "-c"),
        ("blockchain_state", "-b"),
        ("solc_version", "--solc"),
        ("evm_version", "--evm"),
        ("generations", "-g"),
        ("global_timeout", "-t"),
        ("population_size", "-n"),
        ("seed", "--seed"),
        ("seeds", "--seeds"),
        ("seed_strategy", "--seed-strategy"),
        ("minimization_timeout", "--minimization-timeout"),
    ]
    for key, flag in option_map:
        value = config.get(key)
        if value is not None and value != "":
            parts += [flag, str(value)]
    if config.get("validate_minimization"):
        parts.append("--validate-minimization")
    return " ".join(shlex.quote(str(p)) for p in parts)


def _detector_dedup_key(
    contract_name: Optional[str],
    classification: Dict[str, Any],
    location: Dict[str, Any],
) -> str:
    return _stable_key([
        "fuzz",
        contract_name,
        classification.get("invariant_id"),
        classification.get("kind") or classification.get("type"),
        location.get("file"),
        location.get("line"),
        location.get("pc"),
    ])


def _foundry_dedup_key(
    contract_name: str,
    origin: str,
    classification: Dict[str, Any],
    suite_name: Any,
    test_name: Any,
    targets: Dict[str, Any],
    trajectory: Dict[str, Any],
) -> str:
    target_bits = []
    for key in sorted((targets or {}).keys()):
        target_bits.append(f"{key}={targets[key]}")
    seq = "->".join(_function_sequence(trajectory))
    return _stable_key([
        origin,
        contract_name,
        classification.get("family"),
        classification.get("kind"),
        suite_name,
        test_name,
        ",".join(target_bits),
        seq,
    ])


def _detector_llm_context(
    classification: Dict[str, Any],
    location: Dict[str, Any],
    trajectory: Dict[str, Any],
) -> Dict[str, Any]:
    seq = _function_sequence(trajectory)
    facts = [
        {
            "kind": "detector",
            "type": classification.get("type"),
            "swc_id": classification.get("swc_id"),
            "severity": classification.get("severity"),
        },
        {
            "kind": "source_location",
            "file": location.get("file"),
            "line": location.get("line"),
            "pc": location.get("pc"),
            "source_code": location.get("source_code"),
        },
        {
            "kind": "trajectory",
            "length": len(trajectory.get("steps") or []),
            "functions": seq,
        },
    ]
    hints = []
    if classification.get("type"):
        hints.append("Explain why the detector condition is reachable at the reported pc/source location.")
    if seq:
        hints.append("Analyze the transaction sequence in order and identify the state setup needed before the trigger.")
    return {
        "facts": facts,
        "hypothesis_hints": hints,
        "noise_filtered": True,
    }


def _foundry_llm_context(
    classification: Dict[str, Any],
    case: Dict[str, Any],
    trajectory: Dict[str, Any],
    trace_summary: Dict[str, Any],
) -> Dict[str, Any]:
    seq = _function_sequence(trajectory)
    assertions = _assert_values(trace_summary.get("assert_lines") or [])
    targets = case.get("targets") or {}
    facts = [
        {
            "kind": "foundry_failure",
            "suite": case.get("suite"),
            "test_name": case.get("test_name"),
            "reason": case.get("failure_reason"),
        },
        {
            "kind": "classification",
            "family": classification.get("family"),
            "kind_value": classification.get("kind"),
            "summary": classification.get("summary"),
            "targets": targets,
        },
        {
            "kind": "trajectory",
            "length": len(trajectory.get("steps") or []),
            "functions": seq,
        },
    ]
    if assertions:
        facts.append({"kind": "assertions", "values": assertions})
    if trace_summary.get("revert_lines"):
        facts.append({"kind": "reverts", "lines": trace_summary.get("revert_lines")})

    hints = []
    family = classification.get("family")
    kind = classification.get("kind")
    if family in ("accounting", "accounting_anomaly"):
        hints.append("Check whether the triggering function updates balances and totalSupply consistently.")
    if kind == "terminal_no_rollback":
        hints.append("Check whether the sequence enters a terminal state and then calls a rollback/reset transition.")
    if seq:
        hints.append("Use the normalized handler call sequence as the minimal candidate reproduction path.")
    return {
        "facts": facts,
        "hypothesis_hints": hints,
        "noise_filtered": True,
    }


def _semantic_fingerprint(dedup_key: str) -> str:
    return hashlib.sha256(dedup_key.encode("utf-8")).hexdigest()[:24]


def _origin_backend(origin: Any, classification: Dict[str, Any]) -> str:
    origin_text = str(origin or "")
    if origin_text == "fuzzer_detector":
        return "fuzz"
    if origin_text.startswith("foundry"):
        return "foundry"
    return str(classification.get("primary_backend") or "unknown")


def _replay_backend(origin: Any, oracle_name: Any) -> str:
    oracle_text = str(oracle_name or "")
    origin_text = str(origin or "")
    if "foundry" in oracle_text or origin_text.startswith("foundry"):
        return "foundry"
    if "detector" in oracle_text or origin_text == "fuzzer_detector":
        return "fuzz"
    return "unknown"


def _replay_confidence(processing: Dict[str, Any], validation: Dict[str, Any]) -> str:
    if processing.get("minimization_validated") or validation.get("validated_minimality"):
        return "oracle_validated_minimal"
    if (
        validation.get("validation_mode") == "structural"
        and validation.get("validated_reproduction")
    ):
        return "structural_validated_replay"
    if processing.get("reproduction_validated") or validation.get("validated_reproduction"):
        return "oracle_validated_replay"
    if validation.get("status") == "skipped":
        return "structural_only"
    return "unvalidated"


def _replay_confidence_is_confirmed(confidence: Any) -> bool:
    value = str(confidence or "")
    return value.startswith("oracle_validated") or value == "structural_validated_replay"


def build_hybrid_replay_record(finding: Dict[str, Any]) -> Dict[str, Any]:
    """L6 normalized replay/minimize record for L3 Foundry and L4 detector cases."""
    classification = finding.get("classification") or {}
    processing = finding.get("processing") or {}
    validation = processing.get("oracle_validation") or {}
    trajectory = finding.get("trajectory") or {}
    origin = finding.get("origin")
    backend = _origin_backend(origin, classification)
    classification = _normalize_classification_display(classification, backend=backend)
    oracle_name = validation.get("oracle") or ((finding.get("minimization") or {}).get("oracle") or {}).get("kind")
    raw_steps = processing.get("raw_steps")
    processed_steps = processing.get("processed_steps")
    if raw_steps is None:
        raw_steps = len(trajectory.get("steps") or [])
    if processed_steps is None:
        processed_steps = len(trajectory.get("steps") or [])
    removed_steps = max(0, int(raw_steps or 0) - int(processed_steps or 0))
    replay_identity = {
        "schema_version": HYBRID_REPLAY_SCHEMA_VERSION,
        "finding": finding.get("semantic_fingerprint") or finding.get("dedup_key") or finding.get("id"),
        "origin": origin,
        "oracle": oracle_name,
        "raw_steps": raw_steps,
        "processed_steps": processed_steps,
    }
    return _jsonable({
        "schema_version": HYBRID_REPLAY_SCHEMA_VERSION,
        "replay_id": _stable_id(replay_identity),
        "layer": "L6",
        "finding_id": finding.get("id"),
        "semantic_fingerprint": finding.get("semantic_fingerprint"),
        "origin": origin,
        "backend": backend,
        "backend_label": _backend_display_name(backend),
        "replay_backend": _replay_backend(origin, oracle_name),
        "replay_backend_label": _backend_display_name(_replay_backend(origin, oracle_name)),
        "oracle": {
            "name": oracle_name,
            "status": validation.get("status"),
            "validated_reproduction": bool(validation.get("validated_reproduction")),
            "validated_minimality": bool(validation.get("validated_minimality")),
            "attempts": validation.get("attempts"),
            "returncode": validation.get("returncode"),
            "reason": validation.get("reason"),
        },
        "minimization": {
            "strategy": processing.get("minimization_strategy"),
            "raw_steps": raw_steps,
            "processed_steps": processed_steps,
            "removed_steps": removed_steps,
            "oracle_removed_steps": processing.get("oracle_removed_steps"),
            "structural_minimization": processing.get("structural_minimization") or {},
            "minimization_validated": bool(processing.get("minimization_validated")),
            "reproduction_validated": bool(processing.get("reproduction_validated")),
            "confidence": _replay_confidence(processing, validation),
        },
        "target": {
            "contract": finding.get("contract") or {},
            "invariant_id": classification.get("invariant_id"),
            "invariant_family": classification.get("invariant_family"),
            "display": classification.get("display") or _semantic_display(classification, backend=backend),
            "kind": classification.get("kind") or classification.get("type"),
            "expected_type": ((finding.get("minimization") or {}).get("oracle") or {}).get("expected_type"),
        },
        "replay": {
            "function_sequence": _function_sequence(trajectory),
            "trajectory": trajectory,
            "reproduction": finding.get("reproduction") or {},
        },
    })


def build_violation_event(finding: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize Foundry/L3 and fuzzer/L4 findings into one L5 event envelope."""
    classification = finding.get("classification") or {}
    trigger = finding.get("trigger") or {}
    trajectory = finding.get("trajectory") or {}
    reproduction = finding.get("reproduction") or {}
    llm_context = finding.get("llm_context") or {}
    processing = finding.get("processing") or {}
    oracle_validation = processing.get("oracle_validation") or {}
    hybrid_replay = finding.get("hybrid_replay") or build_hybrid_replay_record(finding)
    origin = finding.get("origin")
    backend = _origin_backend(origin, classification)
    classification = _normalize_classification_display(classification, backend=backend)
    event_identity = {
        "schema_version": VIOLATION_EVENT_SCHEMA_VERSION,
        "finding": finding.get("semantic_fingerprint") or finding.get("dedup_key") or finding.get("id"),
        "origin": origin,
        "backend": backend,
        "invariant_id": classification.get("invariant_id"),
        "kind": classification.get("kind") or classification.get("type"),
    }
    return _jsonable({
        "schema_version": VIOLATION_EVENT_SCHEMA_VERSION,
        "event_id": _stable_id(event_identity),
        "finding_id": finding.get("id"),
        "semantic_fingerprint": finding.get("semantic_fingerprint"),
        "dedup_key": finding.get("dedup_key"),
        "origin": origin,
        "backend": backend,
        "layer": "L5",
        "contract": finding.get("contract") or {},
        "display": _semantic_display(classification, backend=backend),
        "classification": {
            "type": classification.get("type"),
            "kind": classification.get("kind"),
            "summary": classification.get("summary"),
            "evidence_subtype": classification.get("evidence_subtype"),
            "evidence_strength": classification.get("evidence_strength"),
            "severity": classification.get("severity"),
            "swc_id": classification.get("swc_id"),
            "primary_backend": backend,
            "invariant_id": classification.get("invariant_id"),
            "invariant_category": classification.get("invariant_category"),
            "invariant_family": classification.get("invariant_family"),
            "invariant_family_zh": classification.get("invariant_family_zh"),
            "benchmark_labels": classification.get("benchmark_labels") or [],
            "trigger_templates": classification.get("trigger_templates") or [],
            "display": classification.get("display") or _semantic_display(classification, backend=backend),
        },
        "violation": {
            "property": llm_context.get("violated_property") or {},
            "root_cause_property": llm_context.get("root_cause_property") or llm_context.get("violated_property") or {},
            "trigger": trigger,
            "trigger_functions": llm_context.get("trigger_functions") or [],
            "touched_state": llm_context.get("touched_state") or [],
        },
        "execution": {
            "sequence_length": len(trajectory.get("steps") or []),
            "function_sequence": _function_sequence(trajectory),
            "trajectory": trajectory,
        },
        "evidence": {
            "location": finding.get("location") or {},
            "trace": finding.get("trace") or {},
            "static_facts": llm_context.get("static_facts") or [],
            "dynamic_facts": llm_context.get("dynamic_facts") or [],
            "evidence_chain": llm_context.get("evidence_chain") or [],
            "evidence_sources": llm_context.get("evidence_sources") or {},
        },
        "reporting_evidence": {
            "check_ref": finding.get("check_ref"),
            "observation_status": finding.get("observation_status"),
            "evidence_mode": finding.get("evidence_mode"),
            "applicability": finding.get("applicability"),
            "interpretation_reason": finding.get("interpretation_reason"),
            "check_resolution": finding.get("check_resolution") or {},
            "pattern_id": finding.get("pattern_id"),
            "guard_direction": finding.get("guard_direction"),
            "report_disposition": finding.get("report_disposition"),
            "return_handling": finding.get("return_handling"),
            "return_check_statement": finding.get("return_check_statement"),
        },
        "reproduction": reproduction,
        "validation": {
            "minimization_validated": bool(processing.get("minimization_validated")),
            "reproduction_validated": bool(processing.get("reproduction_validated")),
            "oracle_status": oracle_validation.get("status"),
            "oracle": oracle_validation.get("oracle"),
            "hybrid_replay_id": hybrid_replay.get("replay_id"),
            "hybrid_replay_confidence": ((hybrid_replay.get("minimization") or {}).get("confidence")),
        },
        "hybrid_replay": hybrid_replay,
        "artifacts": finding.get("artifacts") or {},
    })


def _step_identity(step: Dict[str, Any]) -> str:
    return str(
        step.get("signature")
        or step.get("selector")
        or step.get("calldata")
        or ""
    )


def _trajectory_signature(trajectory: Dict[str, Any]) -> List[str]:
    return [_step_identity(step) for step in (trajectory.get("steps") or [])]


def _is_suffix(shorter: List[str], longer: List[str]) -> bool:
    if not shorter:
        return True
    if len(shorter) > len(longer):
        return False
    return longer[-len(shorter):] == shorter


def _trim_after_trigger(finding: Dict[str, Any]) -> Dict[str, Any]:
    out = json.loads(json.dumps(finding, ensure_ascii=False))
    steps = ((out.get("trajectory") or {}).get("steps") or [])
    trigger_index = ((out.get("trigger") or {}).get("tx_index"))
    if trigger_index is None or not isinstance(trigger_index, int):
        return out

    trimmed = [step for step in steps if int(step.get("index", 0)) <= trigger_index]
    if len(trimmed) == len(steps):
        return out

    out.setdefault("trajectory", {})["steps"] = trimmed
    out.setdefault("minimization", {})["trimmed_suffix_steps"] = len(steps) - len(trimmed)
    return out


def _oracle_validation_enabled(validate_minimization: Optional[bool] = None) -> bool:
    if validate_minimization is not None:
        return bool(validate_minimization)
    return str(os.getenv("SEMINV_VALIDATE_MINIMIZATION", "")).strip().lower() in (
        "1",
        "true",
        "yes",
        "on",
    )


def _oracle_timeout(minimization_timeout: Optional[int] = None) -> Optional[int]:
    if minimization_timeout is not None:
        try:
            value = int(minimization_timeout)
            return value if value > 0 else None
        except Exception:
            pass
    value = int(os.getenv("SEMINV_VALIDATE_MINIMIZATION_TIMEOUT", "60"))
    return value if value > 0 else None


def _run_foundry_reproduction_oracle(
    finding: Dict[str, Any],
    *,
    minimization_timeout: Optional[int] = None,
) -> Dict[str, Any]:
    reproduction = finding.get("reproduction") or {}
    command = reproduction.get("command")
    config = reproduction.get("config") or {}
    project_root = config.get("project_root")
    if not command:
        return {"status": "skipped", "reason": "missing_reproduction_command"}
    if not project_root or not Path(str(project_root)).exists():
        return {"status": "skipped", "reason": "missing_project_root"}

    timeout = _oracle_timeout(minimization_timeout)
    try:
        cmd = shlex.split(str(command), posix=(os.name != "nt"))
        proc = subprocess.run(
            cmd,
            cwd=str(project_root),
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="ignore",
            timeout=timeout,
        )
    except Exception as exc:
        return {"status": "error", "reason": str(exc)}

    output = (proc.stdout or "") + "\n" + (proc.stderr or "")
    match_test = reproduction.get("match_test") or config.get("match_test")
    still_fails = proc.returncode != 0 and (not match_test or str(match_test) in output)
    return {
        "status": "passed" if still_fails else "failed",
        "oracle": "foundry_test_reproduction",
        "returncode": proc.returncode,
        "match_test": match_test,
        "validated_reproduction": bool(still_fails),
        "validated_minimality": False,
        "note": (
            "Re-ran the Foundry reproduction command for the canonical case. "
            "This confirms reproducibility, not deletion-based minimality."
        ),
        "output_tail": "\n".join(output.splitlines()[-20:]),
    }


def _as_int(value: Any, default: int = 0) -> int:
    try:
        if value is None or value == "":
            return default
        return int(value)
    except Exception:
        return default


def _detector_replay_seed_payload(
    finding: Dict[str, Any],
    steps_override: Optional[List[Dict[str, Any]]] = None,
) -> Optional[List[List[Dict[str, Any]]]]:
    steps = steps_override if steps_override is not None else ((finding.get("trajectory") or {}).get("steps") or [])
    if not steps:
        return None

    replay: List[Dict[str, Any]] = []
    for step in steps:
        calldata = str(step.get("calldata") or "").strip()
        selector = _normalize_selector(step.get("selector")) or _selector_from_data(calldata)
        selector = _normalize_selector(selector)
        func_token = step.get("signature") or selector or "fallback"
        step_args = step.get("args")
        if not step_args and step.get("signature"):
            step_args = _decode_calldata_args(step.get("signature"), calldata)
        if not isinstance(step_args, list):
            step_args = []
        replay.append({
            "account": step.get("from"),
            "contract": "0xCONTRACT_ADDR_PLACEHOLDER",
            "amount": _as_int(step.get("value"), 0),
            "gaslimit": _as_int(step.get("gas_limit"), 6_000_000),
            "arguments": [func_token] + _jsonable(step_args),
            "data": calldata,
            "blocknumber": _as_int((step.get("block") or {}).get("blocknumber"), 0),
            "timestamp": _as_int((step.get("block") or {}).get("timestamp"), 0),
            "returndatasize": (step.get("environment") or {}).get("returndatasize") or {},
            "call_return": (step.get("global_state") or {}).get("call_return") or {},
            "extcodesize": (step.get("global_state") or {}).get("extcodesize") or {},
            "__origin__": "detector_replay_oracle",
            "__seed_id__": finding.get("id"),
        })
    return [replay] if replay else None


def _normalize_replay_text(value: Any) -> str:
    return re.sub(r"[\s_-]+", " ", str(value or "")).strip().lower()


def _finding_classification(finding: Optional[Dict[str, Any]]) -> Dict[str, Any]:
    if not isinstance(finding, dict):
        return {}
    classification = finding.get("classification") or {}
    return classification if isinstance(classification, dict) else {}


def _finding_expected_values(expected: Any, finding: Optional[Dict[str, Any]] = None) -> List[Any]:
    values: List[Any] = []
    if expected:
        values.append(expected)
    classification = _finding_classification(finding)
    values.extend([
        classification.get("type"),
        classification.get("kind"),
        classification.get("invariant_id"),
    ])
    display = classification.get("display")
    if isinstance(display, dict):
        values.extend([
            display.get("title"),
            display.get("invariant_id"),
            ((display.get("legacy") or {}) if isinstance(display.get("legacy"), dict) else {}).get("type"),
        ])
    oracle = ((finding or {}).get("minimization") or {}).get("oracle") if isinstance(finding, dict) else {}
    if isinstance(oracle, dict):
        values.append(oracle.get("expected_type"))
    detail = ((finding or {}).get("trigger") or {}).get("detail") if isinstance(finding, dict) else {}
    if isinstance(detail, dict):
        values.extend([
            detail.get("function"),
            (detail.get("classification") or {}).get("kind") if isinstance(detail.get("classification"), dict) else None,
            (detail.get("classification") or {}).get("invariant_id") if isinstance(detail.get("classification"), dict) else None,
            (detail.get("classification") or {}).get("evidence_subtype") if isinstance(detail.get("classification"), dict) else None,
            (detail.get("targets") or {}).get("invariant_id") if isinstance(detail.get("targets"), dict) else None,
        ])
    return [value for value in values if value is not None and str(value).strip()]


def _detector_output_matches(expected: Any, output: str) -> bool:
    if not expected:
        return False
    expected_norm = re.sub(r"\s+", " ", str(expected)).strip().lower()
    output_norm = re.sub(r"\s+", " ", output or "").strip().lower()
    if expected_norm and expected_norm in output_norm:
        return True
    if expected_norm == "dos with block gas limit":
        return "dos with block gas limit" in output_norm or "dos with block gas limit detected" in output_norm
    if expected_norm == "integer overflow":
        return (
            "integer overflow" in output_norm
            or "integer underflow" in output_norm
            or "arithmetic overflow" in output_norm
            or "arithmetic underflow" in output_norm
        )
    return False


def _is_dos_replay_expected(expected: Any, finding: Optional[Dict[str, Any]] = None) -> bool:
    values = _finding_expected_values(expected, finding)
    normalized = {
        re.sub(r"[\s_-]+", " ", str(value or "")).strip().lower()
        for value in values
    }
    return any(
        value in {
            "dos with block gas limit",
            "dos with block gas limit violation",
            "dos with block gas limit candidate",
            "dos with block gas limit invariant",
        }
        or value == "dos with block gas limit"
        or value == "i5.resource.bounded.execution"
        or value == "i5 resource bounded execution"
        or "bounded execution" in value
        for value in normalized
    )


def _classification_kind(finding: Optional[Dict[str, Any]]) -> str:
    classification = _finding_classification(finding)
    return _normalize_replay_text(classification.get("kind") or classification.get("type"))


def _output_indicates_replay_ran(output: str) -> bool:
    output_norm = (output or "").lower()
    return any(
        marker in output_norm
        for marker in (
            "generation number",
            "total code coverage",
            "transaction -",
            "transaction:",
            "[pop]",
            "input:",
        )
    )


def _finding_has_raw_calldata(finding: Dict[str, Any]) -> bool:
    for step in ((finding.get("trajectory") or {}).get("steps") or []):
        calldata = str(step.get("calldata") or "").strip()
        if calldata.startswith("0x") and len(calldata) >= 10:
            return True
    return False


def _is_raw_calldata_sensitive(finding: Dict[str, Any]) -> bool:
    kind = _classification_kind(finding)
    invariant_values = {_normalize_replay_text(value) for value in _finding_expected_values(None, finding)}
    return (
        "short calldata" in kind
        or "short calldata integrity" in invariant_values
        or "i6 external short calldata integrity" in invariant_values
        or "short calldata integrity" in " ".join(invariant_values)
        or "raw calldata" in kind
        or "hash collision" in kind
    )


def _semantic_invariant_output_matches(finding: Dict[str, Any], output: str) -> bool:
    output_norm = _normalize_replay_text(output)
    if "semantic invariant monitor fired" not in output_norm and "invariant event" not in output_norm:
        return False

    expected_values = {_normalize_replay_text(value) for value in _finding_expected_values(None, finding)}
    expected_values.discard("")
    if any(value and value in output_norm for value in expected_values):
        return True

    kind = _classification_kind(finding)
    if kind and kind in output_norm:
        return True

    words = [word for word in re.split(r"\s+", kind) if word not in {"l4", "i2", "i3", "i4", "i5", "i6"}]
    if words and all(word in output_norm for word in words):
        return True

    detail = ((finding.get("trigger") or {}).get("detail") or {})
    target = detail.get("targets") if isinstance(detail, dict) else {}
    function = None
    if isinstance(target, dict):
        function = target.get("function")
    if not function and isinstance(detail, dict):
        function = detail.get("function")
    return bool(function and _normalize_replay_text(function) in output_norm)


def _integer_overflow_output_matches(finding: Dict[str, Any], output: str) -> bool:
    kind = _classification_kind(finding)
    expected_values = {_normalize_replay_text(value) for value in _finding_expected_values(None, finding)}
    if not (
        "integer overflow" in kind
        or "integer underflow" in kind
        or "numeric integrity" in " ".join(expected_values)
        or "integer overflow" in " ".join(expected_values)
        or "integer underflow" in " ".join(expected_values)
    ):
        return False

    output_norm = _normalize_replay_text(output)
    if any(term in output_norm for term in ("integer overflow", "integer underflow", "arithmetic overflow", "arithmetic underflow")):
        return True

    detail = ((finding.get("trigger") or {}).get("detail") or {})
    arithmetic = _normalize_replay_text(detail.get("arithmetic") if isinstance(detail, dict) else None)
    if arithmetic and arithmetic in output_norm:
        return True

    location = finding.get("location") or {}
    source_code = str(location.get("source_code") or "").strip()
    if source_code and source_code.lower() in (output or "").lower():
        return True
    pc = location.get("pc")
    return pc is not None and re.search(r"\bpc\b[^0-9-]*%s\b" % re.escape(str(pc)), output_norm) is not None


def _structural_replay_validation(
    *,
    expected: Any,
    proc: subprocess.CompletedProcess,
    output: str,
    reason: str,
    note: str,
    validated_reproduction: bool = False,
) -> Dict[str, Any]:
    return {
        "status": "passed" if validated_reproduction else "skipped",
        "oracle": "detector_precise_replay",
        "expected_type": expected,
        "returncode": proc.returncode,
        "validated_reproduction": bool(validated_reproduction),
        "validated_minimality": False,
        "reason": reason,
        "validation_mode": "structural",
        "note": note,
        "output_tail": "\n".join(output.splitlines()[-30:]),
    }


def _dos_structural_replay_validation(
    *,
    expected: Any,
    proc: subprocess.CompletedProcess,
    output: str,
) -> Dict[str, Any]:
    return _structural_replay_validation(
        expected=expected,
        proc=proc,
        output=output,
        reason="dos_detector_stateful_structural_replay",
        note=(
            "The DoS/block-gas-limit detector is stateful: it accumulates loop-bound "
            "observations across execution before emitting I5.resource.bounded_execution. "
            "A fresh detector replay can execute the saved sequence without re-emitting "
            "the detector text, so this result is treated as structural replay evidence "
            "and counts as replay-validated, but not as oracle-minimal."
        ),
        validated_reproduction=True,
    )


def _fallback_structural_replay_validation(
    finding: Dict[str, Any],
    *,
    expected: Any,
    proc: subprocess.CompletedProcess,
    output: str,
) -> Optional[Dict[str, Any]]:
    if not _output_indicates_replay_ran(output):
        return None

    if _is_raw_calldata_sensitive(finding) and _finding_has_raw_calldata(finding):
        return _structural_replay_validation(
            expected=expected,
            proc=proc,
            output=output,
            reason="raw_calldata_structural_replay",
            note=(
                "The replay seed preserved the original raw calldata bytes and the child "
                "fuzzer executed the sequence, but the semantic checker did not re-emit "
                "the exact detector text. Treat this as structural replay evidence only."
            ),
        )

    kind = _classification_kind(finding)
    family = _normalize_replay_text(_finding_classification(finding).get("family"))
    if kind.startswith("l4 ") or family == "l4 fuzzer detector" or "semantic invariant" in (output or "").lower():
        return _structural_replay_validation(
            expected=expected,
            proc=proc,
            output=output,
            reason="semantic_invariant_structural_replay",
            note=(
                "The saved transaction sequence executed during replay, but the semantic "
                "invariant monitor did not emit the same invariant event in the fresh run. "
                "This records replayability without claiming oracle validation."
            ),
        )

    if "integer overflow" in kind or "numeric integrity" in " ".join(
        _normalize_replay_text(value) for value in _finding_expected_values(None, finding)
    ):
        return _structural_replay_validation(
            expected=expected,
            proc=proc,
            output=output,
            reason="integer_overflow_opcode_structural_replay",
            note=(
                "The replay sequence executed, but the child process did not expose enough "
                "opcode-level overflow evidence to validate the arithmetic oracle. Treat "
                "this as structural replay evidence, not an oracle-validated overflow."
            ),
        )

    return None



def _build_detector_oracle_command(
    config: Dict[str, Any],
    reproduction_command: Optional[str] = None,
) -> Optional[List[str]]:
    source = config.get("source")
    contract = config.get("contract")
    if not source or not contract:
        return None
    python_exe = "python"
    if reproduction_command:
        try:
            parsed = shlex.split(str(reproduction_command), posix=(os.name != "nt"))
            if parsed:
                python_exe = parsed[0]
        except Exception:
            pass
    cmd = [python_exe, "-m", "fuzzer.main", "-s", str(source), "-c", str(contract)]
    if config.get("blockchain_state"):
        cmd += ["-b", str(config["blockchain_state"])]
    if config.get("solc_version"):
        cmd += ["--solc", str(config["solc_version"])]
    if config.get("evm_version"):
        cmd += ["--evm", str(config["evm_version"])]
    return cmd


def _run_detector_reproduction_oracle(
    finding: Dict[str, Any],
    *,
    minimization_timeout: Optional[int] = None,
    steps_override: Optional[List[Dict[str, Any]]] = None,
) -> Dict[str, Any]:
    seed_payload = _detector_replay_seed_payload(finding, steps_override=steps_override)
    if not seed_payload:
        return {
            "status": "skipped",
            "oracle": "detector_precise_replay",
            "expected_type": ((finding.get("minimization") or {}).get("oracle") or {}).get("expected_type"),
            "validated_reproduction": False,
            "validated_minimality": False,
            "reason": "detector_replay_seed_unavailable",
            "note": "Could not build a replay seed from the detector finding trajectory.",
        }

    reproduction = finding.get("reproduction") or {}
    config = dict(reproduction.get("config") or {})
    expected = ((finding.get("minimization") or {}).get("oracle") or {}).get("expected_type")
    command = _build_detector_oracle_command(config, reproduction.get("command"))
    if not command:
        return {
            "status": "skipped",
            "oracle": "detector_precise_replay",
            "expected_type": expected,
            "validated_reproduction": False,
            "validated_minimality": False,
            "reason": "detector_replay_command_unavailable",
        }

    timeout = _oracle_timeout(minimization_timeout)
    tmp_path: Optional[Path] = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            suffix=".replay_seed.json",
            prefix="seminv_detector_",
            delete=False,
        ) as fh:
            json.dump(seed_payload, fh, indent=2, ensure_ascii=False)
            tmp_path = Path(fh.name)

        cmd = command + ["--seeds", str(tmp_path), "--seed-strategy", "only", "-g", "1", "-n", "2"]
        env = os.environ.copy()
        env["SEMINV_DISABLE_FINDING_REPORT"] = "1"
        env["SEMINV_DETECTOR_REPLAY_ORACLE"] = "1"
        proc = subprocess.run(
            cmd,
            cwd=str(Path.cwd()),
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="ignore",
            timeout=timeout,
            env=env,
        )
    except Exception as exc:
        return {
            "status": "error",
            "oracle": "detector_precise_replay",
            "expected_type": expected,
            "validated_reproduction": False,
            "validated_minimality": False,
            "reason": str(exc),
        }
    finally:
        if tmp_path is not None:
            try:
                tmp_path.unlink()
            except Exception:
                pass

    output = (proc.stdout or "") + "\n" + (proc.stderr or "")
    detected = (
        _detector_output_matches(expected, output)
        or any(_detector_output_matches(value, output) for value in _finding_expected_values(expected, finding))
        or _semantic_invariant_output_matches(finding, output)
        or _integer_overflow_output_matches(finding, output)
    )
    infra_error = (
        proc.returncode != 0
        and not detected
        and bool(re.search(r"Traceback|ModuleNotFoundError|ImportError|SyntaxError", output))
    )
    if not detected and not infra_error and _is_dos_replay_expected(expected, finding):
        return _dos_structural_replay_validation(
            expected=expected,
            proc=proc,
            output=output,
        )
    if not detected and not infra_error:
        structural_validation = _fallback_structural_replay_validation(
            finding,
            expected=expected,
            proc=proc,
            output=output,
        )
        if structural_validation:
            return structural_validation
    return {
        "status": "passed" if detected else ("error" if infra_error else "failed"),
        "oracle": "detector_precise_replay",
        "expected_type": expected,
        "returncode": proc.returncode,
        "validated_reproduction": detected,
        "validated_minimality": detected,
        "note": (
            "Replayed the detector finding trajectory as the only seed with reporting "
            "disabled in the child process. This validates the minimized transaction "
            "sequence when the same detector type is emitted."
        ),
        "output_tail": "\n".join(output.splitlines()[-30:]),
        **({"reason": "detector_replay_process_error"} if infra_error else {}),
    }


def _oracle_minimize_detector_sequence(
    finding: Dict[str, Any],
    *,
    minimization_timeout: Optional[int] = None,
) -> Dict[str, Any]:
    steps = list(((finding.get("trajectory") or {}).get("steps") or []))
    if not steps:
        validation = _run_detector_reproduction_oracle(
            finding,
            minimization_timeout=minimization_timeout,
        )
        return {"finding": finding, "validation": validation, "removed_steps": 0}

    changed = True
    attempts = 0
    while changed:
        changed = False
        for index in range(len(steps)):
            candidate = steps[:index] + steps[index + 1:]
            if not candidate:
                continue
            attempts += 1
            result = _run_detector_reproduction_oracle(
                finding,
                minimization_timeout=minimization_timeout,
                steps_override=candidate,
            )
            if result.get("validated_reproduction"):
                steps = candidate
                changed = True
                break

    out = json.loads(json.dumps(finding, ensure_ascii=False))
    for i, step in enumerate(steps):
        step["index"] = i
    out.setdefault("trajectory", {})["steps"] = steps
    validation = _run_detector_reproduction_oracle(
        out,
        minimization_timeout=minimization_timeout,
        steps_override=steps,
    )
    if validation.get("validated_reproduction") and validation.get("validation_mode") != "structural":
        validation["validated_minimality"] = True
        validation["attempts"] = attempts
        validation["removed_steps"] = len(((finding.get("trajectory") or {}).get("steps") or [])) - len(steps)
        validation["note"] = (
            "Greedy deletion-based minimization using detector transaction-sequence replay. "
            "The final minimized sequence still emits the expected detector type."
        )
    return {
        "finding": out,
        "validation": validation,
        "removed_steps": len(((finding.get("trajectory") or {}).get("steps") or [])) - len(steps),
    }


def _solidity_handler_call(step: Dict[str, Any]) -> Optional[str]:
    sig = str(step.get("signature") or step.get("calldata") or "").strip()
    m = re.match(r"(?P<name>call_[A-Za-z0-9_]+)(?:\s*\(|$)", sig)
    if not m:
        return None
    args = _args_from_foundry_step(step)
    if isinstance(args, list):
        arg_text = ", ".join(str(a) for a in args)
    else:
        arg_text = str(args or "").strip()
        if arg_text.startswith("[") and arg_text.endswith("]"):
            arg_text = arg_text[1:-1].strip()
    arg_text = re.sub(r"\s+\[[^\[\]]+\]", "", arg_text)
    return "handler.%s(%s);" % (m.group("name"), arg_text)


def _foundry_temp_replay_source(
    finding: Dict[str, Any],
    steps: List[Dict[str, Any]],
    temp_contract: str,
) -> Optional[str]:
    reproduction = finding.get("reproduction") or {}
    config = reproduction.get("config") or {}
    match_path = config.get("match_path")
    suite = reproduction.get("match_contract") or config.get("match_contract")
    test_name = reproduction.get("match_test") or config.get("match_test")
    if not match_path or not suite or not test_name:
        return None
    is_invariant = str(test_name).startswith("invariant_")
    if not is_invariant and not str(test_name).startswith("test_"):
        return None

    import_name = Path(str(match_path)).name
    calls: List[str] = []
    for step in steps:
        call = _solidity_handler_call(step)
        if not call:
            return None
        calls.append("        " + call)
    if is_invariant:
        calls.append("        %s();" % test_name)
    else:
        calls = ["        %s();" % test_name]
    body = "\n".join(calls)
    return (
        "// SPDX-License-Identifier: UNLICENSED\n"
        "pragma solidity >=0.7.0 <0.9.0;\n"
        'import "./%s";\n\n'
        "contract %s is %s {\n"
        "    function test_con_fuzzius_min_replay() public {\n"
        "%s\n"
        "    }\n"
        "}\n"
    ) % (import_name, temp_contract, suite, body)


def _foundry_candidate_still_fails(
    finding: Dict[str, Any],
    steps: List[Dict[str, Any]],
    *,
    minimization_timeout: Optional[int] = None,
) -> Dict[str, Any]:
    reproduction = finding.get("reproduction") or {}
    config = reproduction.get("config") or {}
    project_root = config.get("project_root")
    if not project_root or not Path(str(project_root)).exists():
        return {"ok": False, "reason": "missing_project_root"}

    temp_contract = "SemanticInvariantMin_%s" % _safe_filename(str(finding.get("id") or "case"))[:16]
    source = _foundry_temp_replay_source(finding, steps, temp_contract)
    if not source:
        return {"ok": False, "reason": "unsupported_foundry_replay_shape"}

    project = Path(str(project_root))
    root = project
    match_path = str((finding.get("reproduction") or {}).get("config", {}).get("match_path") or "")
    cleanup_root: Optional[Path] = None
    isolated = root / ".isolated_invariant"
    if isolated.exists() and (isolated / match_path).exists():
        root = isolated
    elif match_path:
        case_id = _safe_filename(str(finding.get("semantic_fingerprint") or finding.get("id") or "case"))[:24]
        root = project / (".seminv_minimize_%s" % case_id)
        cleanup_root = root
        try:
            if root.exists():
                shutil.rmtree(root)
            (root / "test").mkdir(parents=True, exist_ok=True)
            (root / "src").mkdir(parents=True, exist_ok=True)
            (root / "lib").mkdir(parents=True, exist_ok=True)
            original_test = project / match_path
            if not original_test.exists():
                return {"ok": False, "reason": "missing_original_test"}
            shutil.copy2(original_test, root / "test" / original_test.name)
            if (project / "src").exists():
                shutil.copytree(project / "src", root / "src", dirs_exist_ok=True)
            if (project / "lib").exists():
                shutil.copytree(project / "lib", root / "lib", dirs_exist_ok=True)
            (root / "foundry.toml").write_text(
                "[profile.default]\nauto_detect_solc = true\n",
                encoding="utf-8",
            )
        except Exception as exc:
            return {"ok": False, "reason": str(exc)}

    test_dir = root / "test"
    test_dir.mkdir(parents=True, exist_ok=True)
    temp_path = test_dir / ("%s.t.sol" % temp_contract)
    timeout = _oracle_timeout(minimization_timeout)
    try:
        temp_path.write_text(source, encoding="utf-8")
        forge = shlex.split(str(reproduction.get("command") or "forge"), posix=(os.name != "nt"))[0]
        cmd = [
            forge,
            "test",
            "--match-path",
            "test/%s" % temp_path.name,
            "--match-contract",
            temp_contract,
            "--match-test",
            "test_con_fuzzius_min_replay",
            "-vvv",
        ]
        proc = subprocess.run(
            cmd,
            cwd=str(root),
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="ignore",
            timeout=timeout,
        )
        output = (proc.stdout or "") + "\n" + (proc.stderr or "")
        return {
            "ok": proc.returncode != 0 and "test_con_fuzzius_min_replay" in output,
            "returncode": proc.returncode,
            "reason": "candidate_failed" if proc.returncode != 0 else "candidate_passed",
            "output_tail": "\n".join(output.splitlines()[-20:]),
        }
    except Exception as exc:
        return {"ok": False, "reason": str(exc)}
    finally:
        try:
            temp_path.unlink()
        except Exception:
            pass
        if cleanup_root is not None:
            try:
                shutil.rmtree(cleanup_root)
            except Exception:
                pass


def _oracle_minimize_foundry_sequence(
    finding: Dict[str, Any],
    *,
    minimization_timeout: Optional[int] = None,
) -> Dict[str, Any]:
    steps = list(((finding.get("trajectory") or {}).get("steps") or []))
    if len(steps) <= 1:
        if _foundry_temp_replay_source(finding, steps, "SemanticInvariantMinProbe"):
            full_result = _foundry_candidate_still_fails(
                finding,
                steps,
                minimization_timeout=minimization_timeout,
            )
            replay = {
                "status": "passed" if full_result.get("ok") else "failed",
                "oracle": "foundry_temp_replay_test",
                "validated_reproduction": bool(full_result.get("ok")),
                "validated_minimality": bool(full_result.get("ok")),
                "attempts": 0,
                "removed_steps": 0,
                "note": "Single-step replay validated with a temporary Foundry replay test.",
            }
            if not full_result.get("ok"):
                replay["reason"] = full_result.get("reason")
                if full_result.get("output_tail"):
                    replay["output_tail"] = full_result.get("output_tail")
        else:
            replay = _run_foundry_reproduction_oracle(
                finding,
                minimization_timeout=minimization_timeout,
            )
        return {
            "finding": finding,
            "validation": replay,
            "removed_steps": 0,
        }

    changed = True
    attempts = 0
    while changed:
        changed = False
        for index in range(len(steps)):
            candidate = steps[:index] + steps[index + 1:]
            if not candidate:
                continue
            attempts += 1
            result = _foundry_candidate_still_fails(
                finding,
                candidate,
                minimization_timeout=minimization_timeout,
            )
            if result.get("ok"):
                steps = candidate
                changed = True
                break

    out = json.loads(json.dumps(finding, ensure_ascii=False))
    for i, step in enumerate(steps):
        step["index"] = i
    out.setdefault("trajectory", {})["steps"] = steps
    removed = len(((finding.get("trajectory") or {}).get("steps") or [])) - len(steps)
    full_result = _foundry_candidate_still_fails(
        out,
        steps,
        minimization_timeout=minimization_timeout,
    )
    validation = {
        "status": "passed" if full_result.get("ok") else "failed",
        "oracle": "foundry_temp_replay_test",
        "validated_reproduction": bool(full_result.get("ok")),
        "validated_minimality": bool(full_result.get("ok")),
        "attempts": attempts,
        "removed_steps": removed,
        "note": "Greedy deletion-based minimization using a temporary Foundry replay test.",
    }
    if not full_result.get("ok"):
        validation["reason"] = full_result.get("reason")
        if full_result.get("output_tail"):
            validation["output_tail"] = full_result.get("output_tail")
    return {
        "finding": out,
        "validation": validation,
        "removed_steps": removed,
    }


def _validate_processed_finding(
    out: Dict[str, Any],
    *,
    validate_minimization: Optional[bool] = None,
    minimization_timeout: Optional[int] = None,
) -> Dict[str, Any]:
    if not _oracle_validation_enabled(validate_minimization):
        return {
            "status": "skipped",
            "reason": "pass --validate-minimization or set SEMINV_VALIDATE_MINIMIZATION=1 to run external oracles",
            "validated_reproduction": False,
            "validated_minimality": False,
        }
    if str(out.get("origin") or "").startswith("foundry"):
        return _run_foundry_reproduction_oracle(
            out,
            minimization_timeout=minimization_timeout,
        )
    if out.get("origin") == "fuzzer_detector":
        return _run_detector_reproduction_oracle(
            out,
            minimization_timeout=minimization_timeout,
        )
    return {
        "status": "skipped",
        "reason": "unsupported_origin_for_external_oracle",
        "validated_reproduction": False,
        "validated_minimality": False,
    }


def _processed_finding(
    finding: Dict[str, Any],
    group_size: int,
    instance_ids: List[str],
    *,
    validate_minimization: Optional[bool] = None,
    minimization_timeout: Optional[int] = None,
) -> Dict[str, Any]:
    out = _trim_after_trigger(finding)
    original_steps = len(((finding.get("trajectory") or {}).get("steps") or []))
    oracle_removed_steps = 0
    oracle_enabled = _oracle_validation_enabled(validate_minimization)
    if oracle_enabled and str(out.get("origin") or "").startswith("foundry"):
        oracle_result = _oracle_minimize_foundry_sequence(
            out,
            minimization_timeout=minimization_timeout,
        )
        out = oracle_result.get("finding") or out
        validation = oracle_result.get("validation") or _validate_processed_finding(
            out,
            validate_minimization=validate_minimization,
            minimization_timeout=minimization_timeout,
        )
        oracle_removed_steps = int(oracle_result.get("removed_steps") or 0)
    elif oracle_enabled and out.get("origin") == "fuzzer_detector":
        oracle_result = _oracle_minimize_detector_sequence(
            out,
            minimization_timeout=minimization_timeout,
        )
        out = oracle_result.get("finding") or out
        validation = oracle_result.get("validation") or _validate_processed_finding(
            out,
            validate_minimization=validate_minimization,
            minimization_timeout=minimization_timeout,
        )
        oracle_removed_steps = int(oracle_result.get("removed_steps") or 0)
    else:
        validation = _validate_processed_finding(
            out,
            validate_minimization=validate_minimization,
            minimization_timeout=minimization_timeout,
        )
    minimized_steps = len(((out.get("trajectory") or {}).get("steps") or []))
    validated_minimality = bool(validation.get("validated_minimality"))
    validated_reproduction = bool(validation.get("validated_reproduction"))
    strategy = "structural_minimized"
    if validated_minimality:
        strategy = "oracle_validated_minimized"
    elif validated_reproduction:
        strategy = "oracle_validated_reproduction_structural_minimized"
    out["processing"] = {
        "kind": "deduplicated_%s_finding" % strategy,
        "dedup_group_size": group_size,
        "instance_ids": instance_ids,
        "raw_instance_id": finding.get("id"),
        "raw_steps": original_steps,
        "processed_steps": minimized_steps,
        "minimization_strategy": strategy,
        "structural_minimization": {
            "strategy": "canonical_shortest_semantic_group_then_trim_after_trigger",
            "changed": original_steps != len(((_trim_after_trigger(finding).get("trajectory") or {}).get("steps") or [])),
        },
        "oracle_removed_steps": oracle_removed_steps,
        "oracle_validation": validation,
        "minimization_validated": validated_minimality,
        "reproduction_validated": validated_reproduction,
        "replay_confidence": _replay_confidence({}, validation),
        "validation_note": (
            "Processed cases are structurally minimized by default. Pass "
            "--validate-minimization or set SEMINV_VALIDATE_MINIMIZATION=1 to run supported external oracles. "
            "A case is marked oracle_validated_minimized only when deletion-based "
            "minimality is validated; Foundry reproduction reruns validate reproducibility."
        ),
    }
    return out


def _canonical_score(finding: Dict[str, Any]) -> List[Any]:
    processed = _trim_after_trigger(finding)
    steps = ((processed.get("trajectory") or {}).get("steps") or [])
    trace = processed.get("trace") or {}
    has_trace = 0 if trace.get("raw_path") else 1
    has_location = 0 if (processed.get("location") or {}).get("file") else 1
    created_at = processed.get("created_at") or 0
    return [len(steps), has_trace, has_location, created_at, str(processed.get("id") or "")]


def _read_finding_file(path: Path) -> Optional[Dict[str, Any]]:
    try:
        data = json.loads(_filesystem_path(path).read_text(encoding="utf-8"))
    except Exception:
        return None
    if not isinstance(data, dict) or data.get("schema_version") not in (SCHEMA_VERSION, LEGACY_SCHEMA_VERSION):
        return None
    return data


def _finding_group_key(finding: Dict[str, Any]) -> Optional[str]:
    key = finding.get("semantic_fingerprint") or finding.get("dedup_key") or finding.get("id")
    return str(key) if key else None


def _validation_rank(finding: Dict[str, Any]) -> int:
    processing = finding.get("processing") or {}
    validation = processing.get("oracle_validation") or {}
    if processing.get("minimization_validated") or validation.get("validated_minimality"):
        return 3
    if processing.get("reproduction_validated") or validation.get("validated_reproduction"):
        return 2
    if (
        validation.get("status") == "skipped"
        and validation.get("reason") in {
            "dos_detector_stateful_structural_replay",
            "raw_calldata_structural_replay",
            "semantic_invariant_structural_replay",
            "integer_overflow_opcode_structural_replay",
        }
    ):
        return 1
    if validation.get("status") in ("failed", "error"):
        return 1
    return 0


def _merge_preserved_processing(
    candidate: Dict[str, Any],
    preserved: Dict[str, Any],
    *,
    group_size: int,
    instance_ids: List[str],
    raw_json: Optional[str],
    out_path: Path,
) -> Dict[str, Any]:
    out = json.loads(json.dumps(preserved, ensure_ascii=False))
    out = _enrich_legacy_finding(out)
    out["created_at"] = candidate.get("created_at", out.get("created_at"))
    out.setdefault("artifacts", {})
    out["artifacts"]["json"] = str(out_path)
    if raw_json:
        out["artifacts"]["raw_json"] = raw_json
    out["artifacts"]["preserved_validated_json"] = (preserved.get("artifacts") or {}).get("json")
    out["artifacts"]["current_canonical_raw_json"] = raw_json

    processing = dict(out.get("processing") or {})
    processing["dedup_group_size"] = group_size
    processing["instance_ids"] = instance_ids
    processing["preserved_validated_result"] = True
    processing["preservation_note"] = (
        "An existing oracle-validated processed case for this semantic fingerprint "
        "was kept because the current processing pass did not produce an equally "
        "strong validation result."
    )
    out["processing"] = processing
    return out


def _read_optional_json(path: Path) -> Dict[str, Any]:
    try:
        path = _filesystem_path(path)
        if path.exists():
            data = json.loads(path.read_text(encoding="utf-8"))
            return data if isinstance(data, dict) else {}
    except Exception:
        return {}
    return {}


def _artifact_path(path: Path) -> str:
    return str(path)


def _semantic_artifact_map(meta_dir: Path, pro_dir: Path) -> Dict[str, Any]:
    invariant_dir = meta_dir
    return {
        "semantic_fact_model": {
            "description": "Recovered semantic facts and invariant target model.",
            "paths": [
                _artifact_path(invariant_dir / "analysis.json"),
                _artifact_path(invariant_dir / "uir_targets.json"),
            ],
        },
        "invariant_target_plan": {
            "description": "Six-family semantic invariant target plan.",
            "paths": [_artifact_path(invariant_dir / "uir_targets.json")],
        },
        "foundry_property_validation": {
            "description": "L3 Foundry property backend output; functional-test failures are diagnostics only.",
            "paths": [
                _artifact_path(invariant_dir / "summary.json"),
                _artifact_path(invariant_dir / "foundry_supplement.json"),
            ],
        },
        "semantic_coverage": {
            "description": "Semantic coverage, seed archive, UIR solving and mutation metrics.",
            "paths": [_artifact_path(meta_dir / "uir_coverage.json")],
        },
        "guidance_statistics": {
            "description": "Vulnerability-oriented semantic guidance statistics.",
            "paths": [_artifact_path(meta_dir / "vulnerability_hint_stats.json")],
        },
        "raw_violation_candidates": {
            "description": "Raw backend candidates kept for traceability, not the primary paper-facing report.",
            "paths": [_artifact_path(meta_dir / "finding_cases")],
        },
        "normalized_violation_evidence": {
            "description": "Normalized, deduplicated, replay-linked invariant violation evidence.",
            "paths": [_artifact_path(pro_dir)],
        },
        "unified_violation_events": {
            "description": "L5 unified semantic invariant violation events.",
            "paths": [_artifact_path(pro_dir / "violation_events.json")],
        },
        "replay_minimized_evidence": {
            "description": "L6 replay and minimization confirmation evidence.",
            "paths": [_artifact_path(pro_dir / "hybrid_replay_report.json")],
        },
    }


def _coverage_snapshot(meta_dir: Path) -> Dict[str, Any]:
    uir = _read_optional_json(meta_dir / "uir_coverage.json")
    summary = uir.get("summary") or {}
    return {
        "target_path": summary.get("target_path") or uir.get("target_path"),
        "coverage_goals": summary.get("coverage_goals") or {},
        "covered": summary.get("covered") or {},
        "percentages": summary.get("percentages") or {},
        "archive_stats": summary.get("archive_stats") or {},
    }


def _guidance_snapshot(meta_dir: Path) -> Dict[str, Any]:
    hint = _read_optional_json(meta_dir / "vulnerability_hint_stats.json")
    return {
        "vulnerability_hints": {
            "schema_version": "semantic-invariant.guidance.v1" if hint else None,
            "config": hint.get("config") or {},
            "stats": hint.get("stats") or {},
        }
    }


def _semantic_event_row(event: Dict[str, Any]) -> Dict[str, Any]:
    classification = event.get("classification") or {}
    display = event.get("display") or classification.get("display") or _semantic_display(
        classification,
        backend=event.get("backend"),
    )
    validation = event.get("validation") or {}
    execution = event.get("execution") or {}
    labels = classification.get("benchmark_labels") or []
    return {
        "event_id": event.get("event_id"),
        "finding_id": event.get("finding_id"),
        "title": display.get("title"),
        "summary": display.get("summary"),
        "invariant_id": classification.get("invariant_id"),
        "invariant_family": classification.get("invariant_family"),
        "invariant_family_zh": classification.get("invariant_family_zh"),
        "backend": event.get("backend"),
        "backend_label": display.get("backend_label") or _backend_display_name(event.get("backend")),
        "trigger_templates": classification.get("trigger_templates") or [],
        "benchmark_labels": [
            "%s:%s" % (item.get("benchmark"), item.get("label"))
            for item in labels
        ],
        "minimal_sequence": execution.get("function_sequence") or [],
        "sequence_length": execution.get("sequence_length"),
        "replay_status": validation.get("oracle_status"),
        "replay_confidence": validation.get("hybrid_replay_confidence"),
        "hybrid_replay_id": validation.get("hybrid_replay_id"),
    }


def build_semantic_invariant_report(
    *,
    meta_dir: Path,
    pro_dir: Path,
    events: List[Dict[str, Any]],
    replay_report: Dict[str, Any],
    index: Dict[str, Any],
    detection: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    from .d_policy import source_path, runtime_bytes
    from .t_policy import apply_t, POLICY, POLICY_VERSION
    manifest = _read_optional_json(meta_dir.parent / 'run_manifest.json')
    owned = []
    for event in events:
        owner = event.get('contract') or {}
        if not owner.get('source') or not owner.get('name'):
            continue
        if manifest.get('source') and (
            source_path(owner['source']) != source_path(manifest['source'])
            or owner['name'] != manifest.get('contract')
        ):
            continue
        owned.append(event)
    if detection is None:
        source = source_path(manifest.get('source'))
        started = manifest.get('started_at')
        text, runtime = '', b''
        if isinstance(started, (int, float)):
            if source and _filesystem_path(source).exists() and _filesystem_path(source).stat().st_mtime <= started:
                text = _filesystem_path(source).read_text(encoding='utf-8')
            result_path = _filesystem_path(meta_dir.parent / 'artifacts/l4_fuzz/results.json')
            if result_path.exists() and started <= result_path.stat().st_mtime <= float(manifest.get('finished_at') or time.time()) + 1:
                runtime = runtime_bytes(_read_optional_json(result_path), manifest.get('contract'))
        detection = apply_t(owned, source=text, runtime=runtime)
    events = detection['events']
    rows = [_semantic_event_row(event) for event in events]
    confirmed_rows = [
        row for row in rows
        if row.get("replay_status") == "passed"
        and _replay_confidence_is_confirmed(row.get("replay_confidence"))
    ]
    unvalidated_rows = [row for row in rows if row not in confirmed_rows]
    replay_records = replay_report.get("records") or []
    family_defs = {
        key: {
            "code": key.split("_", 1)[0],
            "name": value.get("name"),
            "zh": value.get("zh"),
            "primary_backend": value.get("primary_backend"),
        }
        for key, value in SIX_INVARIANT_FAMILIES.items()
    }
    return _jsonable({
        "schema_version": SEMANTIC_REPORT_SCHEMA_VERSION,
        "reporting_policy": POLICY,
        "reporting_policy_version": POLICY_VERSION,
        "detection": {"reporting_policy": POLICY, "reporting_policy_version": POLICY_VERSION,
                      "categories": sorted(detection['predictions']),
                      "evidence_level": "alerts; replay confirmation is reported separately"},
        "framework": {
            "name": "Semantic Invariant Vulnerability Detection Framework",
            "goal": (
                "Model smart-contract vulnerabilities as violations of semantic "
                "invariants over execution traces."
            ),
            "invariant_families": family_defs,
        },
        "run": {
            "meta_dir": str(meta_dir),
            "processed_dir": str(pro_dir),
            "raw_candidate_count": index.get("raw_count"),
            "deduplicated_event_count": len(rows),
            "confirmed_event_count": len(confirmed_rows),
            "unvalidated_event_count": len(unvalidated_rows),
            "fp_filter": index.get("fp_filter") or {
                "mode": FP_FILTER_OFF,
                "input_event_count": len(rows),
                "reported_event_count": len(rows),
                "suppressed_event_count": 0,
                "suppressed_by_rule": {},
            },
        },
        "pipeline": [
            {"layer": "L0", "name": "Contract Intake", "output": "compiled ABI, selector map, deployment context"},
            {"layer": "L1", "name": "Semantic Fact Recovery", "output": "storage, access, accounting, state and relation facts"},
            {"layer": "L2", "name": "Invariant Target Planning", "output": "six-family invariant target plan"},
            {"layer": "L3", "name": "Foundry Property Validation", "output": "property violations and Foundry replay evidence"},
            {"layer": "L4", "name": "Semantic Fuzz Runtime Monitoring", "output": "runtime invariant violation candidates and guidance stats"},
            {"layer": "L5", "name": "ViolationEvent Unification", "output": "deduplicated semantic violation events"},
            {"layer": "L6", "name": "Hybrid Replay and Minimize", "output": "validated minimal replay evidence"},
        ],
        "artifacts": _semantic_artifact_map(meta_dir, pro_dir),
        "semantic_coverage": _coverage_snapshot(meta_dir),
        "guidance": _guidance_snapshot(meta_dir),
        "violation_summary": {
            "total": len(rows),
            "confirmed": len(confirmed_rows),
            "unvalidated": len(unvalidated_rows),
            "by_validation": _count_by(rows, lambda x: x.get("replay_confidence")),
            "by_backend": _count_by(rows, lambda x: x.get("backend")),
            "by_invariant_family": _count_by(rows, lambda x: x.get("invariant_family")),
            "by_invariant_id": _count_by(rows, lambda x: x.get("invariant_id")),
        },
        "replay_summary": {
            "schema_version": replay_report.get("schema_version"),
            "replay_count": replay_report.get("replay_count"),
            "replayed_count": replay_report.get("replayed_count"),
            "minimized_count": replay_report.get("minimized_count"),
            "by_backend": replay_report.get("by_backend") or {},
            "oracle_status": _count_by(replay_records, lambda x: (x.get("oracle") or {}).get("status")),
            "confidence": _count_by(replay_records, lambda x: (x.get("minimization") or {}).get("confidence")),
        },
        "confirmed_violation_events": confirmed_rows,
        "unvalidated_violation_candidates": unvalidated_rows,
        "all_violation_events": rows,
        "terminology": {
            "primary_report": "semantic_invariant_report.json / semantic_invariant_report.md",
            "raw_candidates": "Raw backend candidates are retained only for auditability.",
            "functional_tests": "Functional-test failures are seed-generation diagnostics and are not counted as confirmed invariant violations.",
            "legacy_detector_terms": "SWC and detector names are secondary benchmark labels, not the primary classification.",
        },
    })


def _write_semantic_invariant_markdown(report: Dict[str, Any], path: Path) -> None:
    lines: List[str] = []
    framework = report.get("framework") or {}
    lines.append("# Semantic Invariant Vulnerability Report")
    lines.append("")
    lines.append(framework.get("goal") or "")
    lines.append("")
    run = report.get("run") or {}
    lines.append("## Run Summary")
    lines.append("")
    lines.append(f"- Reporting policy: `{report.get('reporting_policy', 'T')}`")
    lines.append(f"- T categories: `{';'.join((report.get('detection') or {}).get('categories') or [])}`")
    lines.append(f"- Meta dir: `{run.get('meta_dir')}`")
    lines.append(f"- Processed dir: `{run.get('processed_dir')}`")
    lines.append(f"- Raw candidates: `{run.get('raw_candidate_count')}`")
    lines.append(f"- Deduplicated violation events: `{run.get('deduplicated_event_count')}`")
    lines.append(f"- Replay-confirmed events: `{run.get('confirmed_event_count')}`")
    lines.append(f"- Unvalidated candidates: `{run.get('unvalidated_event_count')}`")
    fp_filter = run.get("fp_filter") or {}
    lines.append(f"- FP filter mode: `{fp_filter.get('mode')}`")
    lines.append(f"- FP-filtered events: `{fp_filter.get('suppressed_event_count', 0)}`")
    lines.append("")
    lines.append("## Six Invariant Families")
    lines.append("")
    for item in (framework.get("invariant_families") or {}).values():
        lines.append(f"- `{item.get('code')}` {item.get('name')} ({item.get('zh')}) [{item.get('primary_backend')}]")
    lines.append("")
    summary = report.get("violation_summary") or {}
    lines.append("## Violation Summary")
    lines.append("")
    lines.append(f"- Total: `{summary.get('total')}`")
    lines.append(f"- Confirmed: `{summary.get('confirmed')}`")
    lines.append(f"- Unvalidated: `{summary.get('unvalidated')}`")
    lines.append(f"- By validation: `{summary.get('by_validation')}`")
    lines.append(f"- By backend: `{summary.get('by_backend')}`")
    lines.append(f"- By invariant family: `{summary.get('by_invariant_family')}`")
    lines.append("")
    replay = report.get("replay_summary") or {}
    lines.append("## Replay And Minimization")
    lines.append("")
    lines.append(f"- Replay count: `{replay.get('replay_count')}`")
    lines.append(f"- Replayed: `{replay.get('replayed_count')}`")
    lines.append(f"- Minimized: `{replay.get('minimized_count')}`")
    lines.append(f"- Confidence: `{replay.get('confidence')}`")
    lines.append("")
    coverage = report.get("semantic_coverage") or {}
    lines.append("## Semantic Coverage")
    lines.append("")
    lines.append(f"- Target path: `{coverage.get('target_path')}`")
    lines.append(f"- Percentages: `{coverage.get('percentages')}`")
    lines.append("")
    hint = ((report.get("guidance") or {}).get("vulnerability_hints") or {})
    lines.append("## Guidance Statistics")
    lines.append("")
    lines.append(f"- Config: `{hint.get('config')}`")
    lines.append(f"- Stats: `{hint.get('stats')}`")
    lines.append("")
    lines.append("## Confirmed Violation Events")
    lines.append("")
    for idx, event in enumerate(report.get("confirmed_violation_events") or [], start=1):
        lines.append(f"### {idx}. {event.get('title')}")
        lines.append("")
        lines.append(f"- Event ID: `{event.get('event_id')}`")
        lines.append(f"- Invariant ID: `{event.get('invariant_id')}`")
        lines.append(f"- Backend: `{event.get('backend_label')}`")
        lines.append(f"- Trigger templates: `{event.get('trigger_templates')}`")
        lines.append(f"- Benchmark labels: `{event.get('benchmark_labels')}`")
        lines.append(f"- Minimal sequence: `{event.get('minimal_sequence')}`")
        lines.append(f"- Replay status: `{event.get('replay_status')}`")
        lines.append(f"- Confidence: `{event.get('replay_confidence')}`")
        lines.append("")
    unvalidated = report.get("unvalidated_violation_candidates") or []
    if unvalidated:
        lines.append("## Unvalidated Violation Candidates")
        lines.append("")
        for idx, event in enumerate(unvalidated, start=1):
            lines.append(f"### {idx}. {event.get('title')}")
            lines.append("")
            lines.append(f"- Event ID: `{event.get('event_id')}`")
            lines.append(f"- Invariant ID: `{event.get('invariant_id')}`")
            lines.append(f"- Backend: `{event.get('backend_label')}`")
            lines.append(f"- Minimal sequence: `{event.get('minimal_sequence')}`")
            lines.append(f"- Replay status: `{event.get('replay_status')}`")
            lines.append(f"- Confidence: `{event.get('replay_confidence')}`")
            lines.append("")
    _write_text(path, "\n".join(lines))


def write_semantic_invariant_report(
    *,
    meta_dir: Path,
    pro_dir: Path,
    events: List[Dict[str, Any]],
    replay_report: Dict[str, Any],
    index: Dict[str, Any],
) -> Dict[str, Any]:
    report = build_semantic_invariant_report(
        meta_dir=meta_dir,
        pro_dir=pro_dir,
        events=events,
        replay_report=replay_report,
        index=index,
    )
    json_path = pro_dir / "semantic_invariant_report.json"
    md_path = pro_dir / "semantic_invariant_report.md"
    _write_text(json_path, json.dumps(report, indent=2, ensure_ascii=False))
    _write_semantic_invariant_markdown(report, md_path)
    return report


def refresh_semantic_invariant_report(meta_dir: Path) -> Optional[Dict[str, Any]]:
    meta_dir = Path(meta_dir)
    pro_dir = meta_dir / "finding_cases_pro"
    events_path = pro_dir / "violation_events.json"
    replay_path = pro_dir / "hybrid_replay_report.json"
    index_path = pro_dir / "finding_index.json"
    if not events_path.exists() or not replay_path.exists() or not index_path.exists():
        return None
    events_data = _read_optional_json(events_path)
    replay_report = _read_optional_json(replay_path)
    index = _read_optional_json(index_path)
    events = events_data.get("events") or []
    if not isinstance(events, list):
        events = []
    report = write_semantic_invariant_report(
        meta_dir=meta_dir,
        pro_dir=pro_dir,
        events=events,
        replay_report=replay_report,
        index=index,
    )
    index["semantic_report_schema_version"] = SEMANTIC_REPORT_SCHEMA_VERSION
    index["semantic_invariant_report"] = str(pro_dir / "semantic_invariant_report.json")
    index["semantic_invariant_report_md"] = str(pro_dir / "semantic_invariant_report.md")
    index["summary"] = report.get("violation_summary") or {}
    _write_text(index_path, json.dumps(index, indent=2, ensure_ascii=False))
    return report


def _infer_foundry_case_identity(finding: Dict[str, Any]) -> Dict[str, Any]:
    trigger_detail = (finding.get("trigger") or {}).get("detail") or {}
    return {
        "suite": trigger_detail.get("suite")
        or (finding.get("reproduction") or {}).get("match_contract")
        or ((finding.get("minimization") or {}).get("oracle") or {}).get("match_contract"),
        "test_name": trigger_detail.get("test_name")
        or (finding.get("reproduction") or {}).get("match_test")
        or ((finding.get("minimization") or {}).get("oracle") or {}).get("match_test"),
        "targets": trigger_detail.get("targets") or {},
    }


def _infer_dedup_key(finding: Dict[str, Any]) -> str:
    origin = finding.get("origin") or "unknown"
    contract = Path(str(((finding.get("contract") or {}).get("name")) or "contract")).stem
    classification = finding.get("classification") or {}
    trajectory = finding.get("trajectory") or {}
    if str(origin).startswith("foundry"):
        case = _infer_foundry_case_identity(finding)
        return _foundry_dedup_key(
            contract,
            str(origin),
            classification,
            case.get("suite"),
            case.get("test_name"),
            case.get("targets") or {},
            trajectory,
        )
    if origin == "fuzzer_detector":
        return _detector_dedup_key(contract, classification, finding.get("location") or {})
    return _stable_key([
        origin,
        contract,
        classification.get("family"),
        classification.get("kind") or classification.get("type"),
        "->".join(_function_sequence(trajectory)),
    ])


def _enrich_legacy_finding(finding: Dict[str, Any]) -> Dict[str, Any]:
    out = json.loads(json.dumps(finding, ensure_ascii=False))
    source = (
        ((out.get("contract") or {}).get("source"))
        or ((out.get("location") or {}).get("file"))
        or ((out.get("reproduction") or {}).get("config") or {}).get("source")
    )
    selector_map = _selector_signature_map_from_source(source)
    out["trajectory"] = _enrich_trajectory_selectors(out.get("trajectory") or {}, selector_map)
    classification = dict(out.get("classification") or {})
    origin = str(out.get("origin") or "")
    case = _infer_foundry_case_identity(out)
    targets = case.get("targets") or {}
    if not classification.get("invariant_id") and targets.get("invariant_id"):
        classification["invariant_id"] = targets.get("invariant_id")
    if origin == "fuzzer_detector":
        classification = enrich_classification(classification, detector_type=classification.get("type"))
        classification["primary_backend"] = "fuzz"
    elif origin.startswith("foundry"):
        classification = enrich_classification(
            classification,
            foundry_kind=classification.get("kind"),
            foundry_family=classification.get("family"),
            test_name=case.get("test_name"),
        )
    backend = _origin_backend(origin, classification)
    classification = _normalize_classification_display(classification, backend=backend)
    out["classification"] = classification
    if out.get("origin") == "fuzzer_detector":
        out.setdefault("classification", {})["primary_backend"] = "fuzz"

    if origin == "fuzzer_detector" and str(out.get("dedup_key") or "").startswith("fuzzer_detector|"):
        out["dedup_key"] = _infer_dedup_key(out)
        out["semantic_fingerprint"] = _semantic_fingerprint(str(out["dedup_key"]))
        out.setdefault("compatibility", {})["dedup_key_migrated_to_semantic_backend"] = True
    if not out.get("dedup_key"):
        out["dedup_key"] = _infer_dedup_key(out)
        out.setdefault("compatibility", {})["dedup_key_backfilled"] = True
    if not out.get("semantic_fingerprint") and out.get("dedup_key"):
        out["semantic_fingerprint"] = _semantic_fingerprint(str(out["dedup_key"]))
        out.setdefault("compatibility", {})["semantic_fingerprint_backfilled"] = True
    return out


def _backfill_reproduction_config(finding: Dict[str, Any], meta_dir: Path) -> Dict[str, Any]:
    out = json.loads(json.dumps(finding, ensure_ascii=False))
    origin = str(out.get("origin") or "")
    if not origin.startswith("foundry"):
        return out

    reproduction = out.setdefault("reproduction", {})
    if reproduction.get("config"):
        return out

    case = _infer_foundry_case_identity(out)
    suite = case.get("suite")
    test_name = case.get("test_name")
    if not suite or not test_name:
        return out

    report_case = {
        "reproduce_command": reproduction.get("command"),
    }
    config = _foundry_reproduction_config(Path(meta_dir), report_case, suite, test_name)
    if config:
        reproduction["config"] = config
        out.setdefault("compatibility", {})["reproduction_config_backfilled"] = True
    return out


def _checkpoint_violation_events(pro_dir, findings, mode):
    events = [f.get('violation_event') or build_violation_event(f) for f in findings]
    filtered = apply_fp_filter(events, mode)
    _write_text(pro_dir / 'violation_events.json', json.dumps({
        'schema_version': VIOLATION_EVENT_SCHEMA_VERSION,
        'processing_complete': False,
        'event_count': len(filtered['events']),
        'events': filtered['events'],
        'fp_filter': {k: v for k, v in filtered.items() if k != 'events'},
    }, indent=2, ensure_ascii=False))


def process_finding_cases(
    finding_cases_dir: Path,
    *,
    validate_minimization: Optional[bool] = None,
    minimization_timeout: Optional[int] = None,
    fp_filter_mode: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Build a processed finding_cases_pro directory next to finding_cases.
    Raw finding_cases are preserved. Processed output keeps one canonical case per
    semantic_fingerprint/dedup_key and applies conservative structural minimization.
    """
    raw_dir = Path(finding_cases_dir)
    pro_dir = raw_dir.parent / "finding_cases_pro"
    _filesystem_path(pro_dir).mkdir(parents=True, exist_ok=True)
    report_context = _ReportContext(raw_dir.parent)
    resolved_fp_filter_mode = normalize_fp_filter_mode(
        fp_filter_mode if fp_filter_mode is not None else os.getenv("SEMINV_FP_FILTER", FP_FILTER_OFF)
    )

    existing_processed: Dict[str, Dict[str, Any]] = {}
    existing_paths = []
    for old_path in _filesystem_path(pro_dir).glob("*.json"):
        if old_path.name == "finding_index.json":
            continue
        old_finding = _read_finding_file(old_path)
        if not old_finding:
            continue
        existing_paths.append(old_path)
        old_finding = _enrich_legacy_finding(old_finding)
        old_key = _finding_group_key(old_finding)
        if not old_key:
            continue
        current = existing_processed.get(old_key)
        if current is None or _validation_rank(old_finding) > _validation_rank(current):
            existing_processed[old_key] = old_finding

    groups: Dict[str, List[Dict[str, Any]]] = {}
    source_paths: Dict[str, str] = {}
    for path in _filesystem_path(raw_dir).glob("*.json"):
        finding = _read_finding_file(path)
        if not finding:
            continue
        finding = _enrich_legacy_finding(finding)
        finding = _backfill_reproduction_config(finding, raw_dir.parent)
        key = _finding_group_key(finding)
        if not key:
            continue
        source_paths[finding.get("id") or str(path)] = str(path)
        groups.setdefault(key, []).append(finding)

    # Keep the previous completed evidence until each replacement is durable.
    checkpoint = {key: value for key, value in existing_processed.items() if key in groups}
    _checkpoint_violation_events(pro_dir, list(checkpoint.values()), resolved_fp_filter_mode)
    processed: List[Dict[str, Any]] = []
    written_paths = set()
    for key, items in sorted(groups.items()):
        canonical = sorted(items, key=_canonical_score)[0]
        instance_ids = [str(item.get("id")) for item in items if item.get("id")]
        pro = _processed_finding(
            canonical,
            len(items),
            instance_ids,
            validate_minimization=validate_minimization,
            minimization_timeout=minimization_timeout,
        )
        fname = _safe_filename("%s_%s" % (
            pro.get("semantic_fingerprint") or key,
            (pro.get("classification") or {}).get("kind") or (pro.get("classification") or {}).get("type") or "finding",
        ))
        out_path = pro_dir / ("%s.json" % fname)
        raw_json = source_paths.get(canonical.get("id"))
        pro.setdefault("artifacts", {})["raw_json"] = raw_json
        pro.setdefault("artifacts", {})["json"] = str(out_path)

        preserved = existing_processed.get(key)
        if (
            preserved is not None
            and _validation_rank(preserved) >= 2
            and _validation_rank(preserved) > _validation_rank(pro)
        ):
            pro = _merge_preserved_processing(
                pro,
                preserved,
                group_size=len(items),
                instance_ids=instance_ids,
                raw_json=raw_json,
                out_path=out_path,
            )

        if pro.get("origin") == "fuzzer_detector":
            pro.setdefault("classification", {})["primary_backend"] = "fuzz"
        pro["backend"] = _origin_backend(pro.get("origin"), pro.get("classification") or {})
        pro["classification"] = _normalize_classification_display(pro.get("classification") or {}, backend=pro["backend"])
        pro = _augment_llm_context_with_evidence(
            pro,
            meta_dir=raw_dir.parent,
            report_context=report_context,
        )
        pro["hybrid_replay"] = build_hybrid_replay_record(pro)
        pro["violation_event"] = build_violation_event(pro)
        _write_text(out_path, json.dumps(pro, indent=2, ensure_ascii=False))
        written_paths.add(_filesystem_path(out_path))
        processed.append(pro)
        checkpoint[key] = pro
        _checkpoint_violation_events(pro_dir, list(checkpoint.values()), resolved_fp_filter_mode)

    all_events = [item.get("violation_event") or build_violation_event(item) for item in processed]
    filter_result = apply_fp_filter(all_events, resolved_fp_filter_mode)
    events = filter_result["events"]
    replay_records = [item.get("hybrid_replay") or build_hybrid_replay_record(item) for item in processed]
    replay_report = {
        "schema_version": HYBRID_REPLAY_SCHEMA_VERSION,
        "source_dir": str(raw_dir),
        "processed_dir": str(pro_dir),
        "replay_count": len(replay_records),
        "replayed_count": sum(1 for item in replay_records if ((item.get("oracle") or {}).get("validated_reproduction"))),
        "minimized_count": sum(1 for item in replay_records if ((item.get("oracle") or {}).get("validated_minimality"))),
        "structural_validated_count": sum(
            1
            for item in replay_records
            if ((item.get("minimization") or {}).get("confidence") == "structural_validated_replay")
        ),
        "by_confidence": _count_by(
            replay_records,
            lambda item: (item.get("minimization") or {}).get("confidence"),
        ),
        "by_backend": {
            backend: sum(1 for item in replay_records if item.get("backend") == backend)
            for backend in sorted({str(item.get("backend") or "unknown") for item in replay_records})
        },
        "records": replay_records,
    }
    _write_text(pro_dir / "hybrid_replay_report.json", json.dumps(replay_report, indent=2, ensure_ascii=False))

    event_index = {
        "schema_version": VIOLATION_EVENT_SCHEMA_VERSION,
        "processing_complete": True,
        "source_dir": str(raw_dir),
        "processed_dir": str(pro_dir),
        "event_count": len(events),
        "unfiltered_event_count": len(all_events),
        "fp_filter": {
            key: value for key, value in filter_result.items() if key != "events"
        },
        "by_backend": _count_by(events, lambda x: x.get("backend")),
        "by_invariant_family": _count_by(events, lambda x: (x.get("classification") or {}).get("invariant_family")),
        "by_invariant_id": _count_by(events, lambda x: (x.get("classification") or {}).get("invariant_id")),
        "events": events,
    }
    _write_text(pro_dir / "violation_events.json", json.dumps(event_index, indent=2, ensure_ascii=False))
    for old_path in existing_paths:
        if old_path not in written_paths:
            old_path.unlink(missing_ok=True)

    index = {
        "schema_version": SCHEMA_VERSION,
        "source_dir": str(raw_dir),
        "processed_dir": str(pro_dir),
        "raw_count": sum(len(v) for v in groups.values()),
        "dedup_count": len(processed),
        "reported_event_count": len(events),
        "fp_filter": {
            key: value for key, value in filter_result.items() if key != "events"
        },
        "violation_event_schema_version": VIOLATION_EVENT_SCHEMA_VERSION,
        "violation_event_index": str(pro_dir / "violation_events.json"),
        "hybrid_replay_schema_version": HYBRID_REPLAY_SCHEMA_VERSION,
        "hybrid_replay_report": str(pro_dir / "hybrid_replay_report.json"),
        "groups": [
            {
                "semantic_fingerprint": item.get("semantic_fingerprint"),
                "violation_event_id": ((item.get("violation_event") or {}).get("event_id")),
                "hybrid_replay_id": ((item.get("hybrid_replay") or {}).get("replay_id")),
                "dedup_key": item.get("dedup_key"),
                "canonical_id": item.get("id"),
                "instance_ids": (item.get("processing") or {}).get("instance_ids", []),
                "raw_steps": (item.get("processing") or {}).get("raw_steps"),
                "processed_steps": (item.get("processing") or {}).get("processed_steps"),
                "llm_context_ready": bool((item.get("llm_context") or {}).get("evidence_chain")),
                "evidence_sources": ((item.get("llm_context") or {}).get("evidence_sources") or {}),
                "path": (item.get("artifacts") or {}).get("json"),
            }
            for item in processed
        ],
    }
    semantic_report = write_semantic_invariant_report(
        meta_dir=raw_dir.parent,
        pro_dir=pro_dir,
        events=events,
        replay_report=replay_report,
        index=index,
    )
    index["semantic_report_schema_version"] = SEMANTIC_REPORT_SCHEMA_VERSION
    index["semantic_invariant_report"] = str(pro_dir / "semantic_invariant_report.json")
    index["semantic_invariant_report_md"] = str(pro_dir / "semantic_invariant_report.md")
    index["summary"] = (semantic_report.get("violation_summary") or {})
    _write_text(pro_dir / "finding_index.json", json.dumps(index, indent=2, ensure_ascii=False))
    return index


def _trajectory_from_solution(
    solution: List[Dict[str, Any]],
    function_signature_mapping: Optional[Dict[str, str]] = None,
) -> Dict[str, Any]:
    steps: List[Dict[str, Any]] = []
    setup: List[Dict[str, Any]] = []
    sigs = function_signature_mapping or {}

    for index, item in enumerate(solution or []):
        tx = (item or {}).get("transaction") or {}
        data = tx.get("data") or ""
        selector = _selector_from_data(data)
        selector = _normalize_selector(selector)
        step = {
            "index": index,
            "from": tx.get("from"),
            "to": tx.get("to"),
            "value": _jsonable(tx.get("value", 0)),
            "gas_limit": _jsonable(tx.get("gaslimit", tx.get("gas"))),
            "calldata": data if str(data).startswith("0x") else ("0x" + str(data) if data else ""),
            "selector": selector,
            "signature": sigs.get(selector) or sigs.get(selector.replace("0x", "")),
            "args": [],
            "block": _jsonable((item or {}).get("block") or {}),
            "global_state": _jsonable((item or {}).get("global_state") or {}),
            "environment": _jsonable((item or {}).get("environment") or {}),
        }
        if tx.get("to") is None:
            setup.append(step)
        else:
            steps.append(step)

    return {"setup": setup, "steps": steps}


def build_detector_finding(
    *,
    error: Dict[str, Any],
    pc: Any,
    source_map: Any = None,
    function_signature_mapping: Optional[Dict[str, str]] = None,
    contract_name: Optional[str] = None,
    trigger_tx_index: Optional[int] = None,
    trigger_detail: Optional[Dict[str, Any]] = None,
    fuzzing_args: Any = None,
) -> Dict[str, Any]:
    trajectory = _trajectory_from_solution(
        error.get("individual") or [],
        function_signature_mapping=function_signature_mapping,
    )
    location = _source_location(source_map, pc, error)
    classification = {
        "type": error.get("type"),
        "swc_id": error.get("swc_id"),
        "severity": error.get("severity"),
        "family": "detector",
        "kind": str(error.get("type") or "unknown").lower().replace(" ", "_"),
        "summary": "Runtime semantic monitor observed a potential invariant violation",
    }
    detail_classification = (trigger_detail or {}).get("classification") if isinstance(trigger_detail, dict) else None
    if isinstance(detail_classification, dict):
        classification.update({k: v for k, v in detail_classification.items() if v is not None})
    classification = enrich_classification(
        classification,
        detector_type=error.get("type"),
    )
    classification["primary_backend"] = "fuzz"
    classification = _normalize_classification_display(classification, backend="fuzz")
    contract = Path(str(contract_name or "contract")).stem
    run_config = _build_detector_run_config(fuzzing_args, contract)
    dedup_key = _detector_dedup_key(contract, classification, location)

    identity = {
        "origin": "fuzzer_detector",
        "classification": classification,
        "location": location,
        "trajectory": trajectory,
    }

    finding = {
        "schema_version": SCHEMA_VERSION,
        "origin": "fuzzer_detector",
        "id": _stable_id(identity),
        "dedup_key": dedup_key,
        "semantic_fingerprint": _semantic_fingerprint(dedup_key),
        "created_at": int(time.time()),
        "contract": {
            "name": contract,
            "source": location.get("file"),
            "deployed_address": None,
        },
        "classification": classification,
        "location": location,
        "trigger": {
            "tx_index": trigger_tx_index,
            "failure_reason": error.get("type"),
            "detail": _jsonable(trigger_detail or {}),
        },
        "trajectory": trajectory,
        "reproduction": {
            "mode": "evm_sequence",
            "command": _build_detector_command(run_config),
            "config": run_config,
            "test_path": None,
            "match_contract": None,
            "match_test": None,
        },
        "trace": {
            "raw_path": None,
            "key_path_lines": [],
            "target_calls": [],
            "handler_calls": [],
            "events": [],
            "revert_detected": False,
            "assert_lines": [],
        },
        "minimization": {
            "unit": "transaction_sequence",
            "preserve_prefix_until": trigger_tx_index,
            "oracle": {
                "kind": "detector",
                "expected_type": error.get("type"),
                "expected_pc": pc,
            },
        },
        "llm_context": _detector_llm_context(classification, location, trajectory),
        "artifacts": {
            "json": None,
            "trace": None,
            "raw_stdout": None,
            "raw_stderr": None,
        },
    }
    return _jsonable(finding)


def save_detector_finding(
    *,
    error: Dict[str, Any],
    pc: Any,
    source_map: Any = None,
    function_signature_mapping: Optional[Dict[str, str]] = None,
    contract_name: Optional[str] = None,
    trigger_tx_index: Optional[int] = None,
    trigger_detail: Optional[Dict[str, Any]] = None,
    fuzzing_args: Any = None,
) -> Optional[Dict[str, Any]]:
    if os.getenv("SEMINV_DISABLE_FINDING_REPORT"):
        return None
    try:
        finding = build_detector_finding(
            error=error,
            pc=pc,
            source_map=source_map,
            function_signature_mapping=function_signature_mapping,
            contract_name=contract_name,
            trigger_tx_index=trigger_tx_index,
            trigger_detail=trigger_detail,
            fuzzing_args=fuzzing_args,
        )
        source_path = getattr(fuzzing_args, "source", None) if fuzzing_args is not None else None
        if source_path is None:
            source_path = (finding.get("contract") or {}).get("source")
        out_dir = _canonical_contract_meta_dir(contract_name, source_path=source_path) / "finding_cases"
        out_dir.mkdir(parents=True, exist_ok=True)
        fname = _safe_filename("%s_%s" % (finding["id"], finding["classification"].get("kind")))
        out_path = out_dir / ("%s.json" % fname)
        finding["artifacts"]["json"] = str(out_path)
        _write_text(out_path, json.dumps(finding, indent=2, ensure_ascii=False))
        process_finding_cases(
            out_dir,
            validate_minimization=getattr(fuzzing_args, "validate_minimization", None),
            minimization_timeout=getattr(fuzzing_args, "minimization_timeout", None),
        )
        return finding
    except Exception:
        return None


def _trajectory_from_foundry_sequence(sequence: List[Dict[str, Any]]) -> Dict[str, Any]:
    steps: List[Dict[str, Any]] = []
    for index, step in enumerate(sequence or []):
        calldata = step.get("calldata") or ""
        selector = _normalize_selector(_selector_from_data(calldata))
        steps.append({
            "index": index,
            "from": step.get("sender"),
            "to": step.get("addr"),
            "value": None,
            "gas_limit": None,
            "calldata": calldata,
            "selector": selector,
            "signature": _signature_from_foundry_calldata(calldata),
            "args": _args_from_foundry_step(step),
            "source": step.get("source"),
        })
    return {"setup": [], "steps": steps}


def _extract_foundry_sequence_from_trace(trace_text: str) -> List[Dict[str, Any]]:
    sequence: List[Dict[str, Any]] = []
    seen = set()

    for line in (trace_text or "").splitlines():
        m_seq = _FOUNDRY_SEQ_LINE_RE.search(line.strip())
        if not m_seq:
            continue
        item = {
            "sender": m_seq.group("sender"),
            "addr": m_seq.group("addr"),
            "calldata": m_seq.group("calldata"),
            "args": m_seq.group("args"),
            "source": "foundry_sequence",
        }
        key = (item["sender"], item["addr"], item["calldata"], item["args"])
        if key in seen:
            continue
        seen.add(key)
        sequence.append(item)

    if sequence:
        return sequence

    for line in (trace_text or "").splitlines():
        m_call = _TRACE_HANDLER_CALL_RE.search(line.strip())
        if not m_call:
            continue
        raw_args = (m_call.group("args") or "").strip()
        item = {
            "sender": None,
            "addr": m_call.group("addr") or m_call.group("handler"),
            "calldata": m_call.group("call"),
            "args": "[]" if not raw_args else f"[{raw_args}]",
            "source": "trace_handler_call",
        }
        key = (item["addr"], item["calldata"], item["args"])
        if key in seen:
            continue
        seen.add(key)
        sequence.append(item)

    return sequence


def _failed_trace_path(meta_dir: Optional[Path], case: Dict[str, Any]) -> Optional[Path]:
    if meta_dir is None:
        return None
    suite = case.get("suite", "unknown_suite")
    test = case.get("test_name", "unknown_test")
    path = Path(meta_dir) / "failed_traces" / f"{_safe_filename(f'{suite}__{test}')}.trace.txt"
    return path if path.exists() else None


def _enrich_foundry_case_from_artifacts(
    meta_dir: Optional[Path],
    case: Dict[str, Any],
    report_context: Optional[_ReportContext] = None,
) -> Dict[str, Any]:
    enriched = dict(case)
    trace_path = _failed_trace_path(meta_dir, enriched)
    if trace_path is not None:
        enriched["_trace_path"] = str(trace_path)
        if not enriched.get("replay_sequence"):
            try:
                trace_text = (
                    report_context.read_trace(trace_path)
                    if report_context is not None
                    else trace_path.read_text(encoding="utf-8", errors="ignore")
                )
                enriched["replay_sequence"] = _extract_foundry_sequence_from_trace(trace_text)
            except Exception:
                pass
    return enriched


def _foundry_reproduction_config(
    meta_dir: Optional[Path],
    case: Dict[str, Any],
    suite_name: Any,
    test_name: Any,
) -> Dict[str, Any]:
    config: Dict[str, Any] = {
        "project_root": None,
        "meta_dir": str(meta_dir) if meta_dir else None,
        "test_kind": None,
        "match_path": None,
        "match_contract": suite_name,
        "match_test": test_name,
    }
    if meta_dir is not None:
        p = Path(meta_dir)
        config["test_kind"] = p.name
        if p.parent.name.endswith("_meta"):
            config["project_root"] = str(p.parent.parent)

    command = case.get("reproduce_command") or ""
    m = re.search(r"--match-path\s+(\S+)", command)
    if m:
        config["match_path"] = m.group(1)
    return {k: v for k, v in config.items() if v is not None}


def build_foundry_finding(
    case: Dict[str, Any],
    *,
    meta_dir: Optional[Path] = None,
    contract_name: Optional[str] = None,
    report_context: Optional[_ReportContext] = None,
) -> Dict[str, Any]:
    trace_summary = case.get("trace_summary") or {}
    trajectory = _trajectory_from_foundry_sequence(case.get("replay_sequence") or [])
    contract = _contract_name_from_meta_dir(meta_dir, contract_name)
    test_name = case.get("test_name")
    suite_name = case.get("suite")
    meta_text = str(meta_dir or "").lower()
    origin = "foundry_invariant" if "invariant" in meta_text or str(test_name or "").startswith("invariant_") else "foundry_functional"

    classification = {
        "type": "Invariant Violation" if str(test_name or "").startswith("invariant_") else "Foundry Test Failure",
        "swc_id": None,
        "severity": None,
        "family": case.get("invariant_family"),
        "kind": case.get("invariant_kind"),
        "summary": case.get("summary"),
    }
    classification = enrich_classification(
        classification,
        foundry_kind=case.get("invariant_kind"),
        foundry_family=case.get("invariant_family"),
        test_name=test_name,
    )
    classification = _normalize_classification_display(
        classification,
        backend="foundry" if origin == "foundry_invariant" else classification.get("primary_backend"),
    )
    targets = case.get("targets") or {}
    dedup_key = _foundry_dedup_key(contract, origin, classification, suite_name, test_name, targets, trajectory)
    reproduction_config = _foundry_reproduction_config(meta_dir, case, suite_name, test_name)

    identity = {
        "origin": origin,
        "classification": classification,
        "suite": suite_name,
        "test_name": test_name,
        "replay_sequence": case.get("replay_sequence") or [],
    }

    finding = {
        "schema_version": SCHEMA_VERSION,
        "origin": origin,
        "id": _stable_id(identity),
        "dedup_key": dedup_key,
        "semantic_fingerprint": _semantic_fingerprint(dedup_key),
        "created_at": int(time.time()),
        "contract": {
            "name": Path(str(contract)).stem,
            "source": None,
            "deployed_address": None,
        },
        "classification": classification,
        "location": {
            "pc": None,
            "file": None,
            "line": None,
            "column": None,
            "source_code": None,
        },
        "trigger": {
            "tx_index": None,
            "failure_reason": case.get("failure_reason"),
            "detail": {
                "suite": suite_name,
                "test_name": test_name,
                "targets": targets,
            },
        },
        "trajectory": trajectory,
        "reproduction": {
            "mode": "forge_test",
            "command": case.get("reproduce_command"),
            "config": reproduction_config,
            "test_path": None,
            "match_contract": suite_name,
            "match_test": test_name,
        },
        "trace": {
            "raw_path": case.get("_trace_path"),
            "key_path_lines": trace_summary.get("key_path_lines") or [],
            "target_calls": trace_summary.get("target_calls") or [],
            "handler_calls": trace_summary.get("handler_calls") or [],
            "events": trace_summary.get("events") or [],
            "revert_detected": bool(trace_summary.get("revert_detected")),
            "assert_lines": trace_summary.get("assert_lines") or [],
            "revert_lines": trace_summary.get("revert_lines") or [],
        },
        "minimization": {
            "unit": "transaction_sequence",
            "preserve_prefix_until": None,
            "oracle": {
                "kind": "foundry_test",
                "expected_type": classification["type"],
                "match_contract": suite_name,
                "match_test": test_name,
            },
        },
        "llm_context": _foundry_llm_context(classification, case, trajectory, trace_summary),
        "artifacts": {
            "json": None,
            "trace": None,
            "raw_stdout": str(Path(meta_dir) / "last_trace.txt") if meta_dir else None,
            "raw_stderr": str(Path(meta_dir) / "last_stderr.txt") if meta_dir else None,
        },
    }
    report_context = report_context or _ReportContext(meta_dir, contract_name=contract)
    evidence = _check_evidence_fields(finding, report_context)
    evidence.pop("descriptor", None)
    finding.update(evidence)
    guard_interpretation = _withdraw_guard_interpretation(finding, report_context.analysis)
    if guard_interpretation:
        finding.update(guard_interpretation)
    return _jsonable(finding)


def save_foundry_findings(
    meta_dir: Path,
    report: Dict[str, Any],
    *,
    contract_name: Optional[str] = None,
    source_path: Optional[Any] = None,
    validate_minimization: Optional[bool] = None,
    minimization_timeout: Optional[int] = None,
) -> Dict[str, Any]:
    out_dir = Path(meta_dir) / "finding_cases"
    out_dir.mkdir(parents=True, exist_ok=True)
    contract = _contract_name_from_meta_dir(Path(meta_dir), contract_name)
    mirror_dir = _canonical_contract_meta_dir(contract, source_path=source_path) / "finding_cases"
    mirror_dir.mkdir(parents=True, exist_ok=True)
    report_context = _ReportContext(Path(meta_dir), contract_name=contract)

    findings: List[Dict[str, Any]] = []
    for case in report.get("failures", []) or []:
        enriched_case = _enrich_foundry_case_from_artifacts(
            Path(meta_dir),
            case,
            report_context=report_context,
        )
        finding = build_foundry_finding(
            enriched_case,
            meta_dir=Path(meta_dir),
            contract_name=contract,
            report_context=report_context,
        )
        fname = _safe_filename("%s_%s__%s" % (
            finding["id"],
            case.get("suite", "unknown_suite"),
            case.get("test_name", "unknown_test"),
        ))
        out_path = out_dir / ("%s.json" % fname)
        finding["artifacts"]["json"] = str(out_path)
        _write_text(out_path, json.dumps(finding, indent=2, ensure_ascii=False))

        if mirror_dir.resolve() != out_dir.resolve():
            mirror_path = mirror_dir / ("%s.json" % fname)
            mirror_finding = dict(finding)
            mirror_finding["artifacts"] = dict(finding.get("artifacts") or {})
            mirror_finding["artifacts"]["json"] = str(mirror_path)
            mirror_finding["artifacts"]["source_json"] = str(out_path)
            _write_text(mirror_path, json.dumps(mirror_finding, indent=2, ensure_ascii=False))

        findings.append(finding)

    aggregate = {
        "schema_version": SCHEMA_VERSION,
        "origin": "foundry",
        "fail_count": len(findings),
        "finding_ids": [item["id"] for item in findings],
        "findings": findings,
    }
    (Path(meta_dir) / "finding_report.json").write_text(
        json.dumps(aggregate, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    if mirror_dir.resolve() != out_dir.resolve():
        mirror_aggregate = dict(aggregate)
        mirror_aggregate["mirrored_from"] = str(Path(meta_dir) / "finding_report.json")
        (_canonical_contract_meta_dir(contract, source_path=source_path) / "foundry_finding_report.json").write_text(
            json.dumps(mirror_aggregate, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
    process_finding_cases(
        out_dir,
        validate_minimization=validate_minimization,
        minimization_timeout=minimization_timeout,
    )
    if mirror_dir.resolve() != out_dir.resolve():
        process_finding_cases(
            mirror_dir,
            validate_minimization=validate_minimization,
            minimization_timeout=minimization_timeout,
        )
    return aggregate
