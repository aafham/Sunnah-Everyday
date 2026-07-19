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
- MOB-02 local first-launch onboarding: BM is the default UI language, English
  is selectable during onboarding and later in Settings, and a router gate
  keeps shell/deep routes behind completion. Only allowlisted UI preferences
  (onboarding state, locale, theme, reduced motion and text scale) persist on
  device; no content, source, reviewer, reflection or credential data is stored.
- MOB-03 fail-closed Daily/status/detail presentation: the app now has a static
  Daily detail route and unavailable-status card driven only by
  `NoApprovedDailyContent`. The reader carries no identifier, title, source,
  evidence, grade or body fields, and does not read draft CSV, staging,
  approved directories or a network source.
- PDX-02 executable mobile/admin UX contract: shared `SunnahLayout` tokens
  now own the current spacing, control radius, mobile readable width and admin
  breakpoint/content dimensions. `SunnahContentFrame` caps shell content at
  560 logical pixels; admin switches drawer/rail at 960 and caps content at
  1040. The specification records component, responsive, semantic and
  fail-closed state rules without adding any content or backend path.
- PDX-03 generic RTL/accessibility baseline: installed UI locales remain
  exactly BM/English; directional mobile page insets, Material's
  direction-aware `BackButtonIcon` and semantic app-bar headings are covered
  by widget tests. An internal test-only direction override exercises generic
  layout; it adds no RTL locale, Arabic text/font, religious content/data,
  source record, backend access or publication path.
- MOB-05 private-reflection slice: the Android shell now supports up to 50
  locally stored free-text private reflections of 500 characters each through
  an isolated secure-storage adapter. The field disables autocorrect,
  suggestions, autofill and IME personalized learning; it offers individual
  and confirmed all-reflection deletion, and fails closed without a plaintext
  or browser fallback. Corrupt data can only be cleared through the scoped
  secure key. No reflection text reaches a network, admin, analytics or export
  path. Content bookmarks, viewed history and practice tracking remain
  unavailable until a verified immutable public-bundle reference exists.
- Android backup configuration now disables backup and explicitly excludes
  application domains from legacy, cloud and device-transfer rule sets. This
  is not a claim of secure erasure, universal transfer prevention or completed
  Play Data Safety review.
- Versioned BM/English ARB source and generated localizations now cover the
  existing mobile shell copy. They add no religious-content records or claims.
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
  widget, Play assets and release pipeline remain incomplete.
- Protected repository settings and pull-request creation still cannot be
  inspected or changed because GitHub authentication is unavailable.
- GitHub CLI is unauthenticated; governance and application-shell commits were
  pushed through git, but no pull request has been created or updated.
- MOB-08 remains dependency-gated: verified immutable content references and
  the future transactional bundle store are required before local bookmarks,
  viewed history and practice tracking can operate safely.

### GitHub

- Governance commit: `c1b089b`, application-shell commit: `ae1cde4`, prior
  delivery-record commit: `ece499c`, schema-baseline commit: `3680dc1`,
  content-contract commit: `64ea492`, and content-validation commit:
  `e0aeb6f`; Flutter-test-harness commit: `458232b`, mobile-onboarding commit:
  `4913b54`, fail-closed-daily commit: `c8ddbeb`, responsive-UX commit:
  `56daf54`, generic-RTL feature commit: `3031af2`, and private-reflection
  feature commit: `86f80ba`, pushed to
  `codex/sunnah-everyday-build`; CI workflow/hardening commits: `1c2463d`,
  `4ceff86` and `766e1fb`, pushed to the same branch.
- Pull request: not created; `gh auth login` or a scoped `GH_TOKEN` is needed.
- CI status: Quality run `29682293929` is in progress for `86f80ba`; contracts
  and Flutter quality have passed, while debug/web smoke remains in progress.

### Tests

- `dart format --set-exit-if-changed .` passed (42 files, 0 changes).
- `flutter analyze` and `flutter test` passed for design system, mobile and admin.
- `npm run test:flutter-runner` passed (3 tests), and `npm run check:flutter`
  passed analyzer plus widget/unit tests for `testing_utils` (1), design system
  (3), mobile (9) and admin (4).
- Mobile unit/widget checks cover corrupt-preference fallback, rehydration,
  scale bounds, first-launch language selection, deep-route gating and runtime
  locale changes; `flutter build apk --debug` passed. No release AAB was built.
- MOB-03 source/test formatting, `flutter analyze`, and `flutter test` passed
  for mobile (15 tests). The checks cover unavailable Daily state, its static
  detail route, onboarding gating, localized status copy and semantic back
  navigation; the debug APK smoke build passed. No content record was used.
- PDX-02 formatting passed for design system (7 files), mobile (21) and admin
  (8), with zero changes. Analyzer and widget tests passed: 6 design-system,
  16 mobile and 5 admin tests; the root Flutter runner passed (3), and the
  root quality check included 1 `testing_utils` test. Mobile debug APK and
  admin-web builds both passed locally. No release AAB was built.
- PDX-03 formatting passed with zero changes for design system (7 files) and
  mobile (22). `flutter analyze` and `flutter test` passed for design system
  (6 tests) and mobile (20 tests); the root quality check passed analyzers and
  tests for `testing_utils` (1), design system (6), mobile (20) and admin (5).
  The Flutter runner (3 tests) and CI-workflow policy suite (7 tests) passed.
  Mobile debug APK and admin-web smoke builds passed locally; no release AAB
  was built.
- The MOB-05 reflection slice passed `flutter gen-l10n`, format, mobile
  analysis and 39 mobile tests. A fresh Android debug APK build passed; no
  release AAB was built. Tests cover bounded persistence/reopen, generic
  failures, write rollback with retained UI input, per-note and confirmed
  all-reflection deletion, corrupt-envelope recovery deletion, unsupported
  platform failure, preference allowlisting and backup-rule source.
- `npm run test:ci-workflow` passed (7 policy tests); `npm audit` reported 0
  vulnerabilities. Local debug APK and admin-web smoke builds passed.
- GitHub Quality run `29677407731` passed contracts, Flutter quality and
  debug/web smoke checks on `766e1fb`.
- GitHub Quality run `29678240092` passed contracts, Flutter quality and
  debug/web smoke checks on `4913b54`.
- GitHub Quality run `29678798552` passed contracts, Flutter quality and
  debug/web smoke checks on `c8ddbeb`.
- GitHub Quality run `29679773365` passed contracts, Flutter quality and
  debug/web smoke checks on `56daf54`.
- GitHub Quality run `29680455827` passed contracts, Flutter quality and
  debug/web smoke checks on `3031af2`.
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
