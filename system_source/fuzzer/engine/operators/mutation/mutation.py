#!/usr/bin/env python3
# -*- coding: utf-8 -*-

''' Mutation implementation. '''

import random
import re

from ....utils import settings
from ...plugin_interfaces.operators.mutation import Mutation
import logging
log = logging.getLogger("MutationDEBUG")


def _normalize_selector(selector):
    if not isinstance(selector, str):
        return selector
    selector = selector.strip()
    if selector in ("constructor", "fallback", "receive"):
        return selector
    if re.fullmatch(r"0x[0-9a-fA-F]{8}", selector):
        return selector.lower()
    if re.fullmatch(r"[0-9a-fA-F]{8}", selector):
        return "0x" + selector.lower()
    return selector


def _selector_for_interface(generator, selector):
    if selector in getattr(generator, "interface", {}):
        return selector
    normalized = _normalize_selector(selector)
    if normalized in getattr(generator, "interface", {}):
        return normalized
    if isinstance(normalized, str) and normalized.startswith("0x"):
        bare = normalized[2:]
        if bare in getattr(generator, "interface", {}):
            return bare
    if isinstance(selector, str):
        with0x = "0x" + selector
        if with0x in getattr(generator, "interface", {}):
            return with0x
    return selector


def _clean_abi_type(abi_type):
    if not isinstance(abi_type, str):
        return ""
    abi_type = abi_type.replace(" storage", "").replace(" memory", "").replace(" calldata", "")
    return abi_type.strip()


def _integer_bits(abi_type, prefix):
    suffix = abi_type.replace(prefix, "").split("[")[0]
    if not suffix:
        return 256
    try:
        return int(suffix)
    except Exception:
        return 256


def _interesting_value_for_type(abi_type, generator):
    abi_type = _clean_abi_type(abi_type)
    if "[" in abi_type and "]" in abi_type:
        return None
    if abi_type.startswith("uint"):
        bits = _integer_bits(abi_type, "uint")
        max_value = (1 << bits) - 1
        return random.choice([0, 1, 2, 10, max(0, max_value - 1), max_value])
    if abi_type.startswith("int"):
        bits = _integer_bits(abi_type, "int")
        bits = max(8, bits)
        max_value = (1 << (bits - 1)) - 1
        min_value = -(1 << (bits - 1))
        return random.choice([0, 1, -1, min_value, min_value + 1, max_value - 1, max_value])
    if abi_type.startswith("bool"):
        return random.choice([False, True])
    if abi_type.startswith("address"):
        accounts = getattr(generator, "accounts", []) or []
        return random.choice(accounts) if accounts else None
    if abi_type == "string":
        return random.choice(["", "A", "A" * 32, "A" * 33])
    if abi_type.startswith("bytes"):
        if abi_type == "bytes":
            length = random.choice([0, 1, 32, 33])
        else:
            try:
                max_length = int(abi_type.replace("bytes", "").split("[")[0])
            except Exception:
                max_length = 32
            length = random.choice([0, 1, min(32, max_length), max_length])
        try:
            return bytearray(random.getrandbits(8) for _ in range(length))
        except Exception:
            return None
    return None

