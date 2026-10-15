# RQ4 Offline Path Evidence Recovery

Generated from frozen archives on 2026-10-14. This audit reads files only: it does not compile, run Foundry, invoke an RPC, run fuzzing, or replay any witness.

## Scope and Counts

- Attempted PoCs: 65; top-level zero-exit runs: 48; nonzero exits: 17.
- Archived events across all attempts: 334 rows, of which 333 are invariant events.
- Zero-exit invariant events: 295. Legacy rule-assisted labels are retained only for provenance: `{"部分相关": 27, "未覆盖": 2, "强相关": 19}`.
- The offline audit located source records for all 65 listed cases; the source checkout itself is not included in this artifact.
- Archived end-to-end runtime: zero-exit median 968.04 s (mean 1274.66 s; range 50.7--9485.33 s); event discovery time is reported separately from raw errors.

| Offline recovery measure | Result | Meaning |
|---|---:|---|
| Events linked by selected contract, normalized PC, and detector type | 281/295 (95.25%) | Exact event-to-`results.json` dynamic individual link |
| PC/type-unlinked invariant events | 14/295 | No matching raw error under the selected contract/PC/type key |
| Events with at least two transactions executed through the trigger | 198/295 (67.12%) | Counts only the dynamic prefix through `trigger_tx_index` |
| Zero-exit cases with any multi-transaction executed prefix | 42/48 | Case-level dynamic path evidence |
| PoCs with a PoC-linked dynamic invariant witness | 39/48 (81.25%) | Trigger selector uniquely decodes to a PoC-declared function matching the event function sequence |
| PoC-linked invariant events | 131/295 (44.41%) | Event-level path witnesses; roots, helpers, and callbacks are included |
| Median time to first PoC-linked invariant witness | 61.54 s (n=39) | Earliest qualifying raw error time per covered PoC |
| Cases where all invariant events link by contract/PC/type | 36 | Every archived invariant event in the case has a raw individual |
| Cases with some linked and some unlinked events | 9 | Mixed event-level recoverability |
| Cases with events but no contract/PC/type-linked individual | 1 | All event paths in these cases remain unrecovered from `results.json` |
| Cases with no archived invariant event | 2 | No SemInv invariant path to align in this archive |

### Stored Event Trajectories and Raw Individuals

Stored `execution.trajectory` steps for the 295 zero-exit invariant events: 1: 277, missing: 14, 2: 3, 3: 1.
The separate `results.json` individual is the fuzzed top-level transaction sequence dynamically executed by SemInv. Path length is truncated at `trigger_tx_index`; executed-prefix distribution among linked events: 1 tx: 83, 2 tx: 12, 3 tx: 7, 4 tx: 2, 5 tx: 177. Full individual length remains available as candidate metadata.

The archived `execution.trajectory` and raw `individual` are distinct records. The raw individual is direct dynamic evidence for SemInv's own execution; it is not the transaction sequence of the original Foundry PoC.
Across the recovered zero-exit individuals, 399/1053 top-level selectors (37.89%) decode to a function declared in the current PoC source using its ABI signature. Undecoded selectors remain raw; selector decoding is not treated as a path hit.

## Source-derived PoC Path

The script used a lightweight source-text parser to identify Solidity function bodies, selected test roots from the archived PoC manifest, and approximated direct calls among functions defined in the same source. 66 invariant events mention a test-root function; 52 match only a test root and are not counted as attack-function overlap. After excluding roots, 14 events (4.75%) intersect a non-root function reachable in the direct static call graph, including 13 (4.41%) that also mention a name classified as attack-like by the source heuristic. Separately, 51 events (17.29%) match a callback-like declaration name. Setup/fork-init locations occur in 27 events and infrastructure functions in 89; these sets can overlap with the path candidates.
The later Foundry replay-pass cohort overlaps the SemInv zero-exit cohort in 34 cases. Those cases contain 210 invariant events; 200 link by selected contract/PC/type, 142 have a multi-transaction executed prefix, and 101 are PoC-linked dynamic witnesses.

