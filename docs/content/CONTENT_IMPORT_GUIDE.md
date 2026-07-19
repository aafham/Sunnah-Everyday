# Content Import Guide

## Purpose

Import creates draft research records only. It never publishes religious
content, assigns authenticity, grants source rights, or substitutes for human
review.

## Required files and locations

- `content/templates/sunnah_content_template.csv`
- `content/templates/sunnah_content_schema.json`
- `content/templates/source_register_template.csv`
- `content/templates/reviewer_template.csv`
- `content/templates/evidence_template.csv`
- `content/templates/content_evidence_template.csv`
- `content/templates/source_register_schema.json`
- `content/templates/reviewer_schema.json`
- `content/templates/evidence_schema.json`
- `content/templates/content_evidence_schema.json`
- `packages/content_models/` for the shared draft-only model contract
- `content/staging/` for explicitly non-publication data only
- `content/approved/` only after verified approvals and rights records

The CSV files are header-only. `sunnah_content_schema.json` includes an
explicit mapping from flattened CSV columns to its canonical nested JSON form.
All schema/template checks use structural, non-claiming records only.

## Current implementation boundary

CNT-01 provides the draft-only models, templates, schemas and staging/approved
directory controls. It has not imported any source, reviewer, evidence or
religious-content record. CNT-02 will add the actual validation CLI and its
duplicate/translation/rights reports; BE-03 owns publication enforcement.

## Import flow

1. Create/verify source and reviewer records first.
2. Fill every required metadata, locale, evidence, rights and workflow field.
3. Run the validation CLI in preview mode.
4. Resolve duplicate, missing translation, rights, source, evidence and schema
   errors; do not suppress them.
5. Import as `DRAFT` with an audit record.
6. Use the CMS queues for research and human review.
7. Publish only through the database/server gate after all approvals.

## Development data

Staging fixtures must be non-claiming and clearly include `KANDUNGAN DEMO —
TIDAK UNTUK PENERBITAN`. They must never be copied into `content/approved/`,
a public bundle, Open Testing, or Production. `content/staging/` and
`content/approved/` are currently empty and ignore candidate data by default;
an explicit reviewed change is required before material can be committed.

## Validation failures

Validation must fail on duplicate keys, missing source metadata, invalid rights
status/display mode, incomplete BM/English fields where required, missing review
data, a forbidden Daily Feed grade, staging/placeholder text in a release
bundle, or a public item without evidence. Preserve a safe error report and do
not log protected full text or private reviewer data.
