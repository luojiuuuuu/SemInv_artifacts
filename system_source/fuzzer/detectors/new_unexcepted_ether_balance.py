#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from z3 import is_expr, is_app
from ..utils.utils import detect_balance_in_expr

class UnexpectedEtherBalanceDetector():

    def __init__(self):
        self.init()

    def init(self):
        self.swc_id = 132
        self.severity = "Medium"
        self.violations = []

        # ⭐ 关键：记录已经报告过的 transaction
        self.reported_transactions = set()

    # =====================================
    # 递归检测是否存在 balance == X
    # =====================================
    def _contains_balance_equality(self, expr):

        if not is_expr(expr):
            return False

        if is_app(expr):
            name = expr.decl().name()

            # Z3 等号
            if name in ["=", "Eq", "eq"]:
                left = expr.arg(0)
                right = expr.arg(1)

                if detect_balance_in_expr(left) or detect_balance_in_expr(right):
                    return True

            # 递归子表达式
            for i in range(expr.num_args()):
                if self._contains_balance_equality(expr.arg(i)):
                    return True

        return False

    # =====================================
    # 主检测函数
    # =====================================
    def detect_unexpected_balance(self,
                                  previous_instruction,
                                  current_instruction,
                                  errors,
                                  tainted_record,
                                  individual,
                                  mfe,
                                  previous_branch,
                                  transaction_index):

        # ⭐ 如果这个 transaction 已经报过，直接跳过
        if transaction_index in self.reported_transactions:
            return None, None

        if not previous_branch:
            return None, None

        for expr in previous_branch:

            if is_expr(expr):

                if self._contains_balance_equality(expr):

                    # ⭐ 标记这个 transaction 已经报过
                    self.reported_transactions.add(transaction_index)

                    self.violations.append(
                        (
                            current_instruction["pc"],
                            transaction_index,
                            str(expr)
                        )
                    )

                    return current_instruction["pc"], transaction_index

        return None, None
