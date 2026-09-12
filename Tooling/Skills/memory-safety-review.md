# Memory Safety Review Skill

## Role

Evaluates pointer usage, object lifetime, array bounds, initialization, and allocation behavior.

## Purpose

This skill identifies memory hazards that can lead to undefined behavior, data corruption, or runtime faults, and it should cross-check the result against the guidance in `Resources/Guidelines/MISRA C.md`, `Resources/Guidelines/SEI CERT C Coding Standard.md`, and `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- source files with pointer or array usage
- allocation and free sites
- compiler warnings and analyzer findings
- buffer and data-structure definitions

## Workflow

1. Identify every allocation, ownership boundary, and object lifetime.
2. Review pointer creation, validation, arithmetic, and release logic.
3. Check for null dereference, dangling pointer, use-after-free, and double-free paths.
4. Inspect array bounds, indexing patterns, and fixed-size assumptions.
5. Review initialization of stack, heap, and aggregate objects.
6. Confirm that ownership and lifetime assumptions are explicit and safe.
7. Record defects and recommended corrections.

## Outputs

- memory-lifetime map
- list of memory-safety issues and conditions
- recommended safe allocation and ownership patterns

## Quality Gate

The review is valid only when the risk is tied to a concrete object, access path, and unsafe lifecycle or bounds condition.
