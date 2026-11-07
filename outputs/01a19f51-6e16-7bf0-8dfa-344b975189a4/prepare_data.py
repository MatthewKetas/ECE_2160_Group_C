import collections
import csv
import hashlib
import json
import math
from pathlib import Path
import re
import statistics

OUT = Path(__file__).resolve().parent
SOURCE = OUT.parents[1].parent/'Memory Homework'
ROOT = SOURCE/'Development/Metrics/MemoryAssessment/pi_'
MAIN = '20261103T063115Z'
ORDER = ['O0','O1','O2','O3','Ofast','Os','Oz','unroll','no_loop_vector','no_slp_vector',
         'no_inline','lto','gc_sections','no_stack_reuse','stripped','tune_a76','cpu_a76',
         'short_enums','shared','dlopen','fully_static','workspace','arena','static_storage',
         'path_buffers','packed_record','io_context','window50','window25','combined']
LABELS = {'O0':'-O0','O1':'-O1','O2':'-O2 baseline','O3':'-O3','Ofast':'-Ofast',
          'Os':'-Os','Oz':'-Oz','unroll':'Unroll loops','no_loop_vector':'No loop vectorization',
          'no_slp_vector':'No SLP vectorization','no_inline':'No inlining','lto':'LTO',
          'gc_sections':'Remove unused sections','no_stack_reuse':'No stack reuse','stripped':'Strip symbols',
          'tune_a76':'Tune Cortex-A76','cpu_a76':'Target Cortex-A76','short_enums':'Short enums',
          'shared':'Shared Critter library','dlopen':'Load prediction on demand','fully_static':'Fully static executable',
          'workspace':'Reusable heap workspace','arena':'Partitioned arena','static_storage':'Static ring and workspace',
          'path_buffers':'Fewer path buffers','packed_record':'Packed ring records','io_context':'Caller-owned I/O state',
          'window50':'50-sample history','window25':'25-sample history','combined':'Combined candidate'}
families = {v:'Compiler groups' for v in ORDER[:7]}
families.update({v:'Individual flags' for v in ORDER[7:15]})
families.update({v:'Hardware' for v in ['tune_a76','cpu_a76']})
families.update({v:'Linking and loading' for v in ['shared','dlopen','fully_static']})
families.update({v:'Storage and state' for v in ['workspace','arena','static_storage','path_buffers','io_context']})
families.update({v:'Data layout' for v in ['short_enums','packed_record']})
families.update({v:'Retained history' for v in ['window50','window25']})
families['combined']='Combined candidate'

def get_metrics(path):
    pairs = {'Maximum resident set size (kbytes)':'peak_rss_kib', 'User time (seconds)':'user_s',
             'System time (seconds)':'system_s','Major (requiring I/O) page faults':'major_faults',
             'Minor (reclaiming a frame) page faults':'minor_faults'}
    d={}
    for line in path.read_text().splitlines():
        for label,key in pairs.items():
            if line.strip().startswith(label+':'): d[key]=float(line.split(':',1)[1])
    return d

def value(text,field):
    match=re.search(r'^'+re.escape(field)+r':\s+(\d+)',text,re.M)
    return int(match[1]) if match else None

def stats(values):
    return [statistics.median(values),min(values),max(values)] if values else [None,None,None]

data=dict(runs=[],builds=[],phases=[],frames=[],sessions=[],checks=[],statistics=[],diagnostics=[],
          order=ORDER,labels=LABELS,families=families,main=MAIN,source=str(SOURCE))
