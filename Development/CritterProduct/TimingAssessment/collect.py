#!/usr/bin/env python3
"""Plan on either platform; collect and change hardware settings only on a Pi 5."""
import argparse
import contextlib
import datetime as dt
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import pwd
import random
import re
import shutil
import signal
import subprocess
import sys
import tarfile
import tempfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
CPU = Path("/sys/devices/system/cpu")
RAM_LIMITS = {"8": None, "4": "4G", "2": "2G", "1.5": "1536M"}


def read(path):
    try:
        return Path(path).read_text().strip()
    except OSError:
        return None


def command_output(command, cwd=None):
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=5, cwd=cwd)
        return {"returncode": result.returncode, "stdout": result.stdout.strip(), "stderr": result.stderr.strip()}
    except (OSError, subprocess.TimeoutExpired) as exc:
        return {"error": str(exc)}


def dump(path, obj):
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as f:
        temporary = Path(f.name)
        try:
            f.write(json.dumps(obj, indent=2) + "\n")
            f.flush()
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)


def sha256(path):
    with Path(path).open("rb") as f:
        return hashlib.file_digest(f, "sha256").hexdigest() if hasattr(hashlib, "file_digest") else hashlib.sha256(f.read()).hexdigest()


def require_pi(root=False):
    model = read("/proc/device-tree/model") or ""
    if platform.system() != "Linux" or "Raspberry Pi 5" not in model:
        raise RuntimeError("this operation requires a Raspberry Pi 5 running Linux; use plan on the Mac")
    if root and os.geteuid() != 0:
        raise RuntimeError("run this operation with sudo; application children are dropped back to SUDO_UID")


def online_cpus():
    return [i for i in range(4) if not (CPU / f"cpu{i}/online").exists()
            or read(CPU / f"cpu{i}/online") == "1"]


def snapshot():
    return {"online": online_cpus(), "policies": {
        str(p): {name: read(p / name) for name in
                 ("scaling_governor", "scaling_min_freq", "scaling_max_freq",
                  "scaling_available_governors", "cpuinfo_min_freq", "cpuinfo_max_freq")}
        for p in sorted((CPU / "cpufreq").glob("policy*"))}}


def set_cores(count):
    # Bring required CPUs online before removing others. CPU0 always stays online.
    for i in range(1, count):
        (CPU / f"cpu{i}/online").write_text("1")
    for i in range(3, count - 1, -1):
        if i:
            (CPU / f"cpu{i}/online").write_text("0")
    if online_cpus() != list(range(count)):
        raise RuntimeError("online CPU mask did not match requested core count")


def configure(condition):
    set_cores(4)
    for policy in (CPU / "cpufreq").glob("policy*"):
        governor = condition["governor"]
        if governor not in (read(policy / "scaling_available_governors") or "").split():
            raise RuntimeError(f"{governor} unavailable at {policy}; no governor substitution was made")
        (policy / "scaling_min_freq").write_text(read(policy / "cpuinfo_min_freq"))
        (policy / "scaling_max_freq").write_text(read(policy / "cpuinfo_max_freq"))
        (policy / "scaling_governor").write_text(governor)
    set_cores(condition["cores"])


def restore(state):
    errors = []
    try:
        set_cores(4)
    except (OSError, RuntimeError) as exc:
        errors.append(str(exc))
    for policy, fields in state["policies"].items():
        for name, value in (("scaling_min_freq", fields["cpuinfo_min_freq"]),
                            ("scaling_max_freq", fields["scaling_max_freq"]),
                            ("scaling_min_freq", fields["scaling_min_freq"]),
                            ("scaling_governor", fields["scaling_governor"])):
            try:
                (Path(policy) / name).write_text(value)
            except (OSError, TypeError) as exc:
                errors.append(f"{policy}/{name}: {exc}")
    try:
        for i in range(1, 4):
            (CPU / f"cpu{i}/online").write_text("1" if i in state["online"] else "0")
    except OSError as exc:
        errors.append(str(exc))
    if errors:
        raise RuntimeError("restoration needs attention: " + "; ".join(errors))
    actual = snapshot()
    if actual["online"] != state["online"] or any(
        actual["policies"].get(policy, {}).get(field) != fields[field]
        for policy, fields in state["policies"].items()
        for field in ("scaling_governor", "scaling_min_freq", "scaling_max_freq")):
        raise RuntimeError("restored CPU configuration did not match the saved state")


