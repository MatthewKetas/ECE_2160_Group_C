# Critter Pilot Program Summary

## Overview

This project is the Critter prototype for a Raspberry Pi 5 embedded monitoring system. The implementation follows the project architecture described in the workspace requirements: an I/O layer for environmental acquisition, a memory layer for bounded storage and reduction, and a computation layer for trend and HVAC-related analysis.

The prototype is intentionally focused on a single-room deployment model and uses the temperature source priority defined by the project:

1. Sense HAT
2. Saved data source
3. Raspberry Pi CPU temperature fallback

The system is designed to run as a short collection cycle, capture environmental readings, reduce and summarize the data, and produce a compact, explainable analysis of current conditions and likely HVAC behavior.

---

## Model and agent context

The model used for the work in this session was:

- MAI-Code-1.1-Flash

The project also includes a dedicated agent definition and instruction set used to guide development behavior. Relevant files include:

- [Development/Tooling/Agents/critter.agent.md](../Development/Tooling/Agents/critter.agent.md)
- [Development/Tooling/Instructions/requirements.instructions.md](../Development/Tooling/Instructions/requirements.instructions.md)
- [DEVELOPMENT.md](../DEVELOPMENT.md)
- [Resources/background.md](background.md)

These documents define the architectural rules for the project, including:

- three-module separation (I/O, Memory, Computation)
- source priority for temperature acquisition
- bounded memory usage
- outlier handling
- offline analysis preparation
- portable build expectations
- Raspberry Pi/Linux constraints
- the requirement to keep hardware utilities separate from Critter application logic

The agent was expected to preserve this architecture, avoid duplicating hardware access, keep modules independently testable, and prefer portable C + CMake-based implementation patterns.

---

## Function mapping used in the Pilot

This section maps the actual implementation logic to the architecture and execution flow used in the project.

### Top-level execution

- main
  - Initializes the fixed-size memory buffer with critter_memory_init(&memory, 10U).
  - Starts a monotonic clock using clock_gettime(CLOCK_MONOTONIC, &start_ts).
  - Runs a while loop until elapsed_s >= 60.0 seconds, collecting one sample per second with a staggered sleep based on sample_interval_s.
  - Calls critter_io_read_sample(&sample), critter_io_save_sample(&sample), and critter_memory_add_sample(&memory, &sample) inside the collection loop.
  - Tracks collection metrics such as read attempts, valid samples, rejected samples, outliers, and rate.
  - Calls critter_memory_build_summary(&memory, &summary), then critter_compute_analysis(&summary, prediction_horizon_s, &analysis).
  - Writes metrics via critter_io_save_metrics(&summary, &analysis, ...).
  - Frees the memory buffer before exit.
  - Implemented in [Development/CritterProduct/Pilot/main.c](../Development/CritterProduct/Pilot/main.c)

### I/O functions

- critter_io_get_temperature
  - Calls critter_io_get_temperature_from_source(..., TEMPERATURE_SOURCE_SENSE_HAT), then TEMPERATURE_SOURCE_DATA, then TEMPERATURE_SOURCE_CPU.
  - Returns the first source that succeeds.
  - Implements the project priority chain: Sense HAT -> data -> CPU.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- critter_io_get_temperature_from_source
  - Switches on critter_temperature_source_t and calls the source-specific function.
  - Handles TEMPERATURE_SOURCE_SENSE_HAT by calling critter_read_sense_hat_temperature, TEMPERATURE_SOURCE_DATA by calling critter_read_data_temperature, and TEMPERATURE_SOURCE_CPU by calling critter_read_cpu_temperature.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- critter_read_sense_hat_environment
  - Initializes the Sense HAT interface with sense_hat_environment_init(&sensor, "/dev/i2c-1", ...).
  - Calls sense_hat_environment_read(&sensor, &reading) to populate temperature, humidity, and pressure.
  - Resets the sensor state on read failure by calling sense_hat_environment_close(&sensor) and setting initialized = false.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- critter_read_data_temperature
  - Opens the CSV temperature file from the CRITTER_DATA_FILE environment variable or the default path.
  - Parses the first valid numeric temperature from the CSV, using sscanf(buffer, "%*[^,],%lf", &value).
  - Uses a static last_value to preserve a read result when the file is absent but a prior value exists.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- critter_read_cpu_temperature
  - Opens "/sys/class/thermal/thermal_zone0/temp".
  - Reads the raw millidegree value with fscanf(file, "%d", &raw_millicelsius) and converts it using raw_millicelsius / 1000.0.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- critter_io_read_sample
  - Calls critter_io_get_temperature(&temperature_c, &source).
  - If the selected source is Sense HAT, it calls critter_read_sense_hat_environment(&temperature_c, &humidity, &pressure) to fill humidity and pressure.
  - Stores the timestamp with time(NULL), the selected source, and the measurement values into a critter_sample_t.
  - Returns failure if the temperature cannot be read.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- critter_io_save_sample
  - Resolves the file path using CRITTER_DATA_FILE or critter_resolve_runtime_data_path().
  - Ensures the runtime Data directory exists with critter_ensure_runtime_data_directory().
  - Opens the CSV file in append mode and writes the header only on the first row.
  - Emits timestamp_s,temperature_c,humidity_percent,pressure_hpa,source,has_humidity,has_pressure.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- critter_io_save_metrics
  - Resolves a runtime metrics path and appends a CSV row with collection metrics and analysis results.
  - Writes reads_attempted, valid_samples, rejected_samples, outlier_count, sample_rate_hz, retained_ratio, summary_count, min/max/mean/median/stddev, source, and HVAC flags.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

