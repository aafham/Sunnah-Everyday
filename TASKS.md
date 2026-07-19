# Task Ledger

Status values: `NOT_STARTED`, `IN_PROGRESS`, `BLOCKED`, `IN_REVIEW`, `DONE`,
or `DEFERRED`. Overall completion is the sum of `DONE` weights divided by 100;
blocked work never counts as complete.

| ID | Workstream | Description | Priority | Weight | Status | Dependencies | Acceptance criteria / tests | Commit | Play milestone | Notes |
| --- | --- | --- | ---: | ---: | --- | --- | --- | --- | --- | --- |
| PDX-01 | Product & UX | Governance, task ledger, progress, roadmap, decisions and operating rules | P0 | 3 | DONE | — | Required docs/policies/runbooks exist and are internally consistent | pending commit | M0 | Documentation validation, format and analysis passed |
| PDX-02 | Product & UX | Design system and mobile/admin UX specification | P1 | 2 | NOT_STARTED | PDX-01 | Tokens, components, responsive/a11y requirements documented and tested in UI | — | M0 | |
| PDX-03 | Product & UX | Localisation, RTL and accessibility baseline | P1 | 2 | NOT_STARTED | MOB-01 | BM/EN ARB, semantic/scale/RTL tests | — | M1 | |
| PDX-04 | Product & UX | Public privacy/support site, terms and legal copy | P1 | 3 | NOT_STARTED | PDX-01 | Static pages and hosting handoff; no invented contact details | — | M4 | Owner support email/hosting needed to deploy |
| MOB-01 | Flutter core | Flutter workspace, application architecture, app/admin shell | P0 | 4 | NOT_STARTED | PDX-01 | `flutter analyze`, smoke tests, Android/web build | — | M0 | |
| MOB-02 | Flutter core | Onboarding, local preferences and language selection | P0 | 3 | NOT_STARTED | MOB-01 | Widget tests for persistence/locales | — | M1 | |
| MOB-03 | Flutter core | Today, daily-card and safe detail views | P0 | 4 | NOT_STARTED | MOB-01, CNT-01 | UI/state tests; only staging-safe data | — | M1 | |
| MOB-04 | Flutter core | Explore, categories, situation mode and offline search | P1 | 3 | NOT_STARTED | MOB-03, DEL-01 | BM/EN search and empty-state tests | — | M1 | |
| MOB-05 | Flutter core | Local bookmarks, history and private reflections | P1 | 3 | NOT_STARTED | MOB-01 | Persistence/privacy/deletion tests | — | M1 | |
| MOB-06 | Flutter core | Settings, dark mode, scaling and reduce motion | P1 | 3 | NOT_STARTED | MOB-01 | Theme/a11y widget tests | — | M1 | |
| MOB-07 | Flutter core | Friendly error states and deep-link app routing | P1 | 2 | NOT_STARTED | MOB-01 | Router/error tests | — | M1 | |
| CNT-01 | Content/evidence | Content models, schemas, import templates and staging boundary | P0 | 3 | NOT_STARTED | PDX-01 | Schema/template tests; no claim-bearing demo data | — | M0 | |
| CNT-02 | Content/evidence | Content validation CLI with rights/translation/duplicate checks | P0 | 3 | NOT_STARTED | CNT-01 | Valid/invalid fixture tests | — | M2 | |
| CNT-03 | Content/evidence | Public bundle validation and release gate | P0 | 3 | NOT_STARTED | CNT-02, BE-03 | Prohibited grade/placeholder/rights tests | — | M2 | |
| CNT-04 | Content/evidence | Evidence, source, reviewer and methodology experiences | P1 | 3 | NOT_STARTED | MOB-03, BE-01 | UI/data tests | — | M2 | |
| CNT-05 | Content/evidence | Reports, corrections and withdrawal presentation | P1 | 3 | NOT_STARTED | BE-03, MOB-03 | Report and withdrawal tests | — | M2 | |
| CNT-06 | Content/evidence | Approved-content intake and human-review evidence | P0 | 3 | BLOCKED | Owner reviewers, source rights | 30/90/120 approved capacity only after human records | — | M4/M5 | No AI-generated religious data |
| BE-01 | Backend/database | Initial Supabase schema and migrations | P0 | 4 | NOT_STARTED | PDX-01 | Migration/constraint tests | — | M0 | |
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
| QLT-01 | Quality | Unit/widget test harness and test utilities | P0 | 2 | NOT_STARTED | MOB-01 | `flutter test` baseline | — | M0 | |
| QLT-02 | Quality | Integration, accessibility and security testing | P1 | 2 | NOT_STARTED | QLT-01 | Integration/a11y/secret tests | — | M4 | |
| QLT-03 | Quality | SQL/content-gate tests and coverage reporting | P0 | 2 | NOT_STARTED | CNT-02, BE-03 | Gate/RLS test scripts | — | M2 | |
| QLT-04 | Quality | Dependency, permission, privacy and performance audit | P1 | 2 | NOT_STARTED | MOB-01 | Audits documented and clean | — | M4 | |
| REL-01 | Docs & release | GitHub CI/CD and safe release automation | P0 | 2 | NOT_STARTED | MOB-01, QLT-01 | Workflow syntax, local parity docs | — | M0 | |
| REL-02 | Docs & release | Store assets, metadata, release notes and privacy site | P1 | 2 | NOT_STARTED | PDX-04 | Asset/metadata validation | — | M4 | |
| REL-03 | Docs & release | Play readiness, signing and release handoff | P1 | 2 | NOT_STARTED | REL-01, REL-02 | Readiness checklist and signed build proof | — | M4 | Credentials required to upload |
| REL-04 | Docs & release | Actual Play track upload and monitoring | P0 | 1 | BLOCKED | REL-03, owner Play access, content gate | Verified Console/API result only | — | M0–M5 | Never assume account access |

**Total weight:** 100. **Completed weight:** 3. **Blocked weight:** 4.

## Selection rule

The highest-priority unblocked tasks are `MOB-01`, `CNT-01`, `BE-01`, `QLT-01`,
and `REL-01`. `MOB-01` is selected next because the app shell unblocks the
test harness and CI implementation; keep the ledger current.
