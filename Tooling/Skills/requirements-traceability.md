# Requirements Traceability Skill

## Role

Connects a requirement to implementation, guideline mapping, verification evidence, and outcome.

## Purpose

This skill provides the traceability chain needed to explain why a design decision exists and how it was checked, and it should directly tie each trace back to the project references in `Resources/Guidelines/`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- requirement statements or design constraints
- implementation under review
- applicable standards or guidelines
- test or analysis evidence

## Workflow

1. Define the requirement or safety goal.
2. Identify the implementation that satisfies or fails to satisfy it.
3. Map the implementation to applicable guidance.
4. Link to analysis, static checks, or behavioral tests.
5. Record evidence that the behavior is present, absent, or insufficient.
6. Summarize the result and any remaining risk.

## Outputs

- requirement-to-implementation trace matrix
- evidence summary and gaps
- status of compliance or remaining risk

## Quality Gate

Traceability is valid only when each link is supported by evidence and each requirement is assessed against actual implementation behavior.
