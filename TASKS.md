# Task Ledger

Status values: `NOT_STARTED`, `IN_PROGRESS`, `BLOCKED`, `IN_REVIEW`, `DONE`,
or `DEFERRED`. Overall completion is the sum of `DONE` weights divided by 100;
blocked work never counts as complete.

| ID | Workstream | Description | Priority | Weight | Status | Dependencies | Acceptance criteria / tests | Commit | Play milestone | Notes |
| --- | --- | --- | ---: | ---: | --- | --- | --- | --- | --- | --- |
| PDX-01 | Product & UX | Governance, task ledger, progress, roadmap, decisions and operating rules | P0 | 3 | DONE | — | Required docs/policies/runbooks exist and are internally consistent | `c1b089b` | M0 | Documentation validation, format and analysis passed; branch push verified |
| PDX-02 | Product & UX | Design system and mobile/admin UX specification | P1 | 2 | NOT_STARTED | PDX-01 | Tokens, components, responsive/a11y requirements documented and tested in UI | — | M0 | |
| PDX-03 | Product & UX | Localisation, RTL and accessibility baseline | P1 | 2 | NOT_STARTED | MOB-01 | BM/EN ARB, semantic/scale/RTL tests | — | M1 | |
| PDX-04 | Product & UX | Public privacy/support site, terms and legal copy | P1 | 3 | NOT_STARTED | PDX-01 | Static pages and hosting handoff; no invented contact details | — | M4 | Owner support email/hosting needed to deploy |
| MOB-01 | Flutter core | Flutter workspace, application architecture, app/admin shell | P0 | 4 | DONE | PDX-01 | `flutter analyze`, shell tests, Android debug and web build | `ae1cde4` | M0 | Material 3 mobile/admin shells, shared design system, safe empty states and fail-closed release guard implemented |
| MOB-02 | Flutter core | Onboarding, local preferences and language selection | P0 | 3 | NOT_STARTED | MOB-01 | Widget tests for persistence/locales | — | M1 | |
| MOB-03 | Flutter core | Today, daily-card and safe detail views | P0 | 4 | NOT_STARTED | MOB-01, CNT-01 | UI/state tests; only staging-safe data | — | M1 | |
| MOB-04 | Flutter core | Explore, categories, situation mode and offline search | P1 | 3 | NOT_STARTED | MOB-03, DEL-01 | BM/EN search and empty-state tests | — | M1 | |
| MOB-05 | Flutter core | Local bookmarks, history and private reflections | P1 | 3 | NOT_STARTED | MOB-01 | Persistence/privacy/deletion tests | — | M1 | |
| MOB-06 | Flutter core | Settings, dark mode, scaling and reduce motion | P1 | 3 | NOT_STARTED | MOB-01 | Theme/a11y widget tests | — | M1 | |
| MOB-07 | Flutter core | Friendly error states and deep-link app routing | P1 | 2 | NOT_STARTED | MOB-01 | Router/error tests | — | M1 | |
| CNT-01 | Content/evidence | Content models, schemas, import templates and staging boundary | P0 | 3 | DONE | PDX-01 | Dart model tests plus JSON Schema/Ajv template-contract tests pass; no claim-bearing demo data | `64ea492` | M0 | Header-only templates, empty guarded staging/approved boundaries, and no imported records |
| CNT-02 | Content/evidence | Content validation CLI with rights/translation/duplicate checks | P0 | 3 | DONE | CNT-01 | Valid/invalid fixture tests | `e0aeb6f` | M2 | Read-only RFC 4180 CSV preview validates schemas, trim-aware metadata/locales, duplicate/reference/link/rights/date consistency and safe reports; no DB/network/write/import/approval/publication path |
| CNT-03 | Content/evidence | Public bundle validation and release gate | P0 | 3 | NOT_STARTED | CNT-02, BE-03 | Prohibited grade/placeholder/rights tests | — | M2 | |
| CNT-04 | Content/evidence | Evidence, source, reviewer and methodology experiences | P1 | 3 | NOT_STARTED | MOB-03, BE-01 | UI/data tests | — | M2 | |
| CNT-05 | Content/evidence | Reports, corrections and withdrawal presentation | P1 | 3 | NOT_STARTED | BE-03, MOB-03 | Report and withdrawal tests | — | M2 | |
| CNT-06 | Content/evidence | Approved-content intake and human-review evidence | P0 | 3 | BLOCKED | Owner reviewers, source rights | 30/90/120 approved capacity only after human records | — | M4/M5 | No AI-generated religious data |
| BE-01 | Backend/database | Initial Supabase schema and migrations | P0 | 4 | IN_REVIEW | PDX-01 | Static guard and isolated PostgreSQL structural execution passed; Docker-backed Supabase migration/lint/pgTAP remains pending | `3680dc1` | M0 | 27 required tables plus a junction table; no roles, reviewers, sources, permissions or religious content seeded |
| BE-02 | Backend/database | Admin auth, roles and RLS | P0 | 3 | NOT_STARTED | BE-01 | SQL RLS tests | — | M2 | Supabase project required to deploy |
| BE-03 | Backend/database | Review workflow, immutable versions and publication gate | P0 | 3 | NOT_STARTED | BE-01 | SQL publication/approval tests | — | M2 | |
| BE-04 | Backend/database | Public bundles, scheduling and sync contract | P1 | 3 | NOT_STARTED | BE-03 | Bundle/checksum/scheduling tests | — | M3 | |
| BE-05 | Backend/database | Audit trail and server-side functions | P1 | 2 | NOT_STARTED | BE-01 | Audit/function tests | — | M2 | |
| ADM-01 | Admin CMS | Flutter web admin shell and authenticated navigation | P0 | 3 | NOT_STARTED | MOB-01, BE-02 | Role-aware router tests | — | M2 | |
| ADM-02 | Admin CMS | Structured source/content editor and import preview | P0 | 3 | NOT_STARTED | ADM-01, CNT-01 | Editor validation tests | — | M2 | |
| ADM-03 | Admin CMS | Review queues, approvals, diff and role gates | P0 | 3 | NOT_STARTED | ADM-02, BE-03 | Workflow/permission tests | — | M2 | |
| ADM-04 | Admin CMS | Scheduling, corrections, withdrawals and reports | P1 | 3 | NOT_STARTED | ADM-03, CNT-05 | Admin action tests | — | M2 | |
| DEL-01 | Delivery | Drift offline cache, indexed search and sync transaction | P0 | 2 | NOT_STARTED | MOB-01, BE-04 | Offline/corrupt/withdrawal tests | — | M3 | |
| DEL-02 | Delivery | Local reminder, timezone and reboot behaviour | P1 | 2 | NOT_STARTED | MOB-01, DEL-01 | Scheduler/timezone tests | — | M3 | |
| DEL-03 | Delivery | Native Android Glance widget with bridge | P0 | 3 | NOT_STARTED | DEL-01 | Widget/resizing/theme/deep-link tests | — | M3 | |
| DEL-04 | Delivery | Background refresh and secure deep-link delivery | P1 | 1 | NOT_STARTED | DEL-01, DEL-03 | Worker/deep-link tests | — | M3 | |
| QLT-01 | Quality | Unit/widget test harness and test utilities | P0 | 2 | DONE | MOB-01 | Deterministic four-target `flutter analyze`/`flutter test` baseline | `458232b` | M0 | Private shared viewport/media/transition harness, app-local setup, fatal hit-test warnings and a root runner; no integration, content or release scope added |
| QLT-02 | Quality | Integration, accessibility and security testing | P1 | 2 | NOT_STARTED | QLT-01 | Integration/a11y/secret tests | — | M4 | |
| QLT-03 | Quality | SQL/content-gate tests and coverage reporting | P0 | 2 | NOT_STARTED | CNT-02, BE-03 | Gate/RLS test scripts | — | M2 | |
| QLT-04 | Quality | Dependency, permission, privacy and performance audit | P1 | 2 | NOT_STARTED | MOB-01 | Audits documented and clean | — | M4 | |
| REL-01 | Docs & release | GitHub CI/CD and safe release automation | P0 | 2 | NOT_STARTED | MOB-01, QLT-01 | Workflow syntax, local parity docs | — | M0 | |
| REL-02 | Docs & release | Store assets, metadata, release notes and privacy site | P1 | 2 | NOT_STARTED | PDX-04 | Asset/metadata validation | — | M4 | |
| REL-03 | Docs & release | Play readiness, signing and release handoff | P1 | 2 | NOT_STARTED | REL-01, REL-02 | Readiness checklist and signed build proof | — | M4 | Credentials required to upload |
| REL-04 | Docs & release | Actual Play track upload and monitoring | P0 | 1 | BLOCKED | REL-03, owner Play access, content gate | Verified Console/API result only | — | M0–M5 | Never assume account access |

**Total weight:** 100. **Completed weight:** 15. **Blocked weight:** 4.

## Selection rule

`BE-01` is implemented and in review: its local Supabase runtime validation is
pending a Docker engine. `CNT-02` is complete as a read-only draft validation
preview; it does not import or publish any content. `QLT-01` is complete.
`REL-01` is selected next as the available P0 M0 task now that its test-harness
dependency has passed. Do not mark BE-01 complete or count its weight until the
documented local migration, lint and pgTAP checks have actually passed.
