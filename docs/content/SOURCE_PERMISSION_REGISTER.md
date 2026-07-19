# Source Permission Register

The authoritative register is a controlled database table. This document
defines the minimum columns and the review process; it intentionally contains
no claimed permissions.

| Field | Required | Description |
| --- | --- | --- |
| `source_id` | Yes | Stable source identifier |
| `source_name` / `owner` | Yes | Publisher or rights holder, not a presumed authority |
| `source_type` | Yes | Primary text, assessment, explanation, editorial, etc. |
| `locator` / `url` / `edition` | Yes | Traceable bibliographic or web reference |
| `language` | Yes | Language of the supplied material |
| `permission_status` | Yes | One permitted policy status |
| `rights_basis` / `licence` | Yes | Written grant, public licence, or link-only rationale |
| `scope` | Yes | Exact content, channels, locales, duration and attribution |
| `accessed_at` / `reviewed_at` | Yes | ISO dates |
| `expires_at` | If applicable | Review/expiry trigger |
| `document_reference` | If applicable | Secure internal permission evidence reference |
| `usage_notes` | Yes | Restrictions and attribution wording |
| `reviewed_by` | Yes | Responsible human identity/role |

## Register controls

- Unknown, requested, restricted, expired and rejected records block
  publication unless policy permits a strictly link-only display.
- Permission documents are stored in authorised secure storage, not this public
  repository, and only their safe reference is recorded.
- Review rights at intake, before publication, on expiry, after a source change,
  and at each correction/withdrawal assessment.
