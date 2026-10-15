"""Read existing RQ6 artifacts and write analysis only into this directory."""
from __future__ import annotations

import ast
import collections
import csv
import importlib.util
import json
import os
import pathlib
import re
import statistics
import sys

OUT = pathlib.Path(__file__).resolve().parent
BASE = OUT.parent
REPO = pathlib.Path('<seminv-workspace>')


def read(path):
    return json.loads(pathlib.Path(path).read_text(encoding='utf-8-sig'))


def norm(path):
    return str(path or '').replace('\\', '/').removeprefix('//?/').lower()


def source_key(path):
    path = norm(path)
    return path[path.index('comp_dataset/'):] if 'comp_dataset/' in path else path


def write_json(name, data):
    (OUT / name).write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def write_csv(name, rows):
    if not rows:
        return
    with (OUT / name).open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def counts(values):
    return dict(collections.Counter(values))


def quantile(values, fraction):
    vals = sorted(values)
    if not vals:
        return None
    position = (len(vals) - 1) * fraction
    lo = int(position)
    hi = min(lo + 1, len(vals) - 1)
    return vals[lo] + (vals[hi] - vals[lo]) * (position - lo)


def dist(values):
    vals = [x for x in values if x is not None]
    if not vals:
        return {'n': 0}
    return {'n': len(vals), 'sum': sum(vals), 'mean': statistics.mean(vals),
            'min': min(vals), 'q1': quantile(vals, .25), 'median': quantile(vals, .5),
            'q3': quantile(vals, .75), 'p95': quantile(vals, .95), 'max': max(vals)}


def good(outcome):
    worker = (outcome or {}).get('worker') or {}
    return bool(outcome and outcome.get('status') == 'same_pc_type_observed'
                and worker.get('population_sizes') == [1]
                and worker.get('requested_steps') == worker.get('executed_steps'))


def extract_abi(text):
    marker = '---------------abi---------------'
    if marker not in text:
        return None
    line = text.split(marker, 1)[1].lstrip().splitlines()[0]
    try:
        data = ast.literal_eval(line)
        return data if isinstance(data, list) and all(isinstance(x, dict) for x in data) else None
    except (SyntaxError, ValueError):
        return None


def length_bin(length):
    return '1' if length == 1 else '2-3' if length <= 3 else '>=4'


def calldata_bytes(steps):
    total = 0
    for step in steps:
        data = step.get('calldata')
        if not isinstance(data, str) or not re.fullmatch(r'(?:0x)?[0-9a-fA-F]*', data):
            return None
        data = data.removeprefix('0x')
        if len(data) % 2:
            return None
        total += len(data) // 2
    return total


