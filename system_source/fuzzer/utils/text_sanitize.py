#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Small text cleanup helpers for user-facing reports."""

from __future__ import annotations

import re
from typing import Any


MOJIBAKE_REPLACEMENTS = {
    "鈥檚": "'s",
    "鈥榮": "'s",
    "鈥檛": "n't",
    "鈥榯": "'t",
    "鈥檙": "'r",
    "鈥榩": "'p",
    "鈥": "'",
    "â€™": "'",
    "â€˜": "'",
    "â€œ": '"',
    "â€\x9d": '"',
    "â€“": "-",
    "â€”": "-",
    "Â±": "+/-",
    "卤": "+/-",
}


def sanitize_report_text(text: Any) -> Any:
    if not isinstance(text, str):
        return text
    out = text
    for bad, good in MOJIBAKE_REPLACEMENTS.items():
        out = out.replace(bad, good)
    out = out.replace("\u2018", "'").replace("\u2019", "'")
    out = out.replace("\u201c", '"').replace("\u201d", '"')
    out = out.replace("\u2013", "-").replace("\u2014", "-")
    out = re.sub(r"[ \t]+\n", "\n", out)
    return out


def sanitize_jsonable(value: Any) -> Any:
    if isinstance(value, str):
        return sanitize_report_text(value)
    if isinstance(value, list):
        return [sanitize_jsonable(item) for item in value]
    if isinstance(value, tuple):
        return [sanitize_jsonable(item) for item in value]
    if isinstance(value, dict):
        return {key: sanitize_jsonable(item) for key, item in value.items()}
    return value

