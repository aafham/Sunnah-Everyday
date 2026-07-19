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
- `content/staging/` for explicitly non-publication data only
- `content/approved/` only after verified approvals and rights records

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
a public bundle, Open Testing, or Production.

## Validation failures

Validation must fail on duplicate keys, missing source metadata, invalid rights
status/display mode, incomplete BM/English fields where required, missing review
data, a forbidden Daily Feed grade, staging/placeholder text in a release
bundle, or a public item without evidence. Preserve a safe error report and do
not log protected full text or private reviewer data.
