#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Benchmark-label coverage taxonomy for the six invariant families.

This module is deliberately metadata-first.  It does not replace the existing
detectors or Foundry generators; it names how SB Curated and SolidiFI labels map
onto the invariant-led L3/L4 system, including trigger templates and reporting
classification.
"""

from __future__ import annotations

import os
from typing import Any, Dict, Iterable, List, Optional


TAXONOMY_SCHEMA_VERSION = "con-fuzzius.benchmark_invariant_taxonomy.v1"


SIX_INVARIANT_FAMILIES: Dict[str, Dict[str, str]] = {
    "I1_FINANCIAL_ACCOUNTING": {
        "name": "Financial & Accounting Invariants",
        "zh": "金融与会计一致性",
        "primary_backend": "foundry",
    },
    "I2_AUTHORIZATION_ACCESS": {
        "name": "Authorization & Access Control Invariants",
        "zh": "授权与访问控制",
        "primary_backend": "foundry",
    },
    "I3_PROTOCOL_STATE_MACHINE": {
        "name": "Protocol State Machine Invariants",
        "zh": "协议状态机不变量",
        "primary_backend": "foundry",
    },
    "I4_TRANSACTIONAL_CONSISTENCY": {
        "name": "Transactional Consistency Invariants",
        "zh": "事务一致性 / 跨交易约束",
        "primary_backend": "fuzz",
    },
    "I5_RESOURCE_EXECUTION": {
        "name": "Resource & Execution Integrity Invariants",
        "zh": "资源与执行完整性",
        "primary_backend": "fuzz",
    },
    "I6_EXTERNAL_ENVIRONMENT": {
        "name": "External Interaction & Environment Invariants",
        "zh": "外部交互与环境不变量",
        "primary_backend": "fuzz",
    },
}

BENCHMARK_LABEL_SPECS: List[Dict[str, Any]] = [
    {
        "benchmark": "SB Curated",
        "label": "reentrancy",
        "aliases": ["Reentrancy"],
        "invariant_id": "I6.external.cei_reentrancy",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "external_call_before_related_state_update",
        "report_kind": "reentrancy",
        "detector_types": ["Reentrancy", "L4 Cross Function CEI"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SB Curated",
        "label": "access_control",
        "aliases": ["Access Control"],
        "invariant_id": "I2.authorization.access_noninterference",
        "category": "I2_AUTHORIZATION_ACCESS",
        "backend": "L3/L4",
        "trigger_template": "unauthorized_sensitive_call_changes_privileged_state",
        "report_kind": "access_noninterference",
        "detector_types": ["Unprotected Selfdestruct", "Unsafe Delegatecall", "L4 Access Noninterference", "L4 Unsafe Delegatecall"],
        "foundry_kinds": ["access_negative_call", "supplement_access_noninterference"],
    },
    {
        "benchmark": "SB Curated",
        "label": "arithmetic",
        "aliases": ["Arithmetic", "integer_overflow", "integer_underflow"],
        "invariant_id": "I5.execution.numeric_integrity",
        "category": "I5_RESOURCE_EXECUTION",
        "backend": "L4",
        "trigger_template": "tainted_arithmetic_wraps_into_storage_call_or_branch",
        "report_kind": "numeric_integrity",
        "detector_types": ["Integer Overflow", "Assertion Failure", "Arbitrary Memory Access", "L4 Numeric Integrity"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SB Curated",
        "label": "unchecked_low_level_calls",
        "aliases": ["Unchecked Low Level Calls", "unchecked_call"],
        "invariant_id": "I6.external.call_return_consistency",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "low_level_call_return_not_checked_before_effect",
        "report_kind": "call_return_consistency",
        "detector_types": ["Unchecked Return Value", "L4 Call Return Consistency", "unchecked_return_value"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SB Curated",
        "label": "denial_of_service",
        "aliases": ["Denial of Service", "DoS"],
        "invariant_id": "I5.resource.bounded_execution",
        "category": "I5_RESOURCE_EXECUTION",
        "backend": "L4",
        "trigger_template": "user_controlled_resource_growth_or_block_gas_limit_dos",
        "report_kind": "bounded_execution",
        "detector_types": ["DoS With Block Gas Limit", "Locking Ether", "L4 Failed Refund DoS", "failed_refund_dos"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SB Curated",
        "label": "bad_randomness",
        "aliases": ["Bad Randomness", "randomness"],
        "invariant_id": "I6.external.bad_randomness_dependency",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "environmental_randomness_taints_payout_or_irreversible_state",
        "report_kind": "bad_randomness_dependency",
        "detector_types": ["Block Dependency", "Hash Collision", "L4 Bad Randomness Dependency", "bad_randomness_dependency"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SB Curated",
        "label": "front_running",
        "aliases": ["Front Running", "TOD"],
        "invariant_id": "I4.transaction.order_independence",
        "category": "I4_TRANSACTIONAL_CONSISTENCY",
        "backend": "L4",
        "trigger_template": "swap_two_transactions_and_compare_state_or_payout",
        "report_kind": "order_independence",
        "detector_types": ["Transaction Order Dependency", "L4 Preimage Front Running", "L4 ERC20 Approve Race", "approve_race"],
        "foundry_kinds": ["write_read_consistency"],
    },
    {
        "benchmark": "SB Curated",
        "label": "time_manipulation",
        "aliases": ["Time Manipulation", "timestamp_dependency"],
        "invariant_id": "I6.external.time_dependency",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "timestamp_or_block_number_taints_security_critical_branch",
        "report_kind": "time_dependency",
        "detector_types": ["Block Dependency"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SB Curated",
        "label": "short_addresses",
        "aliases": ["Short Addresses", "short_address"],
        "invariant_id": "I6.external.short_calldata_integrity",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "malformed_or_short_calldata_must_not_commit_effects",
        "report_kind": "short_calldata_integrity",
        "detector_types": ["L4 Short Calldata Integrity"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SolidiFI",
        "label": "re_entrancy",
        "aliases": ["Re-entrancy", "Reentrancy"],
        "invariant_id": "I6.external.cei_reentrancy",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "external_call_before_related_state_update",
        "report_kind": "reentrancy",
        "detector_types": ["Reentrancy"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SolidiFI",
        "label": "timestamp_dependency",
        "aliases": ["Timestamp-Dependency"],
        "invariant_id": "I6.external.time_dependency",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "timestamp_or_block_number_taints_security_critical_branch",
        "report_kind": "time_dependency",
        "detector_types": ["Block Dependency"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SolidiFI",
        "label": "unchecked_send",
        "aliases": ["Unchecked-Send"],
        "invariant_id": "I6.external.call_return_consistency",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "send_or_call_return_not_checked_before_effect",
        "report_kind": "call_return_consistency",
        "detector_types": ["Unchecked Return Value"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SolidiFI",
        "label": "unhandled_exceptions",
        "aliases": ["Unhandled-Exceptions"],
        "invariant_id": "I6.external.call_return_consistency",
        "category": "I6_EXTERNAL_ENVIRONMENT",
        "backend": "L4",
        "trigger_template": "failed_external_call_is_ignored",
        "report_kind": "call_return_consistency",
        "detector_types": ["Unchecked Return Value"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SolidiFI",
        "label": "tod",
        "aliases": ["TOD", "Transaction Order Dependency"],
        "invariant_id": "I4.transaction.order_independence",
        "category": "I4_TRANSACTIONAL_CONSISTENCY",
        "backend": "L4",
        "trigger_template": "swap_two_transactions_and_compare_state_or_payout",
        "report_kind": "order_independence",
        "detector_types": ["Transaction Order Dependency"],
        "foundry_kinds": ["write_read_consistency"],
    },
    {
        "benchmark": "SolidiFI",
        "label": "overflow_underflow",
        "aliases": ["Overflow-Underflow", "Overflow", "Underflow"],
        "invariant_id": "I5.execution.numeric_integrity",
        "category": "I5_RESOURCE_EXECUTION",
        "backend": "L4",
        "trigger_template": "tainted_arithmetic_wraps_into_storage_call_or_branch",
        "report_kind": "numeric_integrity",
        "detector_types": ["Integer Overflow"],
        "foundry_kinds": [],
    },
    {
        "benchmark": "SolidiFI",
        "label": "tx_origin",
        "aliases": ["tx.origin", "tx_origin"],
        "invariant_id": "I2.authorization.tx_origin_boundary",
        "category": "I2_AUTHORIZATION_ACCESS",
        "backend": "L4",
        "trigger_template": "tx_origin_must_not_authorize_sensitive_effect",
        "report_kind": "tx_origin_boundary",
        "detector_types": ["L4 TxOrigin Boundary"],
        "foundry_kinds": [],
    },
]


TRIGGER_TEMPLATE_DEFINITIONS: Dict[str, Dict[str, Any]] = {
    "external_call_before_related_state_update": {
        "backend": "L4",
        "evidence": ["CALL/DELEGATECALL", "related SLOAD before CALL", "related SSTORE after CALL"],
    },
    "unauthorized_sensitive_call_changes_privileged_state": {
        "backend": "L3/L4",
        "evidence": ["sensitive function", "missing/failed authorization guard", "critical state write"],
    },
    "tainted_arithmetic_wraps_into_storage_call_or_branch": {
        "backend": "L4",
        "evidence": ["tainted ADD/SUB/MUL wrap", "flow into SSTORE/CALL/branch"],
    },
    "low_level_call_return_not_checked_before_effect": {
        "backend": "L4",
        "evidence": ["CALL-like opcode", "return value not consumed by branch", "subsequent effect"],
    },
    "user_controlled_resource_growth_or_block_gas_limit_dos": {
        "backend": "L4",
        "evidence": ["user-controlled loop/resource", "gas-sensitive path", "DoS detector hit"],
    },
    "environmental_randomness_taints_payout_or_irreversible_state": {
        "backend": "L4",
        "evidence": ["TIMESTAMP/NUMBER/BLOCKHASH/PREVRANDAO", "tainted payout/branch/SSTORE"],
    },
    "swap_two_transactions_and_compare_state_or_payout": {
        "backend": "L4",
        "evidence": ["write-read relation", "multi-tx sequence", "order-sensitive effect"],
    },
    "timestamp_or_block_number_taints_security_critical_branch": {
        "backend": "L4",
        "evidence": ["TIMESTAMP/NUMBER", "tainted JUMPI", "sensitive effect reachable"],
    },
    "malformed_or_short_calldata_must_not_commit_effects": {
        "backend": "L4",
        "evidence": ["short/malformed calldata", "ABI-sensitive function", "state/value effect"],
    },
    "send_or_call_return_not_checked_before_effect": {
        "backend": "L4",
        "evidence": ["SEND/CALL", "ignored return value", "state/value effect continues"],
    },
    "failed_external_call_is_ignored": {
        "backend": "L4",
        "evidence": ["external call failure", "no revert/guard", "dependent effect"],
    },
    "tx_origin_must_not_authorize_sensitive_effect": {
        "backend": "L4",
        "evidence": ["ORIGIN opcode", "authorization branch", "sensitive state/value effect"],
    },
}


def _normalize(value: Any) -> str:
    return str(value or "").strip().lower().replace("-", "_").replace(" ", "_")


def benchmark_taxonomy() -> Dict[str, Any]:
    by_benchmark: Dict[str, List[Dict[str, Any]]] = {}
    for item in BENCHMARK_LABEL_SPECS:
        by_benchmark.setdefault(item["benchmark"], []).append(dict(item))
    return {
        "schema_version": TAXONOMY_SCHEMA_VERSION,
        "six_invariant_families": SIX_INVARIANT_FAMILIES,
        "trigger_templates": TRIGGER_TEMPLATE_DEFINITIONS,
        "benchmarks": by_benchmark,
    }


def support_matrix() -> Dict[str, Any]:
    by_benchmark: Dict[str, Dict[str, Any]] = {}
    for item in BENCHMARK_LABEL_SPECS:
        benchmark = item["benchmark"]
        entry = {
            "label": item["label"],
            "aliases": list(item.get("aliases") or []),
            "invariant_id": item["invariant_id"],
            "category": item["category"],
            "family": SIX_INVARIANT_FAMILIES[item["category"]]["name"],
            "backend": item["backend"],
            "trigger_template": item["trigger_template"],
            "report_kind": item["report_kind"],
            "coverage_level": "type-level",
        }
        by_benchmark.setdefault(benchmark, {"labels": []})["labels"].append(entry)
    for benchmark, item in by_benchmark.items():
        labels = item["labels"]
        item["label_count"] = len(labels)
        item["categories_covered"] = sorted({x["category"] for x in labels})
        item["all_labels_have_specs"] = all(x.get("invariant_id") and x.get("trigger_template") for x in labels)
    return {
        "schema_version": TAXONOMY_SCHEMA_VERSION,
        "coverage_claim": "type-level benchmark-label coverage for the six invariant families",
        "benchmarks": by_benchmark,
    }


def labels_for_detector_type(detector_type: Any) -> List[Dict[str, Any]]:
    detector_type = str(detector_type or "")
    out = []
    for item in BENCHMARK_LABEL_SPECS:
        if detector_type in (item.get("detector_types") or []):
            out.append(dict(item))
    return out


def labels_for_foundry_kind(kind: Any, family: Any = None, test_name: Any = None) -> List[Dict[str, Any]]:
    kind_norm = _normalize(kind)
    family_norm = _normalize(family)
    test_norm = _normalize(test_name)
    out = []
    for item in BENCHMARK_LABEL_SPECS:
        foundry_kinds = {_normalize(x) for x in (item.get("foundry_kinds") or [])}
        if kind_norm in foundry_kinds or family_norm in foundry_kinds:
            out.append(dict(item))
            continue
    return out


def classification_for_invariant_id(invariant_id: Optional[str]) -> Dict[str, Any]:
    if not invariant_id:
        return {}
    for item in BENCHMARK_LABEL_SPECS:
        if item.get("invariant_id") == invariant_id:
            category = item["category"]
            return {
                "invariant_id": invariant_id,
                "invariant_category": category,
                "invariant_family": SIX_INVARIANT_FAMILIES[category]["name"],
                "invariant_family_zh": SIX_INVARIANT_FAMILIES[category]["zh"],
                "primary_backend": SIX_INVARIANT_FAMILIES[category]["primary_backend"],
            }
    prefix_map = [
        ("I1.", "I1_FINANCIAL_ACCOUNTING"),
        ("I2.", "I2_AUTHORIZATION_ACCESS"),
        ("I3.", "I3_PROTOCOL_STATE_MACHINE"),
        ("I4.", "I4_TRANSACTIONAL_CONSISTENCY"),
        ("I5.", "I5_RESOURCE_EXECUTION"),
        ("I6.", "I6_EXTERNAL_ENVIRONMENT"),
    ]
    for prefix, category in prefix_map:
        if str(invariant_id).startswith(prefix):
            return {
                "invariant_id": invariant_id,
                "invariant_category": category,
                "invariant_family": SIX_INVARIANT_FAMILIES[category]["name"],
                "invariant_family_zh": SIX_INVARIANT_FAMILIES[category]["zh"],
                "primary_backend": SIX_INVARIANT_FAMILIES[category]["primary_backend"],
            }
    return {}


def enrich_classification(
    classification: Dict[str, Any],
    *,
    detector_type: Any = None,
    foundry_kind: Any = None,
    foundry_family: Any = None,
    test_name: Any = None,
) -> Dict[str, Any]:
    out = dict(classification or {})
    disable_label_preservation = os.environ.get(
        "SEMINV_ABLATION_NO_LABEL_PRESERVATION",
        "",
    ).strip().lower() in {"1", "true", "yes", "on"}
    direct_foundry_id = None
    foundry_kind_norm = _normalize(foundry_kind)
    foundry_family_norm = _normalize(foundry_family)
    test_norm = _normalize(test_name)
    if foundry_family_norm in ("accounting", "accounting_anomaly") or any(token in test_norm for token in ("accounting", "supply", "rounding", "precision", "drift")):
        direct_foundry_id = "I1.accounting.delta_consistency" if (
            "delta" in foundry_kind_norm or "anomaly" in foundry_family_norm or "postcheck" in foundry_kind_norm
            or any(token in test_norm for token in ("rounding", "precision", "drift"))
        ) else "I1.accounting.sum_supply_consistency"
    elif foundry_family_norm in ("access", "authorization") or any(token in test_norm for token in ("access", "owner", "auth")):
        direct_foundry_id = "I2.authorization.access_noninterference"
    elif foundry_family_norm in ("state", "state_machine") or any(token in test_norm for token in ("state", "phase", "terminal", "transition")):
        direct_foundry_id = "I3.state.terminal_absorbing" if "terminal" in foundry_kind_norm or "terminal" in test_norm else "I3.state.legal_transition"
    elif foundry_family_norm in ("transaction", "cross_relation") or any(token in test_norm for token in ("cross", "order", "transition_fn")):
        direct_foundry_id = "I4.transaction.write_read_consistency"

    if direct_foundry_id:
        out.setdefault("invariant_id", direct_foundry_id)
        out.update({k: v for k, v in classification_for_invariant_id(direct_foundry_id).items() if v is not None})

    labels = []
    if detector_type:
        labels.extend(labels_for_detector_type(detector_type))
    if foundry_kind or foundry_family or test_name:
        labels.extend(labels_for_foundry_kind(foundry_kind, foundry_family, test_name))

    # Preserve explicit L4/L3 classification when it already carries an id.
    explicit_id = out.get("invariant_id")
    if explicit_id:
        out.update(classification_for_invariant_id(explicit_id))

    if labels and not disable_label_preservation:
        first = labels[0]
        out.setdefault("invariant_id", first["invariant_id"])
        out.setdefault("invariant_category", first["category"])
        out.setdefault("invariant_family", SIX_INVARIANT_FAMILIES[first["category"]]["name"])
        out.setdefault("invariant_family_zh", SIX_INVARIANT_FAMILIES[first["category"]]["zh"])
        out.setdefault("primary_backend", SIX_INVARIANT_FAMILIES[first["category"]]["primary_backend"])
        out["benchmark_labels"] = [
            {
                "benchmark": item["benchmark"],
                "label": item["label"],
                "invariant_id": item["invariant_id"],
                "trigger_template": item["trigger_template"],
                "backend": item["backend"],
            }
            for item in labels
        ]
        out["trigger_templates"] = sorted({item["trigger_template"] for item in labels})
    elif disable_label_preservation:
        out.pop("benchmark_labels", None)
        out.pop("trigger_templates", None)

    return out


def all_benchmark_labels_covered() -> bool:
    return all(item.get("invariant_id") and item.get("trigger_template") and item.get("category") for item in BENCHMARK_LABEL_SPECS)

