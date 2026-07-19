# Flutter Testing Guide

## Purpose and scope

`QLT-01` establishes the repeatable unit and widget-test baseline for the
Flutter workspaces. `QLT-02` extends that baseline with a bounded Android
device smoke, 150% accessibility regressions and a read-only mobile
source-policy check. These checks do not make a release claim, provision a
CI service, approve religious content or complete a Data Safety/security audit.

## Shared test support

`packages/testing_utils/` is a private, test-only Flutter package. It provides:

- fixed logical viewports and device-pixel ratios;
- a deterministic `MediaQuery`, text scaler, animation and direction wrapper;
- a bounded transition-settling helper for deliberate route and Material UI
  animations;
- automatic reset of the Flutter test view after each viewport test.

The package deliberately does not create an application router, provider
container, fake API, database fixture, or content record. Each application owns
its own setup under `test/support/`:

- `apps/mobile/test/support/mobile_app_harness.dart` creates and disposes an
  isolated Riverpod `ProviderContainer`.
- `apps/admin/test/support/admin_app_harness.dart` pumps the admin router with
  an explicit viewport.

Every Flutter package has `test/flutter_test_config.dart`, which makes hit-test
warnings fatal. A passing test must therefore interact with visible widgets
rather than relying on accidental off-screen taps.

## Commands

Run these commands from the repository root:

```text
npm run test:flutter-runner  # verifies the Node runner itself
npm run test:flutter         # Flutter unit and widget tests in every target
npm run check:flutter        # flutter analyze for every target, then tests
npm run test:mobile-security # shipped-source manifest/network/signing/credential guard
```

The repository root is not a Flutter package. Do not use `flutter test` or
`flutter analyze` from the root; use the commands above, or run Flutter from a
specific target directory when iterating locally.

Before a delivery commit, run formatting, `npm run check:flutter`, and the
separate contract checks that apply to the change:

```text
npm run test:content-contract
npm run test:content-validation
```

## Test-data and release boundaries

Tests may use structural labels and safe UI states, but must not add unapproved
religious text, citations, authenticity labels, people, source URLs, or
production-like content fixtures. Content validation and human review remain
the gates for content import and publication.

## QLT-02 device and accessibility coverage

The Android integration smoke is deliberately local and device-bound. With a
booted Android emulator, run it from `apps/mobile`:

```text
flutter test integration_test/safe_shell_smoke_test.dart -d emulator-5554 -r expanded
```

It clears only `AppPreferencesStorageKey.all` on that test device before and
after the test. It covers the BM first-launch gate, static no-approved-content
state, Explore safe empty state and Settings controls; it never seeds, reads or
writes a content record or private reflection. It is not included in
`npm run check:flutter` or the GitHub Quality workflow.

`apps/mobile/test/accessibility_regression_test.dart` uses a 150% text scaler
to cover localized headings, visible/reachable actions, semantics, focus and
keyboard recovery for Today and the generic safe-link recovery page. The page
is scrollable so its recovery action remains usable at that scale.

`npm run test:mobile-security` is a current-source guard in the read-only
contracts job. It checks release-source Android manifest flags, isolated
debug/profile tooling permissions, release-signing fail-closed configuration,
direct mobile networking/telemetry SDK and URI patterns, plus tracked
credential-shaped files without printing values. It does not inspect resolved
transitive dependencies, runtime traffic, a signed artifact, Play Data Safety
answers or device-wide security posture.

`MOB-07` adds router/manifest widget tests under `apps/mobile/test/` for the
current static custom-scheme boundary. They use opaque structural test tokens
only to prove non-disclosure; they do not create a content fixture, fetch a
bundle or exercise content delivery. Broader screen-reader, performance,
dependency/privacy and release-security audits remain QLT-04 or later work.
