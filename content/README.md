# Content intake boundary

This directory is a contract for draft intake, not a religious-content dataset
or a public bundle. It contains no source text, Arabic text, translations,
links, reviewer identities, rights documents, evidence records, or publishable
items.

## Layout

- `templates/` contains header-only CSV templates and JSON Schemas.
- `staging/` is for non-public candidates only. Every future fixture must carry
  the exact marker `KANDUNGAN DEMO — TIDAK UNTUK PENERBITAN` and is ignored by
  default so it cannot be added accidentally.
- `approved/` is empty. Human-approved material, source-rights evidence and
  the relevant release gate are required before any record can enter it.

The templates identify logical keys only; they do not create Supabase rows.
`scripts/validate_content.mjs` now reads a caller-supplied five-file CSV batch
in preview mode, verifies the draft contract and cross-record consistency, and
reports only controlled row/path codes. It never writes a file, database row or
network request, and it always reports `importedRecords: 0` and
`publicationEligible: false`. `scripts/import_content.mjs` deliberately
refuses every write until BE-03 has the server-side role, audit and publication
gates. Neither script can schedule, approve, publish, make an immutable
version, generate a bundle, authenticate a narration, or decide religious
accuracy. See [the content import guide](../docs/content/CONTENT_IMPORT_GUIDE.md)
and [the content models package](../packages/content_models/README.md).

Use a local, non-public batch directory outside this repository for a real
candidate batch. `content/staging/` remains an ignored, non-public boundary for
development placeholders, but the source-contract test deliberately requires
its committed contents to remain only the boundary controls:

```powershell
npm run validate:content -- --input <csv-batch-directory> --as-of 2026-07-19
```

The canonical filenames are `sunnah_content.csv`, `source_register.csv`,
`reviewer.csv`, `evidence.csv` and `content_evidence.csv`. The CLI accepts real
quoted CSV fields, requires the exact template headers, maps the existing
canonical schema contract, and does not print cell values.

## Database mapping

| Intake contract | Future database records |
| --- | --- |
| Source register | `sources` and `source_permissions` |
| Reviewer metadata | `reviewers`, `reviewer_qualifications`, `reviewer_scopes` |
| Content candidate | `sunnah_items` and `sunnah_versions` |
| Evidence and links | `evidence_records` and `version_evidences` |

Review decisions, approvals, schedules, public bundles, corrections and
withdrawals are deliberately excluded. Their human workflow and server-side
gates belong to BE-03 through BE-05.
