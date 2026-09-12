# Findings Status Matrix

## Purpose

This matrix tracks review findings as they are created, validated, classified, and resolved.

## Required Columns

| Finding ID | Title | Severity | Affected Component | Source of Evidence | Relevant Guideline | Status | Recommended Action | Owner |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SR-001 | Example: shared state not synchronized | High | Module or task | Code review, static analysis, log | MISRA C / CERT C / Power of 10 | Open / Accepted / Resolved | Add synchronization and verify race behavior | Review owner |

## Instructions

1. Create a unique finding ID for each issue.
2. Keep the title brief and result-focused.
3. Add the affected code or subsystem.
4. Record evidence used to support the finding.
5. Map to the relevant guideline documents from `Resources/Guidelines/`.
6. Record the current status, owner, and recommended action.
7. Update the matrix as analysis and remediation progress.

## Example Row

| Finding ID | Title | Severity | Affected Component | Source of Evidence | Relevant Guideline | Status | Recommended Action | Owner |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SR-001 | Shared state accessed without synchronization | High | Worker queue logic | Review notes + analyzer output | MISRA C / CERT C | Open | Add lock or atomic protection and retest | Safety review agent |

## Review Rules

- Maintain one authoritative status for each finding.
- Distinguish open, accepted, resolved, and rejected states.
- Keep each finding tied to evidence and recommended remediation.
