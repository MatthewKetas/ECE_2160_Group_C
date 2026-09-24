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
./build/pi/Pilot &
python3 PowerAssessment/baseline_power/baseline_power.py
wait
