# Critter timing data collection

This workflow measures how resource settings affect the timing of the existing
Critter acquisition, saving, filtering, and final prediction functions. Develop
and check it on macOS, commit the source, and build and collect on the Raspberry
Pi 5. Mac timings are development checks and must not become Pi experiment data.

The collector uses Python's standard library. The Pi additionally needs CMake, a
C compiler, GNU time, and iperf3. No Python packages are required.

## What is measured

One scheduled job acquires one temperature, calls the existing sample-save
function, and completes validation/outlier filtering. Its experimental period
and deadline are both 100 ms by default. These values are study assumptions based
on the prototype's nominal 10 Hz rate, not deadlines supplied by the instructor.
Prediction runs once after collection and has its duration recorded separately.

For slot k, release = start + k * period. Response = finish - release, including
late dispatch and blocking. A job succeeds on time if reading, saving, and
filtering succeed and finish <= release + deadline. A legitimate outlier rejection
does not count as a failed job. Failed operations are separately counted.

| Required measure | Definition in run_summary.csv |
|---|---|
| Deadline-miss percentage | Unsuccessful, late, or skipped slots / all scheduled slots * 100 |
| Median and p99 response | Median and nearest-rank p99 of finish minus scheduled release for attempted jobs |
| Maximum observed lateness | Largest max(0, response - deadline) for attempted jobs |
| Maximum acquisition gap | Largest gap between successful read completions, including collection start/end boundaries |
| Longest consecutive miss sequence | Maximum consecutive unsuccessful slots, also expressed as slots * period |

A skipped job has no response-time observation: it is counted as a miss and in
the miss sequence, but is not assigned a fabricated finite latency. Successful
read completion is a host timestamp, not a measurement of physical sensor age.
The boundary-inclusive gap is a coverage measure; the full trace allows plotting
ordinary inter-acquisition gaps separately. Acquisitions finishing after the
window are clipped to its end only for that coverage calculation.

Timing records are preallocated/touched before collection, buffered in RAM, and
written after collection. Per-sample CSV saving remains inside the measured job.
Saving means the application's buffered write/close completed successfully;
there is no fsync, so this does not establish durable storage on the SD card.
GNU time covers setup, waiting, collection, final analysis, and trace export.
It is supporting resource evidence rather than an individual-deadline detector.

## Scheduling and input choices

CritterTiming is a separate executable; Pilot/main.c remains unchanged. The main
experiment uses an absolute monotonic schedule and never acquires early or
bursts to catch up. If work runs past future releases, those slots are recorded
as skipped. This makes all conditions use the same 10 Hz demand, without
oversampling. The original Pilot uses relative sleep after work and therefore
accumulates phase drift. Use --schedule relative for a separately labeled
comparison; do not call periodic results measurements of the unmodified Pilot.

The default source is a fixed 22.5 C CSV input. The existing data reader opens the
file and returns its first numeric temperature on each call; this is a constant,
repeatable input, not a sequential replay or an HVAC accuracy experiment. Memory
still fills its 100-sample ring and performs its existing repeated median/MAD
work. This small working set may show little sensitivity to RAM capacity.

--source cpu uses CPU-temperature reads with no data fallback. It couples stress
to the input temperature and is less suitable for isolating resource effects.
--source sense_hat uses the full Pilot environmental acquisition and rejects a
fallback source as an acquisition failure. Use a single source throughout each
main comparison. The Mac build deliberately substitutes an unavailable hardware
sensor; Linux always builds the real Sense HAT utility.

The only shared I/O changes are optional CRITTER_INPUT_FILE/CRITTER_OUTPUT_FILE
overrides to keep the fixture separate from generated samples, and checking
sample-write/close failures. Existing CRITTER_DATA_FILE behavior remains the
fallback when these new variables are absent.

## Experiment conditions

The shared baseline is native 8 GB RAM, four online cores, performance governor,
nice 0, no matrix competitor, and no generated network traffic. Critter is free
to use any online core except in the explicitly pinned priority comparison.

| Sweep | Conditions | Other settings |
|---|---|---|
| Cores | 4, 3, 2, 1 online cores | CPUs are actually offlined, not merely hidden from Critter |
| Governor | performance, powersave, ondemand | Same hardware min/max policy bounds for each governor |
| RAM | Native 8 GB, 4 GiB, 2 GiB, 1.5 GiB | Boot-time mem= limit; four cores, performance, quiet system |
| Network | Quiet, 10 Mbit/s receive, 50 Mbit/s receive | One UDP stream, 1200-byte payload, same physical interface |
| Priority | Pinned quiet control; matrix competition with Critter nice -10, 0, 10, 19 | Critter and one repeating matrix worker share CPU0; worker stays nice 0 |

