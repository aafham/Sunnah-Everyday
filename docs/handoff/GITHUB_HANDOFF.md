# GitHub Pull Request Handoff

## Verified state

- Repository: `aafham/Sunnah-Everyday`
- Branch: `codex/sunnah-everyday-build`
- Pushed governance commit: `c1b089bf197431638d06edf3c7693f357b32da31`
- Pushed application-shell commit: `ae1cde4201686db56f072df4fd31aead04389a17`
- Pushed schema-baseline commit: `3680dc15f325ccb4f98c0f51997ae1c5d93e2ee5`
- Push: successful through configured git credentials on 2026-07-19.
- GitHub CLI/API authentication: unavailable (`gh auth status` has no logged-in
  account), so no pull request has been created or updated. No browser session
  was available as an authenticated fallback.
- CI: no workflow exists; GitHub's public API reported zero workflow runs and
  zero open PRs for the branch after the schema-baseline push.

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
- Validation: format, analyzer and tests passed for all Flutter packages;
  schema static guard and isolated PostgreSQL structural execution passed.
  Docker-backed local Supabase reset, lint and pgTAP remain pending because the
  Docker engine is unavailable; release AAB correctly fails closed.
- Release impact: no signed AAB, Play upload or public religious content;
  production remains blocked by content review, source rights and release access.

After authentication, inspect branch protection and CI on the actual branch.
Do not force-push or merge around checks.
