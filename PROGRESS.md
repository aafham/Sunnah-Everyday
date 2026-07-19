# Progress

_Last updated: 2026-07-19 (MOB-05 private-reflection slice complete locally; content-bound remainder moved to dependency-gated MOB-08; BE-01 runtime verification pending)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 29.0% | `DONE task weight / 100` |
| Completed weight | 29 / 100 | PDX-01, PDX-02, PDX-03, MOB-01, MOB-02, MOB-03, MOB-05, CNT-01, CNT-02, QLT-01 and REL-01 are complete |
| Remaining weight | 71 / 100 | Includes blocked work |
| Blocked weight | 4 / 100 | CNT-06 and REL-04 |
| Tasks completed | 11 / 39 | Ledger task count; MOB-05 was split into a completed reflection slice (weight 1) and dependency-gated MOB-08 (weight 2) without changing total weight |
| Tasks remaining | 28 / 39 | Unfinished tasks |
| Tasks blocked | 2 / 38 | Owner inputs/access required |
| Software completion | 24.1% | `20 completed implementation weight / 83 implementation weight` |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 closeout / M1 — Core Experience started; BE-01 runtime verification remains in review |
| Target version | `0.1.0+1` development baseline; M1 target remains `0.2.0+2` |
| Current task | MOB-06 — extend settings coverage for dark mode, scaling and reduced motion. MOB-08 owns content-bound bookmarks, viewed history and practice tracking, and remains dependency-gated by MOB-05/CNT-03/BE-04/DEL-01 rather than using fake content identifiers. BE-01 Docker-backed migration, lint and pgTAP verification remains pending |
| Branch | `codex/sunnah-everyday-build` |
| Last recorded task commit | `3031af2` (`feat(mobile): add generic RTL layout baseline`); MOB-05 reflection-slice commit is pending final local parity and push evidence |
| Local checks | MOB-05 reflection slice: `flutter gen-l10n`, `dart format --set-exit-if-changed lib test`, `flutter analyze` and `flutter test` passed for mobile (39 tests); Android debug APK built successfully. The tests cover bounded reflection persistence/reopen, generic errors, failed-write rollback with retained input, individual and confirmed all-delete, corrupt-envelope recovery deletion, hanging secure-read failure, unsupported-platform failure, UI-preference allowlisting, and Android backup-rule source. Root `npm run check:flutter` also passed analyzers/tests for `testing_utils` (1), design system (6), mobile (39) and admin (5); root format, content-contract (5), content-validation (14), Flutter-runner (3), CI-workflow (7) and static Supabase checks passed. This is not a signed AAB, device security audit or Play Data Safety declaration. Docker-backed Supabase migration/lint/pgTAP have not run because no Docker engine is available. |
| GitHub CI | Quality run [`29680455827`](https://github.com/aafham/Sunnah-Everyday/actions/runs/29680455827) passed contracts, Flutter quality and debug/web smoke jobs for `3031af2` on 2026-07-19; it has no release/upload/Play path |
| GitHub push / PR | `3031af2` pushed successfully; public GitHub API query reported 0 open PRs for the branch. `gh auth status` has no logged-in host and no authenticated browser session is available, so a PR cannot be created or edited from this environment |
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

1. MOB-06: extend settings coverage for dark mode, scaling and reduced motion.
2. MOB-07: add friendly error states and deep-link routing coverage.
3. MOB-08: implement content-bound bookmarks, viewed history and practice tracking only after the verified immutable public-bundle reference contract exists.
4. PDX-04: complete public privacy/support site only after owner support-email and hosting inputs are available.
5. BE-01: run the local Supabase migration, lint and pgTAP suite once Docker is available.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
