#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import hashlib
import re


def _normalize_selector(selector):
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


def _stable_negative_pc(*parts):
    raw = "|".join(str(p) for p in parts if p is not None)
    digest = hashlib.sha256(raw.encode("utf-8")).hexdigest()
    return -900000 - (int(digest[:8], 16) % 900000)


class L4SemanticDetector:
    """
    Transaction-level semantic detector supplement backed by UIR targets.

    L3 turns UIR facts into Foundry assertions. L4 reuses the same facts as a
    dynamic fuzzer detector layer, so successful fuzzed transactions can emit
    normalized findings even when no Foundry invariant is being run.
    """

    def __init__(self, uir_targets=None):
        self.uir_targets = uir_targets or {}
        self.init()

    def init(self):
        self.swc_id = "L4"
        self.severity = "Medium"
        self.reported = set()
        self.terminal_seen = {}
        self.tx_origin_seen = set()
        self.functions_by_selector = {}
        self.relation_targets = []
        self.invariant_targets = []

        targets = self.uir_targets or {}
        for selector, info in (targets.get("functions_by_selector") or {}).items():
            norm = _normalize_selector(selector)
            if norm:
                item = dict(info or {})
                item["selector"] = norm
                self.functions_by_selector[norm] = item
        self.relation_targets = list(targets.get("relation_targets") or [])
        self.invariant_targets = list(targets.get("invariant_targets") or [])

    def configure(self, uir_targets):
        self.uir_targets = uir_targets or {}
        self.init()

    def enabled(self):
        return bool(self.functions_by_selector or self.invariant_targets)

    @staticmethod
    def _function_name(info, selector):
        return (info or {}).get("name") or (info or {}).get("signature") or selector

    def _terminal_values_by_state(self):
        out = {}
        for target in self.invariant_targets:
            if not isinstance(target, dict) or target.get("type") != "state_machine":
                continue
            state_var = target.get("state_var")
            terminals = target.get("terminal_candidates") or []
            if state_var and terminals:
                out.setdefault(state_var, set()).update(str(v) for v in terminals)
        return out

    def _emit(self, kind, selector, info, transaction_index, detail):
        key = (kind, selector, str(detail.get("state_var") or detail.get("function") or ""))
        if key in self.reported:
            return None
        self.reported.add(key)

        family_map = {
            "l4_accounting_delta": ("l4_fuzzer_detector", "accounting_delta"),
            "l4_access_noninterference": ("l4_fuzzer_detector", "access_noninterference"),
            "l4_terminal_rollback": ("l4_fuzzer_detector", "terminal_rollback"),
            "l4_tx_origin_boundary": ("l4_fuzzer_detector", "tx_origin_boundary"),
            "l4_short_calldata_integrity": ("l4_fuzzer_detector", "short_calldata_integrity"),
            "l4_unsafe_delegatecall": ("l4_fuzzer_detector", "unsafe_delegatecall"),
            "l4_numeric_integrity": ("l4_fuzzer_detector", "numeric_integrity"),
            "l4_preimage_front_running": ("l4_fuzzer_detector", "order_independence"),
            "l4_cross_function_cei": ("l4_fuzzer_detector", "reentrancy"),
            "l4_call_return_consistency": ("l4_fuzzer_detector", "unchecked_return_value"),
        }
        family, invariant_kind = family_map.get(kind, ("l4_fuzzer_detector", kind))
        function_name = self._function_name(info, selector)
        classification = {
            "family": family,
            "kind": invariant_kind,
            "summary": detail.get("summary") or ("L4 semantic detector supplement: %s" % invariant_kind),
            "invariant_id": detail.get("invariant_id"),
            "evidence_subtype": detail.get("evidence_subtype"),
            "evidence_strength": detail.get("evidence_strength"),
        }
        trigger_detail = {
            "l4": True,
            "selector": selector,
            "function": function_name,
            "classification": classification,
            "targets": detail,
            "uir_categories": list((info or {}).get("categories") or []),
            "uir_risk_tags": list((info or {}).get("risk_tags") or []),
        }
        pc = _stable_negative_pc(kind, selector, detail.get("state_var"), detail.get("invariant_id"))
        return pc, transaction_index, kind, trigger_detail

    @staticmethod
    def _signature_arity(signature):
        if not signature or "(" not in str(signature) or ")" not in str(signature):
            return 0
        inside = str(signature).split("(", 1)[1].rsplit(")", 1)[0].strip()
        if not inside:
            return 0
        depth = 0
        count = 1
        for ch in inside:
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth = max(0, depth - 1)
            elif ch == "," and depth == 0:
                count += 1
        return count

    def detect_instruction(self, current_instruction, transaction_index, selector):
        if not self.enabled() or not current_instruction:
            return []
        selector = _normalize_selector(selector)
        info = self.functions_by_selector.get(selector, {})
        op = current_instruction.get("op")
        if op == "DELEGATECALL":
            finding = self._emit(
                "l4_unsafe_delegatecall",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "opcode": op,
                    "invariant_id": "I2.authorization.access_noninterference",
                    "summary": "A user-reachable delegatecall was observed and preserved as an access-control target event",
                },
            )
            return [finding] if finding else []
        if op == "ORIGIN":
            self.tx_origin_seen.add(transaction_index)
            return []
        if transaction_index not in self.tx_origin_seen:
            return []
        if op not in ("SSTORE", "CALL", "DELEGATECALL", "SELFDESTRUCT", "SUICIDE"):
            return []
        categories = set(info.get("categories") or [])
        risk_tags = set(info.get("risk_tags") or [])
        sensitive = (
            bool(categories & {"sensitive", "access_guarded", "access_anomaly"})
            or bool(risk_tags & {"sensitive_function", "guarded_sensitive", "unguarded_sensitive"})
            or op in ("SELFDESTRUCT", "SUICIDE", "DELEGATECALL")
        )
        if not sensitive:
            return []
        finding = self._emit(
            "l4_tx_origin_boundary",
            selector,
            info,
            transaction_index,
            {
                "function": self._function_name(info, selector),
                "opcode": op,
                "invariant_id": "I2.authorization.tx_origin_boundary",
                "summary": "tx.origin was observed before a sensitive effect in the same transaction",
            },
        )
        return [finding] if finding else []

    def detect_after_transaction(self, individual, transaction_index, selector, transaction, result_is_error=False):
        if not self.enabled():
            return []

        selector = _normalize_selector(selector)
        info = self.functions_by_selector.get(selector)
        findings = []
        if not info:
            return findings

        categories = set(info.get("categories") or [])
        risk_tags = set(info.get("risk_tags") or [])
        function_name = str(self._function_name(info, selector) or "").lower()
        signature = str(info.get("signature") or "").lower()
        reads = {str(x) for x in (info.get("reads") or [])}
        writes = {str(x) for x in (info.get("writes") or [])}
        guards = [
            str((guard or {}).get("evidence") or "").lower()
            for guard in (info.get("guards") or [])
            if isinstance(guard, dict)
        ]
        guard_text = " ".join(guards)

        preimage_like = (
            "hash" in {x.lower() for x in reads}
            and any(token in function_name for token in ("solve", "claim", "submit", "find"))
            and any(token in signature for token in ("string", "bytes"))
        )
        if preimage_like:
            finding = self._emit(
                "l4_preimage_front_running",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "reads": sorted(reads),
                    "invariant_id": "I4.transaction.order_independence",
                    "summary": "Public hash-preimage submission can be copied in the mempool without a commit-reveal phase",
                },
            )
            if finding:
                findings.append(finding)

        tx_origin_guard_like = "tx.origin" in guard_text and any(token in guard_text for token in ("owner", "creator", "admin"))
        if tx_origin_guard_like:
            finding = self._emit(
                "l4_tx_origin_boundary",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "guards": guards,
                    "invariant_id": "I2.authorization.tx_origin_boundary",
                    "summary": "tx.origin is used as an owner-like authorization predicate",
                },
            )
            if finding:
                findings.append(finding)

        owner_initializer_like = (
            bool({x.lower() for x in writes} & {"owner", "creator", "admin"})
            and not guards
            and (
                "access_anomaly" in categories
                or "unguarded_sensitive" in risk_tags
                or "sensitive_function" in risk_tags
                or any(token in function_name for token in ("init", "constructor", "missing"))
            )
        )
        if owner_initializer_like:
            finding = self._emit(
                "l4_access_noninterference",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "writes": sorted(writes),
                    "invariant_id": "I2.authorization.access_noninterference",
                    "summary": "Public execution writes an owner-like authorization variable without a guard",
                },
            )
            if finding:
                findings.append(finding)

        wrong_withdraw_guard_like = (
            "withdraw" in function_name
            and "amount" in guard_text
            and ">=" in guard_text
            and "balance" in guard_text
        )
        if wrong_withdraw_guard_like:
            finding = self._emit(
                "l4_access_noninterference",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "guards": guards,
                    "invariant_id": "I2.authorization.access_noninterference",
                    "summary": "Withdrawal guard permits requested amount greater than or equal to the caller balance",
                },
            )
            if finding:
                findings.append(finding)

        refund_missing_commit_like = (
            "refund" in function_name
            and any("balance" in x.lower() for x in reads)
            and not any("balance" in x.lower() for x in writes)
        )
        if refund_missing_commit_like:
            finding = self._emit(
                "l4_access_noninterference",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "reads": sorted(reads),
                    "writes": sorted(writes),
                    "invariant_id": "I2.authorization.access_noninterference",
                    "summary": "Refund-like function transfers balance without committing the caller balance state",
                },
            )
            if finding:
                findings.append(finding)

        call_value_guard_like = ".call.value" in guard_text and any(token in function_name for token in ("collect", "withdraw", "cashout"))
        if call_value_guard_like:
            finding = self._emit(
                "l4_cross_function_cei",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "guards": guards,
                    "reads": sorted(reads),
                    "writes": sorted(writes),
                    "invariant_id": "I6.external.cei_reentrancy",
                    "summary": "External value call appears in the withdrawal guard before related account state is committed",
                },
            )
            if finding:
                findings.append(finding)

        if result_is_error:
            return findings

        data = str((transaction or {}).get("data") or "")
        data_hex = data[2:] if data.startswith("0x") else data
        if selector not in ("fallback", "receive", "constructor"):
            expected_nibbles = 8 + self._signature_arity(info.get("signature")) * 64
            effectful_for_short_calldata = (
                bool(
                    categories
                    & {
                        "state_update",
                        "sensitive",
                        "access_guarded",
                        "access_anomaly",
                        "accounting_anomaly",
                        "accounting",
                        "state_transition",
                    }
                )
                or bool(
                    risk_tags
                    & {
                        "sensitive_function",
                        "guarded_sensitive",
                        "unguarded_sensitive",
                        "accounting_anomaly",
                    }
                )
            )
            if expected_nibbles > 8 and len(data_hex) < expected_nibbles and effectful_for_short_calldata:
                finding = self._emit(
                    "l4_short_calldata_integrity",
                    selector,
                    info,
                    transaction_index,
                    {
                        "function": self._function_name(info, selector),
                        "signature": info.get("signature"),
                        "actual_calldata_nibbles": len(data_hex),
                        "expected_min_calldata_nibbles": expected_nibbles,
                        "invariant_id": "I6.external.short_calldata_integrity",
                        "summary": "Short or malformed calldata unexpectedly completed successfully",
                    },
                )
                if finding:
                    findings.append(finding)

        if "accounting_anomaly" in categories or "accounting_anomaly" in risk_tags:
            finding = self._emit(
                "l4_accounting_delta",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "invariant_id": "I1.accounting.delta_consistency",
                    "summary": "Successful execution of a function statically marked as accounting-anomalous",
                },
            )
            if finding:
                findings.append(finding)

        if "access_anomaly" in categories or "unguarded_sensitive" in risk_tags:
            finding = self._emit(
                "l4_access_noninterference",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "invariant_id": "I2.authorization.access_noninterference",
                    "summary": "Successful execution of an unguarded sensitive function",
                },
            )
            if finding:
                findings.append(finding)

        shared_state = {x.lower() for x in (reads & writes)}
        numeric_like = (
            shared_state
            and any(token in signature for token in ("uint", "int"))
            and (
                any(token in function_name for token in ("run", "add", "mul", "sub", "deposit", "transfer"))
                or any(token in name for name in shared_state for token in ("count", "balance", "amount", "supply", "total"))
            )
        )
        if numeric_like:
            finding = self._emit(
                "l4_numeric_integrity",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "shared_state": sorted(shared_state),
                    "invariant_id": "I5.execution.numeric_integrity",
                    "evidence_subtype": "uir_numeric_state_read_write",
                    "evidence_strength": "candidate",
                    "summary": "Successful unsigned numeric state update matched a UIR arithmetic-risk pattern",
                },
            )
            if finding:
                findings.append(finding)

        cross_function_cei_like = (
            any("claim" in x.lower() or "bonus" in x.lower() for x in (reads | writes))
            and bool(shared_state or writes)
            and any(
                isinstance(rel, dict)
                and _normalize_selector(rel.get("from_selector")) == selector
                and any(token in str(rel.get("to_function") or "").lower() for token in ("withdraw", "send", "transfer"))
                for rel in self.relation_targets
            )
        )
        if cross_function_cei_like:
            finding = self._emit(
                "l4_cross_function_cei",
                selector,
                info,
                transaction_index,
                {
                    "function": self._function_name(info, selector),
                    "reads": sorted(reads),
                    "writes": sorted(writes),
                    "invariant_id": "I6.external.cei_reentrancy",
                    "summary": "Cross-function call chain updates bonus/claim state after an externally interacting withdrawal path",
                },
            )
            if finding:
                findings.append(finding)

        terminal_values = self._terminal_values_by_state()
        for fact in info.get("transition_facts") or []:
            if not isinstance(fact, dict):
                continue
            state_var = fact.get("state_var")
            if not state_var:
                continue
            terminal_set = terminal_values.get(state_var) or set()
            to_value = str(fact.get("to"))
            transition_kind = str(fact.get("transition_kind") or fact.get("op") or "")

            if to_value in terminal_set:
                self.terminal_seen[state_var] = {
                    "selector": selector,
                    "function": self._function_name(info, selector),
                    "to": to_value,
                    "tx_index": transaction_index,
                }
                continue

            prior = self.terminal_seen.get(state_var)
            if not prior:
                continue
            rollbackish = (
                to_value not in ("", "None", "null")
                or "reset" in transition_kind.lower()
                or "dec" in transition_kind.lower()
                or "sub" in transition_kind.lower()
            )
            if rollbackish:
                finding = self._emit(
                    "l4_terminal_rollback",
                    selector,
                    info,
                    transaction_index,
                    {
                        "state_var": state_var,
                        "from_terminal": prior,
                        "function": self._function_name(info, selector),
                        "to": fact.get("to"),
                        "transition_kind": transition_kind,
                        "invariant_id": "I3.state.terminal_absorbing",
                        "summary": "Successful transition after a terminal state was reached in the same sequence",
                    },
                )
                if finding:
                    findings.append(finding)

        return findings
