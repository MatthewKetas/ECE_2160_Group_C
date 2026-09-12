# Requirements Traceability Review Instructions

This instruction aligns with the repository's requirements-traceability responsibilities in `Resources/DEVELOPMENT.md`.

## Objective

Trace behaviors, assumptions, and requirements through code and testing to confirm that system functionality is implemented and verified in a safety-relevant way.

## Review Focus

Assess:

- requirement completeness
- implementation coverage
- data and control-flow traceability
- assumptions and edge cases
- verification gaps
- conflicts between design intent and code behavior

## Required Method

1. List the relevant requirements or safety goals.
2. Map each requirement to the code path or data path that implements it.
3. Check whether the implementation covers edge conditions and failure modes.
4. Identify missing, indirect, or weakly evidenced coverage.
5. Determine whether verification artifacts support the stated behavior.

## Deliverables

- requirement-to-implementation trace matrix
- identified verification gaps
- conclusion about implementation confidence and residual risk

## Constraints

- A requirement is not considered implemented without evidence.
- Show the mapping from requirement to code, test, or documented behavior.
- Mark assumptions explicitly instead of treating them as known facts.

## Evidence Requirements

Use source references, tests, design notes, and review artifacts to support every traceability claim.
