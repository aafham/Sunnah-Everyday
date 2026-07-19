# Android and Play Release Runbook

## Preconditions

- Read [Release Gates](RELEASE_GATES.md) and all `docs/content/` policies.
- Confirm intended package ID (`com.aafha.sunnaheveryday`) against the actual
  Android configuration and Play app. Do not change it after app creation.
- Confirm release version/versionCode have not been uploaded before.
- Confirm authorised GitHub and Play access without printing credentials.
- Confirm signing process uses secure key storage/Play App Signing and no key is
  present in the repository.

## Local validation

Run, retaining concise results:

```powershell
dart format --set-exit-if-changed .
npm run test:mobile-security
npm run test:quality-audit
npm run check:flutter

Push-Location apps/mobile
flutter build appbundle --release
Pop-Location
```

Run any project-specific integration/content/Supabase/security/permission
checks as they are added. Do not treat a failed or skipped check as passed. The
root is not a Flutter package, so run Flutter analysis/tests through
`npm run check:flutter` or from the relevant package directory.
Inspect the generated AAB path, application ID, version code, and checksum.

## Release preparation

1. Confirm changelog/patch notes include factual user-facing BM and English
   release notes, content status, known issues, GitHub status and Play status.
2. Confirm screenshots and graphics depict only approved production-eligible
   content; development screenshots cannot enter a public listing.
3. Perform the content, privacy, dependency, permission, Data Safety, rating,
   source-rights and reviewer audit appropriate for the chosen track.
4. Push the exact commit and verify CI. If push/CI access is unavailable, stop
   before upload and update the handoff/status honestly.

## Upload

Use an authenticated Play Console session or least-privilege Developer API.
Do not bypass 2FA or save credentials in source control.

1. Choose the track from `RELEASE_GATES.md` based on observed eligibility.
2. Create an edit/release and upload the signed AAB.
3. Attach BM and English release notes.
4. Save/commit the release only after checking displayed version code, track,
   rollout, country/audience and warning state.
5. Capture the actual resulting state in PROGRESS, CHANGELOG/PATCH_NOTES and
   the release record. Submission/review is a separate explicit Console action.

## Failure and rollback

If validation, content gate, Play warning, signing, or upload fails, do not
retry by weakening a gate. Preserve a safe internal build where appropriate,
record the exact non-secret blocker, remediate through a new commit, and use
the Console's documented rollback/halt controls only with observed release
context. Withdrawn content must be removed from bundles/widgets before any
replacement release.
