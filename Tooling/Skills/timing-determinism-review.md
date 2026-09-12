# Timing and Determinism Review Skill

## Role

Examines whether code executes within bounded and predictable time behavior under expected conditions.

## Purpose

This skill identifies timing variability, blocking operations, and watchdog-sensitive behavior that can reduce reliability or cause timing-dependent faults, and it should compare the conclusion to the repository references in `Resources/Guidelines/`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- timing-sensitive code paths
- loops, sleep calls, delays, and polling logic
- watchdog and scheduler interaction
- runtime logs and timing measurements

## Workflow

1. Identify time-critical task loops and blocking calls.
2. Review loop bounds, timeout logic, and termination conditions.
3. Check for nondeterministic or unbounded operations.
4. Inspect scheduling assumptions, runtime delays, and watchdog interactions.
5. Evaluate whether timing behavior can cause missed deadlines or unsafe recovery.
6. Record conclusions and recommended mitigations.

## Outputs

- timing-risk analysis
- boundedness assessment
- recommendations for deterministic scheduling or reduced variability

## Quality Gate

The review is complete only when timing assumptions are tied to actual execution paths and worst-case or failure behavior.
