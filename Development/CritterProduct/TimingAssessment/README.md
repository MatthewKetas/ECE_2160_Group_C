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
| Cores | 4, 3, 2, 1 online cores | Boot with maxcpus=3/2/1; other CPUs stay offline for that boot |
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

Each repetition block shuffles the ten four-core/native-RAM conditions using a
recorded seed. Reduced core counts are separate boot blocks in 3 -> 2 -> 1 order,
followed by a return to four cores and the RAM blocks in 4 -> 2 -> 1.5 GiB order.
Do not describe the entire campaign as fully randomized. Three 60-second
runs per condition give 600 scheduled slots/run and 1,800 slots/condition.
There are 30 four-core/native-RAM runs, 9 reduced-core/native-RAM runs, and
9 reduced-RAM runs: 48 runs and 48 minutes of collection. The unchanged 10-second settling and 5-second warmup add 12 minutes;
network completion adds approximately another minute. Allow roughly 90-110 minutes
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
to silently substitute a different governor. Governor/frequency settings are
restored after each run. The online mask must match --cores (default 4).
The collector never writes CPU hotplug controls: on the tested Pi, CPU3 failed
to restart after runtime offlining (kernel PSCI errors). Core counts are now
set at boot, with a reboot between counts. This preserves actual online-core
counts and avoids that failed restart path.

## Run the experiments from starting the Mac server

Start here if the Pi dependencies and executables were prepared using the steps
above. The commands below explicitly use three 60-second repetitions for the
main study. Run one block at a time and wait for it to finish. Stop if a block
reports an error. Machine labels tell you which terminal to use.

The only information you need to type is the Mac's local IP address and, for the
final transfer, your Pi's SSH login. The Pi saves the assessment directory so the
commands after reboots work from a fresh terminal without finding the clone again.

### 1. Mac terminal A start the network server

Paste this into a Mac terminal, even if its current directory is your home folder:

```sh
cd "/Users/matthewketas/Desktop/University of Pittsburgh/Senior Year/7th Semester/Embedded Systems/ECE_2160_Group_C"
assessment="$PWD/Development/CritterProduct/TimingAssessment"
"$assessment/tools/iperf3/bin/iperf3" --version
caffeinate -i "$assessment/tools/iperf3/bin/iperf3" -s
```

Wait for "Server listening on 5201". Leave this terminal running through the
native-RAM campaign. caffeinate prevents idle system sleep while the server runs.
Allow incoming connections if macOS asks.

This is the native arm64 iperf3 3.22 built locally after Intel/Rosetta Homebrew
passed incompatible westmere flags to the ARM compiler. It uses the cached
official source matching the cached Homebrew recipe's SHA-256, links only the
system library, and disables optional OpenSSL authentication. Reverse UDP was
checked locally. The ignored tools directory stays on the Mac; the Pi uses apt's
iperf3. No further Homebrew installation is needed for this step.

### 2. Mac terminal B find the Mac IP address

Open a second Mac terminal; keep terminal A running. Paste:

```sh
for critter_interface in en0 en1; do
    critter_address="$(ipconfig getifaddr "$critter_interface" 2>/dev/null)"
    if [ -n "$critter_address" ]; then
        printf '%s: %s\n' "$critter_interface" "$critter_address"
    fi
done
```

Note the IPv4 address for the connection shared with the Pi. If none appears,
find it in System Settings under the active Wi-Fi/Ethernet connection. Keep the
same interface throughout the study. The Pi needs TCP and UDP access to port
5201; campus client isolation may require a private LAN or direct Ethernet link.

### 3. Transfer the updated controller, then save the Pi project location

For this repair, copy the updated Python files and these instructions from the
Mac to the existing Pi clone. No C rebuild is needed. In Mac terminal B, paste
this block, enter your usual Pi SSH login when prompted, and press Enter:

```sh
printf 'Pi SSH login (username@hostname-or-IP): '
read -r critter_pi_login
```

Then paste in the same Mac terminal:

```sh
assessment="/Users/matthewketas/Desktop/University of Pittsburgh/Senior Year/7th Semester/Embedded Systems/ECE_2160_Group_C/Development/CritterProduct/TimingAssessment"
scp "$assessment/collect.py" "$assessment/analyze.py" "$assessment/README.md" \
  "${critter_pi_login}:/home/matthewketas/Documents/ECE_2160_Group_C/Development/CritterProduct/TimingAssessment/"
scp "$assessment/tests/test_workflow.py" \
  "${critter_pi_login}:/home/matthewketas/Documents/ECE_2160_Group_C/Development/CritterProduct/TimingAssessment/tests/"
```

Alternatively, transfer these same changes through your usual Git commit/push/pull
workflow. Do not run an older collector after updating the instructions.

Now in a **Pi terminal**, paste:

