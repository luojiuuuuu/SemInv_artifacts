#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Helpers for coarse experiment failure labels."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any, Dict, Iterable, Optional


SOLIDITY_ERROR = "solidity_error"
FOUNDRY_FUNC_ERROR = "foundry_func_error"
FOUNDRY_INVA_ERROR = "foundry_inva_error"
LLM_API_ERROR = "llm_api_error"
EMPTY_ABI_OR_NO_EXTERNAL_ENTRY = "empty_abi_or_no_external_entry"
ABSTRACT_OR_BASE_CONTRACT = "abstract_or_base_contract"
NO_DEPLOYABLE_CONTRACT = "no_deployable_contract"
L1_L3_OTHER_ERROR = "l1_l3_other_error"
NO_ERROR = ""

_SOLIDITY_COMPILE_RE = re.compile(
    r"(solcx\.exceptions\.SolcError|CompilerError|ParserError|DeclarationError|"
    r"TypeError:|SyntaxError:|No compiled contracts found|Contract .* not found|"
    r"Source .* not found|Error: Source file requires different compiler version)",
    re.IGNORECASE,
)
_LLM_API_RE = re.compile(
    r"(HTTPError:.*(?:api|chat|completions)|Client Error:.*(?:api|chat|completions)|"
    r"Payment Required.*(?:api|chat|completions)|Missing LLM config)",
    re.IGNORECASE,
)
_CONTRACT_SELECTION_RE = re.compile(
    r"(?:\[contract_selection_error\].*?error_type=|error_type[\"':=\s]+)"
    r"(empty_abi_or_no_external_entry|abstract_or_base_contract|no_deployable_contract)",
    re.IGNORECASE | re.DOTALL,
)


def _read_text(path: Optional[Path]) -> str:
    if not path:
        return ""
    try:
        if path.exists() and path.is_file():
            return path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""
    return ""


def _first_nonempty_line(text: str) -> str:
    for line in (text or "").splitlines():
        stripped = line.strip()
        if stripped:
            return stripped[:500]
    return ""


def classify_l1_l3_error(
    *,
    exit_code: Any,
    stdout_path: Optional[Path] = None,
    stderr_path: Optional[Path] = None,
    functional_meta_dir: Optional[Path] = None,
    invariant_meta_dir: Optional[Path] = None,
    supplement_meta_dir: Optional[Path] = None,
    extra_paths: Iterable[Path] = (),
) -> Dict[str, Any]:
    """Classify L1-L3 failure into stable experiment labels.

    The three paper-facing labels are:
    - solidity_error: the target Solidity source failed before generated Foundry
      tests became the meaningful failure surface.
    - foundry_func_error: generated functional Foundry test stage failed.
    - foundry_inva_error: generated invariant/supplement Foundry test stage failed.
    """
    if exit_code is None or str(exit_code) == "":
        return {"error_type": NO_ERROR, "error_stage": "", "error_detail": ""}
    if str(exit_code) in ("0", "0.0"):
        return {"error_type": NO_ERROR, "error_stage": "", "error_detail": ""}

    paths = [stdout_path, stderr_path]
    for meta in (functional_meta_dir, invariant_meta_dir, supplement_meta_dir):
        if meta:
            paths.extend(
                [
                    meta / "compile_error.txt",
                    meta / "json_parse_error.txt",
                    meta / "fallback_diagnostic.txt",
                    meta / "last_stderr.txt",
                ]
            )
    paths.extend(extra_paths or [])

    parts = [_read_text(path) for path in paths]
    text = "\n".join(part for part in parts if part)
    functional_compile_text = _read_text(functional_meta_dir / "compile_error.txt" if functional_meta_dir else None)
    invariant_compile_text = _read_text(invariant_meta_dir / "compile_error.txt" if invariant_meta_dir else None)
    supplement_compile_text = _read_text(supplement_meta_dir / "compile_error.txt" if supplement_meta_dir else None)

    has_functional_marker = "[functional_test]" in text or "run_functional_pipeline" in text
    has_invariant_marker = "[invariant_test]" in text or "run_invariant_pipeline" in text
    has_generated_test_marker = (
        "[functional_test] wrote test" in text
        or "[invariant_test] wrote test" in text
        or "run_foundry_tests" in text
    )

    selection_match = _CONTRACT_SELECTION_RE.search(text or "")
    if selection_match:
        error_type = selection_match.group(1).lower()
        return {
            "error_type": error_type,
            "error_stage": "contract_selection",
            "error_detail": _first_nonempty_line(text),
        }

    if not has_generated_test_marker and _SOLIDITY_COMPILE_RE.search(text or ""):
        return {
            "error_type": SOLIDITY_ERROR,
            "error_stage": "solidity_compile",
            "error_detail": _first_nonempty_line(text),
        }

    if functional_compile_text:
        return {
            "error_type": FOUNDRY_FUNC_ERROR,
            "error_stage": "foundry_functional",
            "error_detail": _first_nonempty_line(functional_compile_text),
        }

    if invariant_compile_text or supplement_compile_text:
        diag = invariant_compile_text or supplement_compile_text
        return {
            "error_type": FOUNDRY_INVA_ERROR,
            "error_stage": "foundry_invariant",
            "error_detail": _first_nonempty_line(diag),
        }

    if has_functional_marker and "forge test (json)" in text and not has_invariant_marker:
        return {
            "error_type": FOUNDRY_FUNC_ERROR,
            "error_stage": "foundry_functional",
            "error_detail": _first_nonempty_line(text),
        }

    if has_invariant_marker and "forge test (json)" in text:
        return {
            "error_type": FOUNDRY_INVA_ERROR,
            "error_stage": "foundry_invariant",
            "error_detail": _first_nonempty_line(text),
        }

    if _LLM_API_RE.search(text or ""):
        return {
            "error_type": LLM_API_ERROR,
            "error_stage": "llm",
            "error_detail": _first_nonempty_line(text),
        }

    if _SOLIDITY_COMPILE_RE.search(text or "") and not has_functional_marker and not has_invariant_marker:
        return {
            "error_type": SOLIDITY_ERROR,
            "error_stage": "solidity_compile",
            "error_detail": _first_nonempty_line(text),
        }

    return {
        "error_type": L1_L3_OTHER_ERROR if str(exit_code) not in ("", "None") else "",
        "error_stage": "l1_l3_foundry" if str(exit_code) not in ("", "None") else "",
        "error_detail": _first_nonempty_line(text),
    }
