@title Evaluating Memory Reduction for the Critter Embedded System

@abstract Abstract—This study evaluates memory reduction for the Critter, a Raspberry Pi 5 prototype for unattended machine-room temperature monitoring. Twenty-nine configurations examine compiler groups, individual passes, linking, data layout, stack use, and allocation strategy. Twenty-eight passed behavior checks and produced 336 screening trials across three units and their integrated pipeline. Fully static linking produced the largest repeatable reduction in GNU time's reported peak resident memory, from 1,088 to 544 KiB in the pipeline. However, diagnostic proportional memory was higher, and resident-memory counters disagreed, so this result does not establish a universal RAM winner. Reusing a workspace reduced explicit allocation calls from 22,199 to two without reducing peak requested heap bytes. Packing records saved 200 bytes; reducing history saved more heap but shortened the evidence available for HVAC analysis. My decisions prioritize useful history and correct processing over executable size alone. I retain -O2 as the reference, favor symbol stripping and limited inlining as candidates, and require further validation before deploying static linking, packed storage, or a combined configuration.

@keywords Keywords—embedded systems, Critter, memory optimization, GCC, resident memory, bounded allocation

# I. Introduction

The biggest memory effect in these trials depends on which memory requirement I am trying to reduce. Fully static linking halved the integrated program's reported GNU peak RSS, while a packed record reduced the application's explicit heap demand by only 200 bytes. Reusing scratch storage removed almost every recurring allocation without changing peak heap demand. These are different benefits, and my choice for Critter must follow the product's need to retain useful temperature evidence rather than the smallest number in one column.

My main priority is RAM available for acquisition, retained history, and HVAC analysis. I am more willing to accept a larger executable on the SD card than to discard history merely to obtain a smaller allocation. That preference does not make every disk cost irrelevant: storage writes, deployment size, and fault recovery still matter. I therefore ask what each change removes, whether the measured behavior remains correct, and what I gain or give up before deciding whether to keep it. The annotated workbook records that reasoning alongside the underlying trials [1], [2].

The previous power paper identified a lower-power configuration, while the timing paper showed why a favorable average can conceal an important interruption [3], [4]. This assignment extends that work by distinguishing executable code, requested heap storage, stack requirements, and resident pages. Sections II and III establish those distinctions and the controlled experiment. Section IV presents all configurations. Section V connects their mechanisms and results to my choices, including observations that changed my initial explanations. The conclusion identifies candidates and the evidence still needed before combining them.

# II. Background

## A. The Critter and the memory objective

Critter monitors distributed machine rooms. Its I/O unit acquires and saves measurements; its memory unit validates samples, rejects outliers, and summarizes recent history; its computation unit estimates temperature trends and likely HVAC behavior. The present C prototype is sequential, retains up to 100 accepted samples, and predicts 30 seconds ahead from a summary. Its predictor is brief and rule-based, so it does not represent the future computationally intensive forecasting unit described in the assignment [1], [2].

The baseline sample occupies 40 bytes. A 100-record ring therefore requests 4,000 bytes, and a temporary array of 100 doubles requests another 800 bytes during filtering or summary construction. The baseline repeatedly allocates and frees that temporary storage. The units also use C library routines, the math library, stack variables, and mapped program pages. The inspected build contains no C++ framework or large third-party prediction package to remove. An optimization must address the storage actually present rather than assume a high-level library is responsible.

## B. Memory measures and the operating system

I use GNU /usr/bin/time -v as the assignment requires, retaining its reported maximum resident set size in KiB [8]. The executable's file size and text section are separate measures. File bytes may include debugging information that is not part of the execution working set. Requested heap bytes exclude allocator bookkeeping and library allocations; individual compiler stack frames do not establish a whole-program stack bound.

Diagnostic /proc snapshots add current RSS, proportional set size (PSS), and private/shared page information. RSS counts resident shared pages in each process, while PSS assigns a proportional share [9]. These snapshots come from separately instrumented runs and must not be substituted into the screening results. The Pi uses 16 KiB pages, so a 200-byte application saving need not remove a resident page.

Linux paging also means that textbook contiguous-process allocation is not a placement policy the application selects through GCC. The practical experiment is to allocate related application buffers together and reuse storage whose lifetimes do not overlap. Likewise, lowering an allowed stack or data size is a constraint, not proof that fewer bytes are resident. These distinctions determine what I can legitimately call a memory reduction.

