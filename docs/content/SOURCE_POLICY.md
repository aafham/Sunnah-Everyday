# Source Policy

## Source record

Every source must have a database/register record with its name, owner or
publisher, source type, URL or bibliography, edition, language, access date,
review date, rights basis, licence, permission status, permission document (if
available), and permitted-use notes.

Supported statuses are:

| Status | Allowed use |
| --- | --- |
| `UNKNOWN` | No public use; investigate first. |
| `REQUESTED` | No public full-text use while pending. |
| `GRANTED` | Use only within written permission scope. |
| `PUBLIC_LICENSE` | Use only under licence conditions and attribution. |
| `LINK_ONLY` | Link to official source; do not reproduce protected text. |
| `RESTRICTED` | No use except explicitly authorised internal review. |
| `EXPIRED` | Remove/withhold until renewed. |
| `REJECTED` | Do not use. |

## Approved display modes

- **Link-only:** App-created approved summary plus direct source link. This does
  not permit copying source text.
- **Licensed-content:** Full or excerpted text only when a source record proves
  permission/licence scope, attribution and storage/display rights.

## Intake and verification

1. Researcher proposes a source record, not a claim of authority.
2. Rights reviewer verifies owner, terms, edition, scope and expiry.
3. A reviewer records which content fields use the source and the exact locator.
4. Publication validation checks status and rights against display mode.
5. Expiry/restriction triggers a review or withdrawal workflow.

## Disallowed sources and actions

Social-media posters, unattributed blogs, copied databases, screenshots, and
unverified aggregators are not publication sources. Do not scrape, bulk copy,
or represent a candidate source as licensed. A link is not a licence to copy.

## Attribution

Attribution follows the applicable licence/permission and must not imply
endorsement. Source records are retained even after a content withdrawal so the
reasoning and rights trail remain auditable.
