# Memory Safety Review Instructions

This instruction supports the memory-safety analysis responsibilities defined in `Resources/DEVELOPMENT.md`.

## Objective

Analyze memory usage for hazards such as invalid pointers, dangling references, buffer overruns, uninitialized reads, misuse of dynamic allocation, and failed cleanup.

## Review Focus

Check for:

- null-pointer dereference paths
- out-of-bounds reads and writes
- use-after-free and double-free behavior
- allocation-size computation errors
- alignment issues
- uninitialized memory reads
- invalid pointer arithmetic
- mismatch between pointer ownership and lifetime

## Required Method

1. Identify objects and their ownership boundaries.
2. Trace all pointer creation, copying, validation, and release sites.
3. Check whether lifetime assumptions are valid across function calls, callbacks, and thread boundaries.
4. Evaluate whether allocation size, alignment, and data-type assumptions are correct.
5. Verify that cleanup and error paths keep memory valid and consistent.

## Deliverables

- memory-lifetime and ownership summary
- list of memory-safety risks and their contributing conditions
- recommended remediation and safe ownership patterns

## Constraints

- Treat all unchecked pointer usage as a serious defect candidate.
- Verify dynamic-memory operations against allocation and deallocation lifecycle rules.
- Do not rely on a compile pass as evidence of memory safety.

## Evidence Requirements

Each issue should reference the exact memory object, allocation site, use site, and any condition that makes the operation unsafe.
