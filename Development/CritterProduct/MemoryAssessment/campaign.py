#!/usr/bin/env python3
"""Bounded Critter memory experiment. Standard library only; Linux measurements."""
import argparse
import csv
import datetime as dt
import difflib
import hashlib
import fcntl
import json
import math
import os
from pathlib import Path
import platform
import random
import re
import resource
import shutil
import signal
import statistics
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
UNITS = {'io': 1, 'memory': 2, 'compute': 3, 'pipeline': 4}
FIELDS = ['checksum', 'count', 'rejected', 'outliers', 'mean', 'median', 'stddev',
          'first', 'last', 'prediction', 'trend', 'stable', 'hvac']


def variants():
    items = [dict(name=x[1:], flags=[x]) for x in
             ['-O0', '-O1', '-O2', '-O3', '-Ofast', '-Os', '-Oz']]
    for name, flags in [
        ('unroll', ['-funroll-loops']), ('no_loop_vector', ['-fno-tree-loop-vectorize']),
        ('no_slp_vector', ['-fno-tree-slp-vectorize']), ('no_inline', ['-fno-inline']),
        ('lto', ['-flto']), ('gc_sections', ['-ffunction-sections', '-fdata-sections', '-Wl,--gc-sections']),
        ('no_stack_reuse', ['-fstack-reuse=none']), ('stripped', ['-s']),
        ('tune_a76', ['-mtune=cortex-a76']), ('cpu_a76', ['-mcpu=cortex-a76']),
        ('short_enums', ['-fshort-enums'])]:
        items.append(dict(name=name, flags=['-O2']+flags))
    for name in ['shared', 'dlopen', 'fully_static', 'workspace', 'arena', 'static_storage',
                 'path_buffers', 'packed_record', 'io_context', 'window50', 'window25']:
        items.append(dict(name=name, flags=['-O2']))
    assert len(items) == 29
    return items


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix+'.tmp')
    tmp.write_text(json.dumps(value, indent=2, allow_nan=False)+'\n')
    tmp.replace(path)


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise ValueError('source changed; expected exactly one occurrence: '+old[:100])
    return text.replace(old, new, 1)


