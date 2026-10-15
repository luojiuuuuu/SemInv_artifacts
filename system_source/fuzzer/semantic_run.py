#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Unified semantic-invariant pipeline entrypoint.

This wrapper keeps the long research command profile in one place and exposes a
small paper-facing interface:

    python -m fuzzer.semantic_run -s path/to/Contract.sol -c Contract --solc v0.8.0
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional

from fuzzer.error_classification import (
    ABSTRACT_OR_BASE_CONTRACT,
    EMPTY_ABI_OR_NO_EXTERNAL_ENTRY,
    NO_DEPLOYABLE_CONTRACT,
    classify_l1_l3_error,
)
from fuzzer.static_source_detectors import emit_static_source_findings
from fuzzer.process_utils import run_in_process_group
from fuzzer.reporting.t_policy import POLICY, POLICY_VERSION

UNTESTABLE_CONTRACT_SELECTION_ERRORS = {
    EMPTY_ABI_OR_NO_EXTERNAL_ENTRY,
    ABSTRACT_OR_BASE_CONTRACT,
    NO_DEPLOYABLE_CONTRACT,
}


DEFAULT_PROFILE: Dict[str, Any] = {
    "schema_version": "semantic-invariant.run_profile.v1",
    "name": "semantic-invariant-default",
    "description": "Default end-to-end L3-L6 semantic invariant detection profile.",
    "func_test": {
        "project_root": "foundry",
        "validate_minimization": True,
        "minimization_timeout": 60,
        "run_invariant_supplements": True,
    },
    "fuzz": {
        "generations": 10,
        "seed_strategy": "prepend",
        "data_dependency": 0,
        "uir_solving": True,
        "uir_solving_plateau": 8,
        "solver_branch_plateau": 2,
        "solver_high_risk_branch_age": 3,
        "solver_max_branches_per_call": 3,
        "solver_max_call_ms": 500,
        "solver_branch_cooldown": 2,
        "uir_mutation": True,
        "uir_mutation_rate": 0.10,
        "uir_mutation_insert_rate": 0,
        "solver_uir_priority": "light",
        "solver_targeted_seeds": True,
        "solver_targeted_seeds_per_call": 1,
        "solver_targeted_seed_injection": 2,
        "solver_targeted_seed_queue": 16,
        "solver_targeted_seed_mode": "valuable",
        "solver_abi_constraints": True,
        "vulnerability_hints": True,
        "vulnerability_hint_static_probes": 32,
        "vulnerability_hint_injection": 2,
        "vulnerability_hint_queue": 32,
        "validate_minimization": True,
        "minimization_timeout": 60,
        "llm_rca": True,
    },
}


def _profile_timeout(cli_value: Optional[int], default_value: int) -> int:
    return cli_value if cli_value is not None else default_value


COPY_GROUPS = {
    "functional_test": [
        "summary.json",
        "coverage_global.json",
        "seeds.json",
        "seed_write_guard.json",
        "discarded_seeds.json",
        "llm_report.txt",
        "failed_tests.json",
        "failed_test_details.json",
        "fallback_diagnostic.txt",
        "compile_error.txt",
        "json_parse_error.txt",
        "last_trace.txt",
        "last_stderr.txt",
        "all_test_results.json",
    ],
    "l3_foundry": [
        "summary.json",
        "foundry_supplement.json",
        "analysis.json",
        "uir_targets.json",
        "failure_report.json",
        "failure_report.txt",
        "failed_tests.json",
        "failed_test_details.json",
        "finding_report.json",
        "fallback_diagnostic.txt",
        "compile_error.txt",
        "json_parse_error.txt",
        "last_trace.txt",
        "last_stderr.txt",
    ],
    "l4_fuzz": [
        "gen0_generated_individuals.json",
        "gen0_highlevel.json",
        "uir_coverage.json",
        "vulnerability_hint_stats.json",
        "foundry_finding_report.json",
    ],
    "l5_events": [
        "finding_index.json",
        "violation_events.json",
    ],
    "l6_replay": [
        "hybrid_replay_report.json",
    ],
    "report": [
        "semantic_invariant_report.json",
        "semantic_invariant_report.md",
        "llm_root_cause_report.json",
    ],
}


def _json_load(path: Path) -> Dict[str, Any]:
    try:
        path = Path(_long_path(path))
        if path.exists():
            data = json.loads(path.read_text(encoding="utf-8"))
            return data if isinstance(data, dict) else {}
    except Exception:
        return {}
    return {}


def _copy_file(src: Path, dst: Path) -> Optional[str]:
    src = Path(_long_path(src))
    if not src.exists() or not src.is_file():
        return None
    _mkdir(dst.parent)
    if sys.platform == "win32":
        shutil.copy2(_long_path(src), _long_path(dst))
    else:
        shutil.copy2(src, dst)
    return str(dst)


def _long_path(path: Path) -> str:
    resolved = str(path.resolve())
    if sys.platform != "win32" or resolved.startswith("\\\\?\\"):
        return resolved
    if resolved.startswith("\\\\"):
        return "\\\\?\\UNC\\" + resolved.lstrip("\\")
    return "\\\\?\\" + resolved


def _mkdir(path: Path) -> None:
    if sys.platform == "win32":
        Path(_long_path(path)).mkdir(parents=True, exist_ok=True)
    else:
        path.mkdir(parents=True, exist_ok=True)


def _unlink(path: Path) -> None:
    if sys.platform == "win32":
        Path(_long_path(path)).unlink()
    else:
        path.unlink()


