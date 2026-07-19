# Changelog

All notable project changes are recorded here. This project follows semantic
versioning with Android build numbers.

## [Unreleased]

### Added

- Governance baseline: operating instructions, master build specification,
  weighted task ledger, progress tracking, roadmap and architecture decisions.
- Content methodology, source/rights, narration, classification, weak-hadith,
  AI, correction, review, reviewer and import policies.
- Release gates, Android/Play release, incident, Play Console, and Data Safety
  runbooks.
- Android-first Flutter mobile shell with four-tab navigation, calm safe empty
  states, display preferences and accessibility controls.
- Flutter web admin shell with responsive navigation and explicit backend setup
  states, without fake content or authentication claims.
- Shared private design-system package with Material 3 tokens/themes and
  reusable empty/card primitives.
- Original Android vector launcher mark and branded splash colours; generated
  Flutter-default launcher/PWA image assets were removed rather than shipped.
- Android release builds now fail closed until the verified signing work in
  REL-03 is complete; only a local debug APK may be built at this stage.
- Initial Supabase structural baseline: policy-defined enums, 27 required
  operational tables plus the content-tag junction, composite ownership
  constraints, timestamps and indexes. It includes no seed data or religious
  content.
- Deny-by-default database posture: RLS is enabled and forced on every
  application table; `PUBLIC`, `anon` and `authenticated` have no table grants
  and no policies exist until BE-02 supplies audited least-privilege access.
- A no-dependency schema guard and pgTAP migration/constraint test foundation.
- Draft-only content intake foundation: a pure-Dart `content_models` package,
  five header-only CSV templates, five JSON Schemas, explicit CSV-to-JSON
  mapping, and guarded empty staging/approved directories.
- Content contract tests compile the Draft 2020-12 schemas against non-claiming
  structural records and reject publication-shaped, unreviewed, untraceable or
  missing-translation-status records. No source, reviewer, evidence or
  religious-content record was imported.

### Religious Content

- No religious content has been published, approved, or imported.

### Known Issues

- Local Supabase reset, lint and pgTAP verification await a Docker engine.
  The structural baseline is present, but BE-02 through BE-05 (admin access,
  workflow/publication gates, public bundles and audit automation), the CNT-02
  import validation CLI, approved data, notifications, offline cache,
  widget, CI, Play assets and release pipeline remain incomplete.
- GitHub CLI is unauthenticated; governance and application-shell commits were
  pushed through git, but no pull request has been created or updated.

### GitHub

- Governance commit: `c1b089b`, application-shell commit: `ae1cde4`, prior
  delivery-record commit: `ece499c`, and schema-baseline commit: `3680dc1`
  plus content-contract commit: `64ea492` pushed to
  `codex/sunnah-everyday-build`.
- Pull request: not created; `gh auth login` or a scoped `GH_TOKEN` is needed.
- CI status: no workflows/runs exist yet.

### Tests

- `dart format --set-exit-if-changed .` passed.
- `flutter analyze` and `flutter test` passed for design system, mobile and admin.
- `node scripts/verify_supabase_baseline.mjs` passed; all four migrations also
  applied in an isolated PostgreSQL/PGlite structural harness.
- `dart analyze` and `dart test` passed for `packages/content_models`.
- `npm run test:content-contract` passed: five JSON Schemas accepted only
  non-claiming structural staging records and rejected invalid boundary cases.
- `npm audit` reported 0 vulnerabilities for the content-contract dev tooling.
- `supabase db reset --local --no-seed` did not run because Docker Desktop/the
  local Docker engine is unavailable; local Supabase lint and pgTAP are not
  reported as passed.
- Android debug APK generated and verified with `aapt`; admin web output generated.
- `flutter build appbundle --release` was intentionally rejected by the REL-03
  signing guard.

## [0.0.0+0] — 2026-07-19

### Added

- Initial repository only.
