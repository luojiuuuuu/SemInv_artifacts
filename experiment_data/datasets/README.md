# Dataset snapshots

This directory contains the input snapshots that could be recovered locally and matched to the paper.

## SmartBugs Curated evaluation snapshot

`smartbugs_curated/` contains exactly 143 Solidity files:

- 139 labeled files in the paper's eight evaluated categories;
- three `other` files and one `short_addresses` file retained to preserve the complete 143-file input inventory.

The authoritative evaluated-file mapping remains in `../analysis/rq1_detection_effectiveness/evidence/all_139_mapping.csv` and `selected_runs.csv`.
`smartbugs_curated_manifest.csv` records category, evaluation scope, and byte size for every source.

## ERC semantic suite

`erc_semantic_suite/contracts/` contains the 30 ERC-20 and five ERC-721 contracts used for structural validation. `labels/` contains the public Table-6 label rows and scope metadata. `symgpt_baseline/` contains the matching 35 per-contract baseline result files plus the fresh-run summaries.
`erc_semantic_suite_manifest.csv` records each source and whether its corresponding baseline result is present.

## DeFiHackLabs

The 65 DeFiHackLabs PoC source files were not present in the located SemInv workspace, so they are not duplicated here. RQ5 retains the 65-case inventory, source-relative paths, per-case execution status, 334 archived event rows, and 295 zero-exit invariant-event rows. This is sufficient for result inspection, but not for a clean-room end-to-end rerun of RQ5.

## Licensing

These snapshots contain third-party benchmark material. See `artifact/LICENSE_STATUS.md` before redistribution.

