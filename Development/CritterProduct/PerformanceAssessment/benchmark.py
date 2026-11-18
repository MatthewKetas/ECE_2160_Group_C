#!/usr/bin/env python3
"""Build, train, and benchmark the Critter Pilot's compiler configurations."""

import argparse
import csv
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import random
import shlex
import shutil
import statistics
import subprocess
import sys
import tempfile


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PILOT = HERE.parent / "Pilot"
SENSE_HAT = ROOT / "Utils" / "SenseHat"
IO = [PILOT / "IO" / "critter_io.c", HERE / "replay_sensor.c"]
MEMORY = [PILOT / "Memory" / "critter_memory.c"]
COMPUTATION = [PILOT / "Computation" / "critter_computation.c"]
UNITS = {
    "io": (1, IO, "sample"),
    "memory": (2, MEMORY, "sample"),
    "computation": (3, COMPUTATION, "prediction"),
    "pipeline": (4, IO + MEMORY + COMPUTATION, "sample"),
}
VARIANTS = {
    "O0": ["-O0"],
    "O2": ["-O2"],
    "O2_pgo": ["-O2"],
    "O2_lto": ["-O2", "-flto"],
}
SAMPLES = 600
CASES = 6
CAPACITY = 100
TRAIN_WINDOWS = 12
MAX_WINDOWS = 200000 // CASES * CASES
SEED = 2160
DARWIN = platform.system() == "Darwin"


def timestamp():
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S_%fZ")


def command(args, cwd=None, log=None, env=None, timeout=120):
    """Run one bounded subprocess and retain its exact command and diagnostics."""
    args = [str(arg) for arg in args]
    result = subprocess.run(args, cwd=cwd, env=env, text=True, capture_output=True, timeout=timeout)
    if log is not None:
        with log.open("a") as stream:
            stream.write(f"$ {shlex.join(args)}\n{result.stdout}{result.stderr}")
    if result.returncode:
        detail = f" (see {log})" if log else f"\n{result.stderr.strip()}"
        raise RuntimeError(f"{shlex.join(args)} exited with {result.returncode}{detail}")
    return result.stdout


def board_state():
    state = {}
    for name, path in {
        "model": "/proc/device-tree/model",
        "cpu_governor": "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor",
        "cpu_temperature_millidegrees_c": "/sys/class/thermal/thermal_zone0/temp",
    }.items():
        try:
            state[name] = Path(path).read_text().strip("\x00\n")
        except OSError:
            pass
    if shutil.which("vcgencmd"):
        try:
            state["throttling"] = command(["vcgencmd", "get_throttled"], timeout=3).strip()
        except (OSError, RuntimeError, subprocess.TimeoutExpired):
            state["throttling"] = "unavailable"
    return state


def file_evidence(path, expected_rows):
    digest = hashlib.sha256()
    lines = 0
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
            lines += chunk.count(b"\n")
    if lines != expected_rows + 1:
        raise RuntimeError(f"{path.name} contains {lines - 1} rows, expected {expected_rows}")
    return digest.hexdigest()


def live_io(sensor, unit):
    return sensor == "sense-hat" and unit in ("io", "pipeline")


def minimum_windows(sensor, unit):
    return 1 if live_io(sensor, unit) else CASES


