-- BE-01 delivery/audit structures and a deny-by-default access baseline.
-- This is intentionally not a publication API: BE-02 through BE-05 add the
-- role policies, publication gate, bundle contract and audit automation.

create table public.supported_locales (
  code text primary key check (code ~ '^[a-z]{2}(?:-[A-Z]{2})?$'),
  native_name text not null check (char_length(btrim(native_name)) > 0),
  english_name text not null check (char_length(btrim(english_name)) > 0),
  fallback_locale_code text references public.supported_locales (code) on delete restrict,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.reviewer_scopes
  add constraint reviewer_scopes_locale_code_fkey
  foreign key (locale_code)
  references public.supported_locales (code)
  on delete restrict;

alter table public.daily_schedule
  add constraint daily_schedule_locale_fkey
  foreign key (locale)
  references public.supported_locales (code)
  on delete restrict;

create table public.public_content_bundles (
  id uuid primary key default gen_random_uuid(),
  locale text not null references public.supported_locales (code) on delete restrict,
  bundle_version integer not null check (bundle_version > 0),
  bundle_status text not null default 'DRAFT' check (char_length(btrim(bundle_status)) > 0),
  content_checksum text check (content_checksum is null or content_checksum ~ '^[a-f0-9]{64}$'),
  storage_path text check (storage_path is null or char_length(btrim(storage_path)) > 0),
  generated_at timestamptz,
  published_at timestamptz,
  invalidated_at timestamptz,
  created_by uuid references public.admin_profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (locale, bundle_version),
  check (published_at is null or generated_at is not null),
  check (invalidated_at is null or published_at is not null)
);

create table public.publication_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null check (char_length(btrim(event_type)) > 0),
  sunnah_item_id uuid references public.sunnah_items (id) on delete restrict,
  version_id uuid,
  bundle_id uuid references public.public_content_bundles (id) on delete restrict,
  actor_id uuid references public.admin_profiles (id) on delete restrict,
  reason text,
  event_metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  check (version_id is null or sunnah_item_id is not null)
);

alter table public.publication_events
  add constraint publication_events_version_belongs_to_item_fkey
  foreign key (version_id, sunnah_item_id)
  references public.sunnah_versions (id, sunnah_item_id)
  deferrable initially deferred;

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.admin_profiles (id) on delete restrict,
  action text not null check (char_length(btrim(action)) > 0),
  entity_type text not null check (char_length(btrim(entity_type)) > 0),
  entity_id uuid,
  before_snapshot jsonb,
  after_snapshot jsonb,
  reason text,
  created_at timestamptz not null default now()
);

