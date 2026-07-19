# GitHub Pull Request Handoff

## Verified state

- Repository: `aafham/Sunnah-Everyday`
- Branch: `codex/sunnah-everyday-build`
- Pushed governance commit: `c1b089bf197431638d06edf3c7693f357b32da31`
- Pushed application-shell commit: `ae1cde4201686db56f072df4fd31aead04389a17`
- Pushed schema-baseline commit: `3680dc15f325ccb4f98c0f51997ae1c5d93e2ee5`
- Pushed content-contract commit: `64ea49206bdbc87ebe3cdc796ca354872735de0f`
- Pushed content-validation commit: `e0aeb6f4a3836492e18217fb35a9e6e3487bb4b7`
- Push: successful through configured git credentials on 2026-07-19.
- GitHub CLI/API authentication: unavailable (`gh auth status` has no logged-in
  account), so no pull request has been created or updated. No browser session
  was available as an authenticated fallback.
- CI: no workflow exists; GitHub's public API reported zero workflow runs and
  zero open PRs for the branch after the content-validation push.

## Owner action

Authenticate the GitHub CLI using an account with repository write/PR access:

```powershell
gh auth login
```

Then create the PR without changing history:

```powershell
gh pr create --repo aafham/Sunnah-Everyday --base main --head codex/sunnah-everyday-build --title "feat: establish Sunnah Everyday foundations"
```

Suggested PR body:

- Establishes governance, content/release policies and the weighted task ledger.
- Adds Android Flutter and responsive web-admin shells, a shared Material 3
  design system, safe no-content states and local display controls.
- Adds a no-seed, fail-closed Supabase structural baseline with forced RLS,
  revoked client table access, migration constraints and pgTAP test coverage.
- Adds a draft-only content intake contract with header-only templates, JSON
  Schemas, pure-Dart models, guarded empty boundaries and no content data.
- Adds a read-only RFC 4180 CSV validation preview with schema, duplicate,
  reference, rights, date and translation checks; no source/reviewer/evidence
  data was imported, and the import executable refuses all writes pending
  BE-03 server workflow gates.
- Validation: format, analyzer and tests passed for all Flutter packages;
  content Dart/schema tests, schema static guard and isolated PostgreSQL
  structural execution passed.
  Docker-backed local Supabase reset, lint and pgTAP remain pending because the
  Docker engine is unavailable; release AAB correctly fails closed.
- Release impact: no signed AAB, Play upload or public religious content;
  production remains blocked by content review, source rights and release access.

After authentication, inspect branch protection and CI on the actual branch.
Do not force-push or merge around checks.
