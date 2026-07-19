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

### Religious Content

- No religious content has been published, approved, or imported.

### Known Issues

- Supabase schema/RLS, content models, import validation, approved data,
  notifications, offline cache, widget, CI, Play assets and release pipeline
  are not yet implemented.
- GitHub CLI is unauthenticated; the governance commit was pushed through git,
  but no pull request has been created or updated.

### GitHub

- Governance commit: `c1b089b` pushed to `codex/sunnah-everyday-build`.
- Pull request: not created; `gh auth login` or a scoped `GH_TOKEN` is needed.
- CI status: no workflows/runs exist yet.

### Tests

- `dart format --set-exit-if-changed .` passed.
- `flutter analyze` and `flutter test` passed for design system, mobile and admin.
- Android debug APK generated and verified with `aapt`; admin web output generated.
- `flutter build appbundle --release` was intentionally rejected by the REL-03
  signing guard.

## [0.0.0+0] — 2026-07-19

### Added

- Initial repository only.
