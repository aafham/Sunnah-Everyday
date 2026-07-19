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
Future import tooling must create `DRAFT` records only. It cannot schedule,
approve, publish, make an immutable version, generate a bundle, or decide
religious accuracy. See [the content import guide](../docs/content/CONTENT_IMPORT_GUIDE.md)
and [the content models package](../packages/content_models/README.md).

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
