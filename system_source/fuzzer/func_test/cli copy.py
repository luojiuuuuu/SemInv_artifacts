# -*- coding: utf-8 -*-
import argparse, json, os
import shutil
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

from .build_and_extract import compile_and_extract
from .feature_detect import detect_standards_and_traits
from .gen_foundry_tests import gen_tests_from_abi, write_foundry_test, llm_plan_sequences, load_standards_json, llm_plan_per_function_sequences, build_planner_facts_from_ir
from .run_and_collect import run_foundry_tests, minimal_coverage_signature, write_signature
# from .gen_llm_seeds import heuristic_seeds, write_seeds, llm_generate_report_and_seeds, write_report
from .fast_executor import score_and_pick
from .gen_llm_funcreport import write_report, write_seeds, llm_generate_report_and_seeds
from .gen_foundry_seeds import extract_success_seeds_from_files
from .stds_nomarlize import normalize_stds, resolve_post_conditions_against_abi
from .gen_invariant_tests import gen_invariant_tests, build_contract_ir, recover_invariants, complete_invariants_with_llm, generate_foundry_invariant_tests
from ..utils import settings
from ..utils.env_config import get_llm_config
from ..utils.control_flow_graph import ControlFlowGraph
from ..evm import InstrumentedEVM
from eth_utils import encode_hex, decode_hex, to_canonical_address

