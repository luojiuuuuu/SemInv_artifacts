#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Semantic fact extraction for invariant-oriented analysis artifacts.

The L1 layer is deliberately adapter-like: it converts existing Foundry
analysis artifacts and UIR target files into normalized semantic facts without
changing the current invariant generation or detector logic.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional


SEMANTIC_FACT_SCHEMA_VERSION = "con-fuzzius.semantic_fact.v1"


def _jsonable(value: Any) -> Any:
    if value is None or isinstance(value, (str, int, float, bool)):
        return value
    if isinstance(value, (list, tuple, set)):
        return [_jsonable(v) for v in value]
    if isinstance(value, dict):
        return {str(k): _jsonable(v) for k, v in value.items()}
    return str(value)


def _stable_id(parts: Iterable[Any]) -> str:
    raw = json.dumps([_jsonable(p) for p in parts], sort_keys=True, ensure_ascii=True)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()[:24]


def _read_json(path: Optional[Path]) -> Optional[Any]:
    if path is None or not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8", errors="ignore"))
    except Exception:
        return None


def _list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    if isinstance(value, tuple):
        return list(value)
    if isinstance(value, set):
        return sorted(value)
    return [value]


def _str_list(value: Any) -> List[str]:
    out: List[str] = []
    seen = set()
    for item in _list(value):
        if item is None:
            continue
        text = str(item).strip()
        if not text or text in seen:
            continue
        seen.add(text)
        out.append(text)
    return out


def _contract_name_from_meta_dir(meta_dir: Path, analysis: Optional[Dict[str, Any]] = None) -> str:
    if isinstance(analysis, dict):
        meta = analysis.get("meta") or {}
        name = meta.get("contract_name")
        if name:
            return str(name)
    name = meta_dir.name
    return name[:-5] if name.endswith("_meta") else name


def _selector_for_function(uir_targets: Optional[Dict[str, Any]], function_name: Optional[str]) -> Optional[str]:
    if not function_name or not isinstance(uir_targets, dict):
        return None
    mapping = uir_targets.get("function_name_to_selector") or {}
    selector = mapping.get(function_name)
    if selector:
        return str(selector)
    # Never guess when a name is overloaded. The exact-signature map remains
    # available to callers that have signature-level evidence.
    return None


@dataclass
class SemanticFact:
    fact_id: str
    kind: str
    contract: str
    source: List[str]
    confidence: float = 0.6
    function: Optional[str] = None
    selector: Optional[str] = None
    signature: Optional[str] = None
    storage: List[str] = field(default_factory=list)
    reads: List[str] = field(default_factory=list)
    writes: List[str] = field(default_factory=list)
    categories: List[str] = field(default_factory=list)
    risk_tags: List[str] = field(default_factory=list)
    source_facts: List[str] = field(default_factory=list)
    detail: Dict[str, Any] = field(default_factory=dict)
    schema_version: str = SEMANTIC_FACT_SCHEMA_VERSION

    @classmethod
    def build(
        cls,
        *,
        kind: str,
        contract: str,
        source: Iterable[str],
        confidence: float = 0.6,
        function: Optional[str] = None,
        selector: Optional[str] = None,
        signature: Optional[str] = None,
        storage: Optional[Iterable[Any]] = None,
        reads: Optional[Iterable[Any]] = None,
        writes: Optional[Iterable[Any]] = None,
        categories: Optional[Iterable[Any]] = None,
        risk_tags: Optional[Iterable[Any]] = None,
        source_facts: Optional[Iterable[Any]] = None,
        detail: Optional[Dict[str, Any]] = None,
        identity: Optional[Iterable[Any]] = None,
    ) -> "SemanticFact":
        storage_values = _str_list(storage)
        read_values = _str_list(reads)
        write_values = _str_list(writes)
        category_values = _str_list(categories)
        risk_values = _str_list(risk_tags)
        source_fact_values = _str_list(source_facts)
        source_values = _str_list(source)
        detail_value = _jsonable(detail or {})
        identity_parts = list(identity or [
            kind,
            contract,
            function,
            selector,
            signature,
            storage_values,
            read_values,
            write_values,
            category_values,
            risk_values,
            detail_value,
        ])
        return cls(
            fact_id=_stable_id(identity_parts),
            kind=kind,
            contract=contract,
            source=source_values,
            confidence=float(confidence),
            function=function,
            selector=selector,
            signature=signature,
            storage=storage_values,
            reads=read_values,
            writes=write_values,
            categories=category_values,
            risk_tags=risk_values,
            source_facts=source_fact_values,
            detail=detail_value if isinstance(detail_value, dict) else {"value": detail_value},
        )

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


