# Progress

_Last updated: 2026-07-19 (BE-02 admin identity/RLS verified in isolated CI; BE-03 is next)_

## Weighted status

| Measure | Value | Calculation / meaning |
| --- | ---: | --- |
| Overall completion | 45.0% | `DONE task weight / 100` |
| Completed weight | 45 / 100 | PDX-01, PDX-02, PDX-03, MOB-01, MOB-02, MOB-03, MOB-05, MOB-06, MOB-07, CNT-01, CNT-02, BE-01, BE-02, QLT-01, QLT-02, QLT-04 and REL-01 are complete |
| Remaining weight | 55 / 100 | Includes blocked work |
| Blocked weight | 7 / 100 | CNT-06, PDX-04 and REL-04 |
| Tasks completed | 17 / 39 | Ledger task count; MOB-05 was split into a completed reflection slice (weight 1) and dependency-gated MOB-08 (weight 2) without changing total weight |
| Tasks remaining | 22 / 39 | Unfinished tasks |
| Tasks blocked | 3 / 39 | Owner inputs/access required |
| Software completion | 43.4% | `36 completed implementation weight / 83 implementation weight` |
| Approved religious content readiness | 0 / 120 | No approved dataset or reviewer evidence supplied |
| Production readiness | 0.0% | Production gates are not met |

## Delivery state

| Field | Status |
| --- | --- |
| Current milestone | M0 closeout / M1 — Core Experience started; BE-02 is complete and BE-03 is next |
| Target version | `0.1.0+1` development baseline; M1 target remains `0.2.0+2` |
| Current task | BE-03: implement review workflow, immutable versions and the server-side publication gate with SQL tests. PDX-04 still needs owner support/hosting inputs; deployment to a Supabase project remains separately blocked on authorised project access. MOB-04, MOB-08 and later delivery work remain dependency-gated. MOB-08 still owns content-bound bookmarks, viewed history and practice tracking rather than using fake content identifiers |
| Branch | `main` contains the prior promoted delivery history through `69273cb`; BE-02 is pushed on `codex/be02-admin-identity-rls` at `4df2dfa` and is not recorded as integrated into `main` |
| Last recorded task commit | `4df2dfa` (`feat(backend): add admin identity RLS`); local parity, branch push and remote Quality run are verified |
| Local checks | BE-02: root formatting passed (57 files, 0 changed); CI-workflow policy tests (16), mobile-security (6), quality-audit (8), Flutter-runner (3), content-contract (5), content-validation (14) and the static Supabase guard passed. `npm run check:flutter` passed analysis plus testing_utils (1), design system (7), mobile (55) and admin (5) tests; content-model analysis/tests (13) also passed. The developer workstation still has no Docker engine, so no local-workstation database-runtime result is claimed. |
| GitHub CI | Quality run [`29692641214`](https://github.com/aafham/Sunnah-Everyday/actions/runs/29692641214) passed contracts, Flutter quality and debug/web smoke for `4df2dfa` on 2026-07-19. Contracts applied all five migrations to an isolated runner-local PostgreSQL database, reset without seed files, linted `public`, ran two pgTAP files / 197 tests and cleaned up; it has no release/upload/Play path |
| GitHub push / PR | `codex/be02-admin-identity-rls` was pushed successfully at `4df2dfa`. `gh auth status` has no logged-in host, so the required CLI-authenticated PR workflow and protected repository settings are not available from this environment |
| Google Play | No Console/API credential or track/app/upload state has been observed from this environment; this delivery generated no signed AAB and did not attempt an upload |
| Release status | No signed release AAB was generated, uploaded or submitted by this delivery; local debug APK only, and Console release state is not verified |

## Production blockers

1. No approved religious-content dataset, named qualified reviewers, review evidence, or source-rights clearance.
2. A structural database baseline, isolated GitHub-runner Docker runtime verification, narrowly scoped BE-02 admin identity/RLS, read-only draft validation preview, local Flutter test baseline and read-only GitHub Quality CI exist, but BE-03 publication gates, CNT-03 public-bundle validation, signed AAB, store assets, public privacy URL, support email, and release validation remain incomplete.
3. No verified Google Play Console/API access, signing key, tester list, or production-access evidence.
4. Git push works, but no authenticated GitHub CLI session is available to
   inspect protected repository settings.

The prior main-branch fast-forward was verified. A scoped, authenticated GitHub
session is still required to inspect protected repository settings.
See `docs/handoff/GITHUB_HANDOFF.md`.

## Next five tasks

1. BE-03: implement review workflow, immutable versions and the publication gate.
2. BE-05: implement audit trail and server-side functions after the ordered backend work.
3. ADM-01: implement authenticated, role-aware Flutter admin navigation after the publication-gate work.
4. PDX-04: complete the public privacy/support site after the owner supplies support-email and hosting inputs.
5. CNT-03: implement public-bundle validation only after BE-03.

## Update protocol

After each atomic task, update the task status/commit field in `TASKS.md`,
recalculate the table above from the task weights, record the actual branch,
commit, CI, and Play state, and list only real blockers.
