#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import random

from copy import deepcopy, copy
try:
    from eth_abi import encode
except ImportError:
    from eth_abi import encode_abi as encode
from eth_abi.exceptions import EncodingTypeError, ValueOutOfBounds, ParseError

from ...utils.utils import initialize_logger
from .generator import normalize_abi_argument

from eth_utils import keccak
import re
import logging
logger = logging.getLogger(__name__)

class Individual():
    def __init__(self, generator):
        self.logger = initialize_logger("Individual")
        self.chromosome = []
        self.solution = []
        self.generator = generator

    @property
    def hash(self):
        if not self.solution:
            self.solution = self.decode()
        return str(hash(str([tx for tx in self.solution])))
    
    # ---------------------------ADD--------------------- #
    def _resolve_selector(self, token: str) -> str:
        tok = token.strip()
        # interface 的 key 可能就是4字节
        if tok in self.generator.interface:
            sel = tok[2:] if tok.startswith("0x") else tok
            if re.fullmatch(r"[0-9a-fA-F]{8}", sel):
                return sel.lower()
        # 4字节hex
        m = re.fullmatch(r"(0x)?([0-9a-fA-F]{8})", tok)
        if m: return m.group(2).lower()
        # 完整签名
        if "(" in tok and tok.endswith(")"):
            return keccak(text=tok)[:4].hex()
        raise ValueError(f"Ambiguous function token '{token}', use 4-byte or full signature")


    def init(self, chromosome=None):
        if not chromosome:
            self.chromosome = self.generator.generate_random_individual()
        else:
            self.chromosome = chromosome
        self.solution = self.decode()
        return self

    def clone(self):
        indv = self.__class__(generator=self.generator)
        indv.init(chromosome=deepcopy(self.chromosome))
        return indv

    def decode(self):
        solution = []
        local_balances = {}
        for i in range(len(self.chromosome)):
            # ★ 新增：判断是否为 constructor 笔
            is_ctor = False
            if "arguments" in self.chromosome[i] and isinstance(self.chromosome[i]["arguments"], list):
                is_ctor = (len(self.chromosome[i]["arguments"]) > 0 and self.chromosome[i]["arguments"][0] == "constructor")

            transaction = {}
            transaction["from"] = copy(self.chromosome[i]["account"])
            transaction["value"] = copy(self.chromosome[i]["amount"])
            transaction["gaslimit"] = copy(self.chromosome[i]["gaslimit"])

            # 关键：constructor 的 to 必须为 None，其它函数调用才是已部署地址
            func_tag = None
            if "arguments" in self.chromosome[i] and isinstance(self.chromosome[i]["arguments"], list) and self.chromosome[i]["arguments"]:
                func_tag = self.chromosome[i]["arguments"][0]

            if func_tag == "constructor":
                transaction["to"] = b''
            else:
                transaction["to"] = copy(self.chromosome[i]["contract"])

            # Value-cap rollback hook: disable the new decode-time payable /
            # balance cap while testing original SemInv amount behavior.
            # if hasattr(self.generator, "_cap_amount_for_sender"):
            if False and hasattr(self.generator, "_cap_amount_for_sender"):
                account = transaction.get("from")
                if account not in local_balances:
                    balance_getter = getattr(self.generator, "balance_getter", None)
                    if callable(balance_getter):
                        try:
                            local_balances[account] = int(balance_getter(account))
                        except Exception:
                            local_balances[account] = None
                    else:
                        local_balances[account] = None

                balance = local_balances.get(account)
                transaction["value"] = self.generator._cap_amount_for_sender(
                    func_tag,
                    transaction.get("value", 0),
                    account=account,
                    gaslimit=transaction.get("gaslimit"),
                    balance=balance,
                )
                self.chromosome[i]["amount"] = transaction["value"]

                if balance is not None:
                    try:
                        gas_price_getter = getattr(self.generator, "gas_price_getter", None)
                        gas_price = int(gas_price_getter() if callable(gas_price_getter) else 0)
                        spent = int(transaction.get("value", 0)) + int(transaction.get("gaslimit", 0)) * gas_price
                        local_balances[account] = max(0, int(balance) - spent)
                    except Exception:
                        pass

            transaction["data"] = self.get_transaction_data_from_chromosome(i)

            block = {}
            if "timestamp" in self.chromosome[i] and self.chromosome[i]["timestamp"] is not None:
                block["timestamp"] = copy(self.chromosome[i]["timestamp"])
            if "blocknumber" in self.chromosome[i] and self.chromosome[i]["blocknumber"] is not None:
                block["blocknumber"] = copy(self.chromosome[i]["blocknumber"])

            global_state = {}
            if "balance" in self.chromosome[i] and self.chromosome[i]["balance"] is not None:
                global_state["balance"] = copy(self.chromosome[i]["balance"])
            if "call_return" in self.chromosome[i] and self.chromosome[i]["call_return"] is not None\
                    and len(self.chromosome[i]["call_return"]) > 0:
                global_state["call_return"] = copy(self.chromosome[i]["call_return"])
            if "extcodesize" in self.chromosome[i] and self.chromosome[i]["extcodesize"] is not None\
                    and len(self.chromosome[i]["extcodesize"]) > 0:
                global_state["extcodesize"] = copy(self.chromosome[i]["extcodesize"])

            environment = {}
            if "returndatasize" in self.chromosome[i] and self.chromosome[i]["returndatasize"] is not None:
                environment["returndatasize"] = copy(self.chromosome[i]["returndatasize"])

            input = {"transaction":transaction, "block" : block, "global_state" : global_state, "environment": environment}
            solution.append(input)
        return solution

    # def get_transaction_data_from_chromosome(self, chromosome_index):
    #     data = ""
    #     arguments = []
    #     function = None
    #     for j in range(len(self.chromosome[chromosome_index]["arguments"])):
    #         if self.chromosome[chromosome_index]["arguments"][j] == "fallback":
    #             function = "fallback"
    #             data += random.choice(["", "00000000"])
    #         elif self.chromosome[chromosome_index]["arguments"][j] == "constructor":
    #             function = "constructor"
    #             data += self.generator.bytecode
    #         elif not type(self.chromosome[chromosome_index]["arguments"][j]) is bytearray and \
    #                 not type(self.chromosome[chromosome_index]["arguments"][j]) is list and \
    #                 self.chromosome[chromosome_index]["arguments"][j] in self.generator.interface:
    #             function = self.chromosome[chromosome_index]["arguments"][j]
    #             data += self.chromosome[chromosome_index]["arguments"][j]
    #         else:
    #             arguments.append(self.chromosome[chromosome_index]["arguments"][j])
    #     try:
    #         argument_types = [argument_type.replace(" storage", "").replace(" memory", "") for argument_type in self.generator.interface[function]]
    #         data += encode(argument_types, arguments).hex()
    #     except Exception as e:
    #         self.logger.error("%s", e)
    #         self.logger.error("%s: %s -> %s", function, self.generator.interface[function], arguments)
    #         sys.exit(-6)
    #     return data

    # ------------------------ADD--------------------- #
    def get_transaction_data_from_chromosome(self, chromosome_index):
        raw_data = self.chromosome[chromosome_index].get("data")
        if raw_data is not None:
            return str(raw_data)

        data = ""
        arguments = []
        function = None
        selector = None

        for tok in self.chromosome[chromosome_index]["arguments"]:
            if tok == "fallback":
                function = "fallback"
                data += random.choice(["", "00000000"])
            elif tok == "constructor":
                function = "constructor"
                data += self.generator.bytecode
            elif not isinstance(tok, (bytearray, list)):
                try:
                    selector = self._resolve_selector(tok)   # '095ea7b3'
                    data += selector
                    selector_0x = "0x" + selector

                    if selector in self.generator.interface:
                        function = selector
                    elif selector_0x in self.generator.interface:
                        function = selector_0x
                    elif tok in self.generator.interface:
                        function = tok
                    else:
                        # 额外提示一下当前 interface 的键，便于定位
                        self.logger.error("Selector %s / %s not in interface keys: %s",
                                        selector, selector_0x, list(self.generator.interface.keys()))
                        function = selector  # 让后面的错误处理统一报
                except Exception:
                    arguments.append(tok)
            else:
                arguments.append(tok)
        try:
            # # --- TX-EXEC LOG START (pre-encode) ---
            # try:
            #     # 解析到的函数/选择器打印
            #     _sel_hex = None
            #     if selector is not None:
            #         _sel_hex = "0x" + selector if not str(selector).startswith("0x") else str(selector)
            #     _from = (self.chromosome[chromosome_index].get("account")
            #             or self.chromosome[chromosome_index].get("from") or "")
            #     _to   = (self.chromosome[chromosome_index].get("to")
            #             or self.chromosome[chromosome_index].get("contract") or "")
            #     _seed_id = self.chromosome[chromosome_index].get("__seed_id__", "")
            #     _origin  = self.chromosome[chromosome_index].get("__origin__", "")
            #     self.logger.info(
            #         "[TX-BUILD]%s idx=%d from=%s to=%s function=%s selector=%s args=%s",
            #         " [seed-origin]" if _origin=="seed" else "",
            #         chromosome_index, str(_from), str(_to),
            #         str(function), str(_sel_hex),
            #         repr(arguments)
            #     )
            # except Exception as _e:
            #     self.logger.warning("[TX-BUILD] log-fail: %s", _e)
            # # --- TX-EXEC LOG END (pre-encode) ---
            if function == "constructor" and "constructor" not in self.generator.interface:
                # 友好错误提示（而不是 KeyError）
                raise RuntimeError(
                    "Constructor arg types missing in interface. "
                    "If your seeds include a constructor step, do NOT delete interface['constructor']."
                )
            argument_types = [argument_type.replace(" storage", "").replace(" memory", "").replace(" calldata", "")
                            for argument_type in self.generator.interface[function]]
            arguments = [
                normalize_abi_argument(argument_type, argument, accounts=getattr(self.generator, "accounts", []))
                for argument_type, argument in zip(argument_types, arguments)
            ]
            self.chromosome[chromosome_index]["arguments"] = (
                [self.chromosome[chromosome_index]["arguments"][0]] + arguments
            )
            data += encode(argument_types, arguments).hex()
        except Exception as e:
            # # --- DEBUG extra ---
            # try:
            #     keys = list(self.generator.interface.keys())[:15]
            #     self.logger.error("Interface keys(sample=%d): %s", len(keys), keys)
            #     if function not in self.generator.interface:
            #         self.logger.error("Function key %r not in interface. Did you pass selector or name?", function)
            # except Exception as _e:
            #     self.logger.error("Failed to print interface keys: %s", _e)
            # # --- DEBUG extra end ---
            self.logger.error("%s", e)
            if function in self.generator.interface:
                self.logger.error("%s: %s -> %s", function, self.generator.interface[function], arguments)
            else:
                self.logger.error("Function '%s' not found in interface. Args -> %s", function, arguments)
            sys.exit(-6)
        return data
 
