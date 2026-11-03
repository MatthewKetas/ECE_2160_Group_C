# Critter memory assessment

This is an unattended, bounded memory experiment for the Raspberry Pi 5 running
64-bit Linux. Develop and validate on macOS; build and collect evidence again on
the Pi. Mac checks use Clang, a sensor stub, and a Mac executable-path adapter.
They are marked development-only and cannot become Pi measurement data.

The controller uses Python's standard library. Production Pilot and Sense HAT
sources are never edited. Each build uses a copied source tree, with a saved patch,
configuration, compiler commands, and hashes. The generated input fixture is kept
separate from output CSV files, and existing Pilot data files are never used.

## Transfer and prepare

Transfer the repository including this entire MemoryAssessment directory, the
Pilot directory, and Utils/SenseHat. If using Git, include these new source files
in your commit before pulling on the Pi; untracked files do not transfer through
Git. Generated measurements are intentionally ignored and must be copied back
separately after collection.

On the Pi, open a terminal in the repository root. For the existing clone:

```sh
cd ~/Documents/ECE_2160_Group_C
sudo apt-get install -y build-essential python3 time binutils coreutils
python3 -m unittest discover -s Development/CritterProduct/MemoryAssessment/tests -v
sudo python3 Development/CritterProduct/MemoryAssessment/campaign.py pi-check --minutes 10
```

The Pi check builds supported variants and runs short correctness/workflow trials.
Its report has one screening repetition rather than three. Compiler rejection,
missing static libraries, and behavior-invalid Ofast are recorded rather than
silently replaced. A baseline/reference failure stops collection with an error.
Inspect the final status before the overnight run. Actual flag support is detected
by compiling the real program; GCC-specific and hardware options are not inferred
from Mac behavior. The runner checks the Pi 5 model, ARM64 architecture, and sudo.

Use the same stable power supply, cooling, desktop, peripherals, and background
work throughout collection. Keep the Pi awake. No display, CPU governor, CPU
hotplug, boot RAM, swap, or system-wide memory settings are changed by the runner.
The full campaign requires at least 2 GiB of free disk space before starting;
the short check requires 512 MiB. The requirement covers retained raw CSV outputs
and copied builds, rather than Critter's runtime RAM.

## Start the full unattended campaign with sudo

Run these commands on the Pi, from the repository root:

```sh
sudo -v
nohup sudo -n timeout --signal=TERM --kill-after=5s 7190s python3 "$PWD/Development/CritterProduct/MemoryAssessment/campaign.py" run --minutes 120 > "$PWD/critter-memory-campaign.log" 2>&1 < /dev/null &
```

Wait briefly and check that it started:

```sh
tail -n 15 critter-memory-campaign.log
```

You can then disconnect SSH. `nohup` keeps the launch independent of terminal
hangup, `sudo -n` prevents a later password prompt, and the external timeout adds a
watchdog below two hours. The controller also bounds every child process, stops
starting work ten minutes before its deadline, and kills the entire active child
process group when a command exceeds its allowance. The watchdog can interrupt
final reporting; completed raw runs remain saved for analysis.

For an attended foreground run, use:

```sh
sudo timeout --signal=TERM --kill-after=5s 7190s python3 Development/CritterProduct/MemoryAssessment/campaign.py run --minutes 120
```

Each launch creates a new UTC-stamped result directory under:

```text
Development/Metrics/MemoryAssessment/pi_/YYYYMMDDTHHMMSSZ/
```

The first log line prints its exact absolute path. Results are saved after each
trial, and `completion.json` records complete, budget_exhausted, interrupted, or
failed. A completed campaign can contain invalid, unavailable, or failed variants;
read `report.md` and the build outcomes before selecting any configuration.
The top result directory is returned to the invoking sudo user at normal cleanup.
A watchdog kill or power loss can leave root-owned files; rerun analysis with sudo.

## Inspect, resume, or transfer results

Set the exact result directory printed in your log:

```sh
critter_results="Development/Metrics/MemoryAssessment/pi_/REPLACE_WITH_TIMESTAMP"
cat "$critter_results/completion.json"
cat "$critter_results/report.md"
```

Use the real timestamp in place of REPLACE_WITH_TIMESTAMP. Regenerate the report
without rerunning measurements:

