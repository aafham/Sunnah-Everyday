# Release Gates

## Rule of evidence

A release state is recorded only after direct evidence from the local build,
GitHub, Google Play Console, or Play Developer API. Do not infer upload,
review, approval, tester availability, or production availability from a local
command, a stale browser tab, or a workflow definition.

## Atomic-task gate

Before marking any task `DONE`:

1. Run `dart format --set-exit-if-changed .`, `flutter analyze`, and all
   relevant tests; fix failures.
2. Update README, CHANGELOG, PATCH_NOTES, TASKS and PROGRESS; calculate
   completion using `DONE weight / 100`.
3. Commit on the feature branch with a Conventional Commit.
4. Attempt push only with authorised access, record actual result, and update
   the PR if it exists. No force push or history rewrite.

## Milestone quality gate

Before a release-ready milestone:

- CI is green on the actual commit.
- The intended Android App Bundle is built successfully and is signed with an
  approved upload-key process; no key or secret is committed.
- Version code is new, release notes exist in BM and English, checksums and
  build provenance are retained, and relevant Android/device tests pass.
- Dependency, permission, network, privacy, accessibility, security, content,
  and release-readiness audits are current.
- Store assets show no placeholder, fake reviewer/source, personal data,
  unverified claim, debug UI, or broken layout.

The REL-01 GitHub Actions workflow is a read-only quality gate, not a release
pipeline. It may build a debug APK and admin web smoke output on an ephemeral
runner, but cannot sign or upload an AAB, create a release, contact Google Play
or supply release evidence by itself. See [GitHub Actions Quality Workflow](GITHUB_ACTIONS.md).

## Content gate

Public content must be immutable, approved, rights-cleared, traceable, and
reviewed by at least two distinct humans through source/hadith, fiqh/context,
language and final stages. Daily Feed contains only permitted grades. No
staging or placeholder data is bundled. Capacity requirements:

| Intended use | Minimum approved content |
| --- | ---: |
| Development UI | 0; staging-only, not public |
| Content pilot | 30 |
| Closed beta | 90 |
| Production | 120, unless owner records written exception |

Failure of this gate blocks Open Testing and Production. It allows only
Internal Testing, or a genuinely restricted Closed Test when appropriate.

## Track decision

Select the highest *actually eligible* track, in this order:

1. Production — only when production access and every production/content gate
   is proven.
2. Open Testing — only when beta stability and content gates are proven.
3. Closed Testing — only when account eligibility and a real tester cohort are
   confirmed.
4. Internal Testing — development/placeholder/no-approved-content builds.

Never manufacture tester emails, feedback, support information, reviewer
details, content-rating answers, or Data Safety declarations.

## State vocabulary

Use exactly one truthful state: `Build generated`, `Build uploaded`, `Draft
release created`, `Submitted for review`, `In review`, `Approved`, `Available
to testers`, or `Available in production`. A generated AAB is not uploaded.
