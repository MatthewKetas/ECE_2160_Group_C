# MISRA C

## Overview

**MISRA C** is a set of software-development guidelines for the **C programming language** developed by the **MISRA Consortium**.

The guidelines are intended to improve:

- Safety
- Security
- Portability
- Reliability
- Maintainability
- Predictability

MISRA C is primarily intended for **embedded systems** and other software where failures can have significant consequences.

Although MISRA C originated in the automotive industry, it has become widely used in safety-critical and high-reliability software across multiple industries.

MISRA C applies to standardized versions of the C programming language, including:

- C90
- C99
- C11
- C17

There is also a separate set of guidelines for **MISRA C++**.

---

# History

The MISRA C standard has evolved through several revisions.

| Version | Year | Major Change |
|---|---:|---|
| Draft | 1997 | Initial draft |
| MISRA C:1998 | 1998 | First published edition |
| MISRA C:2004 | 2004 | Major revision and rule restructuring |
| MISRA C:2012 | 2013 | Added directives and expanded classification |
| MISRA Compliance:2016 | 2016 | Formal compliance guidance |
| MISRA Compliance:2020 | 2020 | Updated compliance guidance |
| MISRA C:2023 | 2023 | Added C11/C17 support and integrated amendments |
| MISRA C:2025 | 2025 | Latest published revision referenced by this document |

The first two editions, MISRA C:1998 and MISRA C:2004, treated all guidelines as **rules**.

MISRA C:2012 introduced an additional category called a **Directive**.

A directive generally addresses requirements that:

- Are more open to interpretation
- Relate to development processes
- Relate to procedural or architectural concerns
- Cannot always be verified purely through source-code analysis

---

# Adoption

MISRA C was initially developed for automotive software but has become a widely accepted model for safety-oriented C development.

MISRA principles have been adopted or referenced in industries including:

- Automotive
- Aerospace
- Telecommunications
- Medical devices
- Defense
- Railway systems
- Industrial control
- Embedded systems

Examples of adoption include:

- Joint Strike Fighter C++ Coding Standards based partly on MISRA C:1998
- NASA Jet Propulsion Laboratory C Coding Standards based partly on MISRA C:2004
- IEC 81001-5-1 citing MISRA C as an example of secure coding practice
- ISO 26262 referencing MISRA C for automotive functional safety
- AUTOSAR requiring MISRA C compliance for certain Basic Software modules

MISRA C therefore represents more than an automotive coding convention. It has become an important reference for developing high-integrity C software.

---

# Guideline Classification

MISRA guidelines are classified according to the level of compliance expected.

## Mandatory

Mandatory guidelines must always be followed.

A project cannot claim MISRA compliance while knowingly violating a mandatory guideline.

---

## Required

Required guidelines must normally be followed.

A violation is permitted only when a formally documented **deviation** has been established.

---

## Advisory

Advisory guidelines represent recommended engineering practices.

They may be disapplied, but the decision should be documented as part of the project's compliance process.

---

# Guideline Categories

MISRA rules can be grouped into several broad engineering objectives.

## Portability

Avoid behavior that may differ between:

- Compilers
- Processors
- Operating systems
- Build configurations

For example, the size of a plain C `int` can vary by implementation.

When an exact width is required, explicitly sized types should be preferred where appropriate:

```c
#include <stdint.h>

int16_t temperature;
uint32_t timestamp;
```

This improves portability and makes assumptions about representation explicit.

---

## Avoid Failure-Prone Constructs

MISRA discourages language features and library functions whose behavior may introduce unnecessary runtime risk.

For example, dynamic memory allocation:

```c
void *buffer = malloc(size);
```

may fail and can introduce:

- Memory fragmentation
- Memory leaks
- Nondeterministic execution time
- Unpredictable resource exhaustion

Safety-critical applications therefore often avoid dynamic allocation during normal runtime.

---

## Maintainability and Debuggability

MISRA promotes source code that can be understood and reviewed consistently.

This includes practices involving:

- Naming
- Documentation
- Type usage
- Control flow
- Function structure
- Interface design

Readable code is particularly important when software must undergo formal review or safety assessment.

---

## Complexity Control

MISRA discourages unnecessary software complexity.

Complex code is more difficult to:

- Review
- Test
- Verify
- Analyze
- Maintain
- Certify

Reducing complexity improves the ability to reason about the software's behavior.

---

# Scope

MISRA C:2012 classifies guidelines according to the scope required to determine compliance.

## Single Translation Unit

A guideline can be evaluated by examining a single C translation unit.

A translation unit generally consists of a source file after preprocessing has incorporated its required headers.

---

## System

A system-level guideline requires examination of multiple components or translation units.

For example, identifying conflicting external declarations may require examining the entire program rather than one source file.

---

# Decidability

MISRA C:2012 also classifies **rules** as either:

- Decidable
- Undecidable

