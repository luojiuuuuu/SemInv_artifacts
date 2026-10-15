# -*- coding: utf-8 -*-
import json, math
from pathlib import Path
from typing import Dict, Any, List

def _norm(x, tau=3.0):
    return 1 - math.exp(-x / float(tau))

def score_and_pick(project_root: str, testfile_path: str, k: int = 32) -> Dict[str, Any]:
    """
    评分并挑选 Top-K 种子，所有输出写入 {test_name}_meta/ 目录。
    - 新格式 seeds:  根为 list[ {constructor?, steps: [...]}, ... ]
    - 旧格式 seeds:  {"seeds":[ {id,label_guess,sequence...}, ... ]}
    """
    pr = Path(project_root).resolve()
    # 如 keepMyEther_Functional.t.sol -> keepMyEther
    test_name = str(Path(testfile_path).stem).split('_')[0]
    meta_dir = pr / f"{test_name}_meta"
    meta_dir.mkdir(exist_ok=True)

    # 覆盖签名（目前未直接使用，预留）
    cov_path = meta_dir / "coverage_global.json"
    cov = json.loads(cov_path.read_text(encoding="utf-8")) if cov_path.exists() else {}

    # 寻找 seeds 文件
    seed_candidates: List[Path] = [
        meta_dir / "seeds.json",
        pr / "seeds" / f"{test_name}_seeds.json",
        pr / "seeds" / "seeds.json",
    ]
    seeds_path = next((p for p in seed_candidates if p.exists()), None)
    if seeds_path is None:
        raise FileNotFoundError(
            f"[score_and_pick] 未找到 seeds.json，已尝试：\n" +
            "\n".join(f"  - {p}" for p in seed_candidates)
        )

    seeds_root = json.loads(seeds_path.read_text(encoding="utf-8"))

    # 判断新旧格式
    new_format = isinstance(seeds_root, list)
    ranked: List[Dict[str, Any]] = []

    if new_format:
        # ---------- 新格式：[ {constructor?, steps:[{func,args,from}, ...]}, ... ] ----------
        def score_case(case: Dict[str, Any]) -> float:
            steps = case.get("steps", []) or []
            funcs = [s.get("func", "") for s in steps if isinstance(s, dict)]
            addrs = [str(s.get("from", "")).lower() for s in steps if isinstance(s, dict)]
            uniq_funcs = len(set(f for f in funcs if f))
            uniq_addrs = len(set(a for a in addrs if a))

            # 风险关键词（可按需扩充）
            risk_words = ("approve(", "transferFrom(", "transfer(", "mint", "freeze", "withdraw", "delegatecall", "call(", "selfdestruct")
            risky = any(any(w in (f or "") for w in risk_words) for f in funcs)

            s1 = 0.45 * min(_norm(uniq_funcs, tau=3.0), 1.0)                # 多样性
            s2 = 0.25 * min(_norm(max(len(steps), 0),  tau=4.0), 1.0)       # 步数
            s3 = 0.20 * (1.0 if risky else 0.0)                              # 风险路径线索
            s4 = 0.10 * min(_norm(uniq_addrs, tau=2.0), 1.0)                 # 多地址
            return round(s1 + s2 + s3 + s4, 4)

        for idx, case in enumerate(seeds_root):
            ranked.append({
                "id": f"case-{idx}",
                "score": score_case(case),
                "novelty": {"edge": 0, "slot": 0, "event": 0},
                "risk": []
            })

        ranked.sort(key=lambda x: x["score"], reverse=True)
        topk_idx = [int(r["id"].split("-", 1)[1]) for r in ranked[:k]]
        topk_cases = [seeds_root[i] for i in topk_idx]

        out = {"meta": {"k": k, "scoring_version": "0.2-newfmt"}, "ranked": ranked, "topk_index": topk_idx}

        # 写文件（新格式直接写列表）
        (meta_dir / "seeds_scored.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
        (meta_dir / "seeds.topk.json").write_text(json.dumps(topk_cases, indent=2), encoding="utf-8")

        seeds_dir = pr / "seeds"
        seeds_dir.mkdir(exist_ok=True)
        (seeds_dir / f"{test_name}_seeds.topk.json").write_text(json.dumps(topk_cases, indent=2), encoding="utf-8")

        return out

    else:
        # ---------- 旧格式：{"seeds":[ {id,label_guess,...}, ... ]} ----------
        seeds = seeds_root.get("seeds", [])

        def _norm01(x: float) -> float:
            return min(max(x, 0.0), 1.0)

        seen_labels = set()
        for s in seeds:
            labels = tuple(sorted(s.get("label_guess", [])))
            new_labels = len([l for l in labels if l not in seen_labels])
            novelty = {"edge": new_labels, "slot": 0, "event": 0}
            score = 0.6 * _norm01(new_labels) + 0.4 * (1.0 if "external-call" in s.get("label_guess", []) else 0.0)
            ranked.append({"id": s.get("id", ""), "score": round(score, 4), "novelty": novelty, "risk": []})
            seen_labels.update(labels)

        ranked.sort(key=lambda x: x["score"], reverse=True)
        topk_ids = {r["id"] for r in ranked[:k]}
        out = {"meta": {"k": k, "scoring_version": "0.1-legacy"}, "ranked": ranked, "topk": list(topk_ids)}

        (meta_dir / "seeds_scored.json").write_text(json.dumps(out, indent=2), encoding="utf-8")

        topk_obj = {"meta": {"source": str(seeds_path)}, "seeds": [s for s in seeds if s.get("id", "") in topk_ids]}
        (meta_dir / "seeds.topk.json").write_text(json.dumps(topk_obj, indent=2), encoding="utf-8")

        seeds_dir = pr / "seeds"
        seeds_dir.mkdir(exist_ok=True)
        (seeds_dir / f"{test_name}_seeds.topk.json").write_text(json.dumps(topk_obj, indent=2), encoding="utf-8")

        return out
