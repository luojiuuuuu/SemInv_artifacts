#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Registry and matching logic for semantic invariant specifications."""

from __future__ import annotations

from collections import defaultdict
from typing import Dict, Iterable, List, Sequence

from .facts import SemanticFact
from .spec import INVARIANT_CATEGORIES, InvariantMatch, InvariantSpec, stable_match_id


DEFAULT_DETECTOR_MODULES = [
    "integer_overflow",
    "reentrancy",
    "transaction_order_dependency",
    "new_block_gas_limit_dos",
    "new_unexcepted_ether_balance",
    "unsafe_delegatecall",
    "unprotected_selfdestruct",
    "unchecked_return_value",
    "block_dependency",
    "locking_ether",
    "leaking_ether",
    "assertion_failure",
    "arbitrary_memory_access",
    "new_hashcollision_withmvla",
    "l4_semantic",
]


def default_invariant_specs() -> List[InvariantSpec]:
    return [
        InvariantSpec(
            invariant_id="I1.accounting.sum_supply_consistency",
            category="I1_FINANCIAL_ACCOUNTING",
            name="Balance and supply consistency",
            description="Observed account balances and aggregate supplies should remain mutually consistent.",
            backends=["foundry", "fuzz", "hybrid"],
            required_fact_kinds=["accounting_fact"],
            template_name="sum_supply_consistency",
            detector_names=["integer_overflow", "new_unexcepted_ether_balance"],
            foundry_families=["accounting"],
            violated_property="Balance, supply, and ETH accounting relations must be conserved across calls.",
            swc_ids=["101", "132"],
            severity="high",
            default_confidence=0.7,
            tags=["accounting", "supply", "balance"],
        ),
        InvariantSpec(
            invariant_id="I1.accounting.delta_consistency",
            category="I1_FINANCIAL_ACCOUNTING",
            name="Accounting delta consistency",
            description="Functions that mutate balances, supply, or ETH must preserve expected pre/post deltas.",
            backends=["foundry", "hybrid"],
            required_fact_kinds=["accounting_anomaly_fact", "accounting_fact"],
            match_mode="any",
            template_name="accounting_delta",
            detector_names=["integer_overflow", "leaking_ether", "locking_ether"],
            foundry_families=["accounting_anomaly"],
            violated_property="Balance deltas, supply deltas, and ETH deltas must agree after accounting-sensitive calls.",
            swc_ids=["101", "105"],
            severity="high",
            default_confidence=0.75,
            tags=["delta", "accounting_anomaly"],
        ),
        InvariantSpec(
            invariant_id="I1.eth.conservation",
            category="I1_FINANCIAL_ACCOUNTING",
            name="ETH conservation",
            description="Contract ETH balance must be explainable by tracked inflows and outflows.",
            backends=["foundry", "fuzz", "hybrid"],
            required_fact_kinds=["external_interaction_fact", "accounting_fact"],
            match_mode="any",
            template_name="eth_conservation",
            detector_names=["leaking_ether", "locking_ether", "new_unexcepted_ether_balance"],
            foundry_families=["accounting"],
            violated_property="ETH should not be unexpectedly created, leaked, locked, or used as an exact fragile guard.",
            swc_ids=["105", "132"],
            severity="medium",
            default_confidence=0.65,
            tags=["eth", "balance"],
        ),
        InvariantSpec(
            invariant_id="I2.authorization.access_noninterference",
            category="I2_AUTHORIZATION_ACCESS",
            name="Unauthorized non-interference",
            description="Unauthorized callers must not modify privileged state even when calls do not revert.",
            backends=["foundry", "fuzz", "hybrid"],
            required_fact_kinds=["access_fact", "sensitive_function_fact"],
            match_mode="any",
            template_name="access_noninterference",
            detector_names=["unprotected_selfdestruct", "unsafe_delegatecall"],
            foundry_families=["access"],
            violated_property="Privileged state must not change under attacker-originated calls.",
            swc_ids=["106", "112", "115"],
            severity="high",
            default_confidence=0.75,
            tags=["access", "sensitive"],
        ),
        InvariantSpec(
            invariant_id="I2.authorization.privileged_operation_guard",
            category="I2_AUTHORIZATION_ACCESS",
            name="Privileged operation guard",
            description="Destructive or privilege-changing operations require an authorization guard.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["sensitive_function_fact", "access_fact"],
            match_mode="any",
            template_name="privileged_operation_guard",
            detector_names=["unprotected_selfdestruct", "unsafe_delegatecall"],
            foundry_families=["access"],
            violated_property="Selfdestruct, delegatecall, owner/admin changes, and other privileged effects must be guarded.",
            swc_ids=["106", "112"],
            severity="high",
            default_confidence=0.7,
            tags=["selfdestruct", "delegatecall", "owner"],
        ),
        InvariantSpec(
            invariant_id="I2.authorization.tx_origin_boundary",
            category="I2_AUTHORIZATION_ACCESS",
            name="tx.origin authorization boundary",
            description="tx.origin must not be used as the authorization boundary for sensitive effects.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["sensitive_function_fact", "access_fact", "function_effect_fact"],
            match_mode="any",
            template_name="tx_origin_authorization_monitor",
            detector_names=["l4_semantic"],
            foundry_families=["access"],
            violated_property="Sensitive state or value effects must be authorized by msg.sender/roles rather than tx.origin.",
            swc_ids=["115"],
            severity="high",
            default_confidence=0.65,
            tags=["tx_origin", "authorization", "solidity_benchmark"],
        ),
        InvariantSpec(
            invariant_id="I3.state.domain_validity",
            category="I3_PROTOCOL_STATE_MACHINE",
            name="State domain validity",
            description="Protocol state variables must remain inside their legal domains.",
            backends=["foundry"],
            required_fact_kinds=["state_variable_fact"],
            template_name="state_domain",
            foundry_families=["state"],
            violated_property="State variables must not leave their enum, bool, or bounded integer domains.",
            severity="medium",
            default_confidence=0.65,
            tags=["state", "domain"],
        ),
        InvariantSpec(
            invariant_id="I3.state.legal_transition",
            category="I3_PROTOCOL_STATE_MACHINE",
            name="Legal state transition",
            description="Protocol state may evolve only through recovered legal transitions.",
            backends=["foundry", "hybrid"],
            required_fact_kinds=["state_transition_fact"],
            template_name="state_transition",
            foundry_families=["state_transition"],
            violated_property="State transitions must respect recovered from/to phase constraints.",
            severity="high",
            default_confidence=0.75,
            tags=["state", "transition"],
        ),
        InvariantSpec(
            invariant_id="I3.state.terminal_absorbing",
            category="I3_PROTOCOL_STATE_MACHINE",
            name="Terminal state absorbing",
            description="Terminal protocol states must not roll back to earlier active states.",
            backends=["foundry", "hybrid"],
            required_fact_kinds=["terminal_state_fact", "state_transition_fact"],
            match_mode="any",
            template_name="terminal_absorbing",
            foundry_families=["terminal_no_rollback"],
            violated_property="Once a terminal state is reached, later calls must not reactivate the protocol.",
            severity="high",
            default_confidence=0.8,
            tags=["terminal", "rollback"],
        ),
        InvariantSpec(
            invariant_id="I4.transaction.write_read_consistency",
            category="I4_TRANSACTIONAL_CONSISTENCY",
            name="Write-read relation consistency",
            description="Cross-function write-read relations should remain consistent across multi-call sequences.",
            backends=["foundry", "fuzz", "hybrid"],
            required_fact_kinds=["cross_function_relation_fact"],
            template_name="write_read_sequence",
            detector_names=["transaction_order_dependency"],
            foundry_families=["cross_relation"],
            violated_property="A writer-reader sequence must not break dependent accounting or state assumptions.",
            swc_ids=["114"],
            severity="medium",
            default_confidence=0.7,
            tags=["cross_function", "write_read"],
        ),
        InvariantSpec(
            invariant_id="I4.transaction.order_independence",
            category="I4_TRANSACTIONAL_CONSISTENCY",
            name="Transaction order independence",
            description="Independent user transactions should not produce exploitable outcome differences when swapped.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["cross_function_relation_fact", "function_effect_fact"],
            match_mode="any",
            template_name="swap_order_replay",
            detector_names=["transaction_order_dependency"],
            violated_property="Transaction order should not alter payouts, balances, or privileged outcomes except by intended protocol rules.",
            swc_ids=["114"],
            severity="medium",
            default_confidence=0.65,
            tags=["tod", "front_running"],
        ),
        InvariantSpec(
            invariant_id="I5.execution.numeric_integrity",
            category="I5_RESOURCE_EXECUTION",
            name="Numeric integrity",
            description="Arithmetic values must not wrap or corrupt storage, calls, or branch conditions.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["function_effect_fact", "accounting_fact", "accounting_anomaly_fact"],
            match_mode="any",
            template_name="numeric_integrity_monitor",
            detector_names=["integer_overflow", "assertion_failure", "arbitrary_memory_access"],
            violated_property="User-controlled arithmetic must not overflow, underflow, corrupt memory/storage, or trigger assertion failure.",
            swc_ids=["101", "110", "124"],
            severity="high",
            default_confidence=0.7,
            tags=["overflow", "assertion", "storage_corruption"],
        ),
        InvariantSpec(
            invariant_id="I5.resource.bounded_execution",
            category="I5_RESOURCE_EXECUTION",
            name="Bounded execution resource",
            description="User-controllable state growth must not create unbounded or gas-exhausting execution.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["function_effect_fact", "cross_function_relation_fact"],
            match_mode="any",
            template_name="bounded_resource_monitor",
            detector_names=["new_block_gas_limit_dos"],
            violated_property="Loop/resource bounds must remain bounded by protocol-controlled limits.",
            swc_ids=["128"],
            severity="medium",
            default_confidence=0.65,
            tags=["gas", "dos", "loop"],
        ),
        InvariantSpec(
            invariant_id="I5.resource.progress_availability",
            category="I5_RESOURCE_EXECUTION",
            name="Protocol progress availability",
            description="User-controlled state or external failures must not permanently prevent intended progress.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["function_effect_fact", "cross_function_relation_fact", "external_interaction_fact"],
            match_mode="any",
            template_name="progress_availability_monitor",
            detector_names=["new_block_gas_limit_dos", "locking_ether", "unchecked_return_value"],
            violated_property="A callable progress path should remain available without unbounded gas or unavoidable external-call failure.",
            swc_ids=["104", "128"],
            severity="medium",
            default_confidence=0.6,
            tags=["dos", "progress", "availability"],
        ),
        InvariantSpec(
            invariant_id="I6.external.cei_reentrancy",
            category="I6_EXTERNAL_ENVIRONMENT",
            name="Checks-effects-interactions",
            description="External calls must not precede related state updates in a reentrancy-sensitive way.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["external_interaction_fact", "function_effect_fact"],
            match_mode="any",
            template_name="cei_reentrancy_monitor",
            detector_names=["reentrancy"],
            violated_property="External calls should not expose stale state before related effects are committed.",
            swc_ids=["107"],
            severity="high",
            default_confidence=0.75,
            tags=["reentrancy", "cei"],
        ),
        InvariantSpec(
            invariant_id="I6.external.call_return_consistency",
            category="I6_EXTERNAL_ENVIRONMENT",
            name="External call return consistency",
            description="Failed external calls must not be ignored when subsequent state or financial effects continue.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["external_interaction_fact", "function_effect_fact"],
            match_mode="any",
            template_name="unchecked_return_monitor",
            detector_names=["unchecked_return_value"],
            violated_property="External call return values must be checked before committing dependent state.",
            swc_ids=["104"],
            severity="medium",
            default_confidence=0.65,
            tags=["unchecked_return", "external_call"],
        ),
        InvariantSpec(
            invariant_id="I6.external.environment_dependency",
            category="I6_EXTERNAL_ENVIRONMENT",
            name="Environment dependency safety",
            description="Block, timestamp, balance, or encoding assumptions must not control security-critical outcomes unsafely.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["external_interaction_fact", "function_effect_fact"],
            match_mode="any",
            template_name="environment_dependency_monitor",
            detector_names=["block_dependency", "new_hashcollision_withmvla", "new_unexcepted_ether_balance"],
            violated_property="Environmental values and ambiguous encodings must not decide payouts, privileges, or irreversible state.",
            swc_ids=["120", "132"],
            severity="medium",
            default_confidence=0.6,
            tags=["block_dependency", "hash_collision", "unexpected_balance"],
        ),
        InvariantSpec(
            invariant_id="I6.external.bad_randomness_dependency",
            category="I6_EXTERNAL_ENVIRONMENT",
            name="Bad randomness dependency",
            description="Environment-derived pseudo-randomness must not decide payouts, privileges, or irreversible state.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["external_interaction_fact", "function_effect_fact"],
            match_mode="any",
            template_name="environmental_randomness_monitor",
            detector_names=["block_dependency", "new_hashcollision_withmvla"],
            violated_property="Block/timestamp/hash-derived randomness must not drive security-critical outcomes.",
            swc_ids=["120", "133"],
            severity="medium",
            default_confidence=0.6,
            tags=["bad_randomness", "block_dependency", "hash_collision"],
        ),
        InvariantSpec(
            invariant_id="I6.external.time_dependency",
            category="I6_EXTERNAL_ENVIRONMENT",
            name="Time dependency safety",
            description="Timestamp or block-number dependencies must not directly control security-critical effects.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["external_interaction_fact", "function_effect_fact"],
            match_mode="any",
            template_name="time_dependency_monitor",
            detector_names=["block_dependency"],
            violated_property="Timestamp/block-number taint must not decide payouts, privilege changes, or irreversible transitions unexpectedly.",
            swc_ids=["120"],
            severity="medium",
            default_confidence=0.6,
            tags=["time_manipulation", "timestamp_dependency"],
        ),
        InvariantSpec(
            invariant_id="I6.external.short_calldata_integrity",
            category="I6_EXTERNAL_ENVIRONMENT",
            name="Short calldata integrity",
            description="Malformed or short calldata must not be accepted in a way that commits value or state effects.",
            backends=["fuzz", "hybrid"],
            required_fact_kinds=["function_effect_fact", "external_interaction_fact"],
            match_mode="any",
            template_name="short_calldata_monitor",
            detector_names=["l4_semantic"],
            violated_property="ABI-sensitive calls with malformed/short calldata must fail before committing effects.",
            severity="medium",
            default_confidence=0.45,
            tags=["short_address", "calldata", "abi_integrity"],
        ),
    ]


