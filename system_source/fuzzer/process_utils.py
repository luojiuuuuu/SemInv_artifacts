#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Subprocess helpers that reliably clean up descendant processes on timeout."""

from __future__ import annotations

import os
import signal
import subprocess
from typing import Any, Dict, Optional, Sequence


def process_group_options() -> Dict[str, Any]:
    if os.name == "nt":
        return {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP}
    return {"start_new_session": True}


def terminate_process_tree(proc: subprocess.Popen, grace_seconds: float = 5.0) -> None:
    """Terminate a process and all descendants without affecting the caller."""
    if proc.poll() is not None:
        return

    if os.name == "nt":
        try:
            subprocess.run(
                ["taskkill", "/PID", str(proc.pid), "/T", "/F"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=max(1.0, grace_seconds),
                check=False,
            )
        except (OSError, subprocess.SubprocessError):
            pass
    else:
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
            proc.wait(timeout=grace_seconds)
        except subprocess.TimeoutExpired:
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
            except (OSError, ProcessLookupError):
                pass
        except (OSError, ProcessLookupError):
            pass

    if proc.poll() is None:
        try:
            proc.kill()
        except OSError:
            pass
    try:
        proc.wait(timeout=grace_seconds)
    except (OSError, subprocess.TimeoutExpired):
        pass


def run_in_process_group(
    cmd: Sequence[str],
    *,
    cwd: Optional[str] = None,
    timeout: Optional[float] = None,
    **kwargs: Any,
) -> subprocess.Popen:
    """Start and wait for a command while preserving the Popen handle on timeout."""
    proc = subprocess.Popen(list(cmd), cwd=cwd, **process_group_options(), **kwargs)
    try:
        proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        terminate_process_tree(proc)
        raise
    return proc