class Mutation(Mutation):
    def __init__(self, pm):
        '''
        :param pm: The probability of mutation (usually between 0.001 ~ 0.1)
        :type pm: float in (0.0, 1.0]
        '''
        if pm <= 0.0 or pm > 1.0:
            raise ValueError('Invalid mutation probability')

        self.pm = pm

    def _stats(self, engine):
        env = getattr(engine, "env", None)
        if env is None:
            return None
        if not hasattr(env, "uir_mutation_stats"):
            env.uir_mutation_stats = {
                "attempts": 0,
                "applied": 0,
                "field_mutations": 0,
                "sequence_insertions": 0,
                "by_reason": {},
            }
        return env.uir_mutation_stats

    @staticmethod
    def _record(stats, key, amount=1):
        if stats is None:
            return
        stats[key] = stats.get(key, 0) + amount

    @staticmethod
    def _record_reason(stats, reason):
        if stats is None:
            return
        stats.setdefault("by_reason", {})
        stats["by_reason"][reason] = stats["by_reason"].get(reason, 0) + 1

    def _uir_enabled(self, engine):
        env = getattr(engine, "env", None)
        args = getattr(env, "args", None)
        return bool(
            getattr(args, "uir_mutation", False)
            and isinstance(getattr(env, "uir_targets", None), dict)
        )

    def _function_info(self, engine, selector):
        env = getattr(engine, "env", None)
        targets = getattr(env, "uir_targets", {}) or {}
        functions = targets.get("functions_by_selector", {}) if isinstance(targets, dict) else {}
        normalized = _normalize_selector(selector)
        return functions.get(normalized) or functions.get(selector) or {}

    def _make_gene_for_function(self, individual, function_hash):
        generator = individual.generator
        function_hash = _selector_for_interface(generator, function_hash)
        argument_types = getattr(generator, "interface", {}).get(function_hash)
        if argument_types is None:
            return None
        arguments = [function_hash]
        for index, argument_type in enumerate(argument_types):
            arguments.append(generator.get_random_argument(argument_type, function_hash, index))
        account = generator.get_random_account(function_hash)
        gaslimit = generator.get_random_gaslimit(function_hash)
        amount = generator.get_random_amount(function_hash, account=account, gaslimit=gaslimit)
        return {
            "account": account,
            "contract": generator.contract,
            "amount": amount,
            "arguments": arguments,
            "blocknumber": generator.get_random_blocknumber(function_hash),
            "timestamp": generator.get_random_timestamp(function_hash),
            "gaslimit": gaslimit,
            "call_return": dict(),
            "extcodesize": dict(),
            "returndatasize": dict(),
        }

    def _mutate_gene_with_uir(self, gene, info, individual, stats):
        categories = set(info.get("categories") or [])
        risk_tags = set(info.get("risk_tags") or [])
        reasons = []
        function_hash = gene["arguments"][0]
        generator = individual.generator

        if categories.intersection({"access_guarded", "access_anomaly", "guarded"}) or risk_tags.intersection({"guarded_sensitive", "access_anomaly"}):
            try:
                gene["account"] = generator.get_random_account(function_hash)
                reasons.append("access_guard_account")
            except Exception:
                pass

        if categories.intersection({"accounting", "accounting_anomaly", "sensitive"}) or risk_tags.intersection({"accounting_relation", "accounting_anomaly", "sensitive_function"}):
            argument_types = getattr(generator, "interface", {}).get(function_hash, [])
            numeric_indices = []
            address_indices = []
            for index, argument_type in enumerate(argument_types):
                cleaned = _clean_abi_type(argument_type)
                if cleaned.startswith("uint") or cleaned.startswith("int"):
                    numeric_indices.append(index)
                elif cleaned.startswith("address"):
                    address_indices.append(index)

            if numeric_indices:
                index = random.choice(numeric_indices)
                value = _interesting_value_for_type(argument_types[index], generator)
                if value is not None and index + 1 < len(gene["arguments"]):
                    gene["arguments"][index + 1] = value
                    try:
                        generator.add_argument_to_pool(function_hash, index, value)
                    except Exception:
                        pass
                    reasons.append("accounting_numeric_boundary")

            if address_indices and random.random() <= 0.5:
                index = random.choice(address_indices)
                value = _interesting_value_for_type(argument_types[index], generator)
                if value is not None and index + 1 < len(gene["arguments"]):
                    gene["arguments"][index + 1] = value
                    try:
                        generator.add_argument_to_pool(function_hash, index, value)
                    except Exception:
                        pass
                    reasons.append("semantic_address_argument")

            if "amount" in gene:
                value = random.choice([0, 1, 2, 10])
                if hasattr(generator, "_cap_amount_for_sender"):
                    value = generator._cap_amount_for_sender(
                        function_hash,
                        value,
                        account=gene.get("account"),
                        gaslimit=gene.get("gaslimit"),
                    )
                gene["amount"] = value
                try:
                    generator.add_amount_to_pool(function_hash, value)
                except Exception:
                    pass
                reasons.append("callvalue_boundary")

        if "state_transition" in categories:
            if "timestamp" in gene:
                current = gene.get("timestamp")
                current = current if isinstance(current, int) else 0
                gene["timestamp"] = random.choice([0, 1, current, current + 1])
                reasons.append("state_transition_timestamp")
            if "blocknumber" in gene:
                current = gene.get("blocknumber")
                current = current if isinstance(current, int) else 0
                gene["blocknumber"] = random.choice([0, 1, current, current + 1])
                reasons.append("state_transition_blocknumber")

        if reasons:
            self._record(stats, "field_mutations")
            for reason in reasons:
                self._record_reason(stats, reason)
        return bool(reasons)

    def _maybe_insert_related_call(self, individual, engine, stats):
        env = getattr(engine, "env", None)
        args = getattr(env, "args", None)
        insertion_rate = float(getattr(args, "uir_mutation_insert_rate", 0.1) or 0.0)
        if random.random() > insertion_rate:
            return False
        if len(individual.chromosome) >= settings.MAX_INDIVIDUAL_LENGTH:
            return False

        targets = getattr(env, "uir_targets", {}) or {}
        relations = getattr(env, "uir_relation_targets", None)
        if relations is None:
            relations = targets.get("relation_targets", []) if isinstance(targets, dict) else []
        if not relations:
            return False

        selectors = [_normalize_selector(gene["arguments"][0]) for gene in individual.chromosome if gene.get("arguments")]
        candidates = []
        for relation in relations:
            from_selector = _normalize_selector(relation.get("from_selector"))
            to_selector = _normalize_selector(relation.get("to_selector"))
            if from_selector in selectors and to_selector not in selectors:
                candidates.append((selectors.index(from_selector) + 1, to_selector, "relation_to"))
            elif to_selector in selectors and from_selector not in selectors:
                candidates.append((selectors.index(to_selector), from_selector, "relation_from"))
        if not candidates:
            return False

        insert_at, selector, reason = random.choice(candidates)
        function_hash = _selector_for_interface(individual.generator, selector)
        gene = self._make_gene_for_function(individual, function_hash)
        if gene is None:
            return False
        individual.chromosome.insert(max(0, min(insert_at, len(individual.chromosome))), gene)
        self._record(stats, "sequence_insertions")
        self._record_reason(stats, reason)
        return True

    def _uir_guided_mutate(self, individual, engine):
        if not self._uir_enabled(engine):
            return False
        env = getattr(engine, "env", None)
        args = getattr(env, "args", None)
        semantic_rate = float(getattr(args, "uir_mutation_rate", 0.25) or 0.0)
        if random.random() > semantic_rate:
            return False

        stats = self._stats(engine)
        self._record(stats, "attempts")
        applied = False
        target_genes = []
        for gene in individual.chromosome:
            if not gene.get("arguments"):
                continue
            info = self._function_info(engine, gene["arguments"][0])
            if info:
                target_genes.append((gene, info))

        if target_genes:
            gene, info = random.choice(target_genes)
            applied = self._mutate_gene_with_uir(gene, info, individual, stats) or applied

        applied = self._maybe_insert_related_call(individual, engine, stats) or applied
        if applied:
            self._record(stats, "applied")
        return applied

    def mutate(self, individual, engine):
        for gene in individual.chromosome:
            # TRANSACTION
            function_hash = gene["arguments"][0]
            for element in gene:
                if element == "account" and random.random() <= self.pm:
                    gene["account"] = individual.generator.get_random_account(function_hash)
                elif element == "amount" and random.random() <= self.pm:
                    gene["amount"] = individual.generator.get_random_amount(
                        function_hash,
                        account=gene.get("account"),
                        gaslimit=gene.get("gaslimit"),
                    )
                elif element == "gaslimit" and random.random() <= self.pm:
                    gene["gaslimit"] = individual.generator.get_random_gaslimit(function_hash)
                else:
                    for argument_index in range(1, len(gene["arguments"])):
                        if random.random() > self.pm:
                            continue
                        # ------------------------Debug------------------------ #
                        try:
                            argument_type = individual.generator.interface[function_hash][argument_index - 1]
                        except KeyError as e:
                            log.error("[MUTATION] function_hash=%r not in interface keys(sample): %s", 
                                    function_hash, list(individual.generator.interface.keys())[:12])
                            raise
                        # ------------------------Debug------------------------ #
                        argument_type = individual.generator.interface[function_hash][argument_index - 1]
                        argument = individual.generator.get_random_argument(argument_type,
                                                                            function_hash,
                                                                            argument_index - 1)
                        gene["arguments"][argument_index] = argument

            # BLOCK
            if "timestamp" in gene:
                if random.random() <= self.pm:
                    gene["timestamp"] = individual.generator.get_random_timestamp(function_hash)
            else:
                gene["timestamp"] = individual.generator.get_random_timestamp(function_hash)

            if "blocknumber" in gene:
                if random.random() <= self.pm:
                    gene["blocknumber"] = individual.generator.get_random_blocknumber(function_hash)
            else:
                gene["blocknumber"] = individual.generator.get_random_blocknumber(function_hash)

            # GLOBAL STATE
            if "balance" in gene:
                if random.random() <= self.pm:
                    gene["balance"] = individual.generator.get_random_balance(function_hash)
            else:
                gene["balance"] = individual.generator.get_random_balance(function_hash)

            if "call_return" in gene:
                for address in gene["call_return"]:
                    if random.random() <= self.pm:
                        gene["call_return"][address] = individual.generator.get_random_callresult(function_hash, address)
            else:
                gene["call_return"] = dict()
                address, call_return_value = individual.generator.get_random_callresult_and_address(function_hash)
                if address and address not in gene["call_return"]:
                    gene["call_return"][address] = call_return_value

            if "extcodesize" in gene:
                for address in gene["extcodesize"]:
                    if random.random() <= self.pm:
                        gene["extcodesize"][address] = individual.generator.get_random_extcodesize(function_hash, address)
            else:
                gene["extcodesize"] = dict()
                address, extcodesize_value = individual.generator.get_random_extcodesize_and_address(function_hash)
                if address and address not in gene["extcodesize"]:
                    gene["extcodesize"][address] = extcodesize_value

            if "returndatasize" in gene:
                for address in gene["returndatasize"]:
                    if random.random() <= self.pm:
                        gene["returndatasize"][address] = individual.generator.get_random_returndatasize(function_hash, address)
            else:
                gene["returndatasize"] = dict()
                address, returndatasize_value = individual.generator.get_random_returndatasize_and_address(function_hash)
                if address and address not in gene["returndatasize"]:
                    gene["returndatasize"][address] = returndatasize_value

            if hasattr(individual.generator, "_cap_amount_for_sender"):
                gene["amount"] = individual.generator._cap_amount_for_sender(
                    function_hash,
                    gene.get("amount", 0),
                    account=gene.get("account"),
                    gaslimit=gene.get("gaslimit"),
                )

        self._uir_guided_mutate(individual, engine)

        individual.solution = individual.decode()
        return individual
