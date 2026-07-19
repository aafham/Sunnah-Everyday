# Google Play Console Runbook

## Access and setup

Use a real authenticated owner/developer account or least-privilege Play
Developer API service account. Do not bypass MFA, invent identity answers, or
store secrets in the repository. If access is unavailable, record the exact
blocker in `PROGRESS.md` and follow
[`docs/release/PLAY_RELEASE_RUNBOOK.md`](../release/PLAY_RELEASE_RUNBOOK.md);
do not claim upload.

Before creating an app, confirm package ID availability in the actual account
and match it to Android configuration. Proposed setup:

| Field | Intended value | Verification required |
| --- | --- | --- |
| App name | Sunnah Everyday | Owner/Console confirmation |
| Type | App | Console selection |
| Default language | Malay if available; English listing too | Console availability |
| Category | Education (subject to current Console choice) | Current policy/Console |
| Pricing | Free | Console selection |
| Ads | No ads | Code/dependency audit |
| App access | No user login required | Actual app behaviour |
| Initial country | Malaysia | Owner decision/Console |

## App content declarations

Complete content rating and Data Safety from actual shipped code, dependencies,
network traffic and user-report handling. Do not guess. State only documented
facts: general religious educational content, no claimed government/news/health/
financial affiliation or features unless implementation changes. Privacy policy
must be publicly reachable and match the build before submission.

## Testing tracks

Inspect Console eligibility immediately before choosing a track. Use real,
opted-in tester lists only. If the account requires a closed test for production
access, record actual start date, tester count, continuous test duration and
real feedback; never fabricate the 14-day requirement or feedback.

| Track | Allowed when |
| --- | --- |
| Internal | Early/staging build, account access confirmed |
| Closed | Eligibility and real restricted testers confirmed; content gate met as applicable |
| Open | Open eligibility plus beta/content gates met |
| Production | All production/content/quality/privacy/access gates pass |

## Upload and status recording

Upload only a signed, validated AAB whose package/version matches the Console.
After every Console action, record the exact track, version code, upload state,
submission/review state, tester/production availability, observed warnings, and
timestamp in project documentation. Never equate a draft with availability.