### Memory functions

- critter_memory_init
  - Allocates memory->buffer using calloc(capacity, sizeof(critter_sample_t)).
  - Initializes the ring buffer metadata, including capacity, head, count, and counters.
  - Implemented in [Development/CritterProduct/Pilot/Memory/critter_memory.c](../Development/CritterProduct/Pilot/Memory/critter_memory.c)

- critter_is_valid_sample
  - Checks timestamp_s > 0 and finite values.
  - Validates the source is within the valid range of sensor sources.
  - Ensures humidity is between 0 and 100 if present and pressure is positive if present.
  - Implemented in [Development/CritterProduct/Pilot/Memory/critter_memory.c](../Development/CritterProduct/Pilot/Memory/critter_memory.c)

- critter_median
  - Sorts a local array of temperatures and returns the median value.
  - Used by the outlier detector and summary builder.
  - Implemented in [Development/CritterProduct/Pilot/Memory/critter_memory.c](../Development/CritterProduct/Pilot/Memory/critter_memory.c)

- critter_stddev
  - Computes population standard deviation over the temperature window.
  - Implemented in [Development/CritterProduct/Pilot/Memory/critter_memory.c](../Development/CritterProduct/Pilot/Memory/critter_memory.c)

- critter_detect_outlier
  - Creates a local temperature array from the current memory window.
  - Computes the median and median absolute deviation (MAD), then flags values whose deviation exceeds a threshold.
  - Returns 1 when the sample is treated as an outlier.
  - Implemented in [Development/CritterProduct/Pilot/Memory/critter_memory.c](../Development/CritterProduct/Pilot/Memory/critter_memory.c)

- critter_memory_add_sample
  - Increments total_received_samples.
  - Rejects invalid samples by incrementing total_rejected_samples.
  - Tracks total_valid_samples and total_outliers.
  - Adds non-outlier samples into the ring buffer with critter_add_in_ring.
  - Implemented in [Development/CritterProduct/Pilot/Memory/critter_memory.c](../Development/CritterProduct/Pilot/Memory/critter_memory.c)

- critter_memory_build_summary
  - Walks the ring buffer and computes min, max, mean, median, stddev, and timestamps.
  - Counts samples by source and calculates retained_ratio = count / total_received_samples.
  - Sets summary.source to UNKNOWN if the samples mixed sources.
  - Implemented in [Development/CritterProduct/Pilot/Memory/critter_memory.c](../Development/CritterProduct/Pilot/Memory/critter_memory.c)

### Computation functions

- critter_compute_analysis
  - Computes delta_t from summary.first_timestamp_s and summary.last_timestamp_s.
  - Calculates slope = (latest - mean) / delta_t and intercept = latest - slope * last_timestamp_s.
  - Builds predicted temperature as latest + slope * prediction_horizon_s.
  - Sets stable = fabs(slope) < 0.05 && stddev < 0.5.
  - Sets rising = slope > 0.02, falling = slope < -0.02.
  - Sets likely_hvac_active, likely_heating, and likely_cooling based on thresholds.
  - Implemented in [Development/CritterProduct/Pilot/Computation/critter_computation.c](../Development/CritterProduct/Pilot/Computation/critter_computation.c)

### Supporting utility functions

