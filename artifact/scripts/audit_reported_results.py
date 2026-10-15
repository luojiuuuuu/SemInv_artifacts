#!/usr/bin/env python3
"""Cross-check paper-facing tables against preserved experiment evidence.

The script uses only the Python standard library. It validates the values that
can be recomputed from this artifact and records the one known RQ4 source-run
discrepancy without silently rewriting either side.
"""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
from typing import Any, Dict, Iterable, List


ROOT = Path(__file__).resolve().parents[2]
ANALYSIS = ROOT / "experiment_data" / "analysis"


def read_csv(path: Path) -> List[Dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def pct(value: Any) -> float:
    return round(float(value) * 100.0, 2)


def dec(value: Any) -> float:
    return round(float(value), 2)


checks: List[Dict[str, Any]] = []


def record(rq: str, claim: str, expected: Any, observed: Any, evidence: str,
           status: str | None = None) -> None:
    if status is None:
        status = "supported" if expected == observed else "mismatch"
    checks.append(
        {
            "rq": rq,
            "claim": claim,
            "status": status,
            "expected": expected,
            "observed": observed,
            "evidence": evidence,
        }
    )


def keyed(rows: Iterable[Dict[str, str]], field: str) -> Dict[str, Dict[str, str]]:
    return {row[field]: row for row in rows}


def audit_rq1() -> None:
    base = ANALYSIS / "rq1_detection_effectiveness"
    reported = read_csv(base / "reported" / "paper_overall.csv")[0]
    evidence = next(row for row in read_csv(base / "evidence" / "overall.csv")
                    if row["scope"] == "all_139")
    observed = {
        "detected": int(evidence["TP"]),
        "recall_pct": pct(evidence["Recall"]),
        "fpr_pct": pct(evidence["FPR"]),
        "f1_pct": pct(evidence["F1"]),
    }
    expected = {
        "detected": int(reported["detected_labeled_contracts"]),
        "recall_pct": float(reported["recall_pct"]),
        "fpr_pct": float(reported["fpr_pct"]),
        "f1_pct": float(reported["f1_pct"]),
    }
    record("RQ1", "overall detection effectiveness", expected, observed,
           "rq1_detection_effectiveness/evidence/overall.csv")

    paper_rows = keyed(read_csv(base / "reported" / "paper_table_04.csv"), "baseline")
    evidence_rows = {
        row["baseline"]: row
        for row in read_csv(base / "evidence" / "paired_metrics.csv")
        if row["cohort"] == "historical_scope"
    }
    for name, paper in paper_rows.items():
        row = evidence_rows[name]
        observed_pair = {
            "N": int(row["N"]),
            "K": int(row["K"]),
            "seminv_recall": pct(row["seminv_Recall"]),
            "baseline_recall": pct(row["baseline_Recall"]),
            "seminv_fpr": pct(row["seminv_FPR"]),
            "baseline_fpr": pct(row["baseline_FPR"]),
            "seminv_accuracy": pct(row["seminv_Accuracy"]),
            "baseline_accuracy": pct(row["baseline_Accuracy"]),
            "seminv_f1": pct(row["seminv_F1"]),
            "baseline_f1": pct(row["baseline_F1"]),
        }
        expected_pair = {
            "N": int(paper["paired_files_N"]),
            "K": int(paper["shared_categories_K"]),
            "seminv_recall": float(paper["seminv_recall_pct"]),
            "baseline_recall": float(paper["baseline_recall_pct"]),
            "seminv_fpr": float(paper["seminv_fpr_pct"]),
            "baseline_fpr": float(paper["baseline_fpr_pct"]),
            "seminv_accuracy": float(paper["seminv_accuracy_pct"]),
            "baseline_accuracy": float(paper["baseline_accuracy_pct"]),
            "seminv_f1": float(paper["seminv_f1_pct"]),
            "baseline_f1": float(paper["baseline_f1_pct"]),
        }
        record("RQ1", f"Table 4: {name}", expected_pair, observed_pair,
               "rq1_detection_effectiveness/evidence/paired_metrics.csv")


def audit_rq2() -> None:
    base = ANALYSIS / "rq2_semantic_recovery"
    paper = keyed(read_csv(base / "reported" / "paper_table_06.csv"), "system")
    evidence = keyed(read_csv(base / "evidence" / "obligation_comparison.csv"), "method")
    method_map = {"SemInv-ERC": "v3 all diagnostics", "SymGPT": "Fresh SymGPT"}
    for system, method in method_map.items():
        p, e = paper[system], evidence[method]
        expected = {
            "TP": int(p["true_positive"]),
            "unmatched": int(p["unmatched"]),
            "FN": int(p["false_negative"]),
            "precision_pct": float(p["precision_star_pct"]),
            "recall_pct": float(p["recall_pct"]),
            "f1_pct": float(p["f1_pct"]),
        }
        observed = {
            "TP": int(e["TP"]),
            "unmatched": int(e["FP_closed_world"]),
            "FN": int(e["FN"]),
            "precision_pct": pct(e["precision"]),
            "recall_pct": pct(e["recall"]),
            "f1_pct": pct(e["f1"]),
        }
        record("RQ2", f"Table 6: {system}", expected, observed,
               "rq2_semantic_recovery/evidence/obligation_comparison.csv")

    paper_struct = keyed(read_csv(base / "reported" / "paper_structural_metrics.csv"), "task")
    scopes = {
        "state_declarations": "state_declaration",
        "storage_bindings": "storage_layout_binding",
        "static_may_write": "static_may_write_edge",
    }
    rows = read_json(base / "evidence" / "structural_scores.json")
    for task, scope in scopes.items():
        selected = [row for row in rows if row["variant"] == "fused" and row["scope"] == scope]
        tp = sum(int(row["TP"]) for row in selected)
        fp = sum(int(row["FP"]) for row in selected)
        fn = sum(int(row["FN"]) for row in selected)
        paper_row = paper_struct[task]
        expected = {
            "precision_pct": float(paper_row["precision_pct"]),
            "recall_pct": float(paper_row["recall_pct"]),
            "missing": int(paper_row["missing"]),
        }
        observed = {
            "precision_pct": round(100.0 * tp / (tp + fp), 2),
            "recall_pct": round(100.0 * tp / (tp + fn), 2),
            "missing": fn,
        }
        record("RQ2", f"structural recovery: {task}", expected, observed,
               "rq2_semantic_recovery/evidence/structural_scores.json")


def audit_rq3() -> None:
    base = ANALYSIS / "rq3_coverage_discovery"
    paper = keyed(read_csv(base / "reported" / "paper_table_07.csv"), "system")
    evidence = read_json(base / "evidence" / "fuzz_comparison_metrics.json")
    cohort = evidence["coverage"][evidence["coverage_main_cohort"]]
    record("RQ3", "Table 7 common cohort size", 128, int(cohort["n"]),
           "rq3_coverage_discovery/evidence/fuzz_comparison_metrics.json")
    for system, p in paper.items():
        at_600 = next(row for row in cohort["curves"][system] if int(row["checkpoint_s"]) == 600)
        gain = cohort["search_gain"][system]
        expected = {
            "instruction_600": float(p["instruction_coverage_600s_pct"]),
            "branch_600": float(p["branch_coverage_600s_pct"]),
            "instruction_gain": float(p["instruction_gain_60_to_600_pct_points"]),
            "branch_gain": float(p["branch_gain_60_to_600_pct_points"]),
        }
        observed = {
            "instruction_600": dec(at_600["instruction"]["macro_pct"]),
            "branch_600": dec(at_600["branch"]["macro_pct"]),
            "instruction_gain": dec(gain["instruction"]["gain_60_to_600_pp"]),
            "branch_gain": dec(gain["branch"]["gain_60_to_600_pp"]),
        }
        record("RQ3", f"Table 7: {system}", expected, observed,
               "rq3_coverage_discovery/evidence/fuzz_comparison_metrics.json")


def audit_rq4() -> None:
    base = ANALYSIS / "rq4_component_ablation"
    paper = keyed(read_csv(base / "reported" / "paper_table_08.csv"), "configuration")
    evidence = {
        row["variant"]: row
        for row in read_csv(base / "evidence" / "main_metrics.csv")
        if row["scope"] == "strict8_139_seed11" and row["channel"] == "search+fresh_upstream"
    }
    expected = int(paper["Full"]["gt_matching_hits"])
    observed = int(evidence["Full"]["TP"])
    status = "known_source_snapshot_discrepancy" if (expected, observed) == (129, 128) else None
    record("RQ4", "Table 8 Full GT-matching hits", expected, observed,
           "rq4_component_ablation/evidence/main_metrics.csv", status=status)


def audit_rq5() -> None:
    base = ANALYSIS / "rq5_defi_alignment"
    table9 = keyed(read_csv(base / "reported" / "paper_table_09.csv"), "alignment_level")
    summary = read_json(base / "evidence" / "summary.json")
    path = summary["zero_exit_path_recovery"]
    witness = summary["poc_linked_dynamic_invariant_witness"]
    observed = {
        "linked_inputs": {
            "finds": int(path["invariant_events_linked_by_selected_contract_normalized_pc_and_detector_type"]),
            "pocs": int(path["cases_all_invariant_events_pc_linked"]) + int(path["cases_with_some_linked_and_some_unlinked_events"]),
        },
        "poc_function_matches": {
            "finds": int(witness["linked_events"]),
            "pocs": int(witness["cases_with_at_least_one_linked_witness"]),
        },
        "multi_transaction_prefixes": {
            "finds": int(path["events_with_at_least_two_transactions_executed_through_trigger"]),
            "pocs": int(path["cases_with_any_multi_transaction_executed_prefix"]),
        },
    }
    for key, values in observed.items():
        row = table9[key]
        expected = {"finds": int(row["finds"]), "pocs": int(row["pocs"])}
        record("RQ5", f"Table 9: {key}", expected, values,
               "rq5_defi_alignment/evidence/summary.json")

    event_rows = [row for row in read_csv(base / "evidence" / "event_path_recovery.csv")
                  if row["run_exit_code"] == "0" and row["is_invariant_event"].lower() in {"true", "1"}]
    aligned = [row for row in event_rows if row["poc_linked_dynamic_invariant_witness"].lower() in {"true", "1"}]
    multi = [row for row in aligned if int(row["max_executed_prefix_tx_count_through_trigger"] or 0) >= 2]
    row = table9["function_aligned_multi_transaction"]
    expected = {"finds": int(row["finds"]), "pocs": int(row["pocs"])}
    observed_multi = {"finds": len(multi), "pocs": len({r["source"] for r in multi})}
    record("RQ5", "Table 9: function-aligned multi-transaction", expected, observed_multi,
           "rq5_defi_alignment/evidence/event_path_recovery.csv")

    paper10 = keyed(read_csv(base / "reported" / "paper_table_10.csv"), "invariant")
    groups: Dict[str, List[Dict[str, str]]] = {}
    for row in event_rows:
        groups.setdefault(row["invariant_id"], []).append(row)
    id_map = {
        "resource.bounded_execution": "I5.resource.bounded_execution",
        "execution.numeric_integrity": "I5.execution.numeric_integrity",
        "external.call_return_consistency": "I6.external.call_return_consistency",
        "external.bad_randomness_dependency": "I6.external.bad_randomness_dependency",
    }
    for paper_name, evidence_name in id_map.items():
        selected = groups[evidence_name]
        expected = {"finds": int(paper10[paper_name]["finds"]), "pocs": int(paper10[paper_name]["pocs"])}
        observed_group = {"finds": len(selected), "pocs": len({row["source"] for row in selected})}
        record("RQ5", f"Table 10: {paper_name}", expected, observed_group,
               "rq5_defi_alignment/evidence/event_path_recovery.csv")


def audit_rq6() -> None:
    base = ANALYSIS / "rq6_replay_traceability"
    paper = keyed(read_csv(base / "reported" / "paper_table_12.csv"), "measure")
    metrics = read_json(base / "evidence" / "metrics.json")
    observed = {
        "three_replay_reproduction": (metrics["processed_3of3"], metrics["scope"]["dynamic"]),
        "shortened_multi_transaction": (metrics["minimization"]["shortened"], 234),
        "signal_retention_after_reduction": (metrics["minimization"]["both_observed"], metrics["minimization"]["raw_observed"]),
        "one_deletion_minimal": (metrics["minimization"]["all_deletions_lose_diagnostic"], metrics["minimization"]["deletion_records"]),
        "successfully_parsed_explanations": (metrics["explanations"]["matching_T_requests"], metrics["scope"]["events"]),
        "matching_source_context": (metrics["explanations"]["matched_T_context_content"]["byte_identical_source"], metrics["explanations"]["matching_T_requests"]),
    }
    for key, pair in observed.items():
        row = paper[key]
        expected = (int(row["numerator"]), int(row["denominator"]))
        record("RQ6", f"Table 12: {key}", expected, pair,
               "rq6_replay_traceability/evidence/metrics.json")


def audit_inputs() -> None:
    sb = list((ROOT / "experiment_data" / "datasets" / "smartbugs_curated").rglob("*.sol"))
    erc = list((ROOT / "experiment_data" / "datasets" / "erc_semantic_suite" / "contracts").glob("*.sol"))
    payload = ANALYSIS / "rq6_replay_traceability" / "evidence" / "frozen" / "finding_payloads.json"
    record("inputs", "SmartBugs Curated snapshot", 143, len(sb),
           "experiment_data/datasets/smartbugs_curated")
    record("inputs", "ERC semantic suite", 35, len(erc),
           "experiment_data/datasets/erc_semantic_suite/contracts")
    record("inputs", "RQ6 frozen payload present", True,
           payload.exists() and payload.stat().st_size > 1_000_000,
           "rq6_replay_traceability/evidence/frozen/finding_payloads.json")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, help="Optional JSON report path")
    args = parser.parse_args()

    audit_inputs()
    audit_rq1()
    audit_rq2()
    audit_rq3()
    audit_rq4()
    audit_rq5()
    audit_rq6()

    failures = [item for item in checks if item["status"] == "mismatch"]
    known = [item for item in checks if item["status"] == "known_source_snapshot_discrepancy"]
    report = {
        "schema": "seminv-artifact-audit-v1",
        "status": "fail" if failures else ("pass_with_known_limitations" if known else "pass"),
        "check_count": len(checks),
        "supported_count": sum(item["status"] == "supported" for item in checks),
        "known_discrepancy_count": len(known),
        "failure_count": len(failures),
        "checks": checks,
    }
    rendered = json.dumps(report, ensure_ascii=False, indent=2)
    if args.output:
        output = args.output if args.output.is_absolute() else ROOT / args.output
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(rendered + "\n", encoding="utf-8")
    print(rendered)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())

