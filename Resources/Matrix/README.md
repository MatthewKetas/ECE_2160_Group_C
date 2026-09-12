# Safety Review Matrix

## Purpose

This directory stores reusable review matrices for traceability, requirement coverage, standards mapping, and evidence tracking.

The matrix artifacts are intended to support the workflow defined in `Resources/DEVELOPMENT.md` and should remain organized, reviewable, and easy to trace to source evidence.

## Typical Contents

This directory contains concrete review artifacts such as:

- requirement traceability matrices
- standards mapping matrices
- findings status matrices
- evidence coverage tables
- review status trackers

Current templates include:

- `requirements-traceability-matrix.md`
- `standards-mapping-matrix.md`
- `findings-status-matrix.md`

## Recommended Matrix Structure

Each matrix should capture the following information:

| Column | Description |
| --- | --- |
| Requirement ID | Unique identifier for the requirement or safety goal |
| Requirement / Function | Short description of the requirement or target behavior |
| Source | Requirement origin, specification, or system context |
| Implementation | Related code, subsystem, or function implementing the behavior |
| Applicable Guideline | Relevant MISRA C, CERT C, or Power of 10 reference |
| Review Method | Static analysis, code review, fault injection, test, or inspection |
| Evidence | Source file, function, log, tool output, or observation |
| Risk / Status | Current risk assessment or verification state |
| Recommendation | Action needed to close gap or mitigate risk |

## Example Traceability Row

| Requirement ID | Requirement / Function | Source | Implementation | Applicable Guideline | Review Method | Evidence | Risk / Status | Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SR-001 | Validate sensor input before use | System requirement | `read_sensor()` | MISRA C / CERT C / Power of 10 | Code review + static analysis | file, function, input check | Open / Medium | Add bounds and error handling |

## Usage Guidance

- Keep matrices simple and explicit.
- Use repository-relative references to source files and relevant analysis artifacts.
- Add a unique identifier for every row.
- Keep evidence tied to actual code or test results rather than assumptions.
- Distinguish open issues, accepted deviations, and verified controls.

## Relationship to the Review Workflow

The matrix is the shared evidence and traceability layer between the project’s review workflow elements.

- Agents decide which review or report activity to start.
- Skills perform the technical analysis and populate matrix entries with evidence.
- Instructions define the method, required fields, and status rules.
- The matrix stores the actual requirement mapping, standards mapping, and finding status.
- The final report consumes the approved matrix content rather than creating new untraceable conclusions.

This directory is intended to be a reusable project record and evidence hub, not a duplicate of the guideline documents.
