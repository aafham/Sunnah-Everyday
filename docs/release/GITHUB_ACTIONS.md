# GitHub Actions Quality Workflow

## Scope

`.github/workflows/quality.yml` is the REL-01 read-only quality workflow. It
runs on `push`, `pull_request`, and manual dispatch with only `contents: read`
permission. It uses concurrency cancellation per workflow/ref and has no
`pull_request_target` trigger, secret access, cache restore/save, artifact
upload, release creation, AAB build, signing, Play Console action, or deployment
step.

All third-party actions are pinned to full commit SHAs. Checkout disables
persisted credentials. The workflow has three jobs:

| Job | Purpose | Output boundary |
| --- | --- | --- |
| `contracts` | CI policy, runner, content-contract/content-validation and structural Supabase checks | No database runtime or remote connection |
| `flutter-quality` | Locked dependencies, Dart format, Flutter analysis/tests and content-model checks | No Android release build or publishing |
| `build-smoke` | Android debug APK and admin web build after both quality jobs pass | Ephemeral runner output only; no upload or release artifact |

`build-smoke` intentionally runs `flutter build apk --debug`, not
`flutter build appbundle --release`. Android release signing remains fail-closed
until REL-03. A successful workflow proves only its recorded checks on that
commit; it does not prove a signed build, Google Play upload, review, approval,
or availability.

## Local parity

Run this sequence from the repository root before relying on CI:

```powershell
npm ci --ignore-scripts
npm run verify:ci-workflow
npm run test:ci-workflow
npm run test:flutter-runner
npm run test:content-contract
npm run test:content-validation
node scripts/verify_supabase_baseline.mjs
dart format --set-exit-if-changed .
npm run check:flutter

Push-Location packages/content_models
dart pub get --enforce-lockfile
dart analyze
dart test
Pop-Location

Push-Location packages/testing_utils
flutter pub get --enforce-lockfile
Pop-Location

Push-Location packages/design_system
flutter pub get
Pop-Location

Push-Location apps/mobile
flutter pub get --enforce-lockfile
flutter build apk --debug
Pop-Location

Push-Location apps/admin
flutter pub get --enforce-lockfile
flutter build web --release
Pop-Location
```

The local workflow-policy verifier parses YAML and rejects changed triggers,
workflow or job-level permissions, unreviewed jobs, action pins, non-executable
required commands, secret references and release/Play/upload operations. Its
unit tests also mutate the real workflow source to exercise those fail-closed
checks.

`packages/design_system` is a library package with its lockfile intentionally
ignored by its own `.gitignore`; its dependency resolution therefore does not
use `--enforce-lockfile`. Application and private test-support lockfiles remain
enforced where they are committed.

## Operating rules

After a workflow change is pushed, record the actual GitHub run URL, commit,
job result and timestamp. Do not call a local pass or workflow definition a
remote CI pass. If a run fails, inspect the specific job and amend the branch;
do not weaken the content, signing or release gates to obtain a green run.

REL-03 owns signed AAB and signing readiness. REL-04 owns an actual Google Play
track upload and monitoring. Both need the documented content, security,
privacy, owner-access and release-gate evidence before they can proceed.

## Verified run

- Latest verified commit: `3031af27220f4897abfe305b63a40e2ebd8ed62b`
- Quality run: [29680455827](https://github.com/aafham/Sunnah-Everyday/actions/runs/29680455827)
- Result: all three jobs passed on 2026-07-19: contracts, Flutter quality, and
  debug/web smoke checks.
- Prior responsive-UX commit: `56daf54e3f7bd9c98ed92a5f0c778eba75479e7d`
  with successful Quality run [29679773365](https://github.com/aafham/Sunnah-Everyday/actions/runs/29679773365).
- Prior fail-closed-daily commit: `c8ddbebd1831ffb847ffee876006529574f68b0b`
  with successful Quality run [29678798552](https://github.com/aafham/Sunnah-Everyday/actions/runs/29678798552).
- Prior mobile-onboarding commit: `4913b548d7afccd25b4bf364b60d47ec77df1ad1`
  with successful Quality run [29678240092](https://github.com/aafham/Sunnah-Everyday/actions/runs/29678240092).
- Prior workflow-hardening commit: `766e1fbb4ccb78ded664216a4819c42c0246bdbc`
  with successful Quality run [29677407731](https://github.com/aafham/Sunnah-Everyday/actions/runs/29677407731).

The first workflow run on `4ceff86` failed at design-system dependency
resolution because that library intentionally does not commit a lockfile. The
follow-up `766e1fb` uses normal `flutter pub get` only for that library and was
verified by the successful run above. Neither run generated a release AAB,
upload, Play action or deployment.
