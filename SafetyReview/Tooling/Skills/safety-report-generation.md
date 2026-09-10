# Safety Report Generation Skill

## Role

Consolidates validated findings, metrics, and traceability into a final review report.

## Purpose

This skill packages the review into an auditable summary suitable for technical stakeholders, design reviews, or course submissions, and it must summarize the review against the project references in `Resources/Guidelines/`.

## Reference Material

- `Resources/Guidelines/MISRA C.md`
- `Resources/Guidelines/SEI CERT C Coding Standard.md`
- `Resources/Guidelines/The Power of 10_ Rules for Developing Safety-Critical Code.md`

## Inputs

- approved findings
- metrics and evidence
- standards mapping
- traceability records
- methodology description

## Workflow

1. Confirm which findings are approved and ready for reporting.
2. Consolidate supporting metrics and evidence.
3. Summarize the review scope, methodology, and standards used.
4. Organize findings by severity, subsystem, or safety relevance.
5. Review traceability between requirement, code, guideline, and evidence.
6. Produce an executive summary and a final technical appendix.

## Outputs

- final safety review report
- summary of findings and risks
- standards coverage summary
- traceability overview and recommendations

## Quality Gate

The report is complete only when it distinguishes evidence from assumptions, identifies residual risk, and provides a clear path for follow-up.
