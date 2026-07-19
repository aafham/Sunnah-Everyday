# Sunnah Everyday

Sunnah Everyday ialah aplikasi Flutter Android-first yang membantu pengguna
mengenal, memahami dan cuba mengamalkan satu sunnah atau adab Nabawi pada satu
masa. Setiap kandungan public direka untuk memaparkan cara amalan, dalil, status
riwayat, konteks, sumber dan rekod semakan secara telus. Projek ini
mengutamakan ketepatan kandungan, privasi pengguna, pengalaman minimalis dan
akses offline.

> **Status awal:** repositori sedang dibina daripada asas. Tiada kandungan
> agama public, approved, atau disahkan telah dimasukkan. Jangan gunakan build
> pembangunan untuk Open Testing atau Production.

## Mission

Satu Sunnah. Satu Hari. Satu Langkah. Aplikasi ini memberi pembelajaran umum,
bukan fatwa, dan tidak mewakili JAKIM, pejabat mufti, atau mana-mana agensi
tanpa kebenaran bertulis.

## Planned capabilities

- Today, evidence-led detail, situation discovery, categories and offline search.
- Bounded Android-local private reflections and UI preferences. Content-bound
  bookmarks, viewed history and practice tracking remain deferred until a
  verified immutable public-bundle reference exists.
- BM/English, dark mode, text scaling, reduced motion and a generic RTL-layout
  baseline; Arabic locale, font and content remain deferred pending rights and
  human review.
- Source, reviewer, methodology, correction, report, privacy and terms pages.
- Flutter web admin CMS, Supabase workflow/RLS, immutable content versions and
  publication validation.

## Religious-content safeguards

No hadith or religious claim is generated, self-graded, or published by AI.
Public content requires rights clearance and human source/hadith, fiqh/context,
language, and final publication review by at least two people. Daily Feed is
specified to accept only `SAHIH` or `HASAN` evidence through a database/server
gate; that enforcement is a future BE-03 gate, not a claim about this baseline.
See
[content policies](docs/content/) and [the master specification](MASTER_BUILD_SPEC.md).

## Non-goals

No full Quran, prayer time, qibla, social feed, public worship tracking,
leaderboard, reward points, AI fatwa, advertisements, marketplace, mandatory
user account, continuous location, contacts, or unneeded device permissions.

## Architecture

The target monorepo contains Flutter mobile/admin apps, shared packages and
test support, Supabase migrations/functions/tests, a draft-only content intake
contract, Android release materials, documentation, and future GitHub Actions.
Flutter stable, Dart,
Material 3, Riverpod, go_router, generated ARB localisation, allowlisted UI
preferences and a bounded Android secure-storage reflection envelope support
the current shell. Drift, Supabase, local notifications and native
Kotlin/Glance widget support remain planned.

## Current repository status

