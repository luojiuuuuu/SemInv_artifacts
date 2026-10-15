#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from random import random, shuffle
from itertools import accumulate
from bisect import bisect_right
import math

from ...plugin_interfaces.operators.selection import Selection


class CoveragePreservingUIRSelection(Selection):
    """
    Linear ranking selection with coverage-first, UIR-semantic tie breaking.

    This operator is intentionally conservative: the existing fitness value
    remains the primary ranking signal. UIR profiles only reorder individuals
    inside the same coverage bucket, so semantic guidance can be enabled and
    disabled without changing the rest of the engine pipeline.
    """

    def __init__(self, env, pmin=0.1, pmax=0.9, coverage_slack=0.0,
                 random_rate=0.05, data_dependency=False, plateau_generations=2):
        self.env = env
        self.pmin, self.pmax = pmin, pmax
        self.coverage_slack = coverage_slack if coverage_slack and coverage_slack > 0 else 0.0
        self.random_rate = min(max(random_rate or 0.0, 0.0), 1.0)
        self.data_dependency = bool(data_dependency)
        self.plateau_generations = max(int(plateau_generations or 0), 0)

    def select(self, population, fitness):
        indvs = population.individuals
        if len(indvs) < 2:
            return indvs[0], indvs[0]

        ranked = self._rank_individuals(population, fitness)

        if self.random_rate and random() < self.random_rate:
            father_idx = int(random() * len(ranked))
        else:
            father_idx = self._ranked_wheel_index(len(ranked))

        father = ranked[father_idx]["individual"]

        if self.data_dependency:
            mother = self._select_data_dependency_mother(father, ranked)
            if mother is not None:
                return father, mother

        mother_idx = (father_idx + 1) % len(ranked)
        return father, ranked[mother_idx]["individual"]

    def _rank_individuals(self, population, fitness):
        all_fits = population.all_fits(fitness)
        ranked = []
        for idx, indv in enumerate(population.individuals):
            fit = all_fits[idx]
            semantic_score = self._semantic_score(indv) if self._uir_gate_open() else 0.0
            ranked.append({
                "individual": indv,
                "fitness": fit,
                "coverage_bucket": self._coverage_bucket(fit),
                "semantic_score": semantic_score,
                "efficiency_score": self._efficiency_score(indv),
            })

        ranked.sort(key=lambda item: (
            item["coverage_bucket"],
            item["semantic_score"],
            item["efficiency_score"],
            item["fitness"],
        ))

        try:
            self.env.uir_selection_last_rank = [
                {
                    "hash": item["individual"].hash,
                    "fitness": item["fitness"],
                    "coverage_bucket": item["coverage_bucket"],
                    "semantic_score": item["semantic_score"],
                    "efficiency_score": item["efficiency_score"],
                    "uir_gate_open": self._uir_gate_open(),
                }
                for item in ranked
            ]
        except Exception:
            pass

        return ranked

    def _uir_gate_open(self):
        if self.plateau_generations <= 0:
            return True
        return int(getattr(self.env, "coverage_plateau_generations", 0) or 0) >= self.plateau_generations

    def _coverage_bucket(self, fit):
        try:
            value = float(fit)
        except Exception:
            value = 0.0
        if self.coverage_slack <= 0:
            return value
        return math.floor(value / self.coverage_slack)

    def _ranked_wheel_index(self, size):
        if size <= 1:
            return 0
        p = lambda i: (self.pmin + (self.pmax - self.pmin) * (i - 1) / (size - 1))
        probabilities = [self.pmin] + [p(i) for i in range(2, size)] + [self.pmax]
        psum = sum(probabilities)
        wheel = list(accumulate([prob / psum for prob in probabilities]))
        idx = bisect_right(wheel, random())
        return min(idx, size - 1)

    def _semantic_score(self, indv):
        profiles = getattr(self.env, "uir_seed_profiles", {}) or {}
        profile = profiles.get(indv.hash) or {}
        if not profile:
            return 0.0

        def n(key):
            value = profile.get(key, [])
            return len(value) if isinstance(value, list) else 0

        saturation = self._uir_saturation()
        score = 0.0

        # Reward semantic facts mostly while their global target classes are
        # still unsaturated. Once a UIR class is fully covered, repeatedly
        # calling the same high-risk functions should not dominate selection.
        score += 1.0 * (1.0 - saturation.get("sensitive_functions", 1.0)) * n("touched_sensitive_functions")
        score += 2.0 * (1.0 - saturation.get("access_anomalies", 1.0)) * n("touched_access_anomalies")
        score += 2.0 * (1.0 - saturation.get("accounting_anomalies", 1.0)) * n("touched_accounting_anomalies")
        score += 1.0 * (1.0 - saturation.get("state_transition_functions", 1.0)) * n("touched_state_transitions")
        score += 1.0 * (1.0 - saturation.get("write_read_relations", 1.0)) * n("matched_relations")

        # Keep a small positive signal for touching storage, but avoid making
        # broad guarded paths attractive once they mostly revert.
        score += 0.10 * n("read_storage_vars")
        score += 0.10 * n("written_storage_vars")

        new_coverage = (
            float(profile.get("new_code_coverage") or 0) > 0
            or float(profile.get("new_branch_coverage") or 0) > 0
        )
        if new_coverage and float(profile.get("reverted_transactions") or 0) > 0:
            score += 3.0 * float(profile.get("new_branch_coverage") or 0)
            score += 1.0 * float(profile.get("new_code_coverage") or 0)
        else:
            score -= 4.0 * float(profile.get("invalid_transactions") or 0)
            score -= 3.0 * float(profile.get("guard_failures") or 0)
            score -= 2.0 * float(profile.get("reverted_transactions") or 0)
        score -= 0.10 * float(profile.get("sequence_length") or 0)
        return score

    def _efficiency_score(self, indv):
        profiles = getattr(self.env, "uir_seed_profiles", {}) or {}
        profile = profiles.get(indv.hash) or {}
        if not profile:
            return 0.0
        length = float(profile.get("sequence_length") or len(getattr(indv, "chromosome", []) or []) or 1)
        calls = len(profile.get("called_selectors", []) or [])
        invalid = float(profile.get("invalid_transactions") or 0)
        reverted = float(profile.get("reverted_transactions") or 0)
        guard_failures = float(profile.get("guard_failures") or 0)
        if (
            (float(profile.get("new_code_coverage") or 0) > 0
             or float(profile.get("new_branch_coverage") or 0) > 0)
            and reverted > 0
        ):
            reverted = 0
            guard_failures = 0
        return (calls - invalid - reverted - guard_failures) / max(length, 1.0)

    def _uir_saturation(self):
        cov = getattr(self.env, "uir_coverage", {}) or {}
        targets = getattr(self.env, "uir_targets", {}) or {}
        goals = targets.get("coverage_goals", {}) if isinstance(targets, dict) else {}

        mapping = {
            "sensitive_functions": "sensitive_selectors",
            "access_anomalies": "access_anomaly_selectors",
            "accounting_anomalies": "accounting_anomaly_selectors",
            "state_transition_functions": "state_transition_selectors",
            "write_read_relations": "write_read_relations",
        }
        out = {}
        for goal_key, cov_key in mapping.items():
            total = goals.get(goal_key) or 0
            if not total:
                out[goal_key] = 1.0
                continue
            covered = cov.get(cov_key, set())
            try:
                out[goal_key] = min(len(covered) / float(total), 1.0)
            except Exception:
                out[goal_key] = 1.0
        return out

    def _select_data_dependency_mother(self, father, ranked):
        father_reads, father_writes = self.extract_reads_and_writes(father, self.env)
        try:
            father_args = [gene["arguments"][0] for gene in father.chromosome]
        except Exception:
            father_args = []

        candidates = [item["individual"] for item in ranked]
        shuffle(candidates)
        candidates.sort(key=lambda indv: self._semantic_score(indv), reverse=True)

        for indv in candidates:
            if indv is father:
                continue
            try:
                args = [gene["arguments"][0] for gene in indv.chromosome]
            except Exception:
                args = []
            if father_args == args:
                continue
            reads, writes = self.extract_reads_and_writes(indv, self.env)
            if not reads.isdisjoint(father_writes) or not father_reads.isdisjoint(writes):
                return indv
        return None

    @staticmethod
    def extract_reads_and_writes(individual, env):
        reads, writes = set(), set()
        for tx in getattr(individual, "chromosome", []) or []:
            try:
                function_hash = tx["arguments"][0]
            except Exception:
                continue
            if function_hash in getattr(env, "data_dependencies", {}):
                reads.update(env.data_dependencies[function_hash]["read"])
                writes.update(env.data_dependencies[function_hash]["write"])
        return reads, writes
