# Concurrency Analysis Instructions

This instruction supports the concurrency review responsibilities described in `Resources/DEVELOPMENT.md`.

## Objective

Identify race conditions, lock-order issues, lifecycle problems, shared-state misuse, and synchronization errors that could affect correctness or safety in multithreaded or interrupt-driven systems.

## Review Focus

Check for:

- thread creation and shutdown correctness
- shared-memory access patterns
- mutex and condition-variable misuse
- deadlocks or lock-order inversions
- atomic usage and memory-order assumptions
- interrupt or signal interactions
- watchdog and worker lifecycle coordination
- race conditions in global state, queues, or buffers

## Required Method

1. Identify every shared resource and the threads or handlers that access it.
2. Determine the access pattern: read, write, update, or cleanup.
3. Verify that each access is protected by the correct synchronization mechanism.
4. Check for lock ordering, lock hold times, and proper cleanup paths.
5. Validate assumptions about thread termination, wakeups, and shutdown sequencing.

## Deliverables

- resource-access map
- race-condition or deadlock assessment
- synchronization issues and unsafe patterns
- mitigation guidance and recommended safe-state behavior

## Constraints

- Shared state must be analyzed as a system-level property, not per function.
- Treat missing synchronization as a defect even when timing is not currently observed.
- Document any assumptions about scheduler behavior or platform-specific semantics.

## Evidence Requirements

Use code references, synchronization objects, thread creation points, and execution traces to support every concurrency claim.
