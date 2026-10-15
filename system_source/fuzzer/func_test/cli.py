# -*- coding: utf-8 -*-
import argparse, json, os, sys
import shutil
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

from .build_and_extract import compile_and_extract
from .feature_detect import detect_standards_and_traits
from .gen_foundry_tests import gen_tests_from_abi, write_foundry_test, llm_plan_sequences, load_standards_json, llm_plan_per_function_sequences, build_planner_facts_from_ir
from .gen_foundry_tests import _parse_solc_version, _read_source_package_declaration_text, _repair_target_call_argument_casts
from .run_and_collect import run_foundry_tests, minimal_coverage_signature, write_signature, get_contract_meta_dir, get_test_meta_subdir
# from .gen_llm_seeds import heuristic_seeds, write_seeds, llm_generate_report_and_seeds, write_report
from .fast_executor import score_and_pick
from .gen_llm_funcreport import write_report, write_seeds, llm_generate_report_and_seeds
from .gen_foundry_seeds import extract_success_seeds_from_files, sanitize_seeds_for_fuzzer
from .stds_nomarlize import normalize_stds, resolve_post_conditions_against_abi
from .gen_invariant_tests import gen_invariant_tests, build_contract_ir, recover_invariants, complete_invariants_with_llm, generate_foundry_invariant_tests
from ..utils import settings
from ..utils.utils import read_source_with_legacy_compatibility
from ..utils.env_config import get_llm_config
from ..utils.control_flow_graph import ControlFlowGraph
try:
    from ..evm import InstrumentedEVM
except Exception:
    InstrumentedEVM = None
from eth_utils import encode_hex, decode_hex, to_canonical_address

def _benchmark_source_package_root(source_path: Optional[str]) -> Optional[Path]:
    if not source_path:
        return None
    try:
        source = Path(source_path).resolve()
    except Exception:
        return None
    for parent in [source.parent, *source.parents]:
        if parent.parent.name in {"sources", "external_sources"} and parent.parent.parent.name == "seminv_benchmarks":
            return parent
    return None

def _copy_package_sources_for_foundry(source_path: str, src_dir: Path) -> None:
    """Merge benchmark package source roots into Foundry src/.

    Direct CLI runs execute in the shared Foundry project, so package-local
    imports such as `libraries/X.sol` or `interfaces/Y.sol` must be available
    under `src/` just like they are in isolated runs.
    """
    package_root = _benchmark_source_package_root(source_path)
    if not package_root:
        return
    contracts_root = package_root / "contracts"
    if contracts_root.exists() and contracts_root.is_dir():
        for child in sorted(contracts_root.iterdir()):
            dst = src_dir / child.name
            if child.is_dir():
                shutil.copytree(child, dst, dirs_exist_ok=True)
            elif child.is_file():
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(child, dst)
        for sol_file in sorted(contracts_root.rglob("*.sol")):
            dst = src_dir / sol_file.name
            if not dst.exists():
                shutil.copy2(sol_file, dst)
    for scope_dir in sorted(package_root.glob("@*")):
        if scope_dir.is_dir():
            shutil.copytree(scope_dir, src_dir.parent / scope_dir.name, dirs_exist_ok=True)

def _copy_source_for_foundry(args, dst_src: Path) -> None:
    dst_src.parent.mkdir(parents=True, exist_ok=True)
    _copy_package_sources_for_foundry(args.source, dst_src.parent)
    if Path(args.source).resolve() == dst_src.resolve():
        return
    dst_src.write_text(
        read_source_with_legacy_compatibility(args.source, getattr(args, "solc", "")),
        encoding="utf-8",
    )


