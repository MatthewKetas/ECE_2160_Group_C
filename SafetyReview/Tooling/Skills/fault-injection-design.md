# Fault Injection Design Skill

## Role

Designs controlled abnormal-condition tests to reveal failure behavior and safety impact.

## Purpose

This skill supports systematic validation under invalid input, missing dependencies, timing delay, resource exhaustion, and unexpected device or system conditions, and it should validate test intent against the repository references in `Resources/Guidelines/`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- system interfaces and dependencies
- expected failure conditions
- operational assumptions
- available test environment

## Workflow

1. Select the relevant abnormal condition to inject.
2. Define expected behavior and safety objective.
3. Craft the smallest realistic test to trigger the fault.
4. Observe actual output, transitions, cleanup, and recovery behavior.
5. Evaluate whether the system fails safely and predictably.
6. Record observations and recommendations.

## Outputs

- test scenario description
- expected vs actual behavior
- safety impact assessment
- recommended mitigation or design change

## Quality Gate

Fault-injection scenarios must be controlled, reproducible, and tied to a specific risk or hazard model.
