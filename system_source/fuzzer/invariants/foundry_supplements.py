#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""L3 Foundry invariant supplement planning.

This layer is intentionally conservative. It derives concrete supplemental
Foundry invariant opportunities from L1 facts and L2 matches, but it does not
change the current generated Solidity by default. The plan records which
supplements are already covered by existing templates and which are safe
candidates for a later opt-in codegen pass.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import asdict, dataclass, field
from typing import Any, Dict, Iterable, List, Optional, Sequence

from .facts import SemanticFact
from .spec import InvariantMatch


FOUNDRY_SUPPLEMENT_SCHEMA_VERSION = "con-fuzzius.foundry_supplement_plan.v1"


SUPPLEMENT_TYPES = [
    "accounting_delta_invariant",
    "access_noninterference_invariant",
    "terminal_absorbing_invariant",
    "cross_function_relation_invariant",
]


def _stable_id(parts: Iterable[Any]) -> str:
    raw = json.dumps(list(parts), sort_keys=True, ensure_ascii=True, default=str)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()[:24]


def _str_list(value: Any) -> List[str]:
    if value is None:
        return []
    if isinstance(value, str):
        values = [value]
    elif isinstance(value, (list, tuple, set)):
        values = list(value)
    else:
        values = [value]
    out: List[str] = []
    seen = set()
    for item in values:
        text = str(item).strip()
        if not text or text in seen:
            continue
        seen.add(text)
        out.append(text)
    return out


def _critical_storage_names(facts: Sequence[SemanticFact], contract: str) -> List[str]:
    critical_tokens = [
        "owner",
        "admin",
        "role",
        "supply",
        "balance",
        "allowance",
        "phase",
        "state",
        "status",
        "implementation",
    ]
    names = set()
    for fact in facts:
        if fact.contract != contract:
            continue
        for name in fact.storage:
            lower = name.lower()
            if any(token in lower for token in critical_tokens):
                names.add(name)
    return sorted(names)


@dataclass
class FoundrySupplementPlan:
    plan_id: str
    supplement_type: str
    contract: str
    invariant_id: str
    category: str
    template_name: str
    target_functions: List[str] = field(default_factory=list)
    target_storage: List[str] = field(default_factory=list)
    fact_ids: List[str] = field(default_factory=list)
    match_ids: List[str] = field(default_factory=list)
    current_coverage: str = "new_candidate"
    safety_status: str = "metadata_only"
    rationale: str = ""
    preconditions: List[str] = field(default_factory=list)
    validation_hints: List[str] = field(default_factory=list)
    schema_version: str = FOUNDRY_SUPPLEMENT_SCHEMA_VERSION

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


def _fact_by_id(facts: Iterable[SemanticFact]) -> Dict[str, SemanticFact]:
    return {fact.fact_id: fact for fact in facts}


def _plan_from_match(
    *,
    match: InvariantMatch,
    facts_by_id: Dict[str, SemanticFact],
    supplement_type: str,
    template_name: str,
    current_coverage: str,
    rationale: str,
    preconditions: Iterable[str],
    validation_hints: Iterable[str],
    target_storage: Optional[Iterable[str]] = None,
    target_functions: Optional[Iterable[str]] = None,
    safety_status: str = "metadata_only",
) -> FoundrySupplementPlan:
    storage = _str_list(target_storage if target_storage is not None else match.storage)
    functions = _str_list(target_functions if target_functions is not None else match.functions)
    plan_id = _stable_id([
        supplement_type,
        match.contract,
        match.invariant_id,
        functions,
        storage,
        match.match_id,
    ])
    fact_ids = sorted(fid for fid in match.fact_ids if fid in facts_by_id)
    return FoundrySupplementPlan(
        plan_id=plan_id,
        supplement_type=supplement_type,
        contract=match.contract,
        invariant_id=match.invariant_id,
        category=match.category,
        template_name=template_name,
        target_functions=functions,
        target_storage=storage,
        fact_ids=fact_ids,
        match_ids=[match.match_id],
        current_coverage=current_coverage,
        safety_status=safety_status,
        rationale=rationale,
        preconditions=_str_list(preconditions),
        validation_hints=_str_list(validation_hints),
    )


