# SafetyReview Development

## Purpose

This repository is a development and analysis workspace for reviewing embedded C software from a safety, reliability, and secure-coding perspective.

The workspace is organized to support:

- Safety-oriented code review
- Coding-standard comparison
- Static analysis
- Concurrency analysis
- Memory-safety analysis
- Timing and determinism analysis
- Fault-injection testing
- Data-integrity analysis
- Requirements traceability
- Findings documentation
- Metrics collection
- Reusable analysis tooling
- Automated or agent-assisted review

The repository should remain focused on analysis artifacts, supporting tools, reference material, and review results.

---

## Repository Structure

```text
.
├── Analysis
│   ├── CodeStructure
│   ├── Concurrency
│   ├── DataIntegrity
│   ├── ErrorHandling
│   ├── FaultInjection
│   ├── Findings
│   ├── MemorySafety
│   ├── RequirementsTraceability
│   ├── StandardsComparison
│   ├── StaticAnalysis
│   └── TimingAndDeterminism
├── Findings
├── Metrics
├── Resources
│   ├── Guidelines
│   │   ├── MISRA C.md
│   │   ├── SEI CERT C Coding Standard.md
│   │   └── The Power of 10_ Rules for Developing Safety-Critical Code.md
│   └── Matrix
├── Tooling
│   ├── Agents
│   ├── Instructions
│   └── Skills
└── Workspaces
    └── SafetyReview.code-workspace
```

---

# Directory Responsibilities

## `Analysis/`

Contains detailed engineering analysis organized by review topic.

Each subdirectory should contain investigation notes, evidence, test results, scripts specific to that analysis, and conclusions associated with that topic.

Analysis documents should clearly distinguish:

- Observed behavior
- Measured results
- Guideline violations
- Potential risks
- Assumptions
- Recommendations
- Confirmed defects

Where possible, analysis results should reference the applicable coding guideline and source-code location.

---

## `Analysis/CodeStructure/`

Contains analysis related to source-code organization and structural complexity.

Topics may include:

- Function size
- Function responsibility
- Module boundaries
- Control-flow complexity
- Recursion
- `goto` usage
- Variable scope
- Global state
- Header organization
- Coupling between modules
- Cohesion
- Cyclomatic complexity

This directory should also contain evidence related to structural requirements from safety-oriented coding standards.

---

## `Analysis/Concurrency/`

Contains analysis of multithreaded and concurrent behavior.

Topics may include:

- Thread creation
- Thread termination
- Shared-memory access
- Race conditions
- Synchronization
- Mutex usage
- Deadlocks
- Atomic operations
- Thread-safe interfaces
- Worker lifecycle
- Shutdown behavior
- Watchdog interaction

Concurrency analysis should identify shared resources and document how access to each resource is coordinated.

---

## `Analysis/DataIntegrity/`

Contains analysis related to preserving the correctness and validity of data throughout the system.

Topics may include:

- Input-data validity
- Sensor-data integrity
- Timestamp validity
- Outlier handling
- Sample filtering
- Data summarization
- Data loss
- Duplicate samples
- Invalid numeric values
- Data transformation
- Storage integrity

Analysis should consider whether processing changes or removes information in a way that could affect downstream decisions.

---

## `Analysis/ErrorHandling/`

Contains analysis of error detection, propagation, recovery, and reporting.

Topics may include:

- Return-value checking
- Parameter validation
- Error codes
- Error propagation
- Failure recovery
- Safe-state behavior
- Logging
- Unexpected conditions
- Resource-cleanup behavior

Failures should be evaluated for both local impact and system-level impact.

---

## `Analysis/FaultInjection/`

Contains controlled experiments that intentionally introduce abnormal conditions.

Examples include:

- Invalid input
- Missing files
- Sensor-read failures
- Corrupt data
- Invalid configuration
- Thread-creation failure
- Resource exhaustion
- Timing delays
- Watchdog expiration
- Unexpected termination

Each fault-injection experiment should document:

1. Fault introduced
2. Expected behavior
3. Actual behavior
4. Evidence collected
5. Safety impact
6. Result

Fault injection should only be performed in controlled development or test environments.

---

## `Analysis/Findings/`

Contains findings that arise during individual analysis activities before they are promoted into the repository-level `Findings/` directory.

This directory may contain:

- Preliminary findings
- Investigation notes
- Candidate defects
- Unresolved questions
- Supporting evidence

Validated findings should eventually be summarized in the top-level `Findings/` directory.

---

## `Analysis/MemorySafety/`

Contains analysis of memory-related risks.

Topics may include:

- Buffer bounds
- Array indexing
- Pointer validation
- Pointer arithmetic
- Null pointers
- Object lifetime
- Stack usage
- Heap usage
- Dynamic allocation
- Initialization
- Use-after-free
- Uninitialized memory
- Memory leaks

Preference should be given to deterministic and statically bounded memory behavior.

---

## `Analysis/RequirementsTraceability/`

Contains mappings between requirements, code, safety guidelines, and verification evidence.

A traceability record may connect:

