# Progress

_Last updated: 2026-07-19 (PDX-02 complete with green GitHub Quality CI; BE-01 runtime verification pending; PDX-03 selected)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 26.0% | `DONE task weight / 100` |
| Completed weight | 26 / 100 | PDX-01, PDX-02, MOB-01, MOB-02, MOB-03, CNT-01, CNT-02, QLT-01 and REL-01 are complete |
| Remaining weight | 74 / 100 | Includes blocked work |
| Blocked weight | 4 / 100 | CNT-06 and REL-04 |
| Tasks completed | 9 / 38 | Ledger task count |
| Tasks remaining | 29 / 38 | Unfinished tasks |
| Tasks blocked | 2 / 38 | Owner inputs/access required |
| Software completion | 22.9% | `19 completed implementation weight / 83 implementation weight` |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 closeout / M1 — Core Experience started; BE-01 runtime verification remains in review |
| Target version | `0.1.0+1` development baseline; M1 target remains `0.2.0+2` |
| Current task | PDX-03 — establish the BM/English, generic RTL-layout and accessibility baseline without adding Arabic text/data/fonts; BE-01 Docker-backed migration, lint and pgTAP verification remains pending |
| Branch | `codex/sunnah-everyday-build` |
| Last recorded task commit | `56daf54` (`feat(design): codify responsive UX contract`) |
| Local checks | PDX-02: `dart format --set-exit-if-changed lib test` passed with zero changes for design system (7 files), mobile (21) and admin (8); `flutter analyze` and `flutter test` passed for each target (6 design-system, 16 mobile and 5 admin tests); `npm run test:flutter-runner` passed (3); `npm run check:flutter` passed all four targets (1 `testing_utils`, 6 design-system, 16 mobile and 5 admin tests); mobile debug APK and admin web builds passed. No release AAB was built. CNT-02 and prior structural checks remain passed. All four migrations also applied in an isolated PostgreSQL/PGlite structural harness. `supabase db reset --local --no-seed` could not start because no Docker engine is available, so local Supabase lint and pgTAP have not run. |
| GitHub CI | Quality run [`29679773365`](https://github.com/aafham/Sunnah-Everyday/actions/runs/29679773365) passed contracts, Flutter quality and debug/web smoke jobs for `56daf54` on 2026-07-19; it has no release/upload/Play path |
| GitHub push / PR | `56daf54` pushed successfully; public GitHub query reported 0 open PRs for the branch. `gh auth status` has no logged-in host and no authenticated browser session is available, so a PR cannot be created or edited from this environment |
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

1. PDX-03: establish the BM/English, generic RTL-layout and accessibility baseline.
2. MOB-05: add local bookmarks, history and private reflections.
3. MOB-06: extend settings coverage for dark mode, scaling and reduced motion.
4. MOB-07: add friendly error states and deep-link routing coverage.
5. BE-01: run the local Supabase migration, lint and pgTAP suite once Docker is available.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
