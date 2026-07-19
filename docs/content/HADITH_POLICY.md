# Hadith Policy

## Boundaries

The product does not independently authenticate hadith, choose a grade, alter
quoted text, or treat a report as a recommendation without qualified human
review. Only a named qualified reviewer or recorded authoritative assessment
may populate a narration grade.

## Required evidence fields

Each evidence record stores evidence type, permitted Arabic/display text,
translation status, narrator, collection, book/chapter, reference number,
grade, grader/institution, source ID and locator, source URL where suitable,
verification date, verification note, and rights status.

## Daily Feed rule

Daily Feed accepts only `SAHIH` or `HASAN`. The following are blocked at
database/server publication validation: `DAIF`, `VERY_WEAK`, `FABRICATED`,
`DISPUTED`, and `UNGRADED`. `NOT_APPLICABLE` is not sufficient for an item
whose daily claim depends on a narration.

## Review process

1. Researcher records the source and exact locator without asserting a grade.
2. Hadith reviewer records a decision, source basis, date and identity.
3. Fiqh/context review separately considers what (if anything) can be
   recommended and under what conditions.
4. Language review checks that UI copy does not exaggerate or omit limits.
5. Final approval validates complete, distinct human approvals.

## Display rules

Show the grade and assessor with a traceable source when a grade is presented.
Use cautious, approved language for uncertainty/disagreement. Never show a
long Arabic text as an image or reproduce text without source rights.
