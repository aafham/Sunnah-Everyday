# Sunnah Everyday — Operating Instructions

## Purpose

Sunnah Everyday is an Android-first Flutter application for learning about
approved Sunnah and Prophetic manners. Accuracy, traceability, privacy, and a
calm user experience take precedence over engagement and speed.

## Non-negotiable content safeguards

- Do not invent, paraphrase as quotation, grade, or authenticate religious
  material.
- Do not decide a practice is Sunnah, issue fatwa, or infer a ruling.
- Do not copy or scrape religious texts, translations, or commentary unless
  the source-rights record permits it.
- AI-produced religious-language output is always `DRAFT` or
  `NEEDS_REVIEW`; it is never public content.
- Development-only content must visibly state
  `KANDUNGAN DEMO — TIDAK UNTUK PENERBITAN` and contain no religious claim.
- Never release staging, placeholder, unreviewed, unlicensed, or
  withdrawn content to Open Testing or Production.
- A Daily Feed item needs a permitted narration grade, clear source rights,
  immutable versioning, source/hadith review, fiqh/context review, language
  review, final approval, and at least two distinct human reviewers.

## Delivery rules

1. Read `MASTER_BUILD_SPEC.md`, `TASKS.md`, `PROGRESS.md`, `ROADMAP.md`,
   `DECISIONS.md`, relevant `docs/content/` policies, and release/play-console
   runbooks before changing affected areas.
2. Work on the highest-priority unblocked task. Keep an atomic task focused.
3. Implement working code and real database protections; do not substitute
   pseudocode, mocks presented as production, or UI-only enforcement.
4. For every atomic task, run formatting, analysis, and relevant tests; fix
   failures before marking it done.
5. Update `README.md`, `CHANGELOG.md`, `PATCH_NOTES.md`, `TASKS.md`, and
   `PROGRESS.md`; recalculate completion from task weights.
6. Commit with Conventional Commits on a feature branch. Push and create or
   update a pull request only when access is genuinely available. Record the
   actual result; never claim a push, CI run, PR, upload, review, or release
   that did not occur.
7. Never force-push, rewrite shared history, commit secrets, alter repository
   visibility, or bypass a protection gate.

## Release rules

- Release only stable, signed builds after the documented gates pass.
- Track priority is Production, then Open Testing, Closed Testing, and
  Internal Testing. Content approval failures restrict a build to Internal
  Testing (or a genuinely restricted Closed Test when appropriate).
- Production requires at least 120 approved public items unless the owner has
  recorded a written exception, plus all source, reviewer, privacy, security,
  Play, and quality gates.
- Treat Play states precisely: generated, uploaded, draft release created,
  submitted for review, in review, approved, available to testers, and
  available in production are different states.

## Security and privacy

- Do not commit `.env`, keystores, service-account JSON, Supabase service-role
  keys, tokens, or personally identifiable reflection/report content.
- Public users do not need an account. Bookmarks and reflections stay local;
  reflections are never sent to the backend or shown to admins.
- Log technical failures without private reflections or religious text.

## Current operating state

- Working branch: `codex/sunnah-everyday-build`.
- The repository was bootstrapped from an empty initial commit on 2026-07-19.
- There is no approved religious-content dataset, reviewer roster, source
  clearance, Play credential, signing key, support email, or public privacy
  URL yet. See `PROGRESS.md` for live blockers.
