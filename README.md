# SemInv

SemInv is a smart-contract vulnerability detector built around semantic invariant recovery, invariant-aware guidance, and replayable vulnerability witnesses.

This artifact is organized to mirror the accompanying paper, **“SemInv: Detecting Smart Contract Vulnerabilities through Semantic Invariants.”** The paper's experimental section is the authority for the six research questions, reported metrics, dataset sizes, and evaluation settings in this repository.

## Repository layout

```text
SemInv_OOPSLA/
├── system_source/          # SemInv implementation and runtime assets
├── experiment_data/
│   ├── datasets/           # Recoverable SmartBugs and ERC input snapshots
│   └── analysis/
│       ├── paper_summary.json
│       ├── experiment_settings.json
│       ├── rq1_detection_effectiveness/
│       ├── rq2_semantic_recovery/
│       ├── rq3_coverage_discovery/
│       ├── rq4_component_ablation/
│       ├── rq5_defi_alignment/
│       └── rq6_replay_traceability/
├── artifact/               # Environment, evidence map, and review checks
├── submission/             # Artifact-readiness audit
└── REPRODUCIBILITY.md      # Reproduction scope and commands
```

Each RQ directory separates:

- `reported/`: compact, paper-aligned tables and figure data;
- `evidence/`: run-level measurements, mappings, validation summaries, and audit material;
- `figures/`: exported plots when an exact figure artifact is available.

## Experimental questions

- **RQ1 — Detection effectiveness:** comparison with eight analyzers on SmartBugs Curated.
- **RQ2 — Semantic recovery:** structural recovery and ERC semantic-violation detection.
- **RQ3 — Coverage and discovery:** candidate-hit progress and instruction/branch coverage against five fuzzers.
- **RQ4 — Component contributions:** ablations for functional seeds, property tests, invariant annotations, guidance, and solver support.
- **RQ5 — DeFi alignment:** source-to-trace alignment on DeFiHackLabs incidents.
- **RQ6 — Replay and traceability:** replay reproduction, witness reduction, explanation parsing, and source-context matching.

The name `ConFuzzius` is retained only where it identifies the comparison baseline used by the paper. The implementation under `system_source/` is branded and exposed as SemInv.

## Entry points

```powershell
cd <artifact-root>\system_source
python -m fuzzer.main --help
```

See [`experiment_data/README.md`](experiment_data/README.md) for the experiment-data contract and the mapping from paper claims to evidence files.

For artifact review, begin with [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) and run:

```powershell
pwsh -File artifact\scripts\verify_artifact.ps1
```

The package supports paper-number auditing and archived-result review. It does not yet claim a complete clean-room rerun of all six RQs; the exact limitations are recorded in `submission/artifact_readiness_report.md`.

