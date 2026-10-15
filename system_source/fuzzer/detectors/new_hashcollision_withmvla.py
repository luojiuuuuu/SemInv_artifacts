#!/usr/bin/env python3
# -*- coding: utf-8 -*-

class HashCollisionDetector():

    def __init__(self):
        self.init()
        self.instruction_history = []

    def init(self):
        self.swc_id = 133
        self.severity = "Medium"
        self.violations = {}
        self.reported = set()

    # ========================================
    # 主检测逻辑（最终稳定结构型版本）
    # ========================================
    def detect_hash_collision(self,
                              current_instruction,
                              taint_record,
                              individual,
                              transaction_index,
                              previous_branch):

        # 记录 opcode 历史
        if isinstance(current_instruction, dict):
            self.instruction_history.append(current_instruction)

        if len(self.instruction_history) > 1000:
            self.instruction_history = self.instruction_history[-1000:]

        if transaction_index in self.reported:
            return None, None

        if not isinstance(current_instruction, dict):
            return None, None

        op = current_instruction.get("op")

        if op not in ("SHA3", "KECCAK256"):
            return None, None

        # print("\n=== ENTER KECCAK BRANCH ===")
        # print("PC:", current_instruction.get("pc"))

        lookback = 80
        recent_instr = self.instruction_history[-lookback:]

        mstore_count = 0
        mload_count = 0
        add_count = 0
        sstore_count = 0

        for instr in recent_instr:
            if not isinstance(instr, dict):
                continue

            op = instr.get("op")

            if op == "MSTORE":
                mstore_count += 1
            elif op == "MLOAD":
                mload_count += 1
            elif op == "ADD":
                add_count += 1
            elif op == "SSTORE":
                sstore_count += 1

        # print(">>> MSTORE:", mstore_count)
        # print(">>> MLOAD :", mload_count)
        # print(">>> ADD   :", add_count)
        # print(">>> SSTORE:", sstore_count)

        # 🔥 结构型 heuristic
        if (
            mstore_count >= 4 and
            mload_count >= 1 and
            add_count >= 2 and
            sstore_count == 0
        ):
            # print("\n SWC-133 HASH COLLISION DETECTED")

            self.reported.add(transaction_index)

            self.violations[transaction_index] = (
                current_instruction["pc"],
                transaction_index,
                {
                    "mstore": mstore_count,
                    "mload": mload_count,
                    "add": add_count
                }
            )

            return current_instruction["pc"], transaction_index

        return None, None