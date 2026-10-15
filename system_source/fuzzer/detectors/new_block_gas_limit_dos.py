#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from z3 import is_expr
from z3.z3util import get_vars


class BlockGasLimitDoSDetector:

    def __init__(self):
        self.init()

    def init(self):
        self.swc_id = 128
        self.severity = "Medium"
        self.last_cmp_instruction = None
        self.loop_candidates = {}
        self.reported_loops = set()

    # =====================================================
    # 栈值转换
    # =====================================================
    def _convert_stack_value(self, val):

        try:
            if isinstance(val, int):
                return val

            if isinstance(val, bytes):
                return int.from_bytes(val, "big")

            if isinstance(val, str):
                return int(val, 16)

            if isinstance(val, tuple):
                return self._convert_stack_value(val[1])

        except Exception:
            pass

        return None

    # =====================================================
    # backward jump 检测
    # =====================================================
    def _is_backward_jump(self, pc, stack):

        if not stack:
            return False

        dest = self._convert_stack_value(stack[-1])

        if dest is None:
            return False

        return dest < pc

    # =====================================================
    # 记录比较指令
    # =====================================================
    def _record_cmp(self, current_instruction):

        op = current_instruction.get("op")

        if op in ("LT", "GT", "LE", "GE", "EQ"):
            self.last_cmp_instruction = current_instruction
            # print("[SWC-128] Recorded comparison:", op)

    # =====================================================
    # 分析上界
    # =====================================================
    def _analyze_upper_bound(self, cmp_instruction, pc):

        stack = cmp_instruction.get("stack", [])

        if len(stack) < 2:
            return "collecting", None

        left = self._convert_stack_value(stack[-2])
        right = self._convert_stack_value(stack[-1])

        if left is None or right is None:
            return "collecting", None

        if pc not in self.loop_candidates:
            self.loop_candidates[pc] = {
                "values": []
            }

        record = self.loop_candidates[pc]
        record["values"].append((left, right))

        # 统计不够，不判断
        if len(record["values"]) < 5:
            return "collecting", None

        left_values = [v[0] for v in record["values"]]
        right_values = [v[1] for v in record["values"]]

        if len(set(left_values)) == 1 and len(set(right_values)) > 1:
            return "constant", left_values[0]

        if len(set(right_values)) == 1 and len(set(left_values)) > 1:
            return "constant", right_values[0]

        return "unknown", None
    
    # =====================================================
    # 主检测函数
    # =====================================================
    def detect_block_gas_limit_dos(
        self,
        current_instruction,
        taint_record,
        individual,
        transaction_index,
        previous_branch
    ):

        if not isinstance(current_instruction, dict):
            return None, None

        op = current_instruction.get("op")
        pc = current_instruction.get("pc")
        stack = current_instruction.get("stack", [])

        # 1️⃣ 先记录比较指令
        self._record_cmp(current_instruction)

        # 2️⃣ 只关注跳转
        if op not in ("JUMP", "JUMPI"):
            return None, None

        # 3️⃣ backward jump
        if not self._is_backward_jump(pc, stack):
            return None, None

        # print("\n[SWC-128] Backward jump at PC:", pc)

        # 4️⃣ 必须存在之前的比较
        if not self.last_cmp_instruction:
            # print("[SWC-128] No comparison recorded")
            return None, None

        # print("[SWC-128] Using comparison:",
        #       self.last_cmp_instruction.get("op"))

        bound_type, bound_val = self._analyze_upper_bound(
            self.last_cmp_instruction,
            pc
        )

        # print("[SWC-128] Bound type:", bound_type)
        # print("[SWC-128] Bound value:", bound_val)

        # 5️⃣ 判断漏洞
        if bound_type == "constant":

            if bound_val > 300:
                # if pc in self.reported_loops:
                #     return None, None
                # self.reported_loops.add(pc)
                loop_id = (transaction_index, pc)
                if loop_id in self.reported_loops:
                    return None, None
                self.reported_loops.add(loop_id)
                # print("[SWC-128] DETECTED: large constant loop")
                return pc, transaction_index
            else:
                # print("[SWC-128] Safe bounded loop")
                return None, None

        if bound_type == "symbolic":
            # if pc in self.reported_loops:
            #     return None, None
            # self.reported_loops.add(pc)
            loop_id = (transaction_index, pc)
            if loop_id in self.reported_loops:
                return None, None
            self.reported_loops.add(loop_id)
            # print("[SWC-128] DETECTED: symbolic bound loop")
            return pc, transaction_index

        if bound_type == "collecting":
            return None, None

        if bound_type == "unknown":
            # 只有在统计次数足够后才考虑报
            # if pc in self.reported_loops:
            #     return None, None
            # self.reported_loops.add(pc)
            loop_id = (transaction_index, pc)
            if loop_id in self.reported_loops:
                return None, None
            self.reported_loops.add(loop_id)
            # print("[SWC-128] Unknown bound after analysis")
            return pc, transaction_index

        return None, None