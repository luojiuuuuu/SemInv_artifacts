# Figure Contract And Validation

## Evidence Contract

This directory is an offline analysis of the completed 2026-10-12 RQ5
campaigns. It does not contain a new fuzz run. The Chinese master report is
[RQ5_COMPLETE_REPORT.md](RQ5_COMPLETE_REPORT.md).

SemInv uses the system-level T predictions from the same campaign's
preparation and budgeted search events. The x-axis is search time after
preparation; preparation candidates define the initial state. Their raw
elapsed values remain null, and preparation costs are reported separately.
Concrete coverage is unchanged and does not include static evidence.

| Figure | Question | Source | Scope |
| --- | --- | --- | --- |
| gt_pairwise_frozen | How many target-category candidates were produced within each budget? | paired_gt.csv, frozen/fixed | Separate same-case cohort per baseline; historical ItyFuzz mapping has known oracle mismatch |
| gt_pairwise_audited | How does semantic mapping sensitivity change comparisons? | paired_gt.csv, audited/fixed | Explicitly post-hoc; SMARTIAN RE and sFuzz arithmetic added; ItyFuzz restricted to access control |
| coverage_three_way | How does concrete coverage evolve on identical runtimes? | paired_coverage.csv, three_way | 134 common runtimes; macro means; no zero-imputation at t=0 |
| categories_frozen | Where are historical mapped candidate hits concentrated? | category_summary.csv, frozen | N/A is outside mapping, not zero; ItyFuzz caveat applies |
| categories_audited | Which categories remain strong or weak after semantic audit? | category_summary.csv, audited | Actual hit/N labels; system-level SemInv T; label P/R/F1 supplied separately in seminv_label_metrics.csv |

All five figures are deterministic Matplotlib exports in PNG, vector PDF,
and editable-text SVG. SemInv is consistently blue. Markers and panel labels
complement color in line charts. Heatmaps show values and distinguish N/A
from zero. There are no seed confidence intervals because repeated-seed
measurements are unavailable. Interpolating lines in the coverage plot are
visual connectors between observed checkpoints, not additional measurements.

## Validation Completed

- All six tools have 143 terminal status files: 858 unique tool/case records.
- All nine checkpoints are present: 7,722 unique tool/case/time rows.
- The frozen dataset has 139 Strict8 labels and four other files.
- The SemInv search-only subchannel and DepFuzz results match every
  historical main-campaign checkpoint. System-level SemInv predictions
  match the independent channel audit for all 139 Strict8 files.
- All 6,435 baseline checkpoint records are unchanged. All 7,722 coverage
  checkpoint records are unchanged, including counts, rates, and sample times.
- The 9 SemInv label-metric rows were independently recounted from the
  139 predictions: micro TP=129, FP=93, TN=880, FN=10.
- ConFuzzius, SMARTIAN, and ItyFuzz frozen hits match all nonmissing historical
  baseline final GT entries. Fixed operational denominators are explicitly
  distinguished from the old status-based observation counts.
- sFuzz correction restores 23 originally mapped hits; 17 repeated CSV
  headers are ignored as headers, not observations. No duration resets were
  found in the parsed sFuzz sequences.
- Coverage denominators were recalculated from recorded runtime bytecode;
  covered counts are within bounds. The raw coverage check found no
  nonmonotonic snapshot counts. GT checkpoint sequences are monotonic.
- Every paired-GT table satisfies both-hit + SemInv-only + baseline-only +
  neither = N, with consistent numerators.
- Macro/micro coverage bounds and common-cohort observation counts pass.
- All local Markdown evidence links resolve.
- Nine focused offline regression tests pass, including preparation initial
  state, source ownership/time validation, actual preparation findings from
  four categories, and the existing baseline extraction regressions.
- All five PNG figures were visually inspected. The ItyFuzz legend was moved
  to avoid its low-valued curve; note lines were shortened. No clipped axes,
  legend/curve occlusion, or unreadable category names were observed.

## Data Inventory

23 CSVs include 858 run records, 7,722 checkpoints, 143 preparation records,
43 non-normal terminal states, 4,372 baseline native-event records, 1,265
search-channel plus 146 preparation-channel SemInv T-policy audit records
(1,411 total), and 162,056 native telemetry records.
Counts in different files are not additive bug counts. Native telemetry
does not establish normalized concrete coverage for SMARTIAN/ItyFuzz/sFuzz.

The original campaigns, their original analyses, and RQ1 reference inputs
were not changed. The previous search-only consolidated snapshot is saved
at `<seminv-workspace>\outputs\rq5_complete_analysis_search_only_20261013`.
The report scripts are `experiments/rq5_timecurves/consolidate.py`,
`system_t.py`, `build_report.py`, and `test_consolidate.py`. The old baseline parser remains
unchanged for historical traceability; use the new consolidated report, not
the old sFuzz 0/36 summary, for this audited snapshot.