# III. Approach

## A. Questions and configuration design

My six questions concern linking/loading, persistent state, runtime libraries, storage partitioning, compiler transformations, and processor targeting. Stack/data limits add a test of the program's operating envelope. Each trial addresses a proposed mechanism and a product decision.

The reference is -O2. The seven compiler groups are -O0, -O1, -O2, -O3, -Ofast, -Os, and -Oz. Eight individual comparisons add loop unrolling, disable loop or SLP vectorization, disable inlining, enable LTO, remove unused sections, disable stack reuse, or strip symbols. Two configurations tune or target Cortex-A76. Three compare shared linking, delayed prediction loading, and fully static linking. Four change workspace/arena/static storage or path buffers; two change enum/record layout; one makes I/O state caller-owned; two reduce history. All individual comparisons otherwise retain -O2 [2], [5]–[7], [12].

Each build uses copied source, with its patch, flags, commands, and source hashes preserved. Production files and existing data are not overwritten. Effective compiler settings are recorded rather than inferred from group names. The controller runs with sudo on the Pi, applies limits only to test children, saves each trial incrementally, and imposes command timeouts and a two-hour campaign ceiling. The full campaign completed in 827.66 seconds, about 13.79 minutes, because these fixed workloads completed well below their maximum allowances.

## B. Platform and matched work

Collection used a Raspberry Pi 5 with 64-bit Linux 6.18.50+rpt-rpi-2712, glibc 2.41, and GCC 14.2.0. Before and after collection, the recorded throttling value was 0x0. The protocol kept power, cooling, peripherals, and background use consistent; it did not change boot memory, CPU availability, or governors. Those controls are procedural rather than continuous telemetry of every possible disturbance [2].

Separate executables exercise the existing units and pipeline. Work is calibrated using unoptimized code, then fixed within each unit: I/O performs 100 rounds of 600 samples; memory and pipeline perform 37 rounds, or 22,200 samples; computation performs 2,707 rounds of 10,000 calls. These are matched within-unit comparisons. The baseline links needed Critter archive objects with dynamic system libraries; the fully static treatment differs from that mixed arrangement.

An immutable CSV supplies 22.5 °C. The reader returns its first numeric value each time; the harness adds a deterministic triangular ramp and an outlier every 97 samples. Replay timestamps advance by 0.1 seconds without paced waiting. This exercises filling/wrapping, filtering, saving, and summary construction, but does not measure physical sensor freshness or real HVAC prediction accuracy. Computation varies its summary input and consumes a checksum. Input and output files are separate, preventing generated data from becoming the next trial's input.

## C. Validation and evidence selection

Every build first checks eight invalid-sample cases and a nonfinite prediction horizon. These cover NaN/infinite temperature, invalid timestamps, humidity/pressure bounds, and source identity. Outputs are then compared with -O0 for retained counts, outliers, summaries, predictions, flags, and saved sample rows. Smaller histories use capacity-specific references, making their intentional behavior change explicit. Passing is regression evidence for these inputs, not a complete safety or forecasting argument.

The main session contains 441 records: 336 primary screening trials, 12 combined trials, 28 allocation diagnostics, 39 limit trials, eight paced confirmations, and 18 calibration/reference runs. Three repetitions shuffle variant/unit order with seed 2160. Twenty-eight configurations pass validation; -Ofast fails five checks and is excluded. The 11 failed workload records are deliberate low-data/arena-budget trials, not hidden screening failures. A preceding 156-record Pi check remains separate because it has different work counts and one repetition. No Mac development result enters the paper.

The annotated workbook and raw archive were reconciled through 1,791 checks comparing each result record with GNU time, application output, and independently counted sample rows across both sessions. This verifies transcription and traceability, not the physical accuracy of every memory counter. Screening values are medians of three peaks, with observed ranges. A lower/higher classification requires nonoverlapping ranges against the matching -O2 unit. I make no significance-test or worst-case claim from three repetitions.

## D. Diagnostics and constrained operation