```text
Requirement
    ↓
Applicable Safety Guideline
    ↓
Implementation
    ↓
Analysis or Test
    ↓
Evidence
    ↓
Result
```

Traceability should make it possible to determine why a safety-related implementation decision exists and how it was verified.

---

## `Analysis/StandardsComparison/`

Contains comparisons between the safety and secure-coding standards used by the project.

Primary reference standards currently include:

- MISRA C
- SEI CERT C Coding Standard
- The Power of 10 Rules for Developing Safety-Critical Code

Analysis may identify:

- Equivalent requirements
- Complementary requirements
- Conflicting recommendations
- Rules unique to one standard
- Common safety principles
- Project-specific interpretations

The purpose is not to reproduce the standards but to determine how they affect the project.

---

## `Analysis/StaticAnalysis/`

Contains static-analysis configuration, output, interpretation, and results.

Potential analysis tools may include:

- Compiler diagnostics
- Cppcheck
- Clang-based analyzers
- Commercial MISRA analyzers
- Security-oriented source-code analyzers

Raw tool output should be preserved when useful, but conclusions should be documented separately from raw results.

Tool warnings should be reviewed rather than automatically treated as defects.

---

## `Analysis/TimingAndDeterminism/`

Contains analysis of runtime timing behavior and predictability.

Topics may include:

- Sampling frequency
- Thread scheduling
- Execution time
- Worst-case execution behavior
- Blocking operations
- Loop bounds
- Timeouts
- Watchdog timing
- Scheduling jitter
- Deadline behavior
- Runtime variability

Safety-related code should avoid unnecessary sources of nondeterministic execution.

---

# `Findings/`

Contains the consolidated findings produced by the safety review.

Unlike `Analysis/Findings/`, which may contain investigation-level notes, this directory should contain findings that have been reviewed and are ready for reporting.

Each finding should preferably include:

- Finding identifier
- Title
- Description
- Severity
- Affected component
- Applicable guideline
- Evidence
- Risk
- Recommendation
- Status

Example:

```text
Finding ID: SR-001
Severity: High
Status: Open

Issue:
Shared data is accessed by multiple threads without synchronization.

Applicable Guidance:
MISRA C / CERT C / project concurrency requirements

Risk:
Concurrent access may result in inconsistent or corrupted state.

Recommendation:
Introduce an appropriate synchronization mechanism and verify
thread-safe access through testing and static analysis.
```

---

# `Metrics/`

Contains quantitative measurements collected during the safety review.

Potential metrics include:

- Compiler-warning count
- Static-analysis warning count
- Number of guideline violations
- Function length
- Cyclomatic complexity
- CPU utilization
- Memory consumption
- Stack usage
- Thread count
- Timing jitter
- Sample loss
- Error frequency
- Fault-injection pass rate
- Requirement coverage

Metrics should include enough context to reproduce or interpret the measurement.

Where practical, include:

- Tool used
- Tool version
- Configuration
- Input data
- Date collected
- Test environment
- Result

---

# `Resources/`

Contains reference material used during development and analysis.

Resources should not contain generated findings or project-specific analysis.

---

## `Resources/Guidelines/`

Contains coding and safety guidelines used as references during the review.

Current references include:

```text
Resources/Guidelines/MISRA C.md
Resources/Guidelines/SEI CERT C Coding Standard.md
Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md
```

These files provide supporting reference material.

Project findings should reference relevant guideline concepts without unnecessarily duplicating the guideline documents.

---

## `Resources/Matrix/`

Contains reusable review matrices for traceability, standards mapping, evidence tracking, status reporting, and requirement coverage.

Typical matrix artifacts include:

- requirement traceability matrices
- standards mapping tables
- findings status matrices
- evidence coverage matrices
- review status trackers

Current project templates include:

```text
Resources/Matrix/requirements-traceability-matrix.md
Resources/Matrix/standards-mapping-matrix.md
Resources/Matrix/findings-status-matrix.md
```

Matrix entries should maintain a direct link to the relevant source evidence, implementation item, guideline reference, and review result. They should support the overall workflow from requirement analysis to final reporting.

The matrix is the shared evidence layer between agents, skills, and instructions: agents decide which review to launch, skills produce the evidence, instructions define the method, and the matrix records the validated traceability and status.

---

# `Tooling/`

Contains reusable infrastructure supporting the safety-review process.

Tooling should remain separate from analysis results.

---

## `Tooling/Agents/`

Contains agent definitions for automated or assisted analysis.

Agent files should use the `*.agent.md` convention so they are clearly identified as agent definitions rather than generic documentation.

Example files include:

```text
Tooling/Agents/report.agent.md
Tooling/Agents/safety-review.agent.md
Tooling/Agents/static-analysis.agent.md
```

Agents should have clearly defined responsibilities.

Potential agents include:

- Safety-review agent
- MISRA review agent
- CERT C review agent
- Concurrency-analysis agent
- Memory-safety agent
- Static-analysis agent
- Requirements-traceability agent
- Report-generation agent

Agents should use the instructions and reference material contained elsewhere in the repository rather than embedding large copies of standards directly into their definitions.

---

## `Tooling/Instructions/`