def build_foundry_supplement_plans(
    *,
    facts: Sequence[SemanticFact],
    matches: Sequence[InvariantMatch],
) -> List[FoundrySupplementPlan]:
    facts_by_id = _fact_by_id(facts)
    plans: Dict[str, FoundrySupplementPlan] = {}

    for match in matches:
        if match.invariant_id == "I1.accounting.delta_consistency":
            functions = match.functions
            storage = match.storage
            if not functions or len(storage) < 1:
                continue
            plan = _plan_from_match(
                match=match,
                facts_by_id=facts_by_id,
                supplement_type="accounting_delta_invariant",
                template_name="accounting_delta_pre_post",
                current_coverage=(
                    "partially_covered_by_existing_accounting_anomaly_postcheck"
                    if any(kind == "accounting_anomaly_fact" for kind in match.source_fact_kinds)
                    else "partially_covered_by_existing_accounting_sum_invariant"
                ),
                safety_status="metadata_only",
                rationale=(
                    "Generate a pre/post delta check for accounting-sensitive functions "
                    "so balance, supply, and ETH deltas are compared directly."
                ),
                preconditions=[
                    "target function has a handler wrapper",
                    "mapping/scalar readers can be resolved",
                    "default arguments are buildable for directed calls",
                ],
                validation_hints=[
                    "ResearchTarget.mint should remain detectable as accounting anomaly",
                    "standard token transfer should not fail supply delta checks",
                ],
                target_functions=functions,
                target_storage=storage,
            )
            plans[plan.plan_id] = plan

        elif match.invariant_id == "I2.authorization.access_noninterference":
            functions = match.functions
            if not functions:
                continue
            critical_storage = _critical_storage_names(facts, match.contract)
            plan = _plan_from_match(
                match=match,
                facts_by_id=facts_by_id,
                supplement_type="access_noninterference_invariant",
                template_name="unauthorized_state_noninterference",
                current_coverage="extends_existing_access_revert_check",
                safety_status="metadata_only",
                rationale=(
                    "Existing access checks assert that unauthorized calls revert. "
                    "This supplement records the stronger non-interference property: "
                    "privileged state should not change even if a call unexpectedly returns."
                ),
                preconditions=[
                    "critical storage has public or generated read access",
                    "target function has ABI-compatible default arguments",
                    "attacker prank does not permanently poison handler state",
                ],
                validation_hints=[
                    "attacker call should not change owner/admin/supply/phase",
                    "successful unauthorized call with changed critical storage is a high-value finding",
                ],
                target_functions=functions,
                target_storage=critical_storage or match.storage,
            )
            plans[plan.plan_id] = plan

        elif match.invariant_id == "I3.state.terminal_absorbing":
            storage = match.storage
            if not storage:
                continue
            plan = _plan_from_match(
                match=match,
                facts_by_id=facts_by_id,
                supplement_type="terminal_absorbing_invariant",
                template_name="terminal_no_rollback",
                current_coverage="covered_by_existing_modern_terminal_no_rollback_when_handler_tracks_state",
                safety_status="metadata_only",
                rationale=(
                    "Terminal state facts should be enforced as absorbing states. "
                    "Modern codegen already emits generic terminal no-rollback checks "
                    "when terminal candidates are resolvable."
                ),
                preconditions=[
                    "terminal candidates resolve to comparable enum/bool/uint values",
                    "handler tracks entered_terminal and curr state snapshots",
                ],
                validation_hints=[
                    "close/reset-style rollback should produce a terminal rollback finding",
                    "state domain checks should remain valid after arbitrary handler sequences",
                ],
                target_storage=storage,
            )
            plans[plan.plan_id] = plan

        elif match.invariant_id == "I4.transaction.write_read_consistency":
            if not match.functions and not match.storage:
                continue
            plan = _plan_from_match(
                match=match,
                facts_by_id=facts_by_id,
                supplement_type="cross_function_relation_invariant",
                template_name="writer_reader_sequence_property",
                current_coverage="partially_covered_by_existing_cross_invariant_bounds",
                safety_status="metadata_only",
                rationale=(
                    "Existing cross invariants bound related variables. This supplement "
                    "records stronger writer-reader sequence properties for future opt-in "
                    "Foundry generation."
                ),
                preconditions=[
                    "both writer and reader functions have handler wrappers",
                    "related storage readers can be resolved",
                    "sequence can be generated without unsupported argument types",
                ],
                validation_hints=[
                    "write-read pair coverage should increase",
                    "TOD/front-running contracts should show earlier sequence-sensitive findings",
                ],
            )
            plans[plan.plan_id] = plan

    return sorted(plans.values(), key=lambda p: (p.contract, p.supplement_type, p.target_functions, p.target_storage, p.plan_id))


def plans_to_jsonable(plans: Iterable[FoundrySupplementPlan]) -> List[Dict[str, Any]]:
    return [plan.to_dict() for plan in plans]