Allocation diagnostics rebuild the memory unit with explicit allocation counters; these are excluded from primary RSS measurements. Phase holds permit external /proc snapshots around initialization, working, summarizing, prediction loading/closing, and release. GCC -fstack-usage reports individual frames. File/section sizes and dependencies are retained for comparison [2].

On -O2, fewer path buffers, and the arena, stack caps are existing allowance, 1 MiB, 512, 256, 128, and 64 KiB. Data caps are 4 MiB, 1 MiB, 512, 256, 128, and 64 KiB. RLIMIT_DATA covers data and relevant allocations rather than only Critter's heap. Limits take effect inside the executable after startup; pre-existing mappings can remain. The arena separately tests an exact 4,800-byte budget, one byte less, and zero [10]. Four selected configurations receive two paced 600-sample confirmations each. No per-job deadline trace is collected in this memory campaign.

# IV. Data

Table I retains every configuration and all three standalone units. Values are median GNU-reported peak RSS in KiB; each measured cell has three screening repetitions. Heap values come from one separate pipeline allocation diagnostic. The combined candidate is a later experiment, not a fourth repetition or the final configuration selected after my workbook review. Figure 1 shows repeated pipeline observations rather than implying that all optimization groups behave alike.

{{TABLE1}}

{{FIG1}}

The -O2 pipeline median is 1,088 KiB, with a 1,072–1,088 KiB range. Fully static linking reports 544 KiB in every unit and repetition. The pipeline rises to 1,616 KiB with -O0; -Os, -Oz, and LTO reach 1,600 KiB. Most other pipeline ranges overlap -O2. Several compiler differences are therefore visible only in the integrated path, despite comparable standalone medians. The shared-library I/O and computation medians are 1,104 KiB, and their ranges sit above their respective baselines. The integrated shared-library range overlaps the baseline.

# V. Results

## A. Choosing a compiler policy from behavior and memory

I reject -O0 as the deployment choice for this workload: its pipeline peak is 48.5% above -O2. Its larger generated code and lack of optimization make it a useful reference, but an unoptimized build is not inherently a safe build. My priority is correct C, preserved invariants, and validation of the compiled program. The compiler does not independently certify safety. This is why I keep -O2 as a practical reference rather than selecting a flag on presumed safety alone.

-O1 reports 1,072 KiB, but that value overlaps the baseline's observed range. I do not call it a statistically established reduction. -O3 also reports 1,088 KiB while increasing pipeline text from 8,872 to 9,892 bytes. I see no RAM benefit that justifies selecting a more aggressive group here. That is a workload-based choice, not evidence that valid -O3 transformations are intrinsically unsafe. Compilation time was not measured, so I do not use assumed build-time savings to rank these options.

For -Ofast, my decision is clearer. Five of the nine validation cases fail, so its four workloads are not measured. The group enables assumptions that can conflict with NaN/infinity handling [5]. My annotation that it broke functionality is supported; saying it broke every function would be too broad. A faster or smaller executable that accepts invalid temperature evidence does not meet Critter's purpose. I reject it on the demonstrated behavior failures before considering memory.

-Os and -Oz both reduce pipeline text to 7,424 bytes, 16.3% below -O2, but increase reported peak RSS to 1,600 KiB, or 47.1%. I therefore reject them for this RAM-focused configuration. My original explanation that size optimization removes inlining was too simple: the saved settings show inlining enabled, both vectorization passes disabled, and -funroll-loops disabled for these groups. Smaller text does not establish fewer resident pages, and the data do not identify the mechanism behind the RSS increase. I cannot attribute it to slower SIMD instructions or claim that every inlining decision changed in the same way.

## B. Individual passes and hardware targeting

The individual comparisons refine that choice. -funroll-loops increases pipeline text to 10,696 bytes, 20.6% above baseline, with a 1,104 KiB median whose range touches the reference. I reject it as a memory optimization for this workload. The saved -O2 and -O3 settings have this flag disabled, so the result cannot be dismissed as simply repeating an already-enabled flag. Other loop transformations may still occur; selecting a flag is not proof that every eligible loop was transformed.

Disabling loop vectorization with -fno-tree-loop-vectorize leaves pipeline text at 8,872 bytes and reported RAM similar. Disabling SLP with -fno-tree-slp-vectorize produces 8,840 bytes and also has an overlapping RSS range. I remain indifferent to these changes for memory. My expectation that loops could process several values together concerns potential speed; turning vectorization off tests the cost of that capability, not an additional vectorization benefit. These trials do not show that SIMD generally increases memory or takes longer to execute.