def specs_by_id(specs: Sequence[InvariantSpec]) -> Dict[str, InvariantSpec]:
    return {spec.invariant_id: spec for spec in specs}


def detector_to_specs(specs: Sequence[InvariantSpec]) -> Dict[str, List[str]]:
    mapping: Dict[str, List[str]] = defaultdict(list)
    for spec in specs:
        for detector_name in spec.detector_names:
            mapping[detector_name].append(spec.invariant_id)
    return {name: sorted(ids) for name, ids in mapping.items()}


def _fact_matches_spec(fact: SemanticFact, spec: InvariantSpec) -> bool:
    if not spec.required_fact_kinds:
        return False
    if fact.kind not in spec.required_fact_kinds:
        return False
    tags = set(fact.categories + fact.risk_tags + fact.source_facts)

    if spec.invariant_id.startswith("I1."):
        return fact.kind in ("accounting_fact", "accounting_anomaly_fact", "external_interaction_fact") or bool(tags & {"accounting", "accounting_anomaly", "accounting_relation"})
    if spec.invariant_id.startswith("I2."):
        return fact.kind in ("access_fact", "sensitive_function_fact") or bool(tags & {"access", "access_guarded", "guarded_sensitive", "sensitive"})
    if spec.invariant_id.startswith("I3."):
        return fact.kind in ("state_variable_fact", "state_transition_fact", "terminal_state_fact") or bool(tags & {"state_machine", "state_transition", "terminal_state"})
    if spec.invariant_id.startswith("I4."):
        return fact.kind in ("cross_function_relation_fact", "function_effect_fact") or bool(tags & {"cross_relation", "dfg"})
    if spec.invariant_id.startswith("I5."):
        return fact.kind in ("function_effect_fact", "accounting_fact", "accounting_anomaly_fact", "cross_function_relation_fact")
    if spec.invariant_id.startswith("I6."):
        return fact.kind in ("external_interaction_fact", "function_effect_fact")
    return True


