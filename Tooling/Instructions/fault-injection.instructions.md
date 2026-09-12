# Fault Injection Analysis Instructions

This instruction aligns with the fault-injection analysis guidance in `Resources/DEVELOPMENT.md`.

## Objective

Conduct controlled fault-injection tests to reveal latent defects, unsafe recovery behavior, and failure-mode assumptions before the system is deployed in a real environment.

## Review Focus

Examples of relevant faults include:

- invalid input values
- missing or corrupted files
- delayed or missed sensor data
- invalid configuration values
- resource exhaustion
- thread-creation or shutdown failures
- timing anomalies
- watchdog expiration
- unexpected termination and restart

## Required Method

1. Define the fault to introduce and the expected system response.
2. Apply the fault in a controlled environment with documented assumptions.
3. Observe the actual behavior and collect supporting evidence.
4. Compare real behavior against the expected safety posture.
5. Record whether the system reaches a safe state, fails gracefully, or creates additional hazard.

## Deliverables

- test setup and fault summary
- expected vs actual behavior
- quantified or qualitative impact
- corrective actions or design changes needed

## Constraints

- Fault injection must be performed only in controlled development or test environments.
- Do not use production systems as experimental environments.
- Capture both positive and negative evidence, including non-obvious effects.

## Evidence Requirements

Each experiment should document the fault introduced, the exact condition under which it occurred, the observed behavior, and the safety consequence.
