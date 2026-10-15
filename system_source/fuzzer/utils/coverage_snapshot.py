"""Serializable runtime coverage evidence without changing search feedback."""


def _pc(value):
    return int(value, 16) if isinstance(value, str) and value.startswith("0x") else int(value)


def coverage_snapshot(covered, overall_pcs, overall_jumpis, visited_branches, runtime_bytecode=""):
    pcs = {_pc(value) for value in overall_pcs}
    hits = {_pc(value) for value in covered}
    jumpis = {_pc(value) for value in overall_jumpis}
    raw_conditions = {(_pc(pc), int(condition)) for pc, values in visited_branches.items()
                      for condition in values}
    outcomes = {(pc, int(condition != 0)) for pc, condition in raw_conditions if pc in jumpis}
    return {
        "schema": "seminv.runtime_coverage.v1",
        "runtime_bytecode": runtime_bytecode,
        "overall_pcs": sorted(pcs), "overall_jumpis": sorted(jumpis),
        "concrete_pcs": sorted(hits), "branch_outcomes": sorted(outcomes),
        "branch_raw_conditions": sorted(raw_conditions),
        "pc_coverage": {"covered": len(hits & pcs), "total": len(pcs),
                        "percentage": 100 * len(hits & pcs) / len(pcs) if pcs else None},
        "branch_coverage": {"covered": len(outcomes), "total": 2 * len(jumpis),
                            "percentage": 100 * len(outcomes) / (2 * len(jumpis)) if jumpis else None},
        "outside_universe": sorted(hits - pcs),
    }