create table public.app_configuration (
  config_key text primary key check (config_key ~ '^[a-z0-9]+(?:[._-][a-z0-9]+)*$'),
  config_value jsonb not null,
  updated_by uuid references public.admin_profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index reviewer_scopes_locale_code_idx on public.reviewer_scopes (locale_code);
create index daily_schedule_locale_idx on public.daily_schedule (locale);
create index supported_locales_fallback_locale_code_idx
  on public.supported_locales (fallback_locale_code);
create index public_content_bundles_created_by_idx on public.public_content_bundles (created_by);
create index publication_events_sunnah_item_id_idx on public.publication_events (sunnah_item_id);
create index publication_events_version_id_idx on public.publication_events (version_id);
create index publication_events_bundle_id_idx on public.publication_events (bundle_id);
create index publication_events_actor_id_idx on public.publication_events (actor_id);
create index audit_logs_actor_id_idx on public.audit_logs (actor_id);
create index audit_logs_entity_idx on public.audit_logs (entity_type, entity_id);
create index app_configuration_updated_by_idx on public.app_configuration (updated_by);

create trigger admin_profiles_set_updated_at
before update on public.admin_profiles
for each row execute function public.set_updated_at();

create trigger roles_set_updated_at
before update on public.roles
for each row execute function public.set_updated_at();

create trigger admin_role_assignments_set_updated_at
before update on public.admin_role_assignments
for each row execute function public.set_updated_at();

create trigger reviewers_set_updated_at
before update on public.reviewers
for each row execute function public.set_updated_at();

create trigger reviewer_qualifications_set_updated_at
before update on public.reviewer_qualifications
for each row execute function public.set_updated_at();

create trigger reviewer_scopes_set_updated_at
before update on public.reviewer_scopes
for each row execute function public.set_updated_at();

create trigger sources_set_updated_at
before update on public.sources
for each row execute function public.set_updated_at();

create trigger source_permissions_set_updated_at
before update on public.source_permissions
for each row execute function public.set_updated_at();

create trigger categories_set_updated_at
before update on public.categories
for each row execute function public.set_updated_at();

create trigger tags_set_updated_at
before update on public.tags
for each row execute function public.set_updated_at();

create trigger sunnah_items_set_updated_at
before update on public.sunnah_items
for each row execute function public.set_updated_at();

create trigger sunnah_versions_set_updated_at
before update on public.sunnah_versions
for each row execute function public.set_updated_at();

create trigger evidence_records_set_updated_at
before update on public.evidence_records
for each row execute function public.set_updated_at();

create trigger content_reviews_set_updated_at
before update on public.content_reviews
for each row execute function public.set_updated_at();

create trigger content_approvals_set_updated_at
before update on public.content_approvals
for each row execute function public.set_updated_at();

create trigger daily_schedule_set_updated_at
before update on public.daily_schedule
for each row execute function public.set_updated_at();

create trigger collections_set_updated_at
before update on public.collections
for each row execute function public.set_updated_at();

create trigger content_reports_set_updated_at
before update on public.content_reports
for each row execute function public.set_updated_at();

create trigger corrections_set_updated_at
before update on public.corrections
for each row execute function public.set_updated_at();

create trigger content_withdrawals_set_updated_at
before update on public.content_withdrawals
for each row execute function public.set_updated_at();

create trigger supported_locales_set_updated_at
before update on public.supported_locales
for each row execute function public.set_updated_at();

create trigger public_content_bundles_set_updated_at
before update on public.public_content_bundles
for each row execute function public.set_updated_at();

create trigger app_configuration_set_updated_at
before update on public.app_configuration
for each row execute function public.set_updated_at();

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'admin_profiles',
    'roles',
    'admin_role_assignments',
    'reviewers',
    'reviewer_qualifications',
    'reviewer_scopes',
    'sources',
    'source_permissions',
    'categories',
    'tags',
    'sunnah_items',
    'sunnah_versions',
    'sunnah_item_tags',
    'evidence_records',
    'version_evidences',
    'content_reviews',
    'content_approvals',
    'daily_schedule',
    'collections',
    'collection_items',
    'corrections',
    'content_withdrawals',
    'content_reports',
    'public_content_bundles',
    'publication_events',
    'audit_logs',
    'app_configuration',
    'supported_locales'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);
    execute format('alter table public.%I force row level security', table_name);
    execute format('revoke all on table public.%I from public, anon, authenticated', table_name);
  end loop;
end;
$$;

do $$
declare
  table_name text;
  privilege_name text;
  rls_is_forced boolean;
begin
  foreach table_name in array array[
    'admin_profiles',
    'roles',
    'admin_role_assignments',
    'reviewers',
    'reviewer_qualifications',
    'reviewer_scopes',
    'sources',
    'source_permissions',
    'categories',
    'tags',
    'sunnah_items',
    'sunnah_versions',
    'sunnah_item_tags',
    'evidence_records',
    'version_evidences',
    'content_reviews',
    'content_approvals',
    'daily_schedule',
    'collections',
    'collection_items',
    'corrections',
    'content_withdrawals',
    'content_reports',
    'public_content_bundles',
    'publication_events',
    'audit_logs',
    'app_configuration',
    'supported_locales'
  ]
  loop
    select relrowsecurity and relforcerowsecurity
    into rls_is_forced
    from pg_class
    where oid = format('public.%I', table_name)::regclass;

    if coalesce(rls_is_forced, false) is not true then
      raise exception 'BE-01 must force RLS on public.%', table_name;
    end if;

    if exists (
      select 1
      from pg_policies
      where schemaname = 'public'
        and tablename = table_name
    ) then
      raise exception 'BE-01 must not define a policy on public.%', table_name;
    end if;

    foreach privilege_name in array array['select', 'insert', 'update', 'delete']
    loop
      if has_table_privilege('anon', format('public.%I', table_name), privilege_name)
        or has_table_privilege(
          'authenticated',
          format('public.%I', table_name),
          privilege_name
        ) then
        raise exception 'BE-01 must not grant % on public.% to anon/authenticated',
          privilege_name,
          table_name;
      end if;
    end loop;
  end loop;
end;
$$;
