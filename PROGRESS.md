# Progress

_Last updated: 2026-07-19 (MOB-07 safe deep-link delivery and remote Quality run verified; QLT-02 selected; BE-01 runtime verification pending)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 34.0% | `DONE task weight / 100` |
| Completed weight | 34 / 100 | PDX-01, PDX-02, PDX-03, MOB-01, MOB-02, MOB-03, MOB-05, MOB-06, MOB-07, CNT-01, CNT-02, QLT-01 and REL-01 are complete |
| Remaining weight | 66 / 100 | Includes blocked work |
| Blocked weight | 4 / 100 | CNT-06 and REL-04 |
| Tasks completed | 13 / 39 | Ledger task count; MOB-05 was split into a completed reflection slice (weight 1) and dependency-gated MOB-08 (weight 2) without changing total weight |
| Tasks remaining | 26 / 39 | Unfinished tasks |
| Tasks blocked | 2 / 39 | Owner inputs/access required |
| Software completion | 30.1% | `25 completed implementation weight / 83 implementation weight` |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 closeout / M1 — Core Experience started; BE-01 runtime verification remains in review |
| Target version | `0.1.0+1` development baseline; M1 target remains `0.2.0+2` |
| Current task | QLT-02 — integration, accessibility and security testing. It is selected before the equally P1/unblocked QLT-04 by ledger order, to establish executable regression coverage. MOB-04 remains dependency-blocked by DEL-01; PDX-04 needs owner support/hosting details. MOB-08 owns content-bound bookmarks, viewed history and practice tracking and remains dependency-gated by MOB-05/CNT-03/BE-04/DEL-01 rather than using fake content identifiers. BE-01 Docker-backed migration, lint and pgTAP verification remains pending |
| Branch | `codex/sunnah-everyday-build` |
| Last recorded task commit | `0437704` (`feat(mobile): add safe deep-link routing`); local parity, branch push and remote Quality run are verified |
| Local checks | MOB-07: `flutter gen-l10n`, root `dart format --set-exit-if-changed .` (54 files, 0 changed), `npm run check:flutter` (analyzers plus testing_utils 1, design system 7, mobile 51 and admin 5 tests), Flutter-runner 3, CI-workflow 7, content-contract 5, content-validation 14, static Supabase guard, content-model analysis/tests (13), Android debug APK and admin-web smoke build passed. Router tests cover accepted daily/content/correction URI shapes, malformed/host/path collisions, onboarding precedence, BM/English recovery semantics, opaque-token non-disclosure and Android intent-filter constraints. This is not a signed AAB, device security audit or Play Data Safety declaration. Docker-backed Supabase migration/lint/pgTAP have not run because no Docker engine is available. |
| GitHub CI | Quality run [`29683674702`](https://github.com/aafham/Sunnah-Everyday/actions/runs/29683674702) passed contracts, Flutter quality and debug/web smoke for `0437704` on 2026-07-19. The runner emitted Node 20 deprecation warnings while forcing actions to Node 24; there was no test/build failure, release/upload/Play path |
| GitHub push / PR | `0437704` pushed successfully; public GitHub API query reported 0 open PRs for the branch. `gh auth status` has no logged-in host and no authenticated browser session is available, so a PR cannot be created or edited from this environment |
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

1. QLT-02: add bounded Android integration, accessibility and security regression coverage without content fixtures or release claims.
2. QLT-04: perform the separate dependency, permission, privacy and performance audit.
3. MOB-04: implement Explore/categories/search only after DEL-01 is available.
4. MOB-08: implement content-bound bookmarks, viewed history and practice tracking only after the verified immutable public-bundle reference contract exists.
5. PDX-04: complete public privacy/support site only after owner support-email and hosting inputs are available.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
