# Content models

This pure-Dart package defines the draft-only contract shared by future import
and admin tooling. It deliberately has no Flutter, Supabase, network, content
bundle, publication, or scheduling dependency.

The types preserve policy-defined metadata and enforce only safe intake
boundaries: every record carries a `STAGING` envelope; a content candidate also
starts in `DRAFT`; its notice is `KANDUNGAN DEMO — TIDAK UNTUK PENERBITAN`; and
server-managed publication fields are rejected. They do not authenticate a
narration, decide a classification, approve a reviewer, grant rights, or make
any record public.

The JSON/CSV contract is in [../../content/templates/](../../content/templates/).
