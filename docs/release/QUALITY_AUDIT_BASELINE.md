# QLT-04 Source Audit Baseline

_Last verified: 2026-07-19 for commit
[`1aa0c83c7e92743f8b5aa6a0090faae44c5bba0a`](https://github.com/aafham/Sunnah-Everyday/commit/1aa0c83c7e92743f8b5aa6a0090faae44c5bba0a)._

## Status and scope

QLT-04 is complete as a read-only current-source regression baseline. Its
GitHub Quality run [29685451382](https://github.com/aafham/Sunnah-Everyday/actions/runs/29685451382)
passed contracts, Flutter quality and debug/web smoke checks on 2026-07-19.
It adds no religious content, source/reviewer record, publication path, release
credential, signed AAB, upload or Play action.

`npm run test:quality-audit` reads local tracked files only. It inventories
these six direct dependency manifests:

- `package.json`;
- `apps/mobile/pubspec.yaml` and `apps/admin/pubspec.yaml`;
- `packages/content_models/pubspec.yaml`, `packages/design_system/pubspec.yaml`
  and `packages/testing_utils/pubspec.yaml`.

It scans tracked Dart source in five `lib/` roots selected for this audit for
direct static network APIs, and checks that the current baseline has no declared Flutter
assets/fonts, no payload in the deliberately empty content boundaries, and no
candidate bundled binary over 512 KiB. It fails closed for unreviewed direct
dependency manifests or names, named analytics/ads/network/crash SDK patterns,
direct Dart networking APIs, and those structural changes. Findings contain
policy codes, paths and dependency names only; they do not print source values
or credentials.

The reviewed direct manifests passed this check. The audit did not find a
declared direct analytics, advertising, crash-reporting or network SDK from its
policy list, nor direct static networking APIs in the scanned audited roots.
This is a statement about the guard's direct, tracked-source scope only.

## Android source and debug-artifact observations

The Android **main source manifest** has no `<uses-permission>`, disables
backup, and has no package-visibility `<queries>` or `PROCESS_TEXT` declaration.
Debug/profile source manifests intentionally declare `INTERNET` for Flutter
tooling.

The locally built debug APK was separately inspected. It had `INTERNET`, an
app-private dynamic-receiver permission and `android:debuggable="true"`; it had
no `<queries>` or `PROCESS_TEXT` declaration. It is a debug artifact, not a
signed release artifact. Removing `<queries>` is not a claim that every Android
version, SDK or device can never process external text or make a network request.

Named credential-shaped files are now ignored and tested with `git check-ignore`.
That control prevents regressions for the named patterns; it is not a universal
secret-detection system and does not replace review or secret scanning.

## Local evidence

The following results were recorded for the feature commit:

- `dart format --set-exit-if-changed .` passed with 57 files and 0 changes.
- `npm run test:quality-audit` passed 8 tests; `npm run test:mobile-security`
  passed 6; `npm run test:ci-workflow` passed 9; `npm run verify:ci-workflow`,
  `npm run test:flutter-runner`, `npm run test:content-contract`,
  `npm run test:content-validation` and `node scripts/verify_supabase_baseline.mjs`
  passed.
- Mobile `flutter analyze` and all 55 tests passed; `npm run check:flutter`
  passed for testing utilities (1 test), design system (7), mobile (55) and
  admin (5). Content-model analysis and 13 tests passed.
- The Android `emulator-5554` safe-shell integration smoke, debug APK build and
  admin release-web smoke build passed. The integration smoke used no content
  fixture and cleared only allowlisted UI-preference keys on the test device.
- `npm audit --audit-level=high` and `npm audit --omit=dev --audit-level=high`
  reported 0 vulnerabilities for the root Node lockfile scope. Direct Flutter
  dependency availability was checked with `pub outdated --no-dev-dependencies`.
  Neither command is a Dart/Gradle transitive CVE audit.

## Explicit non-claims

This baseline does **not**:

- resolve or audit transitive dependencies, licenses, CVEs, native libraries or
  SDK behaviour;
- observe runtime traffic, dynamic downloads, device-wide behaviour, encryption,
  erasure or third-party collection/sharing;
- inspect a signed release AAB, establish a release manifest, or complete a
  privacy assessment, Play Data Safety form, content gate or release gate;
- measure startup, frame time, memory, battery, APK/AAB/web payload performance
  or accessibility beyond the recorded local tests.

No signed AAB was generated or uploaded by this delivery. No Google Play
Console/API access was available in this environment, and no release,
submission, review or availability was observed.

## Re-audit triggers

Run and extend this audit whenever a direct dependency/manifest, Android
manifest or Gradle configuration, Dart network/storage path, asset/font/content
boundary, build/release configuration, or privacy-related feature changes.
Before any testing-track or production release, perform the separate signed
artifact, transitive dependency, permission, runtime traffic, privacy/Data
Safety, device, performance, content and release-gate audits required by
[Release Gates](RELEASE_GATES.md).
