#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from abc import ABCMeta, abstractmethod

class Split(metaclass=ABCMeta):
    """
    基类：序列分裂算子。
    """

    @abstractmethod
    def apply(self, individual):
        """
        对一个 individual 应用分裂算子。

        返回值建议为 list[Individual]：
          - 如果不分裂： [original_individual]
          - 如果分裂出两个片段： [child1, child2]
        """
        raise NotImplementedError
