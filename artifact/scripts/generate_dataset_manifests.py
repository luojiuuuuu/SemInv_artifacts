#!/usr/bin/env python3
"""Generate deterministic manifests for the bundled experiment inputs."""

from __future__ import annotations

import csv
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DATASETS = ROOT / "experiment_data" / "datasets"


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    with path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    evaluated = {
        "access_control", "arithmetic", "bad_randomness", "denial_of_service",
        "front_running", "reentrancy", "time_manipulation", "unchecked_low_level_calls",
    }
    sb_root = DATASETS / "smartbugs_curated"
    sb_rows = []
    for source in sorted(sb_root.rglob("*.sol"), key=lambda item: item.as_posix().lower()):
        relative = source.relative_to(sb_root)
        category = relative.parts[0]
        sb_rows.append(
            {
                "relative_path": relative.as_posix(),
                "category": category,
                "evaluated_in_paper": str(category in evaluated).lower(),
                "bytes": source.stat().st_size,
            }
        )
    write_csv(
        DATASETS / "smartbugs_curated_manifest.csv",
        ["relative_path", "category", "evaluated_in_paper", "bytes"],
        sb_rows,
    )

    erc_root = DATASETS / "erc_semantic_suite"
    contracts = erc_root / "contracts"
    baseline = erc_root / "symgpt_baseline"
    erc_rows = []
    for source in sorted(contracts.glob("*.sol"), key=lambda item: item.name.lower()):
        standard = "ERC721" if source.stem.startswith("721_candidate_") else "ERC20"
        baseline_result = baseline / f"{source.stem}.json"
        erc_rows.append(
            {
                "file": source.name,
                "standard": standard,
                "bytes": source.stat().st_size,
                "symgpt_result_present": str(baseline_result.exists()).lower(),
            }
        )
    write_csv(
        DATASETS / "erc_semantic_suite_manifest.csv",
        ["file", "standard", "bytes", "symgpt_result_present"],
        erc_rows,
    )
    print(f"SMARTBUGS_MANIFEST_ROWS={len(sb_rows)}")
    print(f"ERC_MANIFEST_ROWS={len(erc_rows)}")


if __name__ == "__main__":
    main()
