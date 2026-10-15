#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import time
import json
import solcx
import random
import logging
import argparse
import re

from eth_utils import encode_hex, decode_hex, to_canonical_address
from z3 import Solver

from .evm import InstrumentedEVM
from .detectors import DetectorExecutor
from .engine import EvolutionaryFuzzingEngine
from .engine.components import Generator, Individual, Population, pretty_print_initial_population
from .engine.analysis import SymbolicTaintAnalyzer
from .engine.analysis import ExecutionTraceAnalyzer
from .engine.environment import FuzzingEnvironment
from .engine.operators import LinearRankingSelection
from .engine.operators import DataDependencyLinearRankingSelection
from .engine.operators import CoveragePreservingUIRSelection
from .engine.operators import Crossover
from .engine.operators import DataDependencyCrossover
from .engine.operators import Mutation
from .engine.operators import RandomSplit
from .engine.fitness import fitness_function

from .utils import settings
from .utils.source_map import SourceMap
from .utils.utils import initialize_logger, compile, get_interface_from_abi, get_pcs_and_jumpis, get_function_signature_mapping, dump_initial_generated_individuals_to_json, convert_gen0_dump_file_to_highlevel, build_selector_to_signature_map
from .utils.control_flow_graph import ControlFlowGraph
from .utils.env_config import get_llm_config
from .reporting.root_cause import generate_root_cause_report
from .reporting.finding_schema import _canonical_contract_meta_dir
from .func_test.build_and_extract import _select_contract

# -----------------------ADD-------------------------- #
import pathlib
from typing import Any, List, Dict, Optional
# 顶部 imports 附近
try:
    from eth_abi import encode as abi_encode
except ImportError:
    from eth_abi import encode_abi as abi_encode
from decimal import Decimal, InvalidOperation


def _strip_solidity_comments(source_text: str) -> str:
    source_text = re.sub(r"/\*.*?\*/", "", source_text, flags=re.S)
    source_text = re.sub(r"//.*?$", "", source_text, flags=re.M)
    return source_text


def _extract_braced_block(source_text: str, open_brace_idx: int) -> str:
    depth = 0
    for i in range(open_brace_idx, len(source_text)):
        ch = source_text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return source_text[open_brace_idx + 1:i]
    return ""


def _constructor_body_from_source(source_text: Optional[str], contract_name: str) -> Optional[str]:
    if not source_text:
        return None
    src = _strip_solidity_comments(source_text)
    patterns = [
        r"\bconstructor\s*\([^)]*\)[^{;]*\{",
        rf"\bfunction\s+{re.escape(contract_name)}\s*\([^)]*\)[^{{;]*\{{",
    ]
    for pat in patterns:
        m = re.search(pat, src, flags=re.S)
        if not m:
            continue
        open_idx = src.find("{", m.start(), m.end())
        if open_idx >= 0:
            body = _extract_braced_block(src, open_idx)
            if body:
                return body
    return None


def _parse_wei_literal(expr: str) -> Optional[int]:
    expr = (expr or "").strip()
    m = re.fullmatch(r"(\d+(?:\.\d+)?)\s*(wei|gwei|szabo|finney|ether)?", expr, flags=re.I)
    if not m:
        return None
    try:
        value = Decimal(m.group(1))
    except InvalidOperation:
        return None
    unit = (m.group(2) or "wei").lower()
    multipliers = {
        "wei": Decimal(1),
        "gwei": Decimal(10) ** 9,
        "szabo": Decimal(10) ** 12,
        "finney": Decimal(10) ** 15,
        "ether": Decimal(10) ** 18,
    }
    wei = value * multipliers[unit]
    if wei != wei.to_integral_value():
        return None
    return int(wei)


def _infer_constructor_value_from_source(source_path: Optional[str], contract_name: str) -> Optional[int]:
    if not source_path:
        return None
    try:
        source_text = pathlib.Path(source_path).read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return None
    body = _constructor_body_from_source(source_text, contract_name)
    if not body:
        return None
    for m in re.finditer(r"require\s*\(\s*msg\.value\s*(==|>=)\s*([^,\);]+)", body):
        wei = _parse_wei_literal(m.group(2).strip())
        if wei is not None:
            return wei
    for m in re.finditer(r"if\s*\(\s*msg\.value\s*<\s*([^)]+?)\s*\)\s*(?:throw|revert\s*\(\s*\)|\{)", body):
        wei = _parse_wei_literal(m.group(1).strip())
        if wei is not None:
            return wei
    for m in re.finditer(r"if\s*\(\s*([^)]+?)\s*>\s*msg\.value\s*\)\s*(?:throw|revert\s*\(\s*\)|\{)", body):
        wei = _parse_wei_literal(m.group(1).strip())
        if wei is not None:
            return wei
    return None


def _resolve_gen0_output_dir(args, default_dir: Optional[pathlib.Path] = None) -> pathlib.Path:
    explicit_path = getattr(args, "gen0_output_dir", None)
    if explicit_path:
        return pathlib.Path(explicit_path)
    results_path = getattr(args, "results", None)
    if results_path:
        path = pathlib.Path(results_path)
        if path.suffix.lower() == ".json":
            return path.parent if str(path.parent) else pathlib.Path(".")
        return path
    return pathlib.Path(default_dir) if default_dir is not None else pathlib.Path(".")


def _coerce_nonnegative_int(value: Any, default: int = 0) -> int:
    if value is None or value == "":
        return default
    if isinstance(value, bool):
        return default
    try:
        ivalue = int(value, 0) if isinstance(value, str) else int(value)
    except Exception:
        return default
    return ivalue if ivalue >= 0 else default


def _load_raw_seeds(seeds_path: str) -> Any:
    p = pathlib.Path(seeds_path)
    text = p.read_text(encoding="utf-8").strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        raw = []
        for line in text.splitlines():
            line=line.strip()
            if line:
                raw.append(json.loads(line))
        return raw

def load_custom_seeds(seeds_path: str, default_contract: str, accounts: List[str]) -> List[List[Dict[str, Any]]]:
    # 允许两种 schema：高层友好 / 低层原生（下文给示例）；这里只做“整体外形”校验，字段细化在 Generator 里完成
    raw = _load_raw_seeds(seeds_path)
    if isinstance(raw, dict) and isinstance(raw.get("sequences"), list):
        raw = raw.get("sequences") or []
    elif not isinstance(raw, list):
        raw = [raw]
    seed_logger = logging.getLogger("Main")
    out=[]
    for i,item in enumerate(raw):
        if isinstance(item, dict) and ("steps" in item or "constructor" in item):
            # 高层友好：留到 Generator 里做细化；此处只保留原样（交由 _normalize_seed_seq 处理）
            out.append([item])  # 用单元素 list 包住，以便统一成“多步序列容器”
        elif isinstance(item, list) and len(item)>=1:
            out.append(item)
        else:
            seed_logger.warning("Skipping invalid seed at index %d: must be high-level dict or non-empty low-level list.", i)
    return out

def _seeds_require_constructor(seeds):
    if not seeds:
        return False
    for item in seeds:
        # 1) 顶层就是 dict（高层友好）
        if isinstance(item, dict) and "constructor" in item:
            return True
        # 2) 顶层是 list
        if isinstance(item, list) and item:
            first = item[0]
            # 2.1) list[dict] 且 dict 有 "constructor"（高层被包了一层）
            if isinstance(first, dict) and "constructor" in first:
                return True
            # 2.2) 低层 raw：第一步 arguments[0] == "constructor"
            if isinstance(first, dict):
                args = first.get("arguments", [])
                if isinstance(args, list) and args and str(args[0]).lower() == "constructor":
                    return True
    return False


