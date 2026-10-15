#!/usr/bin/env python3
# -*- coding: utf-8 -*-

""" Random sequence-splitting operator implementation. """

import random

from ....utils import settings
from ...plugin_interfaces.operators.split import Split
from ...components.individual import Individual


class RandomSplit(Split):
    def __init__(self, ps, min_len=1):
        """
        :param ps: 概率（per-individual）触发随机分裂，0.0~1.0
        :param min_len: 分裂后每个片段的最小交易数
        """
        if ps < 0.0 or ps > 1.0:
            raise ValueError("Invalid split probability")
        if min_len < 1:
            raise ValueError("min_len must be >= 1")

        self.ps = ps
        self.min_len = min_len

    def apply(self, individual):
        """
        对单个 individual 进行随机分裂:
          A = [t1..tn] -> A1=[t1..tk], A2=[t(k+1)..tn]

        返回:
          - 不分裂: [original_individual]
          - 分裂成功: [child1, child2]
        """

        # 概率门：大多数时候直接返回原始个体
        if random.random() > self.ps:
            return [individual]

        chrom = getattr(individual, "chromosome", None)
        if not chrom:
            return [individual]

        n = len(chrom)
        # print(n)
        # 序列长度太短，无法分裂
        if n < 2 * self.min_len:
            return [individual]

        # 在 [min_len, n - min_len] 之间随机选择切点
        k = random.randint(self.min_len, n - self.min_len)

        frag1 = chrom[:k]
        frag2 = chrom[k:]

        # 构造两个新 Individual，沿用原来的 generator
        gen = individual.generator

        child1 = Individual(generator=gen)
        child1.init(chromosome=frag1)

        child2 = Individual(generator=gen)
        child2.init(chromosome=frag2)

        # # 碎片长度不会超过原始长度，这里再做一次 MAX_INDIVIDUAL_LENGTH 保险检查
        # if len(child1.chromosome) > settings.MAX_INDIVIDUAL_LENGTH:
        #     return [individual]  # 放弃分裂
        # if len(child2.chromosome) > settings.MAX_INDIVIDUAL_LENGTH:
        #     return [individual]

        # Return the original as well so split is always a coverage supplement.
        # The engine keeps the original child and appends only new fragments.
        return [individual, child1, child2]
