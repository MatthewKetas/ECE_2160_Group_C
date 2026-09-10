# Static Analysis Triage Skill

## Role

Classifies diagnostics from compiler or static-analysis tooling into decision categories.

## Purpose

This skill prevents the team from treating every warning as a confirmed defect while still preserving the evidence trail for each issue, and it should use the project guideline references in `Resources/Guidelines/` to validate whether the warning is relevant to safety-critical guidance.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- compiler output
- static-analysis reports
- build configuration
- source context for each warning

## Workflow

1. Collect diagnostics and map them to the affected code region.
2. Determine whether the warning indicates a confirmed defect, likely defect, or investigation item.
3. Check for tool limitations, false-positive patterns, or accepted deviations.
4. Prioritize findings by impact, reachability, and safety significance.
5. Capture the reasoning behind each classification.

## Outputs

- categorized diagnostics list
- confirmed defect vs likely defect vs false positive assessment
- recommended next review actions

## Quality Gate

Classification should be evidence-based. A warning is not “resolved” simply because it is suppressed; it must be justified by code review or a documented accepted risk.
