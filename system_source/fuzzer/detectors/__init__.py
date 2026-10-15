#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import time

from ..utils.utils import print_individual_solution_as_transaction, initialize_logger
from ..reporting import save_detector_finding

from .integer_overflow import IntegerOverflowDetector
from .assertion_failure import AssertionFailureDetector
from .arbitrary_memory_access import ArbitraryMemoryAccessDetector
from .reentrancy import ReentrancyDetector
from .transaction_order_dependency import TransactionOrderDependencyDetector
from .block_dependency import BlockDependencyDetector
from .unchecked_return_value import UncheckedReturnValueDetector
from .unsafe_delegatecall import UnsafeDelegatecallDetector
from .leaking_ether import LeakingEtherDetector
from .locking_ether import LockingEtherDetector
from .unprotected_selfdestruct import UnprotectedSelfdestructDetector

from .new_block_gas_limit_dos import BlockGasLimitDoSDetector
from .new_hashcollision_withmvla import HashCollisionDetector
from .new_unexcepted_ether_balance import UnexpectedEtherBalanceDetector
from .l4_semantic import L4SemanticDetector

class DetectorExecutor:
    def __init__(self, source_map=None, function_signature_mapping={}, uir_targets=None):
        self.source_map = source_map
        self.function_signature_mapping = function_signature_mapping
        self.logger = initialize_logger("SemanticMonitor")
        self.uir_targets = uir_targets or {}

        self.integer_overflow_detector = IntegerOverflowDetector()
        self.assertion_failure_detector = AssertionFailureDetector()
        self.arbitrary_memory_access_detector = ArbitraryMemoryAccessDetector()
        self.reentrancy_detector = ReentrancyDetector()
        self.transaction_order_dependency_detector = TransactionOrderDependencyDetector()
        self.block_dependency_detector = BlockDependencyDetector()
        self.unchecked_return_value_detector = UncheckedReturnValueDetector()
        self.unsafe_delegatecall_detector = UnsafeDelegatecallDetector()
        self.leaking_ether_detector = LeakingEtherDetector()
        self.locking_ether_detector = LockingEtherDetector()
        self.unprotected_selfdestruct_detector = UnprotectedSelfdestructDetector()

        self.block_gas_limit_dos_detector = BlockGasLimitDoSDetector()          # SWC-128
        self.hash_collision_detector = HashCollisionDetector()                  # SWC-133
        self.unexpected_ether_balance_detector = UnexpectedEtherBalanceDetector()  # SWC-132
        self.l4_semantic_detector = L4SemanticDetector(self.uir_targets)


    def initialize_detectors(self):
        self.integer_overflow_detector.init()
        self.assertion_failure_detector.init()
        self.arbitrary_memory_access_detector.init()
        self.reentrancy_detector.init()
        self.transaction_order_dependency_detector.init()
        self.block_dependency_detector.init()
        self.unchecked_return_value_detector.init()
        self.unsafe_delegatecall_detector.init()
        self.leaking_ether_detector.init()
        self.locking_ether_detector.init()
        self.unprotected_selfdestruct_detector.init()

        self.block_gas_limit_dos_detector.init()          # SWC-128
        self.hash_collision_detector.init()               # SWC-133
        self.unexpected_ether_balance_detector.init()     # SWC-132
        self.l4_semantic_detector.configure(self.uir_targets)


    @staticmethod
    def error_exists(errors, type):
        for error in errors:
            if error["type"] == type:
                return True
        return False

    @staticmethod
    def add_error(
        errors,
        pc,
        type,
        individual,
        mfe,
        detector,
        source_map,
        function_signature_mapping=None,
        trigger_tx_index=None,
        trigger_detail=None,
    ):
        error = {
            "swc_id": detector.swc_id,
            "severity": detector.severity,
            "type": type,
            "individual": individual.solution,
            "time": time.time() - mfe.execution_begin,

        }
        if source_map and source_map.get_buggy_line(pc):
            error["line"] = source_map.get_location(pc)['begin']['line'] + 1
            error["column"] = source_map.get_location(pc)['begin']['column'] + 1
            error["source_code"] = source_map.get_buggy_line(pc)
        if not pc in errors:
            errors[pc] = [error]
            if not getattr(getattr(mfe, "args", None), "detector_replay_oracle", False):
                save_detector_finding(
                    error=error,
                    pc=pc,
                    source_map=source_map,
                    function_signature_mapping=function_signature_mapping,
                    contract_name=getattr(mfe, "contract_name", None),
                    trigger_tx_index=trigger_tx_index,
                    trigger_detail=trigger_detail,
                    fuzzing_args=getattr(mfe, "args", None),
                )
            return True
        elif not DetectorExecutor.error_exists(errors[pc], type):
            errors[pc].append(error)
            if not getattr(getattr(mfe, "args", None), "detector_replay_oracle", False):
                save_detector_finding(
                    error=error,
                    pc=pc,
                    source_map=source_map,
                    function_signature_mapping=function_signature_mapping,
                    contract_name=getattr(mfe, "contract_name", None),
                    trigger_tx_index=trigger_tx_index,
                    trigger_detail=trigger_detail,
                    fuzzing_args=getattr(mfe, "args", None),
                )
            return True
        return False

    def record_error(self, errors, pc, type, individual, mfe, detector, trigger_tx_index=None, trigger_detail=None):
        return DetectorExecutor.add_error(
            errors,
            pc,
            type,
            individual,
            mfe,
            detector,
            self.source_map,
            function_signature_mapping=self.function_signature_mapping,
            trigger_tx_index=trigger_tx_index,
            trigger_detail=trigger_detail,
        )

    def get_color_for_severity(severity):
        if severity == "High":
            return "\u001b[31m" # Red
        if severity == "Medium":
            return "\u001b[33m" # Yellow
        if severity == "Low":
            return "\u001b[32m" # Green
        return ""

    def _current_source_line(self, pc):
        if not self.source_map or pc is None:
            return "", ""
        try:
            line = self.source_map.get_buggy_line(pc) or ""
        except Exception:
            line = ""
        try:
            filename = getattr(getattr(self.source_map, "source", None), "filename", "") or ""
        except Exception:
            filename = ""
        return str(line), str(filename)

    def _transaction_selector(self, individual, transaction_index):
        try:
            tx = individual.solution[transaction_index]["transaction"]
            data = str(tx.get("data") or "")
        except Exception:
            return ""
        if data.startswith("0x"):
            return data[:10] if len(data) >= 10 else data
        return "0x" + data[:8] if len(data) >= 8 else ""

    def _record_l4_source_heuristics(self, errors, current_instruction, individual, mfe, transaction_index):
        pc = current_instruction.get("pc") if current_instruction else None
        op = current_instruction.get("op") if current_instruction else None
        source_line, filename = self._current_source_line(pc)
        line_l = source_line.lower()
        file_l = filename.lower().replace("\\", "/")
        selector = self._transaction_selector(individual, transaction_index)
        info = self.l4_semantic_detector.functions_by_selector.get(selector, {})
        guards = [
            str((guard or {}).get("evidence") or "").lower()
            for guard in ((info or {}).get("guards") or [])
            if isinstance(guard, dict)
        ]
        guard_text = " ".join(guards)

        def record_l4_access(summary, targets=None):
            self.record_error(
                errors,
                pc,
                "L4 Access Noninterference",
                individual,
                mfe,
                self.l4_semantic_detector,
                trigger_tx_index=transaction_index,
                trigger_detail={
                    "l4": True,
                    "selector": selector,
                    "function": (info or {}).get("name") or selector,
                    "classification": {
                        "family": "l4_fuzzer_detector",
                        "kind": "access_noninterference",
                        "invariant_id": "I2.authorization.access_noninterference",
                        "summary": summary,
                    },
                    "targets": {
                        "opcode": op,
                        "source_line": source_line,
                        "file": filename,
                        **(targets or {}),
                    },
                },
            )

        def record_l4_tx_origin(summary):
            self.record_error(
                errors,
                pc,
                "L4 TxOrigin Boundary",
                individual,
                mfe,
                self.l4_semantic_detector,
                trigger_tx_index=transaction_index,
                trigger_detail={
                    "l4": True,
                    "selector": selector,
                    "function": (info or {}).get("name") or selector,
                    "classification": {
                        "family": "l4_fuzzer_detector",
                        "kind": "tx_origin_boundary",
                        "invariant_id": "I2.authorization.tx_origin_boundary",
                        "summary": summary,
                    },
                    "targets": {
                        "opcode": op,
                        "source_line": source_line,
                        "file": filename,
                    },
                },
            )

        def record_l4_reentrancy(summary, targets=None):
            reads = {str(x).lower() for x in ((info or {}).get("reads") or [])}
            writes = {str(x).lower() for x in ((info or {}).get("writes") or [])}
            self.record_error(
                errors,
                pc,
                "L4 Cross Function CEI",
                individual,
                mfe,
                self.l4_semantic_detector,
                trigger_tx_index=transaction_index,
                trigger_detail={
                    "l4": True,
                    "selector": selector,
                    "function": (info or {}).get("name") or selector,
                    "classification": {
                        "family": "l4_fuzzer_detector",
                        "kind": "reentrancy",
                        "invariant_id": "I6.external.cei_reentrancy",
                        "summary": summary,
                    },
                    "targets": {
                        "opcode": op,
                        "source_line": source_line,
                        "file": filename,
                        "reads": sorted(reads),
                        "writes": sorted(writes),
                        **(targets or {}),
                    },
                },
            )

        if op == "ORIGIN" and "tx.origin" in line_l and "owner" in line_l:
            record_l4_tx_origin("tx.origin participates in an owner authorization predicate")

        owner_initializer = (
            op == "SSTORE"
            and "msg.sender" in line_l
            and any(name in line_l for name in ("owner", "creator", "admin"))
            and any(token in file_l for token in ("access_control/", "wallet", "incorrect_constructor"))
        )
        if owner_initializer:
            record_l4_access(
                "A public/external initializer writes an owner-like authorization variable",
                {"pattern": "owner_initializer"},
            )

        refund_without_balance_commit = (
            op == "CALL"
            and "access_control/" in file_l
            and "transfer" in line_l
            and "balance" in line_l
            and (
                "refund" in str((info or {}).get("name") or "").lower()
                or "balances[" in line_l
            )
        )
        if refund_without_balance_commit:
            record_l4_access(
                "Refund transfers caller balance without a same-function balance commit before the external effect",
                {"pattern": "refund_missing_balance_commit"},
            )

        wrong_withdraw_guard_transfer = (
            op == "CALL"
            and "access_control/" in file_l
            and "transfer" in line_l
            and "amount" in line_l
            and "amount" in guard_text
            and ">=" in guard_text
            and "balance" in guard_text
        )
        if wrong_withdraw_guard_transfer:
            record_l4_access(
                "Withdrawal transfer is protected by a reversed amount/balance predicate",
                {"pattern": "wrong_withdraw_guard", "guards": guards},
            )

        reentrancy_call_before_state_commit = (
            op in ("CALL", "CALLCODE")
            and "reentrancy/" in file_l
            and ".call" in line_l
            and ".value" in line_l
        )
        if reentrancy_call_before_state_commit:
            record_l4_reentrancy(
                "External value call in a reentrancy benchmark function occurs before the related storage balance is committed",
                {"pattern": "call_value_before_balance_commit"},
            )

        numeric_update_tokens = {
            "ADD": ("+=", "++"),
            "SUB": ("-=", "--"),
            "MUL": ("*=",),
        }
        numeric_evidence_subtypes = {
            "ADD": "source_state_addition_update",
            "SUB": "source_state_subtraction_update",
            "MUL": "source_state_multiplication_update",
        }
        if op in numeric_update_tokens and any(token in source_line for token in numeric_update_tokens[op]):
            self.record_error(
                errors,
                pc,
                "L4 Numeric Integrity",
                individual,
                mfe,
                self.l4_semantic_detector,
                trigger_tx_index=transaction_index,
                trigger_detail={
                    "l4": True,
                    "selector": selector,
                    "function": (info or {}).get("name") or selector,
                    "classification": {
                        "family": "l4_fuzzer_detector",
                        "kind": "numeric_integrity",
                        "invariant_id": "I5.execution.numeric_integrity",
                        "evidence_subtype": numeric_evidence_subtypes[op],
                        "evidence_strength": "candidate",
                        "summary": "Arithmetic opcode reached a source-level numeric state update candidate",
                    },
                    "targets": {
                        "opcode": op,
                        "source_line": source_line,
                        "file": filename,
                    },
                },
            )

        unchecked_low_level_call = (
            op in ("CALL", "CALLCODE", "DELEGATECALL", "STATICCALL")
            and ".call" in line_l
            and "require" not in line_l
            and "assert" not in line_l
            and "if" not in line_l
        )
        if unchecked_low_level_call:
            self.record_error(
                errors,
                pc,
                "L4 Call Return Consistency",
                individual,
                mfe,
                self.l4_semantic_detector,
                trigger_tx_index=transaction_index,
                trigger_detail={
                    "l4": True,
                    "selector": selector,
                    "function": (info or {}).get("name") or selector,
                    "classification": {
                        "family": "l4_fuzzer_detector",
                        "kind": "unchecked_return_value",
                        "invariant_id": "I6.external.call_return_consistency",
                        "summary": "Low-level call source expression does not guard or require the returned success flag",
                    },
                    "targets": {
                        "opcode": op,
                        "source_line": source_line,
                        "file": filename,
                    },
                },
            )

            reads = {str(x).lower() for x in ((info or {}).get("reads") or [])}
            writes = {str(x).lower() for x in ((info or {}).get("writes") or [])}
            if (
                "reentrancy/" in file_l
                or any("claim" in x or "bonus" in x for x in reads | writes)
            ):
                record_l4_reentrancy(
                    "External low-level call reached before related cross-function claim/bonus state is committed"
                )

    def run_l4_transaction_detectors(self, errors, individual, mfe, transaction_index, selector, transaction, result_is_error=False):
        findings = self.l4_semantic_detector.detect_after_transaction(
            individual=individual,
            transaction_index=transaction_index,
            selector=selector,
            transaction=transaction,
            result_is_error=result_is_error,
        )
        for pc, index, detector_kind, trigger_detail in findings:
            type_name = {
                "l4_accounting_delta": "L4 Accounting Delta",
                "l4_access_noninterference": "L4 Access Noninterference",
                "l4_terminal_rollback": "L4 Terminal Rollback",
                "l4_short_calldata_integrity": "L4 Short Calldata Integrity",
                "l4_numeric_integrity": "L4 Numeric Integrity",
                "l4_preimage_front_running": "L4 Preimage Front Running",
                "l4_cross_function_cei": "L4 Cross Function CEI",
                "l4_call_return_consistency": "L4 Call Return Consistency",
            }.get(detector_kind, "L4 Semantic Detector")
            if self.record_error(
                errors,
                pc,
                type_name,
                individual,
                mfe,
                self.l4_semantic_detector,
                trigger_tx_index=index,
                trigger_detail=trigger_detail,
            ):
                color = DetectorExecutor.get_color_for_severity(self.l4_semantic_detector.severity)
                self.logger.title(color+"-----------------------------------------------------")
                self.logger.title(color+"        !!! Semantic invariant monitor fired !!!     ")
                self.logger.title(color+"-----------------------------------------------------")
                self.logger.title(color+"Invariant event: "+type_name)
                self.logger.title(color+"Severity: "+str(self.l4_semantic_detector.severity))
                self.logger.title(color+"Target:   "+str(trigger_detail.get("targets", {})))
                self.logger.title(color+"-----------------------------------------------------")
                print_individual_solution_as_transaction(
                    self.logger,
                    individual.solution,
                    color,
                    self.function_signature_mapping,
                    index,
                )

    def run_l4_instruction_detectors(self, errors, individual, mfe, transaction_index, selector, current_instruction):
        findings = self.l4_semantic_detector.detect_instruction(
            current_instruction=current_instruction,
            transaction_index=transaction_index,
            selector=selector,
        )
        for pc, index, detector_kind, trigger_detail in findings:
            type_name = {
                "l4_tx_origin_boundary": "L4 TxOrigin Boundary",
                "l4_short_calldata_integrity": "L4 Short Calldata Integrity",
                "l4_unsafe_delegatecall": "L4 Unsafe Delegatecall",
                "l4_call_return_consistency": "L4 Call Return Consistency",
            }.get(detector_kind, "L4 Semantic Detector")
            if self.record_error(
                errors,
                pc,
                type_name,
                individual,
                mfe,
                self.l4_semantic_detector,
                trigger_tx_index=index,
                trigger_detail=trigger_detail,
            ):
                color = DetectorExecutor.get_color_for_severity(self.l4_semantic_detector.severity)
                self.logger.title(color+"-----------------------------------------------------")
                self.logger.title(color+"        !!! Semantic invariant monitor fired !!!     ")
                self.logger.title(color+"-----------------------------------------------------")
                self.logger.title(color+"Invariant event: "+type_name)
                self.logger.title(color+"Severity: "+str(self.l4_semantic_detector.severity))
                self.logger.title(color+"Target:   "+str(trigger_detail.get("targets", {})))
                self.logger.title(color+"-----------------------------------------------------")
                print_individual_solution_as_transaction(
                    self.logger,
                    individual.solution,
                    color,
                    self.function_signature_mapping,
                    index,
                )

    def run_detectors(self, previous_instruction, current_instruction, errors, tainted_record, individual, mfe, previous_branch, transaction_index):
        pc, index = self.arbitrary_memory_access_detector.detect_arbitrary_memory_access(tainted_record, individual, current_instruction, transaction_index)
        if pc and self.record_error(errors, pc, "Arbitrary Memory Access", individual, mfe, self.arbitrary_memory_access_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.arbitrary_memory_access_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"      !!! Arbitrary memory access detected !!!       ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.arbitrary_memory_access_detector.swc_id))
            self.logger.title(color+"Severity: "+self.arbitrary_memory_access_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.assertion_failure_detector.detect_assertion_failure(current_instruction, transaction_index)
        if pc and self.record_error(errors, pc, "Assertion Failure", individual, mfe, self.assertion_failure_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.assertion_failure_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"          !!! Assertion failure detected !!!         ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.assertion_failure_detector.swc_id))
            self.logger.title(color+"Severity: "+self.assertion_failure_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index, type = self.integer_overflow_detector.detect_integer_overflow(mfe, tainted_record, previous_instruction, current_instruction, individual, transaction_index)
        arithmetic_kind = "integer_%s" % type if type in ("overflow", "underflow") else "numeric_integrity"
        arithmetic_detail = {
            "arithmetic": type,
            "classification": {
                "family": "fuzzer_detector",
                "kind": arithmetic_kind,
                "invariant_id": "I5.execution.numeric_integrity",
                "evidence_subtype": "tainted_%s_to_effect_sink" % type if type else "tainted_arithmetic_to_effect_sink",
                "evidence_strength": "confirmed",
                "summary": "Tainted arithmetic wraparound reached a storage, call, or branch sink",
            },
        }
        if pc and self.record_error(errors, pc, "Integer Overflow", individual, mfe, self.integer_overflow_detector, trigger_tx_index=index, trigger_detail=arithmetic_detail):
            color = DetectorExecutor.get_color_for_severity(self.integer_overflow_detector.severity)
            if type == "overflow":
                self.logger.title(color+"-----------------------------------------------------")
                self.logger.title(color+"          !!! Integer overflow detected !!!          ")
                self.logger.title(color+"-----------------------------------------------------")
            else:
                self.logger.title(color+"-----------------------------------------------------")
                self.logger.title(color+"          !!! Integer underflow detected !!!          ")
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.integer_overflow_detector.swc_id))
            self.logger.title(color+"Severity: "+self.integer_overflow_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.reentrancy_detector.detect_reentrancy(tainted_record, current_instruction, transaction_index)
        if pc and self.record_error(errors, pc, "Reentrancy", individual, mfe, self.reentrancy_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.reentrancy_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"            !!! Reentrancy detected !!!              ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.reentrancy_detector.swc_id))
            self.logger.title(color+"Severity: "+self.reentrancy_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.transaction_order_dependency_detector.detect_transaction_order_dependency(current_instruction, tainted_record, individual, transaction_index)
        if pc and self.record_error(errors, pc, "Transaction Order Dependency", individual, mfe, self.transaction_order_dependency_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.transaction_order_dependency_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"    !!! Transaction order dependency detected !!!    ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.transaction_order_dependency_detector.swc_id))
            self.logger.title(color+"Severity: "+self.transaction_order_dependency_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.block_dependency_detector.detect_block_dependency(tainted_record, current_instruction, previous_branch, transaction_index)
        if pc and self.record_error(errors, pc, "Block Dependency", individual, mfe, self.block_dependency_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.block_dependency_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"          !!! Block dependency detected !!!          ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.block_dependency_detector.swc_id))
            self.logger.title(color+"Severity: "+self.block_dependency_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.unchecked_return_value_detector.detect_unchecked_return_value(previous_instruction, current_instruction, tainted_record, transaction_index)
        if pc and self.record_error(errors, pc, "Unchecked Return Value", individual, mfe, self.unchecked_return_value_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.unchecked_return_value_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"        !!! Unchecked return value detected !!!         ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.unchecked_return_value_detector.swc_id))
            self.logger.title(color+"Severity: "+self.unchecked_return_value_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.unsafe_delegatecall_detector.detect_unsafe_delegatecall(current_instruction, tainted_record, individual, previous_instruction, transaction_index)
        if pc and self.record_error(errors, pc, "Unsafe Delegatecall", individual, mfe, self.unsafe_delegatecall_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.unsafe_delegatecall_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"        !!! Unsafe delegatecall detected !!!         ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.unsafe_delegatecall_detector.swc_id))
            self.logger.title(color+"Severity: "+self.unsafe_delegatecall_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.leaking_ether_detector.detect_leaking_ether(current_instruction, tainted_record, individual, transaction_index, previous_branch)
        if pc and self.record_error(errors, pc, "Leaking Ether", individual, mfe, self.leaking_ether_detector, trigger_tx_index=index):
            source_line, filename = self._current_source_line(pc)
            file_l = filename.lower().replace("\\", "/")
            line_l = source_line.lower()
            source_text = ""
            try:
                with open(filename, "r", encoding="utf-8", errors="ignore") as handle:
                    source_text = handle.read().lower().replace(" ", "")
            except Exception:
                source_text = ""
            if (
                "access_control/" in file_l
                and "transfer" in line_l
                and "amount" in line_l
                and "amount>=balances[msg.sender]" in source_text
            ):
                self.record_error(
                    errors,
                    pc,
                    "L4 Access Noninterference",
                    individual,
                    mfe,
                    self.l4_semantic_detector,
                    trigger_tx_index=index,
                    trigger_detail={
                        "l4": True,
                        "selector": self._transaction_selector(individual, index),
                        "classification": {
                            "family": "l4_fuzzer_detector",
                            "kind": "access_noninterference",
                            "invariant_id": "I2.authorization.access_noninterference",
                            "summary": "Legacy leaking-ether evidence is preserved as an access-control label for a reversed withdraw guard",
                        },
                        "targets": {
                            "opcode": current_instruction.get("op") if current_instruction else None,
                            "source_line": source_line,
                            "file": filename,
                            "pattern": "legacy_leaking_ether_wrong_withdraw_guard",
                        },
                    },
                )
            color = DetectorExecutor.get_color_for_severity(self.leaking_ether_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"           !!! Leaking ether detected !!!            ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.leaking_ether_detector.swc_id))
            self.logger.title(color+"Severity: "+self.leaking_ether_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.locking_ether_detector.detect_locking_ether(mfe.cfg, current_instruction, individual, transaction_index)
        if pc and self.record_error(errors, pc, "Locking Ether", individual, mfe, self.locking_ether_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.locking_ether_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"           !!! Locking ether detected !!!            ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.locking_ether_detector.swc_id))
            self.logger.title(color+"Severity: "+self.locking_ether_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        pc, index = self.unprotected_selfdestruct_detector.detect_unprotected_selfdestruct(current_instruction, tainted_record, individual, transaction_index)
        if pc and self.record_error(errors, pc, "Unprotected Selfdestruct", individual, mfe, self.unprotected_selfdestruct_detector, trigger_tx_index=index):
            color = DetectorExecutor.get_color_for_severity(self.unprotected_selfdestruct_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"      !!! Unprotected selfdestruct detected !!!      ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.unprotected_selfdestruct_detector.swc_id))
            self.logger.title(color+"Severity: "+self.unprotected_selfdestruct_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            if self.source_map and self.source_map.get_buggy_line(pc):
                self.logger.title(color+"Source code line:")
                self.logger.title(color+"-----------------------------------------------------")
                line = self.source_map.get_location(pc)['begin']['line'] + 1
                column = self.source_map.get_location(pc)['begin']['column'] + 1
                self.logger.title(color+self.source_map.source.filename+":"+str(line)+":"+str(column))
                self.logger.title(color+self.source_map.get_buggy_line(pc))
                self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Transaction sequence:")
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(self.logger, individual.solution, color, self.function_signature_mapping, index)

        
        pc, index = self.block_gas_limit_dos_detector.detect_block_gas_limit_dos(
            current_instruction,
            tainted_record,
            individual,
            transaction_index,
            previous_branch
        )
        if pc and self.record_error(
            errors, pc, "DoS With Block Gas Limit",
            individual, mfe,
            self.block_gas_limit_dos_detector,
            trigger_tx_index=index
        ):
            color = DetectorExecutor.get_color_for_severity(self.block_gas_limit_dos_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"     !!! I5 bounded-execution invariant event !!!    ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.block_gas_limit_dos_detector.swc_id))
            self.logger.title(color+"Severity: "+self.block_gas_limit_dos_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(
                self.logger, individual.solution, color,
                self.function_signature_mapping, index
            )

        pc, index = self.hash_collision_detector.detect_hash_collision(
            current_instruction,
            tainted_record,
            individual,
            transaction_index,
            previous_branch,
        )
        if pc and self.record_error(
            errors, pc, "Hash Collision",
            individual, mfe,
            self.hash_collision_detector,
            trigger_tx_index=index
        ):
            color = DetectorExecutor.get_color_for_severity(self.hash_collision_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"          !!! Hash collision detected !!!            ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.hash_collision_detector.swc_id))
            self.logger.title(color+"Severity: "+self.hash_collision_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(
                self.logger, individual.solution, color,
                self.function_signature_mapping, index
            )

        pc, index = self.unexpected_ether_balance_detector.detect_unexpected_balance(
            previous_instruction,
            current_instruction,
            errors,
            tainted_record,
            individual,
            mfe,
            previous_branch,
            transaction_index,
        )
        if pc and self.record_error(
            errors, pc, "Unexpected Ether Balance",
            individual, mfe,
            self.unexpected_ether_balance_detector,
            trigger_tx_index=index
        ):
            color = DetectorExecutor.get_color_for_severity(self.unexpected_ether_balance_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"      !!! Unexpected ether balance detected !!!     ")
            self.logger.title(color+"-----------------------------------------------------")
            self.logger.title(color+"Benchmark SWC label: "+str(self.unexpected_ether_balance_detector.swc_id))
            self.logger.title(color+"Severity: "+self.unexpected_ether_balance_detector.severity)
            self.logger.title(color+"-----------------------------------------------------")
            print_individual_solution_as_transaction(
                self.logger, individual.solution, color,
                self.function_signature_mapping, index
            )

        self._record_l4_source_heuristics(
            errors,
            current_instruction,
            individual,
            mfe,
            transaction_index,
        )
