-- BE-03: version-scoped review workflow and server-side publication gates.
--
-- This migration creates no people, reviewer, source, permission, content or
-- public-bundle records. It keeps all operational tables closed to direct
-- client access and exposes only narrow, authenticated workflow RPCs.

create type public.content_provenance_status as enum (
  'DRAFT',
  'NEEDS_REVIEW',
  'HUMAN_REVIEWED',
  'DEMO'
);

alter table public.sunnah_versions
  add column workflow_status public.content_workflow_status not null
    default 'DRAFT'::public.content_workflow_status,
  add column provenance_status public.content_provenance_status not null
    default 'DRAFT'::public.content_provenance_status,
  add column human_reviewed_by uuid references public.admin_profiles (id)
    on delete restrict,
  add column human_reviewed_at timestamptz,
  add column publication_snapshot jsonb,
  add column publication_checksum text,
  add column publication_sealed_at timestamptz,
  add column publication_sealed_by uuid references public.admin_profiles (id)
    on delete restrict,
  add constraint sunnah_versions_human_reviewed_provenance_check
    check (
      (
        provenance_status = 'HUMAN_REVIEWED'
        and human_reviewed_by is not null
        and human_reviewed_at is not null
      )
      or (
        provenance_status <> 'HUMAN_REVIEWED'
        and human_reviewed_by is null
        and human_reviewed_at is null
      )
    ),
  add constraint sunnah_versions_publication_checksum_check
    check (
      publication_checksum is null
      or publication_checksum ~ '^[a-f0-9]{64}$'
    ),
  add constraint sunnah_versions_publication_seal_check
    check (
      (
        publication_snapshot is null
        and publication_checksum is null
        and publication_sealed_at is null
        and publication_sealed_by is null
      )
      or (
        publication_snapshot is not null
        and publication_checksum is not null
        and publication_sealed_at is not null
        and publication_sealed_by is not null
      )
    );

alter table public.evidence_records
  add column source_permission_id uuid,
  add column display_mode public.source_display_mode not null default 'LINK_ONLY';

alter table public.evidence_records
  add constraint evidence_records_permission_belongs_to_source_fkey
  foreign key (source_permission_id, source_id)
  references public.source_permissions (id, source_id)
  deferrable initially deferred;

alter table public.content_reviews
  drop constraint if exists content_reviews_decision_check,
  add column reviewed_locale text,
  add column reviewed_checksum text,
  add constraint content_reviews_decision_check
    check (decision in ('APPROVED', 'REJECTED')),
  add constraint content_reviews_reviewed_checksum_check
    check (
      reviewed_checksum is null
      or reviewed_checksum ~ '^[a-f0-9]{64}$'
    ),
  add constraint content_reviews_reviewed_locale_fkey
  foreign key (reviewed_locale)
  references public.supported_locales (code)
  on delete restrict;

alter table public.content_approvals
  drop constraint if exists content_approvals_version_id_reviewer_id_approval_type_key,
  drop constraint if exists content_approvals_decision_check,
  add column approved_checksum text,
  add column supersedes_approval_id uuid references public.content_approvals (id)
    on delete restrict,
  add constraint content_approvals_decision_check
    check (decision in ('APPROVED', 'REJECTED')),
  add constraint content_approvals_type_check
    check (approval_type = 'FINAL_PUBLICATION'),
  add constraint content_approvals_approved_checksum_check
    check (
      approved_checksum is null
      or approved_checksum ~ '^[a-f0-9]{64}$'
    );

create table public.version_sources (
  version_id uuid not null references public.sunnah_versions (id) on delete restrict,
  source_id uuid not null references public.sources (id) on delete restrict,
  source_permission_id uuid not null,
  usage_scope text not null check (
    usage_scope in ('PRIMARY_CONTENT', 'EVIDENCE', 'CONTEXT', 'TRANSLATION')
  ),
  display_mode public.source_display_mode not null,
  created_at timestamptz not null default now(),
  primary key (version_id, source_id, usage_scope),
  unique (version_id, source_permission_id, usage_scope),
  foreign key (source_permission_id, source_id)
    references public.source_permissions (id, source_id)
    deferrable initially deferred
);

create table public.version_locale_states (
  version_id uuid not null references public.sunnah_versions (id) on delete restrict,
  locale text not null references public.supported_locales (code) on delete restrict,
  is_available boolean not null,
  unavailable_rationale text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (version_id, locale),
  check (
    (is_available and unavailable_rationale is null)
    or (
      not is_available
      and unavailable_rationale is not null
      and char_length(btrim(unavailable_rationale)) > 0
    )
  )
);

create table public.content_workflow_events (
  id uuid primary key default gen_random_uuid(),
  version_id uuid not null references public.sunnah_versions (id) on delete restrict,
  actor_id uuid not null references public.admin_profiles (id) on delete restrict,
  event_type text not null check (char_length(btrim(event_type)) > 0),
  from_status public.content_workflow_status,
  to_status public.content_workflow_status,
  reason text,
  input_checksum text check (
    input_checksum is null or input_checksum ~ '^[a-f0-9]{64}$'
  ),
  created_at timestamptz not null default now()
);

alter table public.daily_schedule
  add constraint daily_schedule_status_check
  check (schedule_status in ('SCHEDULED', 'PUBLISHED', 'SUSPENDED', 'WITHDRAWN'));

create index sunnah_versions_workflow_status_idx
  on public.sunnah_versions (workflow_status);
create index sunnah_versions_provenance_status_idx
  on public.sunnah_versions (provenance_status);
create index evidence_records_source_permission_id_idx
  on public.evidence_records (source_permission_id);
create index version_sources_source_id_idx on public.version_sources (source_id);
create index version_sources_permission_id_idx
  on public.version_sources (source_permission_id);
create index version_locale_states_locale_idx on public.version_locale_states (locale);
create index content_reviews_version_scope_locale_idx
  on public.content_reviews (version_id, review_scope, reviewed_locale, reviewed_at desc);
create index content_approvals_version_type_idx
  on public.content_approvals (version_id, approval_type, approved_at desc);
create index content_workflow_events_version_created_at_idx
  on public.content_workflow_events (version_id, created_at desc);

create trigger version_locale_states_set_updated_at
before update on public.version_locale_states
for each row execute function public.set_updated_at();

alter table public.version_sources enable row level security;
alter table public.version_sources force row level security;
alter table public.version_locale_states enable row level security;
alter table public.version_locale_states force row level security;
alter table public.content_workflow_events enable row level security;
alter table public.content_workflow_events force row level security;

revoke all on table public.version_sources, public.version_locale_states,
  public.content_workflow_events from public, anon, authenticated;

-- A SECURITY DEFINER function must not assume where pgcrypto was installed.
-- Local Supabase normally exposes it under extensions, while a plain PostgreSQL
-- installation may have it in public. The selected schema/name comes from the
-- system catalogue and is still invoked with an empty search path.
create or replace function private.sha256_hex(p_payload text)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  digest_schema text;
  digest_name text;
  checksum text;
begin
  select namespace_row.nspname, procedure_row.proname
  into digest_schema, digest_name
  from pg_catalog.pg_proc as procedure_row
  join pg_catalog.pg_namespace as namespace_row
    on namespace_row.oid = procedure_row.pronamespace
  where procedure_row.oid = coalesce(
    pg_catalog.to_regprocedure('extensions.digest(bytea,text)'),
    pg_catalog.to_regprocedure('public.digest(bytea,text)'),
    pg_catalog.to_regprocedure('pg_catalog.digest(bytea,text)')
  );

  if digest_schema is null then
    raise exception using
      errcode = 'P0001',
      message = 'Publication checksum support is unavailable.';
  end if;

  execute pg_catalog.format(
    'select pg_catalog.encode(%I.%I(pg_catalog.convert_to($1, ''UTF8''), ''sha256''), ''hex'')',
    digest_schema,
    digest_name
  )
  into checksum
  using p_payload;

  return checksum;
end;
$$;

create or replace function private.assert_active_admin_role(
  p_role public.admin_role_code,
  p_action text
)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null
    or not private.has_active_admin_role(p_role) then
    raise exception using
      errcode = '42501',
      message = 'The current account is not permitted to perform this workflow action.';
  end if;
end;
$$;

create or replace function private.required_role_for_review_scope(
  p_scope public.review_scope
)
returns public.admin_role_code
language sql
immutable
security definer
set search_path = ''
as $$
  select case $1
    when 'SOURCE_HADITH'::public.review_scope then 'HADITH_REVIEWER'::public.admin_role_code
    when 'FIQH_CONTEXT'::public.review_scope then 'FIQH_REVIEWER'::public.admin_role_code
    when 'LANGUAGE'::public.review_scope then 'LANGUAGE_EDITOR'::public.admin_role_code
  end;
$$;

