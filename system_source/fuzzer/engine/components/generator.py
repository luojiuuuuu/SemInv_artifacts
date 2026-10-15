#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import random
import collections

from ...utils import settings
from ...utils.utils import *

from typing import List, Dict, Any, Optional
try:
    from eth_abi import encode
except ImportError:
    from eth_abi import encode_abi as encode
from eth_utils import keccak
import re
import logging
logger = logging.getLogger(__name__)

UINT_MAX = {
    1: int("0xff", 16),
    2: int("0xffff", 16),
    3: int("0xffffff", 16),
    4: int("0xffffffff", 16),
    5: int("0xffffffffff", 16),
    6: int("0xffffffffffff", 16),
    7: int("0xffffffffffffff", 16),
    8: int("0xffffffffffffffff", 16),
    9: int("0xffffffffffffffffff", 16),
    10: int("0xffffffffffffffffffff", 16),
    11: int("0xffffffffffffffffffffff", 16),
    12: int("0xffffffffffffffffffffffff", 16),
    13: int("0xffffffffffffffffffffffffff", 16),
    14: int("0xffffffffffffffffffffffffffff", 16),
    15: int("0xffffffffffffffffffffffffffffff", 16),
    16: int("0xffffffffffffffffffffffffffffffff", 16),
    17: int("0xffffffffffffffffffffffffffffffffff", 16),
    18: int("0xffffffffffffffffffffffffffffffffffff", 16),
    19: int("0xffffffffffffffffffffffffffffffffffffff", 16),
    20: int("0xffffffffffffffffffffffffffffffffffffffff", 16),
    21: int("0xffffffffffffffffffffffffffffffffffffffffff", 16),
    22: int("0xffffffffffffffffffffffffffffffffffffffffffff", 16),
    23: int("0xffffffffffffffffffffffffffffffffffffffffffffff", 16),
    24: int("0xffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    25: int("0xffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    26: int("0xffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    27: int("0xffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    28: int("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    29: int("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    30: int("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    31: int("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    32: int("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16)
}

INT_MAX = {
    1: int("0x7f", 16),
    2: int("0x7fff", 16),
    3: int("0x7fffff", 16),
    4: int("0x7fffffff", 16),
    5: int("0x7fffffffff", 16),
    6: int("0x7fffffffffff", 16),
    7: int("0x7fffffffffffff", 16),
    8: int("0x7fffffffffffffff", 16),
    9: int("0x7fffffffffffffffff", 16),
    10: int("0x7fffffffffffffffffff", 16),
    11: int("0x7fffffffffffffffffffff", 16),
    12: int("0x7fffffffffffffffffffffff", 16),
    13: int("0x7fffffffffffffffffffffffff", 16),
    14: int("0x7fffffffffffffffffffffffffff", 16),
    15: int("0x7fffffffffffffffffffffffffffff", 16),
    16: int("0x7fffffffffffffffffffffffffffffff", 16),
    17: int("0x7fffffffffffffffffffffffffffffffff", 16),
    18: int("0x7fffffffffffffffffffffffffffffffffff", 16),
    19: int("0x7fffffffffffffffffffffffffffffffffffff", 16),
    20: int("0x7fffffffffffffffffffffffffffffffffffffff", 16),
    21: int("0x7fffffffffffffffffffffffffffffffffffffffff", 16),
    22: int("0x7fffffffffffffffffffffffffffffffffffffffffff", 16),
    23: int("0x7fffffffffffffffffffffffffffffffffffffffffffff", 16),
    24: int("0x7fffffffffffffffffffffffffffffffffffffffffffffff", 16),
    25: int("0x7fffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    26: int("0x7fffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    27: int("0x7fffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    28: int("0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    29: int("0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    30: int("0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    31: int("0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16),
    32: int("0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16)
}

INT_MIN = {
    1: int("-0x80", 16),
    2: int("-0x8000", 16),
    3: int("-0x800000", 16),
    4: int("-0x80000000", 16),
    5: int("-0x8000000000", 16),
    6: int("-0x800000000000", 16),
    7: int("-0x80000000000000", 16),
    8: int("-0x8000000000000000", 16),
    9: int("-0x800000000000000000", 16),
    10: int("-0x80000000000000000000", 16),
    11: int("-0x8000000000000000000000", 16),
    12: int("-0x800000000000000000000000", 16),
    13: int("-0x80000000000000000000000000", 16),
    14: int("-0x8000000000000000000000000000", 16),
    15: int("-0x800000000000000000000000000000", 16),
    16: int("-0x80000000000000000000000000000000", 16),
    17: int("-0x8000000000000000000000000000000000", 16),
    18: int("-0x800000000000000000000000000000000000", 16),
    19: int("-0x80000000000000000000000000000000000000", 16),
    20: int("-0x8000000000000000000000000000000000000000", 16),
    21: int("-0x800000000000000000000000000000000000000000", 16),
    22: int("-0x80000000000000000000000000000000000000000000", 16),
    23: int("-0x8000000000000000000000000000000000000000000000", 16),
    24: int("-0x800000000000000000000000000000000000000000000000", 16),
    25: int("-0x80000000000000000000000000000000000000000000000000", 16),
    26: int("-0x8000000000000000000000000000000000000000000000000000", 16),
    27: int("-0x800000000000000000000000000000000000000000000000000000", 16),
    28: int("-0x80000000000000000000000000000000000000000000000000000000", 16),
    29: int("-0x8000000000000000000000000000000000000000000000000000000000", 16),
    30: int("-0x800000000000000000000000000000000000000000000000000000000000", 16),
    31: int("-0x80000000000000000000000000000000000000000000000000000000000000", 16),
    32: int("-0x8000000000000000000000000000000000000000000000000000000000000000", 16)
}

MAX_RING_BUFFER_LENGTH = 10
MAX_ARRAY_LENGTH = 2


def _clean_abi_type(abi_type):
    return str(abi_type or "").replace(" storage", "").replace(" memory", "").replace(" calldata", "").strip()


def _array_suffixes(abi_type):
    return re.findall(r"\[(.*?)\]", _clean_abi_type(abi_type))


def _base_abi_type(abi_type):
    return re.sub(r"\[.*?\]", "", _clean_abi_type(abi_type))


def _zero_argument_for_type(abi_type, accounts=None):
    abi_type = _clean_abi_type(abi_type)
    suffixes = _array_suffixes(abi_type)
    if suffixes:
        base = _base_abi_type(abi_type)
        dims = [int(s) if s else 0 for s in suffixes]

        def build(depth):
            if depth >= len(dims):
                return _zero_argument_for_type(base, accounts=accounts)
            return [build(depth + 1) for _ in range(max(0, dims[depth]))]

        return build(0)
    if abi_type == "bool":
        return False
    if abi_type.startswith("int") or abi_type.startswith("uint"):
        return 0
    if abi_type.startswith("address"):
        return (accounts or ["0x0000000000000000000000000000000000000000"])[0]
    if abi_type == "string":
        return ""
    if abi_type.startswith("bytes"):
        return bytearray()
    return 0


def normalize_abi_argument(abi_type, value, accounts=None):
    abi_type = _clean_abi_type(abi_type)
    suffixes = _array_suffixes(abi_type)
    if not suffixes:
        return value

    base = _base_abi_type(abi_type)
    dims = [int(s) if s else None for s in suffixes]

    def normalize_array(current, depth):
        if depth >= len(dims):
            return normalize_abi_argument(base, current, accounts=accounts)
        target_len = dims[depth]
        items = current if isinstance(current, list) else []
        if target_len is None:
            return [normalize_array(item, depth + 1) for item in items]
        normalized = [normalize_array(item, depth + 1) for item in items[:target_len]]
        while len(normalized) < target_len:
            normalized.append(_zero_argument_for_type("".join([base] + [f"[{s or ''}]" for s in suffixes[depth + 1:]]), accounts=accounts))
        return normalized

    return normalize_array(value, 0)

class CircularSet:
    def __init__(self, set_size=MAX_RING_BUFFER_LENGTH, initial_set=None):
        self._q = collections.deque(maxlen=set_size)
        if initial_set:
            self._q.extend(initial_set)

    @property
    def empty(self):
        return len(self._q) == 0

    def add(self, value):
        if value not in self._q:
            self._q.append(value)
        else:
            self._q.remove(value)
            self._q.append(value)

    def head_and_rotate(self):
        value = self._q[-1]
        self._q.rotate(1)
        return value

    def discard(self, value):
        if value in self._q:
            self._q.remove(value)

    def __repr__(self):
        return repr(self._q)


class Generator:
    # def __init__(self, interface, bytecode, accounts, contract):
    # --------------------ADD-------------------- #
    def __init__(self, interface, bytecode, accounts, contract,
                 custom_seeds: Optional[List[List[Dict[str, Any]]]] = None,
                 seed_strategy: str = "prepend"):
        self.logger = initialize_logger("Generator")
        self.interface = interface
        self.bytecode = bytecode
        self.accounts = accounts
        self.contract = contract

        # Pools
        self.function_circular_buffer = CircularSet(set_size=len(self.interface), initial_set=set(self.interface))
        self.accounts_pool = {}
        self.amounts_pool = {}
        self.arguments_pool = {}
        self.timestamp_pool = {}
        self.blocknumber_pool = {}
        self.balance_pool = {}
        self.callresult_pool = {}
        self.gaslimit_pool = {}
        self.extcodesize_pool = {}
        self.returndatasize_pool = {}
        self.argument_array_sizes_pool = {}
        self.strings_pool = CircularSet()
        self.bytes_pool = CircularSet()

        # --------------------ADD-------------------- #
        self.seed_strategy = seed_strategy
        self._seed_bank: List[List[Dict[str, Any]]] = []
        if custom_seeds:
            if not isinstance(custom_seeds, list):
                raise ValueError("custom_seeds must be a list")
            self._seed_bank = [list(seq) for seq in custom_seeds]  # 先原样保存

    import re

    def _default_probe_argument(self, abi_type):
        return _zero_argument_for_type(abi_type, accounts=self.accounts)

    def _zero_probe_argument(self, abi_type):
        abi_type = _clean_abi_type(abi_type)
        if abi_type.startswith("address"):
            return "0x0000000000000000000000000000000000000000"
        return self._default_probe_argument(abi_type)

    def _probe_gene(self, function, arguments, account=None, amount=0, gaslimit=None,
                    data=None, probe_kind="guard"):
        if gaslimit is None:
            gaslimit = settings.GAS_LIMIT
        gene = {
            "account": account or (self.accounts[0] if self.accounts else None),
            "contract": self.bytecode if function == "constructor" else self.contract,
            "amount": amount,
            "arguments": arguments,
            "blocknumber": self.get_random_blocknumber(function),
            "timestamp": self.get_random_timestamp(function),
            "gaslimit": gaslimit,
            "call_return": dict(),
            "extcodesize": dict(),
            "returndatasize": dict(),
            "__origin__": "coverage_probe",
            "__coverage_probe__": probe_kind,
        }
        if data is not None:
            gene["data"] = data
        return gene

    def _function_probe_args(self, function):
        return [function] + [
            self._default_probe_argument(arg_type)
            for arg_type in self.interface.get(function, [])
        ]

    def _short_calldata_probe_sequences(self, limit_remaining=None):
        probes = []
        if limit_remaining is not None and limit_remaining <= 0:
            return probes

        primary = self.accounts[0] if self.accounts else "0x0000000000000000000000000000000000000000"
        for function, arg_types in self.interface.items():
            if function in ("constructor", "fallback", "receive"):
                continue
            clean_types = [
                str(arg_type or "").replace(" storage", "").replace(" memory", "").replace(" calldata", "")
                for arg_type in (arg_types or [])
            ]
            if not any(arg_type.startswith("address") for arg_type in clean_types):
                continue

            args = self._function_probe_args(function)
            for value_index, arg_type in enumerate(clean_types):
                if arg_type.startswith("uint") or arg_type.startswith("int"):
                    args[value_index + 1] = 1
            try:
                selector = self._canonicalize_function_token(function)
                selector_hex = str(selector or function)
                selector_hex = selector_hex[2:] if selector_hex.startswith("0x") else selector_hex
                encoded_args = encode(clean_types, args[1:]).hex()
            except Exception as exc:
                logger.debug("Failed to build short calldata probe for %s: %s", function, exc)
                continue

            for arg_index, arg_type in enumerate(clean_types):
                if not arg_type.startswith("address"):
                    continue
                slot_start = arg_index * 64
                slot_end = slot_start + 64
                if len(encoded_args) < slot_end:
                    continue
                # Drop 1..12 bytes from the address slot itself and keep later
                # ABI slots. For address,uint this models the classic short
                # address attack where the amount slot shifts left.
                for missing_bytes in range(1, 13):
                    if limit_remaining is not None and len(probes) >= limit_remaining:
                        return probes
                    drop_nibbles = missing_bytes * 2
                    if drop_nibbles >= 64:
                        continue
                    short_args = encoded_args[:slot_end - drop_nibbles] + encoded_args[slot_end:]
                    short_data = selector_hex + short_args
                    probes.append([self._probe_gene(
                        function,
                        list(args),
                        account=primary,
                        amount=0,
                        data=short_data,
                        probe_kind="short_calldata_probe_arg%d_%d_bytes" % (arg_index, missing_bytes),
                    )])
        return probes

    def generate_guard_probe_sequences(self):
        probes = []
        if not self.interface:
            return probes

        zero_address = "0x0000000000000000000000000000000000000000"
        primary = self.accounts[0] if self.accounts else zero_address
        non_owner = None
        for account in self.accounts:
            if str(account).lower() != str(primary).lower():
                non_owner = account
                break
        non_owner = non_owner or primary

        for function, arg_types in self.interface.items():
            if function == "constructor":
                continue

            if function == "fallback":
                probes.append([self._probe_gene(
                    function, ["fallback"], account=primary, amount=0,
                    data="", probe_kind="fallback_empty_calldata"
                )])
                probes.append([self._probe_gene(
                    function, ["fallback"], account=primary, amount=0,
                    data="ffffffff", probe_kind="fallback_random_calldata"
                )])
                probes.append([self._probe_gene(
                    function, ["fallback"], account=primary, amount=1,
                    probe_kind="value_guard"
                )])
                continue

            args = self._function_probe_args(function)
            probes.append([self._probe_gene(
                function, list(args), account=primary, amount=1,
                probe_kind="value_guard"
            )])
            probes.append([self._probe_gene(
                function, list(args), account=primary, amount=0,
                gaslimit=50000, probe_kind="low_gas_guard"
            )])
            probes.append([self._probe_gene(
                function, list(args), account=non_owner, amount=0,
                probe_kind="non_owner_guard"
            )])

            for index, arg_type in enumerate(arg_types):
                if str(arg_type).replace(" storage", "").replace(" memory", "").startswith("address"):
                    zargs = list(args)
                    zargs[index + 1] = self._zero_probe_argument(arg_type)
                    probes.append([self._probe_gene(
                        function, zargs, account=primary, amount=0,
                        probe_kind="zero_address_guard"
                    )])

        if "constructor" in self.interface and self.bytecode:
            ctor_args = ["constructor"] + [
                self._default_probe_argument(arg_type)
                for arg_type in self.interface.get("constructor", [])
            ]
            probes.append([self._probe_gene(
                "constructor", ctor_args, account=primary, amount=0,
                probe_kind="constructor_deployment"
            )])
            probes.append([self._probe_gene(
                "constructor", list(ctor_args), account=primary, amount=1,
                probe_kind="constructor_value_guard"
            )])

        return probes

    def _numeric_boundary_values(self, abi_type):
        abi_type = str(abi_type or "").replace(" storage", "").replace(" memory", "")
        if not (abi_type.startswith("uint") or abi_type.startswith("int")):
            return []
        if abi_type.startswith("uint"):
            bits_text = abi_type.replace("uint", "").split("[")[0]
            bits = int(bits_text) if bits_text else 256
            max_value = (1 << bits) - 1
            values = [0, 1, 2, 10, (1 << 128) - 1, 1 << 128, (1 << 128) + 1, max_value - 1, max_value]
            return [v for v in values if 0 <= v <= max_value]
        bits_text = abi_type.replace("int", "").split("[")[0]
        bits = int(bits_text) if bits_text else 256
        lo = -(1 << (bits - 1))
        hi = (1 << (bits - 1)) - 1
        return [lo, lo + 1, -1, 0, 1, hi - 1, hi]

    def _boundary_probe_args(self, function, argument_index, value):
        args = self._function_probe_args(function)
        if argument_index + 1 < len(args):
            args[argument_index + 1] = value
        return args

    def generate_vulnerability_probe_sequences(self):
        if not getattr(self, "vulnerability_hints_enabled", False):
            return []
        limit = int(getattr(self, "vulnerability_hint_static_probe_limit", 32) or 0)
        if limit <= 0:
            return []

        probes = []
        seen = set()
        primary = self.accounts[0] if self.accounts else "0x0000000000000000000000000000000000000000"

        def add_probe(seq):
            if len(probes) >= limit:
                return
            key = str(seq)
            if key in seen:
                return
            seen.add(key)
            probes.append(seq)

        targets = getattr(self, "vulnerability_uir_targets", {}) or {}
        relations = targets.get("relation_targets", []) if isinstance(targets, dict) else []
        for seq in self._short_calldata_probe_sequences(limit_remaining=limit - len(probes)):
            add_probe(seq)
            if len(probes) >= limit:
                break

        for relation in relations or []:
            if len(probes) >= limit:
                break
            left = relation.get("from_selector")
            right = relation.get("to_selector")
            left = self._canonicalize_function_token(left) if left else None
            right = self._canonicalize_function_token(right) if right else None
            if left not in self.interface or right not in self.interface:
                continue
            right_gene = self._probe_gene(
                right, self._function_probe_args(right), account=primary, amount=0,
                probe_kind="relation_state_setup"
            )
            for index, arg_type in enumerate(self.interface.get(left, []) or []):
                values = [value for value in self._numeric_boundary_values(arg_type) if value >= (1 << 128)]
                if not values:
                    continue
                for value in values[:3]:
                    writer_args = self._boundary_probe_args(left, index, value)
                    writer_gene = self._probe_gene(
                        left, writer_args, account=primary, amount=0,
                        probe_kind="relation_numeric_boundary"
                    )
                    add_probe([dict(right_gene), writer_gene])
                    if len(probes) >= limit:
                        break
                break

        numeric_writer_sequences = []
        for function, arg_types in self.interface.items():
            if function in ("constructor", "fallback"):
                continue
            for index, arg_type in enumerate(arg_types or []):
                for value in self._numeric_boundary_values(arg_type):
                    args = self._boundary_probe_args(function, index, value)
                    gene = self._probe_gene(
                        function, args, account=primary, amount=0,
                        probe_kind="numeric_boundary"
                    )
                    add_probe([gene])
                    if index == 0 and value >= (1 << 128):
                        numeric_writer_sequences.append(gene)
                    if len(probes) >= limit:
                        break
                if len(probes) >= limit:
                    break

        for relation in relations or []:
            if len(probes) >= limit:
                break
            left = relation.get("from_selector")
            right = relation.get("to_selector")
            left = self._canonicalize_function_token(left) if left else None
            right = self._canonicalize_function_token(right) if right else None
            if left not in self.interface or right not in self.interface:
                continue
            left_gene = self._probe_gene(left, self._function_probe_args(left), account=primary, amount=0, probe_kind="relation_left")
            right_gene = self._probe_gene(right, self._function_probe_args(right), account=primary, amount=0, probe_kind="relation_right")
            add_probe([left_gene, right_gene])
            add_probe([right_gene, left_gene])
            for writer_gene in numeric_writer_sequences[:2]:
                if writer_gene.get("arguments", [None])[0] == left:
                    add_probe([right_gene, dict(writer_gene)])
                elif writer_gene.get("arguments", [None])[0] == right:
                    add_probe([left_gene, dict(writer_gene)])

        return probes

    def _has_valid_contract_address(self) -> bool:
        ADDR_RE = re.compile(r"^0x[0-9a-fA-F]{40}$")
        return isinstance(self.contract, str) and ADDR_RE.match(self.contract) is not None

    def _coerce_seed_tx(self, tx: Dict[str, Any], is_constructor_step: bool) -> Dict[str, Any]:
        
        ADDR_RE = re.compile(r"^0x[0-9a-fA-F]{40}$")
        t = dict(tx)

        if is_constructor_step:
            t["contract"] = self.bytecode
            args = t.get("arguments", [])
            if not isinstance(args, list): args=[]
            if not args or args[0]!="constructor":
                t["arguments"] = ["constructor"] + args
        else:
            c = t.get("contract")
            # 常见占位符或非法地址 → 用 self.contract 兜底
            if (not c) or (isinstance(c, str) and c in ("0xCONTRACT_ADDR_PLACEHOLDER", "BYTECODE_PLACEHOLDER")) \
            or (isinstance(c, str) and not ADDR_RE.match(c)):
                t["contract"] = self.contract
            else:
                t["contract"] = c

        t["account"] = t.get("account") or (self.accounts[0] if self.accounts else None)
        if not t["account"]:
            raise ValueError("Seed tx missing 'account' and no accounts available")
        t["amount"] = t.get("amount", 0)
        t["gaslimit"] = t.get("gaslimit", 6_000_000)
        t["timestamp"] = t.get("timestamp", 0)
        t["blocknumber"] = t.get("blocknumber", 0)
        t.setdefault("returndatasize", dict())
        t.setdefault("call_return", dict())
        t.setdefault("extcodesize", dict())

        if not isinstance(t.get("arguments"), list) or not t["arguments"]:
            raise ValueError("Seed tx must contain 'arguments' with function token first")
        args = t.get("arguments", [])
        if not isinstance(args, list):
            args = []
        if not args:
            raise ValueError("Seed tx must contain 'arguments' with function token first")

        # constructor/fallback 原样；普通函数则把 token 规范成 interface 的键
        head = args[0]
        if head == "constructor":
            # constructor 情况已在函数前半段处理，这里只确保格式
            pass
        elif head == "fallback":
            pass
        else:
            args[0] = self._canonicalize_function_token(head)

        t["arguments"] = args
        # Value-cap rollback hook: keep seed-provided value unchanged while
        # testing the original SemInv amount behavior.
        # t["amount"] = self._cap_amount_for_sender(
        #     args[0],
        #     t.get("amount", 0),
        #     account=t.get("account"),
        #     gaslimit=t.get("gaslimit"),
        # )
        return t

    def _normalize_seed_seq(self, raw_seq: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        # 支持“高层友好 dict 被外层包成 [dict]”的情况（见 main.load_custom_seeds）
        if len(raw_seq)==1 and isinstance(raw_seq[0], dict) and ("steps" in raw_seq[0] or "constructor" in raw_seq[0]):
            hd = raw_seq[0]
            seq=[]
            if "constructor" in hd and hd["constructor"]:
                c=hd["constructor"]
                seq.append({
                    "account": c.get("from"), "contract": None, "amount": c.get("value",0),
                    "arguments": ["constructor"] + list(c.get("args", [])),
                    "blocknumber": 0, "timestamp": 0, "gaslimit": c.get("gas", 6_000_000),
                    "returndatasize": {}
                })
            for st in hd.get("steps", []):
                func = st.get("func")
                if not func: raise ValueError("High-level step missing 'func'")
                seq.append({
                    "account": st.get("from"), "contract": self.contract, "amount": st.get("value",0),
                    "arguments": [func] + list(st.get("args", [])),
                    "blocknumber": 0, "timestamp": 0, "gaslimit": st.get("gas", 6_000_000),
                    "returndatasize": {}
                })
            if not seq:
                raise ValueError("High-level seed has no constructor and no steps")
            raw_seq = seq

        if not isinstance(raw_seq, list) or len(raw_seq) < 1:
            raise ValueError("Each seed sequence must have >=1 tx")
        norm=[]
        for i,tx in enumerate(raw_seq):
            if not isinstance(tx, dict):
                raise ValueError("Seed tx must be a dict")
            args = tx.get("arguments", [])
            is_ctor = (i==0 and isinstance(args, list) and args and args[0]=="constructor")
            norm.append(self._coerce_seed_tx(tx, is_constructor_step=is_ctor))
            
            # # --- SEED-NORM LOG START ---
            # try:
            #     gene = norm[-1]
            #     # 给序列打标（若上游没打）
            #     if isinstance(raw_seq, list) and raw_seq and "__seed_id__" in raw_seq[0]:
            #         gene.setdefault("__seed_id__", raw_seq[0]["__seed_id__"])
            #         gene.setdefault("__origin__", "seed")
            #     sel = gene.get("function") or gene.get("selector") or ""
            #     if isinstance(sel, bytes):
            #         sel_hex = "0x" + sel.hex()
            #     else:
            #         sel_hex = sel if str(sel).startswith("0x") else (f"0x{sel}" if sel else "")
            #     from_addr = gene.get("account") or gene.get("from") or ""
            #     to_addr   = gene.get("to") or gene.get("contract") or ""
            #     logger.info(
            #         "[SEED-NORM][seed=%s][step=%d] from=%s to=%s selector=%s args=%s",
            #         str(gene.get("__seed_id__", "?")), i, str(from_addr), str(to_addr),
            #         sel_hex, repr(gene.get("arguments", [])[1:] if gene.get("arguments") else [])
            #     )
            # except Exception as _e:
            #     logger.warning("[SEED-NORM] log-fail: %s", _e)
            # # --- SEED-NORM LOG END ---

        return norm
    
    def _canonicalize_function_token(self, tok: str) -> str:
        """
        将传入的函数 token 规范成 self.interface 的键：
        - 已是键：直接返回
        - 8位hex（无0x）：若 '0x'+hex 在键中，用 '0x'+hex；否则若 hex 在键中，用 hex
        - 0x + 8位hex：若在键中，用它
        - 完整签名 name(type,...): 计算 keccak 前4字节，优先 '0x'+sel，其次 sel
        - 其他：原样返回（最终会在 individual 里再尝试编码，若失败会报错）
        """
        if not isinstance(tok, str):
            return tok

        tok_stripped = tok.strip()
        # 已是 interface 的键
        if tok_stripped in self.interface:
            return tok_stripped

        # 0x + 8 hex
        if re.fullmatch(r"0x[0-9a-fA-F]{8}", tok_stripped):
            return tok_stripped if tok_stripped in self.interface else tok_stripped

        # 8 hex（无 0x）
        if re.fullmatch(r"[0-9a-fA-F]{8}", tok_stripped):
            with0x = "0x" + tok_stripped
            if with0x in self.interface:
                return with0x
            if tok_stripped in self.interface:
                return tok_stripped
            return with0x  # 偏向带 0x

        # 完整签名
        if "(" in tok_stripped and tok_stripped.endswith(")"):
            sel = keccak(text=tok_stripped)[:4].hex()
            with0x = "0x" + sel
            if with0x in self.interface:
                return with0x
            if sel in self.interface:
                return sel
            return with0x

        return tok_stripped


    def generate_random_individual(self):
        individual = []

        # if "constructor" in self.interface and self.bytecode:
        #     arguments = ["constructor"]
        #     for index in range(len(self.interface["constructor"])):
        #         arguments.append(self.get_random_argument(self.interface["constructor"][index], "constructor", index))
        #     individual.append({
        #         "account": self.get_random_account("constructor"),
        #         "contract": self.bytecode,
        #         "amount": self.get_random_amount("constructor"),
        #         "arguments": arguments,
        #         "blocknumber": self.get_random_blocknumber("constructor"),
        #         "timestamp": self.get_random_timestamp("constructor"),
        #         "gaslimit": self.get_random_gaslimit("constructor"),
        #         "returndatasize": dict()
        #     })

        if "constructor" in self.interface and self.bytecode and not self._has_valid_contract_address():
            arguments = ["constructor"]
            for index in range(len(self.interface["constructor"])):
                arguments.append(self.get_random_argument(self.interface["constructor"][index], "constructor", index))
            account = self.get_random_account("constructor")
            gaslimit = self.get_random_gaslimit("constructor")
            individual.append({
                "account": account,
                "contract": self.bytecode,          # 注意：individual.decode 里会把 constructor 的 to 改成 None
                "amount": self.get_random_amount("constructor", account=account, gaslimit=gaslimit),
                "arguments": arguments,
                "blocknumber": self.get_random_blocknumber("constructor"),
                "timestamp": self.get_random_timestamp("constructor"),
                "gaslimit": gaslimit,
                "returndatasize": dict()
            })

        function, argument_types = self.get_random_function_with_argument_types()
        arguments = [function]
        for index in range(len(argument_types)):
            arguments.append(self.get_random_argument(argument_types[index], function, index))
        account = self.get_random_account(function)
        gaslimit = self.get_random_gaslimit(function)
        individual.append({
            "account": account,
            "contract": self.contract,
            "amount": self.get_random_amount(function, account=account, gaslimit=gaslimit),
            "arguments": arguments,
            "blocknumber": self.get_random_blocknumber(function),
            "timestamp": self.get_random_timestamp(function),
            "gaslimit": gaslimit,
            "call_return": dict(),
            "extcodesize": dict(),
            "returndatasize": dict()
        })

        address, call_return_value = self.get_random_callresult_and_address(function)
        individual[-1]["call_return"] = {address: call_return_value}

        address, extcodesize_value = self.get_random_extcodesize_and_address(function)
        individual[-1]["extcodesize"] = {address: extcodesize_value}

        address, value = self.get_random_returndatasize_and_address(function)
        individual[-1]["returndatasize"] = {address: value}

        return individual

    def generate_random_input(self):
        input = {}

        function, argument_types = self.get_random_function_with_argument_types()
        arguments = [function]
        for index in range(len(argument_types)):
            arguments.append(self.get_random_argument(argument_types[index], function, index))
        account = self.get_random_account(function)
        gaslimit = self.get_random_gaslimit(function)
        input = {
            "account": account,
            "contract": self.contract,
            "amount": self.get_random_amount(function, account=account, gaslimit=gaslimit),
            "arguments": arguments,
            "blocknumber": self.get_random_blocknumber(function),
            "timestamp": self.get_random_timestamp(function),
            "gaslimit": gaslimit,
            "returndatasize": dict()
        }

        address, value = self.get_random_returndatasize_and_address(function)
        input["returndatasize"] = {address: value}

        return input

    def get_random_function_with_argument_types(self):
        function_hash = self.function_circular_buffer.head_and_rotate()
        if function_hash == "constructor":
            function_hash = self.function_circular_buffer.head_and_rotate()
        return function_hash, self.interface[function_hash]

    #
    # TIMESTAMP
    #

    def add_timestamp_to_pool(self, function, timestamp):
        if not function in self.timestamp_pool:
            self.timestamp_pool[function] = CircularSet()
        self.timestamp_pool[function].add(timestamp)

    def get_random_timestamp(self, function):
        if function in self.timestamp_pool:
            return self.timestamp_pool[function].head_and_rotate()
        return None

    def remove_timestamp_from_pool(self, function, timestamp):
        if function in self.timestamp_pool:
            self.timestamp_pool[function].discard(timestamp)
            if self.timestamp_pool[function].empty:
                del self.timestamp_pool[function]

    #
    # BLOCKNUMBER
    #

    def add_blocknumber_to_pool(self, function, blocknumber):
        if not function in self.blocknumber_pool:
            self.blocknumber_pool[function] = CircularSet()
        self.blocknumber_pool[function].add(blocknumber)

    def get_random_blocknumber(self, function):
        if function in self.blocknumber_pool:
            return self.blocknumber_pool[function].head_and_rotate()
        return None

    def remove_blocknumber_from_pool(self, function, blocknumber):
        if function in self.blocknumber_pool:
            self.blocknumber_pool[function].discard(blocknumber)
            if self.blocknumber_pool[function].empty:
                del self.blocknumber_pool[function]

    #
    # BALANCE
    #

    def add_balance_to_pool(self, function, balance):
        if not function in self.balance_pool:
            self.balance_pool[function] = CircularSet()
        self.balance_pool[function].add(balance)

    def get_random_balance(self, function):
        if function in self.balance_pool:
            return self.balance_pool[function].head_and_rotate()
        return None

    #
    # CALL RESULT
    #

    def add_callresult_to_pool(self, function, address, result):
        if not function in self.callresult_pool:
            self.callresult_pool[function] = dict()
        if not address in self.callresult_pool[function]:
            self.callresult_pool[function][address] = CircularSet()
        self.callresult_pool[function][address].add(result)

    def get_random_callresult_and_address(self, function):
        if function in self.callresult_pool:
            address = random.choice(list(self.callresult_pool[function].keys()))
            value = self.callresult_pool[function][address].head_and_rotate()
            return address, value
        return None, None

    def get_random_callresult(self, function, address):
        if function in self.callresult_pool:
            if address in self.callresult_pool[function]:
                value = self.callresult_pool[function][address].head_and_rotate()
                return value
        return None

    def remove_callresult_from_pool(self, function, address, result):
        if function in self.callresult_pool and address in self.callresult_pool[function]:
            self.callresult_pool[function][address].discard(result)
            if self.callresult_pool[function][address].empty:
                del self.callresult_pool[function][address]
                if len(self.callresult_pool[function]) == 0:
                    del self.callresult_pool[function]

    #
    # EXTCODESIZE
    #

    def add_extcodesize_to_pool(self, function, address, size):
        if not function in self.extcodesize_pool:
            self.extcodesize_pool[function] = dict()
        if not address in self.extcodesize_pool[function]:
            self.extcodesize_pool[function][address] = CircularSet()
        self.extcodesize_pool[function][address].add(size)

    def get_random_extcodesize_and_address(self, function):
        if function in self.extcodesize_pool:
            address = random.choice(list(self.extcodesize_pool[function].keys()))
            return address, self.extcodesize_pool[function][address].head_and_rotate()
        return None, None

    def get_random_extcodesize(self, function, address):
        if function in self.extcodesize_pool:
            if address in self.extcodesize_pool[function]:
                return self.extcodesize_pool[function][address].head_and_rotate()
        return None

    def remove_extcodesize_from_pool(self, function, address, size):
        if function in self.extcodesize_pool and address in self.extcodesize_pool[function]:
            self.extcodesize_pool[function][address].discard(size)
            if self.extcodesize_pool[function][address].empty:
                del self.extcodesize_pool[function][address]
                if len(self.extcodesize_pool[function]) == 0:
                    del self.extcodesize_pool[function]

    #
    # RETURNDATASIZE
    #

    def add_returndatasize_to_pool(self, function, address, size):
        if not function in self.returndatasize_pool:
            self.returndatasize_pool[function] = dict()
        if not address in self.returndatasize_pool[function]:
            self.returndatasize_pool[function][address] = CircularSet()
        self.returndatasize_pool[function][address].add(size)

    def get_random_returndatasize_and_address(self, function):
        if function in self.returndatasize_pool:
            address = random.choice(list(self.returndatasize_pool[function].keys()))
            return address, self.returndatasize_pool[function][address].head_and_rotate()
        return None, None

    def get_random_returndatasize(self, function, address):
        if function in self.returndatasize_pool:
            if address in self.returndatasize_pool[function]:
                return self.returndatasize_pool[function][address].head_and_rotate()
        return None

    def remove_returndatasize_from_pool(self, function, address, size):
        if function in self.returndatasize_pool and address in self.returndatasize_pool[function]:
            self.returndatasize_pool[function][address].discard(size)
            if self.returndatasize_pool[function][address].empty:
                del self.returndatasize_pool[function][address]
                if len(self.returndatasize_pool[function]) == 0:
                    del self.returndatasize_pool[function]

    #
    # GASLIMIT
    #

    def add_gaslimit_to_pool(self, function, gaslimit):
        if not function in self.gaslimit_pool:
            self.gaslimit_pool[function] = CircularSet()
        self.gaslimit_pool[function].add(gaslimit)

    def remove_gaslimit_from_pool(self, function, gaslimit):
        if function in self.gaslimit_pool:
            self.gaslimit_pool[function].discard(gaslimit)
            if self.gaslimit_pool[function].empty:
                del self.gaslimit_pool[function]

    def clear_gaslimits_in_pool(self, function):
        if function in self.gaslimit_pool:
            del self.gaslimit_pool[function]

    def get_random_gaslimit(self, function):
        if function in self.gaslimit_pool:
            return self.gaslimit_pool[function].head_and_rotate()
        return settings.GAS_LIMIT

    #
    # ACCOUNTS
    #

    def add_account_to_pool(self, function, account):
        if not function in self.accounts_pool:
            self.accounts_pool[function] = CircularSet()
        self.accounts_pool[function].add(account)

    def remove_account_from_pool(self, function, account):
        if function in self.accounts_pool:
            self.accounts_pool[function].discard(account)
            if self.accounts_pool[function].empty:
                del self.accounts_pool[function]

    def clear_accounts_in_pool(self, function):
        if function in self.accounts_pool:
            self.accounts_pool[function] = CircularSet()

    def get_random_account_from_pool(self, function):
        return self.accounts_pool[function].head_and_rotate()

    def get_random_account(self, function):
        if function in self.accounts_pool:
            return self.get_random_account_from_pool(function)
        else:
            return random.choice(self.accounts)

    #
    # AMOUNTS
    #

    # Value-cap rollback note: this helper is intentionally left defined only
    # as commented-out reference material at its call sites. The active amount
    # path below no longer calls it.
    def _is_payable(self, function: str) -> bool:
        """
        根据 Fuzzer 注入的 self.payable_map / self.payable 判定是否 payable。
        - 若没有任何元信息，保守地视为非 payable（constructor 也视为非 payable）。
        - 对 receive/fallback 特判为 True（若你未来从 ABI 标注，也可走映射）。
        """
        try:
            pm = getattr(self, "payable_map", None)
            if isinstance(pm, dict) and function in pm:
                return bool(pm[function])
            pm2 = getattr(self, "payable", None)
            if isinstance(pm2, dict) and function in pm2:
                return bool(pm2[function])
        except Exception:
            pass

        if function in ("receive", "fallback"):
            return True
        if function == "constructor":
            return False
        return False

    def add_amount_to_pool(self, function, amount):
        if not function in self.amounts_pool:
            self.amounts_pool[function] = CircularSet()
        self.amounts_pool[function].add(amount)

    def remove_amount_from_pool(self, function, amount):
        if function in self.amounts_pool:
            self.amounts_pool[function].discard(amount)
            if self.amounts_pool[function].empty:
                del self.amounts_pool[function]

    def get_random_amount_from_pool(self, function):
        return self.amounts_pool[function].head_and_rotate()

    # Value-cap rollback note: this helper is intentionally left defined only
    # as commented-out reference material at its call sites. The active amount
    # path below no longer calls it.
    def _cap_amount_for_sender(self, function, amount, account=None, gaslimit=None, balance=None):
        if not self._is_payable(function):
            return 0

        try:
            amount = int(amount)
        except Exception:
            amount = 0
        if amount <= 0:
            return 0

        if balance is None:
            balance_getter = getattr(self, "balance_getter", None)
            if not callable(balance_getter) or not account:
                return amount

            try:
                balance = int(balance_getter(account))
            except Exception:
                return amount
        else:
            try:
                balance = int(balance)
            except Exception:
                return amount

        try:
            gaslimit = int(gaslimit if gaslimit is not None else settings.GAS_LIMIT)
        except Exception:
            gaslimit = settings.GAS_LIMIT

        try:
            gas_price_getter = getattr(self, "gas_price_getter", None)
            gas_price = int(gas_price_getter() if callable(gas_price_getter) else settings.GAS_PRICE)
        except Exception:
            gas_price = settings.GAS_PRICE

        affordable = max(0, balance - gaslimit * gas_price)
        return min(amount, affordable)

    # def get_random_amount(self, function):
    #     if function in self.amounts_pool:
    #         amount = self.get_random_amount_from_pool(function)
    #     else:
    #         amount = random.randint(0, 1)
    #         self.add_amount_to_pool(function, amount)
    #         self.add_amount_to_pool(function, 1 - amount)
    #     return amount
    
    def get_random_amount(self, function, account=None, gaslimit=None):
        """
        非 payable：强制 value=0（并入池以兼容旋转池机制）。
        payable（含 receive/fallback）：沿用原“0/1”探索（你也可在此扩展分布/上限）。
        """
        # if not self._is_payable(function):
        #     amount = 0
        #     self.add_amount_to_pool(function, amount)
        #     return amount

        # if function in self.amounts_pool:
        #     return self.get_random_amount_from_pool(function)
        # else:
        #     print("--------------payable function----------------")
        #     amount = random.randint(0, 1)
        #     self.add_amount_to_pool(function, amount) 
        #     self.add_amount_to_pool(function, 1 - amount)
        #     return amount
        

        if function in self.amounts_pool:
            amount = self.get_random_amount_from_pool(function)
        else:
            # Value-cap rollback hook: the new code forced non-payable
            # functions to value=0. Restore the original 0/1 exploration for
            # all functions, and keep the new branch commented for rollback.
            # if not self._is_payable(function):
            #     amount = 0
            # else:
            #     amount = random.randint(0, 1)
            amount = random.randint(0, 1)
            self.add_amount_to_pool(function, amount)
            self.add_amount_to_pool(function, 1 - amount)
        # return self._cap_amount_for_sender(function, amount, account=account, gaslimit=gaslimit)
        return amount

    #
    # STRINGS
    #

    def add_string_to_pool(self, string):
        self.strings_pool.add(string)


    def get_random_string_from_pool(self):
        return self.strings_pool.head_and_rotate()

    #
    # BYTES
    #

    def add_bytes_to_pool(self, string):
        self.bytes_pool.add(string)


    def get_random_bytes_from_pool(self):
        return self.bytes_pool.head_and_rotate()

    #
    # FUNCTION ARGUMENTS
    #

    def add_parameter_array_size(self, function, parameter_index, array_size):
        if function not in self.argument_array_sizes_pool:
            self.argument_array_sizes_pool[function] = dict()
        if parameter_index not in self.argument_array_sizes_pool[function]:
            self.argument_array_sizes_pool[function][parameter_index] = CircularSet()
        self.argument_array_sizes_pool[function][parameter_index].add(min(array_size, MAX_ARRAY_LENGTH))

    def _get_parameter_array_size_from_pool(self, function, argument_index):
        return self.argument_array_sizes_pool[function][argument_index].head_and_rotate()

    def remove_parameter_array_size_from_pool(self, function, parameter_index, array_size):
        if function in self.argument_array_sizes_pool and parameter_index in self.argument_array_sizes_pool[function]:
            self.argument_array_sizes_pool[function][parameter_index].discard(array_size)
            if self.argument_array_sizes_pool[function][parameter_index].empty:
                del self.argument_array_sizes_pool[function][parameter_index]
                if len(self.argument_array_sizes_pool[function]) == 0:
                    del self.argument_array_sizes_pool[function]


    def add_argument_to_pool(self, function, argument_index, argument):
        if type(argument) is list:
            for element in argument:
                self.add_argument_to_pool(function, argument_index, element)
            return
        if function not in self.arguments_pool:
            self.arguments_pool[function] = {}
        if argument_index not in self.arguments_pool[function]:
            self.arguments_pool[function][argument_index] = CircularSet()
        self.arguments_pool[function][argument_index].add(argument)

    def remove_argument_from_pool(self, function, argument_index, argument):
        if type(argument) is list:
            for element in argument:
                self.remove_argument_from_pool(function, argument_index, element)
            return
        if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
            self.arguments_pool[function][argument_index].discard(argument)
            if self.arguments_pool[function][argument_index].empty:
                del self.arguments_pool[function][argument_index]
                if len(self.arguments_pool[function]) == 0:
                    del self.arguments_pool[function]

    def _get_random_argument_from_pool(self, function, argument_index):
        return self.arguments_pool[function][argument_index].head_and_rotate()

    def get_random_argument(self, type, function, argument_index):
        # Boolean
        if type.startswith("bool"):
            # Array
            if "[" in type and "]" in type:
                sizes = self._get_array_sizes(argument_index, function, type)
                array = []
                for _ in range(sizes[0]):
                    if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                        if self._get_random_argument_from_pool(function, argument_index) == 0:
                            array.append(False)
                        else:
                            array.append(True)
                    else:
                        if random.randint(0, 1) == 0:
                            array.append(False)
                        else:
                            array.append(True)
                if len(sizes) > 1:
                    new_array = []
                    for _ in range(sizes[1]):
                        new_array.append(array)
                    array = new_array
                return array
            # Single value
            else:
                if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                    if self._get_random_argument_from_pool(function, argument_index) == 0:
                        return False
                    return True
                else:
                    if random.randint(0, 1) == 0:
                        return False
                    return True

        # Unsigned integer
        elif type.startswith("uint"):
            bytes = int(int(type.replace("uint", "").split("[")[0]) / 8)
            # Array
            if "[" in type and "]" in type:
                sizes = self._get_array_sizes(argument_index, function, type)
                array = []
                for _ in range(sizes[0]):
                    if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                        array.append(self._get_random_argument_from_pool(function, argument_index))
                    else:
                        array.append(self.get_random_unsigned_integer(0, UINT_MAX[bytes]))
                if len(sizes) > 1:
                    new_array = []
                    for _ in range(sizes[1]):
                        new_array.append(array)
                    array = new_array
                return array
            # Single value
            else:
                if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                    return self._get_random_argument_from_pool(function, argument_index)
                return self.get_random_unsigned_integer(0, UINT_MAX[bytes])

        # Signed integer
        elif type.startswith("int"):
            bytes = int(int(type.replace("int", "").split("[")[0]) / 8)
            # Array
            if "[" in type and "]" in type:
                sizes = self._get_array_sizes(argument_index, function, type)
                array = []
                for _ in range(sizes[0]):
                    if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                        array.append(self._get_random_argument_from_pool(function, argument_index))
                    else:
                        array.append(self.get_random_signed_integer(INT_MIN[bytes], INT_MAX[bytes]))
                if len(sizes) > 1:
                    new_array = []
                    for _ in range(sizes[1]):
                        new_array.append(array)
                    array = new_array
                return array
            # Single value
            else:
                if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                    return self._get_random_argument_from_pool(function, argument_index)
                return self.get_random_signed_integer(INT_MIN[bytes], INT_MAX[bytes])

        # Address
        elif type.startswith("address"):
            # Array
            if "[" in type and "]" in type:
                sizes = self._get_array_sizes(argument_index, function, type)
                array = []
                for _ in range(sizes[0]):
                    if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                        array.append(self._get_random_argument_from_pool(function, argument_index))
                    else:
                        array.append(random.choice(self.accounts))
                if len(sizes) > 1:
                    new_array = []
                    for _ in range(sizes[1]):
                        new_array.append(array)
                    array = new_array
                return array
            # Single value
            else:
                if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                    return self._get_random_argument_from_pool(function, argument_index)
                return random.choice(self.accounts)

        # String
        elif type.startswith("string"):
            # Array
            if "[" in type and "]" in type:
                sizes = self._get_array_sizes(argument_index, function, type)
                array = []
                for _ in range(sizes[0]):
                    array.append(self.get_string(random.randint(0, MAX_ARRAY_LENGTH)))
                if len(sizes) > 1:
                    new_array = []
                    for _ in range(sizes[1]):
                        new_array.append(array)
                    array = new_array
                return array
            # Single value
            else:
                if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                    return self._get_random_argument_from_pool(function, argument_index)
                if self.strings_pool.empty:
                    self.add_string_to_pool(self.get_string(0))
                    self.add_string_to_pool(self.get_string(1))
                    self.add_string_to_pool(self.get_string(32))
                    self.add_string_to_pool(self.get_string(33))
                return self.get_random_string_from_pool()

        # Bytes1 ... Bytes32
        elif type.startswith("bytes1") or \
             type.startswith("bytes2") or \
             type.startswith("bytes3") or \
             type.startswith("bytes4") or \
             type.startswith("bytes5") or \
             type.startswith("bytes6") or \
             type.startswith("bytes7") or \
             type.startswith("bytes8") or \
             type.startswith("bytes9") or \
             type.startswith("bytes10") or \
             type.startswith("bytes11") or \
             type.startswith("bytes12") or \
             type.startswith("bytes13") or \
             type.startswith("bytes14") or \
             type.startswith("bytes15") or \
             type.startswith("bytes16") or \
             type.startswith("bytes17") or \
             type.startswith("bytes18") or \
             type.startswith("bytes19") or \
             type.startswith("bytes20") or \
             type.startswith("bytes21") or \
             type.startswith("bytes22") or \
             type.startswith("bytes23") or \
             type.startswith("bytes24") or \
             type.startswith("bytes25") or \
             type.startswith("bytes26") or \
             type.startswith("bytes27") or \
             type.startswith("bytes28") or \
             type.startswith("bytes29") or \
             type.startswith("bytes30") or \
             type.startswith("bytes31") or \
             type.startswith("bytes32"):
            length = int(type.replace("bytes", "").split("[")[0])
            # Array
            if "[" in type and "]" in type:
                sizes = self._get_array_sizes(argument_index, function, type)
                array = []
                for _ in range(sizes[0]):
                    if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                        array.append(self._get_random_argument_from_pool(function, argument_index))
                    else:
                        array.append(self.get_random_bytes(length))
                if len(sizes) > 1:
                    new_array = []
                    for _ in range(sizes[1]):
                        new_array.append(array)
                    array = new_array
                return array
            # Single value
            else:
                if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                    return self._get_random_argument_from_pool(function, argument_index)
                return self.get_random_bytes(random.randint(0, length))

        # Bytes
        elif type.startswith("bytes"):
            # Array
            if "[" in type and "]" in type:
                sizes = self._get_array_sizes(argument_index, function, type)
                array = []
                for _ in range(sizes[0]):
                    array.append(self.get_random_bytes(random.randint(0, MAX_ARRAY_LENGTH)))
                if len(sizes) > 1:
                    new_array = []
                    for _ in range(sizes[1]):
                        new_array.append(array)
                    array = new_array
                return array
            # Single value
            else:
                if function in self.arguments_pool and argument_index in self.arguments_pool[function]:
                    return self._get_random_argument_from_pool(function, argument_index)
                if self.bytes_pool.empty:
                    self.add_bytes_to_pool(self.get_random_bytes(0))
                    self.add_bytes_to_pool(self.get_random_bytes(1))
                    self.add_bytes_to_pool(self.get_random_bytes(32))
                    self.add_bytes_to_pool(self.get_random_bytes(33))
                return self.get_random_bytes_from_pool()

        # Unknown type
        else:
            self.logger.error("Unsupported type: "+str(type))

    def _get_array_sizes(self, argument_index, function, type):
        sizes = []
        for size in re.compile(r"\[(.*?)\]").findall(type):
            # Dynamic array
            if size == "":
                if function in self.argument_array_sizes_pool \
                        and argument_index in self.argument_array_sizes_pool[function]:
                    sizes.append(self._get_parameter_array_size_from_pool(function, argument_index))
                else:
                    sizes.append(random.randint(0, MAX_ARRAY_LENGTH))
            # Fixed size array
            else:
                sizes.append(int(size))
        return sizes

    @staticmethod
    def get_random_unsigned_integer(min, max):
        seed = int(random.uniform(-2, 2))
        if seed == -1:
            return random.choice([min, min + 1, min + 2])
        elif seed == 1:
            return random.choice([max, max - 1, max - 2])
        else:
            return random.randint(min, max)

    @staticmethod
    def get_random_signed_integer(min, max):
        seed = int(random.uniform(-2, 2))
        if seed == -1:
            return random.choice([0, -1, min, min + 1])
        elif seed == 1:
            return random.choice([0, 1, max, max - 1])
        else:
            return random.randint(min, max)

    @staticmethod
    def get_string(length):
        return ''.join('A' for _ in range(length))

    @staticmethod
    def get_random_bytes(length):
        return bytearray(random.getrandbits(8) for _ in range(length))
