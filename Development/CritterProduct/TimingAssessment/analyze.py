#!/usr/bin/env python3
"""Summarize scheduled slots, retaining failed runs and between-run replication."""
import argparse
import csv
import json
import math
from pathlib import Path
import statistics


def percentile(values, fraction):
    return sorted(values)[max(0, math.ceil(len(values) * fraction) - 1)] if values else None


def metrics(info, rows):
    expected = info["duration_ns"] // info["period_ns"]
    if len(rows) != expected or [r["slot"] for r in rows] != list(range(expected)):
        raise ValueError("trace does not contain exactly one ordered row per scheduled slot")
    if any(r["release_ns"] != r["slot"] * info["period_ns"] for r in rows):
        raise ValueError("trace release grid disagrees with experiment metadata")
    responses, lateness, acquisitions, wakeups, work, cpu, io, save, filtering = ([] for _ in range(9))
    misses = longest = streak = skipped = failures = 0
    for r in rows:
        attempted = r["start_ns"] >= 0
        success = attempted and all(r[k] for k in ("read_ok", "save_ok", "filter_ok"))
        if attempted:
            if r["finish_ns"] < r["start_ns"] or r["start_ns"] < r["release_ns"]:
                raise ValueError("invalid timestamp order")
            response = r["finish_ns"] - r["release_ns"]
            responses.append(response / 1e6)
            lateness.append(max(0, response - info["deadline_ns"]) / 1e6)
            wakeups.append((r["start_ns"] - r["release_ns"]) / 1e6)
            work.append((r["finish_ns"] - r["start_ns"]) / 1e6)
            cpu.append(r["cpu_ns"] / 1e6)
            if r["read_ok"]:
                if not r["start_ns"] <= r["acquired_ns"] <= r["saved_ns"] <= r["finish_ns"]:
                    raise ValueError("invalid stage timestamp order")
                acquisitions.append(r["acquired_ns"])
                io.append((r["acquired_ns"] - r["start_ns"]) / 1e6)
                save.append((r["saved_ns"] - r["acquired_ns"]) / 1e6)
                filtering.append((r["finish_ns"] - r["saved_ns"]) / 1e6)
            failures += not success
        else:
            skipped += 1
        missed = not success or r["finish_ns"] > r["release_ns"] + info["deadline_ns"]
        misses += missed
        streak = streak + 1 if missed else 0
        longest = max(longest, streak)
    # Include the run boundaries, so an early final acquisition cannot hide a trailing gap.
    edges = [0] + [min(t, info["duration_ns"]) for t in acquisitions] + [info["duration_ns"]]
    result = {
        "scheduled_cycles": expected, "attempted_cycles": expected - skipped,
        "skipped_cycles": skipped, "operation_failures": failures,
        "deadline_misses": misses, "deadline_miss_pct": 100 * misses / expected,
        "response_median_ms": statistics.median(responses) if responses else None,
        "response_p99_ms": percentile(responses, .99),
        "max_observed_lateness_ms": max(lateness, default=None),
        "max_acquisition_gap_ms": max((b - a) / 1e6 for a, b in zip(edges, edges[1:])),
        "longest_miss_streak": longest,
        "longest_miss_streak_ms": longest * info["period_ns"] / 1e6,
        "successful_reads": len(acquisitions), "outliers": info.get("outliers", 0),
        "analysis_ms": info.get("analysis_ns", 0) / 1e6,
    }
    for label, values in (("start_delay", wakeups), ("work", work), ("cpu", cpu),
                          ("acquisition", io), ("save", save), ("filter", filtering)):
        result[f"{label}_p99_ms"] = percentile(values, .99)
    return result


