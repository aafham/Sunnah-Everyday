# Progress

_Last updated: 2026-07-19 (QLT-01 complete; BE-01 runtime verification pending; REL-01 selected)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 15.0% | `DONE task weight / 100` |
| Completed weight | 15 / 100 | PDX-01, MOB-01, CNT-01, CNT-02 and QLT-01 are complete |
| Remaining weight | 85 / 100 | Includes blocked work |
| Blocked weight | 4 / 100 | CNT-06 and REL-04 |
| Tasks completed | 5 / 38 | Ledger task count |
| Tasks remaining | 33 / 38 | Unfinished tasks |
| Tasks blocked | 2 / 38 | Owner inputs/access required |
| Software completion | 14.5% | `12 completed implementation weight / 83 implementation weight` |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 — Repository, shells, structural schema, draft validation and test baseline |
| Target version | 0.1.0+1 |
| Current task | REL-01 — establish GitHub quality and safe release workflows; BE-01 Docker-backed migration, lint and pgTAP verification remains pending |
| Branch | `codex/sunnah-everyday-build` |
| Last recorded task commit | `458232b` (`test(quality): add Flutter test harness`) |
| Local checks | QLT-01: root Dart format passed (37 files, 0 changes); runner unit tests passed (3); `npm run check:flutter` passed for all four targets: analyze plus 1 `testing_utils`, 3 design-system, 4 mobile and 4 admin tests. CNT-02 CSV validation tests passed (14); content-contract schema/Ajv tests passed (5); Dart format/analyze/tests passed for `content_models`; Supabase static guard and prior Flutter checks remain passed. All four migrations also applied in an isolated PostgreSQL/PGlite structural harness. `supabase db reset --local --no-seed` could not start because no Docker engine is available, so local Supabase lint and pgTAP have not run. |
| GitHub CI | No workflow configured; GitHub public API reported 0 workflow runs for this branch after `458232b` was pushed |
| GitHub push / PR | `458232b` pushed successfully; public API reported no open PR. `gh auth status` has no logged-in host and no authenticated browser session is available, so a PR cannot be created or edited from this environment |
| Google Play | No app, signed AAB, Console/API credential, track check, or upload |
| Release status | No signed release AAB generated, uploaded, or submitted; local debug APK only |

## Production blockers

1. No approved religious-content dataset, named qualified reviewers, review evidence, or source-rights clearance.
2. A structural database baseline, read-only draft validation preview and local Flutter test baseline exist, but Docker-backed local DB verification, BE-02 admin policies/auth, BE-03 publication gates, CNT-03 public-bundle validation, GitHub CI/release automation, signed AAB, store assets, public privacy URL, support email, and release validation remain incomplete.
3. No verified Google Play Console/API access, signing key, tester list, or production-access evidence.
4. Git push works, but no authenticated GitHub CLI/API session is available to
   create/update a PR or inspect protected repository settings.

The branch push was verified after the first task, but authenticated GitHub API
access is still required to create/update a pull request and inspect protected
repository settings. See `docs/handoff/GITHUB_HANDOFF.md`.

## Next five tasks

1. REL-01: establish GitHub quality and safe release workflows.
2. BE-01: run the local Supabase migration, lint and pgTAP suite once Docker is available.
3. MOB-02: add onboarding, local preferences and language selection.
4. MOB-03: add safe Today/detail views after CNT-01, using staging-safe state only.
5. PDX-02: document and verify the design-system/mobile/admin UX specification.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
