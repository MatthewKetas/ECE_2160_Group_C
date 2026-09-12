# Error Handling Review Instructions

This instruction supports the error-handling analysis responsibilities in `Resources/DEVELOPMENT.md`.

## Objective

Review how the software detects, propagates, handles, and reports failures. Error handling should support safe recovery, failure containment, and predictable shutdown when abnormal conditions occur.

## Review Focus

Evaluate:

- return-value checking and status handling
- invalid parameter detection
- error propagation paths
- safe-state and fallback behavior
- recovery and cleanup operations
- logging and diagnostics quality
- failure handling under resource exhaustion or timing issues

## Required Method

1. Identify all externally observable or internally detected failure modes.
2. Trace how each failure is reported and acted upon.
3. Check whether the system fails closed, fails safe, or may continue in an unsafe state.
4. Examine resource cleanup when a function or task fails.
5. Verify that warnings and faults remain actionable and traceable.

## Deliverables

- failure-mode inventory
- evaluation of detection and propagation quality
- recovery strategy assessment
- recommendations for safer error behavior

## Constraints

- Silent failure is not acceptable for safety-relevant functionality.
- A return value that is not checked is effectively a failure path that has not been reviewed.
- Handle cleanup and logging as part of the correctness of the failure path.

## Evidence Requirements

Document the exact function call, condition, return path, and resulting action for each analyzed failure scenario.
