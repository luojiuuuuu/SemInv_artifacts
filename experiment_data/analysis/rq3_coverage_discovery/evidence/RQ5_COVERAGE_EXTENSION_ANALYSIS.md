# RQ5 Coverage Curve Extension

An independent observer collected ItyFuzz all-search snapshots. The plotted curve is cut off at 600s. SMARTIAN's instrumented saved-corpus replay was validated separately and is not plotted as a search curve.

- Frozen dataset: 143 cases.
- Four-tool exact-runtime cohort: 130 cases.
- Time points: latest concrete snapshot at or before each checkpoint; observations are never backdated.
- Raw ItyFuzz statuses remain unchanged. Offline recovery accepted complete JSONL records for 109 files whose final EOF record was truncated; 117 raw statuses had reported validation failures.
- 8 samples had parseable observer logs but no matching target-runtime frame; they are treated as missing coverage, never as zero coverage.
- Only observations at or before 600s enter the 600s curve. Some collectors continued until their watchdog after the 600s search clock; post-600s observations are excluded, and this report does not claim every process stopped at exactly 600s.
- Instructions use the SemInv normalized concrete PC universe; branches are the two concrete JUMPI outcomes.
- Macro means are case-weighted; micro means are also recorded in the CSV.

## 600s Results

| Tool | Observed cases | Instruction macro | Instruction micro | Branch macro | Branch micro |
|---|---:|---:|---:|---:|---:|
| SemInv | 130 | 89.88% | 73.74% | 91.18% | 79.06% |
| DepFuzz | 130 | 90.80% | 75.39% | 83.60% | 76.09% |
| ConFuzzius | 130 | 91.81% | 78.73% | 92.49% | 82.02% |
| ItyFuzz | 130 | 40.78% | 23.67% | 34.53% | 21.04% |

## Per-tool Pair Cohorts

Pairwise CSV rows use each tool's exact-runtime cohort against SemInv. `fixed_n` records the eligible cohort and `observed_n` records cases with valid observations at that checkpoint. Failed or unavailable ItyFuzz runs remain visible in `coverage_extended_status.csv`.

## Files

- `figures/coverage_all_search_four_way.png` and PDF/SVG: four-tool same-case curves.
- `coverage_extended_curves.csv`: pairwise and four-way macro/micro curves.
- `coverage_extended_cohorts.csv`: exact-runtime case membership.
- `coverage_extended_status.csv`: ItyFuzz per-case outcomes.