def _add_fact(facts: Dict[str, SemanticFact], fact: SemanticFact) -> None:
    existing = facts.get(fact.fact_id)
    if existing is None:
        facts[fact.fact_id] = fact
        return
    existing.source = _str_list(existing.source + fact.source)
    existing.source_facts = _str_list(existing.source_facts + fact.source_facts)
    existing.categories = _str_list(existing.categories + fact.categories)
    existing.risk_tags = _str_list(existing.risk_tags + fact.risk_tags)
    existing.confidence = max(existing.confidence, fact.confidence)


def extract_facts_from_uir_targets(
    uir_targets: Optional[Dict[str, Any]],
    *,
    contract: str,
) -> List[SemanticFact]:
    if not isinstance(uir_targets, dict):
        return []
    functions = uir_targets.get("functions_by_selector") or {}
    if not isinstance(functions, dict):
        return []

    facts: Dict[str, SemanticFact] = {}
    for raw_selector, item in functions.items():
        if not isinstance(item, dict):
            continue
        selector = str(item.get("selector") or raw_selector)
        fn_name = item.get("name")
        signature = item.get("signature")
        reads = item.get("reads") or []
        writes = item.get("writes") or []
        categories = _str_list(item.get("categories"))
        risk_tags = _str_list(item.get("risk_tags"))
        source_facts = _str_list(item.get("source_facts"))
        guards = item.get("guards") or []
        transitions = item.get("transition_facts") or []
        storage = _str_list(list(reads) + list(writes))

        _add_fact(facts, SemanticFact.build(
            kind="function_effect_fact",
            contract=contract,
            source=["uir_targets"],
            confidence=0.7,
            function=str(fn_name) if fn_name else None,
            selector=selector,
            signature=str(signature) if signature else None,
            storage=storage,
            reads=reads,
            writes=writes,
            categories=categories,
            risk_tags=risk_tags,
            source_facts=source_facts,
            detail={
                "stateMutability": item.get("stateMutability"),
                "visibility": item.get("visibility"),
                "kind": item.get("kind"),
            },
        ))

        if "accounting" in categories or "accounting_relation" in risk_tags:
            _add_fact(facts, SemanticFact.build(
                kind="accounting_fact",
                contract=contract,
                source=["uir_targets"],
                confidence=0.75,
                function=str(fn_name) if fn_name else None,
                selector=selector,
                signature=str(signature) if signature else None,
                storage=storage,
                reads=reads,
                writes=writes,
                categories=categories,
                risk_tags=risk_tags,
                source_facts=source_facts,
                detail={"reason": "uir accounting category or accounting_relation risk tag"},
                identity=["accounting_fact", contract, selector, fn_name, storage],
            ))

        if "accounting_anomaly" in categories or "accounting_anomaly" in risk_tags:
            _add_fact(facts, SemanticFact.build(
                kind="accounting_anomaly_fact",
                contract=contract,
                source=["uir_targets"],
                confidence=0.8,
                function=str(fn_name) if fn_name else None,
                selector=selector,
                signature=str(signature) if signature else None,
                storage=storage,
                reads=reads,
                writes=writes,
                categories=categories,
                risk_tags=risk_tags,
                source_facts=source_facts,
                detail={"reason": "uir accounting_anomaly category"},
                identity=["accounting_anomaly_fact", contract, selector, fn_name, storage],
            ))

        if guards or "access_guarded" in categories or "guarded_sensitive" in risk_tags:
            _add_fact(facts, SemanticFact.build(
                kind="access_fact",
                contract=contract,
                source=["uir_targets"],
                confidence=0.75,
                function=str(fn_name) if fn_name else None,
                selector=selector,
                signature=str(signature) if signature else None,
                storage=storage,
                reads=reads,
                writes=writes,
                categories=categories,
                risk_tags=risk_tags,
                source_facts=source_facts,
                detail={"guards": _jsonable(guards)},
                identity=["access_fact", contract, selector, fn_name, guards],
            ))

        if "sensitive" in categories or "sensitive_function" in risk_tags:
            _add_fact(facts, SemanticFact.build(
                kind="sensitive_function_fact",
                contract=contract,
                source=["uir_targets"],
                confidence=0.7,
                function=str(fn_name) if fn_name else None,
                selector=selector,
                signature=str(signature) if signature else None,
                storage=storage,
                reads=reads,
                writes=writes,
                categories=categories,
                risk_tags=risk_tags,
                source_facts=source_facts,
                detail={"reason": "sensitive category or risk tag"},
                identity=["sensitive_function_fact", contract, selector, fn_name],
            ))

        if transitions or "state_transition" in categories:
            for idx, transition in enumerate(transitions or [{}]):
                state_var = transition.get("state_var") if isinstance(transition, dict) else None
                _add_fact(facts, SemanticFact.build(
                    kind="state_transition_fact",
                    contract=contract,
                    source=["uir_targets"],
                    confidence=0.8 if transition else 0.7,
                    function=str(fn_name) if fn_name else None,
                    selector=selector,
                    signature=str(signature) if signature else None,
                    storage=[state_var] if state_var else storage,
                    reads=reads,
                    writes=writes,
                    categories=categories,
                    risk_tags=risk_tags,
                    source_facts=source_facts,
                    detail={"transition": _jsonable(transition), "transition_index": idx},
                    identity=["state_transition_fact", contract, selector, fn_name, idx, transition],
                ))

        if item.get("stateMutability") == "payable" or fn_name in ("__receive__", "receive"):
            _add_fact(facts, SemanticFact.build(
                kind="external_interaction_fact",
                contract=contract,
                source=["uir_targets"],
                confidence=0.65,
                function=str(fn_name) if fn_name else None,
                selector=selector,
                signature=str(signature) if signature else None,
                storage=storage,
                reads=reads,
                writes=writes,
                categories=categories,
                risk_tags=risk_tags,
                source_facts=source_facts,
                detail={"reason": "payable or receive function"},
                identity=["external_interaction_fact", contract, selector, fn_name],
            ))

    return sorted(facts.values(), key=lambda f: (f.kind, f.function or "", f.fact_id))