```sh
cd "$HOME/Documents/ECE_2160_Group_C"
assessment="$PWD/Development/CritterProduct/TimingAssessment"
mkdir -p "$HOME/.cache/critter-timing"
printf '%s\n' "$assessment" > "$HOME/.cache/critter-timing/assessment"
python3 "$assessment/collect.py" run --help
```

Confirm that help includes --cores. The updated version also contains the earlier
startup fix for the immediate "Operation not permitted" error.

If the failed campaign left CPU3 offline, **reboot once now** before continuing:

```sh
sudo reboot
```

After reboot, reconnect to the Pi and paste:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
cat /sys/devices/system/cpu/online
```

Expect 0-3. If it is still 0-2, stop and save doctor output; do not retry runtime
CPU onlining. A reboot is the recovery step, not a confirmed repair of the
underlying kernel/firmware issue.

Check the Pi configuration:

```sh
python3 "$assessment/collect.py" doctor
```

Confirm four online cores, native RAM near 8 GB, GNU time, iperf3, and the
performance/powersave/ondemand governors. If ondemand is missing, run the
modprobe command in the preparation section and check again before continuing.

If using SSH, start a persistent session with the following command, then proceed
in the terminal it opens. Skip this block when using the Pi's local terminal.

```sh
sudo apt install tmux
tmux new -s critter-timing
```

### 4. Pi terminal enter the Mac IP and check both traffic levels

Paste this block, then type the Mac's IP address when prompted and press Enter:

```sh
printf 'Mac IPv4 address: '
read -r critter_mac_ip
```

Then paste:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
printf '%s\n' "$critter_mac_ip" > "$HOME/.cache/critter-timing/mac-ip"
iperf3 -c "$critter_mac_ip" -u -R -b 10M -l 1200 -t 10
iperf3 -c "$critter_mac_ip" -u -R -b 50M -l 1200 -t 10
```

Both tests must connect. Inspect achieved receive throughput and packet loss;
requested throughput is not proof that rate arrived. Resolve connectivity or
unsupported rates before main collection. The collector subsequently starts,
stops, and records the traffic automatically. Do not start matrixmult manually.

### 5. Pi terminal check the baseline and four-core experiment controls

First retry the short baseline with the startup fix:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
sudo python3 "$assessment/collect.py" run \
  --ram 8 --family ram --repetitions 1 --duration 10 \
  --results "$assessment/results/smoke"
```

Expect "Saving 1 runs", a baseline condition, and "Collection complete". The
session's run_summary.csv should show complete and 100 scheduled cycles.

Now check the ten four-core/native-RAM conditions together:

```sh
critter_mac_ip="$(cat "$HOME/.cache/critter-timing/mac-ip")"
sudo python3 "$assessment/collect.py" run \
  --ram 8 --family all --network-host "$critter_mac_ip" \
  --repetitions 1 --duration 10 \
  --results "$assessment/results/smoke"
```

Allow approximately five minutes. This session should contain 10 complete runs,
each with 100 scheduled cycles. Check effective masks/niceness, governor records,
matrix coverage, and achieved network throughput in its saved records. Failed
runs remain visible and stop the session. Nonzero deadline misses are outcomes;
do not repeat a run solely to obtain a preferred miss rate. Smoke data stays
separate from the main dataset.

### 6. Pi terminal collect the four-core native 8 GB campaign

Keep the Mac server running. Paste:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
critter_mac_ip="$(cat "$HOME/.cache/critter-timing/mac-ip")"
sudo python3 "$assessment/collect.py" run \
  --ram 8 --family all --network-host "$critter_mac_ip" \
  --repetitions 3 --duration 60 --source data --schedule periodic \
  --results "$assessment/results/main"
```

Wait for all 30 runs to finish, approximately 40 minutes including setup.
This covers the shared four-core baseline, powersave/ondemand, both traffic
levels, the pinned quiet control, and matrix competition at nice -10/0/10/19.
The reduced-core experiments come next, in separate boots.
Conditions are shuffled inside each repetition block.

Sudo controls hardware settings, but application/workload children run under
your ordinary Pi account. Keep cooling, peripherals, storage, and swap unchanged.
Avoid unrelated transfers and interaction during runs. Governor/frequency
settings are restored after each run; core counts stay fixed throughout a boot. The Mac server can remain running while
you complete the RAM blocks.

### 6a. Pi terminal set three cores and reboot

Continue only after the 30-run campaign completes. The boot helper backs up
cmdline.txt once and changes only maxcpus=. It preserves any mem= setting.

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
sudo python3 "$assessment/collect.py" cores 3 && sudo reboot
```

Reconnect after boot. Paste this block; the expected mask is 0-2:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
cat /sys/devices/system/cpu/online
sudo python3 "$assessment/collect.py" run \
  --ram 8 --cores 3 --family cores --repetitions 1 --duration 10 \
  --results "$assessment/results/smoke"
```

