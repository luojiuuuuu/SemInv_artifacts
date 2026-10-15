"""Primary T reporting: evidence-safe D plus owned timestamp-source alerts."""
from __future__ import annotations

import re

from . import d_policy
from ..static_source_detectors import _strip_comments

POLICY = 'T'
POLICY_VERSION = 'T-v1'
TIME_TOKEN = re.compile(r'\bnow\b|\bblock\s*\.\s*timestamp\b')


def time_evidence(event, lines):
    if (event.get('classification') or {}).get('kind') != 'block_dependency':
        return '', ''
    location = (event.get('evidence') or {}).get('location') or {}
    span = str(location.get('source_code') or '')
    if TIME_TOKEN.search(_strip_comments(span)):
        return 'saved_source_span', span
    line = location.get('line')
    if isinstance(line, int) and 0 < line <= len(lines) and TIME_TOKEN.search(lines[line - 1]):
        return 'source_line_recovery', lines[line - 1]
    return '', ''


def _promote(result, original=()):
    result['D_predictions'] = set(result['predictions'])
    lines = result.get('source_text', '').splitlines()
    bases = {e.get('event_id'): time_evidence(e, lines) for e in result['events']}
    for audit in result['audit']:
        basis, statement = bases.get(audit.get('event_id'), ('', '')) if audit['state'] == 'retained' else ('', '')
        audit.update(T_time_basis=basis, T_time_statement=statement,
                     source_unchanged_since_run=result.get('source_unchanged_since_run', False))
    added = {'time_manipulation'} if any(a['T_time_basis'] for a in result['audit']) else set()
    result['predictions'] = result['D_predictions'] | added
    result['excluded_legacy_predictions'] = sorted(set(original) - result['predictions'])
    result.update(reporting_policy=POLICY, reporting_policy_version=POLICY_VERSION)
    return result


def apply_t(events, original=(), *, source='', runtime=b'', suppressed_ids=()):
    """Apply to owned events; source-line recovery requires verified source text."""
    source = _strip_comments(source)
    result = d_policy.apply_d(events, original, source=source, runtime=runtime,
                              suppressed_ids=suppressed_ids)
    result.update(source_text=source, source_unchanged_since_run=bool(source))
    return _promote(result, original)


def collect_run(row, original=()):
    return _promote(d_policy.collect_run(row, original), original)