Directives are not classified this way.

## Decidable Rule

A rule is decidable when an analysis tool can theoretically determine whether the program complies with the rule.

## Undecidable Rule

An undecidable rule cannot always be conclusively verified using automated analysis.

Human review or additional project information may therefore be necessary.

---

# Achieving MISRA Compliance

MISRA compliance requires more than running a static-analysis tool.

Compliance is a project-level process involving:

- Coding standards
- Static analysis
- Code review
- Documentation
- Deviation management
- Tool configuration
- Verification activities

MISRA published additional documents specifically addressing how compliance should be demonstrated.

Important compliance documents include:

- **MISRA Compliance:2016**
- **MISRA Compliance:2020**

---

# Compliance Requirements

To claim compliance with MISRA C:

- All **Mandatory** guidelines must be satisfied.
- All **Required** guidelines must either be satisfied or covered by an approved deviation.
- **Advisory** guidelines may be disapplied.
- Decisions concerning advisory guidelines should still be documented.

For compliance purposes, both **rules** and **directives** form part of the guideline set.

MISRA compliance therefore should not be treated simply as:

> "The static analyzer reported zero MISRA warnings."

A complete compliance process also requires documented engineering decisions.

---

# Deviations

MISRA allows controlled deviations from many requirements when there is a legitimate engineering reason.

A deviation does not mean that a rule is simply ignored.

The deviation should be documented and justified.

At minimum, deviation documentation should identify:

- The MISRA rule or directive involved
- The location where the deviation occurs
- The reason for the deviation
- The engineering justification
- The potential risks
- Why the deviation does not adversely affect system safety
- Any compensating controls or verification

Example deviation record:

```text
Rule:
MISRA C Rule X.Y

Location:
temperature_processing.c

Reason:
Hardware interface requires access through a vendor-defined construct.

Safety Impact:
The operation is limited to the hardware abstraction layer and validated
before use.

Mitigation:
Interface behavior is covered by unit testing and static analysis.
```

Deviations should be explicit and reviewable rather than informal exceptions.

---

# Published MISRA C Editions

## MISRA C:1998

The first published edition was:

> Guidelines for the use of the C language in vehicle based software

MISRA C:1998 contains:

- 127 rules
- 93 required rules
- 34 advisory rules

Rules were numbered sequentially from 1 through 127.

---

## MISRA C:2004

MISRA C:2004 significantly revised the original standard.

Its title broadened the intended application beyond automotive software:

> Guidelines for the use of the C language in critical systems

MISRA C:2004 contains:

- 142 rules
- 122 required rules
- 20 advisory rules

The rules were divided into 21 topical categories.

---

# MISRA C:2012

MISRA C:2012 represented another major revision.

The standard expanded support for **C99** while maintaining guidelines applicable to C90.

It contains:

- 143 rules
- 16 directives

Guidelines can be classified as:

- Mandatory
- Required
- Advisory

They can also be classified according to:

- Single Translation Unit
- System scope

Rules are additionally classified as:

- Decidable
- Undecidable

---

## Amendment 1

MISRA published:

> MISRA C:2012 Amendment 1 — Additional Security Guidelines

in 2016.

The amendment added fourteen security-related guidelines.

---

## Amendment 2

MISRA published:

> MISRA C:2012 Amendment 2 — Updates for ISO/IEC 9899:2011/18 Core Functionality

in 2020.

This amendment added mappings covering:

- Undefined behavior
- Unspecified behavior
- Implementation-defined behavior

associated with C11 and C18.

---

# Supporting Documents

Several addenda support MISRA C:2012.

## Addendum 1 — Rule Mappings

Provides mappings between MISRA C:2004 and MISRA C:2012.

This assists projects migrating between standards.

---

## Addendum 2 — ISO/IEC TS 17961

Examines MISRA C:2012 coverage of:

> ISO/IEC TS 17961:2013 — C Secure Coding Rules

---

## Addendum 3 — CERT C

Examines MISRA C:2012 coverage relative to the:

> CERT C Secure Coding Standard

---

# MISRA C:2023

MISRA C:2023 was published in May 2023.

It is described as:

> MISRA C Third Edition, Second Revision

The release incorporated previous:

- Amendments
- Technical corrigenda
- Updates to language support

It includes support for features from:

- C11
- C17

---

# MISRA C:2025

MISRA C:2025 was published in March 2025.

For new projects, the current applicable MISRA standard should normally be evaluated rather than automatically selecting an older edition.

Older MISRA editions may remain relevant to legacy projects whose certification, tooling, or development processes were established against those versions.

---

# Static Analysis

Static analysis is an important part of MISRA development.

Static analyzers inspect source code without executing it and can detect issues involving:

- Type conversions
- Unreachable code
- Undefined behavior
- Pointer misuse
- Control-flow problems
- Uninitialized data
- Rule violations
- Suspicious constructs