Disabling inlining with -fno-inline reduces pipeline text to 8,456 bytes, a 4.7% saving, while retaining a 1,088 KiB median and passing the tested behavior checks. I keep this as a candidate, as my notes propose, because it reduces duplicated code without an observed RAM penalty. I do not call the measured executable universally safe: call overhead and target timing still need validation in a deployed combination. This is a useful secondary saving even though executable size is not my primary constraint.

LTO with -flto reduces pipeline text by 40.8%, to 5,248 bytes, but its reported RSS median rises to 1,600 KiB. I reject it for the present RAM objective. It analyzes across translation units [5]; neither that description nor the measurements establish increased SIMD as the cause. Removing unused sections with -ffunction-sections, -fdata-sections, and --gc-sections gives 8,584 text bytes, 3.2% below baseline, without a resolved RSS reduction. That is a modest code-footprint option rather than evidence of a smaller working set [12].

Disabling stack reuse with -fstack-reuse=none gives no resolved RSS benefit and leaves the two inspected I/O frames unchanged. Since reuse defaults to all [6], this is a control comparison, not a reason to switch it off. Symbol stripping with -s is more useful for deployment: the pipeline file falls from 122,288 to 67,912 bytes, a 44.5% reduction, while text remains 8,872 bytes and RSS stays similar. I favor stripping a deployment copy while retaining symbols for the exact build elsewhere. Removing debugging information does not establish safety, and keeping a matching symbol file supports later fault investigation.

Finally, -mtune=cortex-a76 and -mcpu=cortex-a76 both give 8,840 text bytes and a 1,088 KiB pipeline median. They tune scheduling or select processor capabilities, respectively [7], but produce no resolved RAM gain here. The Pi having ample resources does not by itself make hardware-specific generation a memory optimization. I would require a measured benefit before accepting the portability constraint as part of this memory decision.

## C. Linking choices and the meaning of the largest reduction

Fully static linking with -static is the most eye-catching result in my notes. Its 544 KiB reported pipeline peak is exactly half the 1,088 KiB baseline and repeats across all units. The executable grows from 122,288 to 896,648 bytes. I am willing to consider that disk cost because preserving RAM for monitoring and history matters more to this prototype than a small SD-card image. This is a conditional candidate, not a final proof that the program needs half as much physical RAM.

The mechanism also needs care. Static linking includes required library code in the executable; it does not remove all libraries or unused services from the running operating system. Shared Critter linking moves code into a separate library, and delayed loading introduces a load/unload path. Their integrated medians are 1,104 and 1,072 KiB, respectively, with ranges overlapping -O2. I see no clear peak-RAM benefit that justifies adding loading complexity to these small units.

Figure 2 explains why I cannot select static linking from GNU peak RSS alone. At finished work in the separate diagnostic runs, -O2 has 1,712 KiB snapshot RSS and 273 KiB PSS; fully static has 816 KiB RSS and 800 KiB PSS. Static linking has lower resident-page count in that snapshot but a higher proportional share. Sharing with other processes changes the accounting. Devices in different machine rooms cannot share physical pages with each other, but processes on the same Pi can. I would evaluate the actual deployment's process mix before choosing which memory budget matters.

{{FIG2}}

There is a second limitation within those same diagnostic records. GNU time reports a 1,088 KiB peak for -O2 while its sampled RSS reaches 1,712 KiB at finished work. The corresponding static values are 528 and 816 KiB. A claimed historical peak below a sampled resident value requires investigation. I preserve the assignment's raw measure and the /proc observations, verify the snapshot PID markers, and leave the discrepancy unresolved. Repeated raw results establish repeatability of the reported metric, not a demonstrated cause or an exact physical-memory saving.

Delayed loading also shows a phase-specific effect: prediction raises diagnostic RSS from 1,712 to 1,776 KiB; closing it lowers that to 1,728 KiB, still above the pre-load value. PSS changes from 273 to 337 and then 289 KiB. This supports describing some unloading, not a complete return to the earlier state or a lower process peak. The loader documentation likewise does not promise immediate removal on every dlclose call [11]. I would revisit this tactic for a substantially larger, infrequently used predictor rather than add it to the present small one.