These source-parser counts are supplementary; the primary result uses runtime individual prefixes and trigger-function alignment.

The Foundry replay logs are quiet (`forge test ... -q`) and do not contain saved runtime call trees, so this archive cannot compare ordered internal call edges between the original PoC and SemInv. It does support dynamic top-level SemInv path-prefix evidence through each invariant trigger, plus exact entrypoint linkage to PoC-declared functions.
All 44 replay-pass logs are present; 44 record the quiet flag and 0 contain a `Traces:` marker.
The existing `attack_flow_steps` manifest field is zero in 42/48 zero-exit cases, so it is not a complete reference path and is excluded from path-score denominators.
Raw detector errors preserve event-relative `time` from `execution_begin`. Among 39 cases with a PoC-linked witness, median time-to-first-witness is 61.54 s (mean 212.41 s; range 1.09--2240.42 s).

## Case-level Examples

| PoC | Invariant events | Contract/PC/type-linked | Multi-transaction executed prefixes | Setup/fork-init locations | Non-root static-callgraph overlap | Test-root-only overlap | Callback-name candidate |
|---|---:|---:|---:|---:|---:|---:|---:|
| `LAXO_Token_exp.sol` | 2 | 2 | 1 | 0 | 1 | 0 | 1 |
| `ThetanutsVaultShareRounding_exp.sol` | 3 | 3 | 1 | 1 | 0 | 1 | 1 |
| `YSDAO_exp.sol` | 7 | 7 | 6 | 1 | 0 | 0 | 6 |
| `WHALE_exp.sol` | 4 | 4 | 4 | 0 | 2 | 0 | 2 |

### Event-level Illustrations

- **LAXO:** event `a3b79617f6d7d93f722e538b` reports `I6.external.call_return_consistency` at `start()`. Event `34fcb71109cf4e771ea71ffd` reports `I5.resource.bounded_execution`; its linked individual executes a five-transaction prefix of `pancakeV3FlashCallback(uint256,uint256,bytes)` calls through trigger index 4, aligning the invariant with the PoC callback entry.
- **WHALE:** events `46f6e8f909661d71ebe5176a` and `0ee5c69dd93eb9a8c87f0d6b` report bounded-execution in `attack(uint256)`. Each links to a five-transaction individual prefix of `attack(uint256)` calls, with the trigger at index 4, showing the multi-transaction path that reaches the invariant.

The per-event CSV preserves event PCs, source lines, reported function sequences, raw candidate selectors, trigger transaction indices, static function-graph overlap, and replay-validation metadata. The per-candidate CSV stores one row for each recovered fuzz individual and its selector sequence; it intentionally avoids copying full calldata.

## Metrics Supported Without Rerunning

1. **PoC-linked dynamic witness coverage:** event- and case-level counts under selected-contract + normalized-PC + detector-type linkage, followed by unique trigger-selector decoding and function-sequence agreement. Test roots, helpers, and callbacks remain eligible.
2. **Dynamic multi-transaction reachability:** count the ordered top-level individual prefix ending at the event trigger; do not count candidate suffix transactions after the trigger.
3. **Time-to-first invariant witness:** use archived raw error time relative to `execution_begin`, taking the earliest qualifying witness per PoC.
4. **Supplementary source overlap:** retain static callgraph and callback-name analyses as context, not as the primary path score.

The reported metric is at top-level trigger-entrypoint and transaction-prefix granularity; stored SemInv replay validation is retained as a separate reproduction record.

## Files

- `case_path_recovery.csv`: all 65 attempted inputs, with the 48 zero-exit cohort clearly flagged.
- `event_path_recovery.csv`: every archived event row; invariant events are explicitly flagged.
- `fuzz_individual_trace_candidates.csv`: PC-linked raw fuzz individuals as top-level selector sequences.
- `summary.json`: machine-readable counts, denominators, and limitations.
- `scripts/audit_rq4_offline_path_alignment.py`: deterministic offline parser and aggregation.

Reproduce the archive with `python scripts/audit_rq4_offline_path_alignment.py` from the repository root. The script reads only frozen local artifacts.
