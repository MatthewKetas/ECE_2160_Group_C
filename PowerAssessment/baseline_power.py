#!/usr/bin/env python3
"""Record 60 seconds of Raspberry Pi 5 idle PMIC rail power."""

import csv
from datetime import datetime, timezone
from pathlib import Path
import re
import statistics
import subprocess
import sys
import time


DURATION_SECONDS = 60


def parse_readings(output):
    """Pair all 12 PMIC currents with voltages; ignore unpaired input voltages."""
    readings = {
        name: float(value)
        for name, value in re.findall(
            r"(\w+)\s+(?:current|volt)\(\d+\)=([0-9.]+)[AV]", output
        )
    }
    currents = sorted(name for name in readings if name.endswith("_A"))
    if len(currents) != 12:
        raise ValueError(f"Expected 12 PMIC current rails, received {len(currents)}.")
    rails = {}
    for name in currents:
        voltage = name[:-2] + "_V"
        if voltage not in readings:
            raise ValueError(f"Missing voltage reading: {voltage}")
        rails[name] = readings[name]
        rails[voltage] = readings[voltage]
    watts = sum(rails[name] * rails[name[:-2] + "_V"] for name in currents)
    return watts, rails


def main():
    results = Path(__file__).resolve().parent / "results"
    results.mkdir(exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S_%fZ")
    destination = results / f"baseline_idle_{stamp}.csv"
    rows = []
    print(f"Measuring idle PMIC power for {DURATION_SECONDS} seconds. Leave the Pi untouched.")
    start = time.monotonic()

    for i in range(DURATION_SECONDS):
        read_start = time.monotonic()
        output = subprocess.check_output(
            ["vcgencmd", "pmic_read_adc"], text=True, timeout=5
        )
        read_end = time.monotonic()
        watts, rails = parse_readings(output)
        if rows and set(rails) != set(rows[0]) - {
            "elapsed_seconds", "read_duration_seconds", "pmic_power_watts"
        }:
            raise ValueError("PMIC rail names changed during the measurement.")
        rows.append({
            "elapsed_seconds": read_end - start,
            "read_duration_seconds": read_end - read_start,
            "pmic_power_watts": watts,
            **rails,
        })
        # Sleep to an absolute schedule instead of adding command time each second.
        time.sleep(max(0, start + i + 1 - time.monotonic()))

    elapsed = time.monotonic() - start
    # Buffer readings in memory; write the CSV after the measurement interval.
    with destination.open("x", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)

    mean = statistics.mean(row["pmic_power_watts"] for row in rows)
    print(f"Average sampled PMIC rail power: {mean:.3f} W")
    print(f"Approximate energy over {elapsed:.2f} seconds: {mean * elapsed:.2f} J")
    print(f"Samples collected: {len(rows)}")
    print(f"Saved: {destination}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        sys.exit(f"Baseline measurement failed: {error}. No completed results saved.")
    except KeyboardInterrupt:
        sys.exit("Baseline interrupted. No completed results saved.")
