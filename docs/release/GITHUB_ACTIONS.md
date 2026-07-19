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
| `contracts` | CI policy, current-source mobile-security and quality-audit policies, runner, content-contract/content-validation and structural Supabase checks | Ephemeral Docker-backed local PostgreSQL runtime for migration reset/lint/pgTAP; no linked/remote Supabase project or deployment |
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
npm run test:mobile-security
npm run test:quality-audit
npm run test:flutter-runner
npm run test:content-contract
npm run test:content-validation
node scripts/verify_supabase_baseline.mjs
npx --yes supabase@2.109.1 db start --yes
npx --yes supabase@2.109.1 db reset --local --no-seed
npx --yes supabase@2.109.1 db lint --local --schema public --level warning --fail-on warning
npx --yes supabase@2.109.1 test db --local supabase/tests
npx --yes supabase@2.109.1 stop --yes --no-backup
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
required commands, secret references and release/Play/upload operations. It
also requires the exact local-only Supabase PostgreSQL start/reset/lint/pgTAP
sequence once and in order, telemetry disabled, failure-safe cleanup, and no
`--linked`, `--db-url`, `supabase link` or `db push` path. Its unit tests mutate
the real workflow source to exercise those fail-closed checks. Docker is
required for the local runtime commands; cleanup must still run after a failure.

The mobile-security command is a separate read-only current-source regression
guard. It checks the Android main source manifest, debug/profile tooling
permission allowlist, release-signing fail-closed configuration, direct mobile
network/telemetry patterns and tracked credential-shaped files without printing
values. It does not prove a signed artifact, resolved transitive dependency
audit, runtime traffic posture, Play Data Safety response or release readiness.

`npm run test:quality-audit` is the complementary QLT-04 read-only source-audit
guard. It inventories six tracked direct dependency manifests, scans five
audited Dart `lib/` roots for direct networking APIs, and requires no declared
Flutter assets/fonts, empty content boundaries and a 512 KiB maximum for each
candidate bundled binary. It reports policy codes, paths and dependency names
only. It does not resolve transitive dependencies, perform CVE or license
analysis, observe traffic or SDK behaviour, inspect a signed artifact, measure
startup/frame/memory performance or dynamic downloads, or complete privacy,
Data Safety, content or release gates. See
[the QLT-04 source-audit baseline](QUALITY_AUDIT_BASELINE.md).

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

- Latest verified commit: `4df2dfa1252b230f2a4b5170bca2b4b816c6e8ff`
- Quality run: [29692641214](https://github.com/aafham/Sunnah-Everyday/actions/runs/29692641214)
- Result: all three jobs passed on 2026-07-19: contracts, Flutter quality, and
  debug/web smoke checks. Contracts ran isolated local PostgreSQL `db start`,
  applied five migrations, reset without seed files, warning-fatal lint, two
  pgTAP files / 197 tests and failure-safe cleanup; it used no remote project,
  credential, content or release path.
- The GitHub runner emitted Node 20 deprecation warnings while forcing the
  pinned actions to Node 24; no workflow job failed.
- The contracts result includes the current-source mobile-security and QLT-04
  quality-audit guards. They are not Android-device, signed-release,
  transitive-dependency, performance, privacy-form or Data Safety audits.
- Prior mobile quality regression commit:
  `2daac26c30d84db6d3ba177d01c1322fa4a38a4e` with successful Quality run
  [29684226127](https://github.com/aafham/Sunnah-Everyday/actions/runs/29684226127).
- Prior safe-deep-link commit:
  `0437704676d4f471cf3e6aa7f27f5f598436a8ff` with successful Quality run
  [29683674702](https://github.com/aafham/Sunnah-Everyday/actions/runs/29683674702).
- Prior display-settings accessibility commit:
  `0f4e79bec87f4c0ed9fd62f3562d3e64d7d1e362` with successful Quality run
  [29682938797](https://github.com/aafham/Sunnah-Everyday/actions/runs/29682938797).
- Prior private-reflection commit: `86f80bafb97348e91417a675c1550fdf89023874`
  with successful Quality run [29682293929](https://github.com/aafham/Sunnah-Everyday/actions/runs/29682293929).
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
