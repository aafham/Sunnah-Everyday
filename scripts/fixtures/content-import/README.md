# CNT-02 validation fixtures

`valid/` is a complete, non-claiming CSV batch for automated validation tests.
Every row is deliberately structural: it carries the required non-publication
marker, uses opaque `STRUCTURAL_TEST` metadata, contains no source text,
translation, person, real URL, rights document, or religious claim, and is
never an application asset or import candidate.

Invalid test cases are constructed from this batch in
`scripts/validate_content.test.mjs`. They mutate only structural keys or
metadata to exercise duplicate, reference, rights, translation and link gates.
The validator must not report a cell value from either the valid or invalid
fixtures.

`invalid-workflow/` is the same structural batch with one deliberately invalid
workflow field. It proves that the executable rejects a release-shaped input
before any import path can run.

The `valid/` batch intentionally records unavailable BM/English locales and a
link-only source without a direct URL. That is valid for a non-public draft,
but correctly produces public-readiness blockers; it never represents approval
or publication eligibility.