def _extract_first_ctor_args_from_seeds(seeds):
    """
    返回 (from_acct, ctor_args)；若不存在则 (None, None)
    兼容：
      - 顶层 dict（高层）
      - 顶层 list 且 list[0] 是含 "constructor" 的 dict（高层被包）
      - 顶层 list 且 list[0].arguments 以 "constructor" 开头（低层 raw）
    """
    if not seeds:
        return (None, None, 0)

    for item in seeds:
        # 顶层 dict（高层）
        if isinstance(item, dict) and "constructor" in item:
            c = item["constructor"] or {}
            return c.get("from"), list(c.get("args", [])), _coerce_nonnegative_int(c.get("value"), 0)

        # 顶层 list
        if isinstance(item, list) and item and isinstance(item[0], dict):
            first = item[0]
            # 高层被包：list[0] 里就有 "constructor"
            if "constructor" in first:
                c = first["constructor"] or {}
                return c.get("from"), list(c.get("args", [])), _coerce_nonnegative_int(c.get("value"), 0)
            # 低层 raw：arguments[0] == "constructor"
            a = first.get("arguments", [])
            if isinstance(a, list) and a and str(a[0]).lower() == "constructor":
                return first.get("account"), list(a[1:]), _coerce_nonnegative_int(first.get("amount"), 0)

    return (None, None, 0)


def _constructor_is_payable(abi: List[Dict[str, Any]]) -> bool:
    for entry in abi or []:
        if isinstance(entry, dict) and entry.get("type") == "constructor":
            return bool(entry.get("payable") or entry.get("stateMutability") == "payable")
    return False


def _strip_ctor_step_from_all_seeds(seeds):
    """
    删除每条序列里的 constructor 第一步，保持“外层结构”不变：
      - 顶层 dict：删掉 dict["constructor"]
      - 顶层 list 且 list[0] 含 "constructor"：删掉该 key（保留 list 外壳）
      - 顶层 list 且低层 raw：丢弃 list[0]
    """
    if not seeds:
        return seeds

    out = []
    for item in seeds:
        # 顶层 dict（高层）
        if isinstance(item, dict) and "constructor" in item:
            d = dict(item)
            d.pop("constructor", None)
            out.append(d)
            continue

        # 顶层 list
        if isinstance(item, list) and item and isinstance(item[0], dict):
            first = dict(item[0])
            # 高层被包：list[0] 带 "constructor"
            if "constructor" in first:
                first.pop("constructor", None)
                new_list = [first] + item[1:]
                out.append(new_list)
                continue
            # 低层 raw：arguments[0] == "constructor"
            a = first.get("arguments", [])
            if isinstance(a, list) and a and str(a[0]).lower() == "constructor":
                out.append(item[1:])  # 去掉首步
                continue

        # 其它情况，原样返回
        out.append(item)
    return out


def _find_compiler_source_key(compiler_output, source_path):
    contracts = compiler_output.get("contracts", {}) if compiler_output else {}
    if source_path in contracts:
        return source_path

    resolved = str(pathlib.Path(source_path).resolve())
    if resolved in contracts:
        return resolved

    normalized_source = os.path.normcase(os.path.normpath(resolved))
    for key in contracts:
        if os.path.normcase(os.path.normpath(key)) == normalized_source:
            return key

    source_name = os.path.basename(source_path)
    basename_matches = [key for key in contracts if os.path.basename(key) == source_name]
    if len(basename_matches) == 1:
        return basename_matches[0]

    if len(contracts) == 1:
        return next(iter(contracts.keys()))

    return None


def _maybe_generate_llm_root_cause_report(contract_name, abi, source_path, args):
    if not getattr(args, "llm_rca", False):
        return None

    meta_dir = _canonical_contract_meta_dir(contract_name, source_path=source_path)
    pro_dir = meta_dir / "finding_cases_pro"
    if not pro_dir.exists():
        logger.warning("[LLM-RCA] finding_cases_pro not found: %s", pro_dir)
        return None

    llm_config = get_llm_config(
        env_file=getattr(args, "env_file", None),
        api_key=getattr(args, "llm_rca_api_key", None),
        api_url=getattr(args, "llm_rca_api_url", None),
        model=getattr(args, "llm_rca_model", None),
    )
    if not llm_config.get("api_key") or not llm_config.get("api_url") or not llm_config.get("model"):
        logger.warning("[LLM-RCA] skipped: missing LLM_API_KEY, LLM_API_URL, or LLM_MODEL in .env")
        return None

    try:
        report = generate_root_cause_report(
            pro_dir,
            contract_name=contract_name,
            source_path=source_path,
            abi=abi,
            api_key=llm_config.get("api_key"),
            api_url=llm_config.get("api_url"),
            model=llm_config.get("model"),
            env_file=getattr(args, "env_file", None),
            max_source_chars=getattr(args, "llm_rca_max_source_chars", 40000),
        )
        logger.info("[LLM-RCA] wrote %s (%s results, %s errors)",
                    pro_dir / "llm_root_cause_report.json",
                    len(report.get("results") or []),
                    len(report.get("errors") or []))
        return report
    except Exception as exc:
        logger.warning("[LLM-RCA] failed: %s", exc)
        return None


def _load_uir_targets_for_fuzzing(contract_name, source_path, args):
    def _log(level, msg, *values):
        log = globals().get("logger")
        if log is not None:
            getattr(log, level)(msg, *values)

    if getattr(args, "no_uir_targets", False):
        _log("info", "[UIR] semantic target loading disabled by --no-uir-targets.")
        return None, None

    candidates = []
    explicit = getattr(args, "uir_targets", None)
    if explicit:
        candidates.append(pathlib.Path(explicit))

    meta_dir = _canonical_contract_meta_dir(contract_name, source_path=source_path)
    candidates.extend([
        meta_dir / "uir_targets.json",
        meta_dir / "analysis.json",
        pathlib.Path("foundry") / f"{contract_name}_meta" / "invariant_test" / "uir_targets.json",
        pathlib.Path("foundry") / f"{contract_name}_meta" / "invariant_test" / "analysis.json",
        pathlib.Path("foundry") / f"{contract_name}_meta" / "functional_test" / "uir_targets.json",
        pathlib.Path("foundry") / f"{contract_name}_meta" / "functional_test" / "analysis.json",
        pathlib.Path("debug_out") / contract_name / "baseline_analysis.json",
    ])

    seen = set()
    for path in candidates:
        try:
            path = pathlib.Path(path)
            key = str(path.resolve())
        except Exception:
            key = str(path)
        if key in seen:
            continue
        seen.add(key)
        if not pathlib.Path(path).exists():
            continue
        try:
            data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
            targets = data.get("uir_targets") if isinstance(data, dict) and "uir_targets" in data else data
            if isinstance(targets, dict) and targets.get("functions_by_selector") is not None:
                _log("info", "[UIR] loaded semantic targets from %s", path)
                return targets, str(path)
        except Exception as exc:
            _log("warning", "[UIR] failed to load semantic targets from %s: %s", path, exc)

    if explicit:
        _log("warning", "[UIR] --uir-targets was provided but no valid target map was loaded: %s", explicit)
    else:
        _log("info", "[UIR] no semantic target map found; UIR coverage metrics disabled.")
    return None, None

