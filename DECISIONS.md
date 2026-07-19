# Architecture and Delivery Decisions

| ID | Decision | Status | Rationale | Consequence |
| --- | --- | --- | --- | --- |
| ADR-001 | Android-first Flutter monorepo | Accepted | The owner specified Flutter Android-first while preserving iOS portability | Mobile and admin share Dart packages; Android widget remains native Kotlin |
| ADR-002 | Public user has no mandatory account | Accepted | Privacy-first MVP and lower friction | Bookmarks/reflections remain local; Supabase Auth is for admins only |
| ADR-003 | Religious content is data, never generated UI copy | Accepted | Prevents invented/unsourced claims | Only approved bundles are public; demo content is explicitly non-publication |
| ADR-004 | Database/server publication gate is authoritative | Accepted | Flutter UI cannot be the only protection | SQL/RLS/functions must enforce approvals, rights, grades and immutable versions |
| ADR-005 | Daily Feed permits only SAHIH/HASAN evidence | Accepted | Required content safety rule | Validation rejects other grade values even if the model supports them |
| ADR-006 | Drift is the offline source of last-known-good data | Accepted | Offline search and daily delivery require relational local state | Bundle application must be transactional/checksummed and support withdrawal |
| ADR-007 | Four-tab information architecture | Accepted | Keeps the mobile experience calm and focused | Hari Ini, Teroka, Simpanan and Tetapan only |
| ADR-008 | Kotlin/Jetpack Glance widget bridge | Accepted | Native Android widgets need reliable lifecycle/resize support | Widget data must be safe cached approved content with deep links |
| ADR-009 | No analytics or ad SDK by default | Accepted | Privacy and Play Data Safety accuracy | Any future telemetry needs explicit approval and policy/audit update |
| ADR-010 | Feature branch and truthful release records | Accepted | Repository may be shared; external access is unverified | No direct main commit, force push, assumed push, or assumed Play state |
| ADR-011 | Public repo visibility is unchanged | Accepted | Remote is already public and owner did not request a change | Do not place sensitive content or credentials in the repository |
| ADR-012 | BE-01 begins with a deny-by-default database baseline | Accepted | No public/admin data path may exist before role, rights and publication controls are audited | All application tables force RLS and revoke table access from `PUBLIC`, `anon` and `authenticated`; BE-02 must add narrowly scoped policies before any access can work |
| ADR-013 | Content intake starts as a draft-only contract | Accepted | Technical templates must not become a path for AI-generated or unreviewed religious content | Header-only CSV/JSON templates, pure-Dart models and directory controls accept only `STAGING`/`DRAFT` metadata; no candidate can schedule, approve, publish or create a public bundle |
