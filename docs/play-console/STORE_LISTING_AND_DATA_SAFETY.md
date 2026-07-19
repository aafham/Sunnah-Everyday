# Store Listing and Data Safety Preparation

## Listing guardrails

Use only features implemented in the submitted build. Do not use screenshots or
claims involving placeholder content, fictitious reviewers/sources, personal
data, debug screens, or unapproved religious content. Do not invent a support
email, support URL or privacy URL; leave them as owner-action blockers until
real values are supplied and deployed.

## Intended Malay listing

**Title:** Sunnah Everyday

**Short description:** Satu sunnah setiap hari dengan cara amalan, dalil dan
sumber yang jelas.

Long copy must be reviewed against the actual feature set and content gate at
release time. It may state the application's educational purpose, evidence,
source, privacy and correction principles only when those features are shipped.

## Intended English listing

**Title:** Sunnah Everyday

**Short description:** One daily Sunnah with practical steps, evidence, and
clear sources.

Long copy must likewise be validated against shipped features before use. Never
promise verified content, reviewers, offline access, widgets, or reports before
the corresponding implementation and gate are complete.

## Data Safety evidence checklist

Before completing the form, audit the release build for:

- Android manifest permissions and SDK-transitive permissions.
- Network destinations and public content/report endpoints.
- Data from optional report follow-up fields, retention and sharing.
- Local-only bookmarks/reflections and whether they ever leave the device.
- Auth/admin-only data excluded from the public-user app.
- Analytics, crash reporting, advertising identifiers and third-party SDKs.
- Encryption, deletion, account/access behaviour, and policy consistency.

The declaration must reflect audit evidence, not the intended architecture. Any
change in collection/sharing requires a fresh audit and policy update.

## Current implementation evidence, not a declaration

The current Android build contains a bounded local private-reflection slice:
at most 50 free-text notes of 500 characters, stored through an isolated
Android secure-storage adapter. The app UI offers individual deletion and a
confirmed deletion of every stored reflection; unreadable data may only be
cleared through the same scoped key. It does not expose reflection text to an
admin, a network endpoint, analytics, or an export feature. Browser and
unsupported platforms fail closed.

The Android main source manifest currently has no `<uses-permission>`, disables
backup with legacy and Android 12+ XML exclusion rules, and has no `<queries>`
or `PROCESS_TEXT` declaration. Debug/profile source manifests intentionally
declare `INTERNET` for Flutter tooling. The locally inspected debug APK also
contains `INTERNET`, an app-private dynamic-receiver permission and
`android:debuggable="true"`; it is not release evidence. These observations do
not establish secure erasure, universal OEM transfer behaviour, third-party SDK
behaviour, encryption, runtime traffic, a release manifest or a completed Play
Data Safety form. A release-time manifest, dependency, traffic and device audit
is still mandatory.
