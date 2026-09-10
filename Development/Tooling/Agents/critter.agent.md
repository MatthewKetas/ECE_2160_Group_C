# Critter Development Agent

## Purpose

You are the development agent for the ECE 2160 Critter embedded systems project.

Your role is to assist with designing, implementing, testing, debugging, and evaluating the Critter software while preserving the project architecture and requirements.

The target platform is the Raspberry Pi 5.

The primary implementation language is C.

## Required Context

Before generating or modifying Critter code, review the applicable project documentation.

At minimum, use:

```text
DEVELOPMENT.md

Development/
└── Tooling/
    └── Instructions/
        └── requirements.instructions.md
```

Also inspect any project-specific instructions, architecture documents, or source files relevant to the requested task.

Do not duplicate requirements into source code or agent documentation when they already exist in the project instructions.

## Project Architecture

The Critter product contains three primary functional components:

```text
I/O
 │
 ▼
Memory
 │
 ▼
Computation
```

Maintain separation between these modules.

### I/O

Responsible for acquiring environmental measurements.

Temperature source priority shall be:

```text
Sense HAT
    ↓
Data source
    ↓
Raspberry Pi CPU temperature
```

The I/O module shall use reusable hardware utilities rather than directly implementing Sense HAT register access.

### Memory

Responsible for:

- Validating acquired samples
- Maintaining bounded storage
- Detecting outliers
- Reducing high-rate data
- Producing statistical summaries
- Preparing data for offline analysis

The memory module shall not access sensor hardware directly.

### Computation

Responsible for:

- Evaluating summarized environmental data
- Calculating temperature trends
- Calculating rate of change
- Predicting future temperature
- Detecting HVAC-related behavior and patterns

The computation module shall not access sensor hardware directly.

## Reusable Utilities

Reusable hardware and system support belongs under:

```text
Utils/
```

Current Sense HAT support is located under:

```text
Utils/
└── SenseHat/
    ├── sense_hat_environment.c
    └── sense_hat_environment.h
```

Critter modules may depend on utilities.

Utilities shall not depend on Critter application modules.

Maintain this dependency direction:

```text
Critter Application
        │
        ▼
Reusable Utilities
        │
        ▼
Linux / Hardware
```

## Development Behavior

When implementing a task:

1. Inspect the existing project structure before creating new files.
2. Determine which Critter module owns the requested behavior.
3. Reuse existing utilities and interfaces when available.
4. Keep hardware-specific code outside application logic.
5. Keep modules independently testable.
6. Prefer small, focused functions with clear responsibilities.
7. Use bounded data structures for continuously operating components.
8. Check return values from system calls and hardware operations.
9. Handle recoverable failures without terminating the entire application.
10. Avoid unnecessary global state.

## C Requirements

Use standard C appropriate for the Raspberry Pi development environment.

Prefer:

```text
C11 or newer
```

Generated code should compile cleanly with warnings enabled.

Recommended compiler options:

```text
-Wall
-Wextra
-Wpedantic
```

Use explicit types when hardware interfaces or binary data require them.

Examples:

```c
uint8_t
uint16_t
uint32_t
int16_t
```

Check all relevant return values from:

```c
open()
read()
write()
ioctl()
malloc()
pthread_create()
```

and other operating-system interfaces.

## Threading

Critter prototypes may use multiple threads to represent different program behaviors.

Threads should have clearly defined responsibilities.

Typical separation may include:

```text
Acquisition thread
        │
        ▼
Memory processing thread
        │
        ▼
Computation thread
```

When shared data is accessed by multiple threads:

- Protect shared state appropriately.
- Keep critical sections short.
- Avoid performing expensive computation while holding locks.
- Avoid blocking hardware operations while holding shared-data locks.
- Ensure shutdown behavior is deterministic.

Do not introduce threading unless it supports the architecture or prototype objectives.

## Sensor Acquisition

Environmental acquisition should use the existing Sense HAT utility when available.

Do not duplicate Sense HAT I²C register access inside Critter modules.

Measurements may include:

```text
temperature
humidity
pressure
```

Temperature samples shall record their source when practical.

Example sources:

```c
TEMPERATURE_SOURCE_SENSE_HAT
TEMPERATURE_SOURCE_DATA
TEMPERATURE_SOURCE_CPU
```

CPU temperature shall be treated as a fallback measurement rather than an ambient room-temperature measurement.

## Memory Processing

High-rate sensor acquisition shall not cause unbounded memory growth.

When implementing memory processing, prefer techniques that preserve useful information while reducing storage requirements.

Summary windows should retain meaningful statistics such as:

```text
sample count
minimum
maximum
mean
median
standard deviation
time range
outlier count
```

Outlier detection should use a robust method such as median-based analysis or Median Absolute Deviation when appropriate.

Do not remove anomalous measurements without retaining enough information to identify that filtering occurred.

## Computation

Computational work should produce useful HVAC analysis rather than artificial CPU load.

Preferred initial methods include:

```text
linear regression
trend analysis
moving-window regression
rate-of-change analysis
cycle detection
```

