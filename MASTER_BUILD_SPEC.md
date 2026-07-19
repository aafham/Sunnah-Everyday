# Sunnah Everyday — Master Build Specification

This repository-controlled specification normalises the owner-supplied master
execution brief dated 2026-07-19. The complete brief was read before this file
was created; this document preserves its operative requirements in a form that
is maintained with the codebase.

## Product identity

- **Name:** Sunnah Everyday
- **Tagline:** Satu Sunnah. Satu Hari. Satu Langkah.
- **Package ID:** `com.aafha.sunnaheveryday` (do not change after Play app
  creation; verify availability before creation).
- **Platform:** Flutter, Android-first; architecture must not preclude iOS.
- **Primary language:** Bahasa Melayu; English is the second language.
- **Initial market:** Malaysia.
- **Positioning:** Daily Sunnah + situational library + verifiable evidence.

The product helps users discover, understand, and gradually try approved
Sunnah and Prophetic manners. It is general education, not a fatwa service,
and must never claim institutional affiliation without written authority.

## Required v1 capabilities

1. Onboarding, BM/English selection, Today, daily card and detail, practical
   steps, evidence, source, context, narration status, classification, and
   reviewer information.
2. Situation mode, categories, local offline search, bookmarks, private local
   reflections, calm private "Saya cuba amalkan hari ini" tracking, settings,
   dark mode, text scaling, and reduce motion.
3. Local daily reminder, Android home-screen widget, deep links, offline
   cache/bundle handling, corrections and withdrawals.
4. Methodology, source register, reviewer panel, correction history, report
   content, privacy, terms, disclaimer, and about pages.
5. Flutter web admin CMS with role-based review queues, structured editor,
   scheduling, immutable versions, source/rights management, corrections,
   reports, audit logs, and publication-bundle status.
6. Supabase migrations, RLS, server/database publication gates, automated
   tests, CI, Android release pipeline, Play metadata/assets, and public
   privacy/support pages.

Out of scope for v1: full Quran, prayer times, qibla, generic digital tasbih,
marketplace, social feed/profile/activity, open chat, AI fatwa, livestream,
masjid finder, ads, purchases, affiliates, continuous location, contacts, and
unnecessary camera or microphone access.

## Religious-content contract

Religious accuracy outranks speed and engagement. The product must not invent
hadith, alter quotes, determine authentication, determine legal status, issue
fatwa, or treat every prophetic action as recommended practice. It must not
use viral/unauthoritative sources or copy copyrighted religious material
without rights records.

The system supports four source layers: primary text, narration assessment,
authoritative explanation, and approved plain-language editorial summaries.
Every source record stores ownership, type, locator, edition, language, rights
and licence details, access/review dates, permission status, relevant document,
and usage limits. Permission states are `UNKNOWN`, `REQUESTED`, `GRANTED`,
`PUBLIC_LICENSE`, `LINK_ONLY`, `RESTRICTED`, `EXPIRED`, and `REJECTED`.

Two presentation modes are required:

- **Link-only:** original app summary plus a link to an official source.
- **Licensed content:** source text only when its recorded licence or
  permission permits display.

Daily Feed accepts only `SAHIH` or `HASAN` evidence. The model still supports
`DAIF`, `VERY_WEAK`, `FABRICATED`, `DISPUTED`, `UNGRADED`, and
`NOT_APPLICABLE`; database/server validation must reject the first five
non-permitted grades from the daily feed. Classification is independent from
narration status and supports `SUNNAH_RECOMMENDED`, `ADAB`, `AKHLAQ`,
`OBLIGATORY`, `PERMISSIBLE`, `PROPHETIC_HABIT`, `PROPHET_SPECIFIC`,
`CONTEXT_SPECIFIC`, `DISPUTED`, `HISTORICAL_INFORMATION`, `DUA`, and `DHIKR`.

Public content requires source/hadith review, fiqh/context review, language
review, final publication approval, at least two distinct human reviewers,
clear source rights, dated reviewer identities, an immutable version, and an
audit trail. The normal workflow is:

`DRAFT → RESEARCHED → HADITH_VERIFIED → FIQH_REVIEWED → LANGUAGE_REVIEWED → APPROVED → SCHEDULED → PUBLISHED`.

Published versions are never edited in place. Corrections clone a version,
record a reason and diff, repeat required review, publish a new immutable
version, preserve the old one, and inform users when material. Withdrawals
immediately override cache and widget content while retaining audit history.

