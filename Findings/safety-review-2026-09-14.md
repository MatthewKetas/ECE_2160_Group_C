# Critter safety review and remediation — 14 September 2026

Baseline: `77719e397d8f20f83ac82c1833d416367b07c6ce`, branch `mketas-safety-assignment-implementation`, including Matthew Ketas's uncommitted annotations. Review scope: the five production C files, five public headers, build configuration and supporting tests. The agreed scope was recovered from the task **Review implementation manually**: 60 CERT rules in chapters 4, 5, 6, 7, 8, 9, 10 and 13, plus all 10 NASA rules. The archived [agreed matrix](../review-results/safety-review-2026-09-14/agreed-review-matrix.md) preserves the 57 AI/tools-first and 13 human-first assignments.

Your original [annotation patch](../review-results/safety-review-2026-09-14/human-annotations.patch) and annotated [IO](../review-results/safety-review-2026-09-14/baseline/critter_io.c.txt) / [Memory](../review-results/safety-review-2026-09-14/baseline/critter_memory.c.txt) files are preserved. I found no separate written pass/fail decisions for the other human-first checks, so this report verifies your recorded comments and supplies its own assessment of all 13 rules; it does not attribute unrecorded conclusions to you.

## Counts and counting convention

| Item | Count | Meaning |
| --- | --- | --- |
| Human annotation blocks double-checked | 14 | All 12 IO annotations and both memory annotations. |
| Annotation blocks supported wholly or partly, and addressed | 13 | Includes two snprintf comments whose pointer diagnosis was wrong but whose error-result coverage was incomplete. |
| Annotation blocks rejected as stated | 1 | U01: getenv already had a null/empty check. |
| Operations/regions explicitly covered by those annotations | 17 | Split each of the three comments explicitly saying “both” into two operations. |
| Supported flagged operation/region rows addressed | 16 | All except U01; includes compliance/error-coverage findings, not only reproduced runtime faults. |
| Unique actionable diagnostics in your two saved analyzer reports | 9 | Eight from the Mac run, plus one distinct older always-true-condition diagnostic. All addressed. |
| Additional unannotated finding groups addressed | 37 | 36 implemented/closed within their described scope; H04 is partially mitigated with deployment risks still open. Includes defects, coding-rule findings, hardening and compiler cleanup. |
| Supporting changes excluded from incident counts | 2 | A15 portable host fallback; A25 reliable test setup/explicit hardware skips. |
| Agreed rule assessments completed | 70 | 57 AI/tools-first, then a separate 13-rule human-first reassessment. |

These are different units; do not add annotation blocks, operation rows and finding groups into a single defect total. Each rule cross-reference is reused evidence, not another incident. Additional groups can cover several related sites (for example three goto branches in A16); the descriptions enumerate those sites. Some additional examples were already mentioned by AI in earlier tasks and are marked accordingly; this is not a claim that all 37 were newly discovered independently. No human review minutes or discovery-time measurements were supplied, and none are invented here.

## Corrections to your rule labels

`EXP33-C` concerns reading uninitialized storage. It does not mean “check every return value” or “check every pointer.” Your IO annotations mostly identify **ERR33-C and P10-7** concerns. The existing pointer checks in the getenv/path helpers were already present. File-return failures, however, were often unchecked. See the primary [EXP33-C](https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/rules/expressions-exp/exp33-c/) and [ERR33-C](https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/rules/error-handling-err/err33-c/) descriptions.

