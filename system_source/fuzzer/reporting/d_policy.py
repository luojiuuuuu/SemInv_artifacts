"""Shared D reporting policy, using only artifact-local evidence.

No replay, ground-truth-dependent rules, or cross-run evidence lookup.
"""
from __future__ import annotations

import json
import re
import time
from pathlib import Path

from .finding_schema import (
    _filesystem_path, _low_level_return_interpretation,
    build_violation_event, fp_filter_decision,
)
from ..static_source_detectors import _function_blocks, _strip_comments

ROOT = Path(__file__).resolve().parents[2]
POLICY_VERSION = "D-v2"
EVENT_FILES = ("finding_cases_pro/violation_events.json",
               "artifacts/l5_events/violation_events.json")
FINDING_DIRS = ("finding_cases_pro", "source_meta/finding_cases_pro",
                "source_meta/finding_cases", "artifacts/raw_violation_candidates")
STRICT_TOKEN_MAP = {
    "access_control": {"access_noninterference", "arbitrary_memory_access",
                       "tx_origin_boundary", "unauthorized_call_must_fail", "unsafe_delegatecall"},
    "arithmetic": {"integer_overflow", "integer_underflow"},
    "bad_randomness": {"bad_randomness_dependency"},
    "denial_of_service": {"failed_refund_dos"},
    "front_running": {"approve_race", "transaction_order_dependency"},
    "reentrancy": {"reentrancy"},
    "time_manipulation": {"timestamp_dependency"},
    "unchecked_low_level_calls": {"unchecked_return_value"},
}


def source_path(value):
    if not value:
        return None
    value = str(value).replace("\\", "/")
    if value.startswith("//?/UNC/"):
        value = "//" + value[8:]
    elif value.startswith("//?/"):
        value = value[4:]
    path = Path(value)
    return (path if path.is_absolute() else ROOT / path).resolve()


