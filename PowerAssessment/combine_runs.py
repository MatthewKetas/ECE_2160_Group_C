#!/usr/bin/env python3
"""Validate and combine PMIC runs; write inputs for build_master.mjs."""
import argparse
import csv
import json
import math
from pathlib import Path
import statistics


def summarize(rows, duration=60):
    times = [float(r['elapsed_seconds']) for r in rows]
    powers = [float(r['pmic_power_watts']) for r in rows]
    if len(rows) != 60 or not all(math.isfinite(x) for x in times + powers):
        raise ValueError('Expected 60 finite time and power samples')
    if not (0 <= times[0] < 1 and 59 <= times[-1] < duration):
        raise ValueError('Samples do not cover the expected 60-second schedule')
    if any(b <= a for a, b in zip(times, times[1:])) or min(powers) < 0:
        raise ValueError('Invalid timestamps or negative power')
    for row in rows:
        numeric = {k: float(v) for k, v in row.items()}
        if not all(math.isfinite(v) for v in numeric.values()):
            raise ValueError('Nonfinite source value')
        currents = [k for k in row if k.endswith('_A')]
        if len(currents) != 12:
            raise ValueError('Expected 12 current rails')
        rail_power = sum(numeric[k] * numeric[k[:-2] + '_V'] for k in currents)
        if not math.isclose(rail_power, numeric['pmic_power_watts'], abs_tol=1e-10):
            raise ValueError('Recorded power does not match summed rail power')
    return statistics.mean(powers), statistics.mean(powers) * duration


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--results', type=Path, default=Path(__file__).parent / 'results')
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / 'outputs/power_master')
    args = parser.parse_args()
    runs, samples, counts, headers = [], [], {}, None
    for source in sorted(args.results.rglob('*.csv')):
        with source.open(newline='') as stream:
            reader = csv.DictReader(stream)
            rows = list(reader)
            if headers is None:
                headers = reader.fieldnames
            if headers != reader.fieldnames:
                raise ValueError(f'{source}: inconsistent column schema')
        try:
            power, energy = summarize(rows)
        except ValueError as exc:
            raise ValueError(f'{source}: {exc}') from exc
        dataset = source.parent.relative_to(args.results).as_posix()
        counts[dataset] = counts.get(dataset, 0) + 1
        iteration = counts[dataset]
        first = len(samples) + 2
        samples.extend([[dataset, iteration, source.name] + [float(row[h]) for h in headers] for row in rows])
        runs.append(dict(dataset=dataset, iteration=iteration, source=source.relative_to(args.results).as_posix(),
                         n=len(rows), first=first, last=len(samples)+1, power=power, energy=energy))
    if not runs:
        raise ValueError('No source CSVs found')
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / 'combined.json').write_text(json.dumps(dict(headers=headers, runs=runs, samples=samples)))
    with (args.output / 'run_results.csv').open('w', newline='') as stream:
        writer = csv.writer(stream)
        writer.writerow(['dataset', 'iteration', 'mean_power_W', 'estimated_energy_J', 'nominal_duration_s', 'samples', 'source'])
        writer.writerows([r['dataset'], r['iteration'], r['power'], r['energy'], 60, r['n'], r['source']] for r in runs)
    print(f'Combined {len(runs)} runs, {len(counts)} datasets, {len(samples)} samples into {args.output}')


if __name__ == '__main__':
    main()
