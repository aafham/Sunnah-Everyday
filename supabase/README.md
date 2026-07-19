# Supabase database boundary

This directory contains versioned PostgreSQL migrations for the admin-only
Supabase backend. It contains no project URL, API key, service-role key,
source text, permission document, reviewer identity, religious content, or seed
data.

## BE-01 baseline

The baseline creates the 27 required operational tables, the needed
`sunnah_item_tags` junction table, policy-defined enum values, timestamps,
foreign keys, indexes and structural constraints. It also prevents a source
from pointing at another source's permission and a content item from pointing
at another item's version.

Every application table has RLS enabled and forced, with explicit revokes for
`PUBLIC`, `anon` and `authenticated` and zero policies. There is no public view
or public bundle API. This is intentional: it fails closed until the following tasks add
their audited controls.

- BE-02: admin auth/profile provisioning, role checks and least-privilege RLS.
- BE-03: workflow transitions, approval separation, immutable published
  versions, rights checks and Daily Feed grade gate.
- BE-04: validated public-bundle contract, sync and withdrawal propagation.
- BE-05: append-only/redacted audit automation and server-side functions.

Bookmarks and private reflections deliberately have no backend tables; they
remain local to the public device.

## Validation

The no-dependency static guard may run without a database:

```powershell
node scripts/verify_supabase_baseline.mjs
```

Runtime migration, RLS and pgTAP validation requires Docker and only the local
Supabase PostgreSQL database. CI runs the same isolated sequence on an
ephemeral runner; the developer workstation still has no Docker engine. It
must only target the local database—not a linked or production project—unless
the owner separately provides authorised non-production access.

```powershell
npx --yes supabase@2.109.1 db start --yes
npx --yes supabase@2.109.1 db reset --local --no-seed
npx --yes supabase@2.109.1 db lint --local --schema public --level warning --fail-on warning
npx --yes supabase@2.109.1 test db --local supabase/tests
npx --yes supabase@2.109.1 stop --yes --no-backup
```

Do not use `--linked`, `--db-url`, `db push`, or a remote connection without
explicit owner authority and a safe credential path. A static pass is not a
claim that the migrations have executed against PostgreSQL. CI cleanup must run
even after a failed validation step.