Contains reusable instructions governing how analysis should be performed.

Potential instruction files include:

```text
safety-review.instructions.md
static-analysis.instructions.md
finding-generation.instructions.md
concurrency-analysis.instructions.md
memory-safety.instructions.md
requirements-traceability.instructions.md
```

Instructions should define methodology, expected output, constraints, and documentation requirements.

---

## `Tooling/Skills/`

Contains reusable higher-level workflows or analysis capabilities.

A skill may combine multiple instructions and analysis activities into a repeatable process.

Potential skills include:

- Complete safety review
- Source-code inspection
- Guideline-compliance review
- Static-analysis triage
- Fault-injection analysis
- Findings consolidation
- Safety-report generation

---

# `Workspaces/`

Contains editor and development-environment workspace configuration.

The workspace configuration should use repository-relative references whenever possible.

Current workspace:

```text
Workspaces/SafetyReview.code-workspace
```

Machine-specific absolute paths should not be required for normal repository operation.

---

# Path Conventions

Repository documentation, scripts, instructions, and workspace configuration should avoid hardcoded machine-specific paths.

Do not assume:

- A specific Windows drive
- A specific Linux mount point
- A specific username
- A specific home directory
- A specific checkout location

Prefer repository-relative paths.

For example:

```text
Resources/Guidelines/
Analysis/Concurrency/
Tooling/Instructions/
```

instead of machine-specific absolute paths.

Shell scripts should determine their location dynamically when access to the repository root is required.

Example:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

From there, repository-relative paths can be constructed.

---

# Analysis Document Guidelines

Analysis documents should generally include the following sections when applicable:

```markdown
# Analysis Title

## Objective

## Scope

## Applicable Guidelines

## Method

## Observations

## Evidence

## Findings

## Risk Assessment

## Recommendations

## Conclusion
```

Not every analysis requires every section, but results should be sufficiently documented to reproduce the reasoning.

---

# Evidence

Safety-review conclusions should be based on evidence whenever possible.

Evidence may include:

- Source-code references
- Compiler output
- Static-analysis output
- Test output
- Runtime measurements
- Logs
- Fault-injection results
- Configuration files
- Screenshots
- Metrics
- Requirements

Avoid making a finding solely because a coding pattern appears unusual.

Determine whether the condition:

1. Violates an applicable guideline.
2. Introduces an identifiable risk.
3. Creates undefined or implementation-dependent behavior.
4. Prevents verification.
5. Reduces reliability or determinism.

---

# Guideline Usage

The repository currently uses three major safety and secure-coding references:

```text
MISRA C
SEI CERT C
The Power of 10
```

These guidelines should be treated as complementary references.

They do not necessarily have identical requirements or compliance models.

Analysis should identify the specific source of a recommendation whenever possible.

For example:

```text
Applicable Guidelines:
- Power of 10 Rule 2 — All loops shall have a fixed upper bound.
- CERT C — Relevant rule for loop or integer behavior.
- MISRA C — Applicable control-flow requirement.
```

Do not claim formal MISRA compliance solely based on an informal review or non-qualified static-analysis tool.

---

# Safety Review Principles

Analysis should prioritize the following characteristics:

- Deterministic behavior
- Bounded execution
- Explicit error handling
- Defensive parameter validation
- Controlled resource usage
- Memory safety
- Thread safety
- Simple control flow
- Limited complexity
- Data integrity
- Defined failure behavior
- Traceability
- Reproducibility

---

# Findings Workflow

A typical safety-review workflow is:

```text
Resources
    ↓
Applicable Guidelines
    ↓
Analysis
    ↓
Evidence
    ↓
Candidate Finding
    ↓
Finding Validation
    ↓
Findings
    ↓
Metrics
    ↓
Final Report
```

Individual analysis directories should contain detailed engineering work.

The top-level `Findings/` directory should contain consolidated review outcomes.

The top-level `Metrics/` directory should contain quantitative evidence supporting the overall review.

---

# Development Rules

When adding material to this repository:

1. Use repository-relative paths.
2. Do not hardcode machine-specific paths.
3. Keep reference material under `Resources/`.
4. Keep reusable tooling under `Tooling/`.
5. Keep investigation-specific work under `Analysis/`.
6. Place consolidated findings under `Findings/`.
7. Place quantitative measurements under `Metrics/`.
8. Document enough evidence to reproduce conclusions.
9. Keep raw analyzer output separate from engineering conclusions.
10. Reference applicable safety guidelines when documenting findings.
11. Clearly distinguish recommendations from confirmed defects.
12. Prefer deterministic and repeatable analysis procedures.
13. Keep generated artifacts organized by analysis topic.
14. Avoid modifying source material being reviewed unless the analysis specifically requires it.

---

# Objective

The goal of this workspace is to provide a repeatable and auditable process for evaluating embedded C software against recognized safety and secure-coding practices.

The repository should make it possible to answer:

- What was analyzed?
- Which guidelines were considered?
- What evidence was collected?
- What risks were identified?
- How severe are those risks?
- What remediation is recommended?
- How can the analysis be reproduced?
- How do the findings trace back to requirements and coding standards?