The priority quiet control separates pinning from competition; nice 0 with the
worker separates competition from changed niceness. Matrix source was pasted by
the user from the course example. It is built with -O0 so the unused result does
not allow the compiler to remove the intended multiplication. The supervisor
repeats complete invocations, including their generation/process-start overhead,
and retains the original time-based random seed. This is a controlled competing
workload, not an added stage in Critter's HVAC algorithm.

Each repetition block shuffles native-RAM conditions using a recorded seed.
RAM conditions are separate boot blocks in the requested 8 -> 4 -> 2 -> 1.5
order; do not describe the entire campaign as fully randomized. Three 60-second
runs per condition give 600 scheduled slots/run and 1,800 slots/condition.
There are 39 native-RAM runs plus 9 reduced-RAM runs: 48 runs and 48 minutes of
collection. The unchanged 10-second settling and 5-second warmup add 12 minutes;
network completion adds approximately another minute. Allow roughly 75-90 minutes
overall for short checks, reboots, and manual steps, depending on the Pi's boot
time and any cooling breaks. All 16 conditions and all five metrics are retained.
The baseline supplies the 4-core, performance, quiet-network, native-RAM control.

The former seven-hour estimate came from five repetitions of five minutes per
condition, not from a hardware or instrumentation requirement. The shorter study
retains three separate repetitions and permits comparison of typical and tail
timing, but has less opportunity to observe rare stalls. Its p99 is based on about
six tail observations per full 600-attempt run, fewer when slots are skipped;
report that limitation and do not infer a guaranteed worst-case bound. Extend
only a selected condition if an unresolved result warrants more data.

## Prepare and check on the Mac

Run from the repository root. These paths work even if the clone's parent has spaces.

```sh
assessment=Development/CritterProduct/TimingAssessment
cmake -S "$assessment" -B "$assessment/build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build "$assessment/build" -j 4
ctest --test-dir "$assessment/build" --output-on-failure
python3 "$assessment/tests/test_workflow.py" --binary "$assessment/build/CritterTiming" --matrix "$assessment/build/matrixmult" -v
python3 "$assessment/collect.py" plan --ram 8 --family all
```

The configuration tests use temporary files; they do not change Mac CPU or boot
settings. Build directories/results are ignored. Review and commit the new
TimingAssessment directory and the shared I/O change before pushing. Preserve
any unrelated local changes. Build again on the Pi; do not copy Mac executables.

## Prepare the Pi

Pull the committed changes into your Pi clone and change to its repository root.
Use a stable power supply and the same cooling, desktop, storage, and peripherals
throughout collection. Keep the Pi awake and avoid interacting with it during runs.

```sh
sudo apt update
sudo apt install build-essential cmake python3 time iperf3
assessment=Development/CritterProduct/TimingAssessment
cmake -S "$assessment" -B "$assessment/build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build "$assessment/build" -j 4
ctest --test-dir "$assessment/build" --output-on-failure
python3 "$assessment/tests/test_workflow.py" --binary "$assessment/build/CritterTiming" --matrix "$assessment/build/matrixmult" -v
python3 "$assessment/collect.py" doctor
```

If the iperf3 installer asks to start an automatic server, choose No: the server
will run on the Mac. Doctor shows online CPUs, available governors, frequency
bounds, MemTotal, boot command line, swap, GNU time, and throttling information.
If ondemand is missing, try `sudo modprobe cpufreq_ondemand`, then run doctor
again. If still unavailable, stop and record that limitation; the runner refuses
to silently substitute a different governor. Runtime core/governor changes are
restored to the starting settings after each run. All four cores must be online
when collection starts.

## Start networking on the Mac