def transform(tree, kind, probe=False):
    """Change only copied source, and fail rather than silently patch a new version."""
    pilot = tree/'Development/CritterProduct/Pilot'
    mh, mc, io = pilot/'Memory/critter_memory.h', pilot/'Memory/critter_memory.c', pilot/'IO/critter_io.c'
    h, m, s = mh.read_text(), mc.read_text(), io.read_text()
    # Separate immutable acquisition fixture from runtime output without bypassing path construction.
    s = replace_once(s, 'const char *path = getenv("CRITTER_DATA_FILE");',
                     'const char *path = getenv("ASSESS_INPUT_FILE");')
    if kind in ('workspace', 'arena', 'static_storage'):
        h = replace_once(h, '    double last_timestamp_s;', '    double last_timestamp_s;\n    double *workspace;')
        m = replace_once(m, '(double *)malloc(sizeof(double) * window_size)', 'memory->workspace')
        m = replace_once(m, '(double *)malloc(sizeof(double) * count)', 'memory->workspace')
        m = m.replace('free(temperatures);', '/* Workspace remains owned by the memory unit. */')
        allocation = '    memory->buffer = (critter_sample_t *)calloc(capacity, sizeof(critter_sample_t));'
        if kind == 'workspace':
            m = replace_once(m, allocation, allocation+'''
    if (!memory->buffer) return -1;
    memory->workspace = calloc(capacity, sizeof(double));
    if (!memory->workspace) { free(memory->buffer); memory->buffer = NULL; return -1; }''')
            m = replace_once(m, '    free(memory->buffer);',
                             '    free(memory->workspace);\n    memory->workspace = NULL;\n    free(memory->buffer);')
        elif kind == 'arena':
            m = replace_once(m, allocation, '''    if (capacity > (size_t)-1 / (sizeof(critter_sample_t) + sizeof(double))) return -1;
    const char *budget = getenv("ASSESS_ARENA_BYTES");
    if (budget && strtoull(budget, NULL, 10) < capacity * (sizeof(critter_sample_t) + sizeof(double))) return -1;
    memory->buffer = calloc(capacity, sizeof(critter_sample_t) + sizeof(double));
    if (memory->buffer) memory->workspace = (double *)(memory->buffer + capacity);''')
        else:
            m = m.replace('#include <string.h>', '''#include <string.h>
static critter_sample_t assessment_ring[ASSESS_CAPACITY];
static double assessment_scratch[ASSESS_CAPACITY];
static int assessment_busy;''')
            m = replace_once(m, allocation, '''    if (capacity > ASSESS_CAPACITY || assessment_busy) return -1;
    assessment_busy = 1;
    memset(assessment_ring, 0, sizeof(assessment_ring));
    memory->buffer = assessment_ring;
    memory->workspace = assessment_scratch;''')
            m = replace_once(m, '    free(memory->buffer);', '    assessment_busy = 0;')
    if kind == 'packed_record':
        record = '''typedef struct __attribute__((packed)) {
    double timestamp_s, temperature_c, humidity_percent, pressure_hpa;
    critter_temperature_source_t source;
    bool has_humidity, has_pressure;
} assessment_record_t;

'''
        h = replace_once(h, 'typedef struct\n{', record+'typedef struct\n{')
        h = h.replace('critter_sample_t *buffer;', 'assessment_record_t *buffer;')
        m = replace_once(m, '    memory->buffer[index] = *sample;', '''    memory->buffer[index] = (assessment_record_t){sample->timestamp_s, sample->temperature_c,
        sample->humidity_percent, sample->pressure_hpa, sample->source,
        sample->has_humidity, sample->has_pressure};''')
        m = replace_once(m, '(critter_sample_t *)calloc(capacity, sizeof(critter_sample_t))',
                         'calloc(capacity, sizeof(*memory->buffer))')
    if kind == 'path_buffers':
        begin = s.index('static int critter_resolve_executable_directory(')
        end = s.index('int critter_io_get_temperature_from_source(', begin)
        s = s[:begin]+'''static int critter_resolve_executable_directory(char *buffer, size_t size)
{
    if (!buffer || size < 2) return -1;
    ssize_t n = readlink("/proc/self/exe", buffer, size-1);
    if (n < 0 || (size_t)n >= size-1) return -1;
    buffer[n] = '\\0';
    char *slash = strrchr(buffer, '/');
    if (!slash) return -1;
    *slash = '\\0';
    return 0;
}
static int assessment_append(char *buffer, size_t size, const char *suffix)
{
    size_t n = strlen(buffer);
    if (n >= size) return -1;
    int written = snprintf(buffer+n, size-n, "%s", suffix);
    return written < 0 || (size_t)written >= size-n ? -1 : 0;
}
static int critter_resolve_runtime_data_path(char *buffer, size_t size)
{
    if (critter_resolve_executable_directory(buffer, size)) return -1;
    return assessment_append(buffer, size, "/Data/temperature_samples.csv");
}
static int critter_ensure_runtime_data_directory(void)
{
    char dir[PATH_MAX];
    struct stat info;
    if (critter_resolve_executable_directory(dir, sizeof(dir)) ||
        assessment_append(dir, sizeof(dir), "/Data")) return -1;
    if (stat(dir, &info)) return mkdir(dir, 0777) && errno != EEXIST ? -1 : 0;
    return S_ISDIR(info.st_mode) ? 0 : -1;
}

'''+s[end:]
    if kind == 'io_context':
        s = s.replace('#include <errno.h>', '#include <errno.h>\n#include "support.h"')
        a, b = s.index('    static sense_hat_environment_t sensor = {0};'), s.index('static int critter_read_sense_hat_temperature(')
        block = s[a:b].replace('    static sense_hat_environment_t sensor = {0};\n', '').replace('    static bool initialized = false;\n', '')
        block = re.sub(r'\bsensor\b', 'assessment_io_state->sensor', block)
        block = re.sub(r'\binitialized\b', 'assessment_io_state->sensor_ready', block)
        s = s[:a]+block+s[b:]
        a, b = s.index('    static bool initialized = false;'), s.index('static int critter_read_cpu_temperature(')
        block = s[a:b].replace('    static bool initialized = false;\n', '').replace('    static double last_value = 20.0;\n', '')
        block = re.sub(r'\binitialized\b', 'assessment_io_state->data_ready', block)
        block = re.sub(r'\blast_value\b', 'assessment_io_state->last_value', block)
        s = s[:a]+block+s[b:]
    if probe:
        m = '#include "support.h"\n'+m
        for name in ['malloc', 'calloc', 'free']:
            m = re.sub(r'\b'+name+r'\s*\(', 'assessment_'+name+'(', m)
    mh.write_text(h); mc.write_text(m); io.write_text(s)


def parse_output(path):
    rows = []
    for line in Path(path).read_text(errors='replace').splitlines():
        if line.startswith('{'):
            try: rows.append(json.loads(line))
            except ValueError: pass
    return rows


def equivalent(a, b):
    for key in FIELDS:
        x, y = a.get(key), b.get(key)
        if not isinstance(x, (int, float)) or not isinstance(y, (int, float)):
            return False
        if not math.isfinite(x) or not math.isfinite(y) or not math.isclose(x, y, rel_tol=1e-9, abs_tol=1e-7):
            return False
    return True


def time_metrics(path):
    values = {}
    if not Path(path).exists(): return values
    for line in Path(path).read_text(errors='replace').splitlines():
        for label, key, cast in [
            ('Maximum resident set size (kbytes)', 'peak_rss_kib', int),
            ('User time (seconds)', 'user_s', float), ('System time (seconds)', 'system_s', float),
            ('Major (requiring I/O) page faults', 'major_faults', int),
            ('Minor (reclaiming a frame) page faults', 'minor_faults', int)]:
            if line.strip().startswith(label+':'):
                values[key] = cast(line.split(':', 1)[1].strip())
    return values


def snapshot(pid):
    result = {}
    for filename in ['status', 'smaps_rollup', 'smaps', 'maps', 'limits']:
        try: result[filename] = Path(f'/proc/{pid}/{filename}').read_text()
        except (OSError, ProcessLookupError): pass
    return result


class BudgetExpired(Exception): pass