create or replace function private.is_eligible_reviewer(
  p_reviewer_id uuid,
  p_required_role public.admin_role_code,
  p_scope public.review_scope,
  p_locale text
)
returns boolean
language sql
stable
security definer
set search_path = ''
set timezone = 'UTC'
as $$
  select exists (
    select 1
    from public.reviewers as reviewer_row
    join public.admin_profiles as profile_row
      on profile_row.id = reviewer_row.admin_profile_id
    join public.admin_role_assignments as assignment_row
      on assignment_row.admin_profile_id = profile_row.id
      and assignment_row.role_code = $2
      and assignment_row.revoked_at is null
    where reviewer_row.id = $1
      and reviewer_row.is_active
      and reviewer_row.verified_at is not null
      and profile_row.is_active
      and exists (
        select 1
        from public.reviewer_qualifications as qualification_row
        where qualification_row.reviewer_id = reviewer_row.id
          and (
            qualification_row.valid_from is null
            or qualification_row.valid_from <= (now() at time zone 'UTC')::date
          )
          and (
            qualification_row.expires_at is null
            or qualification_row.expires_at >= (now() at time zone 'UTC')::date
          )
      )
      and (
        $3 is null
        or exists (
          select 1
          from public.reviewer_scopes as scope_row
          where scope_row.reviewer_id = reviewer_row.id
            and scope_row.review_scope = $3
            and scope_row.is_active
            and (
              (
                $3 = 'LANGUAGE'::public.review_scope
                and scope_row.locale_code = $4
              )
              or (
                $3 <> 'LANGUAGE'::public.review_scope
                and scope_row.locale_code is null
              )
            )
        )
      )
  );
$$;

create or replace function private.current_reviewer_for_scope(
  p_scope public.review_scope,
  p_locale text
)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  current_reviewer_id uuid;
  required_role public.admin_role_code;
begin
  if (
    p_scope = 'LANGUAGE'::public.review_scope
    and (p_locale is null or p_locale not in ('ms', 'en'))
  ) or (
    p_scope <> 'LANGUAGE'::public.review_scope
    and p_locale is not null
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'The review locale is not valid for this review scope.';
  end if;

  required_role := private.required_role_for_review_scope(p_scope);
  perform private.assert_active_admin_role(required_role, 'record a review');

  select reviewer_row.id
  into current_reviewer_id
  from public.reviewers as reviewer_row
  where reviewer_row.admin_profile_id = (select auth.uid())
    and private.is_eligible_reviewer(
      reviewer_row.id,
      required_role,
      p_scope,
      p_locale
    );

  if current_reviewer_id is null then
    raise exception using
      errcode = '42501',
      message = 'The current account has no active qualified reviewer scope.';
  end if;

  return current_reviewer_id;
end;
$$;

create or replace function private.current_final_approver()
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  reviewer_id uuid;
begin
  perform private.assert_active_admin_role('PUBLISHER'::public.admin_role_code, 'record final approval');

  select reviewer_row.id
  into reviewer_id
  from public.reviewers as reviewer_row
  where reviewer_row.admin_profile_id = (select auth.uid())
    and private.is_eligible_reviewer(
      reviewer_row.id,
      'PUBLISHER'::public.admin_role_code,
      null,
      null
    );

  if reviewer_id is null then
    raise exception using
      errcode = '42501',
      message = 'The current publisher has no active qualified reviewer record.';
  end if;

  return reviewer_id;
end;
$$;

create or replace function private.version_input_snapshot(p_version_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
set timezone = 'UTC'
as $$
  select jsonb_build_object(
    'schema_version', 'BE03-1',
    'item', jsonb_build_object(
      'id', item_row.id,
      'slug', item_row.slug,
      'created_by', item_row.created_by,
      'category_id', item_row.category_id,
      'category', (
        select jsonb_build_object(
          'id', category_row.id,
          'slug', category_row.slug,
          'title_ms', category_row.title_ms,
          'title_en', category_row.title_en,
          'parent_id', category_row.parent_id,
          'sort_order', category_row.sort_order,
          'is_active', category_row.is_active
        )
        from public.categories as category_row
        where category_row.id = item_row.category_id
      ),
      'content_type', item_row.content_type,
      'classification', item_row.classification::text,
      'prophetic_form', item_row.prophetic_form::text,
      'audience_scope', to_jsonb(item_row.audience_scope),
      'situation_scope', to_jsonb(item_row.situation_scope),
      'difficulty_level', item_row.difficulty_level,
      'frequency_label', item_row.frequency_label,
      'has_scholarly_difference', item_row.has_scholarly_difference,
      'is_prophet_specific', item_row.is_prophet_specific,
      'requires_medical_note', item_row.requires_medical_note
    ),
    'tags', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', tag_row.id,
          'slug', tag_row.slug,
          'title_ms', tag_row.title_ms,
          'title_en', tag_row.title_en,
          'is_active', tag_row.is_active
        )
        order by tag_row.slug, tag_row.id
      )
      from public.sunnah_item_tags as item_tag_row
      join public.tags as tag_row
        on tag_row.id = item_tag_row.tag_id
      where item_tag_row.sunnah_item_id = item_row.id
    ), '[]'::jsonb),
    'version', jsonb_build_object(
      'id', version_row.id,
      'version_number', version_row.version_number,
      'created_by', version_row.created_by,
      'title_ms', version_row.title_ms,
      'title_en', version_row.title_en,
      'summary_ms', version_row.summary_ms,
      'summary_en', version_row.summary_en,
      'practical_steps_ms', version_row.practical_steps_ms,
      'practical_steps_en', version_row.practical_steps_en,
      'when_to_practise_ms', version_row.when_to_practise_ms,
      'when_to_practise_en', version_row.when_to_practise_en,
      'context_note_ms', version_row.context_note_ms,
      'context_note_en', version_row.context_note_en,
      'misunderstanding_note_ms', version_row.misunderstanding_note_ms,
      'misunderstanding_note_en', version_row.misunderstanding_note_en,
      'legal_classification_note_ms', version_row.legal_classification_note_ms,
      'legal_classification_note_en', version_row.legal_classification_note_en,
      'source_rights_status', version_row.source_rights_status::text,
      'display_mode', version_row.display_mode::text,
      'provenance_status', version_row.provenance_status::text,
      'human_reviewed_by', version_row.human_reviewed_by,
      'human_reviewed_at', to_char(
        version_row.human_reviewed_at at time zone 'UTC',
        'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'
      )
    ),
    'sources', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'usage_scope', version_source_row.usage_scope,
          'source_id', source_row.id,
          'source_stable_key', source_row.stable_key,
          'source_type', source_row.source_type::text,
          'source_name', source_row.source_name,
          'owner_name', source_row.owner_name,
          'source_url', source_row.source_url,
          'bibliographic_locator', source_row.bibliographic_locator,
          'edition', source_row.edition,
          'language_code', source_row.language_code,
          'source_accessed_at', source_row.accessed_at,
          'source_reviewed_at', source_row.reviewed_at,
          'source_current_permission_id', source_row.current_permission_id,
          'permission_id', permission_row.id,
          'permission_revision', permission_row.revision_number,
          'permission_status', permission_row.permission_status::text,
          'permission_display_mode', permission_row.display_mode::text,
          'display_mode', version_source_row.display_mode::text,
          'rights_basis', permission_row.rights_basis,
          'licence', permission_row.licence,
          'permission_scope', permission_row.permission_scope,
          'document_reference', permission_row.document_reference,
          'usage_notes', permission_row.usage_notes,
          'attribution_text', permission_row.attribution_text,
          'permission_accessed_at', permission_row.accessed_at,
          'permission_reviewed_at', permission_row.reviewed_at,
          'permission_reviewed_by', permission_row.reviewed_by,
          'expires_at', permission_row.expires_at
        )
        order by version_source_row.usage_scope, version_source_row.source_id
      )
      from public.version_sources as version_source_row
      join public.sources as source_row
        on source_row.id = version_source_row.source_id
      join public.source_permissions as permission_row
        on permission_row.id = version_source_row.source_permission_id
        and permission_row.source_id = version_source_row.source_id
      where version_source_row.version_id = version_row.id
    ), '[]'::jsonb),
    'evidences', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', evidence_row.id,
          'display_order', version_evidence_row.display_order,
          'is_primary', version_evidence_row.is_primary,
          'evidence_type', evidence_row.evidence_type,
          'arabic_text', evidence_row.arabic_text,
          'translation_ms', evidence_row.translation_ms,
          'translation_en', evidence_row.translation_en,
          'narrator', evidence_row.narrator,
          'collection_name', evidence_row.collection_name,
          'book_name', evidence_row.book_name,
          'chapter_name', evidence_row.chapter_name,
          'reference_number', evidence_row.reference_number,
          'hadith_grade', evidence_row.hadith_grade::text,
          'grader_name', evidence_row.grader_name,
          'source_id', evidence_row.source_id,
          'source_permission_id', evidence_row.source_permission_id,
          'source_locator', evidence_row.source_locator,
          'source_url', evidence_row.source_url,
          'date_verified', evidence_row.date_verified,
          'verification_note', evidence_row.verification_note,
          'rights_status', evidence_row.rights_status::text,
          'display_mode', evidence_row.display_mode::text
        )
        order by version_evidence_row.display_order, evidence_row.id
      )
      from public.version_evidences as version_evidence_row
      join public.evidence_records as evidence_row
        on evidence_row.id = version_evidence_row.evidence_id
      where version_evidence_row.version_id = version_row.id
    ), '[]'::jsonb),
    'locales', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'locale', locale_state_row.locale,
          'is_available', locale_state_row.is_available,
          'unavailable_rationale', locale_state_row.unavailable_rationale
        )
        order by locale_state_row.locale
      )
      from public.version_locale_states as locale_state_row
      where locale_state_row.version_id = version_row.id
    ), '[]'::jsonb)
  )
  from public.sunnah_versions as version_row
  join public.sunnah_items as item_row
    on item_row.id = version_row.sunnah_item_id
  where version_row.id = $1;