def condition_plan(ram="8", family="all", repetitions=3, seed=2160):
    base = dict(cores=4, governor="performance", network_mbit=0, matrix=False, nice=0, pinned=False)
    if ram != "8":
        if family not in ("all", "ram"):
            raise ValueError("non-native RAM sweeps use --family ram; other factors are held constant")
        conditions = [dict(base, condition=f"ram_{ram}", family="ram")]
    else:
        conditions = [dict(base, condition="baseline", family="baseline")]
        if family in ("all", "cores"):
            conditions += [dict(base, condition=f"cores_{n}", family="cores", cores=n) for n in (3, 2, 1)]
        if family in ("all", "governor"):
            conditions += [dict(base, condition=f"governor_{g}", family="governor", governor=g)
                           for g in ("powersave", "ondemand")]
        if family in ("all", "network"):
            conditions += [dict(base, condition=f"network_rx_{rate}M", family="network", network_mbit=rate)
                           for rate in (10, 50)]
        if family in ("all", "priority"):
            conditions += [dict(base, condition="priority_quiet", family="priority", pinned=True)]
            conditions += [dict(base, condition=f"priority_nice_{nice}", family="priority", pinned=True,
                                matrix=True, nice=nice) for nice in (-10, 0, 10, 19)]
    rng = random.Random(seed)
    plan = []
    for repetition in range(1, repetitions + 1):
        block = [dict(c, ram_gib=ram, repetition=repetition) for c in conditions]
        rng.shuffle(block)
        plan.extend(block)
    return plan


def memory_check(ram):
    tokens = (read("/proc/cmdline") or "").split()
    limits = [t for t in tokens if t.startswith("mem=")]
    expected = [] if RAM_LIMITS[ram] is None else ["mem=" + RAM_LIMITS[ram]]
    if limits != expected:
        raise RuntimeError(f"RAM label {ram} requires boot parameters {expected}; observed {limits}. Set RAM and reboot first.")
    meminfo = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
    actual = int(meminfo["MemTotal"].split()[0]) / 1024**2
    target = float(ram)
    if not target - .6 <= actual <= target + .15:
        raise RuntimeError(f"MemTotal={actual:.3f} GiB does not match nominal {ram} GiB")
    return actual


def identity():
    if "SUDO_UID" not in os.environ or int(os.environ["SUDO_UID"]) == 0:
        raise RuntimeError("invoke sudo from your ordinary Pi user account, not a root login")
    uid = int(os.environ["SUDO_UID"])
    account = pwd.getpwuid(uid)
    return uid, account.pw_gid, account.pw_name


def child_setup(uid, gid, user, nice, cpus):
    def setup():
        # Separate process groups permit cleanup; keeping the session preserves one autogroup.
        os.setpgid(0, 0)
        os.sched_setaffinity(0, cpus)
        os.setpriority(os.PRIO_PROCESS, 0, nice)
        os.initgroups(user, gid)
        os.setgid(gid)
        os.setuid(uid)
    return setup


def stop(process):
    if process is None:
        return
    with contextlib.suppress(ProcessLookupError):
        os.killpg(process.pid, signal.SIGTERM)
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        with contextlib.suppress(ProcessLookupError):
            os.killpg(process.pid, signal.SIGKILL)
        process.wait(timeout=5)


