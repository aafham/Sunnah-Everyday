# Draft intake templates

Every CSV in this folder intentionally contains its header row only. A header
is a contract, not example content. Do not add names, sources, URLs, religious
text, grades, classifications, reviewer details, or rights documents as sample
rows.

All templates use logical keys rather than database UUIDs. JSON-valued CSV
columns (`tag_slugs`, scopes and key lists) are arrays when an import tool is
implemented. The matching JSON Schemas are the canonical nested form.

`sunnah_content_template.csv` describes a staged content version. Evidence is
described separately in `evidence_template.csv` and linked by
`content_evidence_template.csv`. Evidence records store Arabic-display and
translation *status* only; neither template stores protected source text.
Reviewer rows establish draft metadata only; they do not import a review or
approval decision.

Only `STAGING` and `DRAFT` appear in the import contract. Server-managed
publication fields and a public bundle are not accepted here.
