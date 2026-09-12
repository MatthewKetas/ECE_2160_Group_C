# Standards Mapping Skill

## Role

Maps an observed code issue, design decision, or failure mode to relevant guidance from MISRA C, SEI CERT C, and The Power of 10 using the project references in `Resources/Guidelines/`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Purpose

This skill is used when a review needs to answer:

- Which coding standard applies?
- Which rule or principle is relevant?
- Does the guidance overlap or conflict?
- Is the guidance mandatory, recommended, or best practice?

## Inputs

- source file or function under review
- observed issue or risky pattern
- applicable project assumptions or safety context
- relevant guideline references

## Workflow

1. Identify the behavior, hazard, or unsafe pattern.
2. Determine the affected domain, such as memory, concurrency, error handling, or control flow.
3. Search the applicable standards for the nearest matching rule or principle.
4. Compare the findings across MISRA C, CERT C, and Power of 10.
5. Record overlap, differences, and whether the guidance is direct or advisory.
6. Capture the rational basis for the mapping and the most relevant standard reference.

## Outputs

- mapped standards references
- identified rule overlap or distinction
- classification of guidance tone: mandatory, required, recommended, or best practice
- explanation of why the issue is considered relevant

## Quality Gate

The mapping is complete only when each conclusion references a clear rule, principle, or rationale and distinguishes between direct requirement and general safety guidance.
