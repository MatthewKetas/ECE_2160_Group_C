# Critter compiler performance

Run this on the Raspberry Pi 5 from the repository root. Use the same Pi, cooling, power supply, and filesystem throughout the run. Keep other workloads quiet. The runner uses Python 3.8+, GCC, and binutils on Raspberry Pi OS.

```sh
python3 Development/CritterProduct/PerformanceAssessment/benchmark.py --sensor sense-hat --smoke
python3 Development/CritterProduct/PerformanceAssessment/benchmark.py --sensor sense-hat
```

The smoke run builds every configuration and performs one short repetition. The second command collects 144 measured trials. Both print their timestamped result directories. Connect the Sense HAT, enable I²C, and use a Pi login with read/write access to `/dev/i2c-1`. Physical acquisition is the default on Linux. If transferring the code through Git, include this directory in the commit before pulling on the Pi.

For Mac development or reproducing the original simulated experiment, select replay explicitly. macOS defaults to replay and Linux defaults to physical acquisition.

```sh
python3 -m unittest discover -s Development/CritterProduct/PerformanceAssessment/tests -v
python3 Development/CritterProduct/PerformanceAssessment/benchmark.py --sensor replay --smoke
```

## What runs

| Workload | Work timed in one batch | Unit for normalized timing |
| --- | --- | --- |
| I/O | Acquire and append 600 physical Sense HAT samples through the Pilot's I/O functions | Sample |
| Memory | Validate and filter 600 samples, retain up to 100 in the ring, and summarize the retained window | Sample |
| Computation | Run the Pilot's 30-second predictor on 600 varying summary inputs | Prediction |
| Critter's complete pipeline | Acquire and save 600 samples in order, filter and summarize them, make one prediction, and save one metrics row | Sample or full 600-sample batch |

In physical mode, the I/O unit and complete pipeline link the repository's real Linux Sense HAT driver. Each sample comes through `critter_io_read_sample`, keeps its actual acquisition timestamp and sensor values, and is appended to CSV. The pipeline filters those live readings, summarizes them, predicts, and saves metrics. Its metrics row reports the observed acquisition rate. A sensor failure or a fallback to the data file or CPU source stops collection. The benchmark preserves the Pilot's existing acquisition behavior, including its two environment reads per sample.

Memory and prediction in isolation retain the original fixed generated workloads so compiler builds receive matched input. Memory sees steady, warming and cooling cases with periodic outliers. Prediction uses prepared summaries. Replay mode also uses those generated values for I/O and the pipeline, with nominal timestamps 0.1 seconds apart.

Elapsed wall time includes sensor access, measured processing and file operations. Process CPU time measures the CPU time used by the same work. The harness records each acquired sample in a preallocated capture buffer during measurement. Allocation and capture-file writing, profile training, and output checks happen outside the measured trials. Reads proceed continuously without the application's sampling sleep, so the sensor can return the same conversion repeatedly. This measures processing and I²C access under continuous demand. Sensor freshness, durable storage writes and the paced one-minute schedule require separate measurements. The current predictor is a small rule-based prototype. All workloads execute sequentially in one thread.

## Builds and PGO

| Build | Treatment | Comparison |
| --- | --- | --- |
| `O0` | `-O0` | Unoptimized reference |
| `O2` | `-O2` | Effect of static compiler optimization against `O0` |
| `O2_pgo` | `-O2` plus profile feedback | Added effect of PGO against `O2` |
| `O2_lto` | `-O2 -flto` | Added effect of link-time optimization against `O2` |

PGO is required by the assignment and automatic here. The runner builds an instrumented executable for each workload, trains it, and rebuilds using the profile it collected. Physical I/O and pipeline training each acquire two batches from the real sensor. The isolated memory/prediction and replay workloads train on twelve generated batches, using a different trace from evaluation. Only the rebuilt executable enters the timing comparisons. GCC uses its native profile files. Clang uses a matching `llvm-profdata`, selected through Xcode on macOS or via `--profdata` when needed. Missing GCC profiles and profile mismatches fail the build.

All builds use `-ffp-contract=off` to hold floating-point contraction constant. The runner calibrates each workload on `O0` to at least about 250 ms, then fixes that work count across its four builds. Physical I/O and pipeline calibration starts at one 600-sample batch. Other workloads start at six batches. The full run collects nine repetitions with a recorded, shuffled order. Every child command has a 120-second limit.

Live sensor values vary across trials. After each physical trial, an `O0` executable processes that trial's lossless captured samples, regenerates the saved CSV rows, and checks filtering totals, summary and prediction checksums, and HVAC decisions against the timed build. This check runs after timing and reads the capture file. It also checks exact sample and metrics CSV hashes. Fixed-input workloads compare against their original `O0` reference. A difference stops collection. These checks establish agreement on the tested inputs. Natural changes in room conditions can still affect the memory unit's workload between physical trials.

## Data and compiler evidence

- `trials.csv` contains per-run wall and CPU times, execution order, work counts, source counts and output checks. The `sense_hat_samples` field counts physical samples for I/O and pipeline runs. `validation=O0_same_capture` identifies the live-data check. `summary.csv` gives median and range, normalized times, and speedups against both references. A speedup above 1 means the build was faster.
- `metadata.json` contains the sensor mode, per-unit input sources, run status, platform, compiler, build sizes, source hashes, and available Pi state. `reference/` contains the unoptimized reference output and CSV files. Each physical measured trial saves its CSVs, exact `capture.bin`, timed result and `O0_check.json` under `trials/`. These binary captures use the recorded build's C sample layout and can be checked on the same platform. Copy the entire timestamped directory back for analysis.
- `builds/<variant>/<workload>/compiler.log` contains commands and compiler remarks on applied and missed optimizations. `disassembly.txt` shows the final linked machine code, including changes made during LTO, and `symbols.txt` helps locate the functions. PGO profiles and training results are kept within the corresponding build.

For example, set `critter_results` to the reported directory and check what the compiler did around the two median calculations used by outlier filtering, then compare function calls in the linked pipeline.

```sh
rg -n 'critter_median|critter_detect_outlier' "$critter_results"/builds/{O2,O2_pgo,O2_lto}/pipeline/compiler.log
rg -n 'critter_(io_read_sample|memory_add_sample|compute_analysis)' "$critter_results"/builds/{O2,O2_lto}/pipeline/disassembly.txt
```

For the workshop paper, lead with what ran on the Pi and how the outputs were checked. Use one table for the four workloads and the four builds. Use the trial spread to qualify small timing differences and one or two compiler findings to explain what changed in Critter. Compare PGO and LTO directly with `-O2` before deciding whether their measured gains matter for unattended temperature logging and HVAC analysis.