def main():
    events = read(BASE / 'frozen/events.json')
    payloads = {x['validation_id']: x for x in read(BASE / 'frozen/finding_payloads.json')}
    selected = read(BASE / 'frozen/selected_runs.json')
    by_source = {source_key(x['source']): x for x in selected}
    by_run = {norm(x['run_dir']): x for x in selected}
    event_by_id = {x['validation_id']: x for x in events}
    event_index = collections.defaultdict(list)
    finding_path_index = collections.defaultdict(list)
    for event in events:
        event_index[(norm(event['semantic_run_dir']), event['event_id'])].append(event['validation_id'])
        if event['validation_id'] in payloads:
            finding_path_index[norm(payloads[event['validation_id']]['finding_path'])].append(event['validation_id'])

    outcome_map = {}
    attempt_rows = []
    abi_by_source = {}
    for file in sorted((BASE / 'runs').glob('*/outcome.json')):
        match = re.fullmatch(r'(T\d+)_(processed|original|delete)_(\d+)', file.parent.name)
        if not match:
            continue
        vid, kind, index = match.groups()
        if vid not in event_by_id:
            continue
        data = read(file)
        outcome_map[file.parent.name] = data
        worker = data.get('worker') or {}
        phase = kind + ('_first' if index == '1' else '_repeat') if kind != 'delete' else 'deletion'
        event = event_by_id[vid]
        abi = extract_abi(data.get('stdout_tail', ''))
        if abi is not None:
            abi_by_source.setdefault(source_key(event['source']), abi)
        attempt_rows.append({'validation_id': vid, 'phase': phase, 'attempt_index': int(index),
                             'category': event['source'].split('/')[1], 'source': event['source'],
                             'status': data.get('status'), 'diagnostic_valid': good(data),
                             'wall_seconds': data.get('seconds'), 'worker_seconds': worker.get('seconds'),
                             'requested_steps': worker.get('requested_steps'),
                             'executed_steps': worker.get('executed_steps'),
                             'evm_error_steps': sum(bool(t.get('evm_error')) for t in worker.get('actual_transactions', [])),
                             'outcome_file': str(file)})

    def outcome(vid, kind, repeat=1):
        return outcome_map.get(f'{vid}_{kind}_{repeat}')

    event_rows = []
    for event in events:
        vid = event['validation_id']
        dynamic = event['has_finding']
        finding = payloads.get(vid, {}).get('finding') or {}
        raw = payloads.get(vid, {}).get('raw') or {}
        proc = outcome(vid, 'processed')
        orig = outcome(vid, 'original')
        psteps = (finding.get('trajectory') or {}).get('steps') or []
        rsteps = (raw.get('trajectory') or {}).get('steps') or []
        classification = finding.get('classification') or {}
        if not dynamic:
            classification = (read(event['event_file']).get('classification') or {})
        row = {'validation_id': vid, 'source': event['source'], 'contract': event['contract'],
               'category': event['source'].split('/')[1], 'kind': event['kind'],
               'invariant_category': classification.get('invariant_category') or 'unknown',
               'run_stage': re.search(r'round_(\d+s)', event['semantic_run_dir']).group(1),
               'event_id': event['event_id'], 'has_sequence': dynamic,
               'location_pc': (finding.get('location') or {}).get('pc'),
               'detector_type': classification.get('type'),
               'raw_status': event.get('raw_status', 'not_applicable'),
               'raw_steps_metadata': event.get('raw_steps'), 'processed_steps': len(psteps) if dynamic else None,
               'exact_raw_steps': len(rsteps) if raw else None,
               'raw_input_bytes': calldata_bytes(rsteps) if raw else None,
               'processed_input_bytes': calldata_bytes(psteps) if dynamic else None,
               'processed_first': proc['status'] if proc else 'not_applicable_no_sequence',
               'original_first': orig['status'] if orig else 'not_run' if dynamic else 'not_applicable_no_sequence',
               'processed_good': good(proc), 'original_good': good(orig),
               'processed_3of3': all(good(outcome(vid, 'processed', n)) for n in [1, 2, 3]),
               'original_3of3': all(good(outcome(vid, 'original', n)) for n in [1, 2, 3]),
               'shortened': bool(dynamic and (event.get('raw_steps') or 0) > (event.get('processed_steps') or 0)),
               'sequence_setup_steps': len((finding.get('trajectory') or {}).get('setup') or []),
               'nonempty_trace_fields': sum(bool((finding.get('trace') or {}).get(k)) for k in ['key_path_lines','target_calls','handler_calls','events','assert_lines','raw_path']),
               'historical_oracle_status': ((finding.get('hybrid_replay') or {}).get('oracle') or {}).get('status'),
               'historical_oracle_reason': ((finding.get('hybrid_replay') or {}).get('oracle') or {}).get('reason'),
               'historical_oracle_returncode': ((finding.get('hybrid_replay') or {}).get('oracle') or {}).get('returncode'),
               'historical_minimization_strategy': ((finding.get('hybrid_replay') or {}).get('minimization') or {}).get('strategy'),
               'historical_minimization_confidence': ((finding.get('hybrid_replay') or {}).get('minimization') or {}).get('confidence'),
               'raw_function_sequence': ';'.join(str(s.get('signature') or s.get('selector') or (s.get('calldata') or '')[:10]) for s in rsteps),
               'processed_function_sequence': ';'.join(str(s.get('signature') or s.get('selector') or (s.get('calldata') or '')[:10]) for s in psteps),
               'strict_replay_success': None,
               'explanation_count': 0, 'matched_request_ids': ''}
        event_rows.append(row)
    row_by_id = {r['validation_id']: r for r in event_rows}

    recovery = read(BASE / 'api_recovery/manifest.json')
    response_rows = [json.loads(line) for line in (BASE / 'api_recovery/responses.jsonl').read_text(encoding='utf-8').splitlines() if line.strip()]
    latest = {row['request_id']: row for row in response_rows}
    report_meta = {}
    for item in recovery['reports']:
        report = read(item['path'])
        report_meta[norm(pathlib.Path(report['finding_cases_pro_dir']).parent)] = report

    module_spec = importlib.util.spec_from_file_location('existing_recovery', BASE / 'api_recovery/recover_llm_reports.py')
    module = importlib.util.module_from_spec(module_spec)
    module_spec.loader.exec_module(module)
    os.chdir(REPO)
    inputs_by_path = {}
    context_by_run = {}
    context_rows = []
    snapshots = []
    for run_path, report in report_meta.items():
        selected_run = by_run[run_path]
        mode, inputs, errors = module.load_inputs(pathlib.Path(report['finding_cases_pro_dir']))
        context = module.build_contract_context(contract_name=report['contract']['name'],
            source_path=report['contract']['source_path'], abi=[])
        context_by_run[run_path] = context
        for label, finding in inputs:
            inputs_by_path[label] = finding
        static = context.get('analysis') or {}
        meta = static.get('meta') or {}
        static_source = meta.get('source_path')
        target_source = selected_run['source']
        source_status = ('same_source' if source_key(static_source) == source_key(target_source) else 'different_source') if static_source else 'source_unrecorded' if static else 'no_analysis'
        static_source_file = REPO / str(static_source or '')
        target_source_file = REPO / target_source
        if not static:
            content_status = 'no_analysis'
        elif not static_source or not static_source_file.is_file():
            content_status = 'source_file_unavailable'
        elif static_source_file.read_bytes() == target_source_file.read_bytes():
            content_status = 'byte_identical_source'
        elif static_source_file.read_text(encoding='utf-8-sig').replace('\r\n','\n') == target_source_file.read_text(encoding='utf-8-sig').replace('\r\n','\n'):
            content_status = 'newline_equivalent_source'
        else:
            content_status = 'different_source_content'
        same_contract = meta.get('contract_name') == report['contract']['name'] if static else None
        artifact = pathlib.Path(selected_run['run_dir']) / 'artifacts/l3_foundry/analysis.json'
        archived = read(artifact) if artifact.exists() else {}
        archived_meta = archived.get('meta') or {}
        archived_match = source_key(archived_meta.get('source_path')) == source_key(target_source) and archived_meta.get('contract_name') == selected_run['contract'] if archived else None
        context_rows.append({'source': target_source, 'contract': selected_run['contract'], 'run_dir': selected_run['run_dir'],
            'input_count': report['input_count'], 'context_source_status': source_status,
            'context_source_content_status': content_status,
            'context_contract_match': same_contract, 'analysis_contract': meta.get('contract_name'),
            'analysis_source': static_source, 'analysis_path': static.get('artifact_path'),
            'analysis_generated_at': meta.get('generated_at'),
            'run_specific_analysis_available': bool(archived), 'run_specific_analysis_matches': archived_match,
            'run_specific_analysis_path': str(artifact) if archived else '',
            'abi_available_in_replay_log': source_key(target_source) in abi_by_source,
            'report_status': report['status']})
        snapshots.append({'run_dir': selected_run['run_dir'], 'context': context})
    context_row_index = {norm(x['run_dir']): x for x in context_rows}

    explanation_rows = []
    joined = collections.defaultdict(list)
    schema_fields = ['root_cause','bug_pattern','vulnerable_function','vulnerable_state','trigger_sequence','violated_property','evidence_chain','why_sequence_triggers_bug','minimal_fix_principle','confidence','uncertainties']
    input_counts = collections.Counter()
    evidence_kind_counts = collections.Counter()
    for response in latest.values():
        label = response['path_label']
        original_input = inputs_by_path[label]
        pathpart, sep, event_id = label.partition('#')
        run_path = norm(pathlib.Path(pathpart).parent.parent)
        run = by_run[run_path]
        if sep:
            input_type = 'violation_event'
            matches = event_index.get((run_path, event_id), [])
        elif original_input.get('origin') in ('fuzzer_detector','foundry_invariant','static_source'):
            input_type = 'individual_finding'
            matches = finding_path_index.get(norm(pathpart), [])
            if not matches:
                eid = (original_input.get('violation_event') or {}).get('event_id')
                matches = event_index.get((run_path, eid), [])
        else:
            input_type = 'aggregate_report' if pathlib.Path(pathpart).name in ('hybrid_replay_report.json','semantic_invariant_report.json') else 'other_input'
            matches = []
        input_counts[input_type] += 1
        result = response.get('result') or {}
        usage = response.get('usage') or {}
        context_row = context_row_index[run_path]
        evidence_chain = result.get('evidence_chain') if isinstance(result.get('evidence_chain'), list) else []
        evidence_kind_counts.update(item.get('kind','missing') for item in evidence_chain if isinstance(item,dict))
        uncertainties = result.get('uncertainties')
        explanation_rows.append({'request_id': response['request_id'], 'source': run['source'], 'contract': run['contract'],
            'category': run['source'].split('/')[1], 'input_type': input_type, 'input_path': label,
            'input_schema': original_input.get('schema_version'), 'status': response['status'],
            'requested_model': response['requested_model'], 'served_model': response.get('served_model'),
            'attempts': response.get('attempts'),
            'matched_T_events': ';'.join(matches), 'matches_T_count': len(matches),
            'context_source_status': context_row['context_source_status'],
            'context_source_content_status': context_row['context_source_content_status'],
            'context_contract_match': context_row['context_contract_match'],
            'schema_all_keys_present': all(k in result for k in schema_fields),
            'empty_root_cause': not bool(result.get('root_cause')),
            'confidence': result.get('confidence'),
            'uncertainty_items': len(uncertainties) if isinstance(uncertainties,list) else None,
            'evidence_chain_items': len(evidence_chain),
            'prompt_tokens': usage.get('prompt_tokens'), 'completion_tokens': usage.get('completion_tokens'),
            'total_tokens': usage.get('total_tokens'), 'cached_prompt_tokens': usage.get('prompt_cache_hit_tokens'),
            'completed_at': response.get('completed_at')})
        for vid in matches:
            joined[vid].append(response['request_id'])
    for row in event_rows:
        row['explanation_count'] = len(joined.get(row['validation_id'], []))
        row['matched_request_ids'] = ';'.join(joined.get(row['validation_id'], []))

    category_rows = []
    for category in sorted({r['category'] for r in event_rows}):
        records = [r for r in event_rows if r['category'] == category]
        dynamic = [r for r in records if r['has_sequence']]
        category_rows.append({'category': category,
            'selected_contracts': sum(x['source'].split('/')[1] == category for x in selected),
            'T_events': len(records), 'dynamic': len(dynamic), 'source_pattern': len(records)-len(dynamic),
            'observed': sum(r['processed_good'] for r in dynamic),
            'not_observed': sum(r['processed_first'] == 'same_pc_type_not_observed' for r in dynamic),
            'timeout': sum(r['processed_first'] == 'timeout' for r in dynamic),
            'observed_fraction_dynamic': sum(r['processed_good'] for r in dynamic)/len(dynamic),
            'three_of_three': sum(r['processed_3of3'] for r in dynamic),
            'shortened': sum(r['shortened'] for r in dynamic),
            'explanations_matched_T': sum(bool(r['explanation_count']) for r in records)})

    minimization_rows = []
    for row in event_rows:
        if not row['shortened']:
            continue
        vid = row['validation_id']
        trials = [outcome_map[f'{vid}_delete_{i}'] for i in range(row['processed_steps']) if f'{vid}_delete_{i}' in outcome_map]
        minimization_rows.append({**{k:row[k] for k in ['validation_id','source','category','raw_status','raw_steps_metadata','processed_steps','exact_raw_steps','raw_input_bytes','processed_input_bytes','original_good','processed_good','original_3of3','processed_3of3']},
            'tx_reduction_fraction': (row['raw_steps_metadata']-row['processed_steps'])/row['raw_steps_metadata'],
            'deletion_trials': len(trials), 'deletions_observed': sum(good(t) for t in trials),
            'all_nonempty_deletions_tested': bool(trials) and len(trials) == row['processed_steps'],
            'deletion_wall_seconds_sum': sum(t['seconds'] for t in trials)})

    phases = {}
    for phase in sorted({r['phase'] for r in attempt_rows}):
        entries = [r for r in attempt_rows if r['phase']==phase]
        phases[phase] = {'attempts':len(entries), 'status_counts':counts(r['status'] for r in entries),
                         'wall_seconds':dist(r['wall_seconds'] for r in entries),
                         'worker_seconds':dist(r['worker_seconds'] for r in entries),
                         'attempts_with_evm_errors':sum(r['evm_error_steps']>0 for r in entries)}

    paired = [r for r in event_rows if r['has_sequence'] and r['original_first'] != 'not_run']
    paired_complete = [r for r in paired if r['original_first']!='timeout' and r['processed_first']!='timeout']
    short_exact = [r for r in minimization_rows if r['exact_raw_steps'] is not None]
    short_original_good = [r for r in short_exact if r['original_good']]
    short_both_good = [r for r in short_exact if r['original_good'] and r['processed_good']]

    def pair_counts(rows):
        return counts('both_observed' if r['original_good'] and r['processed_good'] else 'lost_after_processing' if r['original_good'] else 'gained_after_processing' if r['processed_good'] else 'neither_observed' for r in rows)

    lengths = {}
    dynamic = [r for r in event_rows if r['has_sequence']]
    for name in ['1','2-3','>=4']:
        records = [r for r in dynamic if length_bin(r['raw_steps_metadata']) == name]
        lengths[name] = {'events':len(records), 'shortened':sum(r['shortened'] for r in records),
                         'raw_transactions':sum(r['raw_steps_metadata'] for r in records),
                         'processed_transactions':sum(r['processed_steps'] for r in records),
                         'processed_observed':sum(r['processed_good'] for r in records)}

    sample = read(BASE/'explanations/sample.json')
    sample_rows = []
    for item in sample:
        row = row_by_id[item['validation_id']]
        sample_rows.append({'validation_id':item['validation_id'],'category':item['category'],'source':item['source'],
            'backend':item['backend'],'replay_status':item['replay_status'],
            'exact_recovered_explanations':row['explanation_count'],
            'independent_root_cause_present':bool(item.get('independent_root_cause')),
            'request_ids':row['matched_request_ids']})
    annotations = list(csv.DictReader((BASE/'explanations/annotation_template.csv').open(encoding='utf-8-sig')))
    label_fields = ['fact_correctness','evidence_support','root_cause_correctness','necessary_causal_steps_covered','material_error','reviewer_notes']

    detector_rows = []
    family_rows = []
    for key, destination in [('kind', detector_rows), ('invariant_category', family_rows)]:
        for label in sorted({r[key] for r in event_rows}):
            records = [r for r in event_rows if r[key] == label]
            seqs = [r for r in records if r['has_sequence']]
            destination.append({key:label, 'events':len(records), 'dynamic':len(seqs),
                'source_pattern':len(records)-len(seqs),
                'observed':sum(r['processed_good'] for r in seqs),
                'not_observed':sum(r['processed_first']=='same_pc_type_not_observed' for r in seqs),
                'timeout':sum(r['processed_first']=='timeout' for r in seqs),
                'observed_fraction':sum(r['processed_good'] for r in seqs)/len(seqs) if seqs else None})
    contract_rows = []
    for run in selected:
        records = [r for r in event_rows if r['source']==run['source']]
        seqs = [r for r in records if r['has_sequence']]
        contract_rows.append({'source':run['source'],'contract':run['contract'],'run_status':run['status'],
            'events':len(records),'dynamic':len(seqs),'observed':sum(r['processed_good'] for r in seqs),
            'observed_fraction':sum(r['processed_good'] for r in seqs)/len(seqs) if seqs else None})
    diagnostic_losses = [r for r in event_rows if r['original_good'] and not r['processed_good']]
    failed_events = [r for r in event_rows if r['processed_first'] in ('same_pc_type_not_observed','timeout')]
    completed_first = [r for r in attempt_rows if r['phase']=='processed_first' and r['status']!='timeout']
    historical_passed = [r for r in dynamic if r['historical_oracle_status']=='passed']
    matched_responses = [r for r in explanation_rows if r['matches_T_count']]
    full_inventory = read(REPO/'ccfa-review-reports/rq6-full-inventory/inventory.json')

    metrics = {
        'scope':{'selected_runs':len(selected),'events':len(events),'dynamic':len(dynamic),'source_pattern':len(events)-len(dynamic),
                 'selected_run_stages':counts(re.search(r'round_(\d+s)',x['run_dir']).group(1) for x in selected),
                 'selected_run_statuses':counts(x['status'] for x in selected),
                 'contracts_with_T_events':len({r['source'] for r in event_rows}),
                 'contracts_with_dynamic':len({r['source'] for r in dynamic}),
                 'unique_source_pc_type_dynamic':len({(r['source'], r['location_pc'], r['detector_type']) for r in dynamic}),
                 'contracts_with_processed_observation':len({r['source'] for r in dynamic if r['processed_good']})},
        'processed_status':counts(r['processed_first'] for r in event_rows),
        'processed_3of3':sum(r['processed_3of3'] for r in event_rows),
        'raw_artifact_status':counts(r['raw_status'] for r in dynamic),
        'original_status':counts(r['original_first'] for r in event_rows),
        'paired_raw_available':{'n':len(paired),'contingency':pair_counts(paired),'completed_both_n':len(paired_complete),'completed_both_contingency':pair_counts(paired_complete)},
        'original_oracle_status':counts(r['historical_oracle_status'] for r in dynamic),
        'original_oracle_reason':counts(r['historical_oracle_reason'] for r in dynamic),
        'historical_minimization_strategies':counts(r['historical_minimization_strategy'] for r in dynamic),
        'historical_passed_diagnostic_check':{'n':len(historical_passed),
            'processed_observed':sum(r['processed_good'] for r in historical_passed),
            'original_observed':sum(r['original_good'] for r in historical_passed),
            'returncodes':counts(r['historical_oracle_returncode'] for r in historical_passed)},
        'contract_observation_fractions':dist(r['observed_fraction'] for r in contract_rows),
        'detectors':detector_rows,
        'families':family_rows,
        'failure_diagnostics':{'events':len(failed_events),
            'kinds':counts(r['kind'] for r in failed_events),
            'completed_attempts_with_evm_errors':sum(r['evm_error_steps']>0 for r in completed_first),
            'observed_with_evm_errors':sum(r['evm_error_steps']>0 and r['diagnostic_valid'] for r in completed_first),
            'not_observed_with_evm_errors':sum(r['evm_error_steps']>0 and not r['diagnostic_valid'] for r in completed_first),
            'diagnostic_loss_ids':[r['validation_id'] for r in diagnostic_losses]},
        'invariant_family_counts':counts(r['invariant_category'] for r in event_rows),
        'detector_kind_counts':counts(r['kind'] for r in event_rows),
        'event_stages':counts(r['run_stage'] for r in event_rows),
        'trace_availability':{'dynamic_with_nonempty_trace_fields':sum(r['nonempty_trace_fields']>0 for r in dynamic),'dynamic_with_setup':sum(r['sequence_setup_steps']>0 for r in dynamic)},
        'sequence_lengths':{'original_metadata':dist(r['raw_steps_metadata'] for r in dynamic),'processed':dist(r['processed_steps'] for r in dynamic),'bins':lengths},
        'minimization':{'shortened':len(minimization_rows),'exact_raw':len(short_exact),
            'all_shortened_reduction':dist(r['tx_reduction_fraction'] for r in minimization_rows),
            'exact_raw_reduction':dist(r['tx_reduction_fraction'] for r in short_exact),
            'exact_raw_contingency':pair_counts(short_exact),
            'raw_observed':len(short_original_good),'both_observed':len(short_both_good),
            'both_observed_reduction':dist(r['tx_reduction_fraction'] for r in short_both_good),
            'both_observed_raw_transactions':sum(r['raw_steps_metadata'] for r in short_both_good),
            'both_observed_processed_transactions':sum(r['processed_steps'] for r in short_both_good),
            'exact_raw_calldata_paired':sum(r['raw_input_bytes'] is not None and r['processed_input_bytes'] is not None for r in short_exact),
            'exact_raw_calldata_original':sum(r['raw_input_bytes'] or 0 for r in short_exact),
            'exact_raw_calldata_processed':sum(r['processed_input_bytes'] or 0 for r in short_exact),
            'both_observed_calldata_original':sum(r['raw_input_bytes'] or 0 for r in short_both_good),
            'both_observed_calldata_processed':sum(r['processed_input_bytes'] or 0 for r in short_both_good),
            'deletion_records':sum(bool(r['deletion_trials']) for r in minimization_rows),
            'deletion_attempts':sum(r['deletion_trials'] for r in minimization_rows),
            'deletion_still_observed':sum(r['deletions_observed'] for r in minimization_rows),
            'all_deletions_lose_diagnostic':sum(r['deletion_trials']>0 and r['deletions_observed']==0 for r in minimization_rows),
            'single_tx_among_both_good':sum(r['processed_steps']==1 for r in short_both_good)},
        'validation_cost':{'phases':phases,'all_wall_seconds':dist(r['wall_seconds'] for r in attempt_rows)},
        'explanations':{'journal_rows':len(response_rows),'unique_requests':len(latest),'statuses':counts(r['status'] for r in explanation_rows),
            'input_types':dict(input_counts), 'requested_models':counts(r['requested_model'] for r in explanation_rows),
            'served_models':counts(r['served_model'] for r in explanation_rows),
            'matching_T_requests':sum(bool(r['matches_T_count']) for r in explanation_rows),
            'distinct_T_events_with_explanations':len(joined),
            'T_dynamic_matched':sum(r['has_sequence'] and bool(r['explanation_count']) for r in event_rows),
            'T_source_pattern_matched':sum(not r['has_sequence'] and bool(r['explanation_count']) for r in event_rows),
            'contexts_by_run':counts(r['context_source_status'] for r in context_rows),
            'contexts_by_request':counts(r['context_source_status'] for r in explanation_rows),
            'context_content_by_run':counts(r['context_source_content_status'] for r in context_rows),
            'context_content_by_request':counts(r['context_source_content_status'] for r in explanation_rows),
            'matched_T_context_content':counts(r['context_source_content_status'] for r in matched_responses),
            'matched_T_input_types':counts(r['input_type'] for r in matched_responses),
            'unmatched_input_types':counts(r['input_type'] for r in explanation_rows if not r['matches_T_count']),
            'matched_T_tokens':{k:dist(r[k] for r in matched_responses) for k in ['prompt_tokens','completion_tokens','total_tokens']},
            'matching_T_requests_with_source_path_mismatch':sum(r['matches_T_count']>0 and r['context_source_status']=='different_source' for r in explanation_rows),
            'schema_all_keys_present':sum(r['schema_all_keys_present'] for r in explanation_rows),
            'empty_root_cause':sum(r['empty_root_cause'] for r in explanation_rows),
            'confidence_counts':counts(r['confidence'] for r in explanation_rows),
            'with_uncertainties':sum(bool(r['uncertainty_items']) for r in explanation_rows),
            'uncertainty_items':dist(r['uncertainty_items'] for r in explanation_rows),
            'evidence_chain_kinds':dict(evidence_kind_counts),
            'tokens':{k:dist(r[k] for r in explanation_rows) for k in ['prompt_tokens','completion_tokens','total_tokens','cached_prompt_tokens']},
            'completed_timestamp_span_s':max(r['completed_at'] for r in explanation_rows)-min(r['completed_at'] for r in explanation_rows),
            'run_specific_matching_static_artifacts':sum(r['run_specific_analysis_matches'] is True for r in context_rows),
            'sources_with_abi_in_replay_logs':len(abi_by_source),
            'sample':{'n':len(sample_rows),'backends':counts(r['backend'] for r in sample_rows),
                'categories':counts(r['category'] for r in sample_rows),
                'sources':len({r['source'] for r in sample_rows}),
                'matched_to_recovery':sum(bool(r['exact_recovered_explanations']) for r in sample_rows),
                'replay_statuses':counts(r['replay_status'] for r in sample_rows),
                'invariant_families':counts(row_by_id[r['validation_id']]['invariant_category'] for r in sample_rows),
                'raw_length_bins':counts(length_bin(row_by_id[r['validation_id']]['raw_steps_metadata']) if row_by_id[r['validation_id']]['has_sequence'] else 'no_sequence' for r in sample_rows),
                'matched_context_content':counts(r['context_source_content_status'] for r in explanation_rows if any(vid in {s['validation_id'] for s in sample_rows} for vid in r['matched_T_events'].split(';'))),
                'independent_root_causes':sum(r['independent_root_cause_present'] for r in sample_rows),
                'annotation_slots':len(annotations),'slots_with_any_label':sum(any(r.get(k) for k in label_fields) for r in annotations)}},
        'categories':category_rows,
        'previous_full_inventory':{'campaign':full_inventory['campaign'],
            'search_seconds':full_inventory['protocol']['search_seconds'],
            'watchdog_seconds':full_inventory['protocol']['search_watchdog_seconds'],
            'replay':full_inventory['protocol']['replay'], 'minimization':full_inventory['protocol']['minimization'],
            'cohorts':full_inventory['cohorts']},
        'strict_metrics':{'same_security_consequence_rate':None,'valid_minimization_rate':None,'explanation_correctness':None,'root_cause_accuracy':None,'inter_rater_agreement':None}
    }
    write_json('metrics.json',metrics)
    write_json('reconstructed_contexts.json',snapshots)
    write_json('abis_from_existing_replay_logs.json',abi_by_source)
    write_csv('events.csv',event_rows)
    write_csv('attempts.csv',attempt_rows)
    write_csv('categories.csv',category_rows)
    write_csv('minimization.csv',minimization_rows)
    write_csv('explanations.csv',explanation_rows)
    write_csv('context_audit.csv',context_rows)
    write_csv('sample_mapping.csv',sample_rows)
    write_csv('detectors.csv',detector_rows)
    write_csv('families.csv',family_rows)
    write_csv('contracts.csv',contract_rows)
    write_csv('diagnostic_losses.csv',diagnostic_losses)
    write_csv('replay_failures.csv',failed_events)
    assert len(event_rows) == 880 and len(attempt_rows) == 2476
    assert len(joined) == 735 and all(len(v)==1 for v in joined.values())
    assert sum(r['has_sequence'] for r in event_rows) == 735
    print(json.dumps({'scope':metrics['scope'],'explanations':{k:v for k,v in metrics['explanations'].items() if k not in ['tokens','uncertainty_items','evidence_chain_kinds']}},ensure_ascii=False),flush=True)


if __name__ == '__main__':
    main()
