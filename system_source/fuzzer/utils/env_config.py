#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
from pathlib import Path
from typing import Dict, Optional


def _project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def load_env_file(env_file: Optional[str] = None) -> Dict[str, str]:
    path = Path(env_file) if env_file else (_project_root() / ".env")
    loaded: Dict[str, str] = {}
    if not path.exists():
        return loaded

    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except Exception:
        return loaded

    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if not key:
            continue
        loaded[key] = value
        os.environ.setdefault(key, value)
    return loaded


def get_llm_config(
    *,
    env_file: Optional[str] = None,
    api_key: Optional[str] = None,
    api_url: Optional[str] = None,
    model: Optional[str] = None,
) -> Dict[str, Optional[str]]:
    load_env_file(env_file)
    return {
        "api_key": api_key or os.getenv("LLM_API_KEY"),
        "api_url": api_url or os.getenv("LLM_API_URL"),
        "model": model or os.getenv("LLM_MODEL"),
    }