The two workspace allocations do violate P10-3 because they occur during processing. `memset` does not allocate; the nearby `malloc` was the relevant operation. An initialization-time `calloc` was permitted by that rule. The [original Power of Ten paper](https://spinroot.com/gerard/pdf/P10.pdf) also permits explicitly justified ignored returns when failure cannot change the response; cleanup already returning failure and the final best-effort diagnostic are documented that way.

## Verification key and file locations

- **SR:** `tests/test_safety_regressions.c` — ring/state boundaries, invalid numeric data, replay progression, special files and oversized paths.
- **FI:** `tests/test_io_failures.c` — injected header, row, close and read-close failures in the real IO implementation.
- **SD:** `tests/test_sensor_decoding.c` — simulated register bytes; this is not physical sensor verification.
- **CF:** `tests/test_collection_failures.c` — real collection/control flow with simulated time and IO failures.
- **MC:** existing `tests/test_memory_computation.c` and the rest of the registered tests.

IO, Memory, Computation and Main refer to `Development/CritterProduct/Pilot`; Sensor refers to `Utils/SenseHat/sense_hat_environment.c`. Old line references below belong to the preserved annotated baseline (or explicitly identified older analyzer report). Current links point at nearby fix comments; use the U/A/H/S identifiers to locate all affected regions after further edits. Severity estimates refer to the Pilot's monitoring/reporting function, not a certified hazard classification. All closed rows are owned by this AI-assisted remediation; open decisions belong to the project reviewer.

## Your flagged instances

| ID / current fix | Original evidence | Correct mapping | Decision | Problem and change | Verification |
| --- | --- | --- | --- | --- | --- |
| [IO:100](../Development/CritterProduct/Pilot/IO/critter_io.c#L100) (U01) | IO:70, getenv | EXP33-C | Rejected as stated | Null/empty path was already checked at original lines 79–82. No uninitialized read or missing null guard demonstrated. | Baseline inspection |
| [IO:81](../Development/CritterProduct/Pilot/IO/critter_io.c#L81) (U02) | IO:94, CSV loop | P10-2 | Confirmed; fixed | EOF alone did not bound iteration count. Cap at 4096 records, each in a 256-byte buffer. | SR scan-limit case |
| [IO:133](../Development/CritterProduct/Pilot/IO/critter_io.c#L133) (U03) | IO:113, fclose | ERR33-C; P10-7 | Confirmed; corrected mapping; fixed | End-of-scan close result was ignored. Failure now invalidates the acquisition. | FI read-close case; review |
| [IO:178](../Development/CritterProduct/Pilot/IO/critter_io.c#L178) (U04) | IO:166, snprintf | ERR33-C; P10-7; INT31-C | Partially confirmed; fixed | Pointers/size were already checked. Missing negative-result handling and size_t-to-int narrowing were the gaps. Removed formatting copy, validate readlink length directly. No null-pointer defect confirmed. | Code review; strict build |
| [IO:198](../Development/CritterProduct/Pilot/IO/critter_io.c#L198) (U05) | IO:199, snprintf | ERR33-C; P10-7 | Partially confirmed; fixed | Arguments were known valid; negative formatting return was unhandled. Removed this path formatting entirely using directory-relative opens. | Code review; compiler |
| [IO:225](../Development/CritterProduct/Pilot/IO/critter_io.c#L225) (U06) | IO:312, snprintf | ERR33-C; P10-7; STR31-C relevance | Confirmed; corrected mapping; fixed | Unexamined result allowed a truncated output path. Open the supplied output path directly; an overlong path fails. This was silent truncation, not a demonstrated buffer overflow. | SR oversized-path case |
| [IO:242](../Development/CritterProduct/Pilot/IO/critter_io.c#L242) (U07a) | IO:327, ftell | ERR33-C; P10-7 | Confirmed; corrected mapping; fixed | Failure (-1) looked like a nonempty file. Replace with checked fstat on the opened descriptor. | Code review; SR file types |
| [IO:242](../Development/CritterProduct/Pilot/IO/critter_io.c#L242) (U07b) | IO:329, header fprintf | ERR33-C; P10-7 | Confirmed; corrected mapping; fixed | Header write failure was ignored. Return failure and close the stream. | FI header failures |
| [IO:340](../Development/CritterProduct/Pilot/IO/critter_io.c#L340) (U08a) | IO:350, sample fprintf | ERR33-C; P10-7 | Confirmed; corrected mapping; fixed | Sample-row write failure was ignored. Capture write status and still attempt close. | FI row failure |
| [IO:340](../Development/CritterProduct/Pilot/IO/critter_io.c#L340) (U08b) | IO:360, sample fclose | ERR33-C; P10-7 | Confirmed; corrected mapping; fixed | Buffered output could fail at close after a successful fprintf. Propagate close failure. | FI sample-close failure |
| [IO:225](../Development/CritterProduct/Pilot/IO/critter_io.c#L225) (U09) | IO:382, snprintf | ERR33-C; P10-7; STR31-C relevance | Confirmed; corrected mapping; fixed | Metrics override could silently truncate. Eliminate the copy and pass the path to open. | Same shared output helper as U06; review |
| [IO:225](../Development/CritterProduct/Pilot/IO/critter_io.c#L225) (U10) | IO:400, snprintf append | ERR33-C; P10-7; STR31-C relevance | Confirmed; corrected mapping; fixed | Appending the metrics filename ignored remaining capacity/result. Open the fixed filename relative to the Data directory instead. | Code review; removed operation |
| [IO:242](../Development/CritterProduct/Pilot/IO/critter_io.c#L242) (U11a) | IO:408, ftell | ERR33-C; P10-7 | Confirmed; corrected mapping; fixed | Metrics header decision ignored ftell failure. Shared descriptor-based size check replaces it. | Code review; shared helper |
| [IO:242](../Development/CritterProduct/Pilot/IO/critter_io.c#L242) (U11b) | IO:410, header fprintf | ERR33-C; P10-7 | Confirmed; corrected mapping; fixed | Metrics header could fail silently. Shared header writer reports failure. | FI metrics-header failure |
| [IO:376](../Development/CritterProduct/Pilot/IO/critter_io.c#L376) (U12) | IO:455, fclose | ERR33-C; P10-7 | Confirmed; corrected mapping; fixed | Metrics flush/close failure did not reach the caller. Return failure when close fails. | FI metrics-close failure |
| [Memory:68](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L68) (U13) | Memory:112–115, outlier malloc | P10-3 | Confirmed; fixed | Outlier workspace was allocated during normal acquisition. Replace with a fixed 100-double stack array. | Source allocation inventory; SR/MC |
| [Memory:142](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L142) (U14) | Memory:211–215, summary malloc | P10-3 | Confirmed; clarified; fixed | memset itself does not allocate memory. The nearby malloc did; summary now uses fixed stack workspace. | Source allocation inventory; SR/MC |

## Your static-analysis findings

The stored Mac run reported three branch-analysis-limit notices and a checker-coverage information record in addition to its eight source diagnostics. Those notices are tool-coverage limitations, not four additional code defects. The older report repeats S02/S03 and adds S09. Const suggestions are useful API hardening, not evidence that the original code modified a const object.

| ID / current fix | Reported site | Diagnostic | Resolution | Mapping |
| --- | --- | --- | --- | --- |
| [Memory:24](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L24) (S01) | Memory:34, swap temp | variableScope | Move the temporary into the swap block. | P10-6 |
| [Memory:153](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L153) (S02) | Memory:205, index | variableScope | Declare index inside the summary loop. | P10-6 |
| [Memory:37](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L37) (S03) | Memory:58, stddev values | constParameterPointer | Use const double * for read-only values. | Const-correctness advisory; not an EXP40-C violation |
| [Sensor:147](../Utils/SenseHat/sense_hat_environment.c#L147) (S04) | Sensor:130, set_hts_odr | constParameterPointer | Use const sensor handle. | Const-correctness advisory |
| [Sensor:157](../Utils/SenseHat/sense_hat_environment.c#L157) (S05) | Sensor:139, set_pressure_odr | constParameterPointer | Use const sensor handle. | Const-correctness advisory |
| [Sensor:216](../Utils/SenseHat/sense_hat_environment.c#L216) (S06) | Sensor:201, read_temperature | constParameterPointer | Use const sensor handle. | Const-correctness advisory |
| [Sensor:236](../Utils/SenseHat/sense_hat_environment.c#L236) (S07) | Sensor:217, read_humidity | constParameterPointer | Use const sensor handle. | Const-correctness advisory |
| [Sensor:263](../Utils/SenseHat/sense_hat_environment.c#L263) (S08) | Sensor:239, read_pressure | constParameterPointer | Use const sensor handle. | Const-correctness advisory |
| [Memory:180](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L180) (S09) | Older report Memory:255, count > 0 | knownConditionTrueFalse | Remove the redundant conditional; validate the actual received-count denominator. | Code clarity; denominator safety also covered by A01/A03 |

## Additional findings addressed

A/H IDs distinguish unannotated review findings; H IDs were revisited during the human-first pass. Every row states whether it is a demonstrated/source-confirmed defect, a coding criterion, or hardening. A resolved row does not claim every rule named in its mapping is globally satisfied.

| ID / current fix | Priority / classification | Affected area | Rule or requirement | Problem and implemented response | Evidence |
| --- | --- | --- | --- | --- | --- |
| [Memory:6](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L6) (A01) | High; Defect | Memory: add/build/ring access | EXP34-C; ARR30-C; INT33-C; P10-7 | Zeroed, failed-initialization or freed state could reach a null buffer, invalid index or modulo-zero operation. Validate capacity/head/count before use. | SR invalid/closed/corrupt ring |
| [Memory:85](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L85) (A02) | Medium; Hardening | Memory: init/free | MEM31-C; MEM35-C; P10-2/3 | Replace heap ownership with an embedded 100-sample array. Capacity checks make allocation sizing and reinitialization leaks inapplicable. Initialization-time calloc was not itself P10-3 noncompliance. | SR zero/SIZE_MAX/init/free |
| [Memory:103](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L103) (A03) | Medium; Defect | Memory: lifetime counters | INT30-C; FLP36-C | Unchecked counters could wrap and invalidate ratios. Reject inconsistent counters and further input at 1,000,000,000 received samples; counts stay exactly representable as double. | SR counter boundary |
| [Memory:166](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L166) (A04) | High; Defect; prior AI example | Memory: summary source aggregation | Requirements/source integrity; P10-7 | DATA, CPU, DATA was incorrectly relabeled DATA because UNKNOWN was reused as an initialization marker. Initialize once; mixed stays UNKNOWN. | SR mixed-source sequence |
| [IO:16](../Development/CritterProduct/Pilot/IO/critter_io.c#L16) (A05) | Medium; Defect | IO persistent sensor; Sensor close; Main cleanup | FIO42-C/FIO46-C relevance; P10-7 | The persistent sensor had no application shutdown API and close results were ignored. Add explicit shutdown, close both descriptors, invalidate ownership and propagate errors. | SR repeated close; CF; code review |
| [IO:46](../Development/CritterProduct/Pilot/IO/critter_io.c#L46) (A06) | High; Defect under special-file inputs | IO file opening | FIO32-C; P10-7 | Configurable file paths could be FIFOs/devices and block or invalidate file-position assumptions. Use nonblocking opens and inspect the actual descriptor; reject nonregular files and final symlinks. | SR FIFO/symlink tests |
| [IO:64](../Development/CritterProduct/Pilot/IO/critter_io.c#L64) (A07) | High; Defect | IO CSV numeric parsing | ERR33-C; P10-7; numeric integrity | scanf conversion could overflow; NaN, Inf and partial numeric fields could be accepted. Use bounded records, strtod with errno/range/end checks, finite limits and overlong-row rejection. | SR malformed/nonfinite/overflow input |
| [IO:107](../Development/CritterProduct/Pilot/IO/critter_io.c#L107) (A08) | High; Defect; prior AI example extended | IO replay state | Requirements/freshness; P10-7 | Every call restarted at the first data row; cached data could masquerade as a successful read after file loss. Advance an offset and return failure on missing source/EOF; never publish cached temperature. | SR sequential values, EOF and removed file |
| [IO:133](../Development/CritterProduct/Pilot/IO/critter_io.c#L133) (A09) | Medium; Defect | IO original early CSV success close | ERR33-C; P10-7 | The successful-row fclose at original line 106 was also unchecked, outside the marked end-of-loop close. A single checked close now handles both paths. | FI read-close failure |
| [IO:159](../Development/CritterProduct/Pilot/IO/critter_io.c#L159) (A10) | Medium; Defect plus hardening | IO CPU reader | ERR33-C; P10-7 | CPU reader ignored closes on normal/error paths and used potentially overflowing integer scanf input. Use bounded parsing and checked close. Actual thermal hardware remains untested. | Shared parser tests; source inspection; hardware skip |
| [IO:178](../Development/CritterProduct/Pilot/IO/critter_io.c#L178) (A11) | Medium; Defect | IO executable directory | STR32-C; STR31-C; P10-7 | readlink can return a full buffer without signaling truncation. Reject length at capacity minus one before treating it as a complete path. | Code review; compiler; Linux runtime pending |
| [IO:287](../Development/CritterProduct/Pilot/IO/critter_io.c#L287) (A12) | Medium; Defect | IO sample acquisition | Requirements/failure recovery; P10-7 | Sample acquisition read the Sense HAT twice. A second failure bypassed the fallback that had already succeeded. Build a complete sample from one acquisition chain. | Code flow inspection; simulated sensor support |
| [IO:330](../Development/CritterProduct/Pilot/IO/critter_io.c#L330) (A13) | Medium; Defect | IO sample persistence | Requirements/data integrity | CRITTER_DATA_FILE named both replay input and appended output, so running the Pilot could modify its input fixture. Add CRITTER_OUTPUT_FILE for sample output; input remains read-only. | SR distinct input/output paths; code review |
| [IO:366](../Development/CritterProduct/Pilot/IO/critter_io.c#L366) (A14) | High; Defect | IO metrics row fprintf | ERR33-C; P10-7 | The metrics data-row fprintf was unmarked and unchecked. Save its return value and combine it with close status. | FI metrics-row failure |
| [Sensor:180](../Utils/SenseHat/sense_hat_environment.c#L180) (A16) | Low; Coding-rule finding; prior AI example | Sensor initialization, three branches | P10-1 | Three goto fail statements violated the selected structural rule. Replace them with structured short-circuit initialization and explicit cleanup. goto alone was not a runtime defect. | Source inventory; compiler |
| [Sensor:288](../Utils/SenseHat/sense_hat_environment.c#L288) (A17) | Medium; Defect | Sensor aggregate read | Requirements/optional channels | A failed optional humidity or pressure read discarded valid temperature. Require temperature, expose unavailable optional values as NAN and clear their sample presence flags. Initialization still requires both devices. | SD optional-pressure failure |
| [Computation:40](../Development/CritterProduct/Pilot/Computation/critter_computation.c#L40) (A18) | Medium; Defect; prior AI example | Computation trend | Requirements/known-answer correctness | Using latest-minus-mean over the full duration halved a linear ramp slope. Store first temperature and use endpoint delta; a one-sample window has zero slope. This is a model change, not proof of HVAC prediction accuracy. | SR 0.5 C/s ramp and 28.5 C prediction |
| [Computation:54](../Development/CritterProduct/Pilot/Computation/critter_computation.c#L54) (A19) | High; Defect | Computation HVAC classification | Requirements/source awareness | CPU or mixed readings could drive ambient heating/cooling claims. Suppress HVAC activity/heating/cooling flags for CPU or UNKNOWN summaries; preserve source and numeric trend. | SR mixed-source flags; code inspection |
| [Main:66](../Development/CritterProduct/Pilot/main.c#L66) (A20) | Medium; Defect | Main acquisition failure | Requirements/fault tolerance | A single all-sources read failure stopped the whole run. Count the failed attempt as rejected and continue the bounded collection; fail if no usable summary results. | CF initial read failure followed by recovery |
| [Main:77](../Development/CritterProduct/Pilot/main.c#L77) (A21) | Low; Coding-rule/error-handling finding | Main console/flush paths | P10-7; ERR33-C for fflush | Progress and results ignored console failures. Check normal output/flushes. Cast the final error diagnostic to void because failure cannot change an already-failing exit. | Compiler and source review; CF normal output |
| [Main:103](../Development/CritterProduct/Pilot/main.c#L103) (A22) | High; Defect | Main metrics-save failure | P10-7; error propagation | A metrics-write failure only printed a message; main still returned zero. Persist before reporting success and propagate a failing exit status. | CF injected metrics failure |
| [IO:75](../Development/CritterProduct/Pilot/IO/critter_io.c#L75) (A23) | Low; Coding-rule finding; prior AI example | Main and long IO/Memory functions | P10-4 | Large collection/reporting and file-handling functions impeded review. Split responsibilities and remove duplicated path/source logic; check physical function lengths. | function-sizes.txt; tests |
| [Build:9](../Development/CritterProduct/Pilot/CMakeLists.txt#L9) (A24) | Low; Process/configuration finding | CMake warning configuration | P10-10 | Restrictive warnings were not established by the project itself. Enable Wall/Wextra/Wpedantic/Wconversion/Wshadow/Wformat=2 and Werror for GCC/Clang. Historical daily analysis remains unverified. | Clean strict host build |
| [Memory:31](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L31) (H01) | High; Defect | Memory numeric statistics and sample bounds | P10-7; FLP32-C precondition support | Finite-but-extreme values could overflow sum, median or squared differences and yield nonfinite statistics. Use a documented broad arithmetic envelope, half-sum median, online mean and a checked finite/nonnegative sqrt domain. | SR extreme values; MC; sanitizers |
| [Memory:110](../Development/CritterProduct/Pilot/Memory/critter_memory.c#L110) (H02) | Medium; Defect | Memory timestamp acceptance | Requirements/time integrity; P10-7 | Positive finite timestamps alone allowed backward or duplicate history. Reject nonincreasing acquisition timestamps before retaining a sample. | SR duplicate timestamp; source review |
| [IO:327](../Development/CritterProduct/Pilot/IO/critter_io.c#L327) (H03) | Medium; Defect | IO save_sample input gate | P10-7; requirements | Only the outer pointer was checked before writing samples. Invalid fields could be published before memory validation. Reuse the sample predicate and normalize absent optional fields. | SR NAN save rejection |
| [IO:46](../Development/CritterProduct/Pilot/IO/critter_io.c#L46) (H04) | High; Conditional filesystem risk | IO runtime Data directory | FIO45-C | Separate stat/mkdir and later pathname reopen relied on a stable directory. Anchor mkdir/open operations to descriptors and disallow final symlinks. Ancestor trust and hardlink policy still require deployment review (O03). | Code review; SR leaf-symlink check; target runtime pending |
| [IO:350](../Development/CritterProduct/Pilot/IO/critter_io.c#L350) (H05) | Medium; Defect | IO save_metrics input gate | P10-7 | Metrics export accepted inconsistent counts and nonfinite serialized numbers. Check count relationships, rate, ratio and numeric fields before creating the output. | FI valid export fixture; source review |
| [Sensor:95](../Utils/SenseHat/sense_hat_environment.c#L95) (H06) | Medium; Portability hardening | Sensor read_int16 | INT31-C; INT35-C | High-bit 16-bit values were converted to signed using an implementation-defined out-of-range cast. Assemble in uint32_t, subtract 65536 in int32_t, then narrow within range. No wrong Pi result was demonstrated. | SD 0/32767/-32768/-1 decoding |
| [Sensor:221](../Utils/SenseHat/sense_hat_environment.c#L221) (H07) | Medium; Boundary hardening | Sensor temperature/humidity calibration | P10-7; math preconditions | Direct reads trusted public calibration fields. Reject equal calibration endpoints and nonfinite/out-of-range calibration. Valid initialization already rejected zero spans; no normal-initialization divide-by-zero was demonstrated. | SR/SD invalid calibration |
| [Sensor:279](../Utils/SenseHat/sense_hat_environment.c#L279) (H08) | Medium; Portability hardening | Sensor pressure sign extension | INT31-C; INT35-C | 24-bit sign extension depended on an out-of-range uint32_t-to-int32_t cast. Convert the representable 24-bit value then subtract 2^24 for negatives. | SD signed pressure case |
| [Computation:5](../Development/CritterProduct/Pilot/Computation/critter_computation.c#L5) (H09) | High; Defect; prior AI example | Computation summary/horizon validation | P10-7; numeric integrity | A NaN summary or invalid time interval could return success with an invalid prediction. Check all arithmetic inputs, ordering, numeric envelope and nonnegative horizon; leave output unchanged on failure. | SR NaN, negative horizon, zero-duration cases |
| [Main:28](../Development/CritterProduct/Pilot/main.c#L28) (H10) | Low; Defensive hardening | Main timespec subtraction | INT32-C; FLP36-C review | Subtracting time_t before conversion relies on its arithmetic range. Convert operands first and reject nonfinite/backward observations. Normal monotonic clock values did not demonstrate overflow in the original. | CF frozen/large-jump clock |
| [Main:39](../Development/CritterProduct/Pilot/main.c#L39) (H11) | Medium; Conversion finding plus simplification | Main progress cast and sleep duration | FLP34-C | An unusually large elapsed interval could exceed int before reporting. Cap the displayed value at 60 before casting; use an exact integer 100 ms delay. Original casts of the constant 0.1 were already in range. | CF large clock jump; sanitizers |
| [Main:57](../Development/CritterProduct/Pilot/main.c#L57) (H12) | Medium; Coding-rule finding | Main collection loop | P10-2 | Clock-based termination did not provide a static iteration cap. Add at most 600 attempts and at most three interrupted-sleep retries. This is not a wall-clock/WCET guarantee. | CF frozen clock stops at 600 attempts |
| [Sensor:127](../Utils/SenseHat/sense_hat_environment.c#L127) (H13) | Low; Compiler diagnostic cleanup | Sensor calibration masks/ODR composition | INT31-C review; P10-10 | The strict compiler found three implicit-narrowing diagnostics. Use unsigned assembly and an explicitly range-justified ODR cast. These masked values were already representable; no data-loss bug was demonstrated. | Strict compiler; SD |
| [Computation:59](../Development/CritterProduct/Pilot/Computation/critter_computation.c#L59) (A26) | Medium; Defect | Computation HVAC flags | Requirements/logical consistency | At a 0.04 C/s slope with low variance, likely_heating could be true while likely_hvac_active was false. Include heating/cooling in the activity condition. | SR slow warming classification |

## All 57 AI/tools-first rules

“Reviewed; no finding” means no violation was identified in this source review with the stated evidence; it is not proof of universal compliance. “N/A” means the relevant construct is absent in production. Reserve candidates retain their agreed AI/tools-first assignment; none were silently omitted. CERT mappings use the repository's [2016-edition inventory](../Resources/Guidelines/SEI%20CERT%20C%20Coding%20Standard.md); MISRA was contextual reference material, not an additional exhaustive compliance audit.

| Rule | Disposition | Evidence / limits |
| --- | --- | --- |
| EXP30-C | Reviewed; no finding | Side-effecting assignments/increments are separate or explicitly sequenced by short-circuit operators; no unsequenced read/write found. |
| EXP32-C | N/A | No volatile objects/references in the production inventory. |
| EXP34-C | Fixed gap | A01 guards ring state and public pointers. U01 was already guarded; it is not an extra null-dereference finding. |
| EXP35-C | N/A | Compound-literal assignments initialize named objects; no modification of an array in a temporary returned aggregate. |
| EXP36-C | Reviewed; no finding | No incompatible-alignment pointer cast in production; heap-result casts were removed with allocation. |
| EXP37-C | Reviewed; compiler-supported | Prototypes/callers updated together, including const handles and close status. Restrictive format/type diagnostics pass. |
| EXP39-C | Reviewed; no finding | Register bytes are combined numerically; no incompatible typed alias accesses identified. |
| EXP40-C | Reviewed; no finding | No write through a cast removing const. S03–S08 improve declarations but were not violations of this rule. |
| EXP42-C | N/A | No whole-structure memcmp or padding comparison. |
| EXP43-C | Reviewed; no finding | Private replay-path storage is distinct from getenv storage; the bounded memcpy regions do not overlap under the API contract. |
| EXP44-C | Reviewed; no finding | sizeof operands are types/objects without relied-on side effects; no relevant _Alignof/_Generic use. |
| EXP45-C | Reviewed; no finding | The intentional fgets assignment/test is explicit; no accidental assignment used as an unqualified selection condition. |
| EXP46-C | Reviewed; no finding | Sensor bitwise operations use numeric masks; Boolean predicates use logical operators. |
| INT30-C | Fixed gap | A01/A03 bound ring arithmetic and lifetime counters; no unchecked wrap is required for the retention algorithm. |
| INT32-C | Reviewed; hardened | H10 removes time_t subtraction before conversion. Sensor differences fit int32_t; H06/H08 explicitly represent signed wire values. |
| INT33-C | Fixed gap | A01 validates nonzero capacity before remainder; other integer divisors are nonzero constants. |
| INT34-C | Reviewed; no remaining finding | Wire assembly uses uint32_t with constant shifts 6/8/16 or a validated ODR shift of 4; all counts fit the width. |
| INT35-C | Reviewed; improved precision declarations | H06/H08/H13 use fixed-width unsigned assembly and range-preserving signed conversion; target compiler check remains O05. |
| INT36-C | N/A | No production pointer/integer conversions. |
| FLP30-C | Reviewed; no violation | Original elapsed_s was recomputed from a clock, not a floating-point induction counter. Current outer loop additionally uses an integer cap. |
| FLP36-C | Partly established | A03 caps counters below the exact-integer range of double; timestamp subsecond precision still needs a project error budget (O06). |
| FLP37-C | N/A | No floating-point object-representation comparison. |
| ARR32-C | N/A | All arrays have compile-time bounds; no VLAs. |
| ARR36-C | N/A | No subtraction or ordered comparison between pointers to unrelated arrays. Null/end equality checks are allowed. |
| ARR37-C | Reviewed; no finding | Path offsets refer to the same character arrays returned by readlink/fgets; pointer arithmetic is within those arrays. |
| ARR38-C | Fixed gap | A01/U13/U14 establish fixed object sizes; bounded copy/read arguments match actual storage and reject truncated paths. |
| ARR39-C | Reviewed; no finding | Element indices are not multiplied by sizeof before pointer arithmetic. |
| STR30-C | Reviewed; no finding | String literals are only read; path modification operates on writable arrays. |
| STR32-C | Fixed gap | A11 terminates validated readlink output; CSV strings are used only after successful bounded reads. U06/U09/U10 remove truncating path copies. |
| STR34-C | N/A | No problematic signed-char-to-integer conversion in production; sensor bytes use uint8_t. |
| STR37-C | N/A | No ctype classification calls. |
| STR38-C | N/A | No wide-character/string APIs. |
| MEM30-C | Fixed related state gap | A01 rejects the cleared memory-module state. Application heap ownership was removed; descriptor lifetimes are separately reviewed under FIO42/FIO46. |
| MEM33-C | N/A | No flexible array members. |
| MEM34-C | N/A after change | No explicit application free calls remain. critter_memory_free now resets its embedded object; it does not deallocate an arbitrary pointer. |
| MEM36-C | N/A | No realloc or extended-alignment reallocation. |
| FIO30-C | Reviewed; no finding | Output formats are literals, and header/source strings are passed as data arguments. |
| FIO32-C | Fixed gap | A06 rejects FIFO/device/directory inputs where file semantics are required; CPU sysfs temperature remains a supported read-only regular interface. |
| FIO34-C | N/A | No getchar/fgetc-style return narrowing to char. |
| FIO37-C | Reviewed; no finding | No strlen(buffer)-1 assumption. Newline and comma searches tolerate an empty successful read without underflow. |
| FIO38-C | N/A | No FILE object copies; only owned stream pointers. |
| FIO39-C | N/A | Streams are read-only or append-only, never update streams requiring read/write sequencing. |
| FIO40-C | Reviewed; no finding | Buffers are parsed only after successful fgets; failed reads do not publish new sample output. |
| FIO41-C | N/A | No relevant character IO calls with side-effecting stream arguments. |
| FIO42-C | Fixed gaps | A05/A09/A10 and U03/U08/U12 close owned resources and propagate useful failures. A live sensor handle must be closed before reinitialization. |
| FIO44-C | N/A | No fsetpos. Replay offsets come from checked ftello on the same tracked file identity, then checked fseeko. |
| FIO46-C | Reviewed; corrected lifecycle | ferror is checked before close, streams are not reused afterward, and sensor descriptors are invalidated on shutdown. |
| FIO47-C | Reviewed; compiler-supported | All production format strings and promoted argument types pass -Wformat=2 with -Werror. |
| ERR30-C | Fixed conversion handling | A07/A10 clear errno before strtod and test ERANGE before unrelated calls; mkdirat examines errno only on failure. |
| ERR32-C | Reviewed; no finding | No saved/indeterminate errno is used after intervening cleanup calls. |
| P10-1 | Fixed gap | A16 removes three goto branches; production call flow has no direct/indirect recursion or setjmp/longjmp. |
| P10-3 | Application allocation fixed; process-wide open | U13/U14/A02 remove explicit heap allocation. libc stream creation can still allocate at runtime; no process-wide allocation-free claim (O04). |
| P10-4 | Refactored; measured | A23 decomposes long functions. Final function-sizes.txt records every production C function at no more than 60 physical lines, a conservative screening measure rather than a formal print-format proof. |
| P10-6 | Fixed observed gaps | S01/S02 and nearby loop declarations reduce scope; shared sensor state is file-local only because acquisition and shutdown both own it. |
| P10-8 | Reviewed; documented exceptions | No token pasting, variadic macros or recursive macros in production. Header/C++ guards and two Linux host-condition branches are justified by API/OS compatibility. Test interposition is outside production compliance scope. |
| P10-9 | Reviewed; no observed violation | No application function pointers, pointer typedef aliases or double-indirect object chains; ring storage is embedded. strtod output-end pointer is a standard library interface, not a hidden application dereference. |
| P10-10 | Improved; historical/target evidence open | A24 enables strict builds; current target-config Cppcheck and host Clang scans pass. Broad scans retain explained style findings. No evidence establishes analysis on every past development day (O05). |

## Separate reassessment of all 13 human-first rules

This pass reconsidered the original flags, corresponding fixes, public input contracts and remaining failure paths. It also found H01–H13 and the logical implication A26. The table retains unresolved requirements rather than turning clean builds into a blanket pass.

| Rule | Conclusion | Evidence and remaining concern |
| --- | --- | --- |
| EXP33-C | No confirmed baseline violation from your annotations | Checked initialization through successful reads, summary construction and analysis. The recorded IO labels concern return handling, not uninitialized data. Temporary output objects are committed only on success; SR/FI and host Clang support the review, but ASan is not MemorySanitizer. |
| INT31-C | Portability gaps addressed; target assumptions remain | U04 removes size_t narrowing; H06/H08 make signed wire decoding explicit; H13 resolves three compiler narrowing diagnostics. Existing masked values already fit. Simulated boundary decoding passes; real Pi compiler/hardware verification remains O05. |
| FLP32-C | Math preconditions strengthened | H01 bounds arithmetic and checks variance before sqrt; H07 rejects invalid calibration, and H09 validates computation inputs. Calibration division and prediction formula correctness are not themselves proved by the sqrt-domain rule. Remaining model/outlier issues are O01/O07. |
| FLP34-C | Flagged conversion risk fixed | H11 bounds elapsed-time conversion before casting to int and uses an exact integer sleep duration. Prior constant 0.1 conversions were in range. CF large-clock test and float-cast-overflow sanitizer pass. |
| ARR30-C | Concrete gaps fixed | A01 checks ring capacity/head/count before indexing; fixed storage caps indices; source enums are validated before indexing count-by-source. SR exercises zeroed, cleared, oversized and corrupt state plus wraparound. |
| STR31-C | Path-completeness gaps fixed | U06/U09/U10 remove silent truncation; A11 rejects incomplete executable paths. Original snprintf did not overrun its destination; the confirmed defect was using a truncated pathname. Deployment path authority remains O03. |
| MEM31-C | Ownership simplified; current application heap N/A | A02 removes explicit heap ownership, including potential repeated-init leaks, and U13/U14 remove temporary allocation. No allocated object remains for critter_memory_free to leak. FILE/device resource ownership is separately covered by FIO42. |
| MEM35-C | Sizing made explicit | The ring and temporary arrays are compile-time sized for 100 entries; init rejects zero/larger capacities. No runtime allocation product remains. This changes the public supported-capacity contract to 1..100. |
| FIO45-C | Mitigated, not fully closed | H04 anchors the default directory operations and rejects final symlinks. Configured path ancestors, shared/writable parent directories, existing hardlinks and concurrent writers require a deployment policy (O03); current tests do not prove hostile-filesystem safety. |
| ERR33-C | Recorded failures fixed; justified exceptions documented | All supported user IO-return findings were addressed along with A09/A10/A14/A21/A22. FI tests real header/row/close failure paths and CF tests caller propagation. POSIX returns use P10-7/error-handling rationale; ERR33-C alone is not a blanket POSIX rule. |
| P10-2 | Fixed iteration limits; timing limit remains | U02 caps CSV records at 4096, H12 caps acquisition at 600 and sleep retries at three, and A02 caps memory loops at 100 (nested median work at most 10,000 comparisons). Blocking kernel/filesystem behavior still prevents a hard wall-clock guarantee (O06). |
| P10-5 | Open; not claimed compliant | The production code has defensive predicates but no audited assertion scheme demonstrating an average of two meaningful assertions per function. Test asserts are not production assertions. Do not count proven-redundant checks or insert aborts just to satisfy a quota; define recovery and assertion evidence (O02). |
| P10-7 | Many gaps fixed; contract review remains | U/H/A rows trace validation and return handling through the public APIs and callers. Failure cleanup/last diagnostic explicitly discard returns with reasons. Private ring/index/statistics helpers rely partly on established caller invariants; an exhaustive assertion/parameter-contract proof is not established (O02/O06). |

## Remaining pain areas and next actions

| ID | Priority | Evidence / problem | Next action and why it remains open |
| --- | --- | --- | --- |
| O01 | High | **Outlier adaptation can freeze the retained baseline.** A run with 3 values at 20 C followed by 20 at 25 C retains only the original 3 and counts all 20 later values as outliers. See [reproduction](../review-results/safety-review-2026-09-14/open-outlier-policy.log). Different sensor sources are also compared against the same retained window. | Define how a sustained real change is distinguished from a failing sensor. Evaluate a bounded history of all valid readings for detection, source-separated baselines, or an explicit confirmed-change/rebaseline policy. This report preserves the filtering policy instead of silently selecting an arbitrary number of outliers to trust. It is a functional requirement/design issue, not evidence of an ARR30-C violation. |
| O02 | Medium | **P10-5 remains open.** No verified production assertion density/recovery scheme exists, and some private helpers rely on caller invariants. | Identify meaningful ownership/index/numeric invariants, establish recovery actions, and measure the complete assertion scheme. Standard assert's default process abort and proven-redundant checks are not substitutes for that review. |
| O03 | High if shared/untrusted paths | **Filesystem trust remains conditional.** Final symlinks/special files are rejected, and default directory operations are descriptor-relative; configured ancestor components, hardlinks, old permissive directories and simultaneous appenders are not fully controlled. | Specify trusted ownership/permissions for configured directories and one writer per CSV, or implement component-by-component directory traversal plus an approved ownership/hardlink/concurrency policy. No permissions on existing user directories were silently rewritten. FIO45-C is mitigated, not certified closed. |
| O04 | Medium | **Process-wide P10-3 is unverified.** Application malloc/calloc/free calls are gone, but fdopen and other libc operations can allocate internally during collection. | If the project requires a strict whole-process allocation ban, use a bounded preopened IO plan/static stream buffers or descriptor IO, and measure allocator activity on the target. The present change establishes explicit application-allocation removal only. |
| O05 | Medium | **Target/process evidence is incomplete.** The Mac does not exercise real Linux I2C initialization or successful Pi thermal reads, and history does not show daily static analysis. Broad Cppcheck also reports explained host/API style notes. | Run the same strict build/tests and Linux analyzer configuration on the Pi; retain versions/logs and evaluate actual sensor behavior. Establish ongoing analysis records. Do not claim historical P10-10 compliance or full CERT certification. |
| O06 | Medium | **Timing and precision requirements need decisions.** Iteration limits are finite, but filesystem/I2C latency has no demonstrated wall-clock bound. Time uses double seconds, intervals are currently fixed, and replay assumes a stable input file while reading. | Define sampling jitter/precision budgets, configurable supported frequencies, IO timeout/watchdog expectations and input-file immutability. Measure on the Pi. The one-minute host run is a behavioral check, not a WCET result. |
| O07 | Medium | **HVAC model thresholds/provenance still need validation.** The ramp formula and heating-implies-active bug are fixed, but thresholds remain heuristic. A slowly rising window can still be described as stable under the existing tolerance. Replayed data is labeled DATA, without verifying whether its original source was ambient. | Define intended flag semantics and acceptable forecast errors; validate against known room/HVAC datasets. Preserve original source metadata if replayed CPU measurements may occur. False HVAC flags for CPU/mixed inputs mean inference is withheld, not that HVAC is proven off. |

O01 and the coverage gaps are deliberately excluded from the fixed-incident count. Nothing in this report asserts that all 70 rules passed or that the Pilot is safe for deployment.

## Behavior/API changes to account for

- The memory API now supports **1–100 samples** with embedded storage; requests above 100 fail. `critter_memory_free` resets the object and repeated cleanup is safe. Do not use the public struct with invented capacity/head values.
- `CRITTER_DATA_FILE` is now **input only**. Use **`CRITTER_OUTPUT_FILE`** for saved sample CSV and `CRITTER_METRICS_FILE` for metrics. Default outputs remain `Data/` next to the Linux executable. The default input now names the repository's actual Pilot data path; set it explicitly when starting from a different working directory.
- Replay advances through records. **EOF or source loss returns failure and allows CPU fallback**; no cached or automatic cyclic replay is reported as a fresh sample. Input records exceeding 255 characters, an overlong path, or an acquisition needing more than 4096 scanned records are rejected.
- Sample numeric magnitude and positive timestamps are limited to **1e100** to make double arithmetic bounded; this is deliberately broad numerical protection, not a physical calibration range. Summary horizons use the same upper envelope and must be nonnegative. Multi-sample summaries require at least **1 microsecond** between first/last times. Lifetime counts stop at **1 billion** instead of wrapping.
- `sense_hat_environment_close` now returns a status, and `critter_io_close` provides application shutdown. Read/set functions take const handles. A live handle must be closed before another initialization. Missing optional channels after initialization are exposed as unavailable; initialization still requires both Sense HAT devices.
- `critter_window_summary_t` gains `first_temperature_c`; code constructing summaries directly must populate it consistently. The trend is an endpoint estimate, not a fitted regression. CPU/mixed histories do not produce affirmative HVAC activity/heating/cooling claims.
- Existing error diagnostics whose failure cannot alter an already-failing result are intentionally best-effort. A failed CSV append may still leave a partial row; this change detects failure, it does not provide transactional rollback or power-loss durability.

## Validation and reproducibility

The final strict host build and the registered test suite are recorded under [review-results/safety-review-2026-09-14](../review-results/safety-review-2026-09-14/). The suite has **9 registered tests: 8 pass, 1 explicitly skips** because the Pi CPU-temperature interface is absent. The source-specific test verifies available DATA input; “passed” does not mean a Sense HAT was present. Test-only interception/macros and simulated register values are not production code or physical hardware evidence.

| Check | Result / limits | Artifact |
| --- | --- | --- |
| C11 strict compiler build | Zero warnings with Wall/Wextra/Wpedantic/Wconversion/Wshadow/Wformat=2 and Werror on the available Clang. | [build.log](../review-results/safety-review-2026-09-14/build.log), [compiler version](../review-results/safety-review-2026-09-14/compiler-version.txt) |
| Registered tests | 8 passed, 1 hardware skip. | [tests.log](../review-results/safety-review-2026-09-14/tests.log) |
| AddressSanitizer + UndefinedBehaviorSanitizer + float-cast-overflow | Same 8 passes/1 skip, no reported sanitizer failures. This is not an exhaustive memory proof or MemorySanitizer run. | [sanitizers-tests.log](../review-results/safety-review-2026-09-14/sanitizers-tests.log) |
| Cppcheck with explicit Linux configuration | Exhaustive branch level, warning/style/performance/portability categories, unix64 and __linux__; no source diagnostics. This is analysis configuration, not an actual Linux compile. | [cppcheck-target.log](../review-results/safety-review-2026-09-14/cppcheck-target.log), [checker inventory](../review-results/safety-review-2026-09-14/checkers-target.txt) |
| Broad Cppcheck exploration | Seven retained style observations: two always-failing host sensor-open branches (intentional unsupported-host behavior), five suggestions to make published utility API functions static (rejected to preserve the reusable API). The earlier newly introduced local const suggestion was fixed. | [cppcheck-all-configurations.log](../review-results/safety-review-2026-09-14/cppcheck-all-configurations.log) |
| Clang static analyzer | No diagnostics in all five production C translation units for the Mac configuration; Linux-only I2C branch is not compiled by this check. | [clang-analyzer.log](../review-results/safety-review-2026-09-14/clang-analyzer.log) |
| Function size/source checks | Production C functions screened at <=60 physical lines; no explicit application heap allocation, goto or function pointers. | [function-sizes.txt](../review-results/safety-review-2026-09-14/function-sizes.txt) |
| One-minute real host replay | Normal unaccelerated Pilot execution saved samples and metrics and returned zero. Uses a supplied fixture and separate temporary output files; no hardware inference. | [pilot-run.log](../review-results/safety-review-2026-09-14/pilot-run.log), [metrics](../review-results/safety-review-2026-09-14/pilot-metrics.csv), [exit code](../review-results/safety-review-2026-09-14/pilot-exit.txt) |
| Diff hygiene | git diff --check passes; original annotations preserved. | [human-annotations.patch](../review-results/safety-review-2026-09-14/human-annotations.patch) |

The analyzer logs name their enabled scope. Missing system includes are suppressed for Cppcheck's source-level run; missing application includes are not globally suppressed. The broad exploration excludes unusedFunction but keeps the public-API staticFunction suggestions visible. These runs supplement rule-by-rule review and are not a dedicated 70-rule conformance checker.

From the repository root, reproduce the portable build/tests with:

```sh
cmake -S Development/CritterProduct/Pilot -B /tmp/critter-safety-build -DCMAKE_BUILD_TYPE=Debug
cmake --build /tmp/critter-safety-build
ctest --test-dir /tmp/critter-safety-build --output-on-failure
```

The same commands on the Pi exercise the real Linux build; a Sense HAT is still needed to verify successful I2C sensor behavior. For the current analyzer command and sanitizer options, see the saved [verification commands](../review-results/safety-review-2026-09-14/verification-commands.md).
