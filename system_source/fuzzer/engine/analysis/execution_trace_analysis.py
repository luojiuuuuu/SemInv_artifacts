#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import time
import json
import psutil
import re
from pathlib import Path
from copy import deepcopy
from typing import Any

from ...reporting import refresh_semantic_invariant_report

from ..environment import FuzzingEnvironment
from ..plugin_interfaces import OnTheFlyAnalysis

from ..fitness import fitness_function

from ...utils.utils import initialize_logger, convert_stack_value_to_int, convert_stack_value_to_hex, normalize_32_byte_hex_address, get_function_signature_mapping
from eth._utils.address import force_bytes_to_address
from eth_utils import to_hex, to_int, int_to_big_endian, encode_hex, ValidationError, to_canonical_address, to_normalized_address

from z3 import simplify, BitVec, BitVecVal, Not, Optimize, sat, unsat, unknown, is_expr, Or, ULT, ULE
from z3.z3util import get_vars

from ...utils import settings
from ...utils.coverage_snapshot import coverage_snapshot

_TARGET_LABEL_TOKENS = {
    "access_control": {"access_control", "access_noninterference", "authorization", "unsafe_delegatecall", "unprotected_selfdestruct"},
    "arithmetic": {"arithmetic", "integer_overflow", "integer_underflow", "numeric_integrity"},
    "bad_randomness": {"bad_randomness", "bad_randomness_dependency", "block_dependency", "hash_collision"},
    "denial_of_service": {"denial_of_service", "failed_refund_dos", "dos", "dos_with_block_gas_limit", "bounded_execution"},
    "front_running": {"front_running", "approve_race", "transaction_order_dependency", "order_independence"},
    "reentrancy": {"reentrancy", "cei_reentrancy"},
    "short_addresses": {"short_addresses", "short_address", "short_calldata_integrity"},
    "time_manipulation": {"time_manipulation", "timestamp_dependency", "timestamp"},
    "unchecked_low_level_calls": {"unchecked_low_level_calls", "unchecked_return_value", "call_return_consistency"},
}


def _json_default(value):
    if isinstance(value, (bytes, bytearray)):
        return "0x" + bytes(value).hex()
    try:
        return str(value)
    except Exception:
        return repr(value)


def _infer_benchmark_label_from_source(source: Any) -> str:
    text = str(source or "").replace("\\", "/").lower()
    for label in _TARGET_LABEL_TOKENS:
        if f"/{label}/" in text or text.startswith(f"{label}/"):
            return label
    return ""


def _finding_dir_has_target(meta_dir: Path, label: str) -> bool:
    tokens = _TARGET_LABEL_TOKENS.get(label, {label})
    pro_dir = meta_dir / "finding_cases_pro"
    if not pro_dir.exists():
        return False
    for path in pro_dir.glob("*.json"):
        name = path.stem.lower()
        if any(token in name for token in tokens):
            return True
    report_path = pro_dir / "semantic_invariant_report.json"
    if report_path.exists():
        try:
            text = report_path.read_text(encoding="utf-8", errors="ignore").lower()
            if any(token in text for token in tokens):
                return True
        except Exception:
            pass
    return False


