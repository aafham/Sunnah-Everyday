# Progress

_Last updated: 2026-07-19 (PDX-01 complete; MOB-01 selected next)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 3.0% | `DONE task weight / 100` |
| Completed weight | 3 / 100 | PDX-01 is complete |
| Remaining weight | 97 / 100 | Includes blocked work |
| Blocked weight | 4 / 100 | CNT-06 and REL-04 |
| Tasks completed | 1 / 38 | Ledger task count |
| Tasks remaining | 37 / 38 | Unfinished tasks |
| Tasks blocked | 2 / 38 | Owner inputs/access required |
| Software completion | 0.0% | No production code or migration exists yet |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 — Repository and Governance |
| Target version | 0.1.0+1 |
| Current task | MOB-01 — initialise Flutter workspace and application/admin shells |
| Branch | `codex/sunnah-everyday-build` |
| Last recorded task commit | `c1b089b` (`docs: establish governance and release controls`) |
| Local checks before bootstrap | `dart format` passed with no Dart files; `flutter analyze` passed with no project; `flutter test` failed because `test/` does not exist |
| GitHub CI | No workflow configured; GitHub API reports 0 runs for this branch |
| GitHub push / PR | `c1b089b` pushed successfully; PR creation blocked because GitHub CLI is unauthenticated |
| Google Play | No app, signed AAB, Console/API credential, track check, or upload |
| Release status | No build generated, uploaded, or submitted |

## Production blockers

1. No approved religious-content dataset, named qualified reviewers, review evidence, or source-rights clearance.
2. No application, migrations, tests, signed AAB, store assets, public privacy URL, support email, or release validation.
3. No verified Google Play Console/API access, signing key, tester list, or production-access evidence.
4. Git push works, but no authenticated GitHub CLI/API session is available to
   create/update a PR or inspect protected repository settings.

The branch push was verified after the first task, but authenticated GitHub API
access is still required to create/update a pull request and inspect protected
repository settings. See `docs/handoff/GITHUB_HANDOFF.md`.

## Next five tasks

1. MOB-01: initialise Flutter workspace and application/admin shells.
2. BE-01: add initial Supabase schema and migration test foundation.
3. CNT-01: create models, schemas, import templates, and staging boundary.
4. QLT-01: establish test harness and testing utilities.
5. REL-01: establish GitHub quality and release workflows.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