def trial(executable, unit, workload, windows, output, profile=None, keep=None, sensor="replay", oracle=None):
    # Every trial appends to fresh files. Inspect the outputs after the timed work.
    with tempfile.TemporaryDirectory(prefix="trial_", dir=output) as temp:
        scratch = Path(temp)
        samples = scratch / "samples.csv"
        metrics = scratch / "metrics.csv"
        env = dict(os.environ, LC_ALL="C", CRITTER_DATA_FILE=str(samples), CRITTER_METRICS_FILE=str(metrics))
        hardware = live_io(sensor, unit)
        if hardware:
            env["CRITTER_CAPTURE_FILE"] = str(scratch / "capture.bin")
        if profile is not None:
            env["LLVM_PROFILE_FILE"] = str(profile)
        result = json.loads(command([executable, workload, windows], cwd=executable.parent, env=env))
        result["samples_sha256"] = file_evidence(samples, windows * SAMPLES) if unit in ("io", "pipeline") else ""
        result["metrics_sha256"] = file_evidence(metrics, windows) if unit == "pipeline" else ""
        if unit in ("memory", "pipeline") and not hardware:
            if result["retained"] != windows * CAPACITY or result["rejected"] or result["outliers"] == 0:
                raise RuntimeError(f"Unexpected filtering result for {executable}: {result}")
        if unit in ("computation", "pipeline") and windows >= CASES and not hardware:
            if not all(result[key] for key in ("heating_windows", "cooling_windows", "stable_windows")):
                raise RuntimeError(f"Missing HVAC decisions for {executable}: {result}")
        if hardware:
            if result["sense_hat_samples"] != windows * SAMPLES:
                raise RuntimeError(f"Incomplete physical Sense HAT acquisition for {executable}")
            check_env = dict(env, CRITTER_DATA_FILE=str(scratch / "checked_samples.csv"),
                             CRITTER_METRICS_FILE=str(scratch / "checked_metrics.csv"))
            check_env.pop("LLVM_PROFILE_FILE", None)
            checked = json.loads(command([oracle or executable, "check", windows], env=check_env))
            checked["samples_sha256"] = file_evidence(scratch / "checked_samples.csv", windows * SAMPLES)
            checked["metrics_sha256"] = file_evidence(scratch / "checked_metrics.csv", windows) if unit == "pipeline" else ""
            verify(result, checked, executable.parent.parent.name, unit)
            result["capture_sha256"] = hashlib.sha256((scratch / "capture.bin").read_bytes()).hexdigest()
        else:
            result["capture_sha256"] = ""
        result["validation"] = "O0_same_capture" if hardware else "O0_fixed_input"
        if keep is not None:
            keep.mkdir(parents=True)
            for path in (samples, metrics, scratch / "capture.bin"):
                if path.is_file():
                    shutil.copyfile(path, keep / path.name)
            (keep / "result.json").write_text(json.dumps(result, indent=2) + "\n")
            if hardware:
                (keep / "O0_check.json").write_text(json.dumps(checked, indent=2) + "\n")
        return result


def build(cc, family, objdump, profdata, variant, unit, output, sensor="replay", oracle=None):
    number, sources, _ = UNITS[unit]
    if live_io(sensor, unit):
        sources = [SENSE_HAT / "sense_hat_environment.c" if p == HERE / "replay_sensor.c" else p for p in sources]
    directory = output / "builds" / variant / unit
    directory.mkdir(parents=True)
    executable = directory / "bench"
    base = [cc, "-std=c11", "-g1", "-ffp-contract=off", f"-DBENCH_UNIT={number}",
            f"-DBENCH_SENSOR_REAL={int(sensor == 'sense-hat')}",
            "-I", PILOT, "-I", SENSE_HAT, *VARIANTS[variant]]
    inputs = [HERE / "benchmark.c", *sources, "-lm", "-o", executable.name]
    profile_use = []
    if variant == "O2_pgo":
        profile_dir = directory / "profile"
        profile_dir.mkdir()
        raw = profile_dir / "training.profraw"
        indexed = profile_dir / "training.profdata"
        if family == "clang":
            generate = ["-fprofile-instr-generate"]
            profile_use = [f"-fprofile-instr-use={indexed}", "-Werror=profile-instr-out-of-date",
                           "-Werror=profile-instr-unprofiled"]
        else:
            generate = [f"-fprofile-generate={profile_dir}"]
            profile_use = [f"-fprofile-use={profile_dir}", "-Werror=missing-profile", "-Werror=coverage-mismatch"]
        command([*base, *generate, *inputs], directory, directory / "instrumented-build.log")
        training_windows = 2 if live_io(sensor, unit) else TRAIN_WINDOWS
        training = trial(executable, unit, "train", training_windows, output,
                         raw if family == "clang" else None,
                         keep=profile_dir / "training_data" if live_io(sensor, unit) else None,
                         sensor=sensor, oracle=oracle)
        training["windows"] = training_windows
        (profile_dir / "training.json").write_text(json.dumps(training, indent=2) + "\n")
        if family == "clang":
            command([*profdata, "merge", "-o", indexed, raw], directory, directory / "profile-merge.log")
        elif len(list(profile_dir.glob("*.gcda"))) != len(sources) + 1:
            raise RuntimeError(f"Expected a GCC profile for each source file in {profile_dir}")
        # GCC matches profile data to the build's source and output names.
        executable.unlink()

    remarks = ["-Rpass=.*", "-Rpass-missed=.*"] if family == "clang" else ["-fopt-info-optimized-missed"]
    command([*base, *profile_use, *remarks, *inputs], directory, directory / "compiler.log")
    command([objdump, "-d", "-l", executable.name], directory, directory / "disassembly.txt")
    command(["nm", "-n", executable.name], directory, directory / "symbols.txt")
    return executable