class Fuzzer:
    def __init__(self, contract_name, abi, deployment_bytecode, runtime_bytecode, test_instrumented_evm, blockchain_state, solver, args, seed, source_map=None):
        global logger

        logger = initialize_logger("Fuzzer  ")
        logger.title("Fuzzing contract %s", contract_name)

        cfg = ControlFlowGraph()
        cfg.build(runtime_bytecode, settings.EVM_VERSION)

        self.contract_name = contract_name
        self.interface = get_interface_from_abi(abi)
        self.deployement_bytecode = deployment_bytecode
        self.blockchain_state = blockchain_state
        self.instrumented_evm = test_instrumented_evm
        self.solver = solver
        self.args = args
        self.abi = abi

        self.sel2sig, warns = build_selector_to_signature_map(self.interface, abi)

        print("---------------interface---------------")
        print(self.interface)
        print("---------------abi---------------")
        print(abi)

        # Get some overall metric on the code
        self.overall_pcs, self.overall_jumpis = get_pcs_and_jumpis(runtime_bytecode)

        # Initialize results
        self.results = {"errors": {}}
        uir_targets, uir_targets_path = _load_uir_targets_for_fuzzing(contract_name, getattr(args, "source", None), args)
        self.meta_dir = _canonical_contract_meta_dir(contract_name, source_path=getattr(args, "source", None))

        # Initialize fuzzing environment
        self.env = FuzzingEnvironment(instrumented_evm=self.instrumented_evm,
                                      contract_name=self.contract_name,
                                      solver=self.solver,
                                      results=self.results,
                                      symbolic_taint_analyzer=SymbolicTaintAnalyzer(),
                                      detector_executor=DetectorExecutor(source_map, get_function_signature_mapping(abi), uir_targets=uir_targets),
                                      interface=self.interface,
                                      overall_pcs=self.overall_pcs,
                                      overall_jumpis=self.overall_jumpis,
                                      runtime_bytecode=runtime_bytecode,
                                      len_overall_pcs_with_children=0,
                                      other_contracts = list(),
                                      args=args,
                                      seed=seed,
                                      cfg=cfg,
                                      abi=abi,
                                      meta_dir=str(self.meta_dir),
                                      uir_targets=uir_targets,
                                      uir_targets_path=uir_targets_path)

    def run(self):

        def _default_value_for_type(t: str, accounts_list):
            t = t.replace(" storage","").replace(" memory","")
            # 基础类型
            if t.startswith("uint") or t.startswith("int"):
                return 0
            if t == "bool":
                return False
            if t.startswith("address"):
                # 给一个有效地址（现有假账户里取第一个）
                return accounts_list[0] if accounts_list else "0x" + "11"*20
            if t.startswith("bytes") and t != "bytes":
                return b""
            if t == "bytes":
                return b""
            if t == "string":
                return ""
            # 动态/定长数组（简单起见给空数组）
            if "[" in t and "]" in t:
                return []
            # 结构体/tuple 不在本合约里，用不到；给空
            return 0

        contract_address = None
        self.instrumented_evm.create_fake_accounts()
        for probe_account in ("0x0000000000000000000000000000000000000000",):
            if probe_account.lower() not in {a.lower() for a in self.instrumented_evm.accounts}:
                self.instrumented_evm.accounts.append(self.instrumented_evm.create_fake_account(probe_account))

        if self.args.source:
            for transaction in self.blockchain_state:
                if transaction['from'].lower() not in self.instrumented_evm.accounts:
                    self.instrumented_evm.accounts.append(self.instrumented_evm.create_fake_account(transaction['from']))

                if not transaction['to']:
                    result = self.instrumented_evm.deploy_contract(transaction['from'], transaction['input'], int(transaction['value']), int(transaction['gas']), int(transaction['gasPrice']))
                    if result.is_error:
                        logger.error("Problem while deploying contract %s using account %s. Error message: %s", self.contract_name, transaction['from'], result._error)
                        sys.exit(-2)
                    else:
                        contract_address = encode_hex(result.msg.storage_address)
                        self.instrumented_evm.accounts.append(contract_address)
                        self.env.nr_of_transactions += 1
                        logger.debug("Contract deployed at %s", contract_address)
                        self.env.other_contracts.append(to_canonical_address(contract_address))
                        cc, _ = get_pcs_and_jumpis(self.instrumented_evm.get_code(to_canonical_address(contract_address)).hex())
                        self.env.len_overall_pcs_with_children += len(cc)
                else:
                    input = {}
                    input["block"] = {}
                    input["transaction"] = {
                        "from": transaction["from"],
                        "to": transaction["to"],
                        "gaslimit": int(transaction["gas"]),
                        "value": int(transaction["value"]),
                        "data": transaction["input"]
                    }
                    input["global_state"] = {}
                    out = self.instrumented_evm.deploy_transaction(input, int(transaction["gasPrice"]))

            # if "constructor" in self.interface:
            #     del self.interface["constructor"]

            # # ----------------------ADD----------------------- #
            # # 只有在 seeds 不需要 constructor 编码时才删除
            # if "constructor" in self.interface:
            #     needs_ctor = _seeds_require_constructor(getattr(self.args, "seeds_data", []))
            #     if not needs_ctor:
            #         del self.interface["constructor"]


            if not contract_address:
                if "constructor" not in self.interface:
                    result = self.instrumented_evm.deploy_contract(self.instrumented_evm.accounts[0], self.deployement_bytecode)
                    if result.is_error:
                        logger.error("Problem while deploying contract %s using account %s. Error message: %s", self.contract_name, self.instrumented_evm.accounts[0], result._error)
                        sys.exit(-2)
                    else:
                        contract_address = encode_hex(result.msg.storage_address)
                        self.instrumented_evm.accounts.append(contract_address)
                        self.env.nr_of_transactions += 1
                        logger.debug("Contract deployed at %s", contract_address)

            if contract_address in self.instrumented_evm.accounts:
                self.instrumented_evm.accounts.remove(contract_address)

            # self.env.overall_pcs, self.env.overall_jumpis = get_pcs_and_jumpis(self.instrumented_evm.get_code(to_canonical_address(contract_address)).hex())
            # ----------------------------------ADD------------------------------- #
            if contract_address:
                self.env.runtime_bytecode = self.instrumented_evm.get_code(to_canonical_address(contract_address)).hex()
                self.env.overall_pcs, self.env.overall_jumpis = get_pcs_and_jumpis(
                    self.env.runtime_bytecode
                )
            else:
                # 回退：使用构造时提供的 runtime bytecode 对应的统计（__init__ 已算过 overall_pcs/jumpis）
                self.env.overall_pcs, self.env.overall_jumpis = self.overall_pcs, self.overall_jumpis

        if self.args.abi:
            contract_address = self.args.contract

        # ---- 新增：当 seeds 含 constructor 时，用该参数“预部署一次”获取稳定地址 ----
        use_custom_seeds = getattr(self.args, "seed_strategy", "prepend") != "random"
        needs_ctor = use_custom_seeds and _seeds_require_constructor(getattr(self.args, "seeds_data", []))
        if needs_ctor:
            _, ctor_args_probe, _ = _extract_first_ctor_args_from_seeds(getattr(self.args, "seeds_data", []))
            if "constructor" not in self.interface:
                logger.warning("Seeds include constructor but interface['constructor'] is missing; skipping seed constructor steps.")
                self.args.seeds_data = _strip_ctor_step_from_all_seeds(self.args.seeds_data)
                needs_ctor = False
            else:
                ctor_types_probe = [t.replace(" storage","").replace(" memory","") for t in self.interface["constructor"]]
                try:
                    abi_encode(ctor_types_probe, ctor_args_probe)
                except Exception as e:
                    logger.warning("Skipping seed constructor steps with unencodable args: %s", e)
                    logger.warning("Types: %s  Args: %s", ctor_types_probe, ctor_args_probe)
                    self.args.seeds_data = _strip_ctor_step_from_all_seeds(self.args.seeds_data)
                    needs_ctor = False
        if needs_ctor and not contract_address:
            # 1) 取 constructor 参数
            from_acct, ctor_args, ctor_value = _extract_first_ctor_args_from_seeds(self.args.seeds_data)
            if not from_acct:
                from_acct = self.instrumented_evm.accounts[0]

            # ===== 新增：确保 from_acct 被创建并注资 =====
            acct_set_lower = {a.lower() for a in self.instrumented_evm.accounts}
            if from_acct.lower() not in acct_set_lower:
                # create_fake_account 会把账户加入列表并给予足够余额
                self.instrumented_evm.accounts.append(
                    self.instrumented_evm.create_fake_account(from_acct)
                )
            # ===== 新增结束 =====

            # 2) 取 constructor 参数类型
            if "constructor" not in self.interface:
                logger.error("Seeds include constructor but interface['constructor'] is missing. Keep constructor in interface.")
                sys.exit(-6)
            ctor_types = [t.replace(" storage","").replace(" memory","") for t in self.interface["constructor"]]

            # 3) 拼接部署 data：bytecode + ABI 编码的构造参数
            try:
                encoded = abi_encode(ctor_types, ctor_args).hex()
            except Exception as e:
                logger.error(f"ABI-encode constructor args failed: {e}")
                logger.error(f"Types: {ctor_types}  Args: {ctor_args}")
                sys.exit(-6)

            deploy_data = (self.deployement_bytecode or "")
            deploy_data = deploy_data[2:] if deploy_data.startswith("0x") else deploy_data
            deploy_data = "0x" + deploy_data + encoded

            # 4) 进行部署
            self.instrumented_evm.ensure_account_funded(from_acct)  # 或 transaction['from']
            result = self.instrumented_evm.deploy_contract(from_acct, deploy_data, ctor_value)
            if result.is_error:
                logger.error("Problem while deploying contract %s using account %s. Error: %s",
                            self.contract_name, from_acct, result._error)
                sys.exit(-2)
            contract_address = encode_hex(result.msg.storage_address)
            if contract_address not in self.instrumented_evm.accounts:
                self.instrumented_evm.accounts.append(contract_address)
            self.env.nr_of_transactions += 1
            logger.debug("Contract pre-deployed (from seeds ctor) at %s", contract_address)

            # 5) 既然已经用 seeds 的参数部署好了，就把每条 seed 序列里的 constructor 步骤删掉
            self.args.seeds_data = _strip_ctor_step_from_all_seeds(self.args.seeds_data)


        # ---- 兜底：既没有链上地址，也没有 seeds 触发的预部署，就用“默认值”把合约先部署出来 ----
        if not contract_address:
            if "constructor" in self.interface and self.deployement_bytecode:
                ctor_types = [t.replace(" storage","").replace(" memory","") for t in self.interface["constructor"]]
                ctor_args = [_default_value_for_type(t, self.instrumented_evm.accounts) for t in ctor_types]
                try:
                    encoded = abi_encode(ctor_types, ctor_args).hex()
                except Exception as e:
                    logger.error(f"ABI-encode default ctor args failed: {e}")
                    logger.error(f"Types: {ctor_types}  Args: {ctor_args}")
                    sys.exit(-6)

                deploy_data = (self.deployement_bytecode or "")
                deploy_data = deploy_data[2:] if deploy_data.startswith("0x") else deploy_data
                deploy_data = "0x" + deploy_data + encoded

                from_acct = self.instrumented_evm.accounts[0]
                ctor_value = 0
                inferred_value = _infer_constructor_value_from_source(getattr(self.args, "source", None), self.contract_name)
                if inferred_value is not None:
                    ctor_value = inferred_value
                elif _constructor_is_payable(self.abi):
                    ctor_value = 0
                if ctor_value:
                    logger.info("Default deploy using inferred constructor value %s wei for %s", ctor_value, self.contract_name)
                self.instrumented_evm.ensure_account_funded(
                    from_acct,
                    max(int(ctor_value or 0) + int(settings.GAS_LIMIT) * int(settings.GAS_PRICE), 0),
                )
                result = self.instrumented_evm.deploy_contract(from_acct, deploy_data, ctor_value)
                if result.is_error:
                    logger.error("Default deploy failed for %s from %s. Error: %s", self.contract_name, from_acct, result._error)
                    sys.exit(-2)

                contract_address = encode_hex(result.msg.storage_address)
                if contract_address not in self.instrumented_evm.accounts:
                    self.instrumented_evm.accounts.append(contract_address)
                self.env.nr_of_transactions += 1
                logger.info("Default pre-deploy at %s (ctor defaults used).", contract_address)

                # 部署后更新覆盖度基线
                try:
                    self.env.runtime_bytecode = self.instrumented_evm.get_code(to_canonical_address(contract_address)).hex()
                    self.env.overall_pcs, self.env.overall_jumpis = get_pcs_and_jumpis(
                        self.env.runtime_bytecode
                    )
                except Exception as _e:
                    logger.warning("Failed to refresh coverage after default deploy: %s", _e)

        # ---- 新增结束 ----

        # ----------------------------------ADD------------------------- #
        # 如果传了 --seeds（source 模式），此时已拿到真实 contract_address，可以做最终规范
        if use_custom_seeds and self.args.source and getattr(self.args, "seeds", None):
            try:
                raw = self.args.seeds_data
                if not isinstance(raw, list): raw = [raw]
                final=[]
                for item in raw:
                    # 交给 Generator 的 _normalize_seed_seq 处理，此处只把“高层dict包一层list”的约定保持一致
                    final.append(item)
                self.args.seeds_data = final
                logger.info(f"Prepared {len(final)} custom seed sequences for initialization.")
            except Exception as e:
                logger.error(f"Failed to prepare seeds: {e}")
                sys.exit(-1)

        self.instrumented_evm.create_snapshot()

        # generator = Generator(interface=self.interface,
        #                       bytecode=self.deployement_bytecode,
        #                       accounts=self.instrumented_evm.accounts,
        #                       contract=contract_address)
        
        # --- DEBUG: start ---
        try:
            from .utils.debug_tools import dump_interface_keys, dump_seeds_quick, is_hex_addr
        except Exception:
            # 如果你没新建debug_tools.py，就把上面那些函数放 main.py 顶部，然后这里不用 import
            pass

        logger.info("[DEBUG] contract_address final: %r", contract_address)
        try:
            dump_interface_keys(self.interface, logger, title="interface (selector->types + ctor/fallback)")
        except Exception as _e:
            logger.warning("[DEBUG] dump_interface_keys failed: %s", _e)

        try:
            dump_seeds_quick(getattr(self.args, "seeds_data", []), logger, contract_address or "")
        except Exception as _e:
            logger.warning("[DEBUG] dump_seeds_quick failed: %s", _e)
        # --- DEBUG: end ---

        # --------------------------ADD------------------------ #
        generator = Generator(interface=self.interface,
                      bytecode=self.deployement_bytecode,
                      accounts=self.instrumented_evm.accounts,
                      contract=contract_address,
                      custom_seeds=getattr(self.args, "seeds_data", []),
                      seed_strategy=getattr(self.args, "seed_strategy", "prepend"))
        def _generator_sender_balance(account):
            return int(self.instrumented_evm.get_balance(to_canonical_address(account)))

        setattr(generator, "balance_getter", _generator_sender_balance)
        setattr(generator, "gas_price_getter", lambda: int(settings.GAS_PRICE))
        setattr(generator, "vulnerability_hints_enabled", bool(getattr(self.args, "vulnerability_hints", False)))
        setattr(generator, "vulnerability_hint_static_probe_limit", int(getattr(self.args, "vulnerability_hint_static_probes", 32) or 0))
        setattr(generator, "vulnerability_uir_targets", getattr(self.env, "uir_targets", {}) or {})
        
        # ===== inject payable_map from ABI right after generator is created =====
        payable_by_sig = {}
        try:
            # 1) 收集 ABI 中的函数签名与 payable
            for entry in self.env.abi:
                et = entry.get("type")
                if et == "function":
                    name = entry.get("name", "")
                    inputs = entry.get("inputs", [])
                    sig = name + "(" + ",".join(i.get("type", "") for i in inputs) + ")"
                    is_pay = bool(entry.get("payable")) or (entry.get("stateMutability") == "payable")
                    payable_by_sig[sig] = is_pay
                elif et in ("receive", "fallback"):
                    # 如 ABI 有明确条目，可记录；否则由 Generator._is_payable 的特判兜底
                    # Solidity 标准 JSON ABI 对 receive/fallback 的表示因版本不同可能缺省
                    pass

            # 2) 将“selector -> signature”的映射（__init__ 已构建为 self.sel2sig）折算成“selector -> payable”
            payable_map = {}
            for sel, sig in self.sel2sig.items():
                if sig in payable_by_sig:
                    payable_map[sel] = payable_by_sig[sig]

            # 3) constructor（根据 ABI）通常 nonpayable，这里加映射（Generator 里也会保守返回 False）
            try:
                for entry in self.env.abi:
                    if entry.get("type") == "constructor":
                        is_pay_ctor = bool(entry.get("payable")) or (entry.get("stateMutability") == "payable")
                        payable_map["constructor"] = is_pay_ctor
                        break
            except Exception:
                payable_map["constructor"] = False

            # 4) 可选：若 ABI 显式列出 receive/fallback 且标注 payable，可写入
            # payable_map["receive"]  = True/False
            # payable_map["fallback"] = True/False

            # 5) 注入到 generator（Generator._is_payable 会读取）
            setattr(generator, "payable_map", payable_map)

            # --- 可选调试 ---
            logger.info("[PAYABLE-MAP] %d entries injected (e.g. first 8: %s)",
                        len(payable_map), list(payable_map.items())[:8])
        except Exception as _e:
            logger.warning("Failed to build payable_map from ABI: %s", _e)
        
        # print(generator)
        
        tmp = None

        if getattr(self.args, "seed_strategy", "prepend") != "random" and getattr(self.args, "seeds_data", None):
            try:
                tmp = Individual(generator=generator).init(chromosome=generator._normalize_seed_seq(
                    getattr(self.args, "seeds_data", [])[0] if getattr(self.args, "seeds_data", []) else []))
                if tmp.solution:
                    logger.debug("First-seed first-tx: %s", tmp.solution[0]["transaction"])
            except SystemExit as e:
                logger.warning("Skipping first-seed debug decode because the seed is invalid: %s", e)
            except Exception as e:
                logger.warning("Skipping first-seed debug decode because the seed is invalid: %s", e)

        # Create initial population
        # size = 2 * len(self.interface)
        seed_strategy = getattr(self.args, "seed_strategy", "prepend")
        seed_count = len(getattr(self.args, "seeds_data", []))
        random_size = 2 * len(self.interface)
        guard_probe_count = 0
        probe_generator = getattr(generator, "generate_guard_probe_sequences", None)
        if callable(probe_generator):
            try:
                guard_probe_count = len(probe_generator())
            except Exception as _e:
                logger.warning("Failed to size coverage guard probes: %s", _e)
                guard_probe_count = 0
        vulnerability_probe_count = 0
        vulnerability_probe_kind_counts = {}
        vuln_probe_generator = getattr(generator, "generate_vulnerability_probe_sequences", None)
        if bool(getattr(self.args, "vulnerability_hints", False)) and callable(vuln_probe_generator):
            try:
                vulnerability_probe_sequences = vuln_probe_generator()
                vulnerability_probe_count = len(vulnerability_probe_sequences)
                for seq in vulnerability_probe_sequences:
                    for gene in seq or []:
                        kind = gene.get("__coverage_probe__", "unknown") if isinstance(gene, dict) else "unknown"
                        vulnerability_probe_kind_counts[kind] = vulnerability_probe_kind_counts.get(kind, 0) + 1
            except Exception as _e:
                logger.warning("Failed to size vulnerability hint probes: %s", _e)
                vulnerability_probe_count = 0
                vulnerability_probe_kind_counts = {}
        if bool(getattr(self.args, "vulnerability_hints", False)):
            setattr(self.env, "vulnerability_hint_static_probes", {
                "generated": vulnerability_probe_count,
                "by_kind": vulnerability_probe_kind_counts,
            })
        if seed_strategy == "only":
            size = (seed_count or random_size) + guard_probe_count + vulnerability_probe_count
        elif seed_strategy == "random":
            size = random_size + guard_probe_count + vulnerability_probe_count
        else:
            size = random_size + seed_count + guard_probe_count + vulnerability_probe_count
        population = Population(indv_template=Individual(generator=generator),
                                indv_generator=generator,
                                size=settings.POPULATION_SIZE if settings.POPULATION_SIZE else size).init()
        
        # —— 打印初始种子池（需要你在 CLI 里传入 --print-init-seeds 控制，或直接总是打印） ——
        try:
            should_print = True  # 想总是打印可改成 True
            if should_print:
                # 这里优先用 self.abi（第②步已保存）
                try:
                    pretty_print_initial_population(population, abi=self.abi, logger=logger)
                except NameError:
                    # 没有 logger 也没关系
                    pretty_print_initial_population(population, abi=self.abi)
        except Exception as e:
            print(f"[warn] failed to pretty print initial seeds: {e}")
        
        gen0_output_dir = _resolve_gen0_output_dir(self.args, default_dir=self.meta_dir)
        gen0_output_dir.mkdir(parents=True, exist_ok=True)
        out_path = dump_initial_generated_individuals_to_json(
            population,
            path=str(gen0_output_dir / "gen0_generated_individuals.json"),
        )
        high_path = convert_gen0_dump_file_to_highlevel(
            out_path,
            str(gen0_output_dir / "gen0_highlevel.json"),
            selector_to_sig=self.sel2sig,
            merge=True,
        )
        logger.info("Generation-0 generated individuals written to: %s", out_path)
        logger.info("High-level generation-0 seeds written to: %s", high_path)

        logger.debug("First gene func token: %s", population[0].chromosome[0]["arguments"][0])
        logger.debug("First tx.to: %r", population[0].solution[0]["transaction"]["to"])

        # print(population)

        # --- DEBUG: peek first few individuals ---
        def _abbr(x, n=120):
            try:
                return ("0x"+x.hex())[:n]+"..." if isinstance(x,(bytes,bytearray)) and len(x)>n else ("0x"+x.hex()) if isinstance(x,(bytes,bytearray)) else (str(x)[:n]+"..." if len(str(x))>n else str(x))
            except Exception:
                return str(x)

        try:
            for i in range(min(3, len(population.individuals))):
                ind = population.individuals[i]
                sol = ind.solution if ind.solution else ind.decode()
                if not sol: 
                    logger.info("[POP][%d] empty solution?", i)
                    continue
                tx0 = sol[0]["transaction"]
                args0 = ind.chromosome[0].get("arguments", [])
                func0 = args0[0] if isinstance(args0, list) and args0 else None
                logger.info("[POP][%d] first tx: func=%r  to=%s  value=%s  gas=%s",
                            i, func0, _abbr(tx0.get("to"), 66), tx0.get("value"), tx0.get("gaslimit"))
                logger.info("[POP][%d] first tx data len=%s preview=%s",
                            i, len(tx0.get("data") or ""), _abbr(tx0.get("data"), 120))
        except Exception as _e:
            logger.warning("[DEBUG] population peek failed: %s", _e)
        # --- DEBUG end ---

        # Create genetic operators
        use_uir_selection = bool(getattr(self.args, "uir_selection", False)) and bool(getattr(self.env, "uir_targets", None))
        if use_uir_selection:
            self.env.uir_selection_config = {
                "enabled": True,
                "coverage_slack": getattr(self.args, "uir_coverage_slack", 0.0),
                "random_rate": getattr(self.args, "uir_selection_random_rate", 0.05),
                "data_dependency": bool(self.args.data_dependency),
                "plateau_generations": getattr(self.args, "uir_selection_plateau", 2),
            }
            selection = CoveragePreservingUIRSelection(
                env=self.env,
                coverage_slack=getattr(self.args, "uir_coverage_slack", 0.0),
                random_rate=getattr(self.args, "uir_selection_random_rate", 0.05),
                data_dependency=bool(self.args.data_dependency),
                plateau_generations=getattr(self.args, "uir_selection_plateau", 2),
            )
            logger.info(
                "[UIR] plateau-gated semantic selection enabled (coverage_slack=%s, random_rate=%s, plateau=%s, data_dependency=%s)",
                getattr(self.args, "uir_coverage_slack", 0.0),
                getattr(self.args, "uir_selection_random_rate", 0.05),
                getattr(self.args, "uir_selection_plateau", 2),
                bool(self.args.data_dependency),
            )
        elif getattr(self.args, "uir_selection", False):
            logger.warning("[UIR] semantic selection requested but no UIR targets were loaded; falling back to baseline selection.")
            self.env.uir_selection_config = {"enabled": False, "reason": "missing_uir_targets"}
        else:
            self.env.uir_selection_config = {"enabled": False}

        if self.args.data_dependency:
            if not use_uir_selection:
                selection = DataDependencyLinearRankingSelection(env=self.env)
            crossover = DataDependencyCrossover(pc=settings.PROBABILITY_CROSSOVER, env=self.env)
            mutation = Mutation(pm=settings.PROBABILITY_MUTATION)
        else:
            if not use_uir_selection:
                selection = LinearRankingSelection()
            crossover = Crossover(pc=settings.PROBABILITY_CROSSOVER)
            mutation = Mutation(pm=settings.PROBABILITY_MUTATION)

        # 新增：创建随机分裂算子（和 crossover / mutation 并列）
        # 可先用固定参数，也可以之后做成 settings / 命令行可配置
        split_op = RandomSplit(
            ps=getattr(settings, "PROBABILITY_SPLIT"),   # 每个 child 30% 概率尝试分裂
            min_len=getattr(settings, "MIN_SPLIT_LENGTH") # 分裂后片段最少 1 笔 tx
        )

        # Create and run our evolutionary fuzzing engine
        #engine = EvolutionaryFuzzingEngine(population=population, selection=selection, crossover=crossover, mutation=mutation, mapping=get_function_signature_mapping(self.env.abi))
        engine = EvolutionaryFuzzingEngine(population=population, selection=selection, crossover=crossover, mutation=mutation, mapping=get_function_signature_mapping(self.env.abi),split=split_op)
        engine.env = self.env
        
        engine.fitness_register(lambda x: fitness_function(x, self.env))
        engine.analysis.append(ExecutionTraceAnalyzer(self.env))

        self.env.execution_begin = time.time()
        self.env.population = population

        engine.run(ng=settings.GENERATIONS)

        if self.env.args.cfg:
            if self.env.args.source:
                self.env.cfg.save_control_flow_graph(os.path.splitext(self.env.args.source)[0]+'-'+self.contract_name, 'pdf')
            elif self.env.args.abi:
                self.env.cfg.save_control_flow_graph(os.path.join(os.path.dirname(self.env.args.abi), self.contract_name), 'pdf')

        self.instrumented_evm.reset()

