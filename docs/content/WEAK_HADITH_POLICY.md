# Weak Hadith Policy

## Daily content

Weak, very weak, fabricated, disputed, and ungraded narrations are prohibited
from Daily Feed. This is a hard database/server validation rule, not a UI
convention.

## Model support

The data model preserves grades `DAIF`, `VERY_WEAK`, `FABRICATED`, `DISPUTED`,
and `UNGRADED` to support accurate records, review, future academic treatment,
and prevention controls. Their presence in the model does not make them
eligible public daily content.

## Future academic material

Any future explanatory material about weak narrations needs a separate approved
scope, clear label, human review, sources/rights, and language that neither
promotes a practice nor conceals uncertainty. It remains out of the Daily Feed
and cannot be scheduled by a publisher workaround.

## Enforcement and tests

Content validation and SQL tests must prove that a prohibited grade cannot be
added to a Daily Feed schedule or public bundle. A failed grade check blocks the
release pipeline and records an actionable validation error without exposing
private review notes.
