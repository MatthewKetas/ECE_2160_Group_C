# Code Structure Review Skill

## Role

Reviews software organization and control-flow complexity to identify maintainability and safety risks.

## Purpose

This skill focuses on whether the code structure is clear, bounded, and verifiable. It should also be checked against the project references in `Resources/Guidelines/MISRA C.md`, `Resources/Guidelines/SEI CERT C Coding Standard.md`, and `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- source files and headers
- function definitions and module boundaries
- call graphs or review notes
- static analysis or complexity reports

## Workflow

1. Identify the major modules and their responsibilities.
2. Review function size, scope, and separation of concerns.
3. Inspect recursion, nested conditionals, and large state machines.
4. Check for `goto` use, unstructured flow, or hidden coupling.
5. Review variable scope, global state, and module-level coupling.
6. Assess whether control flow is deterministic and bounded.
7. Record specific risk and recommended simplification.

## Outputs

- structural review summary
- list of risky patterns and affected functions
- recommendations such as refactoring, decomposition, or scope reduction

## Quality Gate

The review must point to concrete code evidence and explain how the structure contributes to complexity, verification difficulty, or safety risk.
