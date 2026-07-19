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
permissions, action pins, required commands, secret references and release/
Play/upload operations. Its unit tests also mutate the real workflow source to
exercise those fail-closed checks.

## Operating rules

After a workflow change is pushed, record the actual GitHub run URL, commit,
job result and timestamp. Do not call a local pass or workflow definition a
remote CI pass. If a run fails, inspect the specific job and amend the branch;
do not weaken the content, signing or release gates to obtain a green run.

REL-03 owns signed AAB and signing readiness. REL-04 owns an actual Google Play
track upload and monitoring. Both need the documented content, security,
privacy, owner-access and release-gate evidence before they can proceed.
