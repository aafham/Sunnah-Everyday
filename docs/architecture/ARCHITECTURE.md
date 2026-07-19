# Architecture

## Current monorepo layout

```text
apps/
  mobile/          Android-first Flutter public application
  admin/           Flutter web admin shell
packages/
  design_system/   Shared Material 3 tokens, themes and small primitives
  content_models/  Pure-Dart draft-only content intake contract
  testing_utils/   Private deterministic Flutter unit/widget-test support
supabase/          Config, four structural baseline migrations and SQL tests
content/           Header-only templates, JSON Schemas and guarded intake boundaries
.github/workflows/ Read-only GitHub Quality CI
```

`apps/mobile` is currently an Android Flutter project with application ID
`com.aafha.sunnaheveryday`. It uses Riverpod for app-level state and go_router
for the four public destinations: Hari Ini, Teroka, Simpanan and Tetapan.
Current screens intentionally show only safe no-content states until an
approved bundle exists. The only current personal-data feature is a bounded
Android-only free-text reflection envelope; it has no content reference,
network, analytics, admin or export path. Browser and unsupported platforms
fail closed.

The Android activity accepts only `sunnah://daily`, `sunnah://content` and
`sunnah://correction` custom-scheme hosts. Before normal path matching or the
onboarding gate, the mobile router treats every external authority as untrusted
and reduces it to a static fail-closed detail or generic recovery route. No
external identifier becomes a route parameter, is rendered, stored, logged or
used for a content lookup. HTTPS App Links, public-bundle lookups and
content-bound deep-link delivery remain deferred to their verified domain,
bundle and withdrawal contracts.

`apps/admin` is a responsive Flutter web shell with route boundaries for a
dashboard, drafts, reviews, sources and reports. It does not authenticate,
query, fabricate or publish data yet. The structural Supabase baseline is
present, but BE-02 auth/RLS policies and BE-03 content workflow remain pending.

`packages/design_system` owns colour tokens, Material 3 light/dark themes and
accessible shared primitives. It contains no licensed imagery/fonts, religious
text or content data.

`packages/testing_utils` is a private test-only Flutter package. It provides
repeatable logical viewports, media preferences and a bounded transition helper
without creating routers, providers, API fakes or content fixtures. Mobile and
admin test harnesses keep their application-specific setup local. The root
Flutter runner executes each package in its own working directory because the
monorepo root is not itself a Flutter package.

`.github/workflows/quality.yml` enforces the repository's local quality parity
on GitHub using read-only permissions. Its contracts job includes a
current-source mobile policy guard for manifest, direct network/signing and
tracked credential regression patterns; it runs Flutter quality and debug/web
smoke jobs but cannot access secrets, publish artifacts, create a release, sign
an AAB or contact Google Play. The guard is not a runtime or release audit.

`packages/content_models` and `content/` define draft-only metadata shapes for
future import tooling. `scripts/validate_content.mjs` consumes a caller-supplied
five-file CSV batch with exact headers, schema mapping and relational checks;
it is read-only, makes no network/database request and produces only safe
row/path codes. `scripts/import_content.mjs` validates then refuses all writes
until BE-03 exists. These areas contain no source/reviewer/content record, do
not ship as Flutter assets, and cannot schedule, approve, publish or make a
bundle.

## Planned trust boundary

The public app will ultimately read immutable, approved public bundles only.
At BE-01, every application table has forced RLS, no `PUBLIC`/`anon`/
`authenticated` table grants and no policy, so no client can read or write the
baseline. BE-02 through BE-05 must add audited admin access, publication and
bundle controls; Flutter UI is never the sole enforcement point. The current
private reflection envelope remains local on the public Android device.
Content-bound bookmarks, viewed history and practice tracking cannot exist
until a verified immutable bundle/reference contract supports them; the shell
does not manufacture IDs in the meantime.

CNT-01/CNT-02 form an additional non-runtime boundary: they accept only
`STAGING` input, start content candidates in `DRAFT`, reject
publication-shaped fields, require the non-publication marker, and validate
schema, duplicate, reference, rights and locale consistency before any future
server handoff. CNT-02 never creates data and always reports that publication
eligibility is not evaluated. BE-03 must still enforce the workflow on the
server.

## Dependency direction

```text
mobile/admin UI → design_system + content_models + future domain/data packages
mobile/admin tests → testing_utils + local application harnesses
current private reflection slice → bounded Android secure-storage envelope only
future data package → Drift local cache + approved public bundle contract
Supabase baseline migrations → future workflow, rights, RLS and publication gates
```

The direction prevents UI code from bypassing database validation and keeps
religious-content review data out of the public app until published safely.
