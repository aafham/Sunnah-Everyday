# Correction and Withdrawal Policy

## Intake

Concerns may arrive through user reports, reviewer discovery, source-rights
changes, or quality checks. Reports are triaged with a minimal-data approach
and are not proof by themselves.

## Correction workflow

1. Record a correction case and audit event.
2. Mark the item under review and suspend it from daily scheduling if risk
   warrants.
3. Clone the published version; never edit it in place.
4. Record reason, proposed diff and required re-reviews.
5. Run relevant source/hadith, fiqh/context, language and final approvals.
6. Publish the new immutable version only after the normal gate passes.
7. Publish an approved user-facing correction note when material.
8. Refresh public bundles, offline cache and widgets.

## Withdrawal workflow

Rights expiry, serious uncertainty, or an approved withdrawal decision removes
the item from public bundle, schedule, cache and widget availability immediately.
Bookmarks must show a safe withdrawal state rather than stale content. Audit
and source records remain; public wording is reviewed and does not expose
private reviewer/report details.

## Service expectations

No admin UI action may bypass the workflow. Every state transition, actor,
reason, affected version and timestamp is auditable. Tests must cover active
daily withdrawal, offline last-known-good handling, widget refresh, correction
history, and report linkage.
