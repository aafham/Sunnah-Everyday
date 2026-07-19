# GitHub Pull Request Handoff

## Verified state

- Repository: `aafham/Sunnah-Everyday`
- Branch: `codex/sunnah-everyday-build`
- Pushed governance commit: `c1b089bf197431638d06edf3c7693f357b32da31`
- Pushed application-shell commit: `ae1cde4201686db56f072df4fd31aead04389a17`
- Push: successful through configured git credentials on 2026-07-19.
- GitHub CLI/API authentication: unavailable (`gh auth status` has no logged-in
  account), so no pull request has been created or updated. No browser session
  was available as an authenticated fallback.
- CI: no workflow exists; GitHub's public API reported zero workflow runs for
  the branch at verification time. The public API also reported zero open PRs
  for this branch.

## Owner action

Authenticate the GitHub CLI using an account with repository write/PR access:

```powershell
gh auth login
```

Then create the PR without changing history:

```powershell
gh pr create --repo aafham/Sunnah-Everyday --base main --head codex/sunnah-everyday-build --title "feat: establish Flutter application shells"
```

Suggested PR body:

- Establishes governance, content/release policies and the weighted task ledger.
- Adds Android Flutter and responsive web-admin shells, a shared Material 3
  design system, safe no-content states and local display controls.
- Validation: format, analyzer and tests passed for all Flutter packages;
  Android debug APK and web output built; release AAB correctly fails closed.
- Release impact: no signed AAB, Play upload or public religious content;
  production remains blocked by content review, source rights and release access.

After authentication, inspect branch protection and CI on the actual branch.
Do not force-push or merge around checks.