```sh
sudo python3 Development/CritterProduct/MemoryAssessment/campaign.py analyze --output "$critter_results"
```

To resume an interrupted collection, with unchanged code on the same Pi:

```sh
sudo timeout --signal=TERM --kill-after=5s 7190s python3 Development/CritterProduct/MemoryAssessment/campaign.py run --minutes 120 --resume --output "$critter_results"
```

Resuming starts a new separately bounded session. Completed slots, including
recorded failures, are preserved. Unfinished attempts are archived and retried.
A lock prevents simultaneous writers, and changed source hashes prevent mixing
experiments. Do not move the result tree until collection/resumption is finished:
linked libraries and recorded build paths use its original absolute location.
Archive the entire timestamped directory and copy it back to the Mac, rather than
copying only the report. The raw records are required to audit interpretations.

## Campaign and research questions

`python3 campaign.py plan` prints the 29 screening configurations:

| Family | Configurations and reason |
|---|---|
| GCC groups (7) | O0, O1, O2, O3, Ofast, Os, Oz: compare speed/size policies |
| Individual transformations (8) | O2 plus unrolling, loop vectorization disabled, SLP vectorization disabled, inlining disabled, LTO, per-function/data sections with linker garbage collection, stack reuse disabled, or symbol stripping |
| Processor (2) | O2 plus mtune=cortex-a76 or mcpu=cortex-a76 |
| Linking/loading (3) | Shared Critter library, prediction loaded on demand, fully static system linking when available |
| Storage (4) | Reusable workspace, one partitioned allocation, static ring/workspace, fewer simultaneous path buffers |
| Layout (2) | Short enums; explicitly packed internal ring record with field-by-field copying |
| State lifetime (1) | Explicit caller-owned I/O context replacing persistent sensor/data state |
| History (2) | 50- and 25-record rings, compared with capacity-specific O0 references |

All individual changes use O2 as the common comparison. The complete effective
GCC option sets are recorded for group levels. An already-active transformation
is not an additional optimization. Stack reuse normally defaults to all; disabling
it is the comparison. Packed storage is confined to the internal ring, preserving
public sample and system-library structures. A short-enum build compiles all
Critter and sensor objects consistently and must not be mixed with other variants.

Static storage removes these explicit heap allocations by reserving arrays in
static data. It supports one memory instance and does not imply lower total RAM.
The explicit I/O context moves state to a caller-owned lifetime; no reduction is
assumed. Reduced history is a product tradeoff, not a behavior-preserving change.
A fixed single-allocation arena reserves exactly capacity*(record bytes+double
bytes), checks multiplication overflow, and rejects a smaller explicit budget.

Three screening repetitions shuffle variant/unit order using a recorded seed.
All four standalone executables use the actual Pilot unit functions, linked from
an archive or shared object. Unused units are not pulled from the baseline archive.
The integrated harness runs the sequential pipeline. Computational load is the
existing small rule-based predictor, not an invented intensive forecasting model.

The unoptimized reference calibrates a fixed amount of work per unit to roughly
1–2 seconds, subject to a conservative work cap. Every variant of that unit then
gets the same count, with an eight-second command limit. Memory and pipeline jobs
fill and wrap the ring. The data-file reader returns its first numeric value each
time; the harness then adds a deterministic triangular ramp and periodic outliers.
Timestamps represent 10 Hz synthetic demand during accelerated replay. This is
not sequential file replay or physical sensor timing. Prediction repeatedly
consumes varying summaries and emits a checked checksum to keep work observable.
Input/output bytes and summary decisions are checked against O0 references.

Build validation separately tests invalid timestamps, NaN/infinite temperatures,
bad source identity, humidity/pressure bounds, and nonfinite prediction horizons.
Invalid builds are retained but excluded from screening. Output checks cover
counts, outliers, summaries, predictions, HVAC decisions, and saved sample rows.
This is regression evidence for these inputs, not proof that pre-existing Pilot
behavior is correct for all HVAC conditions. The original fail-open outlier
allocation path is preserved and can be exposed by constrained-memory trials.

