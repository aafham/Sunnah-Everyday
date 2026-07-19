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
- Read-only CNT-02 CSV validation preview: an RFC 4180-capable parser for the
  five canonical draft files, schema mapping/Ajv checks, trim-aware metadata
  and locale checks, duplicate/reference/link coverage checks, permission
  revision/rights/date checks and safe structured reports. It performs no
  database, network or filesystem write and always reports zero imports and no
  publication eligibility.
- A fail-closed `import_content.mjs` executable validates a batch then refuses
  every write until BE-03 supplies authenticated server workflow and audit
  gates. Structural valid/invalid fixtures contain no religious content.
- Locale schemas and Dart draft models now reject text alongside an unavailable
  locale and reject an unavailable rationale alongside a complete locale.
- QLT-01 Flutter test foundation: a private `testing_utils` package supplies
  deterministic viewport, media-preference and bounded-transition helpers;
  mobile/admin application harnesses own router/provider setup; hit-test
  warnings are fatal; and a root Node runner invokes each Flutter target from
  its own package directory.
- A Flutter testing guide documents the repeatable local commands, test-data
  boundary and intentionally deferred integration/accessibility/security work.
- REL-01 read-only GitHub Actions Quality workflow: SHA-pinned checkout, Node
  and Flutter setup; contracts/content/schema guards; Flutter format/analyze/
  test coverage; and debug APK/admin-web smoke builds. It has read-only
  permissions, no secrets, caches, artifacts, Android release-AAB, Play or
  deployment operation. The policy verifier fails closed for syntax, triggers, workflow or
  job permissions, extra jobs, action pins, executable parity commands,
  secret references and release/upload operations.

### Religious Content

- No religious content has been published, approved, or imported.

### Known Issues

- Local Supabase reset, lint and pgTAP verification await a Docker engine.
  The structural baseline is present, but BE-02 through BE-05 (admin access,
  workflow/publication gates, public bundles and audit automation), CNT-03
  publication-bundle validation, approved data, notifications, offline cache,
  widget, CI, Play assets and release pipeline remain incomplete.
- Protected repository settings and pull-request creation still cannot be
  inspected or changed because GitHub authentication is unavailable.
- GitHub CLI is unauthenticated; governance and application-shell commits were
  pushed through git, but no pull request has been created or updated.

### GitHub

- Governance commit: `c1b089b`, application-shell commit: `ae1cde4`, prior
  delivery-record commit: `ece499c`, schema-baseline commit: `3680dc1`,
  content-contract commit: `64ea492`, and content-validation commit:
  `e0aeb6f`; Flutter-test-harness commit: `458232b`, pushed to
  `codex/sunnah-everyday-build`; CI workflow/hardening commits: `1c2463d`,
  `4ceff86` and `766e1fb`, pushed to the same branch.
- Pull request: not created; `gh auth login` or a scoped `GH_TOKEN` is needed.
- CI status: Quality run `29677407731` passed all three jobs for `766e1fb`.

### Tests

- `dart format --set-exit-if-changed .` passed.
- `flutter analyze` and `flutter test` passed for design system, mobile and admin.
- `npm run test:flutter-runner` passed (3 tests), and `npm run check:flutter`
  passed analyzer plus widget/unit tests for `testing_utils` (1), design system
  (3), mobile (4) and admin (4).
- `npm run test:ci-workflow` passed (7 policy tests); `npm audit` reported 0
  vulnerabilities. Local debug APK and admin-web smoke builds passed.
- GitHub Quality run `29677407731` passed contracts, Flutter quality and
  debug/web smoke checks on `766e1fb`.
- `node scripts/verify_supabase_baseline.mjs` passed; all four migrations also
  applied in an isolated PostgreSQL/PGlite structural harness.
- `dart analyze` and `dart test` passed for `packages/content_models`.
- `npm run test:content-contract` passed: five JSON Schemas accepted only
  non-claiming structural staging records and rejected invalid boundary cases.
- `npm run test:content-validation` passed: 14 CSV/parser/schema/duplicate,
  reference, rights, translation, safe-report and fail-closed-import tests.
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
