-- BE-01 identity, reviewer, source-rights and taxonomy structures.
-- No role, reviewer, source, permission, category or tag records are seeded.

create table public.admin_profiles (
  id uuid primary key references auth.users (id) on delete restrict,
  display_name text not null check (char_length(btrim(display_name)) between 1 and 120),
  public_display_name text check (
    public_display_name is null
    or char_length(btrim(public_display_name)) between 1 and 120
  ),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.roles (
  code public.admin_role_code primary key,
  description text not null check (char_length(btrim(description)) > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.admin_role_assignments (
  id uuid primary key default gen_random_uuid(),
  admin_profile_id uuid not null references public.admin_profiles (id) on delete restrict,
  role_code public.admin_role_code not null references public.roles (code) on delete restrict,
  assigned_by uuid references public.admin_profiles (id) on delete restrict,
  assigned_at timestamptz not null default now(),
  revoked_at timestamptz,
  revoked_by uuid references public.admin_profiles (id) on delete restrict,
  reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (revoked_at is null or revoked_at >= assigned_at)
);

create unique index admin_role_assignments_one_active_role_idx
  on public.admin_role_assignments (admin_profile_id, role_code)
  where revoked_at is null;

create table public.reviewers (
  id uuid primary key default gen_random_uuid(),
  reviewer_code text not null unique check (char_length(btrim(reviewer_code)) between 1 and 80),
  admin_profile_id uuid unique references public.admin_profiles (id) on delete restrict,
  public_display_name text not null check (
    char_length(btrim(public_display_name)) between 1 and 120
  ),
  internal_reference text,
  is_active boolean not null default false,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (not is_active or verified_at is not null)
);

create table public.reviewer_qualifications (
  id uuid primary key default gen_random_uuid(),
  reviewer_id uuid not null references public.reviewers (id) on delete restrict,
  qualification_type text not null check (char_length(btrim(qualification_type)) > 0),
  specialism text not null check (char_length(btrim(specialism)) > 0),
  evidence_reference text not null check (char_length(btrim(evidence_reference)) > 0),
  verified_by uuid references public.admin_profiles (id) on delete restrict,
  valid_from date,
  expires_at date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (expires_at is null or valid_from is null or expires_at >= valid_from)
);

create table public.reviewer_scopes (
  id uuid primary key default gen_random_uuid(),
  reviewer_id uuid not null references public.reviewers (id) on delete restrict,
  review_scope public.review_scope not null,
  locale_code text,
  scope_note text,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index reviewer_scopes_unique_scope_idx
  on public.reviewer_scopes (reviewer_id, review_scope, coalesce(locale_code, ''));

create table public.sources (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique check (char_length(btrim(stable_key)) between 1 and 120),
  source_name text not null check (char_length(btrim(source_name)) > 0),
  owner_name text not null check (char_length(btrim(owner_name)) > 0),
  source_type public.source_type not null,
  source_url text check (source_url is null or source_url ~ '^https?://'),
  bibliographic_locator text,
  edition text,
  language_code text not null check (char_length(btrim(language_code)) > 0),
  accessed_at date not null,
  reviewed_at date not null,
  current_permission_id uuid,
  created_by uuid references public.admin_profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (reviewed_at >= accessed_at)
);

create table public.source_permissions (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references public.sources (id) on delete restrict,
  revision_number integer not null check (revision_number > 0),
  permission_status public.source_permission_status not null default 'UNKNOWN',
  display_mode public.source_display_mode not null default 'LINK_ONLY',
  rights_basis text not null check (char_length(btrim(rights_basis)) > 0),
  licence text,
  permission_scope text not null check (char_length(btrim(permission_scope)) > 0),
  document_reference text,
  usage_notes text not null check (char_length(btrim(usage_notes)) > 0),
  attribution_text text,
  accessed_at date not null,
  reviewed_at date not null,
  expires_at date,
  reviewed_by uuid not null references public.admin_profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (source_id, revision_number),
  unique (id, source_id),
  check (reviewed_at >= accessed_at),
  check (expires_at is null or expires_at >= reviewed_at),
  check (
    display_mode <> 'LICENSED_CONTENT'
    or permission_status in ('GRANTED', 'PUBLIC_LICENSE')
  )
);

alter table public.sources
  add constraint sources_current_permission_belongs_to_source_fkey
  foreign key (current_permission_id, id)
  references public.source_permissions (id, source_id)
  deferrable initially deferred;

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  title_ms text,
  title_en text,
  parent_id uuid references public.categories (id) on delete restrict,
  sort_order integer not null default 0 check (sort_order >= 0),
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tags (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  title_ms text,
  title_en text,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index admin_role_assignments_admin_profile_id_idx
  on public.admin_role_assignments (admin_profile_id);
create index admin_role_assignments_assigned_by_idx
  on public.admin_role_assignments (assigned_by);
create index admin_role_assignments_revoked_by_idx
  on public.admin_role_assignments (revoked_by);
create index reviewer_qualifications_reviewer_id_idx
  on public.reviewer_qualifications (reviewer_id);
create index reviewer_qualifications_verified_by_idx
  on public.reviewer_qualifications (verified_by);
create index reviewer_scopes_reviewer_id_idx
  on public.reviewer_scopes (reviewer_id);
create index sources_created_by_idx on public.sources (created_by);
create index sources_current_permission_id_idx on public.sources (current_permission_id);
create index source_permissions_source_id_idx on public.source_permissions (source_id);
create index source_permissions_reviewed_by_idx on public.source_permissions (reviewed_by);
create index categories_parent_id_idx on public.categories (parent_id);
