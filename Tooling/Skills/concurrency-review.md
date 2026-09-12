# Concurrency Review Skill

## Role

Examines multithreaded or interrupt-driven behavior for race conditions, synchronization gaps, lifecycle issues, and shared-state misuse.

## Purpose

This skill identifies concurrency defects that can lead to inconsistent state, deadlock, missed wakeups, or unsafe behavior under timing variation, and it should confirm alignment with the repository standards in `Resources/Guidelines/`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- thread creation and shutdown paths
- mutex, semaphore, condition-variable, or atomic usage
- shared variables and global state
- worker lifecycle logic and watchdog interactions

## Workflow

1. Build a map of threads, tasks, and shared resources.
2. Identify every shared object and the operations performed on it.
3. Check for missing or inconsistent synchronization.
4. Review lock acquisition order, lock hold times, and cleanup behavior.
5. Inspect shutdown, restart, and watchdog interaction assumptions.
6. Determine whether the code can deadlock, race, or leak state under timing stress.
7. Record the evidence and mitigation strategy.

## Outputs

- shared-resource access map
- race, deadlock, or lifecycle risk assessment
- recommended synchronization and lifecycle changes

## Quality Gate

Concurrency conclusions must be backed by proof of shared access, missing coordination, or unsafe lifecycle behavior.