Without an approved dataset, build the system and validation/import workflow
only. Development placeholders must state `KANDUNGAN DEMO — TIDAK UNTUK
PENERBITAN`, include no religious claim, and never go to Open Testing or
Production.

## Technical architecture

- Flutter and Dart stable, Material 3, Riverpod, go_router, `intl`/ARB.
- Drift local relational storage for cache, search and personal data.
- Supabase PostgreSQL/Auth (admins only), RLS, migrations, and edge functions
  where server-side publication/bundle validation is required.
- `flutter_local_notifications`; native Kotlin/Jetpack Glance with a Flutter
  bridge for Android widgets; connectivity-aware refresh/background work.
- Flutter Web admin dashboard with keyboard-accessible desktop-first UI.
- No service-role secret in the client; pinned maintained dependencies with
  compatible licences and no ad/Advertising ID SDKs.

The database must cover admin profiles/roles/assignments, reviewers and
qualifications/scopes, sources and permissions, categories/tags, content items
and immutable versions, evidence, reviews/approvals, daily schedules,
collections, corrections/withdrawals/reports, public bundles, publication
events, audit logs, app configuration, and locales. RLS/publication tests must
prove that drafts and private reviewer details cannot be read publicly,
researchers cannot publish, reviewers cannot self-approve without another
reviewer, and withdrawals remove public availability.

## Experience requirements

Bottom navigation is exactly Hari Ini, Teroka, Simpanan, and Tetapan. Today is
clean and progressively discloses evidence. It must not use reward points,
public streaks, leaderboards, shame, or claims of spiritual reward. Search is
local/offline over cached approved content only. Arabic is selectable text with
RTL support and a licensed readable font, never an image. The visual system is
minimal, calm, accessible, and uses Warm Ivory `#F7F4EC`, Deep Forest
`#123F35`, Sage `#A8BFAF`, restrained Muted Gold `#C6A15B`, Charcoal
`#17211D`, and Dark Background `#0D1714`.

Widgets have small, medium, and large responsive layouts, light/dark themes,
deep links (`sunnah://daily/{content_id}`, `sunnah://content/{content_id}`,
`sunnah://correction/{correction_id}`), offline safe fallback, post-midnight,
reboot, timezone, and withdrawal handling. Do not place long Arabic texts,
drafts, or production placeholders in a widget.

## Quality, privacy, and delivery

Implement unit, widget, integration, database/RLS, content-validation,
publication-gate, scheduler, widget, deep-link, localisation, accessibility,
admin-workflow, and relevant golden tests. Test no-internet, corrupt bundles,
withdrawals, timezone/midnight/reboot, denied notification permission, Arabic
RTL, large text, dark mode, BM/English search, admin access, prohibited grades,
placeholders, missing rights, duplicate imports, small devices, and tablets.

The public app has no mandatory account, ads, Advertising ID, location,
contacts, social graph, cross-app tracking, or unapproved analytics. Private
reflections remain local. Before a Play submission, audit actual permissions,
dependencies, network calls, SDK collection and Data Safety answers.

Each atomic task must pass formatting, analysis and relevant tests; update the
five tracking documents; use a Conventional Commit; and record actual push/PR/
CI results. A release-ready milestone additionally needs a signed AAB, release
notes, Play readiness audit, and an upload only if permitted credentials exist.

## Release gates

- **Milestone 0 (0.1.0+1):** repository/governance, workspace, initial
  migrations, CI, documentation and progress system.
- **Milestone 1 (0.2.0+2):** core experience; stable build may use Internal
  Testing.
- **Milestone 2 (0.3.0+3):** evidence and governance; Internal Testing only.
- **Milestone 3 (0.4.0+4):** offline, reminder and widget; Internal Testing.
- **Milestone 4 (0.9.0):** beta only after applicable content gate, no
  placeholders, privacy/store assets and pre-launch testing.
- **Milestone 5 (1.0.0):** production only after all content, reviewer,
  rights, security, privacy, Data Safety, rating, listing, signing, access,
  and quality gates pass.

Content capacity gates are 30 approved items for a pilot, at least 90 for
closed beta, and at least 120 for production unless the owner records a written
exception. Until then production is `BLOCKED_BY_CONTENT_APPROVAL`.