def extract_facts_from_analysis(
    analysis: Optional[Dict[str, Any]],
    *,
    contract: str,
    uir_targets: Optional[Dict[str, Any]] = None,
) -> List[SemanticFact]:
    if not isinstance(analysis, dict):
        return []

    facts: Dict[str, SemanticFact] = {}
    storage = analysis.get("storage") or {}
    if isinstance(storage, dict):
        for name, meta in storage.items():
            if not isinstance(meta, dict):
                meta = {"value": meta}
            _add_fact(facts, SemanticFact.build(
                kind="storage_fact",
                contract=contract,
                source=["analysis"],
                confidence=0.8,
                storage=[name],
                categories=[
                    "mapping" if meta.get("is_mapping") else "",
                    "uint" if meta.get("is_uint") else "",
                    "address" if meta.get("is_address") else "",
                    "enum" if meta.get("is_enum") else "",
                ],
                detail=meta,
                identity=["storage_fact", contract, name, meta.get("slot"), meta.get("offset"), meta.get("type")],
            ))

    dfg = analysis.get("dfg") or {}
    if isinstance(dfg, dict):
        for fn_name, item in dfg.items():
            if not isinstance(item, dict):
                continue
            reads = item.get("reads") or []
            writes = item.get("writes") or []
            selector = _selector_for_function(uir_targets, fn_name)
            _add_fact(facts, SemanticFact.build(
                kind="function_effect_fact",
                contract=contract,
                source=["analysis"],
                confidence=0.7,
                function=str(fn_name),
                selector=selector,
                storage=_str_list(list(reads) + list(writes)),
                reads=reads,
                writes=writes,
                categories=["dfg"],
                detail={"dfg": _jsonable(item)},
                identity=["function_effect_fact", contract, fn_name, selector, reads, writes],
            ))

    for idx, item in enumerate(analysis.get("accounting") or []):
        if not isinstance(item, dict):
            continue
        fn_name = item.get("via_function") or item.get("function")
        mapping = item.get("mapping")
        supply = item.get("supply")
        _add_fact(facts, SemanticFact.build(
            kind="accounting_fact",
            contract=contract,
            source=["analysis"],
            confidence=0.85,
            function=str(fn_name) if fn_name else None,
            selector=_selector_for_function(uir_targets, fn_name),
            storage=[mapping, supply],
            categories=["accounting"],
            source_facts=["accounting"],
            detail=item,
            identity=["accounting_fact", contract, idx, mapping, supply, fn_name],
        ))

    for idx, item in enumerate(analysis.get("accounting_anomalies") or []):
        if not isinstance(item, dict):
            continue
        fn_name = item.get("function")
        mapping = item.get("mapping")
        supply = item.get("supply")
        _add_fact(facts, SemanticFact.build(
            kind="accounting_anomaly_fact",
            contract=contract,
            source=["analysis"],
            confidence=0.85,
            function=str(fn_name) if fn_name else None,
            selector=_selector_for_function(uir_targets, fn_name),
            storage=[mapping, supply],
            categories=["accounting_anomaly"],
            source_facts=["accounting_anomalies"],
            detail=item,
            identity=["accounting_anomaly_fact", contract, idx, mapping, supply, fn_name, item.get("reason")],
        ))

    state_machine = analysis.get("state_machine") or {}
    if isinstance(state_machine, dict):
        states = _str_list(state_machine.get("states"))
        details = state_machine.get("details") or {}
        for state_var in states:
            detail = details.get(state_var) if isinstance(details, dict) else {}
            _add_fact(facts, SemanticFact.build(
                kind="state_variable_fact",
                contract=contract,
                source=["analysis"],
                confidence=0.75,
                storage=[state_var],
                categories=["state_machine"],
                source_facts=["state_machine"],
                detail=detail if isinstance(detail, dict) else {"detail": detail},
                identity=["state_variable_fact", contract, state_var],
            ))
            if isinstance(detail, dict) and detail.get("terminal_candidates"):
                _add_fact(facts, SemanticFact.build(
                    kind="terminal_state_fact",
                    contract=contract,
                    source=["analysis"],
                    confidence=0.75,
                    storage=[state_var],
                    categories=["state_machine", "terminal_state"],
                    source_facts=["state_machine"],
                    detail={"terminal_candidates": _jsonable(detail.get("terminal_candidates"))},
                    identity=["terminal_state_fact", contract, state_var, detail.get("terminal_candidates")],
                ))

    transition_facts = []
    if isinstance(state_machine, dict):
        transition_facts.extend(_list(state_machine.get("transition_facts")))
    transition_facts.extend(_list(analysis.get("transition_facts")))
    seen_transition_keys = set()
    for idx, item in enumerate(transition_facts):
        if not isinstance(item, dict):
            continue
        key = json.dumps(_jsonable(item), sort_keys=True, ensure_ascii=True)
        if key in seen_transition_keys:
            continue
        seen_transition_keys.add(key)
        fn_name = item.get("function") or item.get("via_function")
        state_var = item.get("state_var")
        _add_fact(facts, SemanticFact.build(
            kind="state_transition_fact",
            contract=contract,
            source=["analysis"],
            confidence=0.82,
            function=str(fn_name) if fn_name else None,
            selector=_selector_for_function(uir_targets, fn_name),
            storage=[state_var],
            categories=["state_transition"],
            source_facts=["transition_facts"],
            detail=item,
            identity=["state_transition_fact", contract, idx, item],
        ))

    for idx, item in enumerate(analysis.get("access") or []):
        if not isinstance(item, dict):
            continue
        fn_name = item.get("name") or item.get("function")
        _add_fact(facts, SemanticFact.build(
            kind="access_fact",
            contract=contract,
            source=["analysis"],
            confidence=0.82,
            function=str(fn_name) if fn_name else None,
            selector=_selector_for_function(uir_targets, fn_name),
            signature=item.get("signature"),
            categories=["access_guarded"],
            source_facts=["access"],
            detail=item,
            identity=["access_fact", contract, idx, fn_name, item.get("signature")],
        ))

    for idx, item in enumerate(analysis.get("cross_relations") or []):
        if not isinstance(item, dict):
            continue
        from_fn = item.get("from") or item.get("from_function")
        to_fn = item.get("to") or item.get("to_function")
        related_storage = _str_list(item.get("storage") or item.get("vars") or item.get("variables"))
        _add_fact(facts, SemanticFact.build(
            kind="cross_function_relation_fact",
            contract=contract,
            source=["analysis"],
            confidence=0.75,
            function=str(from_fn) if from_fn else None,
            selector=_selector_for_function(uir_targets, from_fn),
            storage=related_storage,
            categories=["cross_relation", str(item.get("type") or item.get("kind") or "")],
            source_facts=["cross_relations"],
            detail={
                "from": from_fn,
                "to": to_fn,
                "from_selector": _selector_for_function(uir_targets, from_fn),
                "to_selector": _selector_for_function(uir_targets, to_fn),
                "raw": _jsonable(item),
            },
            identity=["cross_function_relation_fact", contract, idx, from_fn, to_fn, item],
        ))

    return sorted(facts.values(), key=lambda f: (f.kind, f.function or "", f.fact_id))


def collect_semantic_facts_from_meta_dir(meta_dir: Path) -> List[SemanticFact]:
    meta_dir = Path(meta_dir)
    invariant_dir = meta_dir / "invariant_test"
    analysis = _read_json(invariant_dir / "analysis.json")
    uir_targets = _read_json(invariant_dir / "uir_targets.json")
    contract = _contract_name_from_meta_dir(meta_dir, analysis if isinstance(analysis, dict) else None)

    facts: Dict[str, SemanticFact] = {}
    for fact in extract_facts_from_uir_targets(uir_targets, contract=contract):
        _add_fact(facts, fact)
    for fact in extract_facts_from_analysis(analysis, contract=contract, uir_targets=uir_targets):
        _add_fact(facts, fact)
    return sorted(facts.values(), key=lambda f: (f.contract, f.kind, f.function or "", f.fact_id))


def facts_to_jsonable(facts: Iterable[SemanticFact]) -> List[Dict[str, Any]]:
    return [fact.to_dict() for fact in facts]