| Area | Status |
| --- | --- |
| Version / milestone | `0.1.0+1` development baseline / M0 closeout with M1 core experience started |
| Completion | 32.0% weighted; PDX-01, PDX-02, PDX-03, MOB-01, MOB-02, MOB-03, MOB-05, MOB-06, CNT-01, CNT-02, QLT-01 and REL-01 complete. MOB-05 is deliberately the bounded reflection slice; dependency-gated content-bound bookmarks/history/practice tracking are tracked separately as MOB-08 |
| App / admin / migrations | The mobile shell now has a local first-launch onboarding gate, exactly BM/English UI selection, allowlisted device UI preferences, bounded Android-only private reflections, verified System/Light/Dark settings, 90–150% text scaling and composed reduced motion, plus fail-closed Daily/status/detail views. Reflections have no content reference or network/admin/analytics path; browser and unsupported platforms fail closed. Bookmarks, view history and practice tracking remain unavailable until a verified immutable public-bundle reference exists. Shared layout tokens enforce a 560 logical-pixel mobile content cap, directional mobile page insets, a direction-aware return affordance, 960 admin drawer/rail breakpoint and 1040 admin content cap. Generic RTL layout is exercised only through a widget-test override; it does not enable an RTL locale or add Arabic text/font, religious content/data, source records, backend access or publication. The web-admin shell, shared deterministic Flutter test harness, read-only GitHub Quality workflow and fail-closed structural Supabase baseline remain implemented; local Supabase runtime validation is pending Docker |
| Content intake | Draft-only models, schemas, header-only templates and a read-only CSV validation preview implemented; 0 imported/approved/public items |
| Approved content | 0 items; no reviewer or source-rights records |
| GitHub | `0f4e79b` pushed on feature branch `codex/sunnah-everyday-build`; the public GitHub API reports 0 open pull requests for the branch, and creation or update is blocked by unavailable GitHub CLI authentication/session |
| CI | Read-only Quality run [`29682938797`](https://github.com/aafham/Sunnah-Everyday/actions/runs/29682938797) passed contracts, Flutter quality and debug/web smoke for `0f4e79b`; it cannot release or upload |
| Google Play | No app/AAB/upload/submission/availability |

Full work tracking is in [TASKS.md](TASKS.md), [PROGRESS.md](PROGRESS.md),
[ROADMAP.md](ROADMAP.md), and [DECISIONS.md](DECISIONS.md). The current
mobile/admin UI contract is documented in
[UX_SPECIFICATION.md](docs/design/UX_SPECIFICATION.md).

## Local setup

Flutter 3.44.6 / Dart 3.12.2 and Android SDK 36.1 are available in the
bootstrap environment. Never commit `.env`, signing keys, service-account JSON,
or other secrets.

```powershell
cd apps/mobile
flutter pub get
flutter run

cd ../admin
flutter pub get
flutter run -d chrome
```

Run `dart format --set-exit-if-changed .`, `npm run test:flutter-runner`, then
`npm run check:flutter` from the repository root. The explicit runner invokes
each Flutter workspace (`packages/testing_utils`, `packages/design_system`,
`apps/mobile` and `apps/admin`) from its own package directory; the repository
root itself is not a Flutter package. See
[the Flutter testing guide](docs/testing/TESTING_GUIDE.md). The mobile Android
application ID is
`com.aafha.sunnaheveryday`; a debug APK was generated and inspected locally.

Mobile UI copy lives in `apps/mobile/lib/l10n/app_ms.arb` and `app_en.arb`.
Their generated Dart localizations are versioned with the app so checked-in
source is analyzable; after changing either ARB file, run `flutter gen-l10n`
from `apps/mobile` before format, analysis and tests.

The read-only GitHub Actions quality workflow and exact local parity commands
are documented in [the CI workflow guide](docs/release/GITHUB_ACTIONS.md). It
does not create a release artifact, sign an AAB, use secrets, upload artifacts,
or contact Google Play.

The structural Supabase baseline has no seed data, public API access or content.
Run `node scripts/verify_supabase_baseline.mjs` without Docker. The local
Supabase migration, lint and pgTAP commands require Docker and are documented
in [supabase/README.md](supabase/README.md); never point them at a linked or
production project without explicit owner authority.

The content contract is similarly non-public: run `npm ci --ignore-scripts`,
`npm run test:content-contract`, and `npm run test:content-validation`. To
preview a local five-file CSV batch without writing anything, run:

```powershell
npm run validate:content -- --input <csv-batch-directory> --as-of 2026-07-19
```

The preview supports quoted CSV fields, checks schemas, duplicate/reference/
rights/translation constraints and reports safe row/path codes only. A passing
draft preview never means approval or publication: it always reports zero
imports and `publicationEligible: false`; `scripts/import_content.mjs` refuses
writes until the future server workflow exists. In `packages/content_models`,
run `dart pub get`, `dart analyze`, and `dart test`. It contains only
structural test records, never religious data. See
[content/README.md](content/README.md).

## Releases and Google Play

No signed release AAB has been generated or uploaded. A local debug APK exists
for development verification only. Internal Testing is the highest possible
future track while only staging content exists; Production is blocked
by approved content, reviewers, source rights, privacy/support URL, signing,
Play access, and release gates. See [release runbooks](docs/release/) and
[Play Console runbooks](docs/play-console/).

## Rights and contribution

Do not add religious text, translations, imagery, fonts, data, or source links
without recording ownership, permitted use, and review requirements. Follow
[AGENTS.md](AGENTS.md) before changing the project.
