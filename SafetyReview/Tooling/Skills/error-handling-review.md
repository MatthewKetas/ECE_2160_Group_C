# Error Handling Review Skill

## Role

Checks how the system detects, propagates, reports, and recovers from abnormal conditions.

## Purpose

This skill ensures that detected failures do not silently spread, mask root cause, or leave the system in an unsafe state, and it should compare the result to the project guidance in `Resources/Guidelines/`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- return-value paths
- parameter validation logic
- cleanup and failure handlers
- logging or diagnostic code
- initialization and shutdown flows

## Workflow

1. Identify all failure points and abnormal conditions.
2. Check whether failures are detected and categorized correctly.
3. Trace propagation of status values or error codes.
4. Inspect whether cleanup and safe-state transitions are executed.
5. Review assertions, checks, and fallback logic for correctness.
6. Determine whether failures are visible, traceable, and actionable.
7. Record the issue and the safer handling pattern.

## Outputs

- failure-mode summary
- error-path analysis
- safe-state and recovery recommendations

## Quality Gate

This review is complete only when each failure path is connected to an actual consequence, recovery behavior, or hazard that affects safety or reliability.
