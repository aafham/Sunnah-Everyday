# GitHub Pull Request Handoff

## Verified state

- Repository: `aafham/Sunnah-Everyday`
- Branch: `codex/sunnah-everyday-build`
- Pushed governance commit: `c1b089bf197431638d06edf3c7693f357b32da31`
- Push: successful through configured git credentials on 2026-07-19.
- GitHub CLI/API authentication: unavailable (`gh auth status` has no logged-in
  account), so no pull request has been created or updated.
- CI: no workflow exists; GitHub's public API reported zero workflow runs for
  the branch at verification time.

## Owner action

Authenticate the GitHub CLI using an account with repository write/PR access:

```powershell
gh auth login
```

Then create the PR without changing history:

```powershell
gh pr create --repo aafham/Sunnah-Everyday --base main --head codex/sunnah-everyday-build --title "docs: establish governance and release controls"
```

Suggested PR body:

- Establishes operating rules, weighted task/progress tracking, roadmap and
  architecture decisions.
- Adds content/source/review/AI/correction policies and release/Play runbooks.
- Validation: governance-document presence check, `dart format
  --set-exit-if-changed .`, and `flutter analyze`.
- Release impact: no app build and no Play upload; production remains blocked
  by approved content, reviewers, source rights, and release access.

After authentication, inspect branch protection and CI on the actual branch.
Do not force-push or merge around checks.
