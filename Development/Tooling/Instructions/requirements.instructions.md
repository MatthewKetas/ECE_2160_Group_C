# Critter Product Requirements

## Purpose

The Critter is an embedded monitoring system intended to collect environmental temperature data from a single machine room, reduce and summarize that data for later analysis, and evaluate the processed data to provide insight into HVAC behavior.

The software shall be divided into three primary functional modules:

1. I/O module
2. Memory module
3. Computation module

Each module should exhibit a different type of program behavior so system CPU, memory, I/O, and timing characteristics can be evaluated independently.

---

# 1. I/O Module

## Purpose

The I/O module is responsible for acquiring temperature measurements at a configurable high sampling rate.

The module should focus primarily on frequent hardware or data-source interaction rather than significant data processing.

## Temperature Source Priority

Temperature acquisition shall use the following priority:

```text
Sense HAT
    │
    │ unavailable or read failure
    ▼
Stored / Provided Data
    │
    │ unavailable
    ▼
Raspberry Pi CPU Temperature
```

### Primary Source — Sense HAT

The preferred temperature source shall be the reusable Sense HAT utility.

The I/O module shall use the Sense HAT utility interface rather than directly accessing Sense HAT I²C registers.

The Sense HAT source should also support collection of:

- Temperature
- Relative humidity
- Atmospheric pressure

Temperature is required. Humidity and pressure may be retained when available for later HVAC analysis.

### Secondary Source — Data

A separate data-source function shall support reading temperature samples from supplied or previously generated data.

This source may be used when:

- Sense HAT hardware is unavailable.
- Sense HAT initialization fails.
- A sensor read fails.
- The system is being tested without physical hardware.
- Repeatable input is required for testing.

The data source shall not be embedded directly into the Sense HAT implementation.

Input data paths or files shall be configurable and shall not depend on machine-specific absolute paths.

### Final Fallback — CPU Temperature

If neither the Sense HAT nor a valid data source is available, the system shall obtain temperature from the Raspberry Pi internal CPU temperature sensor.

CPU temperature is a fallback measurement and shall not be treated as equivalent to ambient room temperature.

## Sample Identification

Every acquired sample shall identify its source.

Recommended source identifiers include:

```c
TEMPERATURE_SOURCE_SENSE_HAT
TEMPERATURE_SOURCE_DATA
TEMPERATURE_SOURCE_CPU
```

A sample should contain at minimum:

```text
timestamp
temperature
source
```

When available, it may also contain:

```text
humidity
pressure
```

## Sampling

The sampling frequency shall be configurable.

The I/O module shall:

- Support continuous acquisition.
- Avoid unnecessary processing in the acquisition path.
- Timestamp samples as close as practical to acquisition.
- Detect and report failed reads.
- Prevent a single sensor failure from terminating the application.
- Pass valid samples to the memory module.

---

# 2. Memory Module

## Purpose

The memory module is responsible for managing the high-rate data produced by the I/O module.

Its primary goal is to reduce the quantity of data that must be retained while preserving information useful for offline analysis and HVAC evaluation.

The memory module should demonstrate memory-intensive and data-management behavior.

## Input Validation

Before processing a sample, the memory module shall validate that the sample is usable.

Validation should include:

- Valid timestamp
- Finite numeric temperature
- Valid sample source
- Humidity within a reasonable physical range when present
- Pressure represented as a valid numeric measurement when present

Invalid samples shall not be included in normal statistical summaries.

## Bounded Storage

The memory module shall use bounded storage.

Continuous monitoring shall not result in continuously increasing memory consumption.

The implementation should use a fixed-capacity buffer, rolling window, or equivalent bounded data structure.

When capacity is reached, the implementation shall intentionally:

- summarize,
- reduce,
- replace,
- or discard

older data according to the selected retention policy.

## Outlier Handling

Outlier detection shall be robust against individual extreme measurements.

Outlier detection should be based on a window of recent samples rather than a single comparison against the immediately previous value.

Preferred techniques include robust statistics such as:

```text
Median
Median Absolute Deviation (MAD)
```

or another justified method that provides similar resistance to extreme values.

Outliers shall not silently disappear.

The module shall maintain enough information to report:

```text
number of received samples
number of valid samples
number of rejected samples
number of detected outliers
```

