#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Semantic invariant specifications shared by Foundry and fuzzing backends."""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from typing import Any, Dict, Iterable, List, Optional


INVARIANT_SPEC_SCHEMA_VERSION = "con-fuzzius.invariant_spec.v1"

INVARIANT_CATEGORIES = [
    "I1_FINANCIAL_ACCOUNTING",
    "I2_AUTHORIZATION_ACCESS",
    "I3_PROTOCOL_STATE_MACHINE",
    "I4_TRANSACTIONAL_CONSISTENCY",
    "I5_RESOURCE_EXECUTION",
    "I6_EXTERNAL_ENVIRONMENT",
]

BACKENDS = ["foundry", "fuzz", "hybrid"]


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


@dataclass(frozen=True)
class InvariantSpec:
    invariant_id: str
    category: str
    name: str
    description: str
    backends: List[str]
    required_fact_kinds: List[str] = field(default_factory=list)
    match_mode: str = "any"
    template_name: Optional[str] = None
    detector_names: List[str] = field(default_factory=list)
    foundry_families: List[str] = field(default_factory=list)
    violated_property: str = ""
    swc_ids: List[str] = field(default_factory=list)
    severity: str = "medium"
    default_confidence: float = 0.5
    evidence_floor: str = "pattern-only"
    tags: List[str] = field(default_factory=list)
    schema_version: str = INVARIANT_SPEC_SCHEMA_VERSION

    def __post_init__(self) -> None:
        if self.category not in INVARIANT_CATEGORIES:
            raise ValueError(f"unknown invariant category: {self.category}")
        for backend in self.backends:
            if backend not in BACKENDS:
                raise ValueError(f"unknown backend: {backend}")
        if self.match_mode not in ("any", "all"):
            raise ValueError(f"unsupported match_mode: {self.match_mode}")

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class InvariantMatch:
    match_id: str
    invariant_id: str
    category: str
    contract: str
    fact_ids: List[str]
    functions: List[str] = field(default_factory=list)
    selectors: List[str] = field(default_factory=list)
    storage: List[str] = field(default_factory=list)
    source_fact_kinds: List[str] = field(default_factory=list)
    evidence_sources: List[str] = field(default_factory=list)
    confidence: float = 0.5
    reason: str = ""
    schema_version: str = "con-fuzzius.invariant_match.v1"

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


def stable_match_id(parts: Iterable[Any]) -> str:
    import hashlib

    raw = json.dumps(list(parts), sort_keys=True, ensure_ascii=True, default=str)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()[:24]


def specs_to_jsonable(specs: Iterable[InvariantSpec]) -> List[Dict[str, Any]]:
    return [spec.to_dict() for spec in specs]


def matches_to_jsonable(matches: Iterable[InvariantMatch]) -> List[Dict[str, Any]]:
    return [match.to_dict() for match in matches]