$$;

create or replace function private.current_version_draft_checksum(p_version_id uuid)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select private.sha256_hex(private.version_input_snapshot($1)::text);
$$;

create or replace function private.publication_snapshot(p_version_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
set timezone = 'UTC'
as $$
  select jsonb_build_object(
    'schema_version', 'BE03-1',
    'input', private.version_input_snapshot($1),
    'input_checksum', private.current_version_draft_checksum($1),
    'reviews', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'review_scope', review_row.review_scope::text,
          'reviewed_locale', review_row.reviewed_locale,
          'reviewer_id', review_row.reviewer_id,
          'decision', review_row.decision,
          'reviewed_at', to_char(
            review_row.reviewed_at at time zone 'UTC',
            'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'
          ),
          'reviewed_checksum', review_row.reviewed_checksum
        )
        order by review_row.review_scope, review_row.reviewed_locale,
          review_row.reviewed_at, review_row.id
      )
      from public.content_reviews as review_row
      where review_row.version_id = $1
    ), '[]'::jsonb),
    'final_approvals', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'reviewer_id', approval_row.reviewer_id,
          'decision', approval_row.decision,
          'approved_at', to_char(
            approval_row.approved_at at time zone 'UTC',
            'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'
          ),
          'approved_checksum', approval_row.approved_checksum
        )
        order by approval_row.approved_at, approval_row.id
      )
      from public.content_approvals as approval_row
      where approval_row.version_id = $1
        and approval_row.approval_type = 'FINAL_PUBLICATION'
    ), '[]'::jsonb)
  )
  where exists (
    select 1
    from public.sunnah_versions as version_row
    where version_row.id = $1
  );
$$;

