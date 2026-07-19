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
- Private local bookmarks/reflections, preferences, reminders and Android widget.
- BM/English, dark mode, text scaling, reduced motion and RTL-aware Arabic.
- Source, reviewer, methodology, correction, report, privacy and terms pages.
- Flutter web admin CMS, Supabase workflow/RLS, immutable content versions and
  publication validation.

## Religious-content safeguards

No hadith or religious claim is generated, self-graded, or published by AI.
Public content requires rights clearance and human source/hadith, fiqh/context,
language, and final publication review by at least two people. Daily Feed will
accept only `SAHIH` or `HASAN` evidence through a database/server gate. See
[content policies](docs/content/) and [the master specification](MASTER_BUILD_SPEC.md).

## Non-goals

No full Quran, prayer time, qibla, social feed, public worship tracking,
leaderboard, reward points, AI fatwa, advertisements, marketplace, mandatory
user account, continuous location, contacts, or unneeded device permissions.

## Architecture

The target monorepo contains Flutter mobile/admin apps and shared packages,
Supabase migrations/functions/tests, content templates/validation, Android
release materials, documentation, and GitHub Actions. Flutter stable, Dart,
Material 3, Riverpod, go_router, Drift, Supabase, local notifications, native
Kotlin/Glance widget support, and ARB localisation are planned.

## Current repository status

| Area | Status |
| --- | --- |
| Version / milestone | `0.1.0+1` / M0 bootstrap |
| Completion | 3.0% weighted; PDX-01 complete and MOB-01 selected |
| App / admin / migrations | Not yet initialised |
| Approved content | 0 items; no reviewer or source-rights records |
| GitHub | Feature branch `codex/sunnah-everyday-build`; no verified push/PR for bootstrap work |
| CI | Not configured |
| Google Play | No app/AAB/upload/submission/availability |

Full work tracking is in [TASKS.md](TASKS.md), [PROGRESS.md](PROGRESS.md),
[ROADMAP.md](ROADMAP.md), and [DECISIONS.md](DECISIONS.md).

## Local setup (planned)

Flutter 3.44.6 / Dart 3.12.2 and Android SDK 36.1 are available in the
bootstrap environment. Exact commands will be added when the workspace exists.
Never commit `.env`, signing keys, service-account JSON, or other secrets.

## Releases and Google Play

No build has been generated or uploaded. Internal Testing is the highest
possible future track while only staging content exists; Production is blocked
by approved content, reviewers, source rights, privacy/support URL, signing,
Play access, and release gates. See [release runbooks](docs/release/) and
[Play Console runbooks](docs/play-console/).

## Rights and contribution

Do not add religious text, translations, imagery, fonts, data, or source links
without recording ownership, permitted use, and review requirements. Follow
[AGENTS.md](AGENTS.md) before changing the project.