## D. Allocation lifetime and actual storage requirements

The baseline makes 22,199 explicit memory-unit allocations during a 22,200-sample diagnostic pipeline run. Reusing one scratch buffer reduces that to two allocations; placing ring and scratch storage in one arena reduces it to one. Both still request a peak of 4,800 bytes and have a 1,088 KiB screening median. The benefit is fewer recurring allocations and a clearer ownership/lifetime, not a demonstrated reduction in peak bytes. Figure 3 separates these quantities.

{{FIG3}}

My notes pass over the two heap variants after seeing that static storage eliminates these allocations entirely. That preference should be explained as a choice about bounded ownership and recurring work. The static version reserves a ring and scratch array and supports one memory instance; its state grows from 72 to 80 bytes, and array storage remains in static data. Its 1,072–1,088 KiB pipeline range overlaps -O2. I would consider it for this fixed single-instance prototype, but I cannot claim that zero explicit heap means zero RAM or that static storage is smaller than the arena. A multi-instance design would require a different ownership arrangement.

The stack experiment offers a direct source-level improvement. Reworking path construction reduces the sample-saving function's reported frame from 8,240 to 4,144 bytes and the directory helper from 8,352 to 4,256 bytes. The pipeline median remains 1,088 KiB. I view this as evidence that less simultaneous scratch storage is required, even though a page-level RSS change is unresolved. It does not justify adding these frame sizes together without analyzing the call path. Moving sensor initialization and cached-temperature state into a caller-owned I/O context likewise gives no RSS reduction. Small persistent variables have a purpose; relocating them alone does not remove their storage.

## E. Data representation and the history I would preserve

Packing internal ring records is a candidate I favor because it saves requested storage while retaining the 100-sample capacity. The public sample remains 40 bytes, but the internal record becomes 38 bytes. The ring saves 200 bytes and peak explicit heap falls from 4,800 to 4,600 bytes, a 4.2% reduction. The pipeline RSS median stays at 1,088 KiB. My note described a large byte reduction; the verified saving is modest in absolute terms, and I would report it that way. Unaligned access and representation boundaries still need timing and interface checks; passing the replay does not establish every access is suitable on every target.

Short enums with -fshort-enums provide an instructive neutral result. Although the compiler permits a narrower enum representation, the retained record remains 40 bytes because overall layout/alignment still matters. Heap peak stays 4,800 bytes, so I see no storage benefit that warrants changing binary-interface assumptions. The packed internal record is more targeted than applying blanket structure packing to public or system-library types [6].

Reducing the history to 50 or 25 samples halves or quarters peak requested heap, to 2,400 or 1,200 bytes. It does not resolve a lower RSS median. More importantly for my decision, the final retained time span falls from 10.0 seconds to 4.9 or 2.4 seconds in this replay. All three reject 228 outliers, but their means and standard deviations differ; predictions are approximately 22.35208, 22.35100, and 22.35100 °C. Their closeness on this gentle synthetic trace does not establish equivalent accuracy during an HVAC cycle or a real temperature excursion.

I therefore retain the 100-sample window for the present candidate. The product needs evidence to distinguish a transient reading from a sustained trend, and I have no demonstrated accuracy allowance that permits discarding most of that history. A smaller buffer could be appropriate after a study of warning delay, room dynamics, and forecasting error. The measured heap reduction alone does not answer that product question. Preserving history is also not proof that the present prediction model is accurate.

## F. Limits and combined configurations

All 18 stack trials pass, including the 64 KiB cap on each of the three tested implementations. Those limits are set after startup, when a mapping already exists; diagnostic stack mappings are 144 KiB. The results do not prove that a fresh process needs only 64 KiB or that lowering the allowance reclaimed existing resident pages. My concern about making a stack too small is valid, but the right response is measured call-path requirements with margin, not a declaration that the lowest passing cap is safe.

Data limits of 512 KiB, 1 MiB, and 4 MiB pass for all three implementations; 256, 128, and 64 KiB fail during initialization with exit code 3. That brackets observed operation between tested settings, rather than identifying an exact heap requirement. The arena makes a narrower statement: a 4,800-byte application budget passes; 4,799 and zero are rejected before collection. Those controlled failures are preferable to treating a reduced limit as a saving or assuming every exhaustion must appear as a segmentation fault [10].