def main():
    # if os.getenv("SEMINV_SHOW_LOGO", "").strip().lower() in ("1", "true", "yes", "on"):
    #     print_logo()
    args = launch_argument_parser()
    os.environ["SEMINV_FP_FILTER"] = str(getattr(args, "fp_filter", "evidence-safe") or "evidence-safe")

    logger = initialize_logger("Main    ")

    # Check if contract has already been analyzed
    if args.results and os.path.exists(args.results):
        os.remove(args.results)
        logger.info("Contract "+str(args.source)+" has already been analyzed: "+str(args.results))
        sys.exit(0)

    # Initializing random
    if args.seed:
        seed = args.seed
        if not "PYTHONHASHSEED" in os.environ:
            logger.debug("Please set PYTHONHASHSEED to '1' for Python's hash function to behave deterministically.")
    else:
        seed = random.random()
        # seed = 1
    random.seed(seed)
    logger.title("Initializing seed to %s", seed)

    # Initialize EVM
    instrumented_evm = InstrumentedEVM(settings.RPC_HOST, settings.RPC_PORT)
    instrumented_evm.set_vm_by_name(settings.EVM_VERSION)

    # Create Z3 solver instance
    solver = Solver()
    solver.set("timeout", settings.SOLVER_TIMEOUT)

    # Parse blockchain state if provided
    blockchain_state = []
    if args.blockchain_state:
        if args.blockchain_state.endswith(".json"):
            with open(args.blockchain_state) as json_file:
                for line in json_file.readlines():
                    blockchain_state.append(json.loads(line))
        elif args.blockchain_state.isnumeric():
            settings.BLOCK_HEIGHT = int(args.blockchain_state)
            instrumented_evm.set_vm(settings.BLOCK_HEIGHT)
        else:
            logger.error("Unsupported input file: " + args.blockchain_state)
            sys.exit(-1)

    # --------------------------ADD------------------------- #
    args.seeds_data = []
    if args.seeds:
        try:
            args.seeds_data = load_custom_seeds(args.seeds, default_contract=args.contract, accounts=instrumented_evm.accounts or [])
        except FileNotFoundError as e:
            logger.warning(f"Seeds file missing; falling back to random initialization: {e}")
            args.seeds_data = []
        except Exception as e:
            logger.error(f"Failed to load seeds: {e}")
            sys.exit(-1)

    # Compile source code to get deployment bytecode, runtime bytecode and ABI
    if args.source:
        if args.source.endswith(".sol"):
            compiler_output = compile(args.solc_version, settings.EVM_VERSION, args.source)
            # print(compiler_output)
            if not compiler_output:
                logger.error("No compiler output for: " + args.source)
                sys.exit(-1)
            source_key = _find_compiler_source_key(compiler_output, args.source)
            if not source_key:
                logger.error("Source file not found in compiler output: %s. Available sources: %s",
                             args.source, list(compiler_output.get("contracts", {}).keys()))
                sys.exit(-1)
            try:
                contract_name, contract, selection_info = _select_contract(
                    compiler_output['contracts'][source_key],
                    args.contract or None,
                )
            except RuntimeError as exc:
                logger.error("%s", exc)
                sys.exit(-1)
            if selection_info.get("fallback_used"):
                logger.warning(
                    "Contract selection fallback: %s -> %s",
                    selection_info.get("requested_contract"),
                    selection_info.get("selected_contract"),
                )
            args.contract = contract_name
            source_map = SourceMap(':'.join([source_key, contract_name]), compiler_output)
            Fuzzer(contract_name, contract["abi"], contract['evm']['bytecode']['object'], contract['evm']['deployedBytecode']['object'], instrumented_evm, blockchain_state, solver, args, seed, source_map).run()
            _maybe_generate_llm_root_cause_report(contract_name, contract["abi"], args.source, args)
        else:
            logger.error("Unsupported input file: " + args.source)
            sys.exit(-1)

    if args.abi:
        with open(args.abi) as json_file:
            abi = json.load(json_file)
            runtime_bytecode = instrumented_evm.get_code(to_canonical_address(args.contract)).hex()
            Fuzzer(args.contract, abi, None, runtime_bytecode, instrumented_evm, blockchain_state, solver, args, seed).run()
            _maybe_generate_llm_root_cause_report(args.contract, abi, None, args)

