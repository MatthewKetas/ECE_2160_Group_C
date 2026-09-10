# Finding Generation Skill

## Role

Converts analysis evidence into a consistent, review-ready finding.

## Purpose

This skill standardizes the final representation of a defect, concern, or safety issue so it can be tracked, triaged, and reported consistently, and it should connect each finding to the relevant project reference material in `Resources/Guidelines/`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- evidence from code review, testing, or static analysis
- notes from relevant review skill execution
- applicable guideline references
- affected component or subsystem description

## Workflow

1. Identify the exact issue and its affected component.
2. Determine severity based on impact, likelihood, and recoverability.
3. Capture the evidence and direct code reference.
4. Map to the relevant guideline or standard.
5. State the risk and recommended remediation.
6. Assign a finding ID and status.
7. Prepare the finding for promotion to the top-level `Findings/` directory.

## Outputs

- finding record with ID, title, severity, status, evidence, and recommendation
- links to applicable guidance and affected subsystem

## Quality Gate

A finding is ready only when the evidence supports the issue, the risk is explained, and the recommended action is specific and actionable.
