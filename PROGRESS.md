# Progress

_Last updated: 2026-07-19 (MOB-02 complete with green GitHub Quality CI; BE-01 runtime verification pending; MOB-03 selected)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 20.0% | `DONE task weight / 100` |
| Completed weight | 20 / 100 | PDX-01, MOB-01, MOB-02, CNT-01, CNT-02, QLT-01 and REL-01 are complete |
| Remaining weight | 80 / 100 | Includes blocked work |
| Blocked weight | 4 / 100 | CNT-06 and REL-04 |
| Tasks completed | 7 / 38 | Ledger task count |
| Tasks remaining | 31 / 38 | Unfinished tasks |
| Tasks blocked | 2 / 38 | Owner inputs/access required |
| Software completion | 18.1% | `15 completed implementation weight / 83 implementation weight` |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 closeout / M1 — Core Experience started; BE-01 runtime verification remains in review |
| Target version | `0.1.0+1` development baseline; M1 target remains `0.2.0+2` |
| Current task | MOB-03 — implement fail-closed Today, daily-card and detail surfaces with staging-safe state only; BE-01 Docker-backed migration, lint and pgTAP verification remains pending |
| Branch | `codex/sunnah-everyday-build` |
| Last recorded task commit | `4913b54` (`feat(mobile): add local onboarding preferences`) |
| Local checks | MOB-02: root Dart format passed (42 files, 0 changes); `flutter analyze`/`flutter test` passed for mobile (9 tests); `npm ci --ignore-scripts` reported 0 vulnerabilities; CI policy verifier/tests passed (7); Flutter runner tests passed (3); `npm run check:flutter` passed for all four targets: 1 `testing_utils`, 3 design-system, 9 mobile and 4 admin tests; content-contract tests passed (5); content-validation tests passed (14); Supabase static guard passed; `content_models` analyze/test passed (13); mobile debug APK and admin web smoke builds passed locally. CNT-02 and prior structural checks remain passed. All four migrations also applied in an isolated PostgreSQL/PGlite structural harness. `supabase db reset --local --no-seed` could not start because no Docker engine is available, so local Supabase lint and pgTAP have not run. |
| GitHub CI | Quality run [`29678240092`](https://github.com/aafham/Sunnah-Everyday/actions/runs/29678240092) passed contracts, Flutter quality and debug/web smoke jobs for `4913b54` on 2026-07-19; it has no release/upload/Play path |
| GitHub push / PR | `4913b54` pushed successfully; public API reported no open PR. `gh auth status` has no logged-in host and no authenticated browser session is available, so a PR cannot be created or edited from this environment |
| Google Play | No app, signed AAB, Console/API credential, track check, or upload |
| Release status | No signed release AAB generated, uploaded, or submitted; local debug APK only |

## Production blockers

1. No approved religious-content dataset, named qualified reviewers, review evidence, or source-rights clearance.
2. A structural database baseline, read-only draft validation preview, local Flutter test baseline and read-only GitHub Quality CI exist, but Docker-backed local DB verification, BE-02 admin policies/auth, BE-03 publication gates, CNT-03 public-bundle validation, signed AAB, store assets, public privacy URL, support email, and release validation remain incomplete.
3. No verified Google Play Console/API access, signing key, tester list, or production-access evidence.
4. Git push works, but no authenticated GitHub CLI/API session is available to
   create/update a PR or inspect protected repository settings.

The branch push was verified after the first task, but authenticated GitHub API
access is still required to create/update a pull request and inspect protected
repository settings. See `docs/handoff/GITHUB_HANDOFF.md`.

## Next five tasks

1. MOB-03: add fail-closed Today, daily-card and detail views using staging-safe state only.
2. BE-01: run the local Supabase migration, lint and pgTAP suite once Docker is available.
3. PDX-02: document and verify the design-system/mobile/admin UX specification.
4. PDX-03: extend localisation, RTL and accessibility baseline beyond MOB-02 shell coverage.
5. MOB-05: add local bookmarks, history and private reflections.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