The automated combined candidate uses -O1, LTO, section removal, and the arena. Its pipeline median is 1,584 KiB, 45.6% above -O2, so I do not choose it for reduced reported RAM. Its storage arrangement and code reductions do not make individual benefits additive. This bundle was selected before my annotations and does not test the combination I now favor.

The two longer paced confirmations each report 1,088 KiB for -O2 and -O1, 544 KiB for fully static, and 1,600 KiB for the combined candidate. They support the broad reported-RSS ordering, but do not remove the counter discrepancy or establish deadline compliance. I would next compare a validated -O2 deployment copy with symbols stripped, limited inlining, and carefully bounded storage. Packed records and fully static linking remain conditional candidates. Their combined effect has not been measured; I do not assign the proposed final build a saving from separate percentages.

## G. Critter decisions and broader embedded systems

My overall view remains that RAM should serve the monitoring product. I would accept a larger executable when it preserves useful history and demonstrably reduces the memory budget that constrains deployment. Symbol stripping is a secondary file saving, not evidence that additional RAM became available for samples. Likewise, removing allocation churn can improve how I reason about a recurring path without making the measured resident footprint smaller. This explains why some technically successful transformations are not my first choice for this particular objective.

Soft real time gives Critter room to consider an explicitly acceptable delay or recoverable missed observation. It does not permit incorrect temperature validation, corrupted history, or silently misleading predictions. My rejection of -Ofast follows that distinction. I would trade measured execution margin against memory only after defining allowable acquisition gaps and report age; this campaign did not define or validate a new tolerance. That preserves the reasoning from the earlier timing paper instead of assuming that a noncritical average makes all delays harmless [4].

The autonomous-driving example in my notes strengthens the same requirement. A memory-heavy perception or planning system may benefit from fixed capacities and compact representations, but required accuracy and reaction deadlines constrain those choices. A transformation is not acceptable merely because it is useful on Critter, and a missed safety-critical response cannot be treated as an ordinary recoverable monitoring delay. The appropriate lesson is to state the required behavior and memory envelope together, then support both on the actual target.

## H. Limits of the conclusions and next validation

Three short screening repetitions and one diagnostic per variant provide descriptive evidence. Diagnostic phase holds, allocation counters, and shared-page ownership differ from uninstrumented operation. The source/record checks establish consistency, while the GNU versus /proc discrepancy prevents a stronger physical-memory claim. My first follow-up is matched uninstrumented long runs with same-process counter comparison and a controlled process mix, particularly for static linking and LTO. I would also keep the exact deployed binary and its symbols to support investigation.

The replay has no sensor transactions, communication backlog, changing room traces, or large historical model. Fixed 100-sample storage and a brief predictor limit generalization to the course product's future workload. Correctness tests do not repair pre-existing source-identity or failure-handling defects; the original outlier allocator can fail open when scratch allocation fails. Future trials should inject allocation, I/O, and communication faults; exercise real ramps and HVAC cycles; and combine the selected changes while recording per-job timing and prediction error. I would only then decide whether the proposed memory envelope is appropriate for unattended use.

# VI. Conclusion

The largest repeatable reduction in the required GNU-reported peak-RSS measure came from fully static linking: 1,088 to 544 KiB for the pipeline. That result is qualified by higher diagnostic PSS and disagreement between memory counters. -Os, -Oz, LTO, and the automated combined candidate show why smaller code does not guarantee smaller reported RAM. Reusable storage reduces allocations from 22,199 to two, one, or zero explicit heap calls; packed records save 200 heap bytes; fewer path buffers nearly halve an important function frame. These benefits answer different memory questions.

For Critter, I retain useful history and correct processing as the constraints on optimization. I favor a validated -O2-based deployment candidate with secondary file/code reductions, and keep packing and static linking conditional on interface, timing, and memory-accounting validation. I do not claim the untested combination is already optimal. The value of this study is the decision process: identify the storage that matters, validate the required behavior, measure the relevant effect, and explain why that evidence supports the product choice.

# References