If the short check succeeds, collect the three measured runs (about four minutes):

```sh
sudo python3 "$assessment/collect.py" run \
  --ram 8 --cores 3 --family cores --repetitions 3 --duration 60 \
  --source data --schedule periodic --results "$assessment/results/main"
```

### 6b. Pi terminal set two cores, reboot, and collect

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
sudo python3 "$assessment/collect.py" cores 2 && sudo reboot
```

Reconnect after boot. The expected mask is 0-1:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
cat /sys/devices/system/cpu/online
sudo python3 "$assessment/collect.py" run \
  --ram 8 --cores 2 --family cores --repetitions 3 --duration 60 \
  --source data --schedule periodic --results "$assessment/results/main"
```

### 6c. Pi terminal set one core, reboot, and collect

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
sudo python3 "$assessment/collect.py" cores 1 && sudo reboot
```

Reconnect after boot. The expected mask is 0:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
cat /sys/devices/system/cpu/online
sudo python3 "$assessment/collect.py" run \
  --ram 8 --cores 1 --family cores --repetitions 3 --duration 60 \
  --source data --schedule periodic --results "$assessment/results/main"
```

### 6d. Pi terminal restore four cores and reboot

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
sudo python3 "$assessment/collect.py" cores 4 && sudo reboot
```

Reconnect after boot and verify the mask is 0-3:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
cat /sys/devices/system/cpu/online
```

Keep four cores online for all remaining RAM experiments. The first helper's
backup remains untouched across both the core and RAM sweeps.

### 7. Pi terminal set 4 GiB and reboot

Continue only after the four-core and reduced-core native-RAM campaigns complete
and four cores have been restored. The RAM helper
backs up the boot command line and changes only its mem= limit. Have physical
SD-card access available for recovery before beginning this sweep.

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
sudo python3 "$assessment/collect.py" ram 4 && sudo reboot
```

Wait for the Pi to boot, then reconnect/open a new Pi terminal.
A reboot ends tmux sessions too. The next block works from your home folder.

### 8. Pi terminal collect 4 GiB

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
python3 "$assessment/collect.py" doctor
sudo python3 "$assessment/collect.py" run \
  --ram 4 --family ram --repetitions 3 --duration 60 \
  --source data --schedule periodic \
  --results "$assessment/results/main"
```

Expect three runs, approximately four minutes. The collector checks the boot
argument and actual MemTotal before collecting. MemTotal is slightly below the
nominal cap because some memory is reserved. The cap reduces kernel-managed
memory; it does not emulate different DRAM hardware or bandwidth.

After successful completion, paste the next block:

```sh
sudo python3 "$assessment/collect.py" ram 2 && sudo reboot
```

Wait for reboot, then reconnect/open a new Pi terminal.

### 9. Pi terminal collect 2 GiB

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
python3 "$assessment/collect.py" doctor
sudo python3 "$assessment/collect.py" run \
  --ram 2 --family ram --repetitions 3 --duration 60 \
  --source data --schedule periodic \
  --results "$assessment/results/main"
```

After all three runs finish successfully:

```sh
sudo python3 "$assessment/collect.py" ram 1.5 && sudo reboot
```

Wait for reboot, then reconnect/open a new Pi terminal.

### 10. Pi terminal collect 1.5 GiB

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
python3 "$assessment/collect.py" doctor
sudo python3 "$assessment/collect.py" run \
  --ram 1.5 --family ram --repetitions 3 --duration 60 \
  --source data --schedule periodic \
  --results "$assessment/results/main"
```

After all three runs finish successfully, restore the original boot configuration:

```sh
sudo python3 "$assessment/collect.py" ram restore && sudo reboot
```

Wait for reboot, then reconnect/open a new Pi terminal. Runtime cleanup alone
does not remove boot core/RAM caps; this final restoration and reboot are required.

### 11. Pi terminal summarize and archive

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
python3 "$assessment/collect.py" doctor
python3 "$assessment/analyze.py" "$assessment/results/main"
```

Check the combined main-run statuses:

```sh
python3 - "$assessment/results/main/run_summary.csv" <<'PY'
import csv
from collections import Counter
import sys

with open(sys.argv[1], newline="") as file:
    rows = list(csv.DictReader(file))
print("Main run statuses:", dict(Counter(row["run_status"] for row in rows)))
for row in rows:
    if row["run_status"] != "complete":
        print(row["condition"], row["run_status"], row["error"])
