# Flutter Testing Guide

## Purpose and scope

`QLT-01` establishes the repeatable unit and widget-test baseline for the
Flutter workspaces. It covers deterministic app and component tests only. It
does not make a release claim, provision a CI service, run integration tests,
or approve religious content.

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

Accessibility expansion, integration coverage, security testing, CI, and
release automation are scheduled in their dedicated quality and release tasks.

`MOB-07` adds router/manifest widget tests under `apps/mobile/test/` for the
current static custom-scheme boundary. They use opaque structural test tokens
only to prove non-disclosure; they do not create a content fixture, fetch a
bundle or exercise content delivery. Android device integration, broader
accessibility and security coverage remain QLT-02 work.
