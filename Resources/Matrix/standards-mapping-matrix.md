# Standards Mapping Matrix

## Purpose

This matrix maps analysis findings or design decisions to the applicable safety and secure-coding references in `Resources/Guidelines/`.

## Required Columns

| Issue ID | Issue / Concern | Affected Component | Applicable Guideline | Standard Category | Mapping Rationale | Severity | Mandatory / Advisory | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SI-001 | Example: unsafe pointer use | Module or function | MISRA C / CERT C / Power of 10 | Memory safety | Rule matches the behavior and unsafe lifetime pattern | High | Mandatory / Recommended | Open |

## Instructions

1. Identify the issue, risk, or design decision.
2. Map it to the relevant standard or principle from the project resource documents.
3. Record the exact guideline title or rule category.
4. State why the mapping is relevant.
5. Note whether the guidance is mandatory, required, recommended, or advisory, if available.
6. Track the issue through investigation and resolution.

## Example Row

| Issue ID | Issue / Concern | Affected Component | Applicable Guideline | Standard Category | Mapping Rationale | Severity | Mandatory / Advisory | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SI-001 | Out-of-bounds access in buffer handling | `process_buffer()` | CERT C / MISRA C | Memory safety | Indexing is not bounded by an explicit validated range | High | Mandatory | Open |

## Review Rules

- Use the project guideline docs as the primary source for mapping.
- Distinguish direct requirement from general best practice.
- Track overlap between standards where multiple references apply.
