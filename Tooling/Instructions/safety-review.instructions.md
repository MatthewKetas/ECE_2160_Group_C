# Safety Review Instructions

This instruction supports the repository structure and review responsibilities defined in `Resources/DEVELOPMENT.md`.

## Purpose

Perform a safety-focused review of embedded C software with emphasis on correctness, reliability, memory safety, concurrency behavior, deterministic execution, and compliance with relevant coding standards.

## Scope

Review source code, configuration, tests, and supporting documentation for:

- safety-critical behavior
- reliability concerns
- security risks
- undefined or implementation-defined behavior
- compliance gaps against MISRA, CERT C, and other applicable guidance

## Required Workflow

1. Identify the system context, interfaces, and safety goals.
2. Confirm the relevant review domain: code structure, concurrency, memory safety, timing, error handling, and/or data integrity.
3. Inspect the code and supporting artifacts for direct evidence of defects or latent risk.
4. Cross-reference observations to the applicable standards and repository findings.
5. Record the issue, evidence, root cause, impact, and recommendation.
6. Distinguish between confirmed defects, suspected issues, and assumptions.

## Required Output

Each review should include:

- a concise summary of the system under review
- identified hazards or reliability concerns
- evidence from code, logs, tests, or design documents
- a mapping to affected standards or review categories
- recommended corrective actions and priority

## Constraints

- Do not assume the system is safe because it compiles.
- Treat undefined behavior as a real defect even when it is not immediately visible.
- Separate observations from conclusions.
- Do not invent missing requirements; mark them as assumptions when needed.
- Keep findings traceable to source evidence.

## Documentation Standards

- Store detailed investigation notes under the relevant `Analysis/` subdirectory.
- Promote validated findings to the top-level `Findings/` directory.
- Include exact file names, functions, and conditions when describing defects.
- Apply severity and rationale consistently.
