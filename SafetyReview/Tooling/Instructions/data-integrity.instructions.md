# Data Integrity Analysis Instructions

This instruction aligns with the repository's guidance for data-integrity analysis described in `Resources/DEVELOPMENT.md`.

## Objective

Assess whether data entering, transforming, storing, or being consumed by the system remains valid, trustworthy, and suitable for safety-relevant decisions.

## Review Focus

Examine:

- input-data validation and range checking
- sensor and measurement plausibility
- timestamp and ordering integrity
- filtering, aggregation, and calibration logic
- duplicate, stale, or missing data handling
- numeric conversion and overflow conditions
- data-loss or corruption detection
- persistence and retrieval consistency

## Required Method

1. Identify the data source and expected validity constraints.
2. Trace each transformation step to its downstream use.
3. Check whether invalid values are rejected, flagged, or converted in unsafe ways.
4. Review whether data quality issues can propagate into control, reporting, or safety decisions.
5. Record assumptions about calibration, fault tolerance, and timing.

## Deliverables

- data-flow summary
- list of invalid or unsafe data-handling patterns
- risk assessment for each data quality failure mode
- recommended validation and recovery measures

## Constraints

- Invalid data should not be silently normalized unless that behavior is explicitly intended and verified.
- Assume that data quality problems can affect safety decisions and reporting.
- Distinguish between data-rate issues, data-content issues, and system-design issues.

## Evidence Requirements

Each conclusion should reference the source of the data, the transformation point, and the downstream effect on behavior or outputs.