However, static analysis alone does not establish full MISRA compliance.

Some guidelines require:

- Manual review
- Architectural analysis
- Process documentation
- Dynamic testing
- Deviation records

---

# MISRA Analysis Tools

Tools capable of checking some or many MISRA requirements include:

- Astrée
- Axivion
- CodeSonar
- Coverity
- Cppcheck
- ECLAIR
- Helix QAC
- Klocwork
- LDRA Testbed
- Parasoft C/C++test
- PC-Lint
- Polyspace
- PVS-Studio
- SonarQube
- SQuORE
- Understand

Some commercial compiler and embedded-development environments also provide MISRA analysis capabilities.

Examples include tools from:

- Green Hills Software
- IAR Systems
- TASKING

Tool support varies by MISRA version and individual rule.

A project should therefore document:

- Analyzer version
- MISRA version
- Enabled checks
- Suppressed checks
- Deviations
- Known tool limitations

---

# MISRA Tool Certification

A tool claiming to perform MISRA analysis does not automatically make a project MISRA compliant.

MISRA does not provide a general certification process under which a static-analysis product itself makes code "MISRA certified."

Tool results must instead form part of the project's overall compliance evidence.

---

# Example Suite

MISRA provides example source code for evaluating analysis-tool behavior.

Example suites have been provided for standards including:

- MISRA C:2004
- MISRA C:2012

These examples help:

- Developers understand rule intent
- Tool users evaluate analyzer behavior
- Tool developers validate rule checking

---

# MISRA and Safety-Critical C Development

MISRA C reduces the unrestricted C language to a safer and more analyzable subset.

This is important because C permits many operations that are valid language constructs but risky in embedded or safety-critical systems.

Examples include:

```c
malloc()
```

```c
goto
```

```c
pointer++
```

```c
signed_value >> shift;
```

```c
value = expression_with_implicit_conversion;
```

The compiler may accept these constructs while their behavior remains difficult to analyze or may depend on implementation details.

MISRA attempts to constrain such behavior through explicit development rules.

---

# Relationship to the Power of 10

MISRA C and the **Power of 10 Rules for Developing Safety-Critical Code** share similar goals but operate at different levels.

The Power of 10 provides a small set of broad restrictions, while MISRA C provides a much larger and more detailed coding standard.

Both emphasize concepts such as:

- Predictable control flow
- Restricted memory behavior
- Limited pointer complexity
- Defensive programming
- Compiler diagnostics
- Static analysis
- Maintainable code
- Verifiable behavior

They can therefore be used together as complementary guidance for safety-oriented embedded C development.

---

# Criticism

MISRA C has also received academic criticism.

Research examining earlier MISRA standards has questioned whether every individual rule strongly correlates with software defects.

Concerns raised in previous research include:

- False positives from static-analysis tools
- Rules that may not strongly correlate with observed faults
- Compliance effort
- Rule interpretation
- Differences in analyzer implementations

These criticisms do not necessarily imply that MISRA has no value.

Instead, they reinforce an important engineering principle:

> Coding standards should be part of a broader software safety and verification process rather than treated as a substitute for engineering analysis.

MISRA should therefore be combined with activities such as:

- Requirements analysis
- Architecture review
- Code review
- Unit testing
- Integration testing
- Static analysis
- Dynamic analysis
- Hazard analysis
- Documented deviation management

---

# Practical Development Principles

For an embedded C project following MISRA principles:

1. Use explicit-width integer types when representation matters.
2. Avoid unnecessary implicit conversions.
3. Validate function parameters.
4. Check function return values.
5. Limit pointer complexity.
6. Avoid undefined and implementation-dependent behavior.
7. Avoid uncontrolled dynamic memory allocation.
8. Keep control flow straightforward.
9. Limit variable scope.
10. Use compiler warnings aggressively.
11. Run static analysis regularly.
12. Document justified rule deviations.
13. Treat warnings and analyzer findings as engineering issues requiring review.
14. Keep safety-related assumptions explicit.

---

# Project Application

For a safety-oriented embedded system, MISRA C can serve as the foundation for project-specific coding instructions.

A project may combine:

```text
MISRA C
    +
Power of 10
    +
Project-specific architecture rules
    +
Compiler warnings
    +
Static analysis
    +
Unit and integration testing
```

This produces a layered development approach where MISRA controls detailed C usage while project-specific standards constrain the system architecture and runtime behavior.

---

# References

- MISRA Consortium, **MISRA C Guidelines**
- MISRA Consortium, **MISRA Compliance**
- ISO 26262, **Road Vehicles — Functional Safety**
- CERT, **CERT C Secure Coding Standard**
- NASA/JPL, **C Coding Standards**
- Gerard J. Holzmann, **The Power of 10: Rules for Developing Safety-Critical Code**

Additional overview:

[MISRA C — Wikipedia](https://en.wikipedia.org/wiki/MISRA_C)