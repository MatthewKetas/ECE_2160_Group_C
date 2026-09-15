# Verification commands

Run from the repository root. Results are for the source snapshot fingerprinted in `source-sha256.txt`. Original baseline and reviewer annotations are separate artifacts. The sanitizer and analyzer configurations below were run; this is not a proposal or a certification claim.

## Strict host build and test

```sh
cmake -S Development/CritterProduct/Pilot -B /tmp/critter-safety-build -DCMAKE_BUILD_TYPE=Debug
cmake --build /tmp/critter-safety-build
ctest --test-dir /tmp/critter-safety-build --output-on-failure
```

CMake enables `-Wall -Wextra -Wpedantic -Wconversion -Wshadow -Wformat=2 -Werror` for GCC/Clang. On macOS the Linux-only sensor open returns unsupported; no fake Linux constant is placed in production code. Physical sensor success is not verified by host tests. The Pi thermal test exits 77 when its interface is absent; CTest records a skip.

## Sanitizers

```sh
cmake -S Development/CritterProduct/Pilot -B /tmp/critter-safety-sanitized \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_FLAGS='-fsanitize=address,undefined,float-cast-overflow -fno-omit-frame-pointer' \
  -DCMAKE_EXE_LINKER_FLAGS='-fsanitize=address,undefined,float-cast-overflow'
cmake --build /tmp/critter-safety-sanitized
ctest --test-dir /tmp/critter-safety-sanitized --output-on-failure
```

## Cppcheck: explicit target configuration

```sh
cppcheck --enable=warning,style,performance,portability --inconclusive \
  --check-level=exhaustive --std=c11 --platform=unix64 -D__linux__ \
  --suppress=missingIncludeSystem --error-exitcode=1 \
  --checkers-report=review-results/safety-review-2026-09-14/checkers-target.txt \
  -IDevelopment/CritterProduct/Pilot -IUtils/SenseHat \
  Development/CritterProduct/Pilot/main.c \
  Development/CritterProduct/Pilot/IO/critter_io.c \
  Development/CritterProduct/Pilot/Memory/critter_memory.c \
  Development/CritterProduct/Pilot/Computation/critter_computation.c \
  Utils/SenseHat/sense_hat_environment.c
```

The broader saved exploration uses `--enable=all`, omits `-D__linux__`, and adds `--suppress=unusedFunction`; its other flags are the same. Seven remaining style suggestions in that broad configuration are explicitly discussed in the report. These are not hidden by the clean target-configuration result. Suppressing missing system headers does not turn this scan into a target compile; application includes are still checked.

## Clang static analyzer (host configuration)

```sh
for source_file in \
  Development/CritterProduct/Pilot/main.c \
  Development/CritterProduct/Pilot/IO/critter_io.c \
  Development/CritterProduct/Pilot/Memory/critter_memory.c \
  Development/CritterProduct/Pilot/Computation/critter_computation.c \
  Utils/SenseHat/sense_hat_environment.c
do
  clang --analyze -std=c11 -D_DARWIN_C_SOURCE -Xanalyzer -analyzer-output=text "$source_file"
done
```

## Actual one-minute replay

```sh
run_dir=$(mktemp -d /tmp/critter-pilot-run-XXXXXX)
CRITTER_DATA_FILE="$PWD/Development/CritterProduct/Pilot/Data/temperature_samples.csv" \
CRITTER_OUTPUT_FILE="$run_dir/samples.csv" \
CRITTER_METRICS_FILE="$run_dir/metrics.csv" \
  /tmp/critter-safety-build/Pilot
```

The measured run uses the real clock and sleep. The separate collection regression uses simulated time to exercise a frozen clock, failed acquisition, failed sample output and failed metrics output. The latter does not establish elapsed-time performance.
