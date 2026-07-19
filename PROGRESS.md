# Progress

_Last updated: 2026-07-19 (QLT-04 source-audit delivery and remote Quality run verified; no further ledger task is currently eligible; BE-01 runtime verification pending)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 38.0% | `DONE task weight / 100` |
| Completed weight | 38 / 100 | PDX-01, PDX-02, PDX-03, MOB-01, MOB-02, MOB-03, MOB-05, MOB-06, MOB-07, CNT-01, CNT-02, QLT-01, QLT-02, QLT-04 and REL-01 are complete |
| Remaining weight | 62 / 100 | Includes blocked work |
| Blocked weight | 7 / 100 | CNT-06, PDX-04 and REL-04 |
| Tasks completed | 15 / 39 | Ledger task count; MOB-05 was split into a completed reflection slice (weight 1) and dependency-gated MOB-08 (weight 2) without changing total weight |
| Tasks remaining | 24 / 39 | Unfinished tasks |
| Tasks blocked | 3 / 39 | Owner inputs/access required |
| Software completion | 34.9% | `29 completed implementation weight / 83 implementation weight` |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 closeout / M1 — Core Experience started; BE-01 runtime verification remains in review |
| Target version | `0.1.0+1` development baseline; M1 target remains `0.2.0+2` |
| Current task | No unblocked ledger task is currently eligible. QLT-04 is complete as a source-scoped audit baseline. PDX-04 needs owner support/hosting details; BE-01 needs Docker-backed migration, lint and pgTAP verification; MOB-04, MOB-08 and all later slices remain dependency-gated. MOB-08 still owns content-bound bookmarks, viewed history and practice tracking rather than using fake content identifiers |
| Branch | `codex/sunnah-everyday-build` |
| Last recorded task commit | `1aa0c83` (`test(quality): add source audit baseline`); local parity, branch push and remote Quality run are verified |
| Local checks | QLT-04: root formatting passed (57 files, 0 changed); `npm run test:quality-audit` (8), mobile-security (6), CI-workflow (9), Flutter-runner (3), content-contract (5), content-validation (14) and the static Supabase guard passed. Mobile `flutter analyze` and 55 tests, `npm run check:flutter` (testing_utils 1, design system 7, mobile 55 and admin 5), content-model analysis/tests (13), Android debug APK and admin-web smoke builds passed. `emulator-5554` passed the safe-shell integration smoke. The root Node dependency audit reported 0 high vulnerabilities, and direct Flutter dependency availability was checked; neither result is a Dart/Gradle CVE audit. The main source manifest and debug APK were inspected as recorded in [the QLT-04 baseline](docs/release/QUALITY_AUDIT_BASELINE.md). No signed AAB, performance benchmark or Play Data Safety declaration exists. Docker-backed Supabase migration/lint/pgTAP have not run because no Docker engine is available. |
| GitHub CI | Quality run [`29685451382`](https://github.com/aafham/Sunnah-Everyday/actions/runs/29685451382) passed contracts, Flutter quality and debug/web smoke for `1aa0c83` on 2026-07-19. The contracts job includes the source-scoped quality audit and mobile-security policy guard; it has no release/upload/Play path |
| GitHub push / PR | `1aa0c83` pushed successfully; public GitHub API query reported 0 open PRs for the branch. `gh auth status` has no logged-in host and no authenticated browser session is available, so a PR cannot be created or edited from this environment |
| Google Play | No Console/API credential or track/app/upload state has been observed from this environment; this delivery generated no signed AAB and did not attempt an upload |
| Release status | No signed release AAB was generated, uploaded or submitted by this delivery; local debug APK only, and Console release state is not verified |

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

1. PDX-04: complete the public privacy/support site after the owner supplies support-email and hosting inputs.
2. BE-01: complete Docker-backed Supabase migration, lint and pgTAP verification when a Docker engine is available.
3. MOB-04: implement Explore/categories/search only after DEL-01 is available.
4. MOB-08: implement content-bound bookmarks, viewed history and practice tracking only after the verified immutable public-bundle reference contract exists.
5. CNT-03 / BE-03: begin the public-bundle and server publication gates only after their database prerequisites are complete.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
