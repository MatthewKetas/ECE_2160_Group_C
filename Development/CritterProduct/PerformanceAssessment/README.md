# Critter compiler performance

Run this on the Raspberry Pi 5 from the repository root. Use the same Pi, cooling, power supply, and filesystem throughout the run. Keep other workloads quiet. The runner uses Python 3.8+, GCC, and binutils on Raspberry Pi OS.

```sh
python3 Development/CritterProduct/PerformanceAssessment/benchmark.py --smoke
python3 Development/CritterProduct/PerformanceAssessment/benchmark.py
```

The smoke run builds every configuration and performs one short repetition. The second command collects the paper's data. Both print their timestamped result directories. A Mac with Xcode tools can run the same commands with Apple Clang for development. Use the Pi run for the paper. The benchmark runs in user space and requires no sensor connection or sudo. If transferring the code through Git, include this directory in the commit before pulling on the Pi.

## What runs

| Workload | Work timed in one batch | Unit for normalized timing |
| --- | --- | --- |
| I/O | Acquire and append 600 samples through the Pilot's I/O functions | Sample |
| Memory | Validate and filter 600 samples, retain up to 100 in the ring, and summarize the retained window | Sample |
| Computation | Run the Pilot's 30-second predictor on 600 varying summary inputs | Prediction |
| Critter's complete pipeline | Acquire and save 600 samples in order, filter and summarize them, make one prediction, and save one metrics row | Sample or full 600-sample batch |

The benchmark calls the existing Pilot C units. A simulated Sense HAT supplies deterministic readings with steady, warming, and cooling periods and occasional outliers. The Pilot still assembles samples and appends real CSV files. The harness assigns timestamps 0.1 seconds apart and processes them without the application's sampling sleep. Prediction in isolation uses prepared summaries. The complete pipeline passes the actual memory summary into prediction, so its timing comes from one integrated run.

Elapsed wall time includes the measured work and its file operations. Process CPU time measures the CPU time used by the same work. Input preparation, profile training, and output checks happen outside the measured trials. Results characterize accelerated processing and buffered file writes on the target. The physical I²C bus, sample freshness, durable writes, and the one-minute schedule are outside this experiment. The current predictor is a small rule-based prototype. All workloads execute sequentially in one thread.

## Builds and PGO

| Build | Treatment | Comparison |
| --- | --- | --- |
| `O0` | `-O0` | Unoptimized reference |
| `O2` | `-O2` | Effect of static compiler optimization against `O0` |
| `O2_pgo` | `-O2` plus profile feedback | Added effect of PGO against `O2` |
| `O2_lto` | `-O2 -flto` | Added effect of link-time optimization against `O2` |

PGO is required by the assignment and automatic here. The runner builds an instrumented executable for each workload, runs it on the training trace, and rebuilds using the profile it collected. Only the rebuilt executable enters the timing comparisons. Training and evaluation use different generated traces from the same workload family. GCC uses its native profile files. Clang uses a matching `llvm-profdata`, selected through Xcode on macOS or via `--profdata` when needed. Missing GCC profiles and profile mismatches fail the build.

All builds use `-ffp-contract=off` to hold floating-point contraction constant. The runner calibrates each workload on `O0` to about 250 ms or longer, then fixes that work count across its four builds. The full run collects nine repetitions with a recorded, shuffled order. It checks sample and metrics CSV row counts and hashes, and compares filtering totals, summary and prediction checksums, and HVAC decisions with `O0` for the same workload. A difference stops the run. This checks that the compiler variants agree on the tested work.

## Data and compiler evidence

- `trials.csv` contains per-run wall and CPU times, execution order, work counts, and output checks. `summary.csv` gives median and range, normalized times, and speedups against both references. A speedup above 1 means the build was faster.
- `metadata.json` contains run status, platform, compiler, build sizes, source hashes, and available Pi state. `reference/` contains the unoptimized reference output and CSV files. Copy the timestamped directory back for analysis.
- `builds/<variant>/<workload>/compiler.log` contains commands and compiler remarks on applied and missed optimizations. `disassembly.txt` shows the final linked machine code, including changes made during LTO, and `symbols.txt` helps locate the functions. PGO profiles and training results are kept within the corresponding build.

For example, set `critter_results` to the reported directory and check what the compiler did around the two median calculations used by outlier filtering, then compare function calls in the linked pipeline.

```sh
rg -n 'critter_median|critter_detect_outlier' "$critter_results"/builds/{O2,O2_pgo,O2_lto}/pipeline/compiler.log
rg -n 'critter_(io_read_sample|memory_add_sample|compute_analysis)' "$critter_results"/builds/{O2,O2_lto}/pipeline/disassembly.txt
```

For the workshop paper, lead with what ran on the Pi and how the outputs were checked. Use one table for the four workloads and the four builds. Use the trial spread to qualify small timing differences and one or two compiler findings to explain what changed in Critter. Compare PGO and LTO directly with `-O2` before deciding whether their measured gains matter for unattended temperature logging and HVAC analysis.