for session in sorted(ROOT.iterdir()):
    if not session.is_dir():continue
    session_id=session.name
    role='Full campaign' if session_id==MAIN else 'Short Pi check'
    completion=json.loads((session/'completion.json').read_text())
    env=json.loads((session/'environment.json').read_text())
    workload=json.loads((session/'workloads.json').read_text())
    results=[]
    for p in sorted(session.glob('runs/*/result.json')):
        r=json.loads(p.read_text()); results.append(r)
        label=r['label']
        stage=('Screening' if label.startswith('screen_') else 'Combined screening' if label.startswith('combined_')
               else 'Paced confirmation' if r['paced'] else 'Resource limits' if label.startswith(('limit_','arena_capacity_'))
               else 'Allocation diagnostic' if 'allocation_probe' in r else 'Phase diagnostic' if r['diagnostic'] else 'Calibration / reference')
        o=r.get('output',{});pr=r.get('process',{});ap=r.get('allocation_probe',{})
        repetition=int(label.split('_')[1])+1 if label.startswith(('screen_','combined_','confirm_')) else None
        row=dict(session=session_id,role=role,stage=stage,id=label,variant=r['variant'],label=LABELS.get(r['variant'],r['variant']),
                 family=families.get(r['variant'],'Reference'),unit=r['unit'],repetition=repetition,status=r['status'],capacity=r['capacity'],rounds=r['rounds'],
                 peak_rss_kib=r.get('peak_rss_kib'),duration_s=pr.get('duration_s'),user_s=r.get('user_s'),system_s=r.get('system_s'),
                 major_faults=r.get('major_faults'),minor_faults=r.get('minor_faults'),exit_code=pr.get('returncode'),timeout=pr.get('timed_out'),rows=r['rows'],
                 limit_kind=next(iter(r['limits']),'Existing / none'),limit_bytes=next(iter(r['limits'].values()),None),
                 source=f'{session_id}/runs/{label}/result.json',**{k:o.get(k) for k in ['sample_bytes','record_bytes','memory_state_bytes','checksum','count','rejected','outliers','mean','median','stddev','first','last','prediction','trend','stable','hvac']},
                 **{k:ap.get(k) for k in ['allocation_calls','free_calls','requested_peak_bytes','requested_remaining_bytes']})
        if o.get('first') is not None:row['retained_span_s']=o['last']-o['first']
        data['runs'].append(row)
        raw=get_metrics(p.parent/'time.txt')
        mismatches=[k for k,v in raw.items() if r.get(k)!=v]
        data['checks'].append(dict(session=session_id,check='GNU time / result JSON',record=label,passed=not mismatches,detail=', '.join(mismatches) or 'RSS, CPU times, major/minor faults agree'))
        output_records=[]
        for line in (p.parent/'process.stdout').read_text(errors='replace').splitlines():
            if line.startswith('{'):
                try:output_records.append(json.loads(line))
                except ValueError:pass
        parsed=next((x for x in output_records if 'unit' in x),{})
        data['checks'].append(dict(session=session_id,check='Application stdout / result JSON',record=label,passed=parsed==o,detail='Exact output fields compared'))
        csvpath=p.parent/'Data/temperature_samples.csv'
        saved_rows=0
        if csvpath.exists():
            with csvpath.open('rb') as f:saved_rows=max(0,sum(chunk.count(b'\n') for chunk in iter(lambda:f.read(1024*1024),b''))-1)
        data['checks'].append(dict(session=session_id,check='Saved sample rows',record=label,passed=saved_rows==r['rows'],detail=f'{saved_rows} rows counted; {r["rows"]} recorded'))
        snap=p.parent/'process.snapshots.json'
        if snap.exists():
            for phase,files in json.loads(snap.read_text()).items():
                rollup=files.get('smaps_rollup','');status=files.get('status','')
                q=dict(session=session_id,role=role,id=label,variant=r['variant'],phase=phase,
                       source=f'{session_id}/runs/{label}/process.snapshots.json',time_rss_kib=r.get('peak_rss_kib'))
                for field,key in [('Rss','rss_kib'),('Pss','pss_kib'),('Private_Clean','private_clean_kib'),('Private_Dirty','private_dirty_kib'),('Shared_Clean','shared_clean_kib'),('Shared_Dirty','shared_dirty_kib')]:q[key]=value(rollup,field)
                for field,key in [('VmRSS','status_rss_kib'),('VmHWM','status_hwm_kib'),('VmStk','stack_mapping_kib'),('VmData','data_mapping_kib'),('VmSize','virtual_kib')]:q[key]=value(status,field)
                q['private_kib']=(q['private_clean_kib'] or 0)+(q['private_dirty_kib'] or 0)
                q['shared_kib']=(q['shared_clean_kib'] or 0)+(q['shared_dirty_kib'] or 0)
                data['phases'].append(q)
        if session_id==MAIN and ap:data['diagnostics'].append(row)
    data['sessions'].append(dict(id=session_id,role=role,completion=completion,environment=env,workload=workload,
                                runs=len(results),statuses=dict(collections.Counter(r['status'] for r in results)),
                                stages=dict(collections.Counter(r['stage'] for r in data['runs'] if r['session']==session_id))))
    for p in sorted(session.glob('builds/*/build_result.json')):
        b=json.loads(p.read_text());d=p.parent
        verification=[]
        for line in (d/'verify.stdout').read_text().splitlines():
            if line.startswith('{'):verification.append(json.loads(line))
        failures=verification[0].get('verify_failures') if verification else None
        frame_records=[]
        for su in sorted(d.glob('*.su')):
            for line in su.read_text().splitlines():
                parts=line.split('\t')
                if len(parts)>=3 and parts[1].isdigit():
                    f=dict(session=session_id,build=d.name,variant=b['variant']['name'],diagnostic=b['diagnostic'],
                           function=parts[0].split(':')[-1],bytes=int(parts[1]),kind=parts[2],source=f'{session_id}/builds/{d.name}/{su.name}')
                    data['frames'].append(f);frame_records.append(f)
        for unit in ['io','memory','compute','pipeline']:
            binary=d/unit
            text=(d/f'size_{unit}.stdout').read_text() if (d/f'size_{unit}.stdout').exists() else ''
            sections={name:int(m[1]) if (m:=re.search(r'^\.'+name+r'\s+(\d+)',text,re.M)) else None for name in ['text','rodata','data','bss']}
            libs=list(d.glob('*.so'))
            data['builds'].append(dict(session=session_id,role=role,build=d.name,variant=b['variant']['name'],label=LABELS.get(b['variant']['name'],b['variant']['name']),
                diagnostic=b['diagnostic'],valid=b['valid'],verify_failures=failures,capacity=b['capacity'],unit=unit,
                flags=' '.join(b['variant']['flags']),source_change=b['variant'].get('source',b['variant']['name']),
                file_bytes=binary.stat().st_size,library_bytes=sum(x.stat().st_size for x in libs),**{k+'_bytes':v for k,v in sections.items()},
                max_frame_bytes=max([x['bytes'] for x in frame_records],default=None),source=f'{session_id}/builds/{d.name}'))