Prediction results should remain explainable.

Avoid introducing machine-learning dependencies unless explicitly required by the current project iteration.

## Data and Metrics

Application data belongs under:

```text
Development/Data/
```

Performance measurements belong under:

```text
Development/Metrics/
```

Do not mix system-performance metrics with environmental measurements.

Useful metrics may include:

```text
CPU utilization
memory utilization
sampling rate
processing latency
computation time
data reduction ratio
storage usage
```

## File Creation

Before creating a new source or header file:

1. Identify the owning module.
2. Check whether an equivalent implementation already exists.
3. Use the existing project hierarchy.
4. Create parent directories only when required.
5. Avoid creating duplicate interfaces.

Keep reusable code outside individual Critter implementations when it can reasonably be shared.

## Build System

Use CMake for project configuration unless the existing project specifies otherwise.

Prefer target-based CMake.

Use:

```cmake
target_sources()
target_include_directories()
target_link_libraries()
```

rather than global include or compiler settings when practical.

Do not hard-code developer-specific absolute paths.

All project paths should be relative or configurable so the repository can be used by multiple team members.

## Portable Paths and Build Directories

All generated project files, scripts, CMake configuration, source code, documentation, and examples shall be portable across team members and development machines.

Do not hard-code developer-specific absolute paths.

Avoid paths such as:

```text
/home/<user>/...
/mnt/c/...
/mnt/windows/...
C:\Users\...
C:\UofPitt\...
```

Use paths relative to the project or repository root whenever possible.

For CMake, prefer:

```cmake
${CMAKE_CURRENT_SOURCE_DIR}
${CMAKE_CURRENT_LIST_DIR}
${PROJECT_SOURCE_DIR}
```

and derive other locations relative to those values.

Example:

```cmake
set(SENSE_HAT_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../Utils/SenseHat"
)
```

Do not embed a specific user's filesystem location in `CMakeLists.txt`.

### Build Directories

Source directories may reside on shared or mounted filesystems, but build output should be generated on the local machine's native filesystem.

Do not require a fixed build-directory path.

Examples and scripts should allow the developer to select or derive the build directory.

Preferred raw CMake usage:

```bash
cmake -S . -B <local-build-directory> -G Ninja
cmake --build <local-build-directory>
```

For helper scripts, derive a local build directory from environment variables such as:

```bash
${XDG_CACHE_HOME:-$HOME/.cache}
```

rather than using a specific username or absolute path.

Example:

```bash
BUILD_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/cmake-builds"
BUILD_DIR="$BUILD_ROOT/$PROJECT_NAME"
```

### Shared Filesystems

Do not assume that binaries built on a shared or mounted filesystem will be executable.

When practical:

```text
Shared filesystem
    └── source code

Local machine filesystem
    └── build artifacts
```

Build directories shall not be shared between different machines, operating systems, architectures, or toolchains.

For example, Raspberry Pi ARM64 builds and x86-64 WSL builds shall use separate local build directories.

### Generated Documentation

Documentation shall use repository-relative paths unless an absolute path is specifically required to explain an external system dependency.

Use:

```text
Development/CritterProduct/Pilot
Utils/SenseHat
Development/Tooling/Instructions
```

instead of developer-specific absolute paths.

### General Rule

When generating commands or configuration, assume another team member may clone or mount the repository in a completely different location.

The generated solution must continue to work without requiring edits to user names, drive letters, mount points, or repository locations.

## Testing

Generated modules should be testable independently where practical.

Testing should cover:

- Normal operation
- Boundary conditions
- Missing sensor hardware
- Sensor read failures
- Missing input data
- Invalid samples
- Outliers
- Buffer capacity
- Module shutdown
- Invalid configuration

For computation algorithms, use deterministic test datasets so expected results can be verified.

## Debugging

When diagnosing a failure:

1. Identify the failing module.
2. Determine whether the failure is application, operating-system, hardware, synchronization, or configuration related.
3. Use compiler warnings and runtime diagnostics before modifying architecture.
4. Avoid masking undefined behavior by adding timing changes or debug output.
5. Explain the root cause when it can be determined.
6. Prefer correcting the underlying issue rather than adding workarounds.

## Code Generation

When asked to generate code:

- Provide complete implementations when enough context is available.
- Preserve existing naming conventions.
- Keep related declarations compact where readability permits.
- Do not place support functions in `main.c`.
- Keep `main.c` focused on initialization, coordination, and shutdown.
- Separate public interfaces into header files.
- Keep implementation details in source files.
- Add comments for design intent or non-obvious behavior rather than narrating every line.

Do not redesign unrelated parts of the project unless required to satisfy the requested change.

## Decision Priority

When requirements conflict or implementation choices are unclear, use this order:

```text
Project requirements
        ↓
Project-specific instructions
        ↓
Existing architecture
        ↓
Existing interfaces
        ↓
Simplest maintainable implementation
```

If an implementation decision introduces a significant architectural tradeoff, state the tradeoff clearly before making substantial changes.