def write_csv(path, rows):
    fields = list(dict.fromkeys(key for row in rows for key in row))
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def time_metrics(text):
    labels = {"User time (seconds)": "process_user_s", "System time (seconds)": "process_system_s",
              "Maximum resident set size (kbytes)": "process_max_rss_kib",
              "Major (requiring I/O) page faults": "process_major_faults",
              "Minor (reclaiming a frame) page faults": "process_minor_faults",
              "Voluntary context switches": "process_voluntary_switches",
              "Involuntary context switches": "process_involuntary_switches"}
    values = {}
    for line in text.splitlines():
        if ": " not in line:
            continue
        key, value = line.strip().rsplit(": ", 1)
        if key in labels:
            values[labels[key]] = float(value)
        elif key.startswith("Elapsed (wall clock) time"):
            parts = [float(p) for p in value.split(":")]
            values["process_elapsed_s"] = sum(v * 60**i for i, v in enumerate(reversed(parts)))
    return values


def analyze(root):
    paths = {p.parent for name in ("metadata.json", "experiment.json") for p in root.rglob(name)}
    results = []
    for path in sorted(paths):
        try:
            meta = json.loads((path / "metadata.json").read_text()) if (path / "metadata.json").exists() else {}
        except (OSError, ValueError) as exc:
            meta = dict(status="failed", error=f"unreadable metadata: {exc}")
        row = {"run": str(path), "condition": meta.get("condition", "manual"),
               "repetition": meta.get("repetition", ""),
               "ram_gib": meta.get("ram_gib", ""), "source": meta.get("source", ""),
               "schedule": meta.get("schedule", ""),
               "core_method": meta.get("core_method", "legacy"),
               "binary_sha256": meta.get("binary_sha256", ""),
               "input_sha256": meta.get("input_sha256", ""),
               "run_status": meta.get("status", "unverified_local"),
               "error": meta.get("error") or meta.get("restoration_error") or "; ".join(meta.get("cleanup_errors", []))}
        try:
            info = json.loads((path / "experiment.json").read_text())
            row.update(source=info["source"], schedule=info["schedule"],
                       duration_s=info["duration_ns"] / 1e9, period_ms=info["period_ns"] / 1e6,
                       deadline_ms=info["deadline_ns"] / 1e6)
            with (path / "timing.csv").open() as f:
                rows = [{key: int(value) for key, value in r.items()} for r in csv.DictReader(f)]
            row.update(metrics(info, rows))
            if (path / "time.txt").exists():
                row.update(time_metrics((path / "time.txt").read_text()))
            if info["interrupted"] or info["operation_failed"] or not info["analysis_ok"]:
                row["run_status"] = "failed"
                row["error"] = row["error"] or "application interrupted or operation/analysis failed"
        except (OSError, ValueError, KeyError) as exc:
            row.update(run_status="failed", error=f"{row['error']} {exc}".strip())
        results.append(row)
    if not results:
        raise ValueError("no run metadata or timing records found")
    write_csv(root / "run_summary.csv", results)
    groups = []
    keys = ("condition", "ram_gib", "core_method", "source", "schedule", "duration_s", "period_ms", "deadline_ms", "binary_sha256", "input_sha256")
    def group_key(row):
        return tuple(str(row.get(k, "")) for k in keys)
    for key in sorted({group_key(r) for r in results}):
        all_runs = [r for r in results if group_key(r) == key]
        good = [r for r in all_runs if r["run_status"] == "complete"]
        group = {**dict(zip(keys, key)), "runs_total": len(all_runs),
                 "runs_valid": len(good), "runs_failed_or_unverified": len(all_runs) - len(good)}
        if good:
            rates = [r["deadline_miss_pct"] for r in good]
            group.update(deadline_miss_pct_mean=statistics.mean(rates),
                         deadline_miss_pct_sd=statistics.stdev(rates) if len(rates) > 1 else None)
            for field in ("response_median_ms", "response_p99_ms", "max_acquisition_gap_ms",
                          "max_observed_lateness_ms", "longest_miss_streak"):
                values = [r[field] for r in good if r[field] is not None]
                group[f"mean_run_{field}"] = statistics.mean(values) if values else None
                group[f"max_run_{field}"] = max(values, default=None)
        groups.append(group)
    write_csv(root / "condition_summary.csv", groups)
    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("results", type=Path)
    args = parser.parse_args()
    print(f"Summarized {len(analyze(args.results.resolve()))} runs; failed runs remain in run_summary.csv")
