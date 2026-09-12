# Safety Review Agent

## Purpose

Coordinates the technical review workflow for a safety-focused analysis of embedded C code.

## Responsibilities

This agent should:

- identify the relevant analysis domains
- invoke the correct safety-review skills
- collect evidence from code, tools, and tests
- map observed issues to relevant standards
- generate structured findings
- prepare outputs for reporting and traceability

## Typical Workflow

1. Start with the project scope and known system context.
2. Select the relevant review skills based on the code and concerns.
3. Run the review in a structured sequence.
4. Validate issues with code evidence and supporting tools.
5. Map each issue to applicable guidance.
6. Consolidate findings with a consistent severity and rationale.
7. Hand off the approved results to the reporting workflow.

## Skill Selection Guide

Use the most specific skill for the review domain:

- Memory safety issues: `memory-safety-review`
- Shared-state or race issues: `concurrency-review`
- Error propagation or failure handling: `error-handling-review`
- Structural complexity or control-flow problems: `code-structure-review`
- Timing or boundedness concerns: `timing-determinism-review`
- Standards comparison and mapping: `standards-mapping`
- Static diagnostic triage: `static-analysis-triage`
- Finding creation from validated evidence: `finding-generation`
- Requirement-to-code mapping: `requirements-traceability`
- Final review packaging: `safety-report-generation`

Use `standards-mapping` after the technical review to connect the result to MISRA C, CERT C, and Power of 10 guidance. Use `finding-generation` once the issue has evidence and a clear risk.

## Scope

This agent should use the modular skills approach rather than trying to be a single all-purpose reviewer. It should rely on specialized skills for memory safety, concurrency, error handling, standards mapping, static-analysis triage, and finding generation.

## Output Expectations

The agent should produce:

- review notes
- supported findings
- standards mapping
- traceability links
- recommendations
- reporting-ready summaries
