#!/usr/bin/env python3
# -*- coding: utf-8 -*-

class FuzzingEnvironment:
    def __init__(self, **kwargs) -> None:
        self.nr_of_transactions = 0
        self.unique_individuals = set()
        self.code_coverage = set()
        self.valid_path_code_coverage = set()
        self.guard_revert_code_coverage = set()
        self.deployment_code_coverage = set()
        self.children_code_coverage = dict()
        self.previous_code_coverage_length = 0

        self.visited_branches = dict()
        self.valid_path_branches = set()
        self.guard_revert_branches = set()

        self.memoized_fitness = dict()
        self.memoized_storage = dict()
        self.memoized_symbolic_execution = dict()

        self.individual_branches = dict()

        self.data_dependencies = dict()

        self.__dict__.update(kwargs)
