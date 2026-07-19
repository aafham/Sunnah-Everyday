# Content Import Guide

## Purpose

The future authenticated importer may create draft research records only. The
current CNT-02 tooling is a read-only preview: it never publishes religious
content, assigns authenticity, grants source rights, writes a record, or
substitutes for human review.

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
- `content/staging/` for explicitly non-publication placeholders only; it is
  ignored and must remain boundary-only in committed source
- `content/approved/` only after verified approvals and rights records

The CSV files are header-only. `sunnah_content_schema.json` includes an
explicit mapping from flattened CSV columns to its canonical nested JSON form.
All schema/template checks use structural, non-claiming records only.

## Current implementation boundary

CNT-01 provides the draft-only models, templates, schemas and staging/approved
directory controls. CNT-02 adds a real, read-only CSV validation preview:

```powershell
npm run validate:content -- --input <csv-batch-directory> --as-of 2026-07-19
```

The batch directory must contain these exact files with the exact template
headers:

- `sunnah_content.csv`
- `source_register.csv`
- `reviewer.csv`
- `evidence.csv`
- `content_evidence.csv`

The CLI supports RFC 4180-style quoted fields (including commas, escaped
quotes and newlines), maps the documented CSV paths to the canonical JSON
schemas, runs Draft 2020-12/Ajv validation, and checks duplicates, references,
permission revisions, rights/display compatibility, source dates, locale
state, link coverage/order and exactly one primary evidence link per candidate
version. A source/evidence URL must be an absolute HTTP(S) URL with a host and
no embedded credential. It returns structured codes containing collection, row
and path only; it never prints source text, candidate language, reviewer
details, URLs, rights documents or raw CSV values.

It does not import any source, reviewer, evidence or religious-content record:
`importedRecords` is always `0` and `publicationEligible` is always `false`.
`draftValid` means only that CNT-02 found no hard draft-validation error;
`hasPublicReadinessBlockers` remains separate and neither field means approval
or permission to publish.
`--as-of YYYY-MM-DD` makes permission-expiry reporting deterministic. Omitting
it uses the current UTC date only for the local preview; use an explicit date
in review/CI records.

`scripts/import_content.mjs` is intentionally fail-closed. It runs the same
preview and then exits without writes, approvals or publication. A real
server-side importer remains out of scope until BE-03 supplies authenticated
roles, audit records, immutable versions and publication enforcement.

## Import flow

1. Prepare source and reviewer metadata in a controlled local research
   workspace outside this repository; do not add candidates to
   `content/approved/`.
2. Fill every required metadata, locale, evidence, rights and workflow field in
   a canonical five-file CSV batch.
3. Run the validation CLI in preview mode with an explicit `--as-of` date.
4. Resolve every error. Treat reported rights, expiry, link-only URL and
   unavailable-translation blockers as non-public until the responsible humans
   resolve them.
5. Record the human source/rights, fiqh/context, language and final decisions
   in the future audited CMS workflow. A reviewer reference resolving to a
   draft metadata row is not a reviewer approval.
6. Use the future authenticated server-side importer only after BE-03 is
   implemented; the current importer refuses all writes.
7. Publish only through the database/server gate after all approvals and
   release-bundle checks pass.

## Development data

Staging fixtures must be non-claiming and clearly include `KANDUNGAN DEMO —
TIDAK UNTUK PENERBITAN`. They must never be copied into `content/approved/`,
a public bundle, Open Testing, or Production. `content/staging/` and
`content/approved/` are currently empty and ignore candidate data by default;
an explicit reviewed change is required before material can be committed.

## Validation failures

CNT-02 fails on malformed CSV/header/type data, draft-envelope violations,
duplicate keys/orders, unresolved source/evidence/reviewer/content references,
permission revision/status/display mismatches, contradictory licensed-display
claims, source-date errors, missing primary/link coverage, and incomplete or
contradictory BM/English locale states. It reports unresolved rights, expiry,
missing permission metadata, missing link-only URL and intentionally
unavailable translations as public-readiness blockers without treating a draft
as public.

CNT-02 deliberately does **not** authenticate grades, decide classifications,
verify reviewer qualifications/approval, schedule Daily Feed content, create a
release bundle, or assess publication eligibility. Daily grade, placeholder
release-bundle, distinct-human approval, immutable-version and server workflow
gates belong to CNT-03 and BE-03. Preserve the safe error report and do not log
protected full text or private reviewer data.
