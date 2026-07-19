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