Diagnostic rebuilds instrument only the memory unit's explicit allocations.
They count allocation/free calls, requested peak bytes, and outstanding requested
bytes. They exclude allocator metadata, libc and loader allocations, stack, and
static storage. These counters are not part of primary RSS measurements.
Diagnostic phase holds permit external /proc snapshots without growing an
in-process telemetry buffer. Dynamic prediction records loaded and closed phases;
closing a library need not unmap it or reduce the process's historical peak RSS.

After screening, the runner tests stack limits and data limits on O2, reduced-path
buffers, and the arena. Limits apply only inside test executables after loader
startup, leaving the controller unrestricted. The stack sweep is existing limit,
1 MiB, 512, 256, 128, and 64 KiB. The data sweep is 4 MiB, 1 MiB, 512, 256, 128,
and 64 KiB. RLIMIT_DATA is broader than a heap cap. Explicit arena tests run at
its measured required capacity, one byte below, and zero. Failures remain evidence;
no passing threshold is presented as a safe worst-case bound.

One exploratory combined build uses the lowest observed pipeline-RSS compiler
group, LTO, section garbage collection, and one storage change. It is a candidate
bundle rather than evidence of independent/additive benefits. O2, two low-RSS
screening candidates, and that combined build get two 600-sample paced pipeline
confirmations (approximately 60 seconds each). Ranking is descriptive, not a claim
of statistical significance; range overlaps are reported as no resolved RSS change.

## Timing and output interpretation

Aim for completion within 90–110 minutes, with a two-hour ceiling. Actual time can
be much shorter when fixed workloads and builds finish quickly. The pessimistic
screening allowance is 29*4*3*8 = 46.4 minutes. Builds/validation, diagnostics,
resource-limit trials, paced confirmations, and report generation use the rest.
Optional diagnostics stop early to preserve time for limits and confirmation.
Failures/timeouts can leave parts of the plan unmeasured; the report lists those
combinations. This runtime estimate excludes dependency installation and transfer.

- `report.md`: readable screening, allocation, limits, and build outcomes.
- `runs.csv`: per-run RSS/fault/CPU metrics and behavior/allocation fields.
- `builds.csv`: binary file/section sizes and compiler-reported stack frames.
- `phases.csv`: current RSS, proportional/private/shared memory, and virtual
  memory/stack/data snapshots at diagnostic phases, when Linux exposes them.
- `summary.json`: descriptive screening classifications.
- `events.jsonl`: incremental progress and failures, flushed after each event.
- `runs/*`: raw GNU time output, exact command, stdout/stderr, result JSON, saved
  application CSVs, and diagnostic memory snapshots when available.
- `builds/*`: source copies/patches, configurations, compile/link logs, .su stack
  reports, and ELF/symbol/size reports. Shared libraries are retained alongside
  executables, and shared-library sizes are not hidden from the file-size view.
- `environment.json`, compiler/target/effective-option logs, proc files, throttling
  readings, `workloads.json`: reproducibility context.

RSS is physical resident memory including shared pages, not unique ownership or
requested heap bytes. Zero/missing RSS is unavailable, not zero memory use.
Overlapping observed ranges are not proof of equality. A smaller executable may
leave RSS unchanged. A maximum reported stack frame is not the total call-stack
requirement. Stack or data limits do not by themselves shrink actual memory use.
No automatic result is a deployment recommendation.

## Mac development check

From the repository root:

```sh
python3 -m unittest discover -s Development/CritterProduct/MemoryAssessment/tests -v
python3 Development/CritterProduct/MemoryAssessment/campaign.py mac-check --minutes 30
```

Mac checks compile the portable variants, run real C workloads against the O0
reference, and exercise phase recording. They skip Linux-only options and use no
sudo. Unit integration tests also verify allocation counts and cleanup for the
original, workspace, arena, and static-storage implementations.

References for interpretation: [Linux resource limits](https://man7.org/linux/man-pages/man2/getrlimit.2.html),
[GNU time](https://man7.org/linux/man-pages/man1/time.1.html),
[Linux memory maps](https://man7.org/linux/man-pages/man5/proc_pid_smaps.5.html),
[GCC optimization options](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html),
[GCC code-generation options](https://gcc.gnu.org/onlinedocs/gcc/Code-Gen-Options.html),
[GCC AArch64 options](https://gcc.gnu.org/onlinedocs/gcc/AArch64-Options.html).