class ExecutionTraceAnalyzer(OnTheFlyAnalysis):
    def __init__(self, fuzzing_environment: FuzzingEnvironment) -> None:
        self.logger = initialize_logger("Analysis")
        self.env = fuzzing_environment
        self.symbolic_execution_count = 0

    def _uir_enabled(self):
        return isinstance(getattr(self.env, "uir_targets", None), dict)

    def _uir_normalize_selector(self, selector):
        if selector is None:
            return None
        selector = str(selector).strip().lower()
        if selector in ("fallback", "receive", "constructor"):
            return selector
        if re.fullmatch(r"0x[0-9a-f]{8}", selector):
            return selector
        if re.fullmatch(r"[0-9a-f]{8}", selector):
            return "0x" + selector
        return selector

    def _uir_init_coverage(self):
        if not self._uir_enabled():
            return
        if hasattr(self.env, "uir_coverage"):
            return

        targets = self.env.uir_targets or {}
        functions = targets.get("functions_by_selector") or {}
        normalized = {}
        for selector, item in functions.items():
            norm = self._uir_normalize_selector(selector)
            if norm:
                normalized[norm] = item or {}
        self.env.uir_functions_by_selector = normalized

        relation_targets = []
        for rel in targets.get("relation_targets", []) or []:
            if not isinstance(rel, dict):
                continue
            rel2 = dict(rel)
            rel2["from_selector"] = self._uir_normalize_selector(rel2.get("from_selector"))
            rel2["to_selector"] = self._uir_normalize_selector(rel2.get("to_selector"))
            relation_targets.append(rel2)
        self.env.uir_relation_targets = relation_targets
        self.env.uir_dynamic_relation_targets = []
        self.env.uir_dynamic_relation_keys = set()

        self.env.uir_coverage = {
            "called_selectors": set(),
            "sensitive_selectors": set(),
            "access_guarded_selectors": set(),
            "access_anomaly_selectors": set(),
            "accounting_selectors": set(),
            "accounting_anomaly_selectors": set(),
            "state_transition_selectors": set(),
            "read_storage_vars": set(),
            "written_storage_vars": set(),
            "write_read_relations": set(),
            "cross_relations": set(),
            "dynamic_relations": set(),
            "guarded_selectors": set(),
            "guard_failures": 0,
            "invalid_transactions": 0,
        }
        self.env.uir_seed_profiles = {}
        self.env.uir_seed_archive = {
            "coverage_elite": {},
            "semantic_elite": {},
            "risk_elite": {},
            "soft_filtered": {},
            "all": {},
            "stats": {
                "coverage_elite": 0,
                "semantic_elite": 0,
                "risk_elite": 0,
                "soft_filtered": 0,
            },
        }

    def _uir_new_seed_profile(self, indv):
        if not self._uir_enabled():
            return None
        return {
            "seed_hash": indv.hash,
            "sequence_length": len(getattr(indv, "chromosome", []) or []),
            "called_selectors": [],
            "categories": set(),
            "read_storage_vars": set(),
            "written_storage_vars": set(),
            "matched_relations": set(),
            "matched_dynamic_relations": set(),
            "guarded_calls": 0,
            "guard_failures": 0,
            "invalid_transactions": 0,
            "reverted_transactions": 0,
            "touched_access_anomalies": set(),
            "touched_accounting_anomalies": set(),
            "touched_sensitive_functions": set(),
            "touched_state_transitions": set(),
            "invariant_risk_score": 0,
            "new_code_coverage": 0,
            "new_branch_coverage": 0,
            "new_uir_facts": {},
            "new_detector_findings": 0,
            "archive_labels": [],
            "soft_filter_reasons": [],
        }

    def _branch_signature(self):
        signature = set()
        for pc, branches in getattr(self.env, "visited_branches", {}).items():
            for condition in branches:
                signature.add("{}:{}".format(pc, condition))
        return signature

    def _uir_signature(self):
        if not self._uir_enabled():
            return {}
        self._uir_init_coverage()
        cov = self.env.uir_coverage
        keys = [
            "called_selectors",
            "sensitive_selectors",
            "access_guarded_selectors",
            "access_anomaly_selectors",
            "accounting_selectors",
            "accounting_anomaly_selectors",
            "state_transition_selectors",
            "read_storage_vars",
            "written_storage_vars",
            "write_read_relations",
            "cross_relations",
            "dynamic_relations",
            "guarded_selectors",
        ]
        return {key: set(cov.get(key, set())) for key in keys}

    def _uir_dynamic_relations_enabled(self):
        args = getattr(self.env, "args", None)
        return bool(getattr(args, "uir_dynamic_relations", False) and self._uir_enabled())

    def _uir_add_dynamic_relation(self, from_selector, to_selector, storage_slot):
        if not self._uir_dynamic_relations_enabled():
            return None
        self._uir_init_coverage()
        from_selector = self._uir_normalize_selector(from_selector)
        to_selector = self._uir_normalize_selector(to_selector)
        if not from_selector or not to_selector or from_selector == to_selector:
            return None

        slot_key = str(storage_slot)
        key = ("dynamic_relation", from_selector, to_selector, slot_key)
        dynamic_keys = getattr(self.env, "uir_dynamic_relation_keys", set())
        if key in dynamic_keys:
            return None

        relation = {
            "kind": "dynamic_relation",
            "from_function": None,
            "from_selector": from_selector,
            "to_function": None,
            "to_selector": to_selector,
            "storage_var": "slot:{}".format(slot_key),
            "storage_slot": slot_key,
            "reason": "runtime SSTORE->SLOAD slot dependency",
            "confidence": "low",
            "source": "dynamic_sload_sstore",
            "dynamic": True,
        }
        dynamic_keys.add(key)
        self.env.uir_dynamic_relation_keys = dynamic_keys
        self.env.uir_dynamic_relation_targets.append(relation)
        self.env.uir_relation_targets.append(relation)
        return relation

    def _uir_update_dynamic_relations_from_storage_access(self, selector, access_kind, storage_slot):
        if not self._uir_dynamic_relations_enabled():
            return
        selector = self._uir_normalize_selector(selector)
        if not selector:
            return
        deps = getattr(self.env, "data_dependencies", {}) or {}
        if access_kind == "read":
            for writer_selector, rw in deps.items():
                if writer_selector == selector:
                    continue
                if storage_slot in (rw.get("write") or set()):
                    self._uir_add_dynamic_relation(writer_selector, selector, storage_slot)
        elif access_kind == "write":
            for reader_selector, rw in deps.items():
                if reader_selector == selector:
                    continue
                if storage_slot in (rw.get("read") or set()):
                    self._uir_add_dynamic_relation(selector, reader_selector, storage_slot)

    def _detector_signature(self):
        errors = getattr(self.env, "results", {}).get("errors", {})
        if isinstance(errors, dict):
            return set(errors.keys())
        return set()

    def _uir_record_invalid_tx(self, profile):
        if not self._uir_enabled():
            return
        self._uir_init_coverage()
        self.env.uir_coverage["invalid_transactions"] += 1
        if profile is not None:
            profile["invalid_transactions"] += 1

    def _uir_record_executed_selector(self, profile, selector, result_is_error=False):
        if not self._uir_enabled():
            return
        self._uir_init_coverage()
        selector = self._uir_normalize_selector(selector)
        if not selector:
            return

        info = getattr(self.env, "uir_functions_by_selector", {}).get(selector)
        if not info:
            return

        cov = self.env.uir_coverage
        cov["called_selectors"].add(selector)
        if profile is not None:
            profile["called_selectors"].append(selector)

        categories = set(info.get("categories", []) or [])
        for category in categories:
            if profile is not None:
                profile["categories"].add(category)

        category_to_global = {
            "sensitive": "sensitive_selectors",
            "access_guarded": "access_guarded_selectors",
            "access_anomaly": "access_anomaly_selectors",
            "accounting": "accounting_selectors",
            "accounting_anomaly": "accounting_anomaly_selectors",
            "state_transition": "state_transition_selectors",
            "guarded": "guarded_selectors",
        }
        for category, key in category_to_global.items():
            if category in categories:
                cov[key].add(selector)

        for var in info.get("reads", []) or []:
            cov["read_storage_vars"].add(str(var))
            if profile is not None:
                profile["read_storage_vars"].add(str(var))
        for var in info.get("writes", []) or []:
            cov["written_storage_vars"].add(str(var))
            if profile is not None:
                profile["written_storage_vars"].add(str(var))

        if "guarded" in categories and profile is not None:
            profile["guarded_calls"] += 1
        if result_is_error:
            if profile is not None:
                profile["reverted_transactions"] += 1
            if "guarded" in categories:
                cov["guard_failures"] += 1
                if profile is not None:
                    profile["guard_failures"] += 1

        risk_score = 0
        if "sensitive" in categories:
            risk_score += 2
            if profile is not None:
                profile["touched_sensitive_functions"].add(selector)
        if "access_anomaly" in categories:
            risk_score += 3
            if profile is not None:
                profile["touched_access_anomalies"].add(selector)
        if "accounting_anomaly" in categories:
            risk_score += 3
            if profile is not None:
                profile["touched_accounting_anomalies"].add(selector)
        if "state_transition" in categories:
            risk_score += 1
            if profile is not None:
                profile["touched_state_transitions"].add(selector)
        if profile is not None:
            profile["invariant_risk_score"] += risk_score

    def _uir_finalize_seed_profile(self, profile, before_code=None, before_branches=None,
                                   before_uir=None, before_detectors=None):
        if not self._uir_enabled() or profile is None:
            return
        self._uir_init_coverage()
        selectors = profile.get("called_selectors", []) or []
        cov = self.env.uir_coverage

        for idx, left in enumerate(selectors):
            for right in selectors[idx + 1:]:
                for rel_idx, rel in enumerate(getattr(self.env, "uir_relation_targets", []) or []):
                    from_sel = rel.get("from_selector")
                    to_sel = rel.get("to_selector")
                    if from_sel and to_sel and left == from_sel and right == to_sel:
                        key = "{}:{}>{}:{}".format(
                            rel.get("kind") or "relation",
                            from_sel,
                            to_sel,
                            rel.get("storage_var") or "",
                        )
                        profile["matched_relations"].add(key)
                        if rel.get("kind") == "uir_write_read":
                            cov["write_read_relations"].add(key)
                        elif rel.get("kind") == "dynamic_relation":
                            profile["matched_dynamic_relations"].add(key)
                            cov["dynamic_relations"].add(key)
                        else:
                            cov["cross_relations"].add(key)

        self._uir_update_seed_archive(
            profile=profile,
            before_code=before_code,
            before_branches=before_branches,
            before_uir=before_uir,
            before_detectors=before_detectors,
        )

        jsonable = {}
        for key, value in profile.items():
            if isinstance(value, set):
                jsonable[key] = sorted(value, key=lambda x: str(x))
            else:
                jsonable[key] = value
        self.env.uir_seed_profiles[profile["seed_hash"]] = jsonable

    def _uir_update_seed_archive(self, profile, before_code=None, before_branches=None,
                                 before_uir=None, before_detectors=None):
        if not self._uir_enabled() or profile is None:
            return

        before_code = before_code if before_code is not None else set()
        before_branches = before_branches if before_branches is not None else set()
        before_uir = before_uir if before_uir is not None else {}
        before_detectors = before_detectors if before_detectors is not None else set()

        new_code = set(getattr(self.env, "code_coverage", set())) - set(before_code)
        new_branches = self._branch_signature() - set(before_branches)
        after_uir = self._uir_signature()
        new_uir = {}
        for key, values in after_uir.items():
            diff = set(values) - set(before_uir.get(key, set()))
            if diff:
                new_uir[key] = sorted(diff, key=lambda x: str(x))
        new_detectors = self._detector_signature() - set(before_detectors)

        profile["new_code_coverage"] = len(new_code)
        profile["new_branch_coverage"] = len(new_branches)
        profile["new_uir_facts"] = new_uir
        profile["new_detector_findings"] = len(new_detectors)

        labels = set()
        if new_code or new_branches:
            labels.add("coverage_elite")
        if new_uir or profile.get("matched_relations"):
            labels.add("semantic_elite")
        if (
            new_detectors
            or profile.get("touched_access_anomalies")
            or profile.get("touched_accounting_anomalies")
            or (profile.get("invariant_risk_score") or 0) >= 5
        ):
            labels.add("risk_elite")

        calls = len(profile.get("called_selectors", []) or [])
        unique_calls = len(set(profile.get("called_selectors", []) or []))
        sequence_length = int(profile.get("sequence_length") or 0)
        guard_failures = int(profile.get("guard_failures") or 0)
        reverted = int(profile.get("reverted_transactions") or 0)
        invalid = int(profile.get("invalid_transactions") or 0)
        no_progress = not new_code and not new_branches and not new_uir and not new_detectors

        soft_reasons = []
        if no_progress:
            soft_reasons.append("stale_no_coverage_or_uir_progress")
        if invalid:
            soft_reasons.append("invalid_transaction_heavy")
        if calls and guard_failures / max(calls, 1) >= 0.5 and not new_code and not new_branches:
            soft_reasons.append("guard_failure_heavy")
        if calls and reverted / max(calls, 1) >= 0.5 and not new_code and not new_branches:
            soft_reasons.append("revert_heavy")
        if sequence_length > 1 and unique_calls <= 1 and no_progress:
            soft_reasons.append("repetitive_single_function")
        if no_progress and (
            profile.get("touched_sensitive_functions")
            or profile.get("touched_state_transitions")
            or profile.get("touched_accounting_anomalies")
        ):
            soft_reasons.append("saturated_semantic_path")

        if soft_reasons:
            labels.add("soft_filtered")

        profile["archive_labels"] = sorted(labels)
        profile["soft_filter_reasons"] = soft_reasons

        archive = self.env.uir_seed_archive
        entry = {
            "seed_hash": profile.get("seed_hash"),
            "sequence_length": sequence_length,
            "called_selectors": list(profile.get("called_selectors", []) or []),
            "new_code_coverage": profile["new_code_coverage"],
            "new_branch_coverage": profile["new_branch_coverage"],
            "new_uir_facts": profile["new_uir_facts"],
            "new_detector_findings": profile["new_detector_findings"],
            "matched_relations": sorted(profile.get("matched_relations", set()), key=lambda x: str(x)),
            "matched_dynamic_relations": sorted(profile.get("matched_dynamic_relations", set()), key=lambda x: str(x)),
            "guard_failures": guard_failures,
            "reverted_transactions": reverted,
            "invalid_transactions": invalid,
            "invariant_risk_score": profile.get("invariant_risk_score", 0),
            "archive_labels": profile["archive_labels"],
            "soft_filter_reasons": soft_reasons,
        }
        archive["all"][profile["seed_hash"]] = entry
        if "coverage_elite" in labels:
            archive["coverage_elite"][profile["seed_hash"]] = entry
        if "semantic_elite" in labels:
            archive["semantic_elite"][profile["seed_hash"]] = entry
        if "risk_elite" in labels:
            archive["risk_elite"][profile["seed_hash"]] = entry
        if "soft_filtered" in labels:
            archive["soft_filtered"][profile["seed_hash"]] = entry

        archive["stats"] = {
            "coverage_elite": len(archive["coverage_elite"]),
            "semantic_elite": len(archive["semantic_elite"]),
            "risk_elite": len(archive["risk_elite"]),
            "soft_filtered": len(archive["soft_filtered"]),
            "all": len(archive["all"]),
        }

    def _uir_summary(self):
        if not self._uir_enabled():
            return None
        self._uir_init_coverage()
        targets = self.env.uir_targets or {}
        goals = targets.get("coverage_goals") or {}
        cov = self.env.uir_coverage

        def ratio(covered, total):
            total = int(total or 0)
            if total <= 0:
                return None
            return round((len(covered) / total) * 100, 2)

        summary = {
            "target_path": getattr(self.env, "uir_targets_path", None),
            "coverage_goals": goals,
            "covered": {
                "called_functions": len(cov["called_selectors"]),
                "sensitive_functions": len(cov["sensitive_selectors"]),
                "access_guarded_functions": len(cov["access_guarded_selectors"]),
                "access_anomalies": len(cov["access_anomaly_selectors"]),
                "accounting_functions": len(cov["accounting_selectors"]),
                "accounting_anomalies": len(cov["accounting_anomaly_selectors"]),
                "state_transition_functions": len(cov["state_transition_selectors"]),
                "read_storage_vars": len(cov["read_storage_vars"]),
                "written_storage_vars": len(cov["written_storage_vars"]),
                "write_read_relations": len(cov["write_read_relations"]),
                "cross_relations": len(cov["cross_relations"]),
                "dynamic_relations": len(cov["dynamic_relations"]),
                "dynamic_relation_targets": len(getattr(self.env, "uir_dynamic_relation_targets", []) or []),
                "guarded_functions": len(cov["guarded_selectors"]),
                "guard_failures": cov["guard_failures"],
                "invalid_transactions": cov["invalid_transactions"],
            },
            "percentages": {
                "sensitive_functions": ratio(cov["sensitive_selectors"], goals.get("sensitive_functions")),
                "access_guarded_functions": ratio(cov["access_guarded_selectors"], goals.get("access_guarded_functions")),
                "access_anomalies": ratio(cov["access_anomaly_selectors"], goals.get("access_anomalies")),
                "accounting_functions": ratio(cov["accounting_selectors"], goals.get("accounting_functions")),
                "accounting_anomalies": ratio(cov["accounting_anomaly_selectors"], goals.get("accounting_anomalies")),
                "state_transition_functions": ratio(cov["state_transition_selectors"], goals.get("state_transition_functions")),
                "write_read_relations": ratio(cov["write_read_relations"], goals.get("write_read_relations")),
                "cross_relations": ratio(cov["cross_relations"], goals.get("cross_relations")),
            },
            "details": {
                "called_selectors": sorted(cov["called_selectors"], key=lambda x: str(x)),
                "sensitive_selectors": sorted(cov["sensitive_selectors"], key=lambda x: str(x)),
                "access_anomaly_selectors": sorted(cov["access_anomaly_selectors"], key=lambda x: str(x)),
                "accounting_anomaly_selectors": sorted(cov["accounting_anomaly_selectors"], key=lambda x: str(x)),
                "state_transition_selectors": sorted(cov["state_transition_selectors"], key=lambda x: str(x)),
                "read_storage_vars": sorted(cov["read_storage_vars"], key=lambda x: str(x)),
                "written_storage_vars": sorted(cov["written_storage_vars"], key=lambda x: str(x)),
                "write_read_relations": sorted(cov["write_read_relations"], key=lambda x: str(x)),
                "cross_relations": sorted(cov["cross_relations"], key=lambda x: str(x)),
                "dynamic_relations": sorted(cov["dynamic_relations"], key=lambda x: str(x)),
                "dynamic_relation_targets": getattr(self.env, "uir_dynamic_relation_targets", []) or [],
            },
            "archive_stats": (getattr(self.env, "uir_seed_archive", {}) or {}).get("stats", {}),
        }
        return summary

    def _uir_semantic_progress_count(self):
        if not self._uir_enabled():
            return 0
        self._uir_init_coverage()
        cov = self.env.uir_coverage
        keys = [
            "called_selectors",
            "sensitive_selectors",
            "access_guarded_selectors",
            "access_anomaly_selectors",
            "accounting_selectors",
            "accounting_anomaly_selectors",
            "state_transition_selectors",
            "read_storage_vars",
            "written_storage_vars",
            "write_read_relations",
            "cross_relations",
            "guarded_selectors",
        ]
        return sum(len(cov.get(key, set()) or set()) for key in keys)

    def _uir_solving_enabled(self):
        args = getattr(self.env, "args", None)
        return bool(
            getattr(args, "uir_solving", False)
            and getattr(args, "constraint_solving", False)
            and self._uir_enabled()
        )

    def _uir_solving_stats(self):
        if not hasattr(self.env, "uir_solving_stats"):
            self.env.uir_solving_stats = {
                "triggered": 0,
                "skipped": 0,
                "by_reason": {},
                "last_reasons": [],
            }
        return self.env.uir_solving_stats

    def _uir_record_solving_trigger(self, reasons):
        stats = self._uir_solving_stats()
        stats["triggered"] = stats.get("triggered", 0) + 1
        stats["last_reasons"] = list(reasons)
        stats.setdefault("by_reason", {})
        for reason in reasons:
            stats["by_reason"][reason] = stats["by_reason"].get(reason, 0) + 1

    def _symbolic_execution_stats(self):
        if not hasattr(self.env, "symbolic_execution_stats"):
            self.env.symbolic_execution_stats = {
                "calls": 0,
                "attempted": 0,
                "sat": 0,
                "unsat": 0,
                "unknown": 0,
                "timeout": 0,
                "models": 0,
                "model_variables": 0,
                "abi_constraints_added": 0,
                "abi_constraints_skipped": 0,
                "total_solve_time_ms": 0.0,
                "max_solve_time_ms": 0.0,
                "last_call": {},
                "recent_attempts": [],
                "triggered_by": {},
                "priority": {
                    "mode": "legacy",
                    "uses": 0,
                    "last_top": [],
                },
                "targeted_seeds": {
                    "enabled": False,
                    "generated": 0,
                    "queued": 0,
                    "injected": 0,
                    "invalid": 0,
                    "dropped_duplicate": 0,
                    "dropped_queue_full": 0,
                    "dropped_low_value": 0,
                    "queue_size": 0,
                    "last_injected": [],
                },
                "skipped": {
                    "multi_branch_pc": 0,
                    "no_expression": 0,
                    "memoized": 0,
                    "cooldown": 0,
                    "branch_budget": 0,
                    "time_budget": 0,
                    "path_condition_budget": 0,
                    "variable_budget": 0,
                },
                "budget": {},
            }
        stats = self.env.symbolic_execution_stats
        stats.setdefault("skipped", {})
        stats.setdefault("recent_attempts", [])
        stats.setdefault("budget", {})
        stats.setdefault("triggered_by", {})
        stats.setdefault("priority", {"mode": "legacy", "uses": 0, "last_top": []})
        stats.setdefault("targeted_seeds", {
            "enabled": False,
            "generated": 0,
            "queued": 0,
            "injected": 0,
            "invalid": 0,
            "dropped_duplicate": 0,
            "dropped_queue_full": 0,
            "dropped_low_value": 0,
            "queue_size": 0,
            "last_injected": [],
        })
        return stats

    def _symbolic_stats_record_trigger(self, reasons):
        stats = self._symbolic_execution_stats()
        triggered_by = stats.setdefault("triggered_by", {})
        for reason in reasons or ["legacy_code_coverage_plateau"]:
            triggered_by[reason] = triggered_by.get(reason, 0) + 1

    def _symbolic_stats_add_skip(self, reason, count=1):
        stats = self._symbolic_execution_stats()
        skipped = stats.setdefault("skipped", {})
        skipped[reason] = skipped.get(reason, 0) + count

    def _symbolic_stats_add_attempt(self, attempt):
        stats = self._symbolic_execution_stats()
        trace_limit = int(getattr(self.env.args, "solver_stats_trace_limit", 100) or 0)
        if trace_limit <= 0:
            return
        recent = stats.setdefault("recent_attempts", [])
        recent.append(attempt)
        if len(recent) > trace_limit:
            del recent[:len(recent) - trace_limit]

    def _symbolic_recent_failure_counts(self):
        stats = self._symbolic_execution_stats()
        counts = {}
        for attempt in stats.get("recent_attempts", []) or []:
            if attempt.get("result") not in ("unsat", "unknown", "timeout"):
                continue
            pc = attempt.get("pc")
            branch = attempt.get("branch")
            if pc is None or branch is None:
                continue
            key = "{}:{}".format(pc, branch)
            counts[key] = counts.get(key, 0) + 1
        return counts

    def _symbolic_expression_vars(self, expressions):
        variables = {}
        for expression in expressions or []:
            try:
                for variable in get_vars(expression):
                    variables[str(variable)] = variable
            except Exception:
                continue
        return variables

    def _abi_base_type(self, abi_type):
        abi_type = str(abi_type or "").replace(" storage", "").replace(" memory", "")
        if "[" in abi_type:
            abi_type = abi_type.split("[", 1)[0]
        return abi_type

    def _add_uint_bound(self, variable, bits):
        if bits >= 256:
            return 0
        self.env.solver.add(ULT(variable, BitVecVal(1 << bits, 256)))
        return 1

    def _add_int_bound(self, variable, bits):
        if bits >= 256:
            return 0
        lower = -(1 << (bits - 1))
        upper = (1 << (bits - 1)) - 1
        self.env.solver.add(variable >= BitVecVal(lower, 256))
        self.env.solver.add(variable <= BitVecVal(upper, 256))
        return 2

    def _add_abi_constraints(self, branch_data, expressions, indv_generator):
        if not bool(getattr(self.env.args, "solver_abi_constraints", False)):
            return 0, 0

        added = 0
        skipped = 0
        chromosome = branch_data.get("chromosome") or []
        variables = self._symbolic_expression_vars(expressions)
        for name, variable in variables.items():
            parts = name.split("_")
            if len(parts) < 2:
                skipped += 1
                continue
            try:
                transaction_index = int(parts[1])
            except Exception:
                skipped += 1
                continue
            if transaction_index < 0 or transaction_index >= len(chromosome):
                skipped += 1
                continue

            gene = chromosome[transaction_index]
            function_hash = gene.get("arguments", [None])[0]

            try:
                if name.startswith("calldataload_") or name.startswith("calldatacopy_"):
                    if len(parts) < 3 or function_hash not in indv_generator.interface:
                        skipped += 1
                        continue
                    parameter_index = int(parts[2])
                    if parameter_index >= len(indv_generator.interface[function_hash]):
                        skipped += 1
                        continue
                    abi_type = self._abi_base_type(indv_generator.interface[function_hash][parameter_index])
                    if abi_type == "bool":
                        self.env.solver.add(Or(variable == BitVecVal(0, 256), variable == BitVecVal(1, 256)))
                        added += 1
                    elif abi_type == "address":
                        self.env.solver.add(ULT(variable, BitVecVal(1 << 160, 256)))
                        added += 1
                    elif abi_type.startswith("uint"):
                        bits = 256 if abi_type == "uint" else int(abi_type.replace("uint", ""))
                        added += self._add_uint_bound(variable, bits)
                    elif abi_type.startswith("int"):
                        bits = 256 if abi_type == "int" else int(abi_type.replace("int", ""))
                        added += self._add_int_bound(variable, bits)
                    else:
                        skipped += 1
                elif name.startswith("caller_"):
                    self.env.solver.add(ULT(variable, BitVecVal(1 << 160, 256)))
                    added += 1
                elif name.startswith("callvalue_"):
                    self.env.solver.add(ULE(variable, BitVecVal(int(settings.ACCOUNT_BALANCE), 256)))
                    added += 1
                elif name.startswith("gas_"):
                    gas_cap = max(int(settings.GAS_LIMIT), int((gene or {}).get("gaslimit") or 0), 1) * 4
                    self.env.solver.add(ULE(variable, BitVecVal(gas_cap, 256)))
                    added += 1
                elif name.startswith("call_") or name.startswith("staticcall_"):
                    self.env.solver.add(Or(variable == BitVecVal(0, 256), variable == BitVecVal(1, 256)))
                    added += 1
                elif name.startswith("extcodesize") or name.startswith("returndatasize"):
                    self.env.solver.add(ULE(variable, BitVecVal(2 ** 32, 256)))
                    added += 1
                else:
                    skipped += 1
            except Exception:
                skipped += 1

        stats = self._symbolic_execution_stats()
        stats["abi_constraints_added"] = stats.get("abi_constraints_added", 0) + added
        stats["abi_constraints_skipped"] = stats.get("abi_constraints_skipped", 0) + skipped
        return added, skipped

    def _update_high_risk_branch_ages(self):
        if not hasattr(self.env, "high_risk_branch_ages"):
            self.env.high_risk_branch_ages = {}

        active = {}
        for pc, visited_at_pc in getattr(self.env, "visited_branches", {}).items():
            if len(visited_at_pc) != 1:
                continue
            branch, branch_data = next(iter(visited_at_pc.items()))
            if not branch_data or not branch_data.get("expression"):
                continue
            if self._uir_symbolic_priority(branch_data) <= 0:
                continue
            key = "{}:{}".format(pc, branch)
            active[key] = {
                "pc": pc,
                "branch": branch,
                "selector": branch_data.get("function_selector"),
                "uir_categories": list(branch_data.get("uir_categories", []) or []),
                "uir_risk_tags": list(branch_data.get("uir_risk_tags", []) or []),
                "age": int(self.env.high_risk_branch_ages.get(key, {}).get("age", 0)) + 1,
            }

        self.env.high_risk_branch_ages = active
        return active

    def _targeted_seed_enabled(self):
        return bool(getattr(self.env.args, "solver_targeted_seeds", False))

    def _targeted_seed_stats(self):
        stats = self._symbolic_execution_stats()
        targeted = stats.setdefault("targeted_seeds", {})
        targeted["enabled"] = self._targeted_seed_enabled()
        targeted.setdefault("generated", 0)
        targeted.setdefault("queued", 0)
        targeted.setdefault("injected", 0)
        targeted.setdefault("invalid", 0)
        targeted.setdefault("dropped_duplicate", 0)
        targeted.setdefault("dropped_queue_full", 0)
        targeted.setdefault("dropped_low_value", 0)
        targeted.setdefault("queue_size", len(getattr(self.env, "solver_seed_queue", []) or []))
        targeted.setdefault("last_injected", [])
        return targeted

    def _targeted_seed_mode(self):
        return str(getattr(self.env.args, "solver_targeted_seed_mode", "all") or "all").lower()

    def _targeted_seed_has_direct_value(self, changes):
        value_fields = {"argument", "account", "call_return", "extcodesize", "returndatasize"}
        return any((change or {}).get("field") in value_fields for change in changes or [])

    def _model_value_as_long(self, model, variable, signed=False):
        value = model[variable]
        if value is None:
            return None
        try:
            return int(value.as_signed_long() if signed else value.as_long())
        except Exception:
            try:
                return int(str(value), 0)
            except Exception:
                return None

    def _apply_model_value_to_gene(self, chromosome, variable, model, indv_generator):
        name = str(variable)
        if name.startswith("underflow") or name.startswith("calldatasize"):
            return None

        parts = name.split("_")
        if len(parts) < 2:
            return None
        try:
            transaction_index = int(parts[1])
        except Exception:
            return None
        if transaction_index < 0 or transaction_index >= len(chromosome):
            return None

        gene = chromosome[transaction_index]
        function_hash = gene.get("arguments", [None])[0]

        if name.startswith("caller_"):
            raw = self._model_value_as_long(model, variable)
            if raw is None or raw <= 8 or raw >= 2**160:
                return None
            account_address = normalize_32_byte_hex_address("0x" + hex(raw).replace("0x", "").zfill(40))
            if not self.env.instrumented_evm.has_account(account_address):
                self.env.instrumented_evm.restore_from_snapshot()
                self.env.instrumented_evm.accounts.append(self.env.instrumented_evm.create_fake_account(account_address))
                self.env.instrumented_evm.create_snapshot()
            gene["account"] = account_address
            return {"field": "account", "tx": transaction_index, "value": account_address}

        if name.startswith("callvalue_"):
            amount = self._model_value_as_long(model, variable)
            if amount is None:
                return None
            if amount > settings.ACCOUNT_BALANCE:
                amount = settings.ACCOUNT_BALANCE
            gene["amount"] = max(0, int(amount))
            return {"field": "amount", "tx": transaction_index, "value": gene["amount"]}

        if name.startswith("gas_"):
            gaslimit = self._model_value_as_long(model, variable)
            if gaslimit is None:
                return None
            gene["gaslimit"] = max(0, int(gaslimit))
            return {"field": "gaslimit", "tx": transaction_index, "value": gene["gaslimit"]}

        if name.startswith("timestamp"):
            timestamp = self._model_value_as_long(model, variable)
            if timestamp is None:
                return None
            gene["timestamp"] = int(timestamp)
            return {"field": "timestamp", "tx": transaction_index, "value": gene["timestamp"]}

        if name.startswith("blocknumber"):
            blocknumber = self._model_value_as_long(model, variable)
            if blocknumber is None:
                return None
            gene["blocknumber"] = int(blocknumber)
            return {"field": "blocknumber", "tx": transaction_index, "value": gene["blocknumber"]}

        if name.startswith("balance"):
            balance = self._model_value_as_long(model, variable)
            if balance is None:
                return None
            gene["balance"] = max(0, int(balance))
            return {"field": "balance", "tx": transaction_index, "value": gene["balance"]}

        if name.startswith("calldataload_") or name.startswith("calldatacopy_"):
            if len(parts) < 3 or function_hash not in indv_generator.interface:
                return None
            try:
                parameter_index = int(parts[2])
            except Exception:
                return None
            if parameter_index >= len(indv_generator.interface[function_hash]):
                return None
            argument_type = indv_generator.interface[function_hash][parameter_index]
            if argument_type.startswith("int"):
                argument = self._model_value_as_long(model, variable, signed=True)
            elif argument_type == "address" or argument_type.startswith("address"):
                raw = self._model_value_as_long(model, variable)
                if raw is None:
                    return None
                try:
                    argument = normalize_32_byte_hex_address(hex(raw))
                    if not self.env.instrumented_evm.has_account(argument):
                        self.env.instrumented_evm.restore_from_snapshot()
                        self.env.instrumented_evm.accounts.append(self.env.instrumented_evm.create_fake_account(argument))
                        self.env.instrumented_evm.create_snapshot()
                except Exception:
                    return None
            elif argument_type == "string":
                return None
            elif argument_type.startswith("uint"):
                raw = self._model_value_as_long(model, variable)
                if raw is None:
                    return None
                bits = 256
                if argument_type != "uint":
                    try:
                        bits = int(argument_type.replace("uint", ""))
                    except Exception:
                        bits = 256
                argument = int(raw) % (1 << bits)
            else:
                argument = self._model_value_as_long(model, variable)
                if argument is None:
                    return None
            if len(gene.get("arguments", [])) <= parameter_index + 1:
                return None
            gene["arguments"][parameter_index + 1] = argument
            return {"field": "argument", "tx": transaction_index, "index": parameter_index, "value": argument}

        if name.startswith("call_") or name.startswith("staticcall_"):
            if len(parts) < 4:
                return None
            address = to_normalized_address(parts[2])
            result = self._model_value_as_long(model, variable)
            if result is None:
                old_result = int(parts[3], 16)
                result = 1 - old_result
            gene.setdefault("call_return", {})
            gene["call_return"][address] = int(result)
            return {"field": "call_return", "tx": transaction_index, "address": address, "value": int(result)}

        if name.startswith("extcodesize"):
            if len(parts) < 3:
                return None
            address = to_normalized_address(parts[2])
            size = self._model_value_as_long(model, variable)
            if size is None:
                return None
            gene.setdefault("extcodesize", {})
            gene["extcodesize"][address] = int(size)
            return {"field": "extcodesize", "tx": transaction_index, "address": address, "value": int(size)}

        if name.startswith("returndatasize"):
            if len(parts) < 3:
                return None
            address = to_normalized_address(parts[2])
            size = self._model_value_as_long(model, variable)
            if size is None:
                return None
            gene.setdefault("returndatasize", {})
            gene["returndatasize"][address] = int(size)
            return {"field": "returndatasize", "tx": transaction_index, "address": address, "value": int(size)}

        return None

    def _queue_targeted_seed_from_model(self, branch_data, pc, model, indv_generator, priority_score=None):
        targeted = self._targeted_seed_stats()
        if not self._targeted_seed_enabled():
            return

        targeted["generated"] = targeted.get("generated", 0) + 1
        chromosome = deepcopy(branch_data.get("chromosome") or [])
        changes = []
        for variable in model:
            change = self._apply_model_value_to_gene(chromosome, variable, model, indv_generator)
            if change is not None:
                changes.append(change)

        if not changes:
            targeted["invalid"] = targeted.get("invalid", 0) + 1
            return

        if self._targeted_seed_mode() == "valuable" and not self._targeted_seed_has_direct_value(changes):
            targeted["dropped_low_value"] = targeted.get("dropped_low_value", 0) + 1
            return

        key = str(chromosome)
        if not hasattr(self.env, "solver_seed_seen"):
            self.env.solver_seed_seen = set()
        if key in self.env.solver_seed_seen:
            targeted["dropped_duplicate"] = targeted.get("dropped_duplicate", 0) + 1
            return

        if not hasattr(self.env, "solver_seed_queue"):
            self.env.solver_seed_queue = []
        max_queue = int(getattr(self.env.args, "solver_targeted_seed_queue", 16) or 0)
        if max_queue > 0 and len(self.env.solver_seed_queue) >= max_queue:
            targeted["dropped_queue_full"] = targeted.get("dropped_queue_full", 0) + 1
            return

        self.env.solver_seed_seen.add(key)
        self.env.solver_seed_queue.append({
            "chromosome": chromosome,
            "metadata": {
                "pc": pc,
                "indv_hash": branch_data.get("indv_hash"),
                "selector": branch_data.get("function_selector"),
                "changes": changes[:10],
                "priority_score": priority_score,
            },
        })
        targeted["queued"] = targeted.get("queued", 0) + 1
        targeted["queue_size"] = len(self.env.solver_seed_queue)

    def _inject_targeted_seeds(self, population):
        targeted = self._targeted_seed_stats()
        if not self._targeted_seed_enabled():
            targeted["queue_size"] = len(getattr(self.env, "solver_seed_queue", []) or [])
            return
        queue = getattr(self.env, "solver_seed_queue", []) or []
        if not queue:
            targeted["queue_size"] = 0
            return

        limit = int(getattr(self.env.args, "solver_targeted_seed_injection", 2) or 0)
        if limit <= 0:
            targeted["queue_size"] = len(queue)
            return

        IndvType = population.indv_template.__class__
        injected = []
        while queue and len(injected) < limit:
            entry = queue.pop(0)
            try:
                indv = IndvType(generator=population.indv_generator).init(chromosome=deepcopy(entry["chromosome"]))
            except (Exception, SystemExit):
                targeted["invalid"] = targeted.get("invalid", 0) + 1
                continue
            injected.append((indv, entry.get("metadata", {})))

        if injected:
            for idx, (indv, _) in enumerate(injected):
                if idx < len(population.individuals):
                    population.individuals[idx] = indv
                else:
                    population.individuals.append(indv)
            targeted["injected"] = targeted.get("injected", 0) + len(injected)
            targeted["last_injected"] = [metadata for _, metadata in injected]

        self.env.solver_seed_queue = queue
        targeted["queue_size"] = len(queue)

    def _vulnerability_hints_enabled(self):
        return bool(getattr(getattr(self.env, "args", None), "vulnerability_hints", False))

    def _report_artifact_writes_disabled(self):
        args = getattr(self.env, "args", None)
        return bool(
            getattr(args, "detector_replay_oracle", False)
            or str(os.getenv("SEMINV_DETECTOR_REPLAY_ORACLE", "")).strip().lower() in ("1", "true", "yes")
        )

    def _vulnerability_hint_stats(self):
        if not hasattr(self.env, "vulnerability_hint_stats"):
            self.env.vulnerability_hint_stats = {
                "generated": 0,
                "queued": 0,
                "injected": 0,
                "invalid": 0,
                "dropped_duplicate": 0,
                "dropped_queue_full": 0,
                "queue_size": 0,
                "by_kind": {},
            }
        return self.env.vulnerability_hint_stats

    def _vulnerability_hint_config(self):
        args = getattr(self.env, "args", None)
        return {
            "enabled": self._vulnerability_hints_enabled(),
            "static_probe_limit": int(getattr(args, "vulnerability_hint_static_probes", 0) or 0),
            "injection_per_generation": int(getattr(args, "vulnerability_hint_injection", 0) or 0),
            "queue_limit": int(getattr(args, "vulnerability_hint_queue", 0) or 0),
        }

    def _vulnerability_hint_snapshot(self):
        if self._vulnerability_hints_enabled():
            stats = deepcopy(self._vulnerability_hint_stats())
        else:
            stats = deepcopy(getattr(self.env, "vulnerability_hint_stats", {}) or {})
        queue = getattr(self.env, "vulnerability_hint_queue", []) or []
        stats.setdefault("generated", 0)
        stats.setdefault("queued", 0)
        stats.setdefault("injected", 0)
        stats.setdefault("invalid", 0)
        stats.setdefault("dropped_duplicate", 0)
        stats.setdefault("dropped_queue_full", 0)
        stats.setdefault("by_kind", {})
        stats["queue_size"] = len(queue)
        stats["dropped_total"] = (
            int(stats.get("invalid", 0) or 0)
            + int(stats.get("dropped_duplicate", 0) or 0)
            + int(stats.get("dropped_queue_full", 0) or 0)
        )
        static_probe_stats = deepcopy(getattr(self.env, "vulnerability_hint_static_probes", {}) or {})
        stats["static_probes"] = {
            "generated": int(static_probe_stats.get("generated", 0) or 0),
            "by_kind": static_probe_stats.get("by_kind", {}) or {},
        }
        return stats

    def _write_vulnerability_hint_stats(self, meta_dir, uir_summary=None):
        if self._report_artifact_writes_disabled():
            return None
        if not self._vulnerability_hints_enabled() and not hasattr(self.env, "vulnerability_hint_stats"):
            return None
        payload = {
            "schema_version": "semantic-invariant.guidance.v1",
            "contract": getattr(self.env, "contract_name", None),
            "target_path": getattr(self.env, "uir_targets_path", None),
            "config": self._vulnerability_hint_config(),
            "stats": self._vulnerability_hint_snapshot(),
            "uir_coverage_summary": uir_summary or {},
        }
        (meta_dir / "vulnerability_hint_stats.json").write_text(
            json.dumps(payload, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
        return payload

    def _calldata_vars_from_taint_entry(self, entry):
        variables = []
        if not entry:
            return variables
        items = entry if isinstance(entry, (list, tuple, set)) else [entry]
        for item in items:
            try:
                expr_vars = get_vars(item) if is_expr(item) else [item]
            except Exception:
                expr_vars = [item]
            for var in expr_vars:
                text = str(var)
                if text.startswith("calldataload_") or text.startswith("calldatacopy_"):
                    parts = text.split("_")
                    if len(parts) >= 3:
                        try:
                            variables.append((int(parts[-2]), int(parts[-1]), text))
                        except Exception:
                            pass
        return variables

    def _queue_vulnerability_hint_seed(self, chromosome, kind, metadata=None):
        if not self._vulnerability_hints_enabled():
            return
        stats = self._vulnerability_hint_stats()
        stats["generated"] = stats.get("generated", 0) + 1
        stats.setdefault("by_kind", {})
        stats["by_kind"][kind] = stats["by_kind"].get(kind, 0) + 1

        if not chromosome:
            stats["invalid"] = stats.get("invalid", 0) + 1
            return

        key = str(chromosome)
        if not hasattr(self.env, "vulnerability_hint_seen"):
            self.env.vulnerability_hint_seen = set()
        if key in self.env.vulnerability_hint_seen:
            stats["dropped_duplicate"] = stats.get("dropped_duplicate", 0) + 1
            return

        if not hasattr(self.env, "vulnerability_hint_queue"):
            self.env.vulnerability_hint_queue = []
        max_queue = int(getattr(self.env.args, "vulnerability_hint_queue", 32) or 0)
        if max_queue > 0 and len(self.env.vulnerability_hint_queue) >= max_queue:
            stats["dropped_queue_full"] = stats.get("dropped_queue_full", 0) + 1
            return

        self.env.vulnerability_hint_seen.add(key)
        self.env.vulnerability_hint_queue.append({
            "chromosome": chromosome,
            "metadata": metadata or {},
            "kind": kind,
        })
        stats["queued"] = stats.get("queued", 0) + 1
        stats["queue_size"] = len(self.env.vulnerability_hint_queue)

    def _clone_gene_for_vulnerability_hint(self, indv, transaction_index, kind):
        if transaction_index >= len(indv.chromosome):
            return None, None
        chromosome = deepcopy(indv.chromosome)
        gene = chromosome[transaction_index]
        gene["__origin__"] = "vulnerability_hint"
        gene["__vulnerability_hint__"] = kind
        return chromosome, gene

    def _queue_numeric_boundary_hints(self, indv, variables, kind, pc=None):
        for tx_index, parameter_index, variable_name in variables[:2]:
            if tx_index >= len(indv.chromosome):
                continue
            for value in [1, 2, 10, (1 << 128) - 1, 1 << 128, (1 << 128) + 1, (1 << 256) - 2]:
                chromosome, gene = self._clone_gene_for_vulnerability_hint(indv, tx_index, kind)
                if gene is None:
                    continue
                args = gene.get("arguments")
                if not isinstance(args, list) or parameter_index + 1 >= len(args):
                    continue
                args[parameter_index + 1] = value
                self._queue_vulnerability_hint_seed(chromosome, kind, {
                    "pc": pc,
                    "tx": tx_index,
                    "parameter_index": parameter_index,
                    "variable": variable_name,
                    "value": value,
                })

    def _queue_call_result_hints(self, indv, transaction_index, instruction, result, trace_index):
        try:
            address = to_hex(force_bytes_to_address(
                int_to_big_endian(convert_stack_value_to_int(result.trace[trace_index]["stack"][-2]))
            ))
        except Exception:
            return
        for field, values in (("call_return", [0, 1]), ("extcodesize", [0, 1]), ("returndatasize", [0, 32])):
            for value in values:
                chromosome, gene = self._clone_gene_for_vulnerability_hint(indv, transaction_index, field)
                if gene is None:
                    continue
                gene.setdefault(field, {})
                gene[field][address] = value
                self._queue_vulnerability_hint_seed(chromosome, field, {
                    "pc": instruction.get("pc"),
                    "tx": transaction_index,
                    "address": address,
                    "value": value,
                })

    def _queue_environment_hints(self, indv, transaction_index, kind, field, pc=None):
        for value in [0, 1, 2, 10, (1 << 32) - 1, 1 << 32]:
            chromosome, gene = self._clone_gene_for_vulnerability_hint(indv, transaction_index, kind)
            if gene is None:
                continue
            gene[field] = value
            self._queue_vulnerability_hint_seed(chromosome, kind, {
                "pc": pc,
                "tx": transaction_index,
                "field": field,
                "value": value,
            })

    def _queue_caller_hints(self, indv, transaction_index, kind, pc=None):
        accounts = list(getattr(getattr(indv, "generator", None), "accounts", []) or [])
        if not accounts:
            return
        for account in accounts[:4]:
            chromosome, gene = self._clone_gene_for_vulnerability_hint(indv, transaction_index, kind)
            if gene is None:
                continue
            gene["account"] = account
            self._queue_vulnerability_hint_seed(chromosome, kind, {
                "pc": pc,
                "tx": transaction_index,
                "account": account,
            })

    def _maybe_record_vulnerability_hint(self, indv, transaction_index, transaction, instruction, tainted_record, result, trace_index):
        if not self._vulnerability_hints_enabled():
            return
        op = instruction.get("op")
        pc = instruction.get("pc")

        if op == "SSTORE" and tainted_record and getattr(tainted_record, "stack", None):
            entries = []
            if len(tainted_record.stack) >= 1:
                entries.extend(self._calldata_vars_from_taint_entry(tainted_record.stack[-1]))
            if len(tainted_record.stack) >= 2:
                entries.extend(self._calldata_vars_from_taint_entry(tainted_record.stack[-2]))
            self._queue_numeric_boundary_hints(indv, entries, "sstore_calldata_boundary", pc=pc)

        elif op in ("CALL", "STATICCALL", "CALLCODE", "DELEGATECALL"):
            self._queue_call_result_hints(indv, transaction_index, instruction, result, trace_index)

        elif op in ("SELFDESTRUCT", "SUICIDE"):
            self._queue_caller_hints(indv, transaction_index, "selfdestruct_caller", pc=pc)

        elif op == "CALLVALUE":
            for value in [0, 1, 2, 10]:
                chromosome, gene = self._clone_gene_for_vulnerability_hint(indv, transaction_index, "callvalue_boundary")
                if gene is None:
                    continue
                gene["amount"] = value
                self._queue_vulnerability_hint_seed(chromosome, "callvalue_boundary", {
                    "pc": pc,
                    "tx": transaction_index,
                    "value": value,
                })

        elif op in ("TIMESTAMP", "BLOCKHASH"):
            self._queue_environment_hints(indv, transaction_index, "timestamp_boundary", "timestamp", pc=pc)

        elif op == "NUMBER":
            self._queue_environment_hints(indv, transaction_index, "blocknumber_boundary", "blocknumber", pc=pc)

    def _inject_vulnerability_hint_seeds(self, population):
        if not self._vulnerability_hints_enabled():
            return
        stats = self._vulnerability_hint_stats()
        queue = getattr(self.env, "vulnerability_hint_queue", []) or []
        if not queue:
            stats["queue_size"] = 0
            return

        limit = int(getattr(self.env.args, "vulnerability_hint_injection", 2) or 0)
        if limit <= 0:
            stats["queue_size"] = len(queue)
            return

        IndvType = population.indv_template.__class__
        injected = []
        while queue and len(injected) < limit:
            entry = queue.pop(0)
            try:
                indv = IndvType(generator=population.indv_generator).init(chromosome=deepcopy(entry["chromosome"]))
            except (Exception, SystemExit):
                stats["invalid"] = stats.get("invalid", 0) + 1
                continue
            injected.append((indv, entry))

        if injected:
            for idx, (indv, _) in enumerate(injected):
                if idx < len(population.individuals):
                    population.individuals[idx] = indv
                else:
                    population.individuals.append(indv)
            stats["injected"] = stats.get("injected", 0) + len(injected)
            stats["last_injected"] = [
                {"kind": entry.get("kind"), "metadata": entry.get("metadata", {})}
                for _, entry in injected
            ]

        self.env.vulnerability_hint_queue = queue
        stats["queue_size"] = len(queue)

    def _uir_high_value_uncovered(self):
        if not self._uir_enabled():
            return []
        self._uir_init_coverage()
        cov = self.env.uir_coverage
        uncovered = []
        for selector, info in getattr(self.env, "uir_functions_by_selector", {}).items():
            categories = set(info.get("categories", []) or [])
            risk_tags = set(info.get("risk_tags", []) or [])
            high_value = bool(categories.intersection({
                "sensitive", "access_anomaly", "accounting_anomaly", "state_transition"
            }) or risk_tags.intersection({
                "sensitive_function", "access_anomaly", "accounting_anomaly", "state_machine"
            }))
            if high_value and selector not in cov["called_selectors"]:
                uncovered.append(selector)
        return uncovered

    def _uir_solving_trigger_reasons(self):
        if not self._uir_solving_enabled():
            return []
        self._uir_init_coverage()
        stats = self._uir_solving_stats()
        args = getattr(self.env, "args", None)
        cov = self.env.uir_coverage
        goals = (getattr(self.env, "uir_targets", {}) or {}).get("coverage_goals", {}) or {}
        reasons = []

        coverage_plateau = int(getattr(self.env, "coverage_plateau_generations", 0) or 0)
        semantic_plateau = int(getattr(self.env, "uir_semantic_plateau_generations", 0) or 0)
        min_plateau = int(getattr(args, "uir_solving_plateau", 2) or 0)
        if coverage_plateau < min_plateau and semantic_plateau < min_plateau:
            stats["skipped"] = stats.get("skipped", 0) + 1
            stats["last_reasons"] = []
            return []

        high_value_uncovered = self._uir_high_value_uncovered()
        if high_value_uncovered:
            reasons.append("high_value_uir_target_uncovered")

        min_guard_failures = int(getattr(args, "uir_solving_min_guard_failures", 1) or 0)
        if int(cov.get("guard_failures", 0) or 0) >= min_guard_failures and min_guard_failures > 0:
            reasons.append("guarded_target_revert_stall")

        wr_goal = int(goals.get("write_read_relations") or 0)
        if wr_goal > 0 and len(cov.get("write_read_relations", set()) or set()) < wr_goal:
            reasons.append("write_read_relation_uncovered")

        cross_goal = int(goals.get("cross_relations") or 0)
        if cross_goal > 0 and len(cov.get("cross_relations", set()) or set()) < cross_goal:
            reasons.append("cross_relation_uncovered")

        reasons = sorted(set(reasons))
        if not reasons:
            stats["skipped"] = stats.get("skipped", 0) + 1
            stats["last_reasons"] = []
        return reasons

    # --------------------------ADD-------------------------- #
    def _log_validation_error(self, indv, transaction_index, transaction, exc):
        """
        将交易验证失败的关键信息打印到控制台，并写入 {contract_meta}/tx_errors.jsonl（JSON Lines）。
        便于分析诸如 'Sender account balance cannot afford txn' 的根因。
        """
        try:
            # 解析合约名，构造专属 meta 目录
            contract_file = getattr(self.env, "contract_name", "contract")
            test_name = os.path.splitext(os.path.basename(contract_file))[0]
            meta_dir = Path.cwd() / f"{test_name}_meta"
            meta_dir.mkdir(exist_ok=True)

            # 采集已知字段
            from_addr = transaction.get("from")
            to_addr   = transaction.get("to")
            value     = int(transaction.get("value", 0))
            data_hex  = transaction.get("data", "") or ""
            selector  = ("fallback" if not data_hex else (data_hex[:10] if data_hex.startswith("0x") else "0x"+data_hex[:8]))

            # gaslimit 优先取 chromosome 中的（若存在）
            gaslimit = None
            try:
                gaslimit = self.env.population.individuals[0].chromosome[transaction_index]["gaslimit"]
            except Exception:
                gaslimit = transaction.get("gas", None)

            # gasPrice：从 transaction / settings 里择优取值（都没有就视为 0）
            gas_price = None
            if "gasPrice" in transaction and transaction["gasPrice"] is not None:
                gas_price = int(transaction["gasPrice"])
            elif hasattr(settings, "GAS_PRICE") and settings.GAS_PRICE is not None:
                try:
                    gas_price = int(settings.GAS_PRICE)
                except Exception:
                    gas_price = 0
            else:
                gas_price = 0

            # 当前余额（如环境支持）
            balance = None
            try:
                if from_addr:
                    balance = self.env.instrumented_evm.get_balance(to_canonical_address(from_addr))
                    balance = int(balance)
            except Exception:
                pass

            # 估算所需金额（value + gaslimit*gasPrice）
            need = None
            try:
                gl = int(gaslimit) if gaslimit is not None else 21000
                gp = int(gas_price) if gas_price is not None else 0
                need = int(value) + gl * gp
            except Exception:
                pass

            # 控制台摘要
            self.logger.error(
                "Validation error in %s (tx #%d): %s | from=%s to=%s value=%s gaslimit=%s gasPrice=%s selector=%s balance=%s need=%s",
                indv.hash, transaction_index, exc, from_addr, to_addr, value, gaslimit, gas_price, selector, balance, need
            )

            # 结构化落盘（JSONL）
            entry = {
                "indv_hash": indv.hash,
                "tx_index": transaction_index,
                "error": str(exc),
                "from": from_addr,
                "to": to_addr,
                "value": value,
                "gaslimit": gaslimit,
                "gasPrice": gas_price,
                "selector": selector,
                "balance": balance,
                "need": need,
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            }
            with open(meta_dir / "tx_errors.jsonl", "a", encoding="utf-8") as f:
                f.write(json.dumps(entry, ensure_ascii=False) + "\n")

        except Exception as log_exc:
            # 日志失败不影响主流程
            self.logger.error("Failed to write tx error log: %s", log_exc)

    def _precheck_sender_funds(self, transaction, env):
        """
        返回 (ok: bool, need: int, gas_price: int, balance: int)
        ok 为 False 表示余额不足，调用方可直接跳过本次交易。
        """
        try:
            sender_hex = transaction["from"]  # 0x 前缀的 20 字节地址字符串
            sender_balance = env.instrumented_evm.get_balance(to_canonical_address(sender_hex))
        except Exception:
            # 万一 from 不是可解析地址（极少见），当作 0 处理
            sender_balance = 0

        value = int(transaction.get("value", 0)) or 0
        gas_limit = int(transaction.get("gaslimit", 0)) or 0

        # 兼容 EIP-1559：优先取 maxFeePerGas，其次 gasPrice（你的环境里常用 gasPrice=10）
        gas_price = int(transaction.get("maxFeePerGas") or transaction.get("gasPrice") or 0)

        need = value + gas_limit * gas_price
        ok = sender_balance >= need
        return ok, need, gas_price, sender_balance

    def setup(self, ng, engine): 
        self._uir_init_coverage()

    def execute(self, population, engine):
        self.env.memoized_fitness.clear()
        self.env.memoized_storage.clear()
        self.env.memoized_symbolic_execution.clear()
        self.env.individual_branches.clear()

        """from utils.utils import get_function_signature_mapping
        m = get_function_signature_mapping(self.env.abi)

        for i in population:
            a = [c["arguments"] for c in i.chromosome]
            b = []
            for j in a:
                arg = j[0]
                if arg in m:
                    b.append(m[arg]+" "+j[0])
                else:
                    b.append(arg)
            print(b)"""


        executed_individuals = dict()
        for i, individual in enumerate(population.individuals):
            if individual.hash in executed_individuals:
                population.individuals[i] = executed_individuals[individual.hash]
                continue
            self.execution_function(individual, self.env)
            executed_individuals[individual.hash] = individual
        executed_individuals.clear()

        # Update statistic variables.
        engine._update_statvars()

    def register_step(self, g, population, engine):
        self._inject_vulnerability_hint_seeds(population)
        self._inject_targeted_seeds(population)
        self.execute(population, engine)

        code_coverage_percentage = 0
        if len(self.env.overall_pcs) > 0:
            code_coverage_percentage = (len(self.env.code_coverage) / len(self.env.overall_pcs)) * 100

        branch_coverage = 0
        for pc in self.env.visited_branches:
            branch_coverage += len(self.env.visited_branches[pc])
        branch_coverage_percentage = 0
        if len(self.env.overall_jumpis) > 0:
            branch_coverage_percentage = (branch_coverage / (len(self.env.overall_jumpis) * 2)) * 100

        msg = 'Generation number {} \t Code coverage: {:.2f}% ({}/{}) \t Branch coverage: {:.2f}% ({}/{}) \t ' \
              'Transactions: {} ({} unique)   \t Time: {}'.format(
            g + 1, code_coverage_percentage, len(self.env.code_coverage), len(self.env.overall_pcs),
            branch_coverage_percentage, branch_coverage, len(self.env.overall_jumpis) * 2, self.env.nr_of_transactions, len(self.env.unique_individuals),
            time.time() - self.env.execution_begin)
        self.logger.title(msg)
        valid_code = len(getattr(self.env, "valid_path_code_coverage", set()))
        guard_code = len(getattr(self.env, "guard_revert_code_coverage", set()))
        deploy_code = len(getattr(self.env, "deployment_code_coverage", set()))
        valid_branches = len(getattr(self.env, "valid_path_branches", set()))
        guard_branches = len(getattr(self.env, "guard_revert_branches", set()))
        self.logger.info(
            "Coverage breakdown: valid-path code=%d guard/revert code=%d deployment code=%d valid-path branches=%d guard/revert branches=%d",
            valid_code, guard_code, deploy_code, valid_branches, guard_branches,
        )

        if len(self.env.code_coverage) == self.env.previous_code_coverage_length:
            self.env.coverage_plateau_generations = int(getattr(self.env, "coverage_plateau_generations", 0) or 0) + 1
        else:
            self.env.coverage_plateau_generations = 0

        previous_branch_coverage = getattr(self.env, "previous_branch_coverage_length", None)
        if previous_branch_coverage is None or branch_coverage != previous_branch_coverage:
            self.env.branch_plateau_generations = 0
        else:
            self.env.branch_plateau_generations = int(getattr(self.env, "branch_plateau_generations", 0) or 0) + 1

        uir_semantic_count = self._uir_semantic_progress_count()
        previous_uir_semantic_count = getattr(self.env, "previous_uir_semantic_progress_count", None)
        if previous_uir_semantic_count is None or uir_semantic_count != previous_uir_semantic_count:
            self.env.uir_semantic_plateau_generations = 0
        else:
            self.env.uir_semantic_plateau_generations = int(getattr(self.env, "uir_semantic_plateau_generations", 0) or 0) + 1

        # Save to results
        if "generations" not in self.env.results:
            self.env.results["generations"] = []

        uir_summary = self._uir_summary()
        uir_solving_reasons = self._uir_solving_trigger_reasons()
        args = getattr(self.env, "args", None)
        branch_plateau_threshold = int(getattr(args, "solver_branch_plateau", 0) or 0)
        high_risk_branch_age_threshold = int(getattr(args, "solver_high_risk_branch_age", 0) or 0)
        high_risk_branch_ages = self._update_high_risk_branch_ages()
        high_risk_ready = []
        if high_risk_branch_age_threshold > 0:
            high_risk_ready = [
                item for item in high_risk_branch_ages.values()
                if int(item.get("age", 0)) >= high_risk_branch_age_threshold
            ]
        phase2_solving_reasons = []
        if (
            branch_plateau_threshold > 0
            and int(getattr(self.env, "branch_plateau_generations", 0) or 0) >= branch_plateau_threshold
        ):
            phase2_solving_reasons.append("branch_coverage_plateau")
        if high_risk_ready:
            phase2_solving_reasons.append("high_risk_branch_age")
        phase2_solving_reasons = sorted(set(phase2_solving_reasons))
        symbolic_solving_reasons = sorted(set((uir_solving_reasons or []) + phase2_solving_reasons))
        coverage_stalled = len(self.env.code_coverage) == self.env.previous_code_coverage_length
        generation_symbolic_reasons = list(symbolic_solving_reasons)
        if coverage_stalled and not generation_symbolic_reasons:
            generation_symbolic_reasons = ["legacy_code_coverage_plateau"]
        self.env.results["generations"].append({
            "generation": g + 1,
            "time": time.time() - self.env.execution_begin,
            "total_transactions": self.env.nr_of_transactions,
            "unique_transactions": len(self.env.unique_individuals),
            "code_coverage": code_coverage_percentage,
            "branch_coverage": branch_coverage_percentage,
            "coverage_breakdown": {
                "valid_path_code_covered": valid_code,
                "guard_revert_code_covered": guard_code,
                "deployment_code_covered": deploy_code,
                "valid_path_branch_covered": valid_branches,
                "guard_revert_branch_covered": guard_branches,
            },
            "coverage_plateau_generations": getattr(self.env, "coverage_plateau_generations", 0),
            "branch_plateau_generations": getattr(self.env, "branch_plateau_generations", 0),
            "uir_semantic_plateau_generations": getattr(self.env, "uir_semantic_plateau_generations", 0),
            "uir_coverage": uir_summary,
            "uir_solving_reasons": uir_solving_reasons,
            "phase2_solving_reasons": phase2_solving_reasons,
            "symbolic_solving_reasons": generation_symbolic_reasons,
            "high_risk_branch_frontiers": high_risk_ready[:10],
            "vulnerability_hint_stats": getattr(self.env, "vulnerability_hint_stats", {}),
        })

        if coverage_stalled or symbolic_solving_reasons:
            if uir_solving_reasons:
                self._uir_record_solving_trigger(uir_solving_reasons)
            self._symbolic_stats_record_trigger(generation_symbolic_reasons)
            self.env.current_symbolic_generation = g + 1
            self.symbolic_execution(population.indv_generator, uir_reasons=generation_symbolic_reasons)
            if self.symbolic_execution_count == settings.MAX_SYMBOLIC_EXECUTION:
                del population.individuals[:]
                population.init()
                self.logger.debug("Resetting population...")
                self.execute(population, engine)
                self.symbolic_execution_count = 0
            self.symbolic_execution_count += 1
        else:
            self.symbolic_execution_count = 0

        self.env.previous_code_coverage_length = len(self.env.code_coverage)
        self.env.previous_branch_coverage_length = branch_coverage
        self.env.previous_uir_semantic_progress_count = uir_semantic_count

        if str(os.getenv("SEMINV_STOP_ON_TARGET_COVERAGE", "")).lower() in {"1", "true", "yes"}:
            try:
                threshold = float(os.getenv("SEMINV_STOP_COVERAGE_THRESHOLD", "99"))
            except Exception:
                threshold = 99.0
            label = os.getenv("SEMINV_TARGET_LABEL") or _infer_benchmark_label_from_source(getattr(self.env.args, "source", ""))
            source = Path(str(getattr(self.env.args, "source", "")))
            meta_dir = source.parent / f"{getattr(self.env, 'contract_name', source.stem)}_meta"
            if label and code_coverage_percentage >= threshold and _finding_dir_has_target(meta_dir, label):
                self.logger.info(
                    "Early stop: target label %s detected and code coverage %.2f%% >= %.2f%%",
                    label,
                    code_coverage_percentage,
                    threshold,
                )
                setattr(engine, "stop_requested", True)

    def execution_function(self, indv, env: FuzzingEnvironment):

        env.unique_individuals.add(indv.hash)
        uir_seed_profile = self._uir_new_seed_profile(indv)
        uir_before_code = set(env.code_coverage) if self._uir_enabled() else None
        uir_before_branches = self._branch_signature() if self._uir_enabled() else None
        uir_before_signature = self._uir_signature() if self._uir_enabled() else None
        uir_before_detectors = self._detector_signature() if self._uir_enabled() else None

        # Initialize metric
        branches = {}
        indv.data_dependencies = []
        contract_address = None

        env.detector_executor.initialize_detectors()

        for transaction_index, test in enumerate(indv.solution):

            transaction = test["transaction"]

            _function_hash = transaction["data"][:10] if transaction["data"].startswith("0x") else transaction["data"][:8]
            _function_hash = "fallback" if _function_hash == '' else _function_hash
            _array_size_indexes = dict()

            if transaction["to"] is None and contract_address is not None:
                transaction["to"] = contract_address

            if transaction["to"] is None:
                continue

            # === 资金预检：余额需覆盖 value + gasLimit*gasPrice（或 maxFeePerGas） ===
            if self._vulnerability_hints_enabled():
                sender = transaction.get("from")
                if sender:
                    try:
                        sender_address = to_canonical_address(sender)
                        sender_balance = int(env.instrumented_evm.get_balance(sender_address))
                        min_balance = int(getattr(env.instrumented_evm, "DEFAULT_FUNDING_WEI", 10**24))
                        if sender_balance < min_balance:
                            env.instrumented_evm.storage_emulator.set_balance(sender_address, min_balance)
                    except Exception as exc:
                        self.logger.debug("Failed to fund vulnerability-hint sender %s before precheck: %s", sender, exc)

            ok_funds, need, gas_price, balance = self._precheck_sender_funds(transaction, env)
            if not ok_funds:
                # 统一的彩色/结构化日志（与你现在的输出格式一致）
                _selector = _function_hash if _function_hash else "0x"
                # 详细行（彩色）
                self.logger.error(
                    "\x1b[91m\x1b[1mValidation error in \x1b[91m\x1b[1m%s\x1b[0m\x1b[0m (tx #%d): "
                    "Sender account balance cannot afford txn | from=\x1b[91m\x1b[1m%s\x1b[0m\x1b[0m "
                    "to=\x1b[91m\x1b[1m%s\x1b[0m\x1b[0m value=%d gaslimit=%d gasPrice=%d selector=\x1b[91m\x1b[1m%s\x1b[0m\x1b[0m "
                    "balance=%d need=%d\x1b[0m\x1b[0m",
                    indv.hash, transaction_index, transaction.get("from"), transaction.get("to"),
                    int(transaction.get("value", 0)), int(transaction.get("gaslimit", 0)), int(gas_price),
                    _selector, int(balance), int(need)
                )
                # 简洁行（结构化 JSON）
                try:
                    self.logger.error(json.dumps({
                        "indv_hash": str(indv.hash),
                        "tx_index": transaction_index,
                        "error": "Sender account balance cannot afford txn",
                        "from": transaction.get("from"),
                        "to": transaction.get("to"),
                        "value": int(transaction.get("value", 0)),
                        "gaslimit": int(transaction.get("gaslimit", 0)),
                        "gasPrice": int(gas_price),
                        "selector": _selector,
                        "balance": int(balance),
                        "need": int(need),
                        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
                    }, ensure_ascii=False))
                except Exception:
                    pass

                # （可选）如果你希望“自动降档 value 以达到可执行”，解开下面两行：
                # affordable = max(0, int(balance) - int(transaction.get("gaslimit", 0)) * int(gas_price))
                # transaction["value"] = min(int(transaction.get("value", 0)), affordable)

                # 当前策略：直接跳过这笔无效交易，避免进入 EVM 与产生 ValidationError
                self._uir_record_invalid_tx(uir_seed_profile)
                continue
            # === 资金预检结束 ===

            try:
                result = env.instrumented_evm.deploy_transaction(test)
            except ValidationError as e:
                # self._log_validation_error(indv, transaction_index, transaction, e)
                self.logger.error("Validation error in %s : %s (ignoring for now)", indv.hash, e)
                self._uir_record_invalid_tx(uir_seed_profile)
                continue

            gene = indv.chromosome[transaction_index] if transaction_index < len(indv.chromosome) else {}
            is_constructor_tx = bool((gene.get("arguments") or [None])[0] == "constructor")
            is_guard_probe = bool(gene.get("__coverage_probe__"))
            is_guard_or_revert_path = bool(result.is_error) or is_guard_probe

            self._uir_record_executed_selector(uir_seed_profile, _function_hash, result_is_error=bool(result.is_error))
            env.detector_executor.run_l4_transaction_detectors(
                env.results["errors"],
                indv,
                env,
                transaction_index,
                _function_hash,
                transaction,
                result_is_error=bool(result.is_error),
            )

            if not result.is_error and transaction["to"] == b'':
                contract_address = encode_hex(result.msg.storage_address)
                self.logger.debug("(%s - %d) Contract deployed at %s", indv.hash, transaction_index, contract_address)

            for child_computation in result.children:
                if child_computation.msg.to not in env.other_contracts:
                    continue
                if child_computation.msg.to not in env.children_code_coverage:
                    env.children_code_coverage[child_computation.msg.to] = set()
                env.children_code_coverage[child_computation.msg.to].update([x["pc"] for x in child_computation.trace])

            env.nr_of_transactions += 1

            previous_instruction = None
            previous_branch = []
            previous_branch_expression = None
            previous_branch_address = None
            previous_call_address = None
            sha3 = {}

            for i, instruction in enumerate(result.trace):

                env.symbolic_taint_analyzer.propagate_taint(instruction, contract_address)

                current_tainted_record = env.symbolic_taint_analyzer.get_tainted_record(index=-2)
                env.detector_executor.run_detectors(previous_instruction, instruction, env.results["errors"],
                                                current_tainted_record, indv, env, previous_branch,
                                                transaction_index)
                env.detector_executor.run_l4_instruction_detectors(
                    env.results["errors"],
                    indv,
                    env,
                    transaction_index,
                    _function_hash,
                    instruction,
                )
                self._maybe_record_vulnerability_hint(
                    indv, transaction_index, transaction, instruction,
                    current_tainted_record, result, i
                )

                # If constructor, we don't have to take into account the constructor inputs because they will be part of the
                # state. We don't have to compute the code coverage, because the code is not the deployed one. We don't need
                # to compute the cfg because we are on a different code. We actlually don't need analyzing its traces.
                if is_constructor_tx:
                    env.deployment_code_coverage.add(hex(instruction["pc"]))
                    continue

                # Code coverage
                pc_hex = hex(instruction["pc"])
                env.code_coverage.add(pc_hex)
                if is_guard_or_revert_path:
                    env.guard_revert_code_coverage.add(pc_hex)
                else:
                    env.valid_path_code_coverage.add(pc_hex)

                # Dynamically build control flow graph
                if env.cfg:
                    env.cfg.execute(instruction["pc"], instruction["stack"], instruction["op"], env.visited_branches,
                                    env.results["errors"].keys())

                if previous_instruction and previous_instruction["op"] == "SHA3":
                    sha3[instruction["stack"][-1][1]] = instruction["memory"]

                elif previous_instruction and previous_instruction["op"] == "ADD":
                    if previous_instruction["stack"][-1][1] in sha3:
                        sha3[instruction["stack"][-1][1]] = sha3[previous_instruction["stack"][-1][1]]
                    if previous_instruction["stack"][-2][1] in sha3:
                        sha3[instruction["stack"][-1][1]] = sha3[previous_instruction["stack"][-2][1]]

                if instruction["op"] == "JUMPI":
                    jumpi_pc = hex(instruction["pc"])
                    if jumpi_pc not in env.visited_branches:
                        env.visited_branches[jumpi_pc] = {}
                    if jumpi_pc not in branches:
                        branches[jumpi_pc] = dict()

                    destination = convert_stack_value_to_int(instruction["stack"][-1])
                    jumpi_condition = convert_stack_value_to_int(instruction["stack"][-2])

                    if jumpi_condition == 0:
                        # don't jump, but increase pc
                        branches[jumpi_pc][hex(destination)] = False
                        branches[jumpi_pc][hex(instruction["pc"] + 1)] = True
                    else:
                        # jump to destination
                        branches[jumpi_pc][hex(destination)] = True
                        branches[jumpi_pc][hex(instruction["pc"] + 1)] = False

                    branch_key = "{}:{}".format(jumpi_pc, jumpi_condition)
                    if is_guard_or_revert_path:
                        env.guard_revert_branches.add(branch_key)
                    else:
                        env.valid_path_branches.add(branch_key)

                    env.visited_branches[jumpi_pc][jumpi_condition] = {}
                    env.visited_branches[jumpi_pc][jumpi_condition]["indv_hash"] = indv.hash
                    env.visited_branches[jumpi_pc][jumpi_condition]["chromosome"] = indv.chromosome
                    env.visited_branches[jumpi_pc][jumpi_condition]["transaction_index"] = transaction_index
                    _branch_function_selector = self._uir_normalize_selector(indv.chromosome[transaction_index]["arguments"][0])
                    env.visited_branches[jumpi_pc][jumpi_condition]["function_selector"] = _branch_function_selector
                    _branch_uir_info = getattr(env, "uir_functions_by_selector", {}).get(_branch_function_selector, {}) if self._uir_enabled() else {}
                    env.visited_branches[jumpi_pc][jumpi_condition]["uir_categories"] = list(_branch_uir_info.get("categories", []) or [])
                    env.visited_branches[jumpi_pc][jumpi_condition]["uir_risk_tags"] = list(_branch_uir_info.get("risk_tags", []) or [])

                    tainted_record = env.symbolic_taint_analyzer.check_taint(instruction=instruction)
                    if tainted_record and tainted_record.stack and tainted_record.stack[-2]:
                        if jumpi_condition != 0:
                            previous_branch.append(tainted_record.stack[-2][0] != 0)
                        else:
                            previous_branch.append(tainted_record.stack[-2][0] == 0)
                        previous_branch_expression = previous_branch[-1]
                        env.visited_branches[jumpi_pc][jumpi_condition]["expression"] = previous_branch.copy()
                    else:
                        env.visited_branches[jumpi_pc][jumpi_condition]["expression"] = None
                        previous_branch_expression = None

                    previous_branch_address = jumpi_pc

                # Extract data dependencies (read-after-write)
                elif instruction["op"] == "SLOAD":
                    if instruction["stack"][-1][1] in sha3:
                        hash = instruction["stack"][-1][1]
                        while hash in sha3:
                            if len(sha3[hash]) == 64:
                                hash = sha3[hash][32:64]
                            else:
                                hash = sha3[hash]
                        storage_slot = int.from_bytes(hash, byteorder='big')
                    else:
                        storage_slot = convert_stack_value_to_int(instruction["stack"][-1])

                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                    if _function_hash not in self.env.data_dependencies:
                        self.env.data_dependencies[_function_hash] = {"read": set(), "write": set()}
                    self.env.data_dependencies[_function_hash]["read"].add(storage_slot)
                    self._uir_update_dynamic_relations_from_storage_access(_function_hash, "read", storage_slot)

                elif instruction["op"] == "SSTORE":
                    if instruction["stack"][-1][1] in sha3:
                        hash = instruction["stack"][-1][1]
                        while hash in sha3:
                            if len(sha3[hash]) == 64:
                                hash = sha3[hash][32:64]
                            else:
                                hash = sha3[hash]
                        storage_slot = int.from_bytes(hash, byteorder='big')
                    else:
                        storage_slot = convert_stack_value_to_int(instruction["stack"][-1])

                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                    if _function_hash not in self.env.data_dependencies:
                        self.env.data_dependencies[_function_hash] = {"read": set(), "write": set()}
                    self.env.data_dependencies[_function_hash]["write"].add(storage_slot)
                    self._uir_update_dynamic_relations_from_storage_access(_function_hash, "write", storage_slot)

                # If something goes wrong, we need to clean some pools
                elif instruction["op"] in ["REVERT", "INVALID", "ASSERTFAIL"]:
                    if previous_branch_expression is not None and is_expr(previous_branch_expression):
                        # Only remove from pool when you are sure which variable caused the exception
                        if len(get_vars(previous_branch_expression)) == 1:
                            for var in get_vars(previous_branch_expression):
                                _str_var = str(var)

                                if _str_var.startswith("calldataload_") or str(var).startswith("calldatacopy_"):
                                    _parameter_index = int(str(var).split("_")[-1])
                                    _transaction_index = int(str(var).split("_")[-2])
                                    _function_hash = indv.chromosome[_transaction_index]["arguments"][0]
                                    _argument = indv.chromosome[_transaction_index]["arguments"][_parameter_index + 1]
                                    indv.generator.remove_argument_from_pool(_function_hash, _parameter_index, _argument)

                                elif _str_var.startswith("callvalue_"):
                                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                                    _amount = transaction["value"]
                                    if _amount == 0 or _amount == 1:
                                        indv.generator.remove_amount_from_pool(_function_hash, _amount)

                                elif _str_var.startswith("caller_"):
                                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                                    _caller = transaction["from"]
                                    indv.generator.remove_account_from_pool(_function_hash, _caller)

                                elif _str_var.startswith("gas_"):
                                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                                    _gas_limit = indv.chromosome[transaction_index]["gaslimit"]
                                    indv.generator.remove_gaslimit_from_pool(_function_hash, _gas_limit)

                                elif _str_var.startswith("blocknumber_"):
                                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                                    _blocknumber = indv.chromosome[transaction_index]["blocknumber"]
                                    indv.generator.remove_blocknumber_from_pool(_function_hash, _blocknumber)

                                elif _str_var.startswith("timestamp_"):
                                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                                    _timestamp = indv.chromosome[transaction_index]["timestamp"]
                                    indv.generator.remove_timestamp_from_pool(_function_hash, _timestamp)

                                elif _str_var.startswith("call_"):
                                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                                    _var_split = str(var).split("_")
                                    _address = to_normalized_address(_var_split[2])
                                    _result = int(_var_split[3], 16)
                                    indv.generator.remove_callresult_from_pool(_function_hash, _address, _result)

                                elif _str_var.startswith("extcodesize"):
                                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                                    _var_split = str(var).split("_")
                                    _address = to_normalized_address(_var_split[2])
                                    _size = int(_var_split[3], 16)
                                    indv.generator.remove_extcodesize_from_pool(_function_hash, _address, _size)

                                elif _str_var.startswith("returndatasize"):
                                    _function_hash = indv.chromosome[transaction_index]["arguments"][0]
                                    _var_split = str(var).split("_")
                                    _address = to_normalized_address(_var_split[2])
                                    _size = int(_var_split[3], 16)
                                    indv.generator.remove_returndatasize_from_pool(_function_hash, _address, _size)

                elif instruction["op"] == "BALANCE":
                    taint = BitVec("_".join(["balance", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] in ["CALL", "STATICCALL"]:
                    _address_as_hex = to_hex(force_bytes_to_address(int_to_big_endian(convert_stack_value_to_int(result.trace[i]["stack"][-2]))))
                    if i + 1 < len(result.trace):
                        _result_as_hex = convert_stack_value_to_hex(result.trace[i + 1]["stack"][-1])
                    else:
                        _result_as_hex = ""
                    previous_call_address = _address_as_hex
                    call_type = "call"
                    if instruction["op"] == "STATICCALL":
                        call_type = "staticcall"
                    taint = BitVec("_".join([call_type, str(transaction_index), str(_address_as_hex), str(_result_as_hex), str(instruction["pc"])]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "CALLER":
                    taint = BitVec("_".join(["caller", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "CALLDATALOAD":
                    input_index = convert_stack_value_to_int(instruction["stack"][-1])
                    if input_index > 0 and _function_hash in env.interface:
                        input_index = int((input_index - 4) / 32)
                        if input_index < len(env.interface[_function_hash]):
                            parameter_type = env.interface[_function_hash][input_index]
                            if '[' in parameter_type:
                                array_size_index = convert_stack_value_to_int(result.trace[i + 1]["stack"][-1]) / 32
                                _array_size_indexes[array_size_index] = input_index
                            elif "bytes" in parameter_type:
                                pass
                            else:
                                taint = BitVec("_".join(["calldataload",
                                                         str(transaction_index),
                                                         str(input_index)
                                                         ]), 256)
                                env.symbolic_taint_analyzer.introduce_taint(taint, instruction)
                        else:
                            if input_index in _array_size_indexes:
                                array_size = convert_stack_value_to_int(result.trace[i + 1]["stack"][-1])
                                taint = BitVec("_".join(["inputarraysize",
                                                         str(transaction_index),
                                                         str(_array_size_indexes[input_index])
                                                         ]), 256)
                                env.symbolic_taint_analyzer.introduce_taint(taint, instruction)
                            else:
                                pass

                elif instruction["op"] == "CALLDATACOPY":
                    destOffset = convert_stack_value_to_int(instruction["stack"][-1])
                    offset = convert_stack_value_to_int(instruction["stack"][-2])
                    array_start_index = (offset - 4) / 32
                    lenght = convert_stack_value_to_int(instruction["stack"][-3])

                    if array_start_index - 1 in _array_size_indexes:
                        taint = BitVec("_".join(["calldatacopy",
                                                 str(transaction_index),
                                                 str(_array_size_indexes[array_start_index - 1])
                                                 ]), 256)
                        env.symbolic_taint_analyzer.introduce_taint(taint, instruction)
                    else:
                        pass

                elif instruction["op"] == "CALLDATASIZE":
                    taint = BitVec("_".join(["calldatasize", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "CALLVALUE":
                    taint = BitVec("_".join(["callvalue", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "GAS":
                    taint = BitVec("_".join(["gas", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                # BLOCK Opcodes
                elif instruction["op"] == "BLOCKHASH":
                    taint = BitVec("_".join(["blockhash", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "COINBASE":
                    taint = BitVec("_".join(["coinbase", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "TIMESTAMP":
                    taint = BitVec("_".join(["timestamp", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "NUMBER":
                    taint = BitVec("_".join(["blocknumber", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "DIFFICULTY":
                    taint = BitVec("_".join(["difficulty", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "GASLIMIT":
                    taint = BitVec("_".join(["gaslimit", str(transaction_index)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "EXTCODESIZE":
                    _address_as_hex = to_hex(
                        force_bytes_to_address(int_to_big_endian(convert_stack_value_to_int(result.trace[i]["stack"][-1]))))
                    if i + 1 < len(result.trace):
                        _result_as_hex = convert_stack_value_to_hex(result.trace[i + 1]["stack"][-1])
                    else:
                        _result_as_hex = ""
                    taint = BitVec("_".join(["extcodesize", str(transaction_index), str(_address_as_hex), str(_result_as_hex)]), 256)
                    env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                elif instruction["op"] == "RETURNDATASIZE":
                    if previous_call_address:
                        if i + 1 < len(result.trace):
                            _size = convert_stack_value_to_int(result.trace[i + 1]["stack"][-1])
                        else:
                            _size = 0
                        taint = BitVec("_".join(["returndatasize", str(transaction_index), previous_call_address, str(_size)]), 256)
                        env.symbolic_taint_analyzer.introduce_taint(taint, instruction)

                previous_instruction = instruction

            env.symbolic_taint_analyzer.clear_callstack()

            if not result.is_error and not transaction["to"]:
                contract_address = encode_hex(result.msg.storage_address)

        env.individual_branches[indv.hash] = branches
        self._uir_finalize_seed_profile(
            uir_seed_profile,
            before_code=uir_before_code,
            before_branches=uir_before_branches,
            before_uir=uir_before_signature,
            before_detectors=uir_before_detectors,
        )

        env.symbolic_taint_analyzer.clear_storage()
        env.instrumented_evm.restore_from_snapshot()

    def get_coverage_with_children(self, children_code_coverage, code_coverage):
        code_coverage = len(code_coverage)

        for child_cc in children_code_coverage:
            code_coverage += len(child_cc)
        return code_coverage

    def _uir_symbolic_priority(self, branch_data):
        if not branch_data:
            return 0
        categories = set(branch_data.get("uir_categories", []) or [])
        risk_tags = set(branch_data.get("uir_risk_tags", []) or [])
        priority = 0
        if categories.intersection({"access_anomaly", "accounting_anomaly"}):
            priority += 8
        if categories.intersection({"sensitive", "access_guarded", "guarded"}):
            priority += 5
        if categories.intersection({"accounting", "state_transition"}):
            priority += 3
        if risk_tags.intersection({"sensitive_function", "guarded_sensitive", "accounting_anomaly", "state_machine"}):
            priority += 2
        return priority

    def _should_prioritize_uir_symbolic_branches(self, reasons):
        reason_set = set(reasons or [])
        return bool(reason_set.intersection({
            "high_value_uir_target_uncovered",
            "guarded_target_revert_stall",
            "write_read_relation_uncovered",
            "cross_relation_uncovered",
            "high_risk_branch_age",
        }))

    def _solver_uir_priority_mode(self):
        return str(getattr(self.env.args, "solver_uir_priority", "legacy") or "legacy").lower()

    def _symbolic_branch_age(self, pc, branch):
        key = "{}:{}".format(pc, branch)
        return int((getattr(self.env, "high_risk_branch_ages", {}) or {}).get(key, {}).get("age", 0) or 0)

    def _symbolic_branch_sort_score(self, item, reasons=None, failure_counts=None):
        pc, visited_at_pc = item
        if not visited_at_pc:
            return 0

        failure_counts = failure_counts or {}
        best = 0
        for branch, branch_data in visited_at_pc.items():
            score = 0
            if len(visited_at_pc) == 1:
                score += 20
            if branch_data and branch_data.get("expression"):
                score += 5

            score += self._uir_symbolic_priority(branch_data) * 2
            age = self._symbolic_branch_age(pc, branch)
            score += min(age, 10)

            expression = (branch_data or {}).get("expression") or []
            expression_len = len(expression)
            score -= min(expression_len, 20) * 0.25
            if expression:
                try:
                    score -= min(len(get_vars(expression[-1])), 8) * 0.5
                except Exception:
                    pass

            key = "{}:{}".format(pc, branch)
            score -= failure_counts.get(key, 0) * 5
            best = max(best, score)

        return best

    def _sort_symbolic_branch_items(self, branch_items, reasons):
        stats = self._symbolic_execution_stats()
        priority_stats = stats.setdefault("priority", {})
        mode = self._solver_uir_priority_mode()
        priority_stats["mode"] = mode

        if mode == "light":
            failure_counts = self._symbolic_recent_failure_counts()
            scored = [
                (self._symbolic_branch_sort_score(item, reasons=reasons, failure_counts=failure_counts), item)
                for item in branch_items
            ]
            scored.sort(key=lambda pair: pair[0], reverse=True)
            priority_stats["uses"] = priority_stats.get("uses", 0) + 1
            priority_stats["last_top"] = [
                {
                    "pc": item[0],
                    "score": round(score, 3),
                    "visited_branches": len(item[1]),
                    "max_uir_priority": max([self._uir_symbolic_priority(v) for v in item[1].values()] or [0]),
                }
                for score, item in scored[:10]
            ]
            return [item for _, item in scored]

        if self._should_prioritize_uir_symbolic_branches(reasons):
            branch_items.sort(
                key=lambda item: max([self._uir_symbolic_priority(v) for v in item[1].values()] or [0]),
                reverse=True,
            )
            priority_stats["mode"] = "legacy_uir"
            priority_stats["uses"] = priority_stats.get("uses", 0) + 1

        return branch_items

    def symbolic_execution(self, indv_generator, uir_reasons=None):
        if not self.env.args.constraint_solving:
            return

        stats = self._symbolic_execution_stats()
        stats["calls"] = stats.get("calls", 0) + 1
        max_branches = int(getattr(self.env.args, "solver_max_branches_per_call", 0) or 0)
        max_call_ms = int(getattr(self.env.args, "solver_max_call_ms", 0) or 0)
        cooldown_generations = int(getattr(self.env.args, "solver_branch_cooldown", 0) or 0)
        max_targeted_seeds = int(getattr(self.env.args, "solver_targeted_seeds_per_call", 0) or 0)
        max_path_conditions = int(getattr(self.env.args, "solver_max_path_conditions", 0) or 0)
        max_variables = int(getattr(self.env.args, "solver_max_variables", 0) or 0)
        call_started = time.time()
        attempted_this_call = 0
        sat_this_call = 0
        targeted_this_call = 0
        call_generation = int(getattr(self.env, "current_symbolic_generation", 0) or 0)
        if not hasattr(self.env, "symbolic_branch_cooldowns"):
            self.env.symbolic_branch_cooldowns = {}
        stats["budget"] = {
            "max_branches_per_call": max_branches,
            "max_call_ms": max_call_ms,
            "branch_cooldown_generations": cooldown_generations,
            "trace_limit": int(getattr(self.env.args, "solver_stats_trace_limit", 100) or 0),
            "branch_plateau_generations": int(getattr(self.env.args, "solver_branch_plateau", 0) or 0),
            "high_risk_branch_age_generations": int(getattr(self.env.args, "solver_high_risk_branch_age", 0) or 0),
            "uir_priority": self._solver_uir_priority_mode(),
            "targeted_seeds": bool(getattr(self.env.args, "solver_targeted_seeds", False)),
            "targeted_seed_mode": self._targeted_seed_mode(),
            "targeted_seeds_per_call": int(getattr(self.env.args, "solver_targeted_seeds_per_call", 0) or 0),
            "targeted_seed_injection": int(getattr(self.env.args, "solver_targeted_seed_injection", 2) or 0),
            "targeted_seed_queue": int(getattr(self.env.args, "solver_targeted_seed_queue", 16) or 0),
            "abi_constraints": bool(getattr(self.env.args, "solver_abi_constraints", False)),
            "max_path_conditions": max_path_conditions,
            "max_variables": max_variables,
        }

        branch_items = list(self.env.visited_branches.items())
        branch_items = self._sort_symbolic_branch_items(branch_items, uir_reasons)

        for index, (pc, visited_at_pc) in enumerate(branch_items):
            self.logger.debug("b(%d) pc : %s - visited branches : %s", index, pc,
                               visited_at_pc.keys())

            if len(visited_at_pc) != 1:
                self._symbolic_stats_add_skip("multi_branch_pc")
                continue

            branch, _d = next(iter(visited_at_pc.items()))

            if not _d["expression"]:
                self.logger.debug("No expression for b(%d) pc : %s", index, pc)
                self._symbolic_stats_add_skip("no_expression")
                continue

            if max_branches > 0 and attempted_this_call >= max_branches:
                self._symbolic_stats_add_skip("branch_budget")
                break
            if max_call_ms > 0 and (time.time() - call_started) * 1000 >= max_call_ms:
                self._symbolic_stats_add_skip("time_budget")
                break

            negated_branch = simplify(Not(_d["expression"][-1]))
            branch_key = str(negated_branch)

            if negated_branch in self.env.memoized_symbolic_execution:
                self._symbolic_stats_add_skip("memoized")
                continue

            if cooldown_generations > 0:
                last_generation = self.env.symbolic_branch_cooldowns.get(branch_key)
                if last_generation is not None and call_generation - int(last_generation) < cooldown_generations:
                    self._symbolic_stats_add_skip("cooldown")
                    continue

            expression_count = len(_d["expression"])
            expression_vars = self._symbolic_expression_vars(list(_d["expression"]) + [negated_branch])
            variable_count = len(expression_vars)

            if max_path_conditions > 0 and expression_count > max_path_conditions:
                self._symbolic_stats_add_skip("path_condition_budget")
                continue
            if max_variables > 0 and variable_count > max_variables:
                self._symbolic_stats_add_skip("variable_budget")
                continue

            attempted_this_call += 1
            stats["attempted"] = stats.get("attempted", 0) + 1
            if cooldown_generations > 0:
                self.env.symbolic_branch_cooldowns[branch_key] = call_generation

            solve_started = time.time()
            abi_constraints_added = 0
            abi_constraints_skipped = 0

            try:
                self.env.solver.reset()
                for expression_index in range(len(_d["expression"]) - 1):
                    expression = simplify(_d["expression"][expression_index])
                    self.env.solver.add(expression)
                self.env.solver.add(negated_branch)
                abi_constraints_added, abi_constraints_skipped = self._add_abi_constraints(
                    _d,
                    list(_d["expression"]) + [negated_branch],
                    indv_generator,
                )

                check = self.env.solver.check()
            finally:
                solve_time_ms = round((time.time() - solve_started) * 1000, 3)
                stats["total_solve_time_ms"] = round(stats.get("total_solve_time_ms", 0.0) + solve_time_ms, 3)
                stats["max_solve_time_ms"] = max(float(stats.get("max_solve_time_ms", 0.0)), solve_time_ms)

            attempt_record = {
                "pc": pc,
                "branch": str(branch),
                "selector": _d.get("function_selector"),
                "uir_categories": list(_d.get("uir_categories", []) or []),
                "uir_risk_tags": list(_d.get("uir_risk_tags", []) or []),
                "path_condition_len": expression_count,
                "negated_branch_vars": variable_count,
                "abi_constraints_added": abi_constraints_added,
                "abi_constraints_skipped": abi_constraints_skipped,
                "priority_score": round(self._symbolic_branch_sort_score((pc, visited_at_pc)), 3),
                "solve_time_ms": solve_time_ms,
                "uir_reasons": list(uir_reasons or []),
                "generation": call_generation,
            }

            if check == unsat:
                stats["unsat"] = stats.get("unsat", 0) + 1
                attempt_record["result"] = "unsat"
                self._symbolic_stats_add_attempt(attempt_record)
                self.env.memoized_symbolic_execution[negated_branch] = True
                continue

            if check == unknown:
                stats["unknown"] = stats.get("unknown", 0) + 1
                reason_unknown = ""
                try:
                    reason_unknown = self.env.solver.reason_unknown()
                except Exception:
                    reason_unknown = ""
                if "timeout" in str(reason_unknown).lower():
                    stats["timeout"] = stats.get("timeout", 0) + 1
                    attempt_record["result"] = "timeout"
                else:
                    attempt_record["result"] = "unknown"
                attempt_record["reason_unknown"] = str(reason_unknown)
                self._symbolic_stats_add_attempt(attempt_record)
                self.env.memoized_symbolic_execution[negated_branch] = True
                continue

            if check == sat:
                stats["sat"] = stats.get("sat", 0) + 1
                sat_this_call += 1
                model = self.env.solver.model()
                stats["models"] = stats.get("models", 0) + 1
                stats["model_variables"] = stats.get("model_variables", 0) + len(model)
                attempt_record["result"] = "sat"
                attempt_record["model_variables"] = [str(x) for x in model]
                self._symbolic_stats_add_attempt(attempt_record)

                self.logger.debug("(%s) Symbolic Solution to branch %s: %s ", _d["indv_hash"], pc,
                                  "; ".join([str(x)+" ("+str(model[x])+")" for x in model]))

                if max_targeted_seeds <= 0 or targeted_this_call < max_targeted_seeds:
                    before_queued = self._targeted_seed_stats().get("queued", 0)
                    self._queue_targeted_seed_from_model(
                        branch_data=_d,
                        pc=pc,
                        model=model,
                        indv_generator=indv_generator,
                        priority_score=attempt_record.get("priority_score"),
                    )
                    after_queued = self._targeted_seed_stats().get("queued", 0)
                    if after_queued > before_queued:
                        targeted_this_call += 1

                for variable in model:
                    if str(variable).startswith("underflow"):
                        continue

                    var_split = str(variable).split("_")
                    transaction_index = int(var_split[1])

                    if str(variable).startswith("balance"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        opt = Optimize()
                        for expression_index in range(len(_d["expression"]) - 1):
                            opt.add(_d["expression"][expression_index])
                        opt.add(negated_branch)
                        check = opt.check()
                        if check == sat:
                            opt_model = opt.model()
                            balance = int(opt_model[variable].as_long())
                            if _d["chromosome"][transaction_index]["contract"]:
                                indv_generator.add_balance_to_pool(_function_hash, self.env.instrumented_evm.get_balance(
                                    to_canonical_address(_d["chromosome"][transaction_index]["contract"])))
                            indv_generator.add_balance_to_pool(_function_hash, balance)

                    elif str(variable).startswith("blocknumber"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        blocknumber = int(model[variable].as_long())
                        indv_generator.add_blocknumber_to_pool(_function_hash,
                                                               self.env.instrumented_evm.vm.state.block_number)
                        indv_generator.add_blocknumber_to_pool(_function_hash, blocknumber)

                    elif str(variable).startswith("call_") or str(variable).startswith("staticcall_"):
                        address = to_normalized_address(var_split[2])
                        old_result = int(var_split[3], 16)
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        new_result = 1 - old_result
                        indv_generator.add_callresult_to_pool(_function_hash, address, old_result)
                        indv_generator.add_callresult_to_pool(_function_hash, address, new_result)

                    elif str(variable).startswith("caller_"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        if model[variable].as_long() > 8 and model[variable].as_long() < 2**160:
                            account_address = normalize_32_byte_hex_address("0x"+hex(model[variable].as_long()).replace("0x", "").zfill(40))
                            if not self.env.instrumented_evm.has_account(account_address):
                                self.env.instrumented_evm.restore_from_snapshot()
                                self.env.instrumented_evm.accounts.append(self.env.instrumented_evm.create_fake_account(account_address))
                                self.env.instrumented_evm.create_snapshot()
                            indv_generator.add_account_to_pool(_function_hash, _d["chromosome"][transaction_index]["account"])
                            indv_generator.add_account_to_pool(_function_hash, account_address)

                    elif str(variable).startswith("calldatacopy_"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        parameter_index = int(var_split[2])
                        if "[" in indv_generator.interface[_function_hash][parameter_index]:
                            if indv_generator.interface[_function_hash][parameter_index].startswith("int"):
                                argument = model[variable].as_signed_long()
                            elif indv_generator.interface[_function_hash][parameter_index].startswith("address"):
                                try:
                                    _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                                    argument = normalize_32_byte_hex_address(hex(model[variable].as_long()))
                                    if not self.env.instrumented_evm.has_account(argument):
                                        self.env.instrumented_evm.restore_from_snapshot()
                                        self.env.instrumented_evm.accounts.append(self.env.instrumented_evm.create_fake_account(argument))
                                        self.env.instrumented_evm.create_snapshot()
                                except Exception as e:
                                    self.logger.error("(%s) [symbolic execution : calldatacopy ] %s", _function_hash,
                                                       e)
                                    continue
                            else:
                                argument = model[variable].as_long()
                            indv_generator.add_argument_to_pool(_function_hash, parameter_index, _d["chromosome"][transaction_index]["arguments"][parameter_index + 1])
                            indv_generator.add_argument_to_pool(_function_hash, parameter_index, argument)

                    elif str(variable).startswith("calldataload_"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        parameter_index = int(var_split[2])
                        # TODO: THE SOLVER DOES NOT CONSIDER THE MAX SIZE OF THE VARIABLE
                        #   GENERATING LATER A eth_abi.exceptions.ValueOutOfBounds
                        if "[" in indv_generator.interface[_function_hash][parameter_index]:
                            if indv_generator.interface[_function_hash][parameter_index].startswith("int"):
                                argument = model[variable].as_signed_long()
                            elif indv_generator.interface[_function_hash][parameter_index].startswith("address"):
                                try:
                                    _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                                    argument = normalize_32_byte_hex_address(hex(model[variable].as_long()))
                                    if not self.env.instrumented_evm.has_account(argument):
                                        self.env.instrumented_evm.restore_from_snapshot()
                                        self.env.instrumented_evm.accounts.append(self.env.instrumented_evm.create_fake_account(argument))
                                        self.env.instrumented_evm.create_snapshot()
                                except Exception as e:
                                    self.logger.error("(%s) [symbolic execution : calldataload ] %s", _function_hash,
                                                       e)
                                    continue

                        elif indv_generator.interface[_function_hash][parameter_index].startswith("int"):
                            argument = model[variable].as_signed_long()

                        elif indv_generator.interface[_function_hash][parameter_index] == "address":
                            try:
                                _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                                argument = to_hex(
                                    force_bytes_to_address(int_to_big_endian(int(model[variable].as_long()))))
                                if not self.env.instrumented_evm.has_account(argument):
                                    self.env.instrumented_evm.restore_from_snapshot()
                                    self.env.instrumented_evm.accounts.append(self.env.instrumented_evm.create_fake_account(argument))
                                    self.env.instrumented_evm.create_snapshot()
                            except Exception as e:
                                self.logger.error("(%s) [symbolic execution : calldataload ] %s", _function_hash, e)
                                continue

                        elif indv_generator.interface[_function_hash][parameter_index] == "string":
                            argument = _d["chromosome"][transaction_index]["arguments"][parameter_index + 1]
                        elif indv_generator.interface[_function_hash][parameter_index].startswith("uint"):
                            argument = model[variable].as_long()
                            bits = 256
                            if indv_generator.interface[_function_hash][parameter_index] != "uint":
                                bits = int(indv_generator.interface[_function_hash][parameter_index].replace("uint", ""))
                            base = 1 << bits
                            argument %= base
                        else:
                            argument = model[variable].as_long()
                            self.env.solver.add(BitVec(str(variable), 256) != BitVecVal(0, 256))
                            for variable_2 in model:
                                if variable_2 != variable and str(variable_2).startswith("callvalue"):
                                    callvalue_index = int(str(variable_2).split("_")[1])
                                    self.env.solver.add(BitVec(str(variable_2), 256) == BitVecVal(int(_d["chromosome"][callvalue_index]["amount"]), 256))
                            check = self.env.solver.check()
                            if check == sat:
                                model = self.env.solver.model()
                                argument = model[variable].as_long()

                        indv_generator.add_argument_to_pool(_function_hash, parameter_index, _d["chromosome"][transaction_index]["arguments"][parameter_index + 1])
                        indv_generator.add_argument_to_pool(_function_hash, parameter_index, argument)

                    elif str(variable).startswith("callvalue_"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        amount = model[variable].as_long()
                        if amount > settings.ACCOUNT_BALANCE:
                            amount = settings.ACCOUNT_BALANCE
                        indv_generator.remove_amount_from_pool(_function_hash, 0)
                        indv_generator.remove_amount_from_pool(_function_hash, 1)
                        indv_generator.add_amount_to_pool(_function_hash, _d["chromosome"][transaction_index]["amount"])
                        indv_generator.add_amount_to_pool(_function_hash, amount)

                    elif str(variable).startswith("gas_"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        indv_generator.add_gaslimit_to_pool(_function_hash, _d["chromosome"][transaction_index]["gaslimit"])
                        indv_generator.add_gaslimit_to_pool(_function_hash, model[variable].as_long())

                    elif str(variable).startswith("inputarraysize"):
                        opt = Optimize()
                        for expression_index in range(len(_d["expression"]) - 1):
                            opt.add(_d["expression"][expression_index])
                        opt.add(negated_branch)
                        check = opt.check()
                        if check == sat:
                            opt_model = opt.model()
                            array_size = opt_model[variable].as_long()
                            _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                            parameter_index = int(var_split[2])
                            indv_generator.add_parameter_array_size(_function_hash, parameter_index, len(
                                _d["chromosome"][transaction_index]["arguments"][parameter_index + 1]))
                            indv_generator.add_parameter_array_size(_function_hash, parameter_index, array_size)

                    elif str(variable).startswith("timestamp"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        timestamp = int(model[variable].as_long())
                        indv_generator.add_timestamp_to_pool(_function_hash, self.env.instrumented_evm.vm.state.timestamp)
                        indv_generator.add_timestamp_to_pool(_function_hash, timestamp)

                    elif str(variable).startswith("calldatasize"):
                        pass

                    elif str(variable).startswith("extcodesize"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        _address = to_normalized_address(var_split[2])
                        indv_generator.add_extcodesize_to_pool(_function_hash, _address, int(var_split[3], 16))
                        indv_generator.add_extcodesize_to_pool(_function_hash, _address, int(model[variable].as_long()))

                    elif str(variable).startswith("returndatasize"):
                        _function_hash = _d["chromosome"][transaction_index]["arguments"][0]
                        _address = to_normalized_address(var_split[2])
                        _size = int(var_split[3], 16)
                        indv_generator.add_returndatasize_to_pool(_function_hash, _address, int(var_split[3], 16))
                        indv_generator.add_returndatasize_to_pool(_function_hash, _address, int(model[variable].as_long()))

                    else:
                        self.logger.warning("Unknown symbolic variable: %s ", str(variable))

            self.env.memoized_symbolic_execution[negated_branch] = True

        stats["last_call"] = {
            "attempted": attempted_this_call,
            "sat": sat_this_call,
            "elapsed_ms": round((time.time() - call_started) * 1000, 3),
            "generation": call_generation,
            "uir_reasons": list(uir_reasons or []),
        }

    def finalize(self, population, engine):
        execution_end = time.time()
        execution_delta = execution_end - self.env.execution_begin

        self.logger.title("-----------------------------------------------------")
        msg = 'Number of generations: \t {}'.format(engine.current_generation + 1)
        self.logger.info(msg)
        msg = 'Number of transactions: \t {} ({} unique)'.format(self.env.nr_of_transactions, len(self.env.unique_individuals))
        self.logger.info(msg)
        msg = 'Transactions per second: \t {:.0f}'.format(self.env.nr_of_transactions / execution_delta)
        self.logger.info(msg)
        code_coverage_percentage = 0
        if len(self.env.overall_pcs) > 0:
            code_coverage_percentage = (len(self.env.code_coverage) / len(self.env.overall_pcs)) * 100
        msg = 'Total code coverage: \t {:.2f}% ({}/{})'.format(code_coverage_percentage,
                                                                len(self.env.code_coverage),
                                                                len(self.env.overall_pcs))
        self.logger.info(msg)
        branch_coverage = 0
        for pc in self.env.visited_branches:
            branch_coverage += len(self.env.visited_branches[pc])
        branch_coverage_percentage = 0
        if len(self.env.overall_jumpis) > 0:
            branch_coverage_percentage = (branch_coverage / (len(self.env.overall_jumpis) * 2)) * 100
        msg = 'Total branch coverage: \t {:.2f}% ({}/{})'.format(branch_coverage_percentage,
                                                                 branch_coverage, len(self.env.overall_jumpis) * 2)
        self.logger.info(msg)
        coverage_breakdown = {
            "valid_path_code_covered": len(getattr(self.env, "valid_path_code_coverage", set())),
            "guard_revert_code_covered": len(getattr(self.env, "guard_revert_code_coverage", set())),
            "deployment_code_covered": len(getattr(self.env, "deployment_code_coverage", set())),
            "valid_path_branch_covered": len(getattr(self.env, "valid_path_branches", set())),
            "guard_revert_branch_covered": len(getattr(self.env, "guard_revert_branches", set())),
        }
        self.logger.info(
            "Coverage breakdown: valid-path code=%d guard/revert code=%d deployment code=%d valid-path branches=%d guard/revert branches=%d",
            coverage_breakdown["valid_path_code_covered"],
            coverage_breakdown["guard_revert_code_covered"],
            coverage_breakdown["deployment_code_covered"],
            coverage_breakdown["valid_path_branch_covered"],
            coverage_breakdown["guard_revert_branch_covered"],
        )
        msg = 'Total execution time: \t {:.2f} seconds'.format(execution_delta)
        self.logger.info(msg)
        msg = 'Total memory consumption: \t {:.2f} MB'.format(psutil.Process(os.getpid()).memory_info().rss/1024/1024)
        self.logger.info(msg)
        uir_summary = self._uir_summary()
        if uir_summary:
            percentages = uir_summary.get("percentages", {})
            self.logger.info(
                "UIR semantic coverage: sensitive=%s%% access_anomaly=%s%% state_transition=%s%% write_read=%s%%",
                percentages.get("sensitive_functions"),
                percentages.get("access_anomalies"),
                percentages.get("state_transition_functions"),
                percentages.get("write_read_relations"),
            )

        # Save to results
        self.env.results["transactions"] = {"total": self.env.nr_of_transactions,
                                            "per_second": self.env.nr_of_transactions / execution_delta}
        self.env.results["code_coverage"] = {"percentage": code_coverage_percentage,
                                             "covered": len(self.env.code_coverage),
                                             "total": len(self.env.overall_pcs),
                                             "covered_with_children": self.get_coverage_with_children(
                                                 self.env.children_code_coverage,
                                                 self.env.code_coverage),
                                             "total_with_children": self.env.len_overall_pcs_with_children
                                             }
        self.env.results["branch_coverage"] = {"percentage": branch_coverage_percentage,
                                               "covered": branch_coverage,
                                               "total": len(self.env.overall_jumpis) * 2}
        self.env.results["coverage_breakdown"] = coverage_breakdown
        self.env.results["coverage_snapshot"] = coverage_snapshot(
            self.env.code_coverage, self.env.overall_pcs, self.env.overall_jumpis,
            self.env.visited_branches, getattr(self.env, "runtime_bytecode", ""),
        )
        self.env.results["execution_time"] = execution_delta
        self.env.results["memory_consumption"] = psutil.Process(os.getpid()).memory_info().rss/1024/1024
        self.env.results["address_under_test"] = self.env.population.indv_generator.contract
        self.env.results["seed"] = self.env.seed
        if hasattr(self.env, "symbolic_execution_stats"):
            self.env.results["symbolic_execution_stats"] = getattr(self.env, "symbolic_execution_stats", {})
        if self._vulnerability_hints_enabled() or hasattr(self.env, "vulnerability_hint_stats"):
            self.env.results["vulnerability_hint_config"] = self._vulnerability_hint_config()
            self.env.results["vulnerability_hint_stats"] = self._vulnerability_hint_snapshot()
        if hasattr(self.env, "uir_selection_config"):
            self.env.results["uir_selection"] = self.env.uir_selection_config
        if uir_summary and not self._report_artifact_writes_disabled():
            self.env.results["uir_coverage"] = uir_summary
            self.env.results["uir_seed_profiles"] = getattr(self.env, "uir_seed_profiles", {})
            self.env.results["uir_seed_archive"] = getattr(self.env, "uir_seed_archive", {})
            if hasattr(self.env, "uir_mutation_stats"):
                self.env.results["uir_mutation_stats"] = getattr(self.env, "uir_mutation_stats", {})
            if hasattr(self.env, "uir_solving_stats"):
                self.env.results["uir_solving_stats"] = getattr(self.env, "uir_solving_stats", {})

            try:
                meta_dir = Path(getattr(self.env, "meta_dir", "") or (Path.cwd() / (str(self.env.contract_name) + "_meta")))
                meta_dir.mkdir(parents=True, exist_ok=True)
                uir_payload = {
                    "contract": self.env.contract_name,
                    "target_path": getattr(self.env, "uir_targets_path", None),
                    "summary": uir_summary,
                    "seed_profiles": getattr(self.env, "uir_seed_profiles", {}),
                    "seed_archive": getattr(self.env, "uir_seed_archive", {}),
                    "mutation_stats": getattr(self.env, "uir_mutation_stats", {}),
                    "solving_stats": getattr(self.env, "uir_solving_stats", {}),
                    "symbolic_execution_stats": getattr(self.env, "symbolic_execution_stats", {}),
                }
                if self._vulnerability_hints_enabled() or hasattr(self.env, "vulnerability_hint_stats"):
                    uir_payload["vulnerability_hint_config"] = self._vulnerability_hint_config()
                    uir_payload["vulnerability_hint_stats"] = self._vulnerability_hint_snapshot()
                    hint_payload = self._write_vulnerability_hint_stats(meta_dir, uir_summary=uir_summary)
                    if hint_payload:
                        self.env.results["vulnerability_hint_report"] = str(meta_dir / "vulnerability_hint_stats.json")
                (meta_dir / "uir_coverage.json").write_text(
                    json.dumps(uir_payload, indent=2, ensure_ascii=False),
                    encoding="utf-8",
                )
                try:
                    refresh_semantic_invariant_report(meta_dir)
                except Exception as exc:
                    self.logger.warning("[UIR] failed to refresh semantic invariant report: %s", exc)
            except Exception as exc:
                self.logger.warning("[UIR] failed to write semantic coverage: %s", exc)

        #  Write results to file
        if (
            (not uir_summary)
            and not self._report_artifact_writes_disabled()
            and (self._vulnerability_hints_enabled() or hasattr(self.env, "vulnerability_hint_stats"))
        ):
            try:
                meta_dir = Path(getattr(self.env, "meta_dir", "") or (Path.cwd() / (str(self.env.contract_name) + "_meta")))
                meta_dir.mkdir(parents=True, exist_ok=True)
                hint_payload = self._write_vulnerability_hint_stats(meta_dir, uir_summary={})
                if hint_payload:
                    self.env.results["vulnerability_hint_report"] = str(meta_dir / "vulnerability_hint_stats.json")
                try:
                    refresh_semantic_invariant_report(meta_dir)
                except Exception as exc:
                    self.logger.warning("[VULN-HINT] failed to refresh semantic invariant report: %s", exc)
            except Exception as exc:
                self.logger.warning("[VULN-HINT] failed to write vulnerability hint stats: %s", exc)

        if self.env.args.results:
            results = {}
            if self.env.args.results.lower().endswith(".json"):
                if os.path.exists(self.env.args.results):
                    with open(self.env.args.results, 'r') as file:
                        results = json.load(file)
                results[self.env.contract_name] = self.env.results
                with open(self.env.args.results, 'w') as file:
                    json.dump(results, file, default=_json_default)
            else:
                if os.path.exists(self.env.args.results + '/' + os.path.splitext(os.path.basename(self.env.contract_name))[0] + '.json'):
                    with open(self.env.args.results + '/' + os.path.splitext(os.path.basename(self.env.contract_name))[0] + '.json', 'r') as file:
                        results = json.load(file)
                results[self.env.contract_name] = self.env.results
                with open(self.env.args.results + '/' + os.path.splitext(os.path.basename(self.env.contract_name))[0] + '.json', 'w') as file:
                    json.dump(results, file, default=_json_default)

        diff = list(set(self.env.code_coverage).symmetric_difference(set([hex(x) for x in self.env.overall_pcs])))
        self.logger.debug("Instructions not executed: %s", sorted(diff))