PY
```

A single clean campaign has 48 complete main runs: 30 four-core/native-RAM
runs, nine reduced-core/native-RAM runs, and nine reduced-RAM runs. Retain any failed attempts rather than deleting them to force
this count. Short checks are in the separate smoke directory. The campaign
contains 48 measured minutes; allow roughly 90-110 minutes overall for the checks,
setup, network completion, and core/RAM reboots.

Create the archive, including both main data and short-check records:

```sh
tar -czf "$HOME/critter-timing-results.tar.gz" -C "$assessment" results
ls -lh "$HOME/critter-timing-results.tar.gz"
```

Each run contains timing.csv, samples.csv, experiment.json, metadata.json,
time.txt, telemetry.jsonl, and stdout/stderr logs. Network runs include iperf3
JSON in network.stdout; priority runs include supervisor results in matrix.stdout.
Each session has plan.json, original_state.json, environment.json, source and
build snapshots/hashes, and summaries.

run_summary.csv retains every run, including failures. condition_summary.csv
summarizes whole-run repetitions without pooling different sources, schedules,
durations, periods/deadlines, core-setting methods, or binary/input hashes.
Older records without core_method are labeled legacy and kept separate. mean_run_response_p99_ms is
a mean of run-level p99s, not a pooled p99. Telemetry polls roughly once a second
and can miss brief transitions. No observed maximum establishes a hard bound.

### 12. Mac terminal B copy the archive back

Use the same Pi username and hostname/IP that you use for SSH. Run this block,
type that login when prompted (for example, yourname@raspberrypi.local), and press Enter:

```sh
printf 'Pi SSH login (username@hostname-or-IP): '
read -r critter_pi_login
```

Then paste:

```sh
scp "${critter_pi_login}:critter-timing-results.tar.gz" "$HOME/Downloads/"
```

The archive is now in Downloads. Raw results are ignored by Git, so a git push
alone does not transfer them. Keep the archive with your report materials.
You can stop Mac terminal A's server with Control-C.

### Recovery if a run or reboot fails

If a CPU condition reports "Invalid argument" or a restoration failure, retain
the failed run and inspect the original error before retrying the full campaign.
The collector identifies rejected control paths/values, skips settings already
at their requested value, and preserves the run error alongside any cleanup
error. A restoration failure does not by itself identify the original cause.
This read-only diagnostic finds the newest failed record and shows the current
online-core mask:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
python3 - "$assessment/results" <<'PY'
import json
from pathlib import Path
import sys

failed = []
for path in Path(sys.argv[1]).rglob("metadata.json"):
    data = json.loads(path.read_text())
    if data.get("status") == "failed":
        failed.append((path.stat().st_mtime_ns, path, data))
if failed:
    _, path, data = max(failed, key=lambda item: item[0])
    print("Failed record:", path)
    for key in ("condition", "error", "restoration_error", "configured"):
        print(key + ":", data.get(key))
else:
    print("No failed metadata record found.")
print("Currently online:", Path("/sys/devices/system/cpu/online").read_text().strip())
PY
sudo dmesg | tail -40
```

Save that output before rebooting if an older collector left a core offline.
The observed PSCI CPU3 boot failure requires a reboot for recovery. The updated
collector never writes cpuN/online and refuses an unexpected online mask.
Reduced-core runs must have both the matching mask and maxcpus= boot argument.
A governor mismatch after this fix includes its policy path and observed value;
save the failed metadata instead of skipping the governor check.

Ctrl-C/SIGTERM stops owned child groups and restores governor/frequency settings.
SIGKILL or power loss cannot run cleanup. Use a session's original_state.json
with the collector's restore command if governor/frequency settings need recovery
within the same core-count boot. It does not attempt CPU hotplug:

```sh
assessment="$(cat "$HOME/.cache/critter-timing/assessment")"
printf 'Full path to the session original_state.json: '
read -r critter_state
```

After entering the path, run:

```sh
sudo python3 "$assessment/collect.py" restore "$critter_state"
```

The normal boot file is /boot/firmware/cmdline.txt (older layouts may use
/boot/cmdline.txt). If a core/RAM-limited boot fails, mount the boot partition on the
Mac and restore cmdline.txt from cmdline.txt.critter-timing.original, then boot
again. Do not change swap settings between RAM blocks.

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
that ranking. Keep failed trials and core/RAM boot-block/time-order limitations
visible when explaining conclusions.

## Method references

- Course matrix example: http://www.bigrigg.com/ece1175/matrixmult.c (source supplied by user)
- GNU time: https://www.gnu.org/software/time/manual/time.html
- Linux clocks and absolute sleeping: https://man7.org/linux/man-pages/man2/clock_nanosleep.2.html
- Linux scheduling, niceness, and autogroups: https://man7.org/linux/man-pages/man7/sched.7.html
- Linux CPU frequency policies/governors: https://www.kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html
- Linux core boot limits: https://www.kernel.org/doc/html/latest/core-api/cpu_hotplug.html (maxcpus=)
- Linux boot memory limit: https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html (mem=)
- iperf3 options: https://software.es.net/iperf/invoking.html