def launch_argument_parser():
    parser = argparse.ArgumentParser()

    try:
        default_solc_version = str(solcx.get_solc_version())
    except Exception:
        # A fresh subprocess has no active py-solc-x version until --solc is
        # parsed.  Keep argument construction usable and let the explicit CLI
        # value select/install the compiler later in main().
        default_solc_version = "not selected"

    # Contract parameters
    group1 = parser.add_mutually_exclusive_group(required=True)
    group1.add_argument("-s", "--source", type=str,
                        help="Solidity smart contract source code file (.sol).")
    group1.add_argument("-a", "--abi", type=str,
                        help="Smart contract ABI file (.json).")

    #group2 = parser.add_mutually_exclusive_group(required=True)
    parser.add_argument("-c", "--contract", type=str,
                        help="Contract name to be fuzzed (if Solidity source code file provided) or blockchain contract address (if ABI file provided).")

    parser.add_argument("-b", "--blockchain-state", type=str,
                        help="Initialize fuzzer with a blockchain state by providing a JSON file (if Solidity source code file provided) or a block number (if ABI file provided).")

    # Compiler parameters
    parser.add_argument("--solc", help="Solidity compiler version (default '" +
        default_solc_version + "'). Installed compiler versions: " + str(solcx.get_installed_solc_versions()) + ".",
                        action="store", dest="solc_version", type=str)
    parser.add_argument("--evm", help="Ethereum VM (default '" + str(
        settings.EVM_VERSION) + "'). Available VM's: 'homestead', 'byzantium' or 'petersburg'.", action="store",
                        dest="evm_version", type=str)

    # Evolutionary parameters
    group3 = parser.add_mutually_exclusive_group(required=False)
    group3.add_argument("-g", "--generations",
                        help="Number of generations (default " + str(settings.GENERATIONS) + ").", action="store",
                        dest="generations", type=int)
    group3.add_argument("-t", "--timeout",
                        help="Number of seconds for fuzzer to stop.", action="store",
                        dest="global_timeout", type=int)
    parser.add_argument("-n", "--population-size",
                        help="Size of the population.", action="store",
                        dest="population_size", type=int)
    parser.add_argument("-pc", "--probability-crossover",
                        help="Size of the population.", action="store",
                        dest="probability_crossover", type=float)
    parser.add_argument("-pm", "--probability-mutation",
                        help="Size of the population.", action="store",
                        dest="probability_mutation", type=float)

    # Miscellaneous parameters
    parser.add_argument("-r", "--results", type=str, help="Folder or JSON file where results should be stored.")
    parser.add_argument("--gen0-output-dir", type=str,
                        help="Directory for generation-0 seed dumps. Defaults to the contract meta directory.")
    parser.add_argument("--seed", type=float, help="Initialize the random number generator with a given seed.")
    parser.add_argument("--cfg", help="Build control-flow graph and highlight code coverage.", action="store_true")
    parser.add_argument("--rpc-host", help="Ethereum client RPC hostname.", action="store", dest="rpc_host", type=str)
    parser.add_argument("--rpc-port", help="Ethereum client RPC port.", action="store", dest="rpc_port", type=int)

    parser.add_argument("--data-dependency",
                        help="Disable/Enable data dependency analysis: 0 - Disable, 1 - Enable (default: 1)", action="store",
                        dest="data_dependency", type=int)
    parser.add_argument("--constraint-solving",
                        help="Disable/Enable constraint solving: 0 - Disable, 1 - Enable (default: 1)", action="store",
                        dest="constraint_solving", type=int)
    parser.add_argument("--environmental-instrumentation",
                        help="Disable/Enable environmental instrumentation: 0 - Disable, 1 - Enable (default: 1)", action="store",
                        dest="environmental_instrumentation", type=int)
    parser.add_argument("--max-individual-length",
                        help="Maximal length of an individual (default: " + str(settings.MAX_INDIVIDUAL_LENGTH) + ")", action="store",
                        dest="max_individual_length", type=int)
    parser.add_argument("--max-symbolic-execution",
                        help="Maximum number of symbolic execution calls before restting population (default: " + str(settings.MAX_SYMBOLIC_EXECUTION) + ")", action="store",
                        dest="max_symbolic_execution", type=int)
    parser.add_argument("--solver-max-branches-per-call", type=int, default=0,
                        help="Maximum symbolic branch-solving attempts per symbolic_execution call. 0 keeps the legacy unlimited behavior.")
    parser.add_argument("--solver-max-call-ms", type=int, default=0,
                        help="Maximum wall-clock milliseconds spent in one symbolic_execution call. 0 keeps the legacy unlimited behavior.")
    parser.add_argument("--solver-branch-cooldown", type=int, default=0,
                        help="Generations to wait before retrying the same negated symbolic branch. 0 disables cooldown.")
    parser.add_argument("--solver-stats-trace-limit", type=int, default=100,
                        help="Maximum number of recent symbolic solving attempt records kept in results. 0 disables detailed attempt retention.")
    parser.add_argument("--solver-branch-plateau", type=int, default=0,
                        help="Enable symbolic solving after this many consecutive generations without new branch coverage. 0 disables this phase-2 trigger.")
    parser.add_argument("--solver-high-risk-branch-age", type=int, default=0,
                        help="Enable symbolic solving when a one-sided high-risk UIR branch remains unflipped for this many generations. 0 disables this phase-2 trigger.")
    parser.add_argument("--solver-uir-priority", type=str, default="legacy", choices=["legacy", "light"],
                        help="Symbolic branch ordering policy. 'legacy' preserves existing ordering/legacy UIR sorting; 'light' uses coverage-frontier plus lightweight UIR risk scoring without adding solver triggers.")
    parser.add_argument("--solver-targeted-seeds", action="store_true", default=False,
                        help="Queue solver model-derived chromosomes for direct injection into later generations. Disabled by default.")
    parser.add_argument("--solver-targeted-seed-mode", type=str, default="all", choices=["all", "valuable"],
                        help="Targeted seed injection mode. 'all' keeps stage-4 behavior; 'valuable' only injects models changing argument/account/call_return/extcodesize/returndatasize.")
    parser.add_argument("--solver-targeted-seeds-per-call", type=int, default=1,
                        help="Maximum model-derived seeds queued per symbolic_execution call when --solver-targeted-seeds is enabled. 0 means no per-call limit.")
    parser.add_argument("--solver-targeted-seed-injection", type=int, default=2,
                        help="Maximum queued model-derived seeds injected at the start of each generation.")
    parser.add_argument("--solver-targeted-seed-queue", type=int, default=16,
                        help="Maximum queued model-derived seeds retained before dropping new unique seeds. 0 means unlimited.")
    parser.add_argument("--solver-abi-constraints", action="store_true", default=False,
                        help="Add ABI type bounds to symbolic branch solving. Disabled by default.")
    parser.add_argument("--solver-max-path-conditions", type=int, default=0,
                        help="Skip symbolic solving when a candidate path condition list exceeds this length. 0 disables this stage-5 pruning.")
    parser.add_argument("--solver-max-variables", type=int, default=0,
                        help="Skip symbolic solving when a candidate contains more symbolic variables than this limit. 0 disables this stage-5 pruning.")
    parser.add_argument("--vulnerability-hints", action="store_true", default=False,
                        help="Enable detector-proximity guided probes and hint seed injection. Disabled by default.")
    parser.add_argument("--vulnerability-hint-injection", type=int, default=2,
                        help="Maximum vulnerability hint seeds injected at the start of each generation.")
    parser.add_argument("--vulnerability-hint-queue", type=int, default=32,
                        help="Maximum queued vulnerability hint seeds retained before dropping new unique hints. 0 means unlimited.")
    parser.add_argument("--vulnerability-hint-static-probes", type=int, default=32,
                        help="Maximum static vulnerability probe seeds added to the initial population when --vulnerability-hints is enabled.")
    
    #---------------------ADD----------------------#
    parser.add_argument("--seeds", type=str, help="Path to seeds file (.json or NDJSON). Each seed is a multi-step tx sequence.")
    parser.add_argument("--seed-strategy", type=str, default="prepend", choices=["only", "random", "prepend"], 
                        help="Initial population strategy: only custom seeds, only random individuals, or custom seeds prepended with random fill.")
    parser.add_argument("--validate-minimization", action="store_true", default=None,
                        help="Run external oracles for finding_cases_pro minimization/reproduction validation.")
    parser.add_argument("--minimization-timeout", type=int, default=None,
                        help="Timeout in seconds for each external minimization oracle run.")
    parser.add_argument("--env-file", type=str, default=None,
                        help="Path to env file containing LLM_API_KEY, LLM_API_URL, and LLM_MODEL. Defaults to .env.")
    parser.add_argument("--llm-rca", action="store_true", default=False,
                        help="After fuzzing, run a single-shot LLM root-cause analysis for finding_cases_pro/*.json.")
    parser.add_argument("--fp-filter", choices=["off", "evidence-safe"],
                        default=os.getenv("SEMINV_FP_FILTER", "evidence-safe"),
                        help="Report-layer false-positive filter; defaults to evidence-safe for D reporting.")
    parser.add_argument("--llm-rca-api-key", type=str, default=None,
                        help="API key override for --llm-rca. Defaults to LLM_API_KEY from env file.")
    parser.add_argument("--llm-rca-api-url", type=str, default=None,
                        help="Chat completions endpoint override for --llm-rca. Defaults to LLM_API_URL from env file.")
    parser.add_argument("--llm-rca-model", type=str, default=None,
                        help="Model override for --llm-rca. Defaults to LLM_MODEL from env file.")
    parser.add_argument("--llm-rca-max-source-chars", type=int, default=40000,
                        help="Maximum contract source characters included in each LLM-RCA prompt.")
    parser.add_argument("--uir-targets", type=str, default=None,
                        help="Optional path to uir_targets.json or analysis.json containing uir_targets for semantic coverage metrics.")
    parser.add_argument("--no-uir-targets", action="store_true", default=False,
                        help="Disable automatic UIR target loading. Useful for pure baseline runs.")
    parser.add_argument("--uir-selection", action="store_true", default=False,
                        help="Enable coverage-preserving UIR semantic seed ranking. Disabled by default for easy rollback.")
    parser.add_argument("--uir-coverage-slack", type=float, default=0.0,
                        help="Coverage fitness bucket size for UIR tie-breaking. 0 means exact fitness ties only.")
    parser.add_argument("--uir-selection-random-rate", type=float, default=0.05,
                        help="Random parent selection rate used by --uir-selection to preserve exploration.")
    parser.add_argument("--uir-selection-plateau", type=int, default=2,
                        help="Enable UIR semantic tie-breaking only after this many consecutive generations without new code coverage. Use 0 to enable immediately.")
    parser.add_argument("--uir-mutation", action="store_true", default=False,
                        help="Enable UIR-guided semantic mutation. Disabled by default for baseline-compatible experiments.")
    parser.add_argument("--uir-mutation-rate", type=float, default=0.25,
                        help="Probability of applying an additional UIR-guided mutation after the normal random mutation step.")
    parser.add_argument("--uir-mutation-insert-rate", type=float, default=0.10,
                        help="Probability that UIR-guided mutation inserts a related write-read/cross-relation call when sequence length allows.")
    parser.add_argument("--uir-dynamic-relations", action="store_true", default=False,
                        help="Enable low-confidence dynamic UIR relations learned from runtime SLOAD/SSTORE write-read slots. Disabled by default.")
    parser.add_argument("--uir-solving", action="store_true", default=False,
                        help="Enable UIR-triggered symbolic/taint solving. Disabled by default for baseline-compatible experiments.")
    parser.add_argument("--uir-solving-plateau", type=int, default=2,
                        help="Minimum code or UIR semantic plateau generations before UIR-triggered solving is allowed.")
    parser.add_argument("--uir-solving-min-guard-failures", type=int, default=1,
                        help="Minimum accumulated guarded UIR reverts before guarded-target UIR solving can trigger.")


    version = "Semantic Invariant Fuzz Backend - Version 0.0.2 - "
    version += "\"By three methods we may learn wisdom:\n"
    version += "First, by reflection, which is noblest;\n"
    version += "Second, by imitation, which is easiest;\n"
    version += "And third by experience, which is the bitterest.\"\n"
    parser.add_argument("-v", "--version", action="version", version=version)

    args = parser.parse_args()

    if not args.contract:
        args.contract = ""

    if args.source and args.contract.startswith("0x"):
        parser.error("--source requires --contract to be a name, not an address.")
    if args.source and args.blockchain_state and args.blockchain_state.isnumeric():
        parser.error("--source requires --blockchain-state to be a file, not a number.")

    if args.abi and not args.contract.startswith("0x"):
        parser.error("--abi requires --contract to be an address, not a name.")
    if args.abi and args.blockchain_state and not args.blockchain_state.isnumeric():
        parser.error("--abi requires --blockchain-state to be a number, not a file.")

    if args.evm_version:
        settings.EVM_VERSION = args.evm_version
    if not args.solc_version:
        args.solc_version = solcx.get_solc_version()
    if args.generations:
        settings.GENERATIONS = args.generations
    if args.global_timeout:
        settings.GLOBAL_TIMEOUT = args.global_timeout
    if args.population_size:
        settings.POPULATION_SIZE = args.population_size
    if args.probability_crossover:
        settings.PROBABILITY_CROSSOVER = args.probability_crossover
    if args.probability_mutation:
        settings.PROBABILITY_MUTATION = args.probability_mutation

    if args.data_dependency == None:
        args.data_dependency = 1
    if args.constraint_solving == None:
        args.constraint_solving = 1
    if args.environmental_instrumentation == None:
        args.environmental_instrumentation = 1

    if args.environmental_instrumentation == 1:
        settings.ENVIRONMENTAL_INSTRUMENTATION = True
    elif args.environmental_instrumentation == 0:
        settings.ENVIRONMENTAL_INSTRUMENTATION = False

    if args.max_individual_length:
        settings.MAX_INDIVIDUAL_LENGTH = args.max_individual_length
    if args.max_symbolic_execution:
        settings.MAX_SYMBOLIC_EXECUTION = args.max_symbolic_execution

    if args.abi:
        settings.REMOTE_FUZZING = True

    if args.rpc_host:
        settings.RPC_HOST = args.rpc_host
    if args.rpc_port:
        settings.RPC_PORT = args.rpc_port

    return args

def print_logo():
    print("")
    print("     ______            ______                _           ")
    print("    / ____/___  ____  / ____/_  __________  (_)_  _______")
    print("   / /   / __ \/ __ \/ /_  / / / /_  /_  / / / / / / ___/")
    print("  / /___/ /_/ / / / / __/ / /_/ / / /_/ /_/ / /_/ (__  ) ")
    print("  \____/\____/_/ /_/_/    \__,_/ /___/___/_/\__,_/____/  ")
    print("")

if '__main__' == __name__:
    main()
