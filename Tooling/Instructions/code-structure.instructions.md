# Code Structure Review Instructions

This instruction aligns with the analysis responsibilities in `Resources/DEVELOPMENT.md` and should be used when reviewing module organization, complexity, and maintainability.

## Objective

Assess whether the software structure supports safe, understandable, and testable behavior. Look for unnecessary complexity, poor separation of concerns, hidden coupling, and control-flow patterns that make faults more likely.

## Review Focus

Evaluate:

- function size and responsibility
- module boundaries and cohesion
- global-state usage and lifecycle
- variable scope and initialization patterns
- recursion and control-flow complexity
- `goto` use and branching discipline
- coupling between modules and headers
- config and interface consistency

## Required Method

1. Map the relevant functions, modules, and interfaces.
2. Identify high-risk structures such as large state machines or deeply nested logic.
3. Check whether the code organization matches the intended design and safety goals.
4. Note whether complexity or coupling amplifies failure modes.
5. Reference design constraints and coding standards when a structure is unsafe or difficult to verify.

## Deliverables

- a structural overview of the reviewed code
- list of risky patterns identified
- explanation of how each pattern can affect safety or reliability
- recommended refactoring or simplification measures

## Constraints

- Do not equate complexity with danger unless the code path is reachable and relevant.
- Prefer evidence-based conclusions over subjective criticism.
- Separate structural findings from implementation mistakes.

## Evidence Requirements

Document source locations, function names, and specific control paths when describing structural issues.
