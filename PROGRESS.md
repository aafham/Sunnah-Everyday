# Progress

_Last updated: 2026-07-19 (CNT-02 complete; BE-01 runtime verification pending; QLT-01 selected)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 13.0% | `DONE task weight / 100` |
| Completed weight | 13 / 100 | PDX-01, MOB-01, CNT-01 and CNT-02 are complete |
| Remaining weight | 87 / 100 | Includes blocked work |
| Blocked weight | 4 / 100 | CNT-06 and REL-04 |
| Tasks completed | 4 / 38 | Ledger task count |
| Tasks remaining | 34 / 38 | Unfinished tasks |
| Tasks blocked | 2 / 38 | Owner inputs/access required |
| Software completion | 12.0% | `10 completed implementation weight / 83 implementation weight` |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 — Repository, shells, structural schema and draft validation |
| Target version | 0.1.0+1 |
| Current task | QLT-01 — establish shared test harness and testing utilities; BE-01 Docker-backed migration, lint and pgTAP verification remains pending |
| Branch | `codex/sunnah-everyday-build` |
| Last recorded task commit | pending feature commit (`feat(content): add draft import validator`) |
| Local checks | CNT-02 CSV validation tests passed (14); content-contract schema/Ajv tests passed (5); Dart format/analyze/tests passed for `content_models`; Supabase static guard and prior Flutter checks remain passed. All four migrations also applied in an isolated PostgreSQL/PGlite structural harness. `supabase db reset --local --no-seed` could not start because no Docker engine is available, so local Supabase lint and pgTAP have not run. |
| GitHub CI | No workflow configured; GitHub API reported 0 runs for this branch after `64ea492` was pushed |
| GitHub push / PR | `64ea492` pushed successfully; public API reported no open PR and creation is blocked because `gh auth status` has no logged-in host and no authenticated browser session is available |
| Google Play | No app, signed AAB, Console/API credential, track check, or upload |
| Release status | No signed release AAB generated, uploaded, or submitted; local debug APK only |

## Production blockers

1. No approved religious-content dataset, named qualified reviewers, review evidence, or source-rights clearance.
2. A structural database baseline and read-only draft validation preview exist, but Docker-backed local DB verification, BE-02 admin policies/auth, BE-03 publication gates, CNT-03 public-bundle validation, signed AAB, store assets, public privacy URL, support email, and release validation remain incomplete.
3. No verified Google Play Console/API access, signing key, tester list, or production-access evidence.
4. Git push works, but no authenticated GitHub CLI/API session is available to
   create/update a PR or inspect protected repository settings.

The branch push was verified after the first task, but authenticated GitHub API
access is still required to create/update a pull request and inspect protected
repository settings. See `docs/handoff/GITHUB_HANDOFF.md`.

## Next five tasks

1. QLT-01: establish shared test harness and testing utilities.
2. BE-01: run the local Supabase migration, lint and pgTAP suite once Docker is available.
3. REL-01: establish GitHub quality and release workflows after QLT-01.
4. MOB-02: add onboarding, local preferences and language selection.
5. MOB-03: add safe Today/detail views after CNT-01, using staging-safe state only.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