class Campaign:
    def __init__(self, out, minutes=120, mac=False, resume=False):
        self.out = Path(out).resolve()
        self.out.mkdir(parents=True, exist_ok=resume)
        self.lock = (self.out/'campaign.lock').open('a')
        try:
            fcntl.flock(self.lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except OSError:
            self.lock.close()
            raise
        self.resume = resume
        self.started = time.monotonic()
        self.deadline = self.started+minutes*60
        self.work_deadline = self.deadline-min(600, minutes*60/5)
        self.mac = mac
        self.cc = 'clang' if mac else 'gcc'
        self.events = [json.loads(line) for line in (self.out/'events.jsonl').read_text().splitlines()] if resume and (self.out/'events.jsonl').exists() else []
        self.builds = {}
        self.expected = {}
        self.rounds = {unit: 1 for unit in UNITS}
        self.active = None
        self.seed = 2160

    def event(self, **data):
        data['elapsed_s'] = round(time.monotonic()-self.started, 3)
        self.events.append(data)
        with (self.out/'events.jsonl').open('a') as f:
            f.write(json.dumps(data, allow_nan=False)+'\n'); f.flush(); os.fsync(f.fileno())
        print(data.get('stage', ''), data.get('variant', ''), data.get('unit', ''), data.get('status', ''), flush=True)

    def command(self, cmd, directory, log, timeout=30, env=None, phase_path=None):
        remaining = self.work_deadline-time.monotonic()
        if remaining <= 0: raise BudgetExpired()
        limit = min(timeout, remaining)
        log = Path(log)
        log.parent.mkdir(parents=True, exist_ok=True)
        write_json(str(log)+'.command.json', {'argv': list(map(str, cmd)), 'cwd': str(directory), 'timeout_s': limit})
        start = time.monotonic()
        snapshots, last = {}, None
        with log.with_suffix('.stdout').open('w') as stdout, log.with_suffix('.stderr').open('w') as stderr:
            p = subprocess.Popen(list(map(str, cmd)), cwd=directory, env=env, stdout=stdout, stderr=stderr, start_new_session=True)
            self.active = p
            timed_out = False
            try:
                while p.poll() is None:
                    if time.monotonic()-start >= limit:
                        timed_out = True
                        try: os.killpg(p.pid, signal.SIGKILL)
                        except ProcessLookupError: pass
                        break
                    if phase_path and not self.mac:
                        try:
                            marker = Path(phase_path).read_text().split()
                            if len(marker) == 2 and marker[1] != last:
                                last = marker[1]; snapshots[last] = snapshot(int(marker[0]))
                        except (OSError, ValueError): pass
                    time.sleep(0.02)
                p.wait()
            finally:
                if p.poll() is None:
                    try: os.killpg(p.pid, signal.SIGKILL)
                    except ProcessLookupError: pass
                    p.wait()
                self.active = None
        if snapshots: write_json(str(log)+'.snapshots.json', snapshots)
        return dict(returncode=p.returncode, timed_out=timed_out, duration_s=time.monotonic()-start,
                    stdout=str(log.with_suffix('.stdout')), stderr=str(log.with_suffix('.stderr')))

    def build(self, variant, probe=False):
        name = variant['name']+('_probe' if probe else '')
        if name in self.builds: return self.builds[name]
        dest = self.out/'builds'/name
        if self.resume and (dest/'build_result.json').exists():
            saved = json.loads((dest/'build_result.json').read_text())
            if saved['variant'] != variant:
                raise ValueError('saved build configuration does not match')
            saved['path'] = dest
            self.builds[name] = saved
            return saved
        tree = dest/'source'
        for rel in ['Development/CritterProduct/Pilot', 'Utils/SenseHat']:
            for source in (ROOT/rel).rglob('*'):
                if source.suffix in ('.c', '.h'):
                    target = tree/source.relative_to(ROOT)
                    target.parent.mkdir(parents=True, exist_ok=True); shutil.copy2(source, target)
        for filename in ['harness.c', 'support.h', 'probe.c', 'mac_sensor_stub.c']:
            shutil.copy2(HERE/filename, dest/filename)
        kind = variant.get('source', variant['name'])
        transform(tree, kind, probe)
        pilot = tree/'Development/CritterProduct/Pilot'
        if self.mac:
            io_source = pilot/'IO/critter_io.c'
            source = io_source.read_text().replace('readlink(', 'assessment_mac_executable(')
            source = source.replace('#include <errno.h>', '''#include <errno.h>
#include <mach-o/dyld.h>
static ssize_t assessment_mac_executable(const char *unused, char *buf, size_t size)
{
    (void)unused;
    uint32_t n = (uint32_t)size;
    return _NSGetExecutablePath(buf, &n) == 0 ? (ssize_t)strlen(buf) : -1;
}''')
            # Definitions follow headers so size_t, ssize_t, strlen and uint32_t are declared.
            helper_start = source.index('static ssize_t assessment_mac_executable(')
            helper_end = source.index('\n}', helper_start)+2
            helper = source[helper_start:helper_end]
            source = source[:helper_start]+source[helper_end:]
            marker = '#include "../../../../Utils/SenseHat/sense_hat_environment.h"'
            source = source.replace(marker, marker+'\n'+helper)
            io_source.write_text(source)
        cap = variant.get('capacity', 50 if kind == 'window50' else 25 if kind == 'window25' else 100)
        flags = variant['flags'][:]
        if self.mac and variant['name'] in ['fully_static', 'gc_sections', 'no_stack_reuse', 'tune_a76', 'cpu_a76']:
            raise ValueError('Linux/GCC-specific configuration; not a Mac measurement')
        include = ['-I'+str(pilot), '-I'+str(tree/'Utils/SenseHat'), '-I'+str(dest)]
        common = ['-std=c11', '-Wall', '-Wextra', '-Werror=implicit-function-declaration', '-g', '-fstack-usage', '-DASSESS_CAPACITY='+str(cap)]
        if probe: common += ['-DASSESS_PROBE']
        if kind == 'io_context': common += ['-DASSESS_CONTEXT']
        dynamic = variant['name'] == 'dlopen'
        shared = variant['name'] == 'shared'
        if dynamic: common += ['-DASSESS_DLOPEN']
        if shared or dynamic: common += ['-fPIC']
        source_files = [pilot/'IO/critter_io.c', pilot/'Memory/critter_memory.c', pilot/'Computation/critter_computation.c',
                        dest/'mac_sensor_stub.c' if self.mac else tree/'Utils/SenseHat/sense_hat_environment.c']
        if probe: source_files.append(dest/'probe.c')
        diffs = []
        for source in pilot.rglob('*'):
            if source.suffix in ('.c', '.h'):
                original = ROOT/source.relative_to(tree)
                diffs.extend(difflib.unified_diff(original.read_text().splitlines(True), source.read_text().splitlines(True),
                                                fromfile=str(original.relative_to(ROOT)), tofile=str(source.relative_to(tree))))
        (dest/'source.patch').write_text(''.join(diffs))
        write_json(dest/'configuration.json', dict(variant, capacity=cap, diagnostic=probe, development_only=self.mac))
        objects = []
        for i, source in enumerate(source_files):
            obj = dest/f'core{i}.o'
            result = self.command([self.cc]+common+include+flags+['-c', source, '-o', obj], dest, dest/f'compile{i}', 45)
            if result['returncode']: raise ValueError('compilation failed: '+result['stderr'])
            objects.append(obj)
        prediction_obj = objects[2]
        if dynamic:
            result = self.command([self.cc, '-shared', prediction_obj, '-lm', '-o', dest/'libprediction.so']+flags,
                                  dest, dest/'link_prediction', 30)
            if result['returncode']: raise ValueError('prediction shared-library link failed')
            objects.remove(prediction_obj)
        archive = dest/'libcritter.a'
        if shared:
            library = dest/'libcritter.so'
            result = self.command([self.cc, '-shared']+objects+['-lm', '-o', library]+flags, dest, dest/'shared', 30)
            links = [library, '-Wl,-rpath,'+str(dest)]
        else:
            result = self.command(['ar', 'rcs', archive]+objects, dest, dest/'archive')
            links = [archive]
        if result['returncode']: raise ValueError('library construction failed')
        if variant['name'] == 'fully_static': links += ['-static']
        for unit, number in UNITS.items():
            result = self.command([self.cc]+common+include+flags+['-DASSESS_UNIT='+str(number), dest/'harness.c']+links+
                                  ['-lm']+([] if self.mac else ['-ldl'])+['-o', dest/unit], dest, dest/('link_'+unit), 45)
            if result['returncode']: raise ValueError('executable link failed: '+result['stderr'])
        env = self.environment(dest)
        result = self.command([dest/'pipeline', '--verify'], dest, dest/'verify', 10, env)
        ver = parse_output(result['stdout'])
        valid = result['returncode'] == 0 and bool(ver) and ver[0].get('verify_failures') == 0
        build = dict(path=dest, capacity=cap, variant=variant, valid=valid, diagnostic=probe)
        self.builds[name] = build
        if not self.mac:
            for tool, args in [('size', ['-A']), ('readelf', ['-W', '-l', '-S', '-d', '-s']), ('nm', ['-S', '--size-sort'])]:
                for unit in UNITS:
                    self.command([tool]+args+[dest/unit], dest, dest/(tool+'_'+unit), 10)
            for lib in dest.glob('*.so'):
                self.command(['size', '-A', lib], dest, dest/('size_'+lib.name), 10)
        self.event(stage='build', variant=name, status='valid' if valid else 'behavior_invalid')
        write_json(dest/'build_result.json', dict(build, path=str(dest)))
        return build

    def environment(self, dest):
        env = os.environ.copy()
        for key in list(env):
            if key.startswith(('ASSESS_', 'CRITTER_', 'LD_', 'MALLOC_', 'GLIBC_TUNABLES', 'DYLD_')):
                env.pop(key, None)
        env['LC_ALL'] = 'C'
        env['ASSESS_INPUT_FILE'] = str(self.out/'input.csv')
        return env

    def run_one(self, build, unit, label, rounds=None, diagnostic=False, limits=None, paced=False, timeout=8):
        saved_result = self.out/'runs'/label/'result.json'
        if self.resume and saved_result.exists(): return json.loads(saved_result.read_text())
        dest = build['path']
        data = dest/'Data'
        if data.exists(): shutil.rmtree(data)
        data.mkdir()
        env = self.environment(dest)
        run = self.out/'runs'/label
        if run.exists():
            # Preserve an interrupted attempt before retrying its slot.
            run.rename(run.with_name(run.name+'_interrupted_'+str(time.time_ns())))
        run.mkdir(parents=True, exist_ok=False)
        if diagnostic:
            env['ASSESS_PHASE_FILE'] = str(run/'phase')
        if limits:
            for key, value in limits.items(): env[key] = str(value)
        if paced: env['ASSESS_PACE_NS'] = '100000000'
        n = rounds or self.rounds[unit]
        command = [dest/unit, str(n)]
        if not self.mac: command = ['/usr/bin/time', '-v', '-o', run/'time.txt']+command
        result = self.command(command, dest, run/'process', timeout, env, env.get('ASSESS_PHASE_FILE'))
        outputs = parse_output(result['stdout'])
        output = next((x for x in outputs if 'unit' in x), {})
        expected_rows = n*600 if unit in ('io', 'pipeline') else 0
        actual_rows = 0
        if (data/'temperature_samples.csv').exists():
            with (data/'temperature_samples.csv').open() as f: actual_rows = max(0, sum(1 for _ in f)-1)
        status = 'ok' if result['returncode'] == 0 and output and expected_rows == actual_rows else 'failed'
        if status == 'ok':
            valid_shape = (output.get('unit') == UNITS[unit] and output.get('rounds') == n and
                           output.get('capacity') == build['capacity'] and equivalent(output, output))
            if unit in ('memory', 'pipeline'):
                valid_shape = valid_shape and output['outliers'] == n*600//97 and output['rejected'] == 0 and output['count'] == build['capacity']
            if not valid_shape: status = 'behavior_invalid'
        key = (build['capacity'], unit, n)
        if status == 'ok' and key in self.expected and not equivalent(output, self.expected[key]): status = 'behavior_invalid'
        record = dict(stage='run', variant=build['variant']['name'], unit=unit, label=label, rounds=n,
                      capacity=build['capacity'], status=status, diagnostic=diagnostic, paced=paced,
                      limits=limits or {}, output=output, process=result, rows=actual_rows, **time_metrics(run/'time.txt'))
        if len(outputs)>1: record['allocation_probe'] = outputs[-1]
        if data.exists(): shutil.move(str(data), str(run/'Data'))
        write_json(run/'result.json', record)
        self.event(**{k:v for k,v in record.items() if k not in ('process', 'output')})
        return record

    def metadata(self):
        self.command([self.cc, '--version'], self.out, self.out/'compiler')
        self.command([self.cc, '-dumpmachine'], self.out, self.out/'target')
        for flag in ['-O0', '-O2', '-O3', '-Os', '-Oz', '-Ofast']:
            if not self.mac: self.command([self.cc, flag, '-Q', '--help=optimizers'], self.out, self.out/('effective_'+flag[1:]))
        source_hashes = {}
        for directory in [ROOT/'Development/CritterProduct/Pilot', ROOT/'Utils/SenseHat', HERE]:
            for path in directory.rglob('*'):
                if path.suffix in ('.c', '.h', '.py', '.md') and '__pycache__' not in str(path):
                    source_hashes[str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
        env_path = self.out/'environment.json'
        if self.resume:
            old = json.loads(env_path.read_text())
            if old['source_hashes'] != source_hashes or old['machine'] != platform.machine() or old['development_only'] != self.mac:
                raise RuntimeError('resume requires unchanged source and the same target; start a new campaign')
        else:
            write_json(env_path, dict(platform=platform.platform(), machine=platform.machine(),
            page_bytes=os.sysconf('SC_PAGE_SIZE'), development_only=self.mac, seed=self.seed,
            utc=dt.datetime.now(dt.timezone.utc).isoformat(), source_hashes=source_hashes,
            limits={str(x):resource.getrlimit(x) for x in [resource.RLIMIT_STACK, resource.RLIMIT_DATA, resource.RLIMIT_AS]}))
        if not self.mac:
            for file in ['meminfo', 'cpuinfo', 'cmdline', 'swaps']:
                shutil.copyfile('/proc/'+file, self.out/('proc_'+file))
            self.command(['git', 'rev-parse', 'HEAD'], ROOT, self.out/'git_head')
            self.command(['git', 'diff', '--', 'Development/CritterProduct/Pilot', 'Utils/SenseHat', str(HERE)], ROOT, self.out/'git_diff')
            if shutil.which('vcgencmd'): self.command(['vcgencmd', 'get_throttled'], self.out, self.out/'throttled_before')

    def execute(self, quick=False):
        minimum_free = (512 if quick else 2048)*1024*1024
        if shutil.disk_usage(self.out).free < minimum_free:
            raise RuntimeError(f'need at least {minimum_free//(1024*1024)} MiB free for raw results')
        (self.out/'input.csv').write_text('timestamp_s,temperature_c\n1000,22.5\n')
        self.metadata()
        reference = self.build(dict(name='O0', flags=['-O0']))
        if not reference['valid']: raise RuntimeError('unoptimized correctness reference failed')
        for unit in UNITS:
            trial = self.run_one(reference, unit, 'calibrate_'+unit, rounds=1)
            if trial['status'] != 'ok': raise RuntimeError('reference workload failed')
            self.expected[(100, unit, 1)] = trial['output']
            # Fixed work per unit across every variant, calibrated once on unoptimized code.
            self.rounds[unit] = 1 if quick else max(1, min(100 if unit in ('io','pipeline') else 100000,
                int(1.5/max(trial['process']['duration_s'], 0.02))))
            result = self.run_one(reference, unit, 'oracle_100_'+unit)
            if not quick:
                for attempt in range(2):
                    elapsed = result['process']['duration_s']
                    if result['status'] != 'ok' or elapsed >= 0.7: break
                    maximum = 100 if unit in ('io','pipeline') else 100000
                    self.rounds[unit] = min(maximum, max(self.rounds[unit]+1, int(self.rounds[unit]*1.5/max(elapsed,0.02))))
                    result = self.run_one(reference, unit, f'calibration_refine_{unit}_{attempt}')
            if result['status'] != 'ok': raise RuntimeError('calibrated reference failed')
            self.expected[(100, unit, self.rounds[unit])] = result['output']
        write_json(self.out/'workloads.json', self.rounds)
        selected = variants()
        if quick and self.mac:
            selected = [v for v in selected if v['name'] not in ('tune_a76','cpu_a76','fully_static','gc_sections','no_stack_reuse')]
        for cap in [50, 25]:
            ref = self.build(dict(name=f'oracle{cap}', flags=['-O0'], capacity=cap))
            for unit in UNITS:
                r = self.run_one(ref, unit, f'oracle_{cap}_{unit}')
                if r['status'] != 'ok': raise RuntimeError('capacity reference failed')
                self.expected[(cap, unit, self.rounds[unit])] = r['output']
        good = {}
        for variant in selected:
            try:
                b = self.build(variant)
                if b['valid']: good[variant['name']] = b
            except ValueError as e:
                self.event(stage='build', variant=variant['name'], status='unsupported_or_build_failed', reason=str(e))
        repetitions = 1 if quick else 3
        rng = random.Random(self.seed)
        for rep in range(repetitions):
            jobs = [(name, unit) for name in good for unit in UNITS]
            rng.shuffle(jobs)
            for name, unit in jobs:
                self.run_one(good[name], unit, f'screen_{rep}_{name}_{unit}')
        if quick:
            for name in good:
                self.run_one(good[name], 'pipeline', f'check_phase_{name}', diagnostic=True)
            return
        # Diagnostic rebuilds keep allocation counters out of primary RSS measurements.
        for name in good:
            if time.monotonic() > self.work_deadline-600: break
            try:
                probe = self.build(good[name]['variant'], probe=True)
                if probe['valid']: self.run_one(probe, 'pipeline', 'diagnostic_'+name, diagnostic=True)
            except ValueError as e:
                self.event(stage='diagnostic', variant=name, status='failed', reason=str(e))
        self.limit_sweep(good)
        self.confirm(good)

    def limit_sweep(self, good):
        for name in ['O2', 'path_buffers', 'arena']:
            if name not in good: continue
            for kind, levels in [('ASSESS_STACK_BYTES', [None, 1048576, 524288, 262144, 131072, 65536]),
                                 ('ASSESS_DATA_BYTES', [4194304, 1048576, 524288, 262144, 131072, 65536])]:
                for level in levels:
                    self.run_one(good[name], 'pipeline', f'limit_{name}_{kind}_{level}', rounds=1,
                                 limits={kind:level} if level else {}, timeout=8)
        if 'arena' in good:
            baseline = self.expected[(100, 'pipeline', 1)]
            # sizeof is measured on the target, including ABI padding.
            required = baseline['capacity'] * (baseline['record_bytes'] + 8)
            for budget in [required, required-1, 0]:
                self.run_one(good['arena'], 'pipeline', f'arena_capacity_{budget}', rounds=1,
                             limits={'ASSESS_ARENA_BYTES':budget})
        # These are post-loader runtime data limits, not a pure heap cap or a certification.

    def confirm(self, good):
        records = collect_results(self.out)
        candidates = []
        for name in good:
            if name in ('Ofast', 'window25', 'window50'): continue
            runs = [r for r in records if r['variant']==name and r['unit']=='pipeline' and
                    r['label'].startswith('screen_') and r['status']=='ok' and r.get('peak_rss_kib',0)>0]
            if len(runs) == 3:
                candidates.append((statistics.median(r['peak_rss_kib'] for r in runs),name))
        ranked = [name for _,name in sorted(candidates) if name != 'O2'][:2]
        # Combine one compiler group, independent flags, and one storage change; preserve history.
        group_scores = [(score,name) for score,name in candidates if name in ('O0','O1','O2','O3','Os','Oz')]
        group = min(group_scores)[1] if group_scores else 'O2'
        source = next((name for name in ranked if name in ('workspace','arena','path_buffers','packed_record')), 'arena')
        combined = dict(name='combined', source=source, flags=['-'+group, '-flto', '-ffunction-sections', '-fdata-sections', '-Wl,--gc-sections'])
        try:
            b = self.build(combined)
            if b['valid']:
                good['combined'] = b
                for rep in range(3):
                    for unit in UNITS: self.run_one(b, unit, f'combined_{rep}_{unit}')
        except ValueError as e:
            self.event(stage='combined', variant='combined', status='failed', reason=str(e))
        for name in dict.fromkeys(['O2']+ranked+(['combined'] if 'combined' in good else [])):
            for rep in range(2):
                self.run_one(good[name], 'pipeline', f'confirm_{rep}_{name}', rounds=1, paced=True, timeout=70)
        if shutil.which('vcgencmd'): self.command(['vcgencmd', 'get_throttled'], self.out, self.out/'throttled_after')


def collect_results(out):
    return [json.loads(p.read_text()) for p in sorted(Path(out).glob('runs/*/result.json')) if '_interrupted_' not in p.parent.name]


def analyze(out):
    out = Path(out)
    records = collect_results(out)
    columns = ['label','variant','unit','capacity','rounds','status','diagnostic','paced','peak_rss_kib',
               'user_s','system_s','major_faults','minor_faults']
    columns += ['sample_bytes','record_bytes','memory_state_bytes']+FIELDS+['allocation_calls','requested_peak_bytes','requested_remaining_bytes']
    with (out/'runs.csv').open('w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=columns, extrasaction='ignore'); writer.writeheader()
        for r in records:
            output = {k:v for k,v in r.get('output',{}).items() if k!='unit'}
            writer.writerow(dict(r, **output, **r.get('allocation_probe',{})))
    lines = ['# Critter memory experiment', '',
             'Development-only Mac output; not Pi evidence.' if (out/'environment.json').exists() and json.loads((out/'environment.json').read_text())['development_only'] else 'Raspberry Pi Linux measurements.', '',
             'Primary comparisons use matched work and capacity, with O2 as reference. Ranges overlap => no resolved RSS change, not proof of equality.',
             'Allocation diagnostics, paced confirmation, and resource-limit trials are separate from screening.', '',
             '| Variant | Unit | Successful/recorded | Median peak RSS (KiB) | Range | Classification |',
             '|---|---|---:|---:|---|---|']
    summary = []
    for name, unit in sorted({(r['variant'],r['unit']) for r in records if r['label'].startswith('screen_')}):
        runs = [r for r in records if r['variant']==name and r['unit']==unit and r['label'].startswith('screen_')]
        valid = [r['peak_rss_kib'] for r in runs if r['status']=='ok' and r.get('peak_rss_kib',0)>0]
        baseline = [r['peak_rss_kib'] for r in records if r['variant']=='O2' and r['unit']==unit and
                    r['label'].startswith('screen_') and r['status']=='ok' and r.get('peak_rss_kib',0)>0]
        classification = 'incomplete/failed'
        if len(valid)==len(runs) and len(valid)>=3 and len(baseline)>=3:
            classification = 'reference' if name=='O2' else 'no resolved RSS change'
            if name != 'O2' and max(valid)<min(baseline): classification='lower observed RSS'
            if name != 'O2' and min(valid)>max(baseline): classification='higher observed RSS'
            if name in ('window25','window50'): classification += '; retention changed'
        if any(r['status']=='behavior_invalid' for r in runs): classification='behavior-invalid'
        med = statistics.median(valid) if valid else None
        span = f'{min(valid)}–{max(valid)}' if valid else '—'
        lines.append(f'| {name} | {unit} | {len(valid)}/{len(runs)} | {med if med is not None else "—"} | {span} | {classification} |')
        summary.append(dict(variant=name,unit=unit,median_peak_rss_kib=med,classification=classification))
    lines += ['', '## Storage and allocation diagnostics', '',
              '| Variant | Sample / retained record bytes | State bytes | Explicit allocation calls | Peak requested heap bytes | Remaining requested bytes |',
              '|---|---:|---:|---:|---:|---:|']
    for r in records:
        if r.get('allocation_probe'):
            o, p = r['output'], r['allocation_probe']
            lines.append(f'| {r["variant"]} | {o["sample_bytes"]} / {o["record_bytes"]} | {o["memory_state_bytes"]} | {p["allocation_calls"]} | {p["requested_peak_bytes"]} | {p["requested_remaining_bytes"]} |')
    lines += ['', '## Resource limits and paced confirmation', '',
              '| Trial | Status | Peak RSS (KiB) | Exit code |', '|---|---|---:|---:|']
    for r in records:
        if r['limits'] or r['paced'] or r['label'].startswith('limit_'):
            lines.append(f'| {r["label"]} | {r["status"]} | {r.get("peak_rss_kib", "—")} | {r["process"]["returncode"]} |')
    build_rows = []
    for build_path in sorted((out/'builds').glob('*/build_result.json')):
        b = json.loads(build_path.read_text())
        if b['diagnostic']: continue
        directory = build_path.parent
        stack = []
        for su in directory.glob('*.su'):
            for line in su.read_text(errors='replace').splitlines():
                parts = line.split('\t')
                if len(parts)>1 and parts[1].isdigit(): stack.append(int(parts[1]))
        for unit in UNITS:
            row = dict(variant=b['variant']['name'],unit=unit,binary_file_bytes=(directory/unit).stat().st_size,
                       shared_library_file_bytes=sum(p.stat().st_size for p in directory.glob('*.so')),
                       largest_reported_frame_bytes=max(stack) if stack else '')
            report = directory/('size_'+unit+'.stdout')
            if report.exists():
                for section in ['text','rodata','data','bss']:
                    match = re.search(r'^\.'+section+r'\s+(\d+)', report.read_text(), re.M)
                    row[section+'_bytes'] = int(match[1]) if match else 0
            build_rows.append(row)
    with (out/'builds.csv').open('w', newline='') as f:
        keys = ['variant','unit','binary_file_bytes','shared_library_file_bytes','largest_reported_frame_bytes',
                'text_bytes','rodata_bytes','data_bytes','bss_bytes']
        writer = csv.DictWriter(f,fieldnames=keys); writer.writeheader(); writer.writerows(build_rows)
    with (out/'phases.csv').open('w', newline='') as f:
        keys = ['variant','phase','rss_kib','pss_kib','private_clean_kib','private_dirty_kib',
                'shared_clean_kib','shared_dirty_kib','vm_size_kib','vm_data_kib','vm_stack_kib']
        writer = csv.DictWriter(f,fieldnames=keys); writer.writeheader()
        for r in records:
            path = out/'runs'/r['label']/'process.snapshots.json'
            if not path.exists(): continue
            for phase_name, files in json.loads(path.read_text()).items():
                row = dict(variant=r['variant'],phase=phase_name)
                for field, key in [('Rss','rss_kib'),('Pss','pss_kib'),('Private_Clean','private_clean_kib'),
                                   ('Private_Dirty','private_dirty_kib'),('Shared_Clean','shared_clean_kib'),('Shared_Dirty','shared_dirty_kib')]:
                    values = re.findall(r'^'+field+r':\s+(\d+)', files.get('smaps_rollup', files.get('smaps','')), re.M)
                    if values: row[key] = sum(map(int,values))
                for field, key in [('VmSize','vm_size_kib'),('VmData','vm_data_kib'),('VmStk','vm_stack_kib')]:
                    match = re.search(r'^'+field+r':\s+(\d+)', files.get('status',''), re.M)
                    if match: row[key] = int(match[1])
                writer.writerow(row)
    lines += ['', 'Binary sections and file sizes are in builds.csv. The largest compiler-reported frame is a build-wide diagnostic, not a bound on total call-stack usage. Shared-library sections remain in their raw size reports.']
    lines += ['', '## Build and validation outcomes', '']
    events_path = out/'events.jsonl'
    events = [json.loads(line) for line in events_path.read_text().splitlines()] if events_path.exists() else []
    for event in events:
        if event.get('stage')=='build': lines.append(f'- {event["variant"]}: {event["status"]}. '+event.get('reason',''))
    finished = {(e.get('variant'),e.get('unit')) for e in events if e.get('stage')=='run' and e.get('label','').startswith('screen_')}
    missing = [f'{v["name"]}/{u}' for v in variants() for u in UNITS if (v['name'],u) not in finished]
    lines += ['', '## Unmeasured screening combinations', '', ', '.join(missing) or 'None.', '',
              '## Interpretation limits', '',
              'Peak RSS includes resident shared pages; byte-level storage savings may not change page-level RSS. Zero RSS is treated as unavailable.',
              'The fixed CSV reader returns its first numeric value; the harness adds a deterministic triangular ramp and outliers. This is accelerated synthetic replay, not sensor acquisition.',
              'The predictor is the existing brief rule-based function, not a future intensive HVAC model.',
              'Reduced-window candidates preserve their own capacity-specific reference, not the original retained history.',
              'Static storage supports one memory instance. Allocation probe counts only explicit Critter memory allocations, excluding libc and loader allocations.',
              'Stack/data limits apply inside the executable after startup. A passing limit is an observation, not a worst-case bound. Failed allocations may expose existing fail-open filtering behavior.',
              'Source copies, patches, effective options, commands, stack reports, ELF reports, raw time output, snapshots, and per-run outputs are retained.']
    (out/'report.md').write_text('\n'.join(lines)+'\n')
    write_json(out/'summary.json', summary)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['run','pi-check','mac-check','analyze','plan'])
    parser.add_argument('--output', type=Path)
    parser.add_argument('--minutes', type=int, default=120, choices=range(10,121), metavar='10..120')
    parser.add_argument('--resume', action='store_true', help='resume unchanged source in --output; starts a new bounded session')
    args = parser.parse_args()
    if args.action == 'plan': print(json.dumps(variants(), indent=2)); return
    if args.action == 'analyze':
        if not args.output: parser.error('analyze requires --output EXISTING_RESULTS')
        analyze(args.output); return
    mac = args.action=='mac-check'
    if mac and sys.platform != 'darwin': parser.error('mac-check is for macOS only')
    if not mac:
        if sys.platform != 'linux' or platform.machine() not in ('aarch64','arm64'):
            parser.error('Pi measurements require 64-bit ARM Linux; use mac-check for development')
        if os.geteuid() != 0: parser.error('run with sudo so diagnostics have consistent access')
        for tool in ['gcc','ar','size','readelf','nm']:
            if not shutil.which(tool): parser.error('missing prerequisite: '+tool)
        if not Path('/usr/bin/time').exists(): parser.error('install GNU time first')
        model = Path('/proc/device-tree/model')
        if not model.exists() or 'Raspberry Pi 5' not in model.read_text():
            parser.error('this campaign targets Raspberry Pi 5 (Cortex-A76)')
    timestamp = dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    out = args.output or ROOT/'Development/Metrics/MemoryAssessment'/('mac_check_' if mac else 'pi_')/timestamp
    if args.resume and not args.output: parser.error('--resume requires --output EXISTING_RESULTS')
    c = Campaign(out, args.minutes, mac, args.resume)
    print('Results:', c.out, flush=True)
    status = 'complete'
    exitcode = 0
    def stop(signum, frame): raise KeyboardInterrupt()
    for sig in [signal.SIGTERM, signal.SIGINT]: signal.signal(sig, stop)
    try:
        c.execute(quick=mac or args.action=='pi-check')
    except BudgetExpired:
        status='budget_exhausted'; c.event(stage='campaign',status=status)
    except KeyboardInterrupt:
        status='interrupted'; exitcode=130
    except Exception as e:
        status='failed'; exitcode=1; c.event(stage='campaign',status=status,reason=str(e))
        import traceback; traceback.print_exc()
    finally:
        analyze(c.out)
        write_json(c.out/'completion.json', dict(status=status, elapsed_s=time.monotonic()-c.started,
                                               maximum_minutes=args.minutes, development_only=mac))
        if os.geteuid()==0 and os.environ.get('SUDO_UID'):
            uid,gid=int(os.environ['SUDO_UID']),int(os.environ['SUDO_GID'])
            for p in [c.out]+list(c.out.rglob('*')):
                if not p.is_symlink(): os.chown(p,uid,gid)
        print('Finished:',status,'Report:',c.out/'report.md',flush=True)
        c.lock.close()
    sys.exit(exitcode)


if __name__=='__main__': main()