def process_settings(pid):
    return {"pid": pid, "nice": os.getpriority(os.PRIO_PROCESS, pid),
            "affinity": sorted(os.sched_getaffinity(pid)),
            "scheduler": os.sched_getscheduler(pid),
            "autogroup": read(f"/proc/{pid}/autogroup"), "cgroup": read(f"/proc/{pid}/cgroup")}


def telemetry():
    return {"monotonic_ns": time.monotonic_ns(), "online": read(CPU / "online"),
            "policies": {p.name: {k: read(p / k) for k in
                         ("scaling_cur_freq", "scaling_governor", "scaling_min_freq", "scaling_max_freq")}
                         for p in (CPU / "cpufreq").glob("policy*")},
            "temperature_millic": read("/sys/class/thermal/thermal_zone0/temp"),
            "meminfo": read("/proc/meminfo"), "vmstat": read("/proc/vmstat"),
            "cpu_stat": read("/proc/stat"), "network": read("/proc/net/dev"),
            "pressure": {name: read(f"/proc/pressure/{name}") for name in ("cpu", "memory", "io")}}


def matrix_loop(binary):
    stopping = False
    def handler(sig, frame):
        nonlocal stopping
        stopping = True
    signal.signal(signal.SIGTERM, handler)
    signal.signal(signal.SIGINT, handler)
    completed = 0
    started = time.monotonic_ns()
    while not stopping:
        result = subprocess.run([binary], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if stopping:
            break
        if result.returncode:
            raise RuntimeError(f"matrix workload exited {result.returncode}")
        completed += 1
    print(json.dumps({"completed_invocations": completed, "started_ns": started,
                      "stopped_ns": time.monotonic_ns()}), flush=True)


def one_run(args, condition, folder, account, state):
    uid, gid, user = account
    folder.mkdir()
    os.chown(folder, uid, gid)
    meta = dict(condition, status="started", source=args.source, schedule=args.schedule,
                binary_sha256=sha256(args.binary), input_sha256=sha256(args.input),
                duration_s=args.duration, period_ms=args.period_ms, deadline_ms=args.deadline_ms,
                started_utc=dt.datetime.now(dt.timezone.utc).isoformat())
    dump(folder / "metadata.json", meta)
    children = []
    samples = []
    app = network = matrix = None
    files = []
    try:
        configure(condition)
        time.sleep(args.settle)
        configured = snapshot()
        for fields in configured["policies"].values():
            if fields["scaling_governor"] != condition["governor"]:
                raise RuntimeError("requested governor did not take effect")
        meta["configured"] = configured
        meta["throttled_before"] = command_output(["vcgencmd", "get_throttled"])
        meta["swaps_before"] = read("/proc/swaps")
        meta["boot_id"] = read("/proc/sys/kernel/random/boot_id")
        cpus = {0} if condition["pinned"] else set(range(condition["cores"]))
        env = os.environ.copy()
        env.update(HOME=pwd.getpwuid(uid).pw_dir, USER=user, LOGNAME=user, LC_ALL="C")
        for key in ("CRITTER_DATA_FILE", "CRITTER_INPUT_FILE", "CRITTER_OUTPUT_FILE", "CRITTER_METRICS_FILE"):
            env.pop(key, None)
        def launch(command, name, nice=0, affinity=None):
            out = (folder / f"{name}.stdout").open("w")
            err = (folder / f"{name}.stderr").open("w")
            files.extend((out, err))
            p = subprocess.Popen(command, cwd=REPO, env=env, stdout=out, stderr=err,
                                 preexec_fn=child_setup(uid, gid, user, nice, affinity or cpus))
            children.append(p)
            settings = process_settings(p.pid)
            if settings["nice"] != nice or settings["affinity"] != sorted(affinity or cpus):
                raise RuntimeError(f"effective priority/affinity mismatch for {name}")
            meta[name + "_settings"] = settings
            return p
        if condition["matrix"]:
            matrix = launch([sys.executable, str(HERE / "collect.py"), "_matrix", str(args.matrix)],
                            "matrix", affinity={0})
        if condition["network_mbit"]:
            route = command_output(["ip", "route", "get", args.network_host])
            meta["network_route"] = route
            if route.get("returncode") != 0 or re.search(r"\bdev lo\b", route.get("stdout", "")):
                raise RuntimeError("network peer must be reachable through a physical network interface")
            network = launch([shutil.which("iperf3"), "-c", args.network_host, "-u", "-R",
                              "-b", f"{condition['network_mbit']}M", "-l", "1200",
                              "-t", str(math.ceil(args.duration + args.warmup + 10)), "-J"], "network")
        time.sleep(args.warmup)
        for p in (network, matrix):
            if p is not None and p.poll() is not None:
                raise RuntimeError("background workload exited before measurement began; inspect its stderr")
        if matrix:
            meta["matrix_settings"] = process_settings(matrix.pid)
        app = launch(["/usr/bin/time", "-v", "-o", str(folder / "time.txt"), str(args.binary),
                      "--duration", str(args.duration), "--period-ms", str(args.period_ms),
                      "--deadline-ms", str(args.deadline_ms), "--source", args.source,
                      "--input", str(args.input), "--schedule", args.schedule, "--output", str(folder)],
                     "critter", nice=condition["nice"])
        if matrix:
            for field in ("autogroup", "cgroup"):
                if meta["matrix_settings"][field] != meta["critter_settings"][field]:
                    raise RuntimeError(f"priority experiment children differ in {field}")
        dump(folder / "metadata.json", meta)
        timeout = time.monotonic() + args.duration + 30
        while app.poll() is None:
            samples.append(telemetry())
            if time.monotonic() > timeout:
                raise RuntimeError("Critter exceeded collection duration plus 30-second completion allowance")
            for p in (network, matrix):
                if p is not None and p.poll() is not None:
                    raise RuntimeError("background workload stopped before Critter exited")
            time.sleep(1)
        samples.append(telemetry())
        meta["critter_returncode"] = app.returncode
        if app.returncode != 0:
            raise RuntimeError(f"Critter exited {app.returncode}; timing records are retained when available")
        if network:
            network.wait(timeout=20)
            data = json.loads((folder / "network.stdout").read_text())
            if network.returncode != 0 or "error" in data:
                raise RuntimeError(f"network test failed: {data.get('error', network.returncode)}")
            received = data.get("end", {}).get("sum_received", data.get("end", {}).get("sum", {}))
            if received.get("bytes", 0) <= 0:
                raise RuntimeError("network test reported no received bytes")
            meta["network_result"] = received
        if matrix and matrix.poll() is not None:
            raise RuntimeError("matrix supervisor stopped unexpectedly")
        if any(s["online"] != ",".join(str(i) for i in range(condition["cores"]))
               and s["online"] != ("0" if condition["cores"] == 1 else f"0-{condition['cores'] - 1}") for s in samples):
            raise RuntimeError("online CPU mask changed during collection")
        expected_limits = {Path(p).name: fields for p, fields in configured["policies"].items()}
        for s in samples:
            for name, fields in s["policies"].items():
                if fields["scaling_governor"] != condition["governor"] or any(
                    fields[k] != expected_limits[name][k] for k in ("scaling_min_freq", "scaling_max_freq")):
                    raise RuntimeError("governor or frequency policy limits changed during collection")
        meta["throttled_after"] = command_output(["vcgencmd", "get_throttled"])
        meta["swaps_after"] = read("/proc/swaps")
        meta["status"] = "complete"
    except BaseException as exc:
        meta.update(status="failed", error=str(exc) or type(exc).__name__)
        raise
    finally:
        cleanup_errors = []
        for p in reversed(children):
            try:
                stop(p)
            except (OSError, subprocess.TimeoutExpired) as exc:
                cleanup_errors.append(str(exc))
        for f in files:
            f.close()
        if samples:
            try:
                with (folder / "telemetry.jsonl").open("w") as f:
                    for sample in samples:
                        f.write(json.dumps(sample) + "\n")
            except OSError as exc:
                cleanup_errors.append(str(exc))
        try:
            restore(state)
            meta["restored"] = snapshot()
        except Exception as exc:
            meta.update(status="failed", restoration_error=str(exc))
            dump(folder / "metadata.json", meta)
            raise
        finally:
            if cleanup_errors:
                meta.update(status="failed", cleanup_errors=cleanup_errors)
            meta["finished_utc"] = dt.datetime.now(dt.timezone.utc).isoformat()
            dump(folder / "metadata.json", meta)
        if cleanup_errors:
            raise RuntimeError("cleanup needs attention: " + "; ".join(cleanup_errors))


def run(args):
    require_pi(root=True)
    account = identity()
    if os.sched_getscheduler(0) != os.SCHED_OTHER:
        raise RuntimeError("launch the collector under ordinary SCHED_OTHER scheduling")
    if online_cpus() != [0, 1, 2, 3]:
        raise RuntimeError("start with all four CPUs online")
    actual_ram = memory_check(args.ram)
    plan = condition_plan(args.ram, args.family, args.repetitions, args.seed)
    state = snapshot()
    if not state["policies"]:
        raise RuntimeError("no CPU frequency policies found")
    for policy, fields in state["policies"].items():
        if any(not fields.get(name) for name in ("scaling_governor", "scaling_min_freq", "scaling_max_freq",
                                                "cpuinfo_min_freq", "cpuinfo_max_freq")):
            raise RuntimeError(f"missing frequency policy controls at {policy}; inspect doctor before collecting")
    for condition in plan:
        for fields in state["policies"].values():
            if condition["governor"] not in (fields["scaling_available_governors"] or "").split():
                raise RuntimeError(f"missing governor {condition['governor']}; inspect doctor, try modprobe cpufreq_ondemand")
    if not args.binary.is_file() or not os.access(args.binary, os.X_OK):
        raise RuntimeError("build the CritterTiming executable first")
    if not Path("/usr/bin/time").is_file() or command_output(["/usr/bin/time", "--version"]).get("returncode") != 0:
        raise RuntimeError("GNU time is required: sudo apt install time")
    if args.source == "data" and not args.input.is_file():
        raise RuntimeError("input CSV not found")
    if any(c["matrix"] for c in plan) and (not args.matrix.is_file() or not os.access(args.matrix, os.X_OK)):
        raise RuntimeError("build matrixmult first")
    if any(c["network_mbit"] for c in plan) and (not args.network_host or not shutil.which("iperf3")):
        raise RuntimeError("network conditions need --network-host MAC_IP and iperf3 installed")
    # Children share one session/autogroup; each receives its own cleanup process group.
    if os.getsid(0) != os.getpid():
        os.setsid()
    results_existed = args.results.exists()
    args.results.mkdir(parents=True, exist_ok=True)
    if not results_existed:
        os.chown(args.results, account[0], account[1])
    session = args.results / dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S_%fZ")
    session.mkdir()
    os.chown(session, account[0], account[1])
    dump(session / "original_state.json", state)
    dump(session / "plan.json", plan)
    environment = {"uname": platform.uname()._asdict(), "actual_ram_gib": actual_ram,
                   "cmdline": read("/proc/cmdline"), "model": read("/proc/device-tree/model"),
                   "os_release": read("/etc/os-release"), "swaps": read("/proc/swaps"),
                   "binary_sha256": sha256(args.binary), "input_sha256": sha256(args.input),
                   "matrix_source_sha256": sha256(HERE / "workload/matrixmult.c"),
                   "matrix_binary_sha256": sha256(args.matrix) if args.matrix.exists() else None,
                   "git_head": command_output(["git", "-c", f"safe.directory={REPO}", "rev-parse", "HEAD"], cwd=REPO),
                   "git_status": command_output(["git", "-c", f"safe.directory={REPO}", "status", "--short"], cwd=REPO),
                   "compiler": command_output(["cc", "--version"]),
                   "iperf_version": command_output(["iperf3", "--version"]),
                   "options": {k: str(v) if isinstance(v, Path) else v for k, v in vars(args).items()}}
    dump(session / "environment.json", environment)
    with tarfile.open(session / "source_snapshot.tar.gz", "w:gz") as archive:
        sources = [HERE / name for name in ("main.c", "CMakeLists.txt", "collect.py", "analyze.py", "workload/matrixmult.c")]
        sources += list((HERE.parent / "Pilot").rglob("*.c")) + list((HERE.parent / "Pilot").rglob("*.h"))
        sources += list((REPO / "Utils/SenseHat").glob("*.[ch]"))
        for path in sources:
            archive.add(path, arcname=str(path.relative_to(REPO)))
        for name in ("CMakeCache.txt", "compile_commands.json"):
            path = args.binary.parent / name
            if path.exists():
                archive.add(path, arcname="build_info/" + name)
    shutil.copy2(HERE / "workload/matrixmult.c", session / "matrixmult.c")
    shutil.copy2(args.input, session / "input.csv")
    print(f"Saving {len(plan)} runs to {session}", flush=True)
    try:
        for index, condition in enumerate(plan, 1):
            print(f"[{index}/{len(plan)}] {condition['condition']} repetition {condition['repetition']}", flush=True)
            one_run(args, condition, session / f"{index:03d}_{condition['condition']}_r{condition['repetition']}", account, state)
    finally:
        try:
            restore(state)
        finally:
            from analyze import analyze
            if list(session.glob("*/metadata.json")):
                analyze(session)
            for path in [session] + list(session.rglob("*")):
                os.chown(path, account[0], account[1])
    print(f"Collection complete. Run summaries: {session / 'run_summary.csv'}", flush=True)


def change_cmdline(text, ram):
    lines = text.strip().splitlines()
    if len(lines) != 1 or not any(t.startswith("root=") for t in lines[0].split()):
        raise ValueError("expected one boot command line containing root=; refusing to replace this file")
    tokens = [t for t in lines[0].split() if not t.startswith("mem=")]
    if RAM_LIMITS[ram]:
        tokens.append("mem=" + RAM_LIMITS[ram])
    return " ".join(tokens) + "\n"


def ram_change(args):
    require_pi(root=True)
    path = args.cmdline or next((p for p in (Path("/boot/firmware/cmdline.txt"), Path("/boot/cmdline.txt")) if p.exists()), None)
    if path is None:
        raise RuntimeError("cannot locate cmdline.txt; specify --cmdline")
    text = path.read_text()
    backup = path.with_name(path.name + ".critter-timing.original")
    if args.value == "restore":
        original = backup.read_text()
        if change_cmdline(text, "8") != change_cmdline(original, "8"):
            raise RuntimeError("other boot options changed after backup; restore mem= manually to preserve them")
        new = original
    else:
        new = change_cmdline(text, args.value)
        if not backup.exists():
            with backup.open("x") as f:
                f.write(text)
                f.flush()
                os.fsync(f.fileno())
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as f:
        temporary = Path(f.name)
        try:
            f.write(new)
            f.flush()
            os.fsync(f.fileno())
            os.chmod(temporary, path.stat().st_mode & 0o777)
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)
    os.sync()
    print(f"Updated {path}; original backup: {backup}\n{new.strip()}\nReboot manually, then run doctor to verify MemTotal.")


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "_matrix":
        matrix_loop(sys.argv[2])
        return
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    for action in ("plan", "run"):
        p = sub.add_parser(action)
        p.add_argument("--ram", choices=RAM_LIMITS, default="8")
        p.add_argument("--family", choices=("all", "cores", "governor", "ram", "network", "priority"), default="all")
        p.add_argument("--repetitions", type=int, default=3)
        p.add_argument("--seed", type=int, default=2160)
        p.add_argument("--duration", type=float, default=60)
        p.add_argument("--settle", type=float, default=10)
        p.add_argument("--warmup", type=float, default=5)
        p.add_argument("--period-ms", type=float, default=100)
        p.add_argument("--deadline-ms", type=float, default=100)
        p.add_argument("--binary", type=Path, default=HERE / "build/CritterTiming")
        p.add_argument("--matrix", type=Path, default=HERE / "build/matrixmult")
        p.add_argument("--input", type=Path, default=HERE / "input.csv")
        p.add_argument("--results", type=Path, default=HERE / "results")
        p.add_argument("--network-host")
        p.add_argument("--source", choices=("data", "cpu", "sense_hat"), default="data")
        p.add_argument("--schedule", choices=("periodic", "relative"), default="periodic")
    sub.add_parser("doctor")
    p = sub.add_parser("ram")
    p.add_argument("value", choices=tuple(RAM_LIMITS) + ("restore",))
    p.add_argument("--cmdline", type=Path)
    p = sub.add_parser("restore")
    p.add_argument("state", type=Path)
    args = parser.parse_args()
    if args.action in ("plan", "run"):
        if args.repetitions < 1 or args.repetitions > 100 or not all(math.isfinite(x) for x in
                (args.duration, args.settle, args.warmup, args.period_ms, args.deadline_ms)):
            parser.error("invalid repetition count or non-finite timing setting")
        if not 0 < args.duration <= 3600 or min(args.settle, args.warmup) < 0 or not 1 <= args.deadline_ms <= args.period_ms:
            parser.error("require duration 0..3600s; nonnegative waits; 1ms <= deadline <= period")
        duration_ns, period_ns = round(args.duration * 1e9), round(args.period_ms * 1e6)
        if duration_ns < period_ns or duration_ns % period_ns or duration_ns // period_ns > 1000000:
            parser.error("duration must contain 1..1000000 whole periods")
        for name in ("binary", "matrix", "input", "results"):
            setattr(args, name, getattr(args, name).resolve())
    if args.action == "plan":
        plan = condition_plan(args.ram, args.family, args.repetitions, args.seed)
        print(json.dumps(plan, indent=2))
        print(f"{len(plan)} runs; minimum collection time {len(plan)*args.duration/60:.1f} minutes; "
              f"approximately {len(plan)*(args.duration+args.settle+args.warmup)/60:.1f} including setup, plus network tails.", file=sys.stderr)
    elif args.action == "doctor":
        require_pi()
        print(json.dumps({"model": read("/proc/device-tree/model"), "configuration": snapshot(),
                          "meminfo": read("/proc/meminfo"), "cmdline": read("/proc/cmdline"),
                          "swaps": read("/proc/swaps"), "time": command_output(["/usr/bin/time", "--version"]),
                          "iperf3": command_output(["iperf3", "--version"]),
                          "throttled": command_output(["vcgencmd", "get_throttled"])}, indent=2))
    elif args.action == "ram":
        ram_change(args)
    elif args.action == "restore":
        require_pi(root=True)
        restore(json.loads(args.state.read_text()))
    elif args.action == "run":
        require_pi(root=True)
        with open("/run/lock/critter-timing.lock", "w") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            run(args)


if __name__ == "__main__":
    signal.signal(signal.SIGTERM, lambda sig, frame: sys.exit(143))
    try:
        main()
    except KeyboardInterrupt:
        print("Collection interrupted; inspect the last run and saved restoration status.", file=sys.stderr)
        sys.exit(130)
    except (RuntimeError, ValueError, OSError, subprocess.SubprocessError) as exc:
        print(f"Collection stopped: {exc}", file=sys.stderr)
        sys.exit(1)