create or replace function private.has_current_approved_review(
  p_version_id uuid,
  p_scope public.review_scope,
  p_locale text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  with version_row as (
    select version_value.created_by
    from public.sunnah_versions as version_value
    where version_value.id = $1
  ),
  ranked_reviews as (
    select
      review_row.*,
      row_number() over (
        partition by review_row.reviewer_id, review_row.review_scope,
          coalesce(review_row.reviewed_locale, '')
        order by review_row.reviewed_at desc, review_row.id desc
      ) as current_rank
    from public.content_reviews as review_row
    where review_row.version_id = $1
  )
  select exists (
    select 1
    from ranked_reviews as review_row
    join public.reviewers as reviewer_row
      on reviewer_row.id = review_row.reviewer_id
    cross join version_row
    where review_row.current_rank = 1
      and review_row.review_scope = $2
      and review_row.reviewed_locale is not distinct from $3
      and review_row.decision = 'APPROVED'
      and review_row.reviewed_checksum = private.current_version_draft_checksum($1)
      and reviewer_row.admin_profile_id is distinct from version_row.created_by
      and private.is_eligible_reviewer(
        review_row.reviewer_id,
        private.required_role_for_review_scope($2),
        $2,
        $3
      )
  );
$$;

create or replace function private.has_current_final_approval(p_version_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  with version_row as (
    select version_value.created_by
    from public.sunnah_versions as version_value
    where version_value.id = $1
  ),
  ranked_approvals as (
    select
      approval_row.*,
      row_number() over (
        partition by approval_row.reviewer_id, approval_row.approval_type
        order by approval_row.approved_at desc, approval_row.id desc
      ) as current_rank
    from public.content_approvals as approval_row
    where approval_row.version_id = $1
      and approval_row.approval_type = 'FINAL_PUBLICATION'
  )
  select exists (
    select 1
    from ranked_approvals as approval_row
    join public.reviewers as reviewer_row
      on reviewer_row.id = approval_row.reviewer_id
    cross join version_row
    where approval_row.current_rank = 1
      and approval_row.decision = 'APPROVED'
      and approval_row.approved_checksum = private.current_version_draft_checksum($1)
      and reviewer_row.admin_profile_id is distinct from version_row.created_by
      and private.is_eligible_reviewer(
        approval_row.reviewer_id,
        'PUBLISHER'::public.admin_role_code,
        null,
        null
      )
  );
$$;

create or replace function private.current_approved_reviewer_count(
  p_version_id uuid
)
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  with version_row as (
    select version_value.created_by
    from public.sunnah_versions as version_value
    where version_value.id = $1
  ),
  ranked_reviews as (
    select
      review_row.*,
      row_number() over (
        partition by review_row.reviewer_id, review_row.review_scope,
          coalesce(review_row.reviewed_locale, '')
        order by review_row.reviewed_at desc, review_row.id desc
      ) as current_rank
    from public.content_reviews as review_row
    where review_row.version_id = $1
  ),
  ranked_approvals as (
    select
      approval_row.*,
      row_number() over (
        partition by approval_row.reviewer_id, approval_row.approval_type
        order by approval_row.approved_at desc, approval_row.id desc
      ) as current_rank
    from public.content_approvals as approval_row
    where approval_row.version_id = $1
      and approval_row.approval_type = 'FINAL_PUBLICATION'
  ),
  current_reviewers as (
    select review_row.reviewer_id
    from ranked_reviews as review_row
    join public.reviewers as reviewer_row
      on reviewer_row.id = review_row.reviewer_id
    cross join version_row
    where review_row.current_rank = 1
      and review_row.decision = 'APPROVED'
      and review_row.reviewed_checksum = private.current_version_draft_checksum($1)
      and reviewer_row.admin_profile_id is distinct from version_row.created_by
      and (
        (review_row.review_scope = 'SOURCE_HADITH'::public.review_scope
          and review_row.reviewed_locale is null)
        or (review_row.review_scope = 'FIQH_CONTEXT'::public.review_scope
          and review_row.reviewed_locale is null)
        or (review_row.review_scope = 'LANGUAGE'::public.review_scope
          and review_row.reviewed_locale in ('ms', 'en'))
      )
      and private.is_eligible_reviewer(
        review_row.reviewer_id,
        private.required_role_for_review_scope(review_row.review_scope),
        review_row.review_scope,
        review_row.reviewed_locale
      )
    union
    select approval_row.reviewer_id
    from ranked_approvals as approval_row
    join public.reviewers as reviewer_row
      on reviewer_row.id = approval_row.reviewer_id
    cross join version_row
    where approval_row.current_rank = 1
      and approval_row.decision = 'APPROVED'
      and approval_row.approved_checksum = private.current_version_draft_checksum($1)
      and reviewer_row.admin_profile_id is distinct from version_row.created_by
      and private.is_eligible_reviewer(
        approval_row.reviewer_id,
        'PUBLISHER'::public.admin_role_code,
        null,
        null
      )
  )
  select count(distinct reviewer_id)::integer
  from current_reviewers;
$$;

create or replace function private.assert_version_publication_eligible(
  p_version_id uuid
)
returns void
language plpgsql
stable
security definer
set search_path = ''
set timezone = 'UTC'
as $$
declare
  version_row public.sunnah_versions%rowtype;
  item_row public.sunnah_items%rowtype;
  evidence_count integer;
  primary_evidence_count integer;
begin
  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id;

  if not found then
    raise exception using
      errcode = 'P0001',
      message = 'The requested version does not exist.';
  end if;

  select *
  into item_row
  from public.sunnah_items as item_value
  where item_value.id = version_row.sunnah_item_id;

  if version_row.workflow_status not in (
    'APPROVED'::public.content_workflow_status,
    'SCHEDULED'::public.content_workflow_status,
    'PUBLISHED'::public.content_workflow_status
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'The version is not in a publication-eligible workflow state.';
  end if;

  if version_row.provenance_status <> 'HUMAN_REVIEWED'::public.content_provenance_status
    or version_row.human_reviewed_by is null
    or version_row.human_reviewed_at is null then
    raise exception using
      errcode = 'P0001',
      message = 'The version has not passed the required human provenance review.';
  end if;

  if version_row.created_by is null
    or item_row.category_id is null
    or item_row.classification is null
    or item_row.prophetic_form is null
    or nullif(btrim(item_row.content_type), '') is null
    or not exists (
      select 1
      from public.categories as category_row
      where category_row.id = item_row.category_id
        and category_row.is_active
    ) then
    raise exception using
      errcode = 'P0001',
      message = 'Required item metadata or a traceable author is missing.';
  end if;

  if exists (
    select 1
    from public.sunnah_item_tags as item_tag_row
    join public.tags as tag_row
      on tag_row.id = item_tag_row.tag_id
    where item_tag_row.sunnah_item_id = version_row.sunnah_item_id
      and not tag_row.is_active
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'Inactive tags cannot be included in a publication-eligible item.';
  end if;

  if nullif(btrim(version_row.title_ms), '') is null
    or nullif(btrim(version_row.title_en), '') is null
    or nullif(btrim(version_row.summary_ms), '') is null
    or nullif(btrim(version_row.summary_en), '') is null
    or nullif(btrim(version_row.practical_steps_ms), '') is null
    or nullif(btrim(version_row.practical_steps_en), '') is null
    or nullif(btrim(version_row.when_to_practise_ms), '') is null
    or nullif(btrim(version_row.when_to_practise_en), '') is null
    or nullif(btrim(version_row.context_note_ms), '') is null
    or nullif(btrim(version_row.context_note_en), '') is null
    or nullif(btrim(version_row.misunderstanding_note_ms), '') is null
    or nullif(btrim(version_row.misunderstanding_note_en), '') is null
    or nullif(btrim(version_row.legal_classification_note_ms), '') is null
    or nullif(btrim(version_row.legal_classification_note_en), '') is null then
    raise exception using
      errcode = 'P0001',
      message = 'Required BM and English version fields are incomplete.';
  end if;

  if not exists (
    select 1
    from public.version_locale_states as locale_state_row
    join public.supported_locales as locale_row
      on locale_row.code = locale_state_row.locale
    where locale_state_row.version_id = p_version_id
      and locale_state_row.locale = 'ms'
      and locale_state_row.is_available
      and locale_row.is_active
  ) or not exists (
    select 1
    from public.version_locale_states as locale_state_row
    join public.supported_locales as locale_row
      on locale_row.code = locale_state_row.locale
    where locale_state_row.version_id = p_version_id
      and locale_state_row.locale = 'en'
      and locale_state_row.is_available
      and locale_row.is_active
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'BM and English availability are required for publication.';
  end if;

  if concat_ws(
    ' ',
    item_row.slug,
    version_row.title_ms,
    version_row.title_en,
    version_row.summary_ms,
    version_row.summary_en,
    version_row.practical_steps_ms,
    version_row.practical_steps_en,
    version_row.when_to_practise_ms,
    version_row.when_to_practise_en,
    version_row.context_note_ms,
    version_row.context_note_en,
    version_row.misunderstanding_note_ms,
    version_row.misunderstanding_note_en,
    version_row.legal_classification_note_ms,
    version_row.legal_classification_note_en
  ) ilike '%KANDUNGAN DEMO%'
    or concat_ws(
      ' ',
      item_row.slug,
      version_row.title_ms,
      version_row.title_en,
      version_row.summary_ms,
      version_row.summary_en,
      version_row.practical_steps_ms,
      version_row.practical_steps_en,
      version_row.when_to_practise_ms,
      version_row.when_to_practise_en,
      version_row.context_note_ms,
      version_row.context_note_en,
      version_row.misunderstanding_note_ms,
      version_row.misunderstanding_note_en,
      version_row.legal_classification_note_ms,
      version_row.legal_classification_note_en
    ) ilike '%TIDAK UNTUK PENERBITAN%' then
    raise exception using
      errcode = 'P0001',
      message = 'Development-only marker blocks publication.';
  end if;

  if exists (
    select 1
    from public.content_withdrawals as withdrawal_row
    where withdrawal_row.version_id = p_version_id
      and withdrawal_row.restored_at is null
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'An active withdrawal blocks publication.';
  end if;

  if version_row.publication_sealed_at is not null then
    perform private.assert_sealed_version_integrity(p_version_id);
  end if;

  if not exists (
    select 1
    from public.version_sources as version_source_row
    where version_source_row.version_id = p_version_id
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'No version-scoped source permission is recorded.';
  end if;

  if version_row.display_mode = 'LICENSED_CONTENT'::public.source_display_mode
    and version_row.source_rights_status not in (
      'GRANTED'::public.source_permission_status,
      'PUBLIC_LICENSE'::public.source_permission_status
    ) then
    raise exception using
      errcode = 'P0001',
      message = 'Licensed display requires an allowed version rights status.';
  end if;

  if version_row.display_mode = 'LINK_ONLY'::public.source_display_mode
    and version_row.source_rights_status not in (
      'LINK_ONLY'::public.source_permission_status,
      'GRANTED'::public.source_permission_status,
      'PUBLIC_LICENSE'::public.source_permission_status
    ) then
    raise exception using
      errcode = 'P0001',
      message = 'Link-only display requires an allowed version rights status.';
  end if;

  if exists (
    select 1
    from public.version_sources as version_source_row
    join public.sources as source_row
      on source_row.id = version_source_row.source_id
    join public.source_permissions as permission_row
      on permission_row.id = version_source_row.source_permission_id
      and permission_row.source_id = version_source_row.source_id
    where version_source_row.version_id = p_version_id
      and (
        version_source_row.display_mode <> version_row.display_mode
        or source_row.current_permission_id is distinct from permission_row.id
        or (
          permission_row.expires_at is not null
          and permission_row.expires_at < (now() at time zone 'UTC')::date
        )
        or (
          version_source_row.display_mode = 'LICENSED_CONTENT'::public.source_display_mode
          and (
            permission_row.permission_status not in (
              'GRANTED'::public.source_permission_status,
              'PUBLIC_LICENSE'::public.source_permission_status
            )
            or permission_row.display_mode <> 'LICENSED_CONTENT'::public.source_display_mode
          )
        )
        or (
          version_source_row.display_mode = 'LINK_ONLY'::public.source_display_mode
          and (
            permission_row.permission_status not in (
              'LINK_ONLY'::public.source_permission_status,
              'GRANTED'::public.source_permission_status,
              'PUBLIC_LICENSE'::public.source_permission_status
            )
            or nullif(btrim(source_row.source_url), '') is null
          )
        )
      )
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'A version source permission is not current or display-compatible.';
  end if;

  if exists (
    select 1
    from public.version_sources as version_source_row
    join public.source_permissions as permission_row
      on permission_row.id = version_source_row.source_permission_id
      and permission_row.source_id = version_source_row.source_id
    where version_source_row.version_id = p_version_id
      and permission_row.permission_status = 'GRANTED'::public.source_permission_status
      and nullif(btrim(permission_row.document_reference), '') is null
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'Granted source permissions require a written reference.';
  end if;

  if exists (
    select 1
    from public.version_sources as version_source_row
    join public.source_permissions as permission_row
      on permission_row.id = version_source_row.source_permission_id
      and permission_row.source_id = version_source_row.source_id
    where version_source_row.version_id = p_version_id
      and permission_row.permission_status = 'PUBLIC_LICENSE'::public.source_permission_status
      and (
        nullif(btrim(permission_row.licence), '') is null
        or nullif(btrim(permission_row.attribution_text), '') is null
      )
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'Public-license source permissions require licence and attribution.';
  end if;

  if exists (
    select 1
    from public.version_evidences as version_evidence_row
    join public.evidence_records as evidence_row
      on evidence_row.id = version_evidence_row.evidence_id
    left join public.source_permissions as permission_row
      on permission_row.id = evidence_row.source_permission_id
      and permission_row.source_id = evidence_row.source_id
    where version_evidence_row.version_id = p_version_id
      and (
        evidence_row.source_permission_id is null
        or permission_row.id is null
        or evidence_row.rights_status <> permission_row.permission_status
        or evidence_row.display_mode <> version_row.display_mode
        or not exists (
          select 1
          from public.version_sources as version_source_row
          where version_source_row.version_id = p_version_id
            and version_source_row.source_id = evidence_row.source_id
            and version_source_row.source_permission_id = evidence_row.source_permission_id
            and version_source_row.display_mode = evidence_row.display_mode
        )
      )
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'Evidence is not bound to the version source permission.';
  end if;

  if exists (
    select 1
    from public.version_evidences as version_evidence_row
    join public.evidence_records as evidence_row
      on evidence_row.id = version_evidence_row.evidence_id
    where version_evidence_row.version_id = p_version_id
      and evidence_row.display_mode = 'LINK_ONLY'::public.source_display_mode
      and (
        nullif(btrim(evidence_row.arabic_text), '') is not null
        or nullif(btrim(evidence_row.translation_ms), '') is not null
        or nullif(btrim(evidence_row.translation_en), '') is not null
      )
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'Link-only evidence cannot include source text or translations.';
  end if;

  select
    count(*)::integer,
    count(*) filter (where version_evidence_row.is_primary)::integer
  into evidence_count, primary_evidence_count
  from public.version_evidences as version_evidence_row
  where version_evidence_row.version_id = p_version_id;

  if evidence_count = 0 or primary_evidence_count <> 1 then
    raise exception using
      errcode = 'P0001',
      message = 'Exactly one primary evidence record is required.';
  end if;

  if not private.has_current_approved_review(
    p_version_id,
    'SOURCE_HADITH'::public.review_scope,
    null
  ) or not private.has_current_approved_review(
    p_version_id,
    'FIQH_CONTEXT'::public.review_scope,
    null
  ) or not private.has_current_approved_review(
    p_version_id,
    'LANGUAGE'::public.review_scope,
    'ms'
  ) or not private.has_current_approved_review(
    p_version_id,
    'LANGUAGE'::public.review_scope,
    'en'
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'Required current reviewer decisions are incomplete.';
  end if;

  if not private.has_current_final_approval(p_version_id) then
    raise exception using
      errcode = 'P0001',
      message = 'A current qualified final approval is required.';
  end if;

  if private.current_approved_reviewer_count(p_version_id) < 2 then
    raise exception using
      errcode = 'P0001',
      message = 'At least two distinct qualified human reviewers are required.';
  end if;

end;
$$;

create or replace function private.assert_sealed_version_integrity(
  p_version_id uuid
)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  version_row public.sunnah_versions%rowtype;
  expected_snapshot jsonb;
begin
  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id;

  if not found
    or version_row.publication_snapshot is null
    or version_row.publication_checksum is null
    or version_row.content_checksum is null
    or version_row.publication_sealed_at is null
    or version_row.publication_sealed_by is null then
    raise exception using
      errcode = 'P0001',
      message = 'The version does not have a complete server publication seal.';
  end if;

  expected_snapshot := private.publication_snapshot(p_version_id);

  if version_row.publication_snapshot is distinct from expected_snapshot
    or version_row.publication_checksum <> private.sha256_hex(
      version_row.publication_snapshot::text
    )
    or version_row.content_checksum <> version_row.publication_checksum then
    raise exception using
      errcode = 'P0001',
      message = 'The server publication seal no longer matches the version inputs.';
  end if;
end;
$$;

create or replace function private.assert_daily_feed_eligible(
  p_version_id uuid,
  p_locale text
)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  primary_grade public.hadith_grade;
begin
  if p_locale is null or p_locale not in ('ms', 'en') then
    raise exception using
      errcode = 'P0001',
      message = 'Only reviewed BM and English daily locales are supported.';
  end if;

  select evidence_row.hadith_grade
  into primary_grade
  from public.version_evidences as version_evidence_row
  join public.evidence_records as evidence_row
    on evidence_row.id = version_evidence_row.evidence_id
  where version_evidence_row.version_id = p_version_id
    and version_evidence_row.is_primary;

  if primary_grade not in (
    'SAHIH'::public.hadith_grade,
    'HASAN'::public.hadith_grade
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'The primary evidence grade is not eligible for the Daily Feed.';
  end if;

  perform private.assert_version_publication_eligible(p_version_id);
  perform private.assert_sealed_version_integrity(p_version_id);

  if not exists (
    select 1
    from public.version_locale_states as locale_state_row
    join public.supported_locales as locale_row
      on locale_row.code = locale_state_row.locale
    where locale_state_row.version_id = p_version_id
      and locale_state_row.locale = p_locale
      and locale_state_row.is_available
      and locale_row.is_active
  ) or not private.has_current_approved_review(
    p_version_id,
    'LANGUAGE'::public.review_scope,
    p_locale
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'The requested daily locale is not currently reviewed and available.';
  end if;
end;
$$;

create or replace function private.record_workflow_event(
  p_version_id uuid,
  p_actor_id uuid,
  p_event_type text,
  p_from_status public.content_workflow_status,
  p_to_status public.content_workflow_status,
  p_reason text,
  p_input_checksum text
)
returns void
language sql
volatile
security definer
set search_path = ''
as $$
  insert into public.content_workflow_events (
    version_id,
    actor_id,
    event_type,
    from_status,
    to_status,
    reason,
    input_checksum
  )
  values ($1, $2, $3, $4, $5, $6, $7);
$$;

create or replace function private.sync_item_workflow_status(
  p_version_id uuid,
  p_status public.content_workflow_status
)
returns void
language sql
volatile
security definer
set search_path = ''
as $$
  update public.sunnah_items as item_row
  set
    current_version_id = coalesce(item_row.current_version_id, version_row.id),
    workflow_status = $2
  from public.sunnah_versions as version_row
  where version_row.id = $1
    and item_row.id = version_row.sunnah_item_id
    and (
      item_row.current_version_id is null
      or item_row.current_version_id = version_row.id
    );
$$;

create or replace function private.prevent_sealed_version_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    if old.publication_sealed_at is not null or old.immutable_after_publish then
      raise exception using
        errcode = '55000',
        message = 'A sealed or published version cannot be deleted.';
    end if;
    return old;
  end if;

  if old.publication_sealed_at is not null or old.immutable_after_publish then
    if old.immutable_after_publish and not new.immutable_after_publish then
      raise exception using
        errcode = '55000',
        message = 'Published immutability cannot be removed.';
    end if;

    if (
      to_jsonb(new) - array['workflow_status', 'immutable_after_publish', 'updated_at']
    ) is distinct from (
      to_jsonb(old) - array['workflow_status', 'immutable_after_publish', 'updated_at']
    ) then
      raise exception using
        errcode = '55000',
        message = 'A sealed or published version cannot be changed in place.';
    end if;
  end if;

  return new;
end;
$$;

create or replace function private.prevent_sealed_version_graph_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  affected_version_id uuid;
begin
  if tg_op = 'INSERT' then
    affected_version_id := new.version_id;
  elsif tg_op = 'DELETE' then
    affected_version_id := old.version_id;
  else
    if exists (
      select 1
      from public.sunnah_versions as version_row
      where version_row.id = old.version_id
        and (
          version_row.publication_sealed_at is not null
          or version_row.immutable_after_publish
        )
    ) or exists (
      select 1
      from public.sunnah_versions as version_row
      where version_row.id = new.version_id
        and (
          version_row.publication_sealed_at is not null
          or version_row.immutable_after_publish
        )
    ) then
      raise exception using
        errcode = '55000',
        message = 'The publication inputs of a sealed or published version cannot change.';
    end if;
    return new;
  end if;

  if exists (
    select 1
    from public.sunnah_versions as version_row
    where version_row.id = affected_version_id
      and (
        version_row.publication_sealed_at is not null
        or version_row.immutable_after_publish
      )
  ) then
    raise exception using
      errcode = '55000',
      message = 'The publication inputs of a sealed or published version cannot change.';
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create or replace function private.prevent_workflow_event_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  raise exception using
    errcode = '55000',
    message = 'Workflow events are append-only.';
end;
$$;

create trigger sunnah_versions_prevent_sealed_mutation
before update or delete on public.sunnah_versions
for each row execute function private.prevent_sealed_version_mutation();

create trigger version_sources_prevent_sealed_mutation
before insert or update or delete on public.version_sources
for each row execute function private.prevent_sealed_version_graph_mutation();

create trigger version_locale_states_prevent_sealed_mutation
before insert or update or delete on public.version_locale_states
for each row execute function private.prevent_sealed_version_graph_mutation();

create trigger version_evidences_prevent_sealed_mutation
before insert or update or delete on public.version_evidences
for each row execute function private.prevent_sealed_version_graph_mutation();

create trigger content_reviews_prevent_sealed_mutation
before insert or update or delete on public.content_reviews
for each row execute function private.prevent_sealed_version_graph_mutation();

create trigger content_approvals_prevent_sealed_mutation
before insert or update or delete on public.content_approvals
for each row execute function private.prevent_sealed_version_graph_mutation();

create trigger content_workflow_events_append_only
before update or delete on public.content_workflow_events
for each row execute function private.prevent_workflow_event_mutation();

create or replace function public.advance_content_workflow(
  p_version_id uuid,
  p_target_status public.content_workflow_status,
  p_reason text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  version_row public.sunnah_versions%rowtype;
  actor_id uuid;
  required_role public.admin_role_code;
begin
  actor_id := (select auth.uid());
  if actor_id is null then
    raise exception using
      errcode = '42501',
      message = 'Authentication is required for workflow changes.';
  end if;

  -- All permitted transitions in this RPC are researcher work.  Check this
  -- before looking up the version so a caller without that role cannot use
  -- differing errors to discover version identifiers.
  perform private.assert_active_admin_role(
    'RESEARCHER'::public.admin_role_code,
    'advance content workflow'
  );

  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0001',
      message = 'The requested version does not exist.';
  end if;

  if version_row.publication_sealed_at is not null
    or version_row.immutable_after_publish then
    raise exception using
      errcode = '55000',
      message = 'A sealed version cannot be advanced through draft workflow steps.';
  end if;

  case version_row.workflow_status
    when 'DRAFT'::public.content_workflow_status then
      if p_target_status <> 'RESEARCHED'::public.content_workflow_status then
        raise exception using errcode = 'P0001', message = 'Invalid draft workflow transition.';
      end if;
      required_role := 'RESEARCHER'::public.admin_role_code;
    when 'RESEARCHED'::public.content_workflow_status then
      if p_target_status <> 'HADITH_REVIEW_PENDING'::public.content_workflow_status then
        raise exception using errcode = 'P0001', message = 'Invalid researched workflow transition.';
      end if;
      required_role := 'RESEARCHER'::public.admin_role_code;
    when 'HADITH_VERIFIED'::public.content_workflow_status then
      if p_target_status <> 'FIQH_REVIEW_PENDING'::public.content_workflow_status then
        raise exception using errcode = 'P0001', message = 'Invalid hadith-reviewed workflow transition.';
      end if;
      required_role := 'RESEARCHER'::public.admin_role_code;
    when 'FIQH_REVIEWED'::public.content_workflow_status then
      if p_target_status <> 'LANGUAGE_REVIEW_PENDING'::public.content_workflow_status then
        raise exception using errcode = 'P0001', message = 'Invalid fiqh-reviewed workflow transition.';
      end if;
      required_role := 'RESEARCHER'::public.admin_role_code;
    when 'LANGUAGE_REVIEWED'::public.content_workflow_status then
      if p_target_status <> 'FINAL_APPROVAL_PENDING'::public.content_workflow_status then
        raise exception using errcode = 'P0001', message = 'Invalid language-reviewed workflow transition.';
      end if;
      required_role := 'RESEARCHER'::public.admin_role_code;
    when 'CORRECTION_PENDING'::public.content_workflow_status then
      if p_target_status <> 'DRAFT'::public.content_workflow_status then
        raise exception using errcode = 'P0001', message = 'Invalid correction workflow transition.';
      end if;
      required_role := 'RESEARCHER'::public.admin_role_code;
    else
      raise exception using
        errcode = 'P0001',
        message = 'The current workflow state cannot be advanced by this action.';
  end case;

  perform private.assert_active_admin_role(required_role, 'advance content workflow');

  update public.sunnah_versions
  set workflow_status = p_target_status
  where id = p_version_id;

  perform private.sync_item_workflow_status(p_version_id, p_target_status);
  perform private.record_workflow_event(
    p_version_id,
    actor_id,
    'WORKFLOW_ADVANCED',
    version_row.workflow_status,
    p_target_status,
    p_reason,
    private.current_version_draft_checksum(p_version_id)
  );
end;
$$;

create or replace function public.mark_version_human_reviewed(
  p_version_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  version_row public.sunnah_versions%rowtype;
  actor_id uuid;
begin
  actor_id := (select auth.uid());
  perform private.assert_active_admin_role(
    'CONTENT_ADMIN'::public.admin_role_code,
    'record human provenance review'
  );

  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id
  for update;

  if not found then
    raise exception using errcode = 'P0001', message = 'The requested version does not exist.';
  end if;

  if version_row.publication_sealed_at is not null
    or version_row.immutable_after_publish then
    raise exception using
      errcode = '55000',
      message = 'A sealed version cannot change provenance state.';
  end if;

  if version_row.provenance_status = 'DEMO'::public.content_provenance_status then
    raise exception using
      errcode = 'P0001',
      message = 'Development-only versions must be recreated before human review.';
  end if;

  update public.sunnah_versions
  set
    provenance_status = 'HUMAN_REVIEWED'::public.content_provenance_status,
    human_reviewed_by = actor_id,
    human_reviewed_at = now()
  where id = p_version_id;

  perform private.record_workflow_event(
    p_version_id,
    actor_id,
    'HUMAN_PROVENANCE_RECORDED',
    version_row.workflow_status,
    version_row.workflow_status,
    null,
    private.current_version_draft_checksum(p_version_id)
  );
end;
$$;

create or replace function public.record_content_review(
  p_version_id uuid,
  p_scope public.review_scope,
  p_reviewed_locale text default null,
  p_decision text default 'APPROVED',
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  version_row public.sunnah_versions%rowtype;
  current_reviewer_id uuid;
  prior_review_id uuid;
  review_id uuid;
  actor_id uuid;
  next_status public.content_workflow_status;
  checksum text;
begin
  if p_decision is null or p_decision not in ('APPROVED', 'REJECTED') then
    raise exception using errcode = 'P0001', message = 'Review decisions must be APPROVED or REJECTED.';
  end if;

  actor_id := (select auth.uid());
  current_reviewer_id := private.current_reviewer_for_scope(p_scope, p_reviewed_locale);

  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id
  for update;

  if not found then
    raise exception using errcode = 'P0001', message = 'The requested version does not exist.';
  end if;

  if version_row.created_by = actor_id then
    raise exception using
      errcode = '42501',
      message = 'A version author cannot submit its required reviewer decision.';
  end if;

  if version_row.publication_sealed_at is not null
    or version_row.immutable_after_publish then
    raise exception using errcode = '55000', message = 'A sealed version cannot receive another review.';
  end if;

  if (
    p_scope = 'SOURCE_HADITH'::public.review_scope
    and version_row.workflow_status <> 'HADITH_REVIEW_PENDING'::public.content_workflow_status
  ) or (
    p_scope = 'FIQH_CONTEXT'::public.review_scope
    and version_row.workflow_status <> 'FIQH_REVIEW_PENDING'::public.content_workflow_status
  ) or (
    p_scope = 'LANGUAGE'::public.review_scope
    and version_row.workflow_status <> 'LANGUAGE_REVIEW_PENDING'::public.content_workflow_status
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'The version is not waiting for this review scope.';
  end if;

  checksum := private.current_version_draft_checksum(p_version_id);

  select review_row.id
  into prior_review_id
  from public.content_reviews as review_row
  where review_row.version_id = p_version_id
    and review_row.reviewer_id = current_reviewer_id
    and review_row.review_scope = p_scope
    and review_row.reviewed_locale is not distinct from p_reviewed_locale
  order by review_row.reviewed_at desc, review_row.id desc
  limit 1;

  insert into public.content_reviews (
    review_scope,
    reviewer_id,
    version_id,
    decision,
    notes,
    reviewed_locale,
    reviewed_checksum,
    supersedes_review_id
  )
  values (
    p_scope,
    current_reviewer_id,
    p_version_id,
    p_decision,
    p_notes,
    p_reviewed_locale,
    checksum,
    prior_review_id
  )
  returning id into review_id;

  if p_decision = 'REJECTED' then
    next_status := case p_scope
      when 'SOURCE_HADITH'::public.review_scope then 'RESEARCHED'::public.content_workflow_status
      when 'FIQH_CONTEXT'::public.review_scope then 'HADITH_VERIFIED'::public.content_workflow_status
      else 'FIQH_REVIEWED'::public.content_workflow_status
    end;
  elsif p_scope = 'SOURCE_HADITH'::public.review_scope then
    next_status := 'HADITH_VERIFIED'::public.content_workflow_status;
  elsif p_scope = 'FIQH_CONTEXT'::public.review_scope then
    next_status := 'FIQH_REVIEWED'::public.content_workflow_status;
  elsif private.has_current_approved_review(
    p_version_id,
    'LANGUAGE'::public.review_scope,
    'ms'
  ) and private.has_current_approved_review(
    p_version_id,
    'LANGUAGE'::public.review_scope,
    'en'
  ) then
    next_status := 'LANGUAGE_REVIEWED'::public.content_workflow_status;
  else
    next_status := 'LANGUAGE_REVIEW_PENDING'::public.content_workflow_status;
  end if;

  update public.sunnah_versions
  set workflow_status = next_status
  where id = p_version_id;

  perform private.sync_item_workflow_status(p_version_id, next_status);
  perform private.record_workflow_event(
    p_version_id,
    actor_id,
    case when p_decision = 'APPROVED' then 'REVIEW_APPROVED' else 'REVIEW_REJECTED' end,
    version_row.workflow_status,
    next_status,
    null,
    checksum
  );

  return review_id;
end;
$$;

create or replace function public.record_final_publication_approval(
  p_version_id uuid,
  p_decision text default 'APPROVED',
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  version_row public.sunnah_versions%rowtype;
  final_reviewer_id uuid;
  prior_approval_id uuid;
  approval_id uuid;
  actor_id uuid;
  checksum text;
  next_status public.content_workflow_status;
begin
  if p_decision is null or p_decision not in ('APPROVED', 'REJECTED') then
    raise exception using errcode = 'P0001', message = 'Approval decisions must be APPROVED or REJECTED.';
  end if;

  actor_id := (select auth.uid());
  final_reviewer_id := private.current_final_approver();

  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id
  for update;

  if not found then
    raise exception using errcode = 'P0001', message = 'The requested version does not exist.';
  end if;

  if version_row.created_by = actor_id then
    raise exception using
      errcode = '42501',
      message = 'A version author cannot issue final approval or publish the version.';
  end if;

  if version_row.workflow_status <> 'FINAL_APPROVAL_PENDING'::public.content_workflow_status
    or version_row.publication_sealed_at is not null
    or version_row.immutable_after_publish then
    raise exception using
      errcode = 'P0001',
      message = 'The version is not eligible for final approval.';
  end if;

  checksum := private.current_version_draft_checksum(p_version_id);

  if p_decision = 'APPROVED'
    and (
      not private.has_current_approved_review(
        p_version_id,
        'SOURCE_HADITH'::public.review_scope,
        null
      )
      or not private.has_current_approved_review(
        p_version_id,
        'FIQH_CONTEXT'::public.review_scope,
        null
      )
      or not private.has_current_approved_review(
        p_version_id,
        'LANGUAGE'::public.review_scope,
        'ms'
      )
      or not private.has_current_approved_review(
        p_version_id,
        'LANGUAGE'::public.review_scope,
        'en'
      )
    ) then
    raise exception using
      errcode = 'P0001',
      message = 'Required current reviewer decisions are incomplete.';
  end if;

  select approval_row.id
  into prior_approval_id
  from public.content_approvals as approval_row
  where approval_row.version_id = p_version_id
    and approval_row.reviewer_id = final_reviewer_id
    and approval_row.approval_type = 'FINAL_PUBLICATION'
  order by approval_row.approved_at desc, approval_row.id desc
  limit 1;

  insert into public.content_approvals (
    version_id,
    reviewer_id,
    approval_type,
    decision,
    notes,
    approved_checksum,
    supersedes_approval_id
  )
  values (
    p_version_id,
    final_reviewer_id,
    'FINAL_PUBLICATION',
    p_decision,
    p_notes,
    checksum,
    prior_approval_id
  )
  returning id into approval_id;

  next_status := case when p_decision = 'APPROVED'
    then 'APPROVED'::public.content_workflow_status
    else 'LANGUAGE_REVIEWED'::public.content_workflow_status
  end;

  update public.sunnah_versions
  set workflow_status = next_status
  where id = p_version_id;

  if p_decision = 'APPROVED' then
    perform private.assert_version_publication_eligible(p_version_id);
  end if;

  perform private.sync_item_workflow_status(p_version_id, next_status);
  perform private.record_workflow_event(
    p_version_id,
    actor_id,
    case when p_decision = 'APPROVED' then 'FINAL_APPROVAL_GRANTED' else 'FINAL_APPROVAL_REJECTED' end,
    version_row.workflow_status,
    next_status,
    null,
    checksum
  );

  return approval_id;
end;
$$;

create or replace function public.seal_version_for_publication(
  p_version_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  version_row public.sunnah_versions%rowtype;
  actor_id uuid;
  snapshot jsonb;
  checksum text;
begin
  actor_id := (select auth.uid());
  perform private.assert_active_admin_role(
    'PUBLISHER'::public.admin_role_code,
    'seal a version for publication'
  );

  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id
  for update;

  if not found then
    raise exception using errcode = 'P0001', message = 'The requested version does not exist.';
  end if;

  if version_row.created_by = actor_id then
    raise exception using
      errcode = '42501',
      message = 'A version author cannot seal or publish the version.';
  end if;

  if version_row.workflow_status <> 'APPROVED'::public.content_workflow_status
    or version_row.publication_sealed_at is not null
    or version_row.immutable_after_publish then
    raise exception using
      errcode = 'P0001',
      message = 'Only an unsealed approved version may receive a publication seal.';
  end if;

  perform private.assert_version_publication_eligible(p_version_id);
  snapshot := private.publication_snapshot(p_version_id);
  checksum := private.sha256_hex(snapshot::text);

  update public.sunnah_versions
  set
    content_checksum = checksum,
    publication_snapshot = snapshot,
    publication_checksum = checksum,
    publication_sealed_at = now(),
    publication_sealed_by = actor_id
  where id = p_version_id;

  perform private.record_workflow_event(
    p_version_id,
    actor_id,
    'PUBLICATION_SEALED',
    version_row.workflow_status,
    version_row.workflow_status,
    null,
    private.current_version_draft_checksum(p_version_id)
  );
end;
$$;

create or replace function public.schedule_daily_version(
  p_version_id uuid,
  p_local_date date,
  p_timezone_scope text,
  p_locale text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  version_row public.sunnah_versions%rowtype;
  actor_id uuid;
  schedule_id uuid;
begin
  if p_local_date is null
    or nullif(btrim(p_timezone_scope), '') is null then
    raise exception using errcode = 'P0001', message = 'A daily date and timezone scope are required.';
  end if;

  actor_id := (select auth.uid());
  perform private.assert_active_admin_role(
    'PUBLISHER'::public.admin_role_code,
    'schedule Daily Feed content'
  );

  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id
  for update;

  if not found then
    raise exception using errcode = 'P0001', message = 'The requested version does not exist.';
  end if;

  if version_row.created_by = actor_id
    or version_row.workflow_status <> 'APPROVED'::public.content_workflow_status then
    raise exception using
      errcode = '42501',
      message = 'Only an independent publisher may schedule an approved version.';
  end if;

  perform private.assert_daily_feed_eligible(p_version_id, p_locale);

  insert into public.daily_schedule (
    local_date,
    timezone_scope,
    version_id,
    locale,
    schedule_status,
    scheduled_by
  )
  values (
    p_local_date,
    p_timezone_scope,
    p_version_id,
    p_locale,
    'SCHEDULED',
    actor_id
  )
  returning id into schedule_id;

  update public.sunnah_versions
  set workflow_status = 'SCHEDULED'::public.content_workflow_status
  where id = p_version_id;

  perform private.sync_item_workflow_status(
    p_version_id,
    'SCHEDULED'::public.content_workflow_status
  );
  perform private.record_workflow_event(
    p_version_id,
    actor_id,
    'DAILY_SCHEDULED',
    version_row.workflow_status,
    'SCHEDULED'::public.content_workflow_status,
    null,
    private.current_version_draft_checksum(p_version_id)
  );

  return schedule_id;
end;
$$;

create or replace function public.publish_daily_schedule(p_schedule_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  schedule_row public.daily_schedule%rowtype;
  version_row public.sunnah_versions%rowtype;
  actor_id uuid;
begin
  actor_id := (select auth.uid());
  perform private.assert_active_admin_role(
    'PUBLISHER'::public.admin_role_code,
    'publish Daily Feed content'
  );

  select *
  into schedule_row
  from public.daily_schedule as schedule_value
  where schedule_value.id = p_schedule_id
  for update;

  if not found then
    raise exception using errcode = 'P0001', message = 'The requested daily schedule does not exist.';
  end if;

  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = schedule_row.version_id
  for update;

  if schedule_row.schedule_status <> 'SCHEDULED'
    or version_row.workflow_status <> 'SCHEDULED'::public.content_workflow_status
    or version_row.created_by = actor_id then
    raise exception using
      errcode = '42501',
      message = 'Only an independent publisher may publish a scheduled version.';
  end if;

  perform private.assert_daily_feed_eligible(version_row.id, schedule_row.locale);

  update public.daily_schedule
  set
    schedule_status = 'PUBLISHED',
    published_at = now()
  where id = schedule_row.id;

  update public.sunnah_versions
  set
    workflow_status = 'PUBLISHED'::public.content_workflow_status,
    immutable_after_publish = true
  where id = version_row.id;

  update public.sunnah_items
  set
    current_version_id = version_row.id,
    workflow_status = 'PUBLISHED'::public.content_workflow_status
  where id = version_row.sunnah_item_id;

  update public.corrections as correction_row
  set
    correction_status = 'PUBLISHED',
    resolved_at = now()
  where correction_row.to_version_id = version_row.id
    and correction_row.resolved_at is null;

  update public.sunnah_versions as prior_version_row
  set workflow_status = 'CORRECTED'::public.content_workflow_status
  from public.corrections as correction_row
  where correction_row.to_version_id = version_row.id
    and correction_row.from_version_id = prior_version_row.id;

  update public.daily_schedule as prior_schedule_row
  set schedule_status = 'SUSPENDED'
  from public.corrections as correction_row
  where correction_row.to_version_id = version_row.id
    and prior_schedule_row.version_id = correction_row.from_version_id
    and prior_schedule_row.schedule_status in ('SCHEDULED', 'PUBLISHED');

  perform private.record_workflow_event(
    version_row.id,
    actor_id,
    'DAILY_PUBLISHED',
    version_row.workflow_status,
    'PUBLISHED'::public.content_workflow_status,
    null,
    private.current_version_draft_checksum(version_row.id)
  );
end;
$$;

create or replace function public.withdraw_published_version(
  p_version_id uuid,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  version_row public.sunnah_versions%rowtype;
  actor_id uuid;
begin
  if nullif(btrim(p_reason), '') is null then
    raise exception using errcode = 'P0001', message = 'A withdrawal reason is required.';
  end if;

  actor_id := (select auth.uid());
  perform private.assert_active_admin_role(
    'PUBLISHER'::public.admin_role_code,
    'withdraw published content'
  );

  select *
  into version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_version_id
  for update;

  if not found then
    raise exception using errcode = 'P0001', message = 'The requested version does not exist.';
  end if;

  if version_row.workflow_status not in (
    'SCHEDULED'::public.content_workflow_status,
    'PUBLISHED'::public.content_workflow_status
  ) or version_row.created_by = actor_id then
    raise exception using
      errcode = '42501',
      message = 'Only an independent publisher may withdraw scheduled or published content.';
  end if;

  if exists (
    select 1
    from public.content_withdrawals as withdrawal_row
    where withdrawal_row.version_id = p_version_id
      and withdrawal_row.restored_at is null
  ) then
    raise exception using errcode = 'P0001', message = 'The version is already withdrawn.';
  end if;

  insert into public.content_withdrawals (
    sunnah_item_id,
    version_id,
    reason,
    withdrawn_by
  )
  values (
    version_row.sunnah_item_id,
    p_version_id,
    p_reason,
    actor_id
  );

  update public.daily_schedule
  set schedule_status = 'WITHDRAWN'
  where version_id = p_version_id
    and schedule_status in ('SCHEDULED', 'PUBLISHED');

  update public.sunnah_versions
  set workflow_status = 'WITHDRAWN'::public.content_workflow_status
  where id = p_version_id;

  update public.sunnah_items
  set workflow_status = 'WITHDRAWN'::public.content_workflow_status
  where id = version_row.sunnah_item_id
    and current_version_id = p_version_id;

  perform private.record_workflow_event(
    p_version_id,
    actor_id,
    'WITHDRAWN',
    version_row.workflow_status,
    'WITHDRAWN'::public.content_workflow_status,
    p_reason,
    private.current_version_draft_checksum(p_version_id)
  );
end;
$$;

create or replace function public.create_correction_draft(
  p_from_version_id uuid,
  p_reason text,
  p_diff_summary jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  source_version_row public.sunnah_versions%rowtype;
  actor_id uuid;
  new_version_id uuid;
  next_version_number integer;
begin
  if nullif(btrim(p_reason), '') is null
    or jsonb_typeof(p_diff_summary) <> 'object' then
    raise exception using
      errcode = 'P0001',
      message = 'A correction reason and object-shaped diff summary are required.';
  end if;

  actor_id := (select auth.uid());
  perform private.assert_active_admin_role(
    'CONTENT_ADMIN'::public.admin_role_code,
    'create a correction draft'
  );

  select *
  into source_version_row
  from public.sunnah_versions as version_value
  where version_value.id = p_from_version_id
  for update;

  if not found then
    raise exception using errcode = 'P0001', message = 'The source version does not exist.';
  end if;

  if source_version_row.workflow_status <> 'PUBLISHED'::public.content_workflow_status
    or source_version_row.publication_sealed_at is null then
    raise exception using
      errcode = 'P0001',
      message = 'Only a sealed published version can start a correction.';
  end if;

  perform 1
  from public.sunnah_items as item_row
  where item_row.id = source_version_row.sunnah_item_id
  for update;

  select coalesce(max(version_row.version_number), 0) + 1
  into next_version_number
  from public.sunnah_versions as version_row
  where version_row.sunnah_item_id = source_version_row.sunnah_item_id;

  insert into public.sunnah_versions (
    sunnah_item_id,
    version_number,
    title_ms,
    title_en,
    summary_ms,
    summary_en,
    practical_steps_ms,
    practical_steps_en,
    when_to_practise_ms,
    when_to_practise_en,
    context_note_ms,
    context_note_en,
    misunderstanding_note_ms,
    misunderstanding_note_en,
    legal_classification_note_ms,
    legal_classification_note_en,
    source_rights_status,
    display_mode,
    workflow_status,
    provenance_status,
    created_by
  )
  values (
    source_version_row.sunnah_item_id,
    next_version_number,
    source_version_row.title_ms,
    source_version_row.title_en,
    source_version_row.summary_ms,
    source_version_row.summary_en,
    source_version_row.practical_steps_ms,
    source_version_row.practical_steps_en,
    source_version_row.when_to_practise_ms,
    source_version_row.when_to_practise_en,
    source_version_row.context_note_ms,
    source_version_row.context_note_en,
    source_version_row.misunderstanding_note_ms,
    source_version_row.misunderstanding_note_en,
    source_version_row.legal_classification_note_ms,
    source_version_row.legal_classification_note_en,
    source_version_row.source_rights_status,
    source_version_row.display_mode,
    'CORRECTION_PENDING',
    'NEEDS_REVIEW',
    actor_id
  )
  returning id into new_version_id;

  insert into public.version_sources (
    version_id,
    source_id,
    source_permission_id,
    usage_scope,
    display_mode
  )
  select
    new_version_id,
    version_source_row.source_id,
    version_source_row.source_permission_id,
    version_source_row.usage_scope,
    version_source_row.display_mode
  from public.version_sources as version_source_row
  where version_source_row.version_id = p_from_version_id;

  insert into public.version_evidences (
    version_id,
    evidence_id,
    display_order,
    is_primary
  )
  select
    new_version_id,
    version_evidence_row.evidence_id,
    version_evidence_row.display_order,
    version_evidence_row.is_primary
  from public.version_evidences as version_evidence_row
  where version_evidence_row.version_id = p_from_version_id;

  insert into public.version_locale_states (
    version_id,
    locale,
    is_available,
    unavailable_rationale
  )
  select
    new_version_id,
    locale_state_row.locale,
    locale_state_row.is_available,
    locale_state_row.unavailable_rationale
  from public.version_locale_states as locale_state_row
  where locale_state_row.version_id = p_from_version_id;

  insert into public.corrections (
    sunnah_item_id,
    from_version_id,
    to_version_id,
    correction_status,
    reason,
    diff_summary,
    created_by
  )
  values (
    source_version_row.sunnah_item_id,
    p_from_version_id,
    new_version_id,
    'OPEN',
    p_reason,
    p_diff_summary,
    actor_id
  );

  perform private.record_workflow_event(
    new_version_id,
    actor_id,
    'CORRECTION_DRAFT_CREATED',
    null,
    'CORRECTION_PENDING'::public.content_workflow_status,
    p_reason,
    private.current_version_draft_checksum(new_version_id)
  );

  return new_version_id;
end;
$$;

alter function private.sha256_hex(text) owner to postgres;
alter function private.assert_active_admin_role(public.admin_role_code, text) owner to postgres;
alter function private.required_role_for_review_scope(public.review_scope) owner to postgres;
alter function private.is_eligible_reviewer(
  uuid,
  public.admin_role_code,
  public.review_scope,
  text
) owner to postgres;
alter function private.current_reviewer_for_scope(public.review_scope, text) owner to postgres;
alter function private.current_final_approver() owner to postgres;
alter function private.version_input_snapshot(uuid) owner to postgres;
alter function private.current_version_draft_checksum(uuid) owner to postgres;
alter function private.publication_snapshot(uuid) owner to postgres;
alter function private.has_current_approved_review(uuid, public.review_scope, text) owner to postgres;
alter function private.has_current_final_approval(uuid) owner to postgres;
alter function private.current_approved_reviewer_count(uuid) owner to postgres;
alter function private.assert_version_publication_eligible(uuid) owner to postgres;
alter function private.assert_sealed_version_integrity(uuid) owner to postgres;
alter function private.assert_daily_feed_eligible(uuid, text) owner to postgres;
alter function private.record_workflow_event(
  uuid,
  uuid,
  text,
  public.content_workflow_status,
  public.content_workflow_status,
  text,
  text
) owner to postgres;
alter function private.sync_item_workflow_status(uuid, public.content_workflow_status)
  owner to postgres;
alter function private.prevent_sealed_version_mutation() owner to postgres;
alter function private.prevent_sealed_version_graph_mutation() owner to postgres;
alter function private.prevent_workflow_event_mutation() owner to postgres;

alter function public.advance_content_workflow(
  uuid,
  public.content_workflow_status,
  text
) owner to postgres;
alter function public.mark_version_human_reviewed(uuid) owner to postgres;
alter function public.record_content_review(
  uuid,
  public.review_scope,
  text,
  text,
  text
) owner to postgres;
alter function public.record_final_publication_approval(uuid, text, text) owner to postgres;
alter function public.seal_version_for_publication(uuid) owner to postgres;
alter function public.schedule_daily_version(uuid, date, text, text) owner to postgres;
alter function public.publish_daily_schedule(uuid) owner to postgres;
alter function public.withdraw_published_version(uuid, text) owner to postgres;
alter function public.create_correction_draft(uuid, text, jsonb) owner to postgres;

revoke all on function private.sha256_hex(text) from public, anon, authenticated;
revoke all on function private.assert_active_admin_role(public.admin_role_code, text)
  from public, anon, authenticated;
revoke all on function private.required_role_for_review_scope(public.review_scope)
  from public, anon, authenticated;
revoke all on function private.is_eligible_reviewer(
  uuid,
  public.admin_role_code,
  public.review_scope,
  text
) from public, anon, authenticated;
revoke all on function private.current_reviewer_for_scope(public.review_scope, text)
  from public, anon, authenticated;
revoke all on function private.current_final_approver() from public, anon, authenticated;
revoke all on function private.version_input_snapshot(uuid) from public, anon, authenticated;
revoke all on function private.current_version_draft_checksum(uuid)
  from public, anon, authenticated;
revoke all on function private.publication_snapshot(uuid) from public, anon, authenticated;
revoke all on function private.has_current_approved_review(uuid, public.review_scope, text)
  from public, anon, authenticated;
revoke all on function private.has_current_final_approval(uuid) from public, anon, authenticated;
revoke all on function private.current_approved_reviewer_count(uuid)
  from public, anon, authenticated;
revoke all on function private.assert_version_publication_eligible(uuid)
  from public, anon, authenticated;
revoke all on function private.assert_sealed_version_integrity(uuid)
  from public, anon, authenticated;
revoke all on function private.assert_daily_feed_eligible(uuid, text)
  from public, anon, authenticated;
revoke all on function private.record_workflow_event(
  uuid,
  uuid,
  text,
  public.content_workflow_status,
  public.content_workflow_status,
  text,
  text
) from public, anon, authenticated;
revoke all on function private.sync_item_workflow_status(uuid, public.content_workflow_status)
  from public, anon, authenticated;
revoke all on function private.prevent_sealed_version_mutation()
  from public, anon, authenticated;
revoke all on function private.prevent_sealed_version_graph_mutation()
  from public, anon, authenticated;
revoke all on function private.prevent_workflow_event_mutation()
  from public, anon, authenticated;

revoke all on function public.advance_content_workflow(
  uuid,
  public.content_workflow_status,
  text
) from public, anon, authenticated;
revoke all on function public.mark_version_human_reviewed(uuid)
  from public, anon, authenticated;
revoke all on function public.record_content_review(
  uuid,
  public.review_scope,
  text,
  text,
  text
) from public, anon, authenticated;
revoke all on function public.record_final_publication_approval(uuid, text, text)
  from public, anon, authenticated;
revoke all on function public.seal_version_for_publication(uuid)
  from public, anon, authenticated;
revoke all on function public.schedule_daily_version(uuid, date, text, text)
  from public, anon, authenticated;
revoke all on function public.publish_daily_schedule(uuid)
  from public, anon, authenticated;
revoke all on function public.withdraw_published_version(uuid, text)
  from public, anon, authenticated;
revoke all on function public.create_correction_draft(uuid, text, jsonb)
  from public, anon, authenticated;

grant execute on function public.advance_content_workflow(
  uuid,
  public.content_workflow_status,
  text
) to authenticated;
grant execute on function public.mark_version_human_reviewed(uuid) to authenticated;
grant execute on function public.record_content_review(
  uuid,
  public.review_scope,
  text,
  text,
  text
) to authenticated;
grant execute on function public.record_final_publication_approval(uuid, text, text)
  to authenticated;
grant execute on function public.seal_version_for_publication(uuid) to authenticated;
grant execute on function public.schedule_daily_version(uuid, date, text, text)
  to authenticated;
grant execute on function public.publish_daily_schedule(uuid) to authenticated;
grant execute on function public.withdraw_published_version(uuid, text)
  to authenticated;
grant execute on function public.create_correction_draft(uuid, text, jsonb)
  to authenticated;