def read_json(path):
    try:
        return json.loads(_filesystem_path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None


def semantic_additions(events):
    result = set()
    for event in events:
        kind = (event.get("classification") or {}).get("kind")
        detail = ((event.get("violation") or {}).get("trigger") or {}).get("detail") or {}
        summary = (detail.get("classification") or {}).get("summary") or ""
        if kind == "unprotected_selfdestruct":
            result.add("access_control")
        if kind == "order_independence" and "without a commit-reveal" in summary:
            result.add("front_running")
    return result


def event_categories(events):
    kinds = {(e.get("classification") or {}).get("kind") for e in events}
    return {c for c, aliases in STRICT_TOKEN_MAP.items() if kinds & aliases} | semantic_additions(events)


def checked_void_call(event, source, runtime):
    """Require both a typed void call and an immediate compiler failure guard."""
    if (event.get("classification") or {}).get("kind") != "unchecked_return_value":
        return False
    loc = (event.get("evidence") or {}).get("location") or {}
    pc = loc.get("pc")
    if not isinstance(pc, int) or pc < 0 or pc + 6 >= len(runtime) or runtime[pc] != 0xf1:
        return False
    call = re.fullmatch(r'([A-Za-z_]\w*)\.([A-Za-z_]\w*)\s*\(.*\)\s*;?',
                        str(loc.get("source_code") or "").strip(), re.S)
    if not call:
        return False
    receiver, method = call.groups()
    functions = [f for f in _function_blocks(source) if f['name'] == method]
    if len(functions) != 1 or re.search(r'\breturns\s*\(', functions[0]['header']):
        return False
    types = set(re.findall(r'\b([A-Za-z_]\w*)\s+' + re.escape(receiver) + r'\s*(?:=|;)', source))
    if len(types) != 1:
        return False
    # Reject a same-named function belonging to an unrelated source contract.
    owner = list(re.finditer(r'\bcontract\s+([A-Za-z_]\w*)\b[^\{;]*\{', source[:functions[0]['start']]))
    if not owner or owner[-1].group(1) not in types:
        return False
    if runtime[pc + 1:pc + 4] != bytes([0x15, 0x80, 0x15]):
        return False
    width = runtime[pc + 4] - 0x5f
    if not 1 <= width <= 4:
        return False
    jump = pc + 5 + width
    dest = int.from_bytes(runtime[pc + 5:jump], 'big')
    if jump >= len(runtime) or runtime[jump] != 0x57 or not jump < dest < len(runtime) or runtime[dest] != 0x5b:
        return False
    return runtime[jump + 1:dest].hex() in {'3d6000803e3d6000fd', '600080fd'}


def runtime_bytes(payload, contract):
    value = ((payload or {}).get(contract) or {}).get('coverage_snapshot') or {}
    try:
        return bytes.fromhex(str(value.get('runtime_bytecode') or '').removeprefix('0x'))
    except ValueError:
        return b''


def apply_d(events, original=(), *, source='', runtime=b'', suppressed_ids=()):
    """Counterevidence wins across copies; unrelated findings remain independent."""
    def identity(event):
        return event.get('event_id') or json.dumps(event, sort_keys=True)

    suppressed = set(suppressed_ids)
    reasons = {i: 'saved_suppression' for i in suppressed}
    for event in events:
        decision = fp_filter_decision(event, 'evidence-safe')
        if not decision['retain']:
            suppressed.add(identity(event))
            reasons[identity(event)] = decision.get('rule_id') or 'evidence_safe'
        elif checked_void_call(event, source, runtime):
            suppressed.add(identity(event))
            reasons[identity(event)] = 'checked_void_call'
    retained, seen, audit = [], set(), []
    for event in events:
        event_id = event.get('event_id')
        event_key = identity(event)
        if event_key in suppressed:
            state = 'evidence_safe_suppressed'
        elif event_key in seen:
            state = 'duplicate'
        else:
            state = 'retained'
            seen.add(event_key)
            retained.append(event)
        audit.append({'event_id': event_id, 'kind': (event.get('classification') or {}).get('kind'),
                      'evidence_subtype': (event.get('classification') or {}).get('evidence_subtype'),
                      'evidence_strength': (event.get('classification') or {}).get('evidence_strength'),
                      'state': state, 'filter_rule': reasons.get(event_key)})
    # Category-only legacy summaries cannot bypass event ownership or filtering.
    predicted = event_categories(retained)
    return {'predictions': predicted, 'events': retained, 'audit': audit,
            'excluded_legacy_predictions': sorted(set(original) - predicted),
            'reporting_policy': 'D', 'reporting_policy_version': POLICY_VERSION}


def collect_run(row, original=()):
    run = source_path(row.get('semantic_run_dir'))
    manifest = read_json(run / 'run_manifest.json') if run else None
    source = source_path(row.get('source'))
    if (not isinstance(manifest, dict) or source_path(manifest.get('source')) != source
            or manifest.get('contract') != row.get('contract')):
        raise ValueError(f"Run identity mismatch: {row.get('source')} / {run}")
    if manifest.get('fp_filter_mode') not in {'off', 'evidence-safe'}:
        raise ValueError(f'Unknown input filter mode: {run}')
    try:
        start = float(manifest['started_at'])
        end = float(manifest.get('finished_at') or time.time()) + 1
    except (KeyError, TypeError, ValueError):
        raise ValueError(f'Missing run time: {run}')
    source_current = bool(source and _filesystem_path(source).exists()
                          and _filesystem_path(source).stat().st_mtime <= start)
    text = _strip_comments(_filesystem_path(source).read_text(encoding='utf-8')) if source_current else ''
    files, copies, rejected, suppressed = [], [], [], set()

    def current(path):
        return path.exists() and start <= path.stat().st_mtime <= end

    def add(event, path, mode):
        owner = event.get('contract') or {}
        if source_path(owner.get('source')) != source or owner.get('name') != row['contract']:
            rejected.append({'event_file': str(path), 'event_id': event.get('event_id'),
                             'kind': (event.get('classification') or {}).get('kind'),
                             'observed_event_source': owner.get('source'),
                             'observed_event_contract': owner.get('name'),
                             'state': 'unverified_event_owner', 'evidence_source': mode})
        else:
            copies.append((event, path, mode))

    for relative in EVENT_FILES:
        path = _filesystem_path(run / relative)
        fa = {'event_file': str(path), 'events': 0}
        if not path.exists():
            files.append({**fa, 'state': 'absent'})
            continue
        if not current(path):
            files.append({**fa, 'state': 'stale'})
            continue
        payload = read_json(path)
        if not isinstance(payload, dict) or not isinstance(payload.get('events'), list):
            files.append({**fa, 'state': 'malformed'})
            continue
        saved = (payload.get('fp_filter') or {}).get('suppressed') or []
        suppressed.update(x['event_id'] for x in saved if x.get('event_id'))
        files.append({**fa, 'state': 'current', 'events': len(payload['events']),
                      'saved_suppressed_count': len(saved)})
        for event in payload['events']:
            add(event, path, 'event_index')
    for relative in FINDING_DIRS:
        for path in sorted(_filesystem_path(run / relative).glob('*.json')):
            finding = read_json(path)
            if not isinstance(finding, dict) or not finding.get('classification'):
                continue
            created = finding.get('created_at')
            if not current(path) or not isinstance(created, (int, float)) or not start <= created <= end:
                files.append({'event_file': str(path), 'state': 'stale_finding', 'events': 0})
                continue
            event = finding.get('violation_event')
            mode = 'embedded_event'
            if not event:
                if (finding.get('reproduction') or {}).get('mode') != 'source_pattern':
                    continue
                # Reinterpret only the saved finding against its unchanged owned source.
                owner = finding.get('contract') or {}
                if not source_current or source_path(owner.get('source')) != source or owner.get('name') != row['contract']:
                    continue
                finding.update(_low_level_return_interpretation(finding) or {})
                event = build_violation_event(finding)
                mode = 'saved_static_finding'
            files.append({'event_file': str(path), 'state': 'current_finding', 'events': 1,
                          'created_at': created, 'mtime': path.stat().st_mtime})
            add(event, path, mode)
    results_path = _filesystem_path(run / 'artifacts/l4_fuzz/results.json')
    results = read_json(results_path) if current(results_path) else None
    result = apply_d([e for e, _, _ in copies], original,
                     source=text, runtime=runtime_bytes(results, row['contract']), suppressed_ids=suppressed)
    for audit, (_, path, mode) in zip(result['audit'], copies):
        audit.update(event_file=str(path), evidence_source=mode)
    context = {'source': row['source'], 'contract': row['contract'], 'semantic_run_dir': str(run)}
    result['audit'] = [{**context, **a} for a in result['audit'] + rejected]
    result['files'] = [{**context, **a} for a in files]
    result['source_text'] = text
    result['source_unchanged_since_run'] = source_current
    result['input_fp_filter_mode'] = manifest['fp_filter_mode']
    return result