@ref [1] University of Pittsburgh, ECE 2160, “Memory usage homework and Critter product description,” unpublished course assignment, Fall 2026. Assignment supplied with this study.

@ref [2] M. Ketas and ECE 2160 Group C, “Critter memory assessment,” unpublished course-project materials, Nov. 2026. Sources: critter-memory-results.tar.gz; annotated Critter_Memory_Experiment_Review.xlsx, Interpretations rows 7–42; MemoryAssessment runner, harness, copied source, build reports, and raw records. Main session 20261103T063115Z; preliminary session 20261103T061931Z. Author annotations reviewed Nov. 4, 2026.

@ref [3] M. Ketas, “Evaluating Power Reduction for the Critter Embedded System,” ECE 2160 homework paper, University of Pittsburgh, Sep. 2026. Author-supplied Power_HW_Ketas_VF.docx.

@ref [4] M. Ketas, “Timing Predictability of the Critter Embedded System,” ECE 2160 homework paper, University of Pittsburgh, Oct. 2026. Author-supplied Reliability_HW_Ketas_V3.docx and timing-assessment records.

@ref [5] Free Software Foundation, Using the GNU Compiler Collection, version 14.2.0, “Options That Control Optimization.” Accessed: Nov. 4, 2026. https://gcc.gnu.org/onlinedocs/gcc-14.2.0/gcc/Optimize-Options.html

@ref [6] Free Software Foundation, Using the GNU Compiler Collection, version 14.2.0, “Options for Code Generation Conventions.” Accessed: Nov. 4, 2026. https://gcc.gnu.org/onlinedocs/gcc-14.2.0/gcc/Code-Gen-Options.html

@ref [7] Free Software Foundation, Using the GNU Compiler Collection, version 14.2.0, “AArch64 Options.” Accessed: Nov. 4, 2026. https://gcc.gnu.org/onlinedocs/gcc-14.2.0/gcc/AArch64-Options.html

@ref [8] Linux man-pages project, “time(1),” GNU resource reporting. Accessed: Nov. 4, 2026. https://man7.org/linux/man-pages/man1/time.1.html

@ref [9] Linux man-pages project, “proc_pid_smaps(5),” resident, proportional, private, and shared mappings. Accessed: Nov. 4, 2026. https://man7.org/linux/man-pages/man5/proc_pid_smaps.5.html

@ref [10] Linux man-pages project, “getrlimit(2),” RLIMIT_STACK, RLIMIT_DATA, and RLIMIT_AS. Accessed: Nov. 4, 2026. https://man7.org/linux/man-pages/man2/getrlimit.2.html

@ref [11] Linux man-pages project, “dlopen(3),” loading and closing shared objects. Accessed: Nov. 4, 2026. https://man7.org/linux/man-pages/man3/dlopen.3.html

@ref [12] GNU Binutils, “Options,” GNU linker documentation, section garbage collection and symbol stripping. Accessed: Nov. 4, 2026. https://sourceware.org/binutils/docs/ld/Options.html

# Acknowledgements

The Critter software implementation was spearheaded by Andre Gilchrist and contributed to by ECE 2160 Group C. Generative AI assisted with experiment implementation, verification, data analysis, and manuscript preparation using my annotated results, decisions, and review.

# Source Outlines

Course and experimental evidence [1], [2]. The assignment establishes the three units, memory objective, and required optimization techniques. The archive establishes the actual builds and measurements. The annotated workbook supplies my observations, candidate choices, and emphasis on retaining history. Technical explanations are checked against source and recorded flags rather than accepted solely because they appear in an annotation.

Prior papers [3], [4]. The power paper supplies the workshop structure and links resource reduction to useful monitoring. The timing paper supplies the distinction between typical speed, acquisition continuity, and a bounded required service. Their measured power or timing improvements are not imported as results of this memory campaign.

Compiler and linker documentation [5]–[7], [12]. These sources define the tested options and interface implications. The retained effective-option logs establish what this GCC build enables. They explain why an option is meaningful; the Critter records establish its measured effect, and neither alone proves a causal explanation for every RSS difference.

Operating-system documentation [8]–[11]. These sources define process resource reporting, page sharing, loading, and runtime limits. They support keeping file size, requested storage, resident pages, and permitted growth distinct. They do not resolve the observed counter discrepancy or certify any deployment threshold.