def calibrate(executable, unit, target_ns, output, sensor="replay"):
    step = minimum_windows(sensor, unit)
    windows = step
    while True:
        probe = trial(executable, unit, "evaluate", windows, output, sensor=sensor)
        if probe["wall_ns"] >= target_ns or windows == MAX_WINDOWS:
            return windows
        growth = min(10.0, target_ns / max(1, probe["wall_ns"]) * 1.1)
        windows = min(MAX_WINDOWS, math.ceil(windows * growth / step) * step)


def verify(result, reference, variant, unit):
    for key, value in reference.items():
        if key in ("wall_ns", "cpu_ns"):
            continue
        if isinstance(value, float):
            matches = math.isclose(result[key], value, rel_tol=1e-12, abs_tol=1e-12)
        else:
            matches = result[key] == value
        if not matches:
            raise RuntimeError(f"{variant}/{unit}: {key} differs from O0 ({result[key]} vs {value})")


def write_summary(output, rows):
    groups = {}
    for unit in UNITS:
        for variant in VARIANTS:
            group = [row for row in rows if row["unit"] == unit and row["variant"] == variant]
            walls = [row["wall_ns"] for row in group]
            cpus = [row["cpu_ns"] for row in group]
            median = statistics.median(walls)
            windows = group[0]["windows"]
            groups[unit, variant] = {
                "unit": unit, "variant": variant, "repetitions": len(group), "windows": windows,
                "operation": UNITS[unit][2], "operations": windows * SAMPLES,
                "wall_median_ns": median, "wall_min_ns": min(walls), "wall_max_ns": max(walls),
                "cpu_median_ns": statistics.median(cpus), "wall_ns_per_operation": median / (windows * SAMPLES),
                "wall_ms_per_batch": median / windows / 1e6,
            }

    for (unit, variant), group in groups.items():
        group["speedup_vs_O0"] = groups[unit, "O0"]["wall_median_ns"] / group["wall_median_ns"]
        group["speedup_vs_O2"] = groups[unit, "O2"]["wall_median_ns"] / group["wall_median_ns"]

    with (output / "summary.csv").open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=next(iter(groups.values())).keys())
        writer.writeheader()
        writer.writerows(groups.values())


