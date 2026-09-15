The complete matrix contains **70 rules: 60 CERT rules from the eight selected chapters, plus all ten Power of Ten rules.**

- **Human first — 13 rules:** the ten selected CERT rules and NASA P10-2, P10-5, and P10-7. Preserve human conclusions before AI reassessment.
- **AI/tools first — 57 rules:** includes the previously deferred human-review candidates and applicability screening.
- **Reserve:** initially reviewed by AI/tools; a priority for additional human review if time permits or uncertainty remains.
- **N/A screen:** AI checks whether the relevant construct is absent. This is an applicability decision, not a compliance pass.

These classifications apply to the current implementation. They do not imply that AI or static analysis can conclusively verify every assigned rule.

| Chapter | Rule | Initial reviewer | Description and implementation-specific focus |
|---|---|---|---|
| **4 — Expressions** | **EXP30-C** | AI/tools | Avoid dependence on evaluation order for side effects. Inspect expressions that modify and read shared state. |
| 4 | **EXP32-C** | AI/tools — N/A screen | Do not access volatile objects through nonvolatile references. Confirm that no relevant volatile objects exist. |
| 4 | **EXP33-C** | **Human first** | Do not read uninitialized memory. Trace initialization of samples, summaries, results, and output parameters across success and failure paths. |
| 4 | **EXP34-C** | AI/tools — Reserve | Prevent null dereferences. Check both structure pointers and their internal buffers, including failed initialization and cleanup states. |
| 4 | **EXP35-C** | AI/tools — N/A screen | Do not modify objects with temporary lifetime. Check for relevant temporary aggregates and array members. |
| 4 | **EXP36-C** | AI/tools | Avoid pointer conversions that violate alignment requirements. Inspect pointer casts and allocator-result conversions. |
| 4 | **EXP37-C** | AI/tools | Supply compatible argument counts and types. Check prototypes, calls, and variadic arguments. |
| 4 | **EXP39-C** | AI/tools | Respect effective-type and aliasing requirements. Inspect accesses through converted pointers; escalate ambiguous aliasing. |
| 4 | **EXP40-C** | AI/tools | Do not modify constant objects. Inspect casts removing `const` and subsequent writes. |
| 4 | **EXP42-C** | AI/tools — N/A screen | Do not compare structure padding as data. Confirm absence of relevant whole-object byte comparisons. |
| 4 | **EXP43-C** | AI/tools | Respect `restrict` non-aliasing contracts, including library interfaces. Check whether input and output regions overlap. |
| 4 | **EXP44-C** | AI/tools | Do not depend on side effects in operands of `sizeof`, `_Alignof`, or `_Generic`. Inspect their operands and applicable exceptions. |
| 4 | **EXP45-C** | AI/tools | Check assignments in selection expressions. Distinguish accidental assignment from explicitly compared, intentional assignment. |
| 4 | **EXP46-C** | AI/tools | Avoid inappropriate bitwise operations on Boolean-like operands. Distinguish logical conditions from numeric sensor masks. |
| **5 — Integers** | **INT30-C** | AI/tools — Reserve | Prevent unintended unsigned wraparound. Review counters, allocation products, and ring-index arithmetic. |
| 5 | **INT31-C** | **Human first** | Ensure integer conversions preserve required values and interpretation. Review signedness, narrowing, sensor data, and target assumptions. |
| 5 | **INT32-C** | AI/tools — Reserve | Prevent signed overflow. Review timestamp subtraction and sensor arithmetic before conversions occur. |
| 5 | **INT33-C** | AI/tools — Reserve | Prevent invalid integer division and remainder operations. Establish valid divisors, particularly ring-buffer capacity. |
| 5 | **INT34-C** | AI/tools | Ensure valid shift counts and operands. Review sensor bit assembly, integer promotions, and signed shifts. |
| 5 | **INT35-C** | AI/tools | Use appropriate integer precision. Check fixed-width types, masks, constants, and target limits. |
| 5 | **INT36-C** | AI/tools — N/A screen | Review pointer/integer conversions for portability and representation risks. Confirm absence of such conversions. |
| **6 — Floating Point** | **FLP30-C** | AI/tools | Avoid floating-point induction counters. Distinguish accumulated floating-point counters from elapsed time recomputed from a clock. |
| 6 | **FLP32-C** | **Human first** | Prevent or detect math-function domain and range errors. Trace arguments and applicable error handling around functions such as `sqrt()`. |
| 6 | **FLP34-C** | **Human first** | Ensure numeric conversions involving floating-point values are within destination range. Review conversions used in timing and reporting. |
| 6 | **FLP36-C** | AI/tools — Reserve | Preserve required precision in integer-to-floating conversions. Evaluate timestamp and counter precision requirements. |
| 6 | **FLP37-C** | AI/tools — N/A screen | Do not compare floating-point object representations instead of values. Confirm absence of relevant bytewise comparisons. |
| **7 — Arrays** | **ARR30-C** | **Human first** | Prevent invalid pointer formation and out-of-bounds access. Establish ring-buffer and source-index invariants. |
| 7 | **ARR32-C** | AI/tools — N/A screen | Validate variable-length-array bounds. Confirm that arrays are fixed-size or dynamically allocated rather than VLAs. |
| 7 | **ARR36-C** | AI/tools — N/A screen | Avoid subtraction or relational comparison of pointers to unrelated arrays. Null equality checks are a different operation. |
| 7 | **ARR37-C** | AI/tools | Restrict pointer arithmetic to appropriate array objects. Trace the origins of pointers used in path manipulation. |
| 7 | **ARR38-C** | AI/tools — Reserve | Ensure library pointer/size arguments describe valid object ranges. Follow capacities through helper functions and library calls. |
| 7 | **ARR39-C** | AI/tools | Avoid double-scaling pointer offsets. Check arithmetic mixing typed pointers, element counts, and byte sizes. |
| **8 — Characters and Strings** | **STR30-C** | AI/tools | Do not modify string literals. Trace literal-derived pointers and potential writes. |
| 8 | **STR31-C** | **Human first** | Provide sufficient string storage, including termination. Review path capacities, appended filenames, and oversized input handling. |
| 8 | **STR32-C** | AI/tools — Reserve | Establish null termination before string-library use, including after input, formatting, and failure paths. |
| 8 | **STR34-C** | AI/tools — N/A screen | Prevent problematic sign extension when converting character data to larger integer types. Check for relevant conversions. |
| 8 | **STR37-C** | AI/tools — N/A screen | Supply valid arguments to character-classification functions. Confirm absence of relevant `<ctype.h>` calls. |
| 8 | **STR38-C** | AI/tools — N/A screen | Avoid mixing narrow and wide strings or their APIs. Confirm absence of wide-character processing. |
| **9 — Memory Management** | **MEM30-C** | AI/tools — Reserve | Prevent access to released memory. Trace aliases and calls made after cleanup. |
| 9 | **MEM31-C** | **Human first** | Release allocated memory when appropriate. Trace ownership across normal operation, early returns, reinitialization, and shutdown. |
| 9 | **MEM33-C** | AI/tools — N/A screen | Allocate and copy flexible-array-member structures correctly. Confirm absence of flexible array members. |
| 9 | **MEM34-C** | AI/tools | Free only valid dynamically allocated pointers or null pointers. Check allocation origins, interior pointers, and repeated deallocation. |
| 9 | **MEM35-C** | **Human first** | Allocate sufficient space for the intended objects. Establish correct types, counts, and representable size calculations. |
| 9 | **MEM36-C** | AI/tools — N/A screen | Preserve required alignment when reallocating. Confirm absence of `realloc()` and relevant extended-alignment storage. |
| **10 — Input/Output** | **FIO30-C** | AI/tools | Keep externally controlled data out of format strings. Check the provenance of format arguments. |
| 10 | **FIO32-C** | AI/tools — Reserve | Avoid file-only operations on inappropriate devices or special files. Evaluate configurable paths and expected object types. |
| 10 | **FIO34-C** | AI/tools — N/A screen | Preserve the distinction between character-input results and EOF sentinels. Check for relevant character-input APIs. |
| 10 | **FIO37-C** | AI/tools | Do not assume successful `fgets()` returns a nonempty string. Inspect newline removal and subsequent string operations. |
| 10 | **FIO38-C** | AI/tools — N/A screen | Do not copy `FILE` objects. Confirm that code passes stream pointers rather than copying stream objects. |
| 10 | **FIO39-C** | AI/tools — N/A screen | Follow required transitions between reading and writing an update stream. Confirm that no relevant update streams exist. |
| 10 | **FIO40-C** | AI/tools | Prevent unsafe use of buffers after failed `fgets()`/`fgetws()` calls. Trace buffer use following failure. |
| 10 | **FIO41-C** | AI/tools — N/A screen | Avoid side effects in stream arguments to specified character-I/O functions. Confirm absence of the relevant calls. |
| 10 | **FIO42-C** | AI/tools — Reserve | Close files when no longer needed. Trace successful opens through normal and failure paths; assess descriptor ownership where applicable. |
| 10 | **FIO44-C** | AI/tools — N/A screen | Use only valid, previously obtained positions with `fsetpos()`. Confirm absence of stream-position restoration. |
| 10 | **FIO45-C** | **Human first** | Avoid filesystem time-of-check/time-of-use races. Evaluate path stability, permissions, and changes by other processes. |
| 10 | **FIO46-C** | AI/tools | Prevent access to closed streams or file handles. Trace local streams and persistent sensor descriptors. |
| 10 | **FIO47-C** | AI/tools | Use valid format strings with matching argument types and counts. Apply compiler format checking and inspect diagnostics. |
| **13 — Error Handling** | **ERR30-C** | AI/tools | Use `errno` according to each API’s contract. Check when it must be cleared and when its value is meaningful. |
| 13 | **ERR32-C** | AI/tools | Avoid relying on indeterminate or invalidated `errno` values. Inspect intervening calls and failure conditions. |
| 13 | **ERR33-C** | **Human first** | Detect and appropriately handle standard-library failures. Evaluate propagation, recovery, and exceptions beyond merely locating ignored returns. |
| **NASA Power of Ten** | **P10-1 — Control flow** | AI/tools | Restrict control flow; detect `goto`, `setjmp`/`longjmp`, and direct or indirect recursion. |
| NASA | **P10-2 — Loop bounds** | **Human first** | Establish statically verifiable iteration limits. Assess collection, file-reading, and processing loops; document deliberately nonterminating-loop exceptions where applicable. |
| NASA | **P10-3 — Allocation timing** | AI/tools | Establish whether dynamic allocation occurs after initialization. This is separate from whether allocation is correctly sized and freed. |
| NASA | **P10-4 — Function size** | AI/tools | Measure functions against the single-page guideline, approximately 60 lines using the specified formatting convention. |
| NASA | **P10-5 — Assertions** | **Human first** | Assess meaningful, side-effect-free assertions, explicit failure responses, and an average of at least two assertions per function. |
| NASA | **P10-6 — Scope** | AI/tools | Establish that data objects are declared at the smallest necessary scope. |
| NASA | **P10-7 — Returns and parameters** | **Human first** | Assess handling of nonvoid return values and validation of all function parameters, including application interfaces and justified exceptions. |
| NASA | **P10-8 — Preprocessor** | AI/tools | Restrict preprocessing to simple constructs; inspect prohibited macro mechanisms and justification for conditional compilation. |
| NASA | **P10-9 — Pointers** | AI/tools | Inspect dereference-depth restrictions, hidden dereferences in macros or typedefs, and prohibited function pointers. |
| NASA | **P10-10 — Verification process** | AI/tools | Audit warning settings, diagnostics, and historical static-analysis records. A current clean run cannot establish daily analysis throughout development. |

**The ten reserve candidates remain visible rather than being silently excluded:** EXP34-C, INT30-C, INT32-C, INT33-C, FLP36-C, ARR38-C, STR32-C, MEM30-C, FIO32-C, and FIO42-C.

For reporting, keep **initial reviewer**, **evidence**, and **final decision** separate. A rule assigned to AI/tools can still finish as *unresolved*, and one defect can support multiple rule findings without becoming multiple independent defects.