When useful for offline investigation, outliers may be stored separately from the primary summarized data.

## Data Reduction

The memory module shall reduce high-rate samples into meaningful time windows.

For each completed window, the module should calculate at least:

```text
sample count
minimum temperature
maximum temperature
mean temperature
```

The following are strongly recommended:

```text
median temperature
standard deviation
temperature range
first timestamp
last timestamp
outlier count
```

When humidity and pressure are available, equivalent summary values should be retained where useful.

## Source Awareness

The memory module shall preserve information about where measurements originated.

A summary should make it possible to determine whether its samples originated from:

- Sense HAT
- input data
- CPU temperature fallback
- a combination of sources

This is particularly important because CPU temperature is not an ambient temperature measurement.

## Offline Analysis

Processed data shall be exportable in a format suitable for offline analysis.

Preferred formats include:

```text
JSON
CSV
```

The memory module should separate:

```text
acquisition
processing
storage/export
```

so that changing the output format does not require changing the acquisition logic.

## Thread Safety

If samples are produced and consumed by separate threads, shared data structures shall be protected against concurrent access.

The synchronization strategy should minimize the amount of work performed while locks are held.

---

# 3. Computation Module

## Purpose

The computation module shall evaluate processed temperature data to identify patterns and make predictions about HVAC behavior.

This module should exhibit significantly more computational activity than the I/O or memory modules.

It should operate primarily on summarized or processed data rather than directly consuming every raw sensor measurement.

## Analysis Inputs

The computation module may use:

```text
temperature history
temperature trend
temperature range
temperature variability
humidity
pressure
sample timing
historical summary windows
```

The module shall consider the source of the underlying temperature measurements when interpreting results.

## HVAC Analysis

The module should evaluate behavior useful for understanding HVAC operation.

At minimum, the analysis should determine:

- Whether temperature is rising, falling, or stable.
- The rate of temperature change.
- A predicted future temperature over a configurable prediction horizon.

The module should also support evaluating patterns such as:

- Repeated heating and cooling cycles.
- Unusually rapid temperature changes.
- Failure to maintain a stable temperature.
- Increasing or decreasing temperature trends.
- Changes in normal HVAC cycling behavior.

## Prediction

Initial prototypes should use a deterministic and explainable prediction method.

Suitable approaches include:

```text
linear regression
trend extrapolation
moving-window regression
cycle analysis
```

A prediction result should contain enough information to explain the result.

For example:

```text
current temperature
temperature trend
rate of change
predicted temperature
prediction horizon
analysis timestamp
```

More advanced prediction algorithms may be introduced in later iterations.

## Computational Behavior

Computational work should represent useful analysis rather than artificial busy-work.

Increasing computational demand should come from operations such as:

- Evaluating larger historical windows.
- Regression calculations.
- Statistical analysis.
- HVAC cycle detection.
- Comparing current behavior against historical behavior.
- Repeated prediction across the monitored room timeline.

---

# 4. Module Separation

The three major components shall remain logically independent.

The intended data flow is:

```text
             ┌─────────────────┐
             │    I/O Module   │
             │                 │
             │ Acquire Samples │
             └────────┬────────┘
                      │
                      ▼
             ┌─────────────────┐
             │  Memory Module  │
             │                 │
             │ Validate        │
             │ Remove Outliers │
             │ Summarize       │
             └────────┬────────┘
                      │
                      ▼
             ┌─────────────────┐
             │ Computation     │
             │ Module          │
             │                 │
             │ Analyze         │
             │ Predict         │
             └─────────────────┘
```

The I/O module shall not perform HVAC prediction.

The memory module shall not directly access sensor hardware.

The computation module shall not directly access sensor hardware.

Reusable hardware utilities shall remain outside the Critter-specific modules.

---

# 5. Prototype Behavior

Prototype implementations should make the different workload characteristics observable.

```text
Module          Primary Behavior
--------------  --------------------------------
I/O             Frequent sensor/data acquisition
Memory          Storage, filtering, and reduction
Computation     Statistical and predictive analysis
```

This separation should make it possible to measure and compare:

- CPU utilization
- Memory utilization
- Sampling frequency
- Execution time
- Data reduction
- Storage requirements
- Thread behavior

The architecture should permit each module to be modified or evaluated independently without requiring significant changes to the other modules.