# Requirements Traceability Matrix

## Purpose

This matrix records the relationship between project requirements, implemented code, safety guidance, evidence, and outcome.

## Required Columns

| Requirement ID | Requirement / Safety Goal | Source | Implementation / Component | Applicable Guideline | Review Method | Evidence | Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SR-001 | Example: validate input before use | System requirement or design note | Function or module | MISRA C / CERT C / Power of 10 | Code review, static analysis, test | File, function, log, analyzer result | Pass / fail / partial | Open / Closed / Accepted | Additional detail |

## Instructions

1. Give each requirement a unique identifier.
2. Link the requirement to the relevant source code or subsystem.
3. Map the behavior to one or more applicable standards from `Resources/Guidelines/`.
4. Record the review method used to evaluate the requirement.
5. Add direct evidence, such as code references, logs, or tool output.
6. State whether the requirement was met, partially met, or not met.
7. Record status and any recommended action.

## Example Row

| Requirement ID | Requirement / Safety Goal | Source | Implementation / Component | Applicable Guideline | Review Method | Evidence | Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SR-001 | Validate sensor input before use | Project design note | `read_sensor()` | MISRA C / CERT C / Power of 10 | Code review + static analysis | file path, function, bounds check evidence | Partial | Open | Need explicit range validation and error handling |

## Review Rules

- Keep the matrix tied to evidence, not guesses.
- If a requirement cannot be mapped to implementation, record the gap explicitly.
- Use the matrix to support final report generation and traceability summaries.