def _remove_tree(path: Path, *, ignore_errors: bool = False) -> None:
    if not path.exists():
        return
    try:
        shutil.rmtree(path, ignore_errors=ignore_errors)
    except OSError:
        if sys.platform == "win32":
            shutil.rmtree(_long_path(path), ignore_errors=ignore_errors)
        elif not ignore_errors:
            raise
    if sys.platform == "win32" and path.exists():
        shutil.rmtree(_long_path(path), ignore_errors=ignore_errors)


def _copy_tree(src: Path, dst: Path) -> Optional[str]:
    src = Path(_long_path(src))
    if not src.exists() or not src.is_dir():
        return None
    if dst.exists():
        _remove_tree(dst)
    _mkdir(dst.parent)
    try:
        shutil.copytree(src, dst)
        return str(dst)
    except (OSError, shutil.Error) as first_error:
        if dst.exists():
            _remove_tree(dst, ignore_errors=True)
        errors: List[Dict[str, str]] = []
        _mkdir(dst)
        for item in src.rglob("*"):
            rel = item.relative_to(src)
            target = dst / rel
            try:
                if item.is_dir():
                    _mkdir(target)
                    continue
                _mkdir(target.parent)
                if sys.platform == "win32":
                    shutil.copy2(_long_path(item), _long_path(target))
                else:
                    shutil.copy2(item, target)
            except Exception as exc:
                errors.append({
                    "source": str(item),
                    "destination": str(target),
                    "error": repr(exc),
                })
        if errors:
            error_path = dst.parent / f"{dst.name}_copy_errors.json"
            _mkdir(error_path.parent)
            error_path.write_text(json.dumps({
                "initial_error": repr(first_error),
                "error_count": len(errors),
                "errors": errors,
            }, indent=2), encoding="utf-8")
    return str(dst)


def _count_failed(summary: Dict[str, Any]) -> int:
    if "fail" in summary:
        return int(summary.get("fail") or 0)
    if "failed" in summary:
        return int(summary.get("failed") or 0)
    failed_tests = summary.get("failed_tests")
    return len(failed_tests or []) if isinstance(failed_tests, list) else 0


def _count_total(summary: Dict[str, Any]) -> int:
    return int(summary.get("total") or summary.get("test_count") or 0)


def _count_passed(summary: Dict[str, Any]) -> int:
    if "pass" in summary:
        return int(summary.get("pass") or 0)
    if "passed" in summary:
        return int(summary.get("passed") or 0)
    total = _count_total(summary)
    return max(0, total - _count_failed(summary))


def _parse_solc_version(solc_version: str) -> tuple:
    raw = str(solc_version or "").strip().lower()
    if raw.startswith("v"):
        raw = raw[1:]
    nums: List[int] = []
    for part in raw.split(".")[:3]:
        try:
            nums.append(int(part))
        except Exception:
            nums.append(0)
    while len(nums) < 3:
        nums.append(0)
    return tuple(nums)


def choose_foundry_evm(solc_version: str) -> str:
    """Pick a Foundry-only EVM version compatible with generated tests.

    L4 fuzzing still uses the user supplied --evm. Foundry tests import
    forge-std, whose current implementation uses opcodes such as SHL and
    CHAINID, so modern Solidity tests need at least Istanbul even when the L4
    local VM is intentionally kept at byzantium/petersburg.
    """
    version = _parse_solc_version(solc_version)
    if version >= (0, 6, 2):
        return "istanbul"
    if version >= (0, 5, 0):
        return "petersburg"
    if version >= (0, 4, 22):
        return "byzantium"
    return "homestead"