def _finalize_functional_seeds(functional_meta_dir: Path, seeds: List[Dict[str, Any]], abi: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Last-mile guard for seeds.json.

    The extractor already sanitizes Foundry-derived seeds. This second pass is
    intentionally redundant and cheap: it protects the fuzzer-facing artifact if
    a future extractor path returns raw candidates or partially-normalized data.
    """
    clean_seeds, report = sanitize_seeds_for_fuzzer(seeds or [], abi or [])
    guard_path = functional_meta_dir / "seed_write_guard.json"
    try:
        guard_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    except Exception:
        pass
    return clean_seeds

def run_functional_pipeline(root, args, comp, feats, source_code, invariant_result,
                            planner_facts, api_key, api_url, model):
    artifact_name = args.artifact_name or comp["contract"]

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

        functional_llm_plan = {"name": "LLM-Plan", "sequences": []}
        functional_perfn_plan = {"name": "LLM-PerFn", "sequences": []}

        for future in as_completed([future_main, future_perfn]):
            try:
                future_result = future.result()
                if future is future_main:
                    functional_llm_plan = future_result if isinstance(future_result, dict) else {"name": "LLM-Plan", "sequences": []}
                elif future is future_perfn:
                    functional_perfn_plan = future_result if isinstance(future_result, dict) else {"name": "LLM-PerFn", "sequences": []}
            except Exception as e:
                if future is future_main:
                    print(f"[functional_test] llm_plan failed: {e}")
                elif future is future_perfn:
                    print(f"[functional_test] perfn_plan failed: {e}")

    functional_stds: List[Any] = []
    if len(feats["standards"]) > 0:
        functional_stds.extend(feats["standards"] or [])
    if functional_llm_plan.get("sequences"):
        functional_stds.append(functional_llm_plan)
    if functional_perfn_plan.get("sequences"):
        functional_stds.append(functional_perfn_plan)

    functional_stds = normalize_stds(functional_stds, comp["abi"])
    functional_stds = resolve_post_conditions_against_abi(functional_stds, comp["abi"])

    functional_test_content = gen_tests_from_abi(
        contract_name=comp["contract"],
        abi=comp["abi"],
        standards=functional_stds,
        solc_version=args.solc,
        source_path=args.source
    )
    functional_test_content = _repair_target_call_argument_casts(
        functional_test_content,
        _read_source_package_declaration_text(args.source, source_code),
        pre_08=not (_parse_solc_version(args.solc)[0] >= 1 or _parse_solc_version(args.solc)[1] >= 8),
        contract_name=comp["contract"],
    )

    test_dir = Path(root) / "test"
    functional_test_path = write_foundry_test(
        test_dir, comp["contract"], functional_test_content, test_kind="functional", artifact_name=artifact_name
    )
    print(f"[functional_test] wrote test: {functional_test_path}")

    src_dir = Path(root) / "src"
    src_dir.mkdir(parents=True, exist_ok=True)
    dst_src = src_dir / Path(args.source).name
    _copy_source_for_foundry(args, dst_src)
    print(f"[functional_test] ensured source in src/: {dst_src}")

    functional_results, functional_trace_text = run_foundry_tests(
        project_root=root,
        contract_name=comp["contract"],
        testfile_path=str(functional_test_path),
        forge_path=args.forge,
        profile=getattr(args, "profile", None),
        is_invariant_test=False,
        test_kind="functional",
        source_path=args.source,
        artifact_name=artifact_name,
        validate_minimization=getattr(args, "validate_minimization", None),
        minimization_timeout=getattr(args, "minimization_timeout", None),
        solc_version=args.solc,
        evm_version=args.evm,
    )

    functional_meta_dir = get_test_meta_subdir(root, artifact_name, "functional")

    functional_sig = minimal_coverage_signature(
        functional_results, functional_trace_text, abi=comp["abi"]
    )
    functional_sig_path = write_signature(functional_meta_dir, functional_sig)
    print(f"[functional_test] wrote coverage signature: {functional_sig_path}")

    try:
        functional_report_result = llm_generate_report_and_seeds(
            comp["contract"],
            comp["abi"],
            comp["function_signature_mapping"],
            feats["standards"],
            api_key=api_key,
            api_url=api_url,
            model=model
        )
        functional_report_text = functional_report_result["report"]
    except Exception as exc:
        # Reporting is advisory. Preserve the completed Foundry run and let the
        # deterministic trace-to-seed extractor feed the fuzzing stage.
        functional_report_text = (
            "LLM functional report unavailable; Foundry results and extracted "
            f"seeds remain valid. Error: {exc}"
        )
        print(f"[functional_test] LLM report unavailable; continuing with Foundry seed extraction: {exc}")

    functional_report_path = write_report(functional_meta_dir, functional_report_text)
    print(f"[functional_test] wrote report: {functional_report_path}")

    functional_meta_dir = get_test_meta_subdir(root, artifact_name, "functional")
    try:
        functional_seeds = extract_success_seeds_from_files(
            project_root=root,
            testfile_path=str(functional_test_path),
            comp_obj_or_path=comp,
            source_path=args.source,
            meta_dir=str(functional_meta_dir),
            test_kind="functional",
        )
    except Exception as e:
        functional_seeds = []
        extraction_error_path = functional_meta_dir / "seed_extraction_error.txt"
        extraction_error_path.write_text(str(e), encoding="utf-8")
        print(f"[functional_test] seed extraction failed; wrote empty seeds: {extraction_error_path}")

    functional_seeds = _finalize_functional_seeds(functional_meta_dir, functional_seeds, comp["abi"])
    functional_seeds_path = write_seeds(functional_meta_dir, functional_seeds)
    discarded_report = functional_meta_dir / "discarded_seeds.json"
    if discarded_report.exists():
        try:
            seed_report = json.loads(discarded_report.read_text(encoding="utf-8"))
            print(
                "[functional_test] seed sanitizer: "
                f"{seed_report.get('valid_count', len(functional_seeds))}/"
                f"{seed_report.get('candidate_count', len(functional_seeds))} valid, "
                f"{seed_report.get('discarded_count', 0)} discarded"
            )
        except Exception:
            pass
    print(f"[functional_test] wrote seeds: {functional_seeds_path}")

    return {
        "test_path": functional_test_path,
        "results": functional_results,
        "trace_text": functional_trace_text,
        "meta_dir": str(functional_meta_dir),
        "signature_path": functional_sig_path,
        "report_path": functional_report_path,
        "seeds_path": functional_seeds_path,
    }

def run_invariant_pipeline(root, args, comp, source_code, invariant_result,
                           api_key, api_url, model):
    artifact_name = args.artifact_name or comp["contract"]

    try:
        invariant_completed_result = complete_invariants_with_llm(
            source_code=source_code,
            api_key=api_key,
            api_url=api_url,
            model=model,
            invariant_result=invariant_result,
        )
    except Exception as exc:
        # LLM candidates extend the static candidates but are not required by
        # deterministic supplements. Keep those checks executable when the
        # external service is temporarily unavailable.
        invariant_completed_result = dict(invariant_result)
        invariant_completed_result["llm_candidates"] = []
        invariant_completed_result["llm_rejected"] = []
        invariant_completed_result["llm_codegen_candidates"] = []
        print(f"[invariant_test] LLM completion unavailable; continuing with static invariants: {exc}")

    invariant_gen_result = generate_foundry_invariant_tests(
        contract_name=comp["contract"],
        source_path=args.source,
        abi=comp["abi"],
        solc_version=args.solc,
        invariant_result=invariant_completed_result,
        dump_dir="./debug_out/" + str(artifact_name) + "/",
        dump_prefix="baseline_",
        return_analysis=True,
        supplement_base_stem=artifact_name,
    )

    invariant_test_content = invariant_gen_result["foundry_code"]
    invariant_supplement_content = invariant_gen_result.get("foundry_supplement_code") or ""
    invariant_analysis = invariant_gen_result["analysis"]

    test_dir = Path(root) / "test"
    invariant_test_path = write_foundry_test(
        test_dir, comp["contract"], invariant_test_content, test_kind="invariant", artifact_name=artifact_name
    )
    print(f"[invariant_test] wrote test: {invariant_test_path}")

    invariant_supplement_test_path = None
    if invariant_supplement_content and getattr(args, "write_invariant_supplements", True):
        supplement_path = test_dir / f"{artifact_name}_InvariantSupplement.t.sol"
        supplement_path.write_text(invariant_supplement_content, encoding="utf-8")
        invariant_supplement_test_path = str(supplement_path)
        print(f"[invariant_test] wrote supplement test: {invariant_supplement_test_path}")

    src_dir = Path(root) / "src"
    src_dir.mkdir(parents=True, exist_ok=True)
    dst_src = src_dir / Path(args.source).name
    _copy_source_for_foundry(args, dst_src)
    print(f"[invariant_test] ensured source in src/: {dst_src}")

    invariant_results, invariant_trace_text = run_foundry_tests(
        project_root=root,
        contract_name=comp["contract"],
        testfile_path=str(invariant_test_path),
        forge_path=args.forge,
        profile=getattr(args, "profile", None),
        is_invariant_test=True,
        test_kind="invariant",
        source_path=args.source,
        artifact_name=artifact_name,
        validate_minimization=getattr(args, "validate_minimization", None),
        minimization_timeout=getattr(args, "minimization_timeout", None),
        solc_version=args.solc,
        evm_version=args.evm,
    )

    supplement_results = None
    supplement_trace_text = ""
    supplement_meta_dir = None
    if invariant_supplement_test_path and getattr(args, "run_invariant_supplements", False):
        supplement_artifact_name = f"{artifact_name}_supplement"
        supplement_results, supplement_trace_text = run_foundry_tests(
            project_root=root,
            contract_name=comp["contract"],
            testfile_path=str(invariant_supplement_test_path),
            forge_path=args.forge,
            profile=getattr(args, "profile", None),
            is_invariant_test=True,
            test_kind="invariant",
            source_path=args.source,
            artifact_name=supplement_artifact_name,
            validate_minimization=getattr(args, "validate_minimization", None),
            minimization_timeout=getattr(args, "minimization_timeout", None),
            solc_version=args.solc,
            evm_version=args.evm,
        )
        supplement_meta_dir = get_test_meta_subdir(root, supplement_artifact_name, "invariant")

    invariant_meta_dir = get_test_meta_subdir(root, artifact_name, "invariant")

    # 可选：保存分析结果
    (invariant_meta_dir / "analysis.json").write_text(
        json.dumps(invariant_analysis, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )
    if isinstance(invariant_analysis, dict) and invariant_analysis.get("uir_targets"):
        (invariant_meta_dir / "uir_targets.json").write_text(
            json.dumps(invariant_analysis["uir_targets"], indent=2, ensure_ascii=False),
            encoding="utf-8"
        )
    if invariant_gen_result.get("foundry_supplement"):
        supplement_meta = dict(invariant_gen_result["foundry_supplement"])
        supplement_meta["base_artifact_name"] = artifact_name
        if supplement_meta.get("mode") == "inline_appended_to_invariant_file":
            supplement_meta["supplement_artifact_name"] = artifact_name
        else:
            supplement_meta["supplement_artifact_name"] = f"{artifact_name}_supplement"
        (invariant_meta_dir / "foundry_supplement.json").write_text(
            json.dumps(supplement_meta, indent=2, ensure_ascii=False),
            encoding="utf-8"
        )
        if supplement_meta_dir:
            (supplement_meta_dir / "foundry_supplement.json").write_text(
                json.dumps(supplement_meta, indent=2, ensure_ascii=False),
                encoding="utf-8"
            )
    if invariant_supplement_content:
        (invariant_meta_dir / "generated_supplement.t.sol").write_text(
            invariant_supplement_content,
            encoding="utf-8"
        )
        if supplement_meta_dir:
            (supplement_meta_dir / "generated_supplement.t.sol").write_text(
                invariant_supplement_content,
                encoding="utf-8"
            )

    return {
        "completed_result": invariant_completed_result,
        "gen_result": invariant_gen_result,
        "analysis": invariant_analysis,
        "test_path": invariant_test_path,
        "supplement_test_path": invariant_supplement_test_path,
        "results": invariant_results,
        "supplement_results": supplement_results,
        "trace_text": invariant_trace_text,
        "supplement_trace_text": supplement_trace_text,
        "meta_dir": str(invariant_meta_dir),
        "supplement_meta_dir": str(supplement_meta_dir) if supplement_meta_dir else None,
    }

def main():
    ap = argparse.ArgumentParser("func-test pipeline")
    ap.add_argument("-s", "--source", required=True, help="Solidity source file path")
    ap.add_argument("-c", "--contract", default=None, help="Contract name in source")
    ap.add_argument("--solc", default="v0.8.24", help="solc version, e.g., v0.8.24")
    ap.add_argument("--evm", help="Ethereum VM (default '" + str(settings.EVM_VERSION) + "'). Available VM's: 'homestead', 'byzantium' or 'petersburg'.")
    ap.add_argument("--project-root", default=".", help="Foundry project root (forge.toml 所在目录)")
    ap.add_argument("--artifact-name", default=None,
                    help="Unique file/meta directory stem for generated artifacts. Defaults to contract name.")
    ap.add_argument("--forge", default=None, help="path to forge/forge.exe (optional)")
    ap.add_argument("-k", "--topk", type=int, default=32, help="Top-K seeds to keep")
    ap.add_argument("--api-key", default=None, help="LLM API Key override. Defaults to LLM_API_KEY from .env.")
    ap.add_argument("--env-file", default=None, help="Path to env file for LLM_API_KEY/LLM_API_URL/LLM_MODEL. Defaults to .env.")
    ap.add_argument("--validate-minimization", action="store_true", default=None,
                    help="Run external oracles for finding_cases_pro minimization/reproduction validation.")
    ap.add_argument("--minimization-timeout", type=int, default=None,
                    help="Timeout in seconds for each external minimization oracle run.")
    ap.add_argument("--no-write-invariant-supplements", dest="write_invariant_supplements",
                    action="store_false", default=True,
                    help="Do not write the separate *_InvariantSupplement.t.sol file.")
    ap.add_argument("--run-invariant-supplements", action="store_true", default=False,
                    help="Run the generated *_InvariantSupplement.t.sol file in addition to the baseline invariant test.")
    ap.add_argument("--functional-only", action="store_true", default=False,
                    help="Stop after functional Foundry tests and seed extraction; do not run invariant tests.")
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
    try:
        cfg.build(comp["runtime_bytecode"], settings.EVM_VERSION)
    except Exception as e:
        print(f"[func_test] cfg build failed; continuing with empty CFG: {e}")

    ast_only_recovery = os.environ.get("SEMINV_ABLATION_AST_ONLY_RECOVERY", "").strip().lower() in {"1", "true", "yes", "on"}
    storage_layout = None if ast_only_recovery else comp.get("storage_layout")
    solc_ir = None if ast_only_recovery else comp.get("solc_ir")
    solc_ir_optimized = None if ast_only_recovery else comp.get("solc_ir_optimized")
    legacy_assembly = None if ast_only_recovery else comp.get("legacy_assembly")
    compiler_artifacts = None if ast_only_recovery else comp.get("compiler_artifacts")

    print("[CLI->InvariantGen] ast_only_recovery:", ast_only_recovery)
    print("[CLI->InvariantGen] passing storage_layout:", storage_layout is not None)
    print("[CLI->InvariantGen] passing solc_ir:", bool(solc_ir))
    print("[CLI->InvariantGen] passing solc_ir_optimized:", bool(solc_ir_optimized))

    # IR构建
    ir_result = build_contract_ir(
        contract_name=comp["contract"],
        source_path=args.source,
        source_code=source_code,
        abi=comp["abi"],
        ast=comp["ast"],
        cfg=cfg,
        solc_version=args.solc,
        storage_layout=storage_layout,
        solc_ir=solc_ir,
        solc_ir_optimized=solc_ir_optimized,
        legacy_assembly=legacy_assembly,
        compiler_artifacts=compiler_artifacts,
    )

    # 不变量恢复
    invariant_result = recover_invariants(
        contract_name=comp["contract"],
        source_path=args.source,
        cfg=cfg,
        solc_version=args.solc,
        ir_build_result=ir_result,
    )

    # 从静态分析结果提取“测试规划友好”的事实
    planner_facts = build_planner_facts_from_ir(invariant_result)
    print("[func_test] planner_facts:", planner_facts)
    
    # t_llm_start = time.time()

    # t_llm_end = time.time()

    # print(f"[TIME] LLM stage: {t_llm_end - t_llm_start:.3f}s")

    # 先保证源码复制到 src/ 一次即可，也可以放在两个 pipeline 里各自做
    src_dir = Path(root) / "src"
    src_dir.mkdir(parents=True, exist_ok=True)
    dst_src = src_dir / Path(args.source).name
    _copy_source_for_foundry(args, dst_src)
    print(f"[main] ensured source in src/: {dst_src}")

    if args.functional_only:
        functional_output = run_functional_pipeline(
            root, args, comp, feats, source_code, invariant_result,
            planner_facts, api_key, api_url, model
        )
        print("[main] functional_output:", functional_output["meta_dir"])
        print("[main] functional_only: invariant pipeline skipped")
        return

    with ThreadPoolExecutor(max_workers=2) as executor:
        future_functional = executor.submit(
            run_functional_pipeline,
            root, args, comp, feats, source_code, invariant_result,
            planner_facts, api_key, api_url, model
        )

        future_invariant = executor.submit(
            run_invariant_pipeline,
            root, args, comp, source_code, invariant_result,
            api_key, api_url, model
        )

        try:
            functional_output = future_functional.result()
        except Exception as exc:
            functional_meta_dir = Path(root) / f"{args.artifact_name}_meta" / "functional_test"
            functional_meta_dir.mkdir(parents=True, exist_ok=True)
            summary_path = functional_meta_dir / "summary.json"
            summary_path.write_text(
                json.dumps(
                    {
                        "status": "degraded",
                        "error": str(exc),
                        "total": 0,
                        "passed": 0,
                        "failed": 0,
                    },
                    indent=2,
                    ensure_ascii=False,
                ),
                encoding="utf-8",
            )
            functional_output = {"meta_dir": str(functional_meta_dir), "degraded": True}
            print(f"[main] functional pipeline degraded: {exc}", file=sys.stderr)
        try:
            invariant_output = future_invariant.result()
        except Exception as exc:
            invariant_meta_dir = Path(root) / f"{args.artifact_name}_meta" / "invariant_test"
            invariant_meta_dir.mkdir(parents=True, exist_ok=True)
            summary_path = invariant_meta_dir / "summary.json"
            summary_path.write_text(
                json.dumps(
                    {
                        "status": "degraded",
                        "error": str(exc),
                        "tests": 0,
                        "passed": 0,
                        "failed": 0,
                    },
                    indent=2,
                    ensure_ascii=False,
                ),
                encoding="utf-8",
            )
            invariant_output = {"meta_dir": str(invariant_meta_dir), "degraded": True}
            print(f"[main] invariant pipeline degraded: {exc}", file=sys.stderr)

    print("[main] functional_output:", functional_output["meta_dir"])
    print("[main] invariant_output:", invariant_output["meta_dir"])

if __name__ == "__main__":
    main()
