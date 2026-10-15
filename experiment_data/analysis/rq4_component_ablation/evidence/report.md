# RQ3 full-dataset completion analysis

Terminal tasks: 717/717; complete: True.
Protocol: search + fresh upstream, T-v1 / D-v2; no Full rerun; replay and minimization disabled.

| Variant | Strict-8 seed-11 observed N | TP | Recall | Mean coverage |
|---|---:|---:|---:|---:|
| Full | 139 | 128 | 92.09% | 89.26% |
| NoSymbolic | 139 | 126 | 90.65% | 83.35% |
| NoUIRSearch_NoSymbolic | 139 | 127 | 91.37% | 83.36% |
| LegacyNoUIR | 139 | 119 | 85.61% | 88.69% |
| NoUIRSearch | 139 | 129 | 92.81% | 89.11% |
| NoPropertyTests | 139 | 129 | 92.81% | 89.04% |
| LegacyNoUIR_NoSymbolic | 139 | 117 | 84.17% | 83.22% |
| NoFunctionalSeeds | 139 | 129 | 92.81% | 89.37% |

Original upstream events with missing source ownership: 93. These remain unresolved, not verified negatives.
See paired_effects.csv for marginal and interaction effects, normal_completion_sensitivity.csv for paired successful runs,
property_exact_output_ablation.csv for the exact property-channel marginal, and discordant_cases.csv for wins and losses.
