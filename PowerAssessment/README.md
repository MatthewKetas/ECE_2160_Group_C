# Idle power baseline

On the Raspberry Pi 5, stop Critter and close unnecessary applications. Keep
the desktop, monitor, keyboard, mouse, network, and cooling setup unchanged.
Let the Pi settle for a couple of minutes, then run from the repository root:

```sh
python3 PowerAssessment/baseline_power.py
```

The script takes approximately 60 seconds and reads `vcgencmd pmic_read_adc`
once per second. Python 3 and the Pi's `vcgencmd` are the only requirements.
It changes no hardware settings. Avoid interacting with the Pi while it runs.

Results are saved beside the script in `results/`, regardless of the terminal's
working directory. Names identify the baseline and include a UTC timestamp:

```text
results/baseline_idle_20260924T220000_123456Z.csv
```

Each CSV includes elapsed time, command duration, summed PMIC power in watts,
and the raw paired currents (`_A`, amperes) and voltages (`_V`, volts).
The terminal reports the sample mean and approximate energy. Energy is estimated
from sample mean power times elapsed duration, not a continuous energy-meter reading.
Repeat the command 10 times for 10 separate baseline runs. Analyze the 10 run
averages as repetitions; the 60 samples within a run are not 60 independent runs.

## Measurement overhead and limits

This is an idle baseline **with monitoring enabled**. Python and `vcgencmd`
consume power and can wake the CPU or affect its frequency. The script sleeps
between readings, avoids live progress output, and buffers the data in memory
until the measurement ends to reduce interference. Command duration is recorded
for diagnosis; it does not measure the logger's energy consumption.

Use the same monitoring method and sampling interval for subsequent experiments.
This improves comparability but does not guarantee that logger overhead cancels,
especially when clock speeds or core availability change. Do not subtract an
assumed logger power value.

An external input-power meter with suitable resolution and logging independent
of the Pi is preferable for total device power. Compare idle measurements with
the logger on and off using that meter to quantify monitoring overhead. Ensure
the meter supports the Pi's power supply and does not cause undervoltage.

PMIC rail power excludes some loads and conversion losses; it is not total
USB-C input power. Do not apply another board's calibration formula as though
it were measured here. See the assignment's
[RPi5-power reference](https://github.com/jfikar/RPi5-power).

## Local check (no Pi required)

```sh
python3 -m unittest discover -s PowerAssessment -p 'test_*.py'
```

## Running a program along with the power checker

From the repository root:

```sh
./build/pi/Pilot &
python3 PowerAssessment/baseline_power.py
wait
```

## Separate unit experiments

The power logger is unchanged. Run each experiment once and repeat manually;
no automatic batch, append, or master CSV is used.

### Build on the Pi

From the repository root:

```sh
sh PowerAssessment/build_units.sh
```

This builds `IO/IO`, `mem/Mem`, and `comp/Compute` within `PowerAssessment`.
It links the existing Pilot unit functions, without changing them. All three
use GCC, C11, and `-O0` (matching the unoptimized build settings found in the
existing Pilot CMake cache). Record the Pi's `gcc --version` with the experiment.
Keep compiler/version/flags constant when changing clocks or online cores.

The initially supplied executables were cross-compiled for 64-bit Linux ARM
using the Clang compiler bundled with [Zig 0.16.0](https://ziglang.org/download/),
targeting glibc 2.31, with C11 and `-O0`. Rebuild with the command above on the
Pi before collecting comparison data against the GCC-built original Pilot.
The cross-compiler is only a build tool; it is not needed on the Pi.

### I/O: one minute of normal acquisition and saving

```sh
./PowerAssessment/IO/IO &
python3 PowerAssessment/baseline_power.py
wait
```

`IO_main.c` reuses Pilot's 60-second loop, 100 ms pause, progress reporting,
sensor-read function, and sample-save function. It does not allocate the memory
unit or run predictions. The original unfinished I/O main never updated its
elapsed time or slept; those omissions are fixed. The final line reports the
number of samples from Sense HAT, file fallback, and CPU fallback. Check that
the source is consistent across configurations. Saved samples follow the
existing I/O module's paths (normally beside the executable under `Data/`).

### Memory: the same 600 samples every run

```sh
./PowerAssessment/mem/Mem &
python3 PowerAssessment/baseline_power.py
wait
```

`mem/memory_dataset.h` contains fixed synthetic temperatures: gradual warming,
small deterministic noise, and six injected hot/cold outliers. They are compiled
into the executable so no sensor reads or input-file parsing occur in this run.
Timestamps are fixed, 0.1 seconds apart, and the source is labeled DATA.

`Mem_main.c` initializes Pilot's 100-sample buffer, adds each of the 600 samples
once with a 100 ms post-processing pause, then builds one summary and frees the
buffer. It prints the outcome without saving samples or running computation.
Each invocation resets state. Expected results are 600 valid inputs, zero
invalid inputs, six outliers, and 100 retained samples. Outliers are counted
as valid inputs by the original memory API, but are not retained.

This is a paced, fixed-work replay. Unlike Pilot's time-limited loop, it always
finishes all 600 inputs, so runtime is slightly over 60 seconds and can increase
as the CPU slows down. The unchanged logger captures a 60-second window, not
necessarily the complete replay or final summary. Report its result as window
power/energy, not energy to process all 600 samples. This small 100-sample
working set should not be described as a proven memory-bandwidth stress test.

### Compute: one prediction only

Start the logger first so the brief compute run occurs within its window:

```sh
python3 PowerAssessment/baseline_power.py &
sleep 2
./PowerAssessment/comp/Compute
wait
```

`Compute_main.c` calls the real prediction function exactly once with Pilot's
30-second prediction horizon. Its fixed input in `comp/compute_input.h` is the
summary produced by the memory dataset above. There is no replay loop, sleep,
or memory processing inside the compute executable. Expected prediction:
25.732950 degrees C. The printed call timing includes clock overhead and is
limited by clock resolution; a zero timing does not mean zero energy use.

The one-second PMIC sampling cannot reliably resolve this short call. The
60-second trace mainly describes idle power plus process startup, printing,
and the brief prediction. A defensible conclusion is that this experiment
cannot resolve the single prediction's energy, not that computation consumes
no energy or cannot be measured using other instrumentation.

### Keep run labels clear

The unchanged logger still creates `results/baseline_idle_<timestamp>.csv`.
After each run, manually rename that specific file with `io_`, `memory_`, or
`compute_` in place of `baseline_idle_`, or move it into a clearly labeled
results folder. Leave other copies of Critter stopped during unit experiments.

### Check the fixed inputs without a one-minute wait

```sh
gcc -std=c11 -O0 -Wall -Wextra -I Development/CritterProduct/Pilot \
    PowerAssessment/test_unit_inputs.c \
    Development/CritterProduct/Pilot/Memory/critter_memory.c \
    Development/CritterProduct/Pilot/Computation/critter_computation.c \
    -lm -o /tmp/critter_test_unit_inputs
/tmp/critter_test_unit_inputs
```

This checks all dataset counts, the saved summary against the actual memory
functions, and the expected prediction. It is a correctness check, not a power run.