def match_specs_to_facts(
    specs: Sequence[InvariantSpec],
    facts: Iterable[SemanticFact],
) -> List[InvariantMatch]:
    grouped: Dict[tuple, List[SemanticFact]] = defaultdict(list)
    fact_list = list(facts)

    for spec in specs:
        for fact in fact_list:
            if not _fact_matches_spec(fact, spec):
                continue
            key_function = fact.function or ""
            key_storage = tuple(sorted(fact.storage))
            key = (spec.invariant_id, fact.contract, key_function, key_storage)
            grouped[key].append(fact)

    matches: List[InvariantMatch] = []
    for (invariant_id, contract, _function, _storage), group in grouped.items():
        spec = next(s for s in specs if s.invariant_id == invariant_id)
        fact_kinds = sorted({f.kind for f in group})
        if spec.match_mode == "all" and not set(spec.required_fact_kinds).issubset(set(fact_kinds)):
            continue
        functions = sorted({f.function for f in group if f.function})
        selectors = sorted({f.selector for f in group if f.selector})
        storage = sorted({s for f in group for s in f.storage})
        sources = sorted({source for f in group for source in f.source})
        avg_conf = sum(f.confidence for f in group) / len(group)
        confidence = max(spec.default_confidence, min(0.95, (avg_conf + spec.default_confidence) / 2.0))
        match_id = stable_match_id([
            invariant_id,
            contract,
            functions,
            selectors,
            storage,
            sorted(f.fact_id for f in group),
        ])
        matches.append(InvariantMatch(
            match_id=match_id,
            invariant_id=invariant_id,
            category=spec.category,
            contract=contract,
            fact_ids=sorted(f.fact_id for f in group),
            functions=functions,
            selectors=selectors,
            storage=storage,
            source_fact_kinds=fact_kinds,
            evidence_sources=sources,
            confidence=round(confidence, 4),
            reason=f"matched {len(group)} semantic fact(s): {', '.join(fact_kinds)}",
        ))

    return sorted(matches, key=lambda m: (m.contract, m.category, m.invariant_id, m.functions, m.storage, m.match_id))


def validate_registry(specs: Sequence[InvariantSpec]) -> Dict[str, object]:
    category_counts = {category: 0 for category in INVARIANT_CATEGORIES}
    for spec in specs:
        category_counts[spec.category] += 1
    detector_mapping = detector_to_specs(specs)
    missing_detectors = sorted(set(DEFAULT_DETECTOR_MODULES) - set(detector_mapping.keys()))
    return {
        "spec_count": len(specs),
        "category_counts": category_counts,
        "categories_covered": sorted(category for category, count in category_counts.items() if count > 0),
        "missing_categories": sorted(category for category, count in category_counts.items() if count == 0),
        "detector_mapping": detector_mapping,
        "expected_detectors": DEFAULT_DETECTOR_MODULES,
        "detectors_mapped": sorted(detector_mapping.keys()),
        "missing_detectors": missing_detectors,
    }
