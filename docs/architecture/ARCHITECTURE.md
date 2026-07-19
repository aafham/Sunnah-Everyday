# Architecture

## Current monorepo layout

```text
apps/
  mobile/          Android-first Flutter public application
  admin/           Flutter web admin shell
packages/
  design_system/   Shared Material 3 tokens, themes and small primitives
supabase/          Planned migrations, functions and SQL tests
content/           Planned templates, staging and approved-data boundaries
```

`apps/mobile` is currently an Android Flutter project with application ID
`com.aafha.sunnaheveryday`. It uses Riverpod for app-level state and go_router
for the four public destinations: Hari Ini, Teroka, Simpanan and Tetapan.
Current screens intentionally show only safe no-content states until an
approved bundle exists.

`apps/admin` is a responsive Flutter web shell with route boundaries for a
dashboard, drafts, reviews, sources and reports. It does not authenticate,
query, fabricate or publish data yet; Supabase auth/RLS and content workflow are
separate pending tasks.

`packages/design_system` owns colour tokens, Material 3 light/dark themes and
accessible shared primitives. It contains no licensed imagery/fonts, religious
text or content data.

## Planned trust boundary

The public app will read immutable, approved public bundles only. Supabase
PostgreSQL, RLS, migrations and server-side publication gates will be the
authoritative content boundary. Flutter UI is never the sole enforcement point.
Admin-only auth and reviewer records are isolated from the public client;
private reflections/bookmarks remain local on the public device.

## Dependency direction

```text
mobile/admin UI → design_system + future domain/data packages
future data package → Drift local cache + approved public bundle contract
Supabase migrations/functions → authoritative workflow, rights and RLS gates
```

The direction prevents UI code from bypassing database validation and keeps
religious-content review data out of the public app until published safely.