- critter_resolve_runtime_data_path
  - Uses readlink("/proc/self/exe", ...) to resolve the executable directory and then appends "/Data/temperature_samples.csv".
  - Writes the local runtime path without hardcoded host-specific absolute paths.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- critter_ensure_runtime_data_directory
  - Uses stat() on the resolved Data directory and creates it with mkdir() if absent.
  - Implemented in [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

- sense_hat_environment_init
  - Initializes the reusable Sense HAT utility interface.
  - Implemented in [Utils/SenseHat/sense_hat_environment.c](../Utils/SenseHat/sense_hat_environment.c)

- sense_hat_environment_read
  - Reads the raw sensor values and records temperature, humidity, and pressure.
  - Implemented in [Utils/SenseHat/sense_hat_environment.c](../Utils/SenseHat/sense_hat_environment.c)

- sense_hat_environment_close
  - Closes the Sense HAT device state and frees allocated resources.
  - Implemented in [Utils/SenseHat/sense_hat_environment.c](../Utils/SenseHat/sense_hat_environment.c)

---

## Architecture and responsibility split

### 1. I/O module

The I/O layer is responsible for acquiring environmental measurements and returning temperature values with source awareness. It also handles the local runtime storage pattern used by the Pilot.

Key files:

- [Development/CritterProduct/Pilot/IO/critter_io.h](../Development/CritterProduct/Pilot/IO/critter_io.h)
- [Development/CritterProduct/Pilot/IO/critter_io.c](../Development/CritterProduct/Pilot/IO/critter_io.c)

Responsibilities:

- read the temperature using the highest-priority available source
- prefer the Sense HAT utility when hardware is present
- fall back to a saved data file when the sensor is missing or unavailable
- use the CPU internal temperature as a last fallback
- collect full sample records including timestamp, temperature, humidity, and pressure when available
- save each sample to a CSV file in the local runtime Data directory
- save collection metrics in a separate CSV file for later analysis

The I/O logic is implemented around the source-priority pattern:

```text
Sense HAT -> data file -> CPU temperature
```

This ensures the system can continue operating during hardware or sensor failures without crashing.

### 2. Memory module

The memory layer handles validation, bounded storage, and reduction. It is designed to keep the acquisition loop from growing without bound while still preserving useful information.

Key files:

- [Development/CritterProduct/Pilot/Memory/critter_memory.h](../Development/CritterProduct/Pilot/Memory/critter_memory.h)
- [Development/CritterProduct/Pilot/Memory/critter_memory.c](../Development/CritterProduct/Pilot/Memory/critter_memory.c)

Responsibilities:

- validate incoming samples
- reject invalid values such as NaN or nonphysical humidity/pressure values
- track received, valid, rejected, and outlier counts
- store a fixed-capacity ring buffer of recent values
- detect outliers using a robust window-based method
- reduce high-rate data into summary statistics
- preserve summary data suitable for offline analysis
- record source distribution and retained ratios for reporting

The memory logic is built around bounded storage rather than unbounded growth, which is important for a continuously running monitoring system.

### 3. Computation module

The computation layer consumes the summarized memory data and calculates the current trend and likely HVAC-related behavior.

Key files:

- [Development/CritterProduct/Pilot/Computation/critter_computation.h](../Development/CritterProduct/Pilot/Computation/critter_computation.h)
- [Development/CritterProduct/Pilot/Computation/critter_computation.c](../Development/CritterProduct/Pilot/Computation/critter_computation.c)

Responsibilities:

- compute trend and rate of change
- estimate a predicted temperature over a short horizon
- compute summary metrics such as mean, variance, and recent delta
- classify the observation as stable, rising, or falling
- identify likely HVAC-related behavior using simple explainable thresholds
- avoid machine-learning dependencies while still producing meaningful prototype insights

The computation logic is intentionally explainable and rule-based rather than opaque or statistical black-box logic.

---

## Data model and shared types

The shared types used by the Pilot are declared in:

- [Development/CritterProduct/Pilot/critter_types.h](../Development/CritterProduct/Pilot/critter_types.h)

Important types:

- critter_sample_t
  - timestamp
  - temperature
  - humidity
  - pressure
  - source
  - validity flags

- critter_window_summary_t
  - sample count and valid sample count
  - min/max/mean/median/stddev
  - first/last timestamps
  - source information
  - retained ratio
  - outlier count

- critter_analysis_result_t
  - current temperature
  - trend and rate of change
  - predicted temperature
  - behavior flags such as likely heating/cooling/HVAC activity

These structures allow the system to represent the flow from raw high-rate samples to processed summary values and simple analysis outputs.

---

## Functional execution flow

The main execution path is implemented in:

- [Development/CritterProduct/Pilot/main.c](../Development/CritterProduct/Pilot/main.c)

### Step-by-step flow

1. Initialize memory storage
   - A bounded memory buffer is created with a fixed capacity.

2. Start a one-minute acquisition window
   - A monotonic clock is used to define the collection duration.

3. Collect a sample every second
   - The I/O layer reads a temperature value and attached environmental data when available.
   - The sample is saved to the local Data directory in CSV form.
   - The sample is validated and inserted into the bounded memory buffer.
   - Outliers are detected and tracked.

4. Periodically report progress
   - The loop updates a compact terminal progress display so the user sees elapsed time without flooding output.

5. End the collection window
   - After 60 seconds, the memory buffer is summarized.

6. Run analysis
   - The summary is sent to the computation module.
   - Trend, predicted temperature, and likely HVAC behavior are computed.

7. Save metrics
   - The collection metrics are saved to a CSV file using the same runtime Data directory pattern as the temperature data.

8. Free memory and exit
   - The bounded sample buffer is released before shutdown.

---

## Data capture and file handling

The Pilot writes data to the local runtime Data directory so it persists where the program is run rather than relying on a machine-specific path.

### Temperature sample file

The sample data is stored in a CSV file similar to:

- [Development/CritterProduct/Pilot/Data/temperature_samples.csv](../Development/CritterProduct/Pilot/Data/temperature_samples.csv)

Fields include:

- timestamp_s
- temperature_c
- humidity_percent
- pressure_hpa
- source
- has_humidity
- has_pressure

This makes the data suitable for later offline analysis.

### Metrics file

The collection metrics are saved in a CSV file similar to:

- [Development/CritterProduct/Pilot/Data/collection_metrics.csv](../Development/CritterProduct/Pilot/Data/collection_metrics.csv)

Fields include:

- reads_attempted
- valid_samples
- rejected_samples
- outlier_count
- sample_rate_hz
- retained_ratio
- summary_count
- min/max/mean/median/stddev
- source
- current/predicted temperature
- trend and rate of change
- HVAC flags

This allows the team to evaluate both the quality of the dataset and the quality of the inferred environmental behavior.

---

## Hardware and utility usage

The project keeps hardware access in reused utilities under:

- [Utils/SenseHat/sense_hat_environment.h](../Utils/SenseHat/sense_hat_environment.h)
- [Utils/SenseHat/sense_hat_environment.c](../Utils/SenseHat/sense_hat_environment.c)

The Critter modules do not directly manipulate the Sense HAT devices themselves; rather, they rely on the utility layer. This preserves the dependency direction required by the project and keeps application logic hardware-independent.

---

## Test coverage and verification

The Pilot includes tests under:

- [Development/CritterProduct/Pilot/tests](../Development/CritterProduct/Pilot/tests)

Examples include:

- memory and computation validation
- fallback data file reading
- internal CPU temperature fallback reading
- source-specific temperature testing

These tests provide confidence that the I/O fallback logic and memory/computation behavior operate correctly under expected conditions.

---

## Summary of what the program accomplishes

The current Pilot accomplishes the following:

- acquires environmental temperature data from the highest-priority available source
- records humidity and pressure when available
- stores a bounded window of recent samples
- rejects invalid or unsuitable samples
- removes or flags outliers
- reduces sampling data into a summary
- calculates trend and predictive behavior
- classifies current conditions as likely stable/rising/falling or HVAC-active
- saves both raw sample data and summary metrics to a local runtime Data directory

This aligns closely with the project’s intended design of a single-room pilot system focused on environmental monitoring and HVAC-related analysis.

---

## Limitations

This is still a prototype, not a full production-grade HVAC intelligence system. The current implementation is best described as:

- a working single-room monitoring prototype
- a bounded-memory environmental summarizer
- a rule-based trend and behavior analysis layer

It does not yet include a broader historical model, room-by-room fleet management, or more advanced predictive HVAC detection beyond the prototype’s explainable statistical rules.

---

## Closing note

The project goal is to maintain a clear separation between acquisition, memory management, and computation, while keeping the system portable, testable, and explainable. The Pilot reflects that design even though it remains intentionally lightweight and prototype-oriented.