class SemanticRun:
    def __init__(self, args: argparse.Namespace) -> None:
        self.args = args
        self.fp_filter_mode = str(getattr(args, "fp_filter", "evidence-safe") or "evidence-safe")
        os.environ["SEMINV_FP_FILTER"] = self.fp_filter_mode
        self.cwd = Path.cwd()
        self.source = Path(args.source)
        self.contract = args.contract
        self.artifact_name = args.artifact_name or self.contract
        self.project_root = Path(args.project_root)
        self.foundry_evm = choose_foundry_evm(args.solc)
        self.l4_fuzz_evm = args.evm
        self.source_meta_dir = self.source.parent / f"{self.contract}_meta"
        self.foundry_meta_dir = self.project_root / f"{self.artifact_name}_meta"
        self.functional_meta_dir = self.foundry_meta_dir / "functional_test"
        self.invariant_meta_dir = self.foundry_meta_dir / "invariant_test"
        self.processed_dir = self.source_meta_dir / "finding_cases_pro"

        self.output_stem = f"{self.source.stem}_outputs"
        if args.run_dir:
            self.run_dir = Path(args.run_dir)
        elif args.output_root:
            run_id = args.run_id or datetime.now().strftime("%Y%m%d_%H%M%S")
            self.run_dir = Path(args.output_root) / f"{self.contract}_{run_id}"
        else:
            base_output_dir = self.source.parent / self.output_stem
            self.run_dir = base_output_dir / args.run_id if args.run_id else base_output_dir
        if args.run_dir or args.output_root:
            self.source_meta_dir = self.run_dir / "source_meta"
            self.processed_dir = self.source_meta_dir / "finding_cases_pro"
        self.logs_dir = self.run_dir / "logs"
        self.artifacts_dir = self.run_dir / "artifacts"
        self.report_dir = self.run_dir / "report"
        self.manifest: Dict[str, Any] = {
            "schema_version": "semantic-invariant.run_manifest.v1",
            "profile": DEFAULT_PROFILE,
            "source": str(self.source),
            "contract": self.contract,
            "artifact_name": self.artifact_name,
            "solc": args.solc,
            "evm": args.evm,
            "foundry_evm": self.foundry_evm,
            "l4_fuzz_evm": self.l4_fuzz_evm,
            "fp_filter_mode": self.fp_filter_mode,
            "reporting_policy": POLICY,
            "reporting_policy_version": POLICY_VERSION,
            "evm_selection_policy": "Foundry EVM is selected from solc version; L4 fuzz EVM uses the user supplied --evm.",
            "run_dir": str(self.run_dir),
            "output_layout": {
                "mode": "explicit_run_dir" if args.run_dir else ("source_adjacent" if not args.output_root else "custom_output_root"),
                "source_adjacent_dir": str(self.source.parent / self.output_stem),
                "output_root": str(args.output_root) if args.output_root else None,
                "run_id": args.run_id,
                "run_dir": str(args.run_dir) if args.run_dir else None,
            },
            "started_at": int(time.time()),
            "stages": [],
            "artifacts": {},
        }

    def prepare(self) -> None:
        for path in (self.run_dir, self.logs_dir, self.artifacts_dir, self.report_dir):
            _mkdir(path)
        for name in ("l1_l3_foundry", "l4_l6_fuzz"):
            _mkdir(self.logs_dir / name)
        for relative in (
            "stage_stdout.log",
            "stage_stderr.log",
            "pipeline.log",
            "warnings.log",
            "errors.log",
            "l1_l3_foundry/stdout.log",
            "l1_l3_foundry/stderr.log",
            "l4_l6_fuzz/stdout.log",
            "l4_l6_fuzz/stderr.log",
            "l1_l3_foundry_stdout.log",
            "l1_l3_foundry_stderr.log",
            "l4_l6_fuzz_stdout.log",
            "l4_l6_fuzz_stderr.log",
        ):
            stale = self.logs_dir / relative
            if stale.exists() and stale.is_file():
                _unlink(stale)

    def _append_log(self, relative_path: str, text: str) -> None:
        path = self.logs_dir / relative_path
        _mkdir(path.parent)
        open_path = _long_path(path) if sys.platform == "win32" else path
        with open(open_path, "a", encoding="utf-8") as handle:
            handle.write(text.rstrip("\n") + "\n")

    def _pipeline_event(self, event: str, **payload: Any) -> None:
        record = {
            "ts": datetime.now().isoformat(timespec="seconds"),
            "event": event,
            **payload,
        }
        self._append_log("pipeline.log", json.dumps(record, ensure_ascii=False))

    def _stage_error(self, message: str, **payload: Any) -> None:
        record = {
            "ts": datetime.now().isoformat(timespec="seconds"),
            "message": message,
            **payload,
        }
        self._append_log("stage_stderr.log", message)
        self._append_log("errors.log", json.dumps(record, ensure_ascii=False))

    def _stage_warning(self, message: str, **payload: Any) -> None:
        record = {
            "ts": datetime.now().isoformat(timespec="seconds"),
            "message": message,
            **payload,
        }
        self._append_log("warnings.log", json.dumps(record, ensure_ascii=False))

    def stage(self, index: int, total: int, name: str, details: Iterable[str] = ()) -> None:
        header = f"[{index}/{total}] {name}"
        print(header, flush=True)
        self._append_log("stage_stdout.log", header)
        for line in details:
            rendered = f"  {line}"
            print(rendered, flush=True)
            self._append_log("stage_stdout.log", rendered)
        self._pipeline_event("stage", index=index, total=total, name=name, details=list(details))

    def _run_command(self, name: str, cmd: List[str], timeout_seconds: Optional[int] = None) -> int:
        stage_log_dir = self.logs_dir / name
        stage_log_dir.mkdir(parents=True, exist_ok=True)
        stdout_path = stage_log_dir / "stdout.log"
        stderr_path = stage_log_dir / "stderr.log"
        start = time.time()
        self._pipeline_event(
            "command_start",
            stage=name,
            command=cmd,
            stdout=str(stdout_path),
            stderr=str(stderr_path),
        )
        timed_out = False
        returncode = 0
        with stdout_path.open("w", encoding="utf-8") as stdout, stderr_path.open("w", encoding="utf-8") as stderr:
            try:
                proc = run_in_process_group(
                    cmd,
                    cwd=str(self.cwd),
                    stdout=stdout,
                    stderr=stderr,
                    text=True,
                    timeout=timeout_seconds if timeout_seconds and timeout_seconds > 0 else None,
                )
                returncode = int(proc.returncode)
            except subprocess.TimeoutExpired as exc:
                timed_out = True
                returncode = 124
                stderr.write(f"\n[TIMEOUT] {name} exceeded {timeout_seconds} seconds\n")
                if exc.stdout:
                    stdout.write(str(exc.stdout))
                if exc.stderr:
                    stderr.write(str(exc.stderr))
        elapsed = time.time() - start
        stderr_nonempty = stderr_path.exists() and stderr_path.stat().st_size > 0
        self.manifest["stages"].append({
            "name": name,
            "command": cmd,
            "returncode": returncode,
            "elapsed_seconds": round(elapsed, 3),
            "stdout": str(stdout_path),
            "stderr": str(stderr_path),
            "stderr_nonempty": stderr_nonempty,
            "timeout_seconds": timeout_seconds if timeout_seconds and timeout_seconds > 0 else None,
            "timed_out": timed_out,
        })
        self._pipeline_event(
            "command_finish",
            stage=name,
            returncode=returncode,
            elapsed_seconds=round(elapsed, 3),
            stdout=str(stdout_path),
            stderr=str(stderr_path),
            stderr_nonempty=stderr_nonempty,
            timeout_seconds=timeout_seconds if timeout_seconds and timeout_seconds > 0 else None,
            timed_out=timed_out,
        )
        if returncode != 0:
            self._stage_error(
                f"{name} failed with return code {returncode}. See {stderr_path}",
                stage=name,
                returncode=returncode,
                stderr=str(stderr_path),
            )
        elif stderr_nonempty:
            self._stage_warning(
                f"{name} wrote non-fatal backend stderr. See {stderr_path}",
                stage=name,
                stderr=str(stderr_path),
            )
        return returncode

    def func_test_command(self) -> List[str]:
        cfg = DEFAULT_PROFILE["func_test"]
        cmd = [
            sys.executable,
            "-m",
            "fuzzer.func_test.cli",
            "-s",
            str(self.source),
            "-c",
            self.contract,
            "--solc",
            self.args.solc,
            "--evm",
            self.foundry_evm,
            "--project-root",
            str(self.project_root),
            "--artifact-name",
            self.artifact_name,
        ]
        if cfg["validate_minimization"] and not self.args.no_validate_minimization:
            cmd.append("--validate-minimization")
        timeout = _profile_timeout(self.args.minimization_timeout, cfg["minimization_timeout"])
        cmd.extend(["--minimization-timeout", str(timeout)])
        if cfg["run_invariant_supplements"]:
            cmd.append("--run-invariant-supplements")
        if self.args.ablation_functional_only:
            cmd.append("--functional-only")
        if self.args.env_file:
            cmd.extend(["--env-file", self.args.env_file])
        return cmd

    def fuzz_command(self) -> List[str]:
        cfg = dict(DEFAULT_PROFILE["fuzz"])
        generations = self.args.generations if self.args.generations is not None else cfg["generations"]
        timeout = _profile_timeout(self.args.minimization_timeout, cfg["minimization_timeout"])
        seeds = self.args.seeds or str(self.functional_meta_dir / "seeds.json")
        seed_policy = (self.manifest.get("l1_l3_downgraded") or {}).get("policy")
        use_random_seed_fallback = (
            self.args.ablation_no_functional_seeds
            or self.args.ablation_skip_foundry
            or self.args.ablation_abi_random_baseline
            or seed_policy == "continue_l4_without_functional_seeds_random_fallback"
        )
        seed_strategy = "random" if use_random_seed_fallback else cfg["seed_strategy"]
        use_uir = not (self.args.ablation_no_uir or self.args.ablation_abi_random_baseline)
        use_symbolic = not (self.args.ablation_no_symbolic or self.args.ablation_abi_random_baseline)
        use_hints = not (self.args.ablation_no_vulnerability_hints or self.args.ablation_abi_random_baseline)
        cmd = [
            sys.executable,
            "-m",
            "fuzzer.main",
            "-s",
            str(self.source),
            "-c",
            self.contract,
            "--solc",
            self.args.solc,
            "--evm",
            self.l4_fuzz_evm,
            "-g",
            str(generations),
            "--seed-strategy",
            seed_strategy,
            "--gen0-output-dir",
            str(self.artifacts_dir / "l4_fuzz"),
            "-r",
            str(self.artifacts_dir / "l4_fuzz" / "results.json"),
            "--data-dependency",
            str(cfg["data_dependency"] if not self.args.ablation_abi_random_baseline else 0),
            "--constraint-solving",
            "1" if use_symbolic else "0",
        ]
        if not use_uir:
            cmd.append("--no-uir-targets")
        if use_symbolic:
            cmd.extend([
            "--solver-branch-plateau",
            str(cfg["solver_branch_plateau"]),
            "--solver-high-risk-branch-age",
            str(cfg["solver_high_risk_branch_age"]),
            "--solver-max-branches-per-call",
            str(cfg["solver_max_branches_per_call"]),
            "--solver-max-call-ms",
            str(cfg["solver_max_call_ms"]),
            "--solver-branch-cooldown",
            str(cfg["solver_branch_cooldown"]),
            "--solver-uir-priority",
            cfg["solver_uir_priority"],
            "--solver-targeted-seeds",
            "--solver-targeted-seeds-per-call",
            str(cfg["solver_targeted_seeds_per_call"]),
            "--solver-targeted-seed-injection",
            str(cfg["solver_targeted_seed_injection"]),
            "--solver-targeted-seed-queue",
            str(cfg["solver_targeted_seed_queue"]),
            "--solver-targeted-seed-mode",
            cfg["solver_targeted_seed_mode"],
            "--solver-abi-constraints",
            ])
        if use_uir:
            cmd.extend([
                "--uir-solving",
                "--uir-solving-plateau",
                str(cfg["uir_solving_plateau"]),
                "--uir-mutation",
                "--uir-mutation-rate",
                str(cfg["uir_mutation_rate"]),
                "--uir-mutation-insert-rate",
                str(cfg["uir_mutation_insert_rate"]),
            ])
        if use_hints:
            cmd.extend([
                "--vulnerability-hints",
                "--vulnerability-hint-static-probes",
                str(cfg["vulnerability_hint_static_probes"]),
                "--vulnerability-hint-injection",
                str(cfg["vulnerability_hint_injection"]),
                "--vulnerability-hint-queue",
                str(cfg["vulnerability_hint_queue"]),
            ])
        cmd.extend([
            "--minimization-timeout",
            str(timeout),
        ])
        if cfg["validate_minimization"] and not self.args.no_validate_minimization:
            cmd.append("--validate-minimization")
        if cfg["llm_rca"] and not self.args.no_llm_rca:
            cmd.append("--llm-rca")
        if self.args.env_file:
            cmd.extend(["--env-file", self.args.env_file])
        if not use_random_seed_fallback:
            cmd.extend(["--seeds", seeds])
        return cmd

    def collect_artifacts(self) -> Dict[str, Any]:
        copied: Dict[str, Any] = {}
        destinations = {
            "functional_test": (self.functional_meta_dir, self.artifacts_dir / "functional_test"),
            "l3_foundry": (self.invariant_meta_dir, self.artifacts_dir / "l3_foundry"),
            "l4_fuzz": (self.source_meta_dir, self.artifacts_dir / "l4_fuzz"),
            "l5_events": (self.processed_dir, self.artifacts_dir / "l5_events"),
            "l6_replay": (self.processed_dir, self.artifacts_dir / "l6_replay"),
            "report": (self.processed_dir, self.report_dir),
        }
        for group, (src_dir, dst_dir) in destinations.items():
            copied[group] = {}
            for filename in COPY_GROUPS[group]:
                copied_path = _copy_file(src_dir / filename, dst_dir / filename)
                if copied_path:
                    copied[group][filename] = copied_path

        failed_traces = _copy_tree(self.functional_meta_dir / "failed_traces", self.artifacts_dir / "functional_test" / "failed_traces")
        if failed_traces:
            copied.setdefault("functional_test", {})["failed_traces"] = failed_traces
        finding_cases = _copy_tree(self.source_meta_dir / "finding_cases", self.artifacts_dir / "raw_violation_candidates")
        if finding_cases:
            copied["raw_violation_candidates"] = finding_cases

        self.manifest["artifacts"] = copied
        return copied

    def build_summary(self) -> Dict[str, Any]:
        from .reporting.t_policy import collect_run
        from .reporting.finding_schema import build_semantic_invariant_report, _write_semantic_invariant_markdown, _write_text
        functional = _json_load(self.functional_meta_dir / "summary.json")
        invariant = _json_load(self.invariant_meta_dir / "summary.json")
        semantic = _json_load(self.processed_dir / "semantic_invariant_report.json")
        replay = _json_load(self.processed_dir / "hybrid_replay_report.json")
        uir = _json_load(self.source_meta_dir / "uir_coverage.json")
        hint = _json_load(self.source_meta_dir / "vulnerability_hint_stats.json")
        rca_path = self.processed_dir / "llm_root_cause_report.json"
        rca = _json_load(rca_path)
        uir_summary = uir.get("summary") or {}
        hint_stats = hint.get("stats") or {}
        evidence = collect_run({'source': str(self.source), 'contract': self.contract,
                                'semantic_run_dir': str(self.run_dir)})
        detection = {'reporting_policy': POLICY, 'reporting_policy_version': POLICY_VERSION,
                     'input_fp_filter_mode': evidence['input_fp_filter_mode'],
                     'report_fp_filter_mode': 'evidence-safe',
                     'categories': sorted(evidence['predictions']),
                     'event_count': len(evidence['events']),
                     'evidence_level': 'alerts; replay confirmation is reported separately'}
        semantic = build_semantic_invariant_report(
            meta_dir=self.source_meta_dir, pro_dir=self.processed_dir, events=evidence['events'],
            replay_report=replay, index=_json_load(self.processed_dir / 'finding_index.json'),
            detection=evidence)
        semantic['detection'] = detection
        _write_text(self.report_dir / 'semantic_invariant_report.json', json.dumps(semantic, indent=2))
        _write_semantic_invariant_markdown(semantic, self.report_dir / 'semantic_invariant_report.md')
        violation_summary = semantic.get("violation_summary") or {}
        replay_summary = semantic.get("replay_summary") or {}
        _write_text(self.run_dir / 'detection_T.json',
                    json.dumps({**detection, 'event_audit': evidence['audit']}, indent=2))
        return {
            "schema_version": "semantic-invariant.console_summary.v1",
            "reporting_policy": POLICY,
            "detection": detection,
            "run_dir": str(self.run_dir),
            "functional_test": {
                "total": _count_total(functional),
                "passed": _count_passed(functional),
                "failed": _count_failed(functional),
                "note": "Functional-test failures are seed-generation diagnostics, not confirmed vulnerabilities.",
            },
            "l3_foundry": {
                "total": _count_total(invariant),
                "passed": _count_passed(invariant),
                "invariant_violations": _count_failed(invariant),
                "supplement_enabled": bool(_json_load(self.invariant_meta_dir / "foundry_supplement.json").get("enabled")),
            },
            "l4_fuzz": {
                "semantic_coverage": uir_summary.get("percentages") or {},
                "coverage_goals": uir_summary.get("coverage_goals") or {},
                "vulnerability_hints": {
                    "generated": hint_stats.get("generated"),
                    "queued": hint_stats.get("queued"),
                    "injected": hint_stats.get("injected"),
                    "invalid": hint_stats.get("invalid"),
                    "static_probes": (hint_stats.get("static_probes") or {}).get("generated"),
                },
            },
            "l5_l6": {
                "violations": violation_summary,
                "replay": replay_summary or {
                    "replay_count": replay.get("replay_count"),
                    "replayed_count": replay.get("replayed_count"),
                    "minimized_count": replay.get("minimized_count"),
                    "by_backend": replay.get("by_backend") or {},
                },
            },
            "llm_rca": {
                "enabled": not self.args.no_llm_rca,
                "available": bool(rca),
                "schema_version": rca.get("schema_version"),
                "status": rca.get("status"),
                "results": len(rca.get("results") or []),
                "errors": len(rca.get("errors") or []),
                "path": str(self.report_dir / "llm_root_cause_report.json") if rca else None,
            },
            "primary_report": str(self.report_dir / "semantic_invariant_report.md"),
            "primary_report_json": str(self.report_dir / "semantic_invariant_report.json"),
        }

    def augment_primary_report(self, summary: Dict[str, Any]) -> None:
        json_path = self.report_dir / "semantic_invariant_report.json"
        md_path = self.report_dir / "semantic_invariant_report.md"
        report = _json_load(json_path)
        if not report:
            report = {'schema_version': 'semantic-invariant.report.v1'}
        if report:
            report['reporting_policy'] = summary['detection']['reporting_policy']
            report['reporting_policy_version'] = summary['detection']['reporting_policy_version']
            report['detection'] = summary['detection']
            report["functional_test_diagnostics"] = summary.get("functional_test") or {}
            report["llm_root_cause"] = summary.get("llm_rca") or {}
            report["unified_run"] = {
                "run_dir": str(self.run_dir),
                "console_summary": str(self.run_dir / "console_summary.txt"),
                "manifest": str(self.run_dir / "run_manifest.json"),
                "functional_artifacts": str(self.artifacts_dir / "functional_test"),
                "logs": str(self.logs_dir),
            }
            json_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")

        if not md_path.exists():
            md_path.write_text('# Semantic Invariant Vulnerability Report\n', encoding='utf-8')
        if md_path.exists():
            extra = [
                "",
                "## T Detection Results",
                "",
                f"- Categories: `{';'.join(summary['detection']['categories'])}`",
                f"- Retained events: `{summary['detection']['event_count']}`",
                "- Evidence: alerts; replay confirmation is reported separately.",
                "",
                "## Functional Test Diagnostics",
                "",
                f"- Total: `{(summary.get('functional_test') or {}).get('total')}`",
                f"- Passed: `{(summary.get('functional_test') or {}).get('passed')}`",
                f"- Failed: `{(summary.get('functional_test') or {}).get('failed')}`",
                "- Note: Functional-test failures are seed-generation diagnostics, not confirmed vulnerabilities.",
                "",
                "## LLM Root Cause Analysis",
                "",
                f"- Enabled: `{(summary.get('llm_rca') or {}).get('enabled')}`",
                f"- Available: `{(summary.get('llm_rca') or {}).get('available')}`",
                f"- Status: `{(summary.get('llm_rca') or {}).get('status')}`",
                f"- Results: `{(summary.get('llm_rca') or {}).get('results')}`",
                f"- Errors: `{(summary.get('llm_rca') or {}).get('errors')}`",
                f"- Artifact: `{(summary.get('llm_rca') or {}).get('path')}`",
                "",
            ]
            text = md_path.read_text(encoding="utf-8")
            if "## Functional Test Diagnostics" not in text:
                md_path.write_text(text.rstrip() + "\n" + "\n".join(extra), encoding="utf-8")

    def write_summary(self, summary: Dict[str, Any]) -> None:
        summary_path = self.run_dir / "console_summary.json"
        text_path = self.run_dir / "console_summary.txt"
        summary_path.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")

        lines = [
            "Semantic invariant run report.",
            "",
            f"Run directory: {self.run_dir}",
            "",
            "T detection results:",
            f"  categories={';'.join(summary['detection']['categories'])}",
            f"  retained_events={summary['detection']['event_count']}",
            "",
            "Functional test diagnostics:",
            f"  total={summary['functional_test']['total']} passed={summary['functional_test']['passed']} failed={summary['functional_test']['failed']}",
            "  note=failures are seed-generation diagnostics, not confirmed vulnerabilities",
            "",
            "L3 Foundry property validation:",
            f"  total={summary['l3_foundry']['total']} passed={summary['l3_foundry']['passed']} invariant_violations={summary['l3_foundry']['invariant_violations']}",
            f"  supplement_enabled={summary['l3_foundry']['supplement_enabled']}",
            "",
            "L4 Semantic fuzz monitoring:",
            f"  semantic_coverage={summary['l4_fuzz']['semantic_coverage']}",
            f"  vulnerability_hints={summary['l4_fuzz']['vulnerability_hints']}",
            "",
            "L5/L6 Evidence:",
            f"  violations={summary['l5_l6']['violations']}",
            f"  replay={summary['l5_l6']['replay']}",
            "",
            "LLM Root Cause Analysis:",
            f"  enabled={summary['llm_rca']['enabled']} available={summary['llm_rca']['available']} results={summary['llm_rca']['results']} errors={summary['llm_rca']['errors']}",
            f"  artifact={summary['llm_rca']['path']}",
            "",
            f"Primary report: {summary['primary_report']}",
            f"Detailed logs: {self.logs_dir}",
        ]
        text_path.write_text("\n".join(lines), encoding="utf-8")
        print("", flush=True)
        self._append_log("stage_stdout.log", "")
        for line in lines:
            print(line, flush=True)
            self._append_log("stage_stdout.log", line)

    def write_manifest(self, status: str) -> None:
        self.manifest["finished_at"] = int(time.time())
        self.manifest["status"] = status
        (self.run_dir / "run_manifest.json").write_text(
            json.dumps(self.manifest, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    def run(self) -> int:
        self.prepare()
        if self.args.ablation_no_label_preservation:
            os.environ["SEMINV_ABLATION_NO_LABEL_PRESERVATION"] = "1"
        total = 6
        self.stage(1, total, "Contract intake", [
            f"source: {self.source}",
            f"contract: {self.contract}",
            f"solc: {self.args.solc}",
            f"foundry_evm: {self.foundry_evm}",
            f"l4_fuzz_evm: {self.l4_fuzz_evm}",
        ])
        self.manifest["ablation"] = {
            "abi_random_baseline": bool(self.args.ablation_abi_random_baseline),
            "skip_foundry": bool(self.args.ablation_skip_foundry),
            "functional_only": bool(self.args.ablation_functional_only),
            "skip_fuzz": bool(self.args.ablation_skip_fuzz),
            "no_functional_seeds": bool(self.args.ablation_no_functional_seeds),
            "no_uir": bool(self.args.ablation_no_uir),
            "no_symbolic": bool(self.args.ablation_no_symbolic),
            "no_static_source": bool(self.args.ablation_no_static_source),
            "no_vulnerability_hints": bool(self.args.ablation_no_vulnerability_hints),
            "no_label_preservation": bool(self.args.ablation_no_label_preservation),
            "foundry_timeout_seconds": self.args.foundry_timeout,
            "fuzz_timeout_seconds": self.args.fuzz_timeout,
        }

        if self.args.dry_run:
            self.manifest["dry_run"] = True
            self.manifest["commands"] = {
                "l1_l3_foundry": self.func_test_command(),
                "l4_l6_fuzz": self.fuzz_command(),
            }
            self.write_manifest("dry_run")
            for line in (
                "Dry run only. Expanded commands were written to run_manifest.json.",
                f"Run directory: {self.run_dir}",
            ):
                print(line, flush=True)
                self._append_log("stage_stdout.log", line)
            self._pipeline_event("dry_run", run_dir=str(self.run_dir))
            return 0

        self.stage(2, total, "L1-L3 semantic fact recovery and Foundry property validation")
        rc = 0
        if self.args.ablation_skip_foundry or self.args.ablation_abi_random_baseline:
            self.manifest["l1_l3_downgraded"] = {
                "returncode": None,
                "policy": "skip_l1_l3_for_ablation_random_fuzz",
            }
            self._stage_warning("L1-L3 skipped by ablation profile", stage="l1_l3_foundry")
        else:
            rc = self._run_command("l1_l3_foundry", self.func_test_command(), timeout_seconds=self.args.foundry_timeout)
        if rc != 0:
            l1_l3_error = classify_l1_l3_error(
                exit_code=rc,
                stdout_path=self.logs_dir / "l1_l3_foundry" / "stdout.log",
                stderr_path=self.logs_dir / "l1_l3_foundry" / "stderr.log",
                functional_meta_dir=self.functional_meta_dir,
                invariant_meta_dir=self.invariant_meta_dir,
                supplement_meta_dir=self.project_root / f"{self.artifact_name}_supplement_meta" / "invariant_test",
                extra_paths=[self.run_dir / "stdout.txt", self.run_dir / "stderr.txt"],
            )
            self.manifest["failure_classification"] = l1_l3_error
            message = f"  error: L1-L3 command failed with return code {rc}"
            print(message, file=sys.stderr, flush=True)
            self._stage_error(message, stage="l1_l3_foundry", returncode=rc)
            self.collect_artifacts()
            seeds = Path(self.args.seeds) if self.args.seeds else self.functional_meta_dir / "seeds.json"
            if l1_l3_error.get("error_type") in UNTESTABLE_CONTRACT_SELECTION_ERRORS:
                self.manifest["untestable_case"] = {
                    "returncode": rc,
                    "error_type": l1_l3_error.get("error_type"),
                    "error_stage": l1_l3_error.get("error_stage"),
                    "error_detail": l1_l3_error.get("error_detail"),
                    "policy": "skip_untestable_contract_selection_case",
                }
                self.write_manifest("skipped_untestable")
                return 0
            if not seeds.exists():
                downgrade = (
                    "  warning: L1-L3 failed and no functional seeds are available; "
                    "continuing to L4 fuzz with random initialization."
                )
                print(downgrade, flush=True)
                self._stage_warning(
                    downgrade,
                    stage="l1_l3_foundry",
                    returncode=rc,
                    policy="continue_l4_without_functional_seeds_random_fallback",
                )
                self.manifest["l1_l3_downgraded"] = {
                    "returncode": rc,
                    "seeds": str(seeds),
                    "policy": "continue_l4_without_functional_seeds_random_fallback",
                }
            else:
                downgrade = (
                    "  warning: L1-L3 failed, but functional seeds are available; "
                    "continuing to L4 fuzz with degraded semantic targets."
                )
                print(downgrade, flush=True)
                self._stage_warning(
                    downgrade,
                    stage="l1_l3_foundry",
                    returncode=rc,
                    seeds=str(seeds),
                    policy="continue_l4_with_functional_seeds",
                )
                self.manifest["l1_l3_downgraded"] = {
                    "returncode": rc,
                    "seeds": str(seeds),
                    "policy": "continue_l4_with_functional_seeds",
                }

        invariant = _json_load(self.invariant_meta_dir / "summary.json")
        self.stage(3, total, "L3 output collected", [
            f"tests: {_count_total(invariant)}",
            f"passed: {_count_passed(invariant)}",
            f"invariant violations: {_count_failed(invariant)}",
        ])

        static_result = {"emitted": 0, "kinds": []}
        if not self.args.ablation_no_static_source and not self.args.ablation_abi_random_baseline:
            static_result = emit_static_source_findings(
                source_path=self.source,
                contract_name=self.args.contract,
                meta_dir=self.source_meta_dir,
                validate_minimization=not getattr(self.args, "no_validate_minimization", False),
                minimization_timeout=getattr(self.args, "minimization_timeout", None),
                fp_filter_mode=self.fp_filter_mode,
            )
        if static_result.get("emitted"):
            self._stage_warning(
                "source-level invariant evidence emitted",
                stage="static_source_detectors",
                emitted=static_result.get("emitted"),
                kinds=static_result.get("kinds"),
            )

        self.stage(4, total, "L4 semantic fuzz monitoring")
        if self.args.ablation_skip_fuzz:
            self._stage_warning("L4 fuzz skipped by ablation profile", stage="l4_l6_fuzz")
            rc = 0
        else:
            rc = self._run_command("l4_l6_fuzz", self.fuzz_command(), timeout_seconds=self.args.fuzz_timeout)
        if rc != 0:
            message = f"  error: L4-L6 command failed with return code {rc}"
            print(message, file=sys.stderr, flush=True)
            self._stage_error(message, stage="l4_l6_fuzz", returncode=rc)
            self.collect_artifacts()
            self.write_manifest("failed_l4_l6")
            summary = self.build_summary()
            self.augment_primary_report(summary)
            self.write_summary(summary)
            return rc

        self.stage(5, total, "Collecting functional diagnostics and semantic evidence")
        self.collect_artifacts()

        self.stage(6, total, "Writing unified output")
        summary = self.build_summary()
        self.augment_primary_report(summary)
        self.write_summary(summary)
        self.write_manifest("completed")
        return 0


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser("semantic invariant end-to-end runner")
    parser.add_argument("-s", "--source", required=True, help="Solidity source file path.")
    parser.add_argument("-c", "--contract", required=True, help="Contract name.")
    parser.add_argument("--solc", required=True, help="Solidity compiler version, e.g. v0.8.0.")
    parser.add_argument(
        "--evm",
        default="byzantium",
        help=(
            "L4 fuzz EVM version. Foundry L1-L3 selects its EVM automatically "
            "from --solc. Defaults to byzantium."
        ),
    )
    parser.add_argument("--generations", "-g", type=int, default=None, help="Fuzz generations. Defaults to profile value 10.")
    parser.add_argument("--project-root", default=DEFAULT_PROFILE["func_test"]["project_root"], help="Foundry project root.")
    parser.add_argument(
        "--output-root",
        default=None,
        help=(
            "Optional unified run output root. When omitted, output is written "
            "next to the source as <source_stem>_outputs, e.g. newvul/ResearchTarget_outputs."
        ),
    )
    parser.add_argument(
        "--run-id",
        default=None,
        help=(
            "Optional run id. With --output-root, creates <contract>_<run_id>; "
            "without --output-root, creates <source_stem>_outputs/<run_id>."
        ),
    )
    parser.add_argument("--run-dir", default=None, help="Optional exact unified run directory. Overrides --output-root/--run-id layout.")
    parser.add_argument("--artifact-name", default=None, help="Optional unique Foundry artifact/meta name. Defaults to the contract name.")
    parser.add_argument("--seeds", default=None, help="Optional seed file override. Defaults to foundry/<artifact-name>_meta/functional_test/seeds.json.")
    parser.add_argument("--minimization-timeout", type=int, default=None, help="Oracle timeout. Defaults to profile value 60.")
    parser.add_argument("--foundry-timeout", type=int, default=None, help="Per-contract L1-L3 Foundry stage timeout in seconds. 0/omitted means no stage timeout.")
    parser.add_argument("--fuzz-timeout", type=int, default=None, help="Per-contract L4-L6 fuzz stage timeout in seconds. 0/omitted means no stage timeout.")
    parser.add_argument("--env-file", default=None, help="Optional .env path for LLM and RCA configuration.")
    parser.add_argument("--no-validate-minimization", action="store_true", default=False, help="Disable replay/minimization validation.")
    parser.add_argument("--no-llm-rca", action="store_true", default=False, help="Disable default --llm-rca in the fuzz stage.")
    parser.add_argument(
        "--fp-filter",
        choices=["off", "evidence-safe"],
        default=os.getenv("SEMINV_FP_FILTER", "evidence-safe"),
        help="Native event filter, default evidence-safe. Primary T reporting always applies evidence-safe.",
    )
    parser.add_argument("--ablation-abi-random-baseline", action="store_true", default=False, help="Run ABI-random fuzz baseline: no Foundry, no UIR, no symbolic, no hints, random seeds.")
    parser.add_argument("--ablation-skip-foundry", action="store_true", default=False, help="Skip L1-L3 Foundry generation and run L4 with random initialization.")
    parser.add_argument("--ablation-functional-only", action="store_true", default=False, help="Run only Foundry functional seed extraction, skipping Foundry invariant property tests.")
    parser.add_argument("--ablation-skip-fuzz", action="store_true", default=False, help="Skip L4 fuzz; useful for static/property-only ablations.")
    parser.add_argument("--ablation-no-functional-seeds", action="store_true", default=False, help="Run Foundry but do not feed functional seeds into L4 fuzz.")
    parser.add_argument("--ablation-no-uir", action="store_true", default=False, help="Disable UIR target loading, UIR solving, and UIR mutation in L4 fuzz.")
    parser.add_argument("--ablation-no-symbolic", action="store_true", default=False, help="Disable symbolic/constraint solving in L4 fuzz.")
    parser.add_argument("--ablation-no-static-source", action="store_true", default=False, help="Disable source-level semantic detectors.")
    parser.add_argument("--ablation-no-vulnerability-hints", action="store_true", default=False, help="Disable vulnerability hint probes and injection.")
    parser.add_argument("--ablation-no-label-preservation", action="store_true", default=False, help="Disable benchmark-label enrichment/preservation in L5/L6 normalization.")
    parser.add_argument("--dry-run", action="store_true", default=False, help="Create the run directory and print/write expanded commands without executing them.")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    runner = SemanticRun(args)
    return runner.run()


if __name__ == "__main__":
    raise SystemExit(main())