def run(args, output, metadata):
    version = command([args.cc, "--version"]).strip()
    family = "clang" if "clang" in version.lower() else "gcc"
    if family == "gcc" and "free software foundation" not in version.lower():
        raise RuntimeError(f"Use GCC or Clang via --cc. Detected: {version.splitlines()[0]}")
    profdata = [args.profdata] if args.profdata else (["xcrun", "llvm-profdata"] if DARWIN else ["llvm-profdata"])
    metadata["compiler"] = version
    metadata["disassembler"] = command([args.objdump, "--version"]).splitlines()[0]
    if family == "clang":
        metadata["profdata"] = command([*profdata, "--version"]).strip()
    sources = [HERE / "benchmark.py", HERE / "benchmark.c", HERE / "replay_sensor.h",
               PILOT / "critter_types.h", SENSE_HAT / "sense_hat_environment.h", *IO, *MEMORY, *COMPUTATION,
               PILOT / "IO" / "critter_io.h", PILOT / "Memory" / "critter_memory.h",
               PILOT / "Computation" / "critter_computation.h"]
    metadata["source_sha256"] = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                                for path in sources}
    if args.sensor == "sense-hat":
        driver = SENSE_HAT / "sense_hat_environment.c"
        metadata["source_sha256"][str(driver.relative_to(ROOT))] = hashlib.sha256(driver.read_bytes()).hexdigest()
    executables = {}
    for variant in VARIANTS:
        print(f"Building {variant} for all four workloads", flush=True)
        for unit in UNITS:
            executables[variant, unit] = build(args.cc, family, args.objdump, profdata, variant, unit, output,
                                             sensor=args.sensor, oracle=executables.get(("O0", unit)))
    metadata["executable_bytes"] = {f"{variant}/{unit}": path.stat().st_size
                                   for (variant, unit), path in executables.items()}

    windows = {}
    references = {}
    print("Calibrating and checking O0 references", flush=True)
    for unit in UNITS:
        baseline = executables["O0", unit]
        windows[unit] = minimum_windows(args.sensor, unit) if args.smoke else calibrate(
            baseline, unit, args.target_seconds * 1e9, output, sensor=args.sensor)
        references[unit] = trial(baseline, unit, "evaluate", windows[unit], output,
                                 keep=output / "reference" / unit, sensor=args.sensor)
    metadata["windows"] = windows
    (output / "reference" / "results.json").write_text(json.dumps(references, indent=2) + "\n")

    # Interleave all treatment/workload pairs so no configuration always runs first.
    rng = random.Random(SEED)
    warmups = list(executables)
    rng.shuffle(warmups)
    for variant, unit in warmups:
        trial(executables[variant, unit], unit, "evaluate", minimum_windows(args.sensor, unit), output,
              sensor=args.sensor, oracle=executables["O0", unit])

    rows = []
    fields = ["order", "repetition", "variant", "unit", "windows", "operation", "operations",
              *next(iter(references.values())).keys()]
    with (output / "trials.csv").open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        for repetition in range(1, metadata["repetitions"] + 1):
            print(f"Measuring repetition {repetition}/{metadata['repetitions']}", flush=True)
            order = list(executables)
            rng.shuffle(order)
            for variant, unit in order:
                count = windows[unit]
                hardware = live_io(args.sensor, unit)
                keep = output / "trials" / f"{len(rows) + 1:03d}_{variant}_{unit}" if hardware else None
                result = trial(executables[variant, unit], unit, "evaluate", count, output,
                               keep=keep, sensor=args.sensor, oracle=executables["O0", unit])
                if not hardware:
                    verify(result, references[unit], variant, unit)
                row = {"order": len(rows) + 1, "repetition": repetition, "variant": variant, "unit": unit,
                       "windows": count, "operation": UNITS[unit][2], "operations": count * SAMPLES, **result}
                writer.writerow(row)
                stream.flush()
                rows.append(row)
    write_summary(output, rows)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--smoke", action="store_true", help="build all variants and run one short repetition")
    parser.add_argument("--sensor", choices=("sense-hat", "replay"), default="replay" if DARWIN else "sense-hat",
                        help="physical Sense HAT on Linux (default), or deterministic replay for development")
    parser.add_argument("--repeats", type=int, default=9, help="measured repetitions per variant and workload")
    parser.add_argument("--target-seconds", type=float, default=0.25, help="minimum O0 calibration target per trial")
    parser.add_argument("--cc", default="clang" if DARWIN else "gcc", help="C compiler executable")
    parser.add_argument("--profdata", help="llvm-profdata executable matching the Clang version")
    parser.add_argument("--objdump", default="objdump", help="disassembler executable")
    parser.add_argument("--output", type=Path, default=HERE / "results", help="parent for timestamped run directories")
    args = parser.parse_args()
    if args.repeats < 1 or not 0.01 <= args.target_seconds <= 5.0:
        parser.error("--repeats must be positive and --target-seconds must be between 0.01 and 5.0")
    if args.sensor == "sense-hat":
        if platform.system() != "Linux":
            parser.error("Physical Sense HAT collection requires Linux on the Pi. Use --sensor replay for Mac checks.")
        if not os.access("/dev/i2c-1", os.R_OK | os.W_OK):
            parser.error("Cannot access /dev/i2c-1. Enable I2C and grant your Pi user access to the device.")

    output = args.output.resolve() / timestamp()
    output.mkdir(parents=True)
    print(f"Results directory: {output}", flush=True)
    metadata = {
        "status": "running", "schema_version": 2, "sensor": args.sensor,
        "started_utc": output.name, "platform": platform.platform(),
        "machine": platform.machine(), "smoke": args.smoke, "repetitions": 1 if args.smoke else args.repeats,
        "target_seconds": None if args.smoke else args.target_seconds,
        "seed": SEED, "samples_per_window": SAMPLES, "retained_sample_capacity": CAPACITY,
        "pgo_training_windows": {unit: 2 if live_io(args.sensor, unit) else TRAIN_WINDOWS for unit in UNITS},
        "workload_sources": {unit: "physical Sense HAT" if live_io(args.sensor, unit) else "generated fixed inputs"
                             for unit in UNITS},
        "sampling": "unpaced acquisition with real timestamps" if args.sensor == "sense-hat" else "unpaced replay with nominal 10 Hz timestamps",
        "board_before": board_state(),
    }
    manifest = output / "metadata.json"
    manifest.write_text(json.dumps(metadata, indent=2) + "\n")
    try:
        run(args, output, metadata)
        metadata["status"] = "complete"
        return 0
    except (OSError, RuntimeError, ValueError, subprocess.TimeoutExpired, KeyboardInterrupt) as error:
        metadata.update(status="failed", error=str(error) or "interrupted")
        print(f"Benchmark failed: {metadata['error']}", file=sys.stderr)
        return 1
    finally:
        metadata["board_after"] = board_state()
        metadata["finished_utc"] = timestamp()
        manifest.write_text(json.dumps(metadata, indent=2) + "\n")


if __name__ == "__main__":
    sys.exit(main())