def main():
    ap = argparse.ArgumentParser("func-test pipeline")
    ap.add_argument("-s", "--source", required=True, help="Solidity source file path")
    ap.add_argument("-c", "--contract", default=None, help="Contract name in source")
    ap.add_argument("--solc", default="v0.8.24", help="solc version, e.g., v0.8.24")
    ap.add_argument("--evm", help="Ethereum VM (default '" + str(settings.EVM_VERSION) + "'). Available VM's: 'homestead', 'byzantium' or 'petersburg'.")
    ap.add_argument("--project-root", default=".", help="Foundry project root (forge.toml 所在目录)")
    ap.add_argument("--forge", default=None, help="path to forge/forge.exe (optional)")
    ap.add_argument("-k", "--topk", type=int, default=32, help="Top-K seeds to keep")
    ap.add_argument("--api-key", default=None, help="LLM API Key override. Defaults to LLM_API_KEY from .env.")
    ap.add_argument("--env-file", default=None, help="Path to env file for LLM_API_KEY/LLM_API_URL/LLM_MODEL. Defaults to .env.")
    args = ap.parse_args()

    root = str(Path(args.project_root).resolve())

    # 编译 & 抽取（evm 可为空，内部回落到 settings.EVM_VERSION）
    comp = compile_and_extract(args.source, args.contract, args.solc, args.evm)
    feats = detect_standards_and_traits(comp["abi"])
    print("[func_test] features:", feats)


    HERE = Path(__file__).resolve().parent           # 当前文件所在目录
    standards_path = HERE / "standards.json"  # 同级文件
    load_standards_json(str(standards_path))

    with open(args.source, 'r', encoding="utf-8") as file:
        source_code = file.read()

    # print(source_code)

    llm_config = get_llm_config(env_file=args.env_file, api_key=args.api_key)
    api_key = llm_config.get("api_key")
    api_url = llm_config.get("api_url")
    model = llm_config.get("model")
    if not api_key or not api_url or not model:
        raise RuntimeError("Missing LLM config. Set LLM_API_KEY, LLM_API_URL, and LLM_MODEL in .env or pass --api-key.")

    cfg = ControlFlowGraph()
    cfg.build(comp["runtime_bytecode"], settings.EVM_VERSION)

    print("[CLI->InvariantGen] passing storage_layout:", comp.get("storage_layout") is not None)
    print("[CLI->InvariantGen] passing solc_ir:", bool(comp.get("solc_ir")))
    print("[CLI->InvariantGen] passing solc_ir_optimized:", bool(comp.get("solc_ir_optimized")))


    # 4.1) IR构建
    ir_result = build_contract_ir(
        contract_name=comp["contract"],
        source_path=args.source,
        source_code=source_code,
        abi=comp["abi"],
        ast=comp["ast"],
        cfg=cfg,
        solc_version=args.solc,
        storage_layout=comp.get("storage_layout"),
        solc_ir=comp.get("solc_ir"),
        solc_ir_optimized=comp.get("solc_ir_optimized"),
        legacy_assembly=comp.get("legacy_assembly"),
        compiler_artifacts=comp.get("compiler_artifacts"),
    )

    # 4.2) 不变量恢复
    invariant_result = recover_invariants(
        contract_name=comp["contract"],
        source_path=args.source,
        cfg=cfg,
        solc_version=args.solc,
        ir_build_result=ir_result,
    )

    # 4.2.1) 从静态分析结果提取“测试规划友好”的事实
    planner_facts = build_planner_facts_from_ir(invariant_result)
    print("[func_test] planner_facts:", planner_facts)
    
    # t_llm_start = time.time()

    # # 1) 调 LLM 生成 plan
    # llm_plan = llm_plan_sequences(
    #     contract_name=comp["contract"],
    #     abi=comp["abi"],
    #     standards=feats["standards"],
    #     api_key=api_key,
    #     api_url=api_url,
    #     model=model,
    #     source_text=source_code,
    #     ir_result=invariant_result,        # 新增
    #     planner_facts=planner_facts,       # 新增
    #     max_sequences=10,
    #     max_steps=6
    # )
    # print(llm_plan)

    # # 1.5) 每函数最小兜底计划（由 LLM 产出，必要时我们补齐少数缺失）
    # perfn_plan = llm_plan_per_function_sequences(
    #     contract_name=comp["contract"],
    #     abi=comp["abi"],
    #     api_key=api_key,
    #     api_url=api_url,
    #     model=model,
    #     source_text=source_code,
    #     ir_result=invariant_result,        # 新增
    #     planner_facts=planner_facts        # 新增
    # )
    # print(perfn_plan)

    # 1) 并行调 LLM：主计划 + 每函数兜底计划
    with ThreadPoolExecutor(max_workers=2) as executor:
        future_main = executor.submit(
            llm_plan_sequences,
            contract_name=comp["contract"],
            abi=comp["abi"],
            standards=feats["standards"],
            api_key=api_key,
            api_url=api_url,
            model=model,
            source_text=source_code,
            ir_result=invariant_result,
            planner_facts=planner_facts,
            max_sequences=10,
            max_steps=6
        )

        future_perfn = executor.submit(
            llm_plan_per_function_sequences,
            contract_name=comp["contract"],
            abi=comp["abi"],
            api_key=api_key,
            api_url=api_url,
            model=model,
            source_text=source_code,
            ir_result=invariant_result,
            planner_facts=planner_facts
        )

        llm_plan = {"name": "LLM-Plan", "sequences": []}
        perfn_plan = {"name": "LLM-PerFn", "sequences": []}

        for future in as_completed([future_main, future_perfn]):
            try:
                result = future.result()
                if future is future_main:
                    llm_plan = result if isinstance(result, dict) else {"name": "LLM-Plan", "sequences": []}
                elif future is future_perfn:
                    perfn_plan = result if isinstance(result, dict) else {"name": "LLM-PerFn", "sequences": []}
            except Exception as e:
                if future is future_main:
                    print(f"[func_test] llm_plan failed: {e}")
                    llm_plan = {"name": "LLM-Plan", "sequences": []}
                elif future is future_perfn:
                    print(f"[func_test] perfn_plan failed: {e}")
                    perfn_plan = {"name": "LLM-PerFn", "sequences": []}

    print(llm_plan)
    print(perfn_plan)

    # t_llm_end = time.time()

    # print(f"[TIME] LLM stage: {t_llm_end - t_llm_start:.3f}s")

    # 2) 组合 standards 列表：内置字符串 + LLM 主计划 + LLM 每函数计划
    stds: List[Any] = []
    if len(feats["standards"])>0:
        stds.extend(feats["standards"] or [])
    if llm_plan.get("sequences"):
        stds.append(llm_plan)
    if perfn_plan.get("sequences"):
        stds.append(perfn_plan)
    print(stds)

    print(comp["abi"])

    stds = normalize_stds(stds,comp["abi"])

    stds = resolve_post_conditions_against_abi(stds,comp["abi"])

    print(stds)

    # 3) 生成测试源码并写入
    content = gen_tests_from_abi(
        contract_name=comp["contract"],
        abi=comp["abi"],
        standards=stds,
        solc_version=args.solc,
        source_path=args.source
    )

    # #4) 生成 invariant 测试
    # result = gen_invariant_tests(
    #     contract_name=args.contract,
    #     source_path=args.source,
    #     source_code=source_code, 
    #     abi=comp["abi"], 
    #     ast=comp["ast"], 
    #     cfg=cfg, 
    #     api_key = api_key,
    #     api_url = api_url,
    #     model = model,
    #     solc_version=args.solc,
    #     dump_dir="./debug_out/"+str(comp["contract"])+"/",
    #     dump_prefix="baseline_",
    #     return_analysis=True,
    #     storage_layout=comp.get("storage_layout"),
    #     solc_ir=comp.get("solc_ir"),
    #     solc_ir_optimized=comp.get("solc_ir_optimized"),
    #     legacy_assembly=comp.get("legacy_assembly"),
    #     compiler_artifacts=comp.get("compiler_artifacts"),
    #     )

    # # 4.3) LLM补全
    # completed_result = complete_invariants_with_llm(
    #     source_code=source_code,
    #     api_key=api_key,
    #     api_url=api_url,
    #     model=model,
    #     invariant_result=invariant_result,
    # )

    # # 4.4) Invariant Foundry测试生成
    # result = generate_foundry_invariant_tests(
    #     # contract_name=args.contract,
    #     contract_name=comp["contract"],
    #     source_path=args.source,
    #     abi=comp["abi"],
    #     solc_version=args.solc,
    #     invariant_result=completed_result,
    #     dump_dir="./debug_out/" + str(comp["contract"]) + "/",
    #     dump_prefix="baseline_",
    #     return_analysis=True,
    # )
    
    # content = result["foundry_code"]
    # analysis = result["analysis"]

    test_dir = Path(root) / "test"
    test_path = write_foundry_test(test_dir, comp["contract"], content)
    print(f"[func_test] wrote test: {test_path}")

    # 将合约源码复制到 project_root/src/，确保 forge 可编译到它
    src_dir = Path(root) / "src"
    src_dir.mkdir(parents=True, exist_ok=True)
    dst_src = src_dir / Path(args.source).name
    if Path(args.source).resolve() != dst_src.resolve():
        shutil.copy(args.source, str(dst_src))
    print(f"[func_test] ensured source in src/: {dst_src}")

    # 执行刚生成的测试文件并回收覆盖签名
    # # 不变量测试
    # results, trace_text = run_foundry_tests(
    #     root, str(test_path), forge_path=args.forge, profile=getattr(args, "profile", None), is_invariant_test=True
    # )
    # 功能测试
    results, trace_text = run_foundry_tests(
        root, str(test_path), forge_path=args.forge, profile=getattr(args, "profile", None), is_invariant_test=False
    )
    sig = minimal_coverage_signature(results, trace_text, abi=comp["abi"])
    sig_path = write_signature(root, str(test_path), sig)
    print(f"[func_test] wrote coverage signature: {sig_path}")

    result = llm_generate_report_and_seeds(
        comp["contract"],
        comp["abi"],
        comp["function_signature_mapping"],
        feats["standards"],
        api_key=api_key,
        api_url=api_url,
        model = model
    )

    report_path = write_report(root, str(test_path), result["report"])
    print(f"[func_test] wrote report: {report_path}")

    # seeds_path = write_seeds(root, str(test_path), result["seeds"])
    # print(f"[func_test] wrote seeds: {seeds_path}")

    # seeds = extract_success_seeds_from_files(outp, comp)
    seeds = extract_success_seeds_from_files(root, str(test_path), comp)
    seeds_path = write_seeds(root, str(test_path), seeds)
    print(f"[func_test] wrote seeds: {seeds_path}")

    # # ③ 快速执行器打分 & Top-K 选取
    # scored = score_and_pick(root, testfile_path=str(test_path), k=args.topk)
    # print(f"[func_test] scored seeds, kept Top-{args.topk}")

if __name__ == "__main__":
    main()
