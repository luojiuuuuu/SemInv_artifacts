# Experiment data

This directory follows Section 5 of the accompanying SemInv paper. It contains a compact reported-results layer and the corresponding run evidence.

`datasets/` contains the recovered 143-file SmartBugs snapshot and 35-contract ERC semantic suite. RQ6's frozen replay payload is stored with its evidence. The DeFiHackLabs source checkout was not recoverable from the located workspace and is therefore documented as an end-to-end rerun limitation.

## Data contract

1. Files under `reported/` reproduce the values printed in the paper's tables, figures, and experimental prose.
2. Files under `evidence/` preserve the underlying measurements and audit trails used to support or diagnose those values.
3. Where a run artifact and the final manuscript differ, the manuscript value is kept in `reported/`, while the run artifact remains unchanged in `evidence/` for provenance.
4. For the minor RQ3 wording discrepancy between prose and Table 7, `reported/paper_table_07.csv` follows the table values, which are the structured source of record.
5. Baseline tool names are preserved exactly as reported in the paper.

## Common evaluation settings

- SmartBugs Curated: 143 files, 139 labeled contracts, eight vulnerability categories.
- ERC semantic suite: 30 ERC-20 and five ERC-721 contracts; 34 compiled paired cases with 152 public violation labels.
- DeFiHackLabs: 65 incidents from January–June 2026; 48 completed zero-exit PoCs.
- RQ1/RQ3/RQ4 budget: up to 600 seconds per run.
- RQ6 replay: three fresh-deployment replays with a fixed seed.
- Evaluation host: Intel Core i7-12700, 128 GB RAM.

## RQ index

| RQ | Directory | Primary reported files |
|---|---|---|
| RQ1 | `rq1_detection_effectiveness` | Table 4, Figure 5 data, overall metrics |
| RQ2 | `rq2_semantic_recovery` | Table 6, structural and execution validation |
| RQ3 | `rq3_coverage_discovery` | Table 7, discovery cohorts, Figures 6–7 |
| RQ4 | `rq4_component_ablation` | Table 8, Figure 8 data, component diagnostics |
| RQ5 | `rq5_defi_alignment` | Tables 9–11, input generation and timing |
| RQ6 | `rq6_replay_traceability` | Table 12, reduction and explanation detail |

The machine-readable paper-to-evidence index and automated cross-check are under `../artifact/`.