primary=[r for r in data['runs'] if r['session']==MAIN and r['stage'] in ['Screening','Combined screening']]
for v in ORDER:
    for unit in ['io','memory','compute','pipeline']:
        rows=[r for r in primary if r['variant']==v and r['unit']==unit]
        good=[r for r in rows if r['status']=='ok']
        base=[r['peak_rss_kib'] for r in primary if r['variant']=='O2' and r['unit']==unit and r['status']=='ok']
        vals=[r['peak_rss_kib'] for r in good]
        med,lo,hi=stats(vals)
        classification='Validation failed / not measured' if v=='Ofast' else 'Incomplete'
        if len(vals)==3:
            classification='Reference' if v=='O2' else 'No resolved RSS change'
            if v!='O2' and max(vals)<min(base):classification='Lower reported RSS'
            if v!='O2' and min(vals)>max(base):classification='Higher reported RSS'
        data['statistics'].append(dict(variant=v,label=LABELS[v],family=families[v],unit=unit,n=len(good),median=med,min=lo,max=hi,
            classification=classification,delta=(med/statistics.median(base)-1) if med is not None else None,
            r1=next((r['peak_rss_kib'] for r in good if r['repetition']==1),None),
            r2=next((r['peak_rss_kib'] for r in good if r['repetition']==2),None),
            r3=next((r['peak_rss_kib'] for r in good if r['repetition']==3),None)))
bad=[x for x in data['checks'] if not x['passed']]
assert not bad, bad[:5]
assert len([r for r in primary if r['stage']=='Screening'])==336
data['validation_summary']=dict(checks=len(data['checks']),failures=len(bad),runs=len(data['runs']))
data['archive_sha256']=hashlib.sha256((SOURCE/'critter-memory-results.tar.gz').read_bytes()).hexdigest()
(OUT/'source_data.json').write_text(json.dumps(data,allow_nan=False))
print(json.dumps({'sessions':[(s['id'],s['runs'],s['stages']) for s in data['sessions']],
                  'checks':data['validation_summary'],'build_rows':len(data['builds']),'phase_rows':len(data['phases']),'frame_rows':len(data['frames'])},indent=2))