On this Mac, a native arm64 iperf3 3.22 executable was built locally after the
Intel/Rosetta Homebrew installation passed an incompatible westmere flag to the
ARM compiler. It uses the cached official source (matching the cached Homebrew
recipe's SHA-256), links only the system library, and disables optional OpenSSL
authentication. The ordinary unauthenticated UDP/TCP tests remain available.
The executable is ignored by Git and is only for the Mac; build/install the Pi's
iperf3 through apt as described above. From the repository root, start this copy:

```sh
assessment=Development/CritterProduct/TimingAssessment
"$assessment/tools/iperf3/bin/iperf3" --version
"$assessment/tools/iperf3/bin/iperf3" -s
```

On another Mac with a working Homebrew setup, install iperf3 if needed and start
the server in a separate terminal instead:

```sh
brew install iperf3
iperf3 -s
```

Find the Mac's local IP under its active network connection settings. Both
machines must be reachable over the chosen network; allow iperf3 through the Mac
firewall if prompted. The server uses TCP and UDP port 5201. A private LAN or
direct Ethernet connection avoids campus client-isolation restrictions.

Before the main study, test from the Pi (replace MAC_IP with the actual address):

```sh
iperf3 -c MAC_IP -u -R -b 10M -l 1200 -t 10
iperf3 -c MAC_IP -u -R -b 50M -l 1200 -t 10
```

Review achieved receive rate and loss. If 50 Mbit/s cannot be sustained, preserve
that observation and agree on a supported high condition before main collection;
do not label requested throughput as achieved throughput. During the actual
experiment the runner starts/stops traffic and saves the full iperf3 JSON.
Its receive-side loss, jitter, and throughput describe the network stream;
Critter's timing metrics come from timing.csv. Avoid unrelated transfers, public
speed-test servers, loopback traffic, or changes between Wi-Fi and Ethernet.

## First run a short Pi check

Start with an ordinary Pi user account. Sudo gives the controller permission to
change settings; Critter, GNU time, iperf3, and the matrix supervisor run back as
that ordinary user. Negative niceness is applied before dropping privileges.
Children share a session/autogroup and have separate process groups for cleanup.

```sh
sudo python3 "$assessment/collect.py" run --ram 8 --family ram --repetitions 1 --duration 10 --results "$assessment/results/smoke"
```

Check that metadata.json says complete, time.txt exists, and run_summary.csv has
100 scheduled cycles. Deadline misses may be zero or nonzero; they are outcomes,
not grounds to rerun until a preferred result appears.

Then check each control with short runs before committing to the long campaign:

```sh
sudo python3 "$assessment/collect.py" run --ram 8 --family cores --repetitions 1 --duration 10 --results "$assessment/results/smoke"
sudo python3 "$assessment/collect.py" run --ram 8 --family governor --repetitions 1 --duration 10 --results "$assessment/results/smoke"
sudo python3 "$assessment/collect.py" run --ram 8 --family priority --repetitions 1 --duration 10 --results "$assessment/results/smoke"
sudo python3 "$assessment/collect.py" run --ram 8 --family network --network-host MAC_IP --repetitions 1 --duration 10 --results "$assessment/results/smoke"
```

Check effective masks/niceness, governor records, continuous matrix coverage,
and achieved network throughput. Failed runs remain visible and stop the
session; correct the cause before collecting another labeled session.

## Collect the main native-RAM campaign

Use a persistent terminal session on the Pi if collecting over SSH. Leave the
Mac awake with its iperf3 server running. Reassign assessment after opening a new shell.

```sh
sudo python3 "$assessment/collect.py" run --ram 8 --family all --network-host MAC_IP --results "$assessment/results/main"
```

This performs all 39 native-RAM runs in three shuffled repetition blocks. The
collector prints the current condition and creates a timestamped session folder.
It also accepts --family cores, governor, network, priority, or ram when splitting
the campaign across sessions; those sessions each include their own baseline.

## Collect the reduced-RAM blocks

The RAM helper backs up cmdline.txt once, preserves its other boot parameters,
and sets exactly one mem= argument. It never reboots automatically. This reduces
kernel-managed RAM; it does not emulate different DRAM bandwidth or hardware.
The collector checks both the boot argument and actual MemTotal after reboot.
MemTotal will be below the nominal cap because the system reserves some memory.
Swap remains unchanged and is recorded; do not change swap between these blocks.

Run these steps in order, reconnecting and returning to the repository after each reboot:

```sh
sudo python3 "$assessment/collect.py" ram 4
sudo reboot
```

```sh
assessment=Development/CritterProduct/TimingAssessment
python3 "$assessment/collect.py" doctor
sudo python3 "$assessment/collect.py" run --ram 4 --family ram --results "$assessment/results/main"
sudo python3 "$assessment/collect.py" ram 2
sudo reboot
```

```sh
assessment=Development/CritterProduct/TimingAssessment
python3 "$assessment/collect.py" doctor
sudo python3 "$assessment/collect.py" run --ram 2 --family ram --results "$assessment/results/main"
sudo python3 "$assessment/collect.py" ram 1.5
sudo reboot
```

```sh
assessment=Development/CritterProduct/TimingAssessment
python3 "$assessment/collect.py" doctor
sudo python3 "$assessment/collect.py" run --ram 1.5 --family ram --results "$assessment/results/main"
sudo python3 "$assessment/collect.py" ram restore
sudo reboot
```

Restoring returns the original boot command line. The default Pi OS location is
/boot/firmware/cmdline.txt, with /boot/cmdline.txt supported on older layouts.
An explicit --cmdline path is available for a nonstandard configuration. If a
RAM-limited boot fails, mount the boot partition on the Mac and restore the saved
cmdline.txt.critter-timing.original before booting again. Have physical SD-card
access before starting the reboot sweep. For a temporal-drift check, collect a
further native-RAM baseline after restoration and report it as a closing control.

## Summarize and preserve the data

After all sessions, run on the Pi or on a copied results directory on the Mac:

```sh
python3 "$assessment/analyze.py" "$assessment/results/main"
tar -czf critter-timing-results.tar.gz -C "$assessment/results" main
```

Copy the archive back to the Mac with your usual file transfer. Keep the raw
data archive with the report materials; ignored results do not travel in git.

Each run contains timing.csv, samples.csv, experiment.json, metadata.json,
time.txt, telemetry.jsonl, and stdout/stderr logs. Network runs additionally have
the iperf3 JSON in network.stdout; priority runs have matrix supervision results
in matrix.stdout. Each session includes plan.json, original_state.json,
environment.json, source_snapshot.tar.gz, source/binary/input hashes, compiler
and build information, and summaries. Telemetry polls roughly once per second
and is buffered until the run ends: it can miss short transitions. The polling
and traffic generator are part of the measured environment in every applicable
condition and cannot establish a zero-overhead observation.

run_summary.csv preserves every run, including failures and missing traces.
condition_summary.csv reports valid run counts and summaries across whole runs;
individual cycles are not treated as independent experiment repetitions. It
does not pool different sources, schedules, durations, periods/deadlines, or
binary/input hashes. Its mean_run_response_p99_ms is the mean of run-level p99s,
not a pooled p99. No observed maximum is a guaranteed worst-case bound.

Ctrl-C or SIGTERM stops owned child process groups and restores CPU settings.
SIGKILL/power loss cannot run cleanup. If needed, use the saved state:

```sh
sudo python3 "$assessment/collect.py" restore /absolute/path/to/session/original_state.json
```

Runtime cleanup does not remove a boot RAM cap; use ram restore and reboot.

## Use the evidence in the paper

Plot each condition's miss percentage and tail response together, then compare
maximum gaps and miss sequences to show severity. Use stage timing, CPU time,
faults/context switches, memory pressure, actual frequency/temperature, and
network throughput to explain supported mechanisms. A zero-miss result for
this workload is useful evidence, not proof of a hard bound. A negligible RAM
effect is plausible when the working set fits comfortably even at 1.5 GiB.

Connect acquisition gaps to potentially missed room-temperature excursions and
to the changing time span represented by a fixed 100-sample history. Keep
prediction accuracy and physical sensor freshness outside the claims of the
fixed-input timing experiment. Discuss the sequential pipeline: file I/O and
filtering delay the next acquisition, while the final predictor is not competing
inside the periodic acquisition loop. Rank the largest measured impact only
among the defined treatment levels, since unequal stress severity can change
that ranking. Keep failed trials and RAM boot-block/time-order limitations
visible when explaining conclusions.

## Method references

- Course matrix example: http://www.bigrigg.com/ece1175/matrixmult.c (source supplied by user)
- GNU time: https://www.gnu.org/software/time/manual/time.html
- Linux clocks and absolute sleeping: https://man7.org/linux/man-pages/man2/clock_nanosleep.2.html
- Linux scheduling, niceness, and autogroups: https://man7.org/linux/man-pages/man7/sched.7.html
- Linux CPU frequency policies/governors: https://www.kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html
- Linux boot memory limit: https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html (mem=)
- iperf3 options: https://software.es.net/iperf/invoking.html
