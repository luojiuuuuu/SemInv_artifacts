# Artifact review layer

This directory turns the paper-aligned source and result archive into an inspectable artifact package.

## What can be reproduced

| Level | Status | How |
|---|---|---|
| Paper-number audit | Supported | Run `scripts/audit_reported_results.py` to compare reported tables with preserved evidence. |
| Package-structure audit | Supported | Run `scripts/verify_artifact.ps1` to validate JSON/CSV syntax, dataset counts, source branding, and paper values. |
| SemInv CLI smoke check | Supported | Install the observed lock and run `python -m fuzzer.main --help` from `system_source/`. |
| RQ1/RQ2 input reconstruction | Supported | The 143 SmartBugs and 35 ERC Solidity inputs are bundled. |
| RQ6 saved-sequence inspection | Supported | The frozen event inventory and finding payloads are bundled. |
| Full six-RQ clean-room rerun | Partial | Exact baseline builds, DeFiHackLabs PoC sources, all historical run wrappers, and an immutable DeepSeek-V3 snapshot are not all present. |

## Files

- `evidence_index.csv`: paper item to evidence mapping.
- `claim_evidence_matrix.csv`: integrity status for the major experimental claims.
- `baseline_inventory.csv`: known and missing baseline versions, seeds, and budgets.
- `reproducibility_status.json`: machine-readable readiness summary.
- `audit_results.json`: generated result of the current cross-check.
- `environment/`: observed toolchain and Python dependency lock.
- `scripts/`: read-only validation and dataset-inventory utilities.

The single known numeric provenance issue is RQ4 Full: the final paper reports 129 GT-matching hits, while the preserved `t_v1` source snapshot recomputes 128. Both values and the source diagnosis are retained.

