-- BE-01 content, evidence and review structures.
-- Publication, approval, immutable-version and Daily Feed gates are deliberately
-- deferred to BE-03; this migration creates no content or review records.

create table public.sunnah_items (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  category_id uuid references public.categories (id) on delete restrict,
  content_type text not null check (char_length(btrim(content_type)) > 0),
  classification public.practice_classification,
  prophetic_form public.prophetic_form,
  audience_scope text[] not null default '{}',
  situation_scope text[] not null default '{}',
  difficulty_level smallint check (difficulty_level between 1 and 5),
  frequency_label text check (frequency_label is null or char_length(btrim(frequency_label)) > 0),
  has_scholarly_difference boolean not null default false,
  is_prophet_specific boolean not null default false,
  requires_medical_note boolean not null default false,
  current_version_id uuid,
  workflow_status public.content_workflow_status not null default 'DRAFT',
  created_by uuid references public.admin_profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.sunnah_versions (
  id uuid primary key default gen_random_uuid(),
  sunnah_item_id uuid not null references public.sunnah_items (id) on delete restrict,
  version_number integer not null check (version_number > 0),
  title_ms text,
  title_en text,
  summary_ms text,
  summary_en text,
  practical_steps_ms text,
  practical_steps_en text,
  when_to_practise_ms text,
  when_to_practise_en text,
  context_note_ms text,
  context_note_en text,
  misunderstanding_note_ms text,
  misunderstanding_note_en text,
  legal_classification_note_ms text,
  legal_classification_note_en text,
  source_rights_status public.source_permission_status not null default 'UNKNOWN',
  display_mode public.source_display_mode not null default 'LINK_ONLY',
  content_checksum text,
  immutable_after_publish boolean not null default false,
  created_by uuid references public.admin_profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (sunnah_item_id, version_number),
  unique (id, sunnah_item_id),
  check (content_checksum is null or content_checksum ~ '^[a-f0-9]{64}$'),
  check (not immutable_after_publish or content_checksum is not null),
  check (
    display_mode <> 'LICENSED_CONTENT'
    or source_rights_status in ('GRANTED', 'PUBLIC_LICENSE')
  )
);

alter table public.sunnah_items
  add constraint sunnah_items_current_version_belongs_to_item_fkey
  foreign key (current_version_id, id)
  references public.sunnah_versions (id, sunnah_item_id)
  deferrable initially deferred;

create table public.sunnah_item_tags (
  sunnah_item_id uuid not null references public.sunnah_items (id) on delete restrict,
  tag_id uuid not null references public.tags (id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (sunnah_item_id, tag_id)
);

create table public.evidence_records (
  id uuid primary key default gen_random_uuid(),
  evidence_type text not null check (char_length(btrim(evidence_type)) > 0),
  arabic_text text,
  translation_ms text,
  translation_en text,
  narrator text,
  collection_name text,
  book_name text,
  chapter_name text,
  reference_number text,
  hadith_grade public.hadith_grade not null default 'UNGRADED',
  grader_name text,
  source_id uuid not null references public.sources (id) on delete restrict,
  source_locator text not null check (char_length(btrim(source_locator)) > 0),
  source_url text check (source_url is null or source_url ~ '^https?://'),
  date_verified date,
  verification_note text,
  rights_status public.source_permission_status not null default 'UNKNOWN',
  created_by uuid references public.admin_profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.version_evidences (
  version_id uuid not null references public.sunnah_versions (id) on delete restrict,
  evidence_id uuid not null references public.evidence_records (id) on delete restrict,
  display_order integer not null default 0 check (display_order >= 0),
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (version_id, evidence_id),
  unique (version_id, display_order)
);

create unique index version_evidences_one_primary_idx
  on public.version_evidences (version_id)
  where is_primary;

create table public.content_reviews (
  id uuid primary key default gen_random_uuid(),
  review_scope public.review_scope not null,
  reviewer_id uuid not null references public.reviewers (id) on delete restrict,
  version_id uuid not null references public.sunnah_versions (id) on delete restrict,
  decision text not null check (char_length(btrim(decision)) > 0),
  notes text,
  reviewed_at timestamptz not null default now(),
  signature_hash text check (signature_hash is null or signature_hash ~ '^[a-f0-9]{64}$'),
  supersedes_review_id uuid references public.content_reviews (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.content_approvals (
  id uuid primary key default gen_random_uuid(),
  version_id uuid not null references public.sunnah_versions (id) on delete restrict,
  reviewer_id uuid not null references public.reviewers (id) on delete restrict,
  approval_type text not null check (char_length(btrim(approval_type)) > 0),
  decision text not null check (char_length(btrim(decision)) > 0),
  notes text,
  approved_at timestamptz not null default now(),
  signature_hash text check (signature_hash is null or signature_hash ~ '^[a-f0-9]{64}$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (version_id, reviewer_id, approval_type)
);

create table public.daily_schedule (
  id uuid primary key default gen_random_uuid(),
  local_date date not null,
  timezone_scope text not null check (char_length(btrim(timezone_scope)) > 0),
  version_id uuid not null references public.sunnah_versions (id) on delete restrict,
  locale text not null check (char_length(btrim(locale)) > 0),
  schedule_status text not null check (char_length(btrim(schedule_status)) > 0),
  scheduled_by uuid references public.admin_profiles (id) on delete restrict,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (local_date, timezone_scope, locale)
);

create table public.collections (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  title_ms text,
  title_en text,
  description_ms text,
  description_en text,
  status text not null default 'DRAFT' check (char_length(btrim(status)) > 0),
  created_by uuid references public.admin_profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.collection_items (
  collection_id uuid not null references public.collections (id) on delete restrict,
  version_id uuid not null references public.sunnah_versions (id) on delete restrict,
  display_order integer not null default 0 check (display_order >= 0),
  created_at timestamptz not null default now(),
  primary key (collection_id, version_id),
  unique (collection_id, display_order)
);

create table public.content_reports (
  id uuid primary key default gen_random_uuid(),
  sunnah_item_id uuid not null references public.sunnah_items (id) on delete restrict,
  version_id uuid,
  report_category text not null check (char_length(btrim(report_category)) > 0),
  report_body text not null check (char_length(btrim(report_body)) between 1 and 4000),
  report_status text not null default 'OPEN' check (char_length(btrim(report_status)) > 0),
  triaged_by uuid references public.admin_profiles (id) on delete restrict,
  triaged_at timestamptz,
  resolution_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, sunnah_item_id),
  check (triaged_at is null or triaged_at >= created_at)
);

alter table public.content_reports
  add constraint content_reports_version_belongs_to_item_fkey
  foreign key (version_id, sunnah_item_id)
  references public.sunnah_versions (id, sunnah_item_id)
  deferrable initially deferred;

create table public.corrections (
  id uuid primary key default gen_random_uuid(),
  sunnah_item_id uuid not null references public.sunnah_items (id) on delete restrict,
  from_version_id uuid not null,
  to_version_id uuid,
  report_id uuid,
  correction_status text not null default 'OPEN' check (char_length(btrim(correction_status)) > 0),
  reason text not null check (char_length(btrim(reason)) > 0),
  diff_summary jsonb not null default '{}'::jsonb,
  created_by uuid references public.admin_profiles (id) on delete restrict,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (to_version_id is null or to_version_id <> from_version_id)
);

alter table public.corrections
  add constraint corrections_from_version_belongs_to_item_fkey
  foreign key (from_version_id, sunnah_item_id)
  references public.sunnah_versions (id, sunnah_item_id)
  deferrable initially deferred,
  add constraint corrections_to_version_belongs_to_item_fkey
  foreign key (to_version_id, sunnah_item_id)
  references public.sunnah_versions (id, sunnah_item_id)
  deferrable initially deferred,
  add constraint corrections_report_belongs_to_item_fkey
  foreign key (report_id, sunnah_item_id)
  references public.content_reports (id, sunnah_item_id)
  deferrable initially deferred;

create table public.content_withdrawals (
  id uuid primary key default gen_random_uuid(),
  sunnah_item_id uuid not null references public.sunnah_items (id) on delete restrict,
  version_id uuid not null,
  reason text not null check (char_length(btrim(reason)) > 0),
  withdrawn_by uuid references public.admin_profiles (id) on delete restrict,
  withdrawn_at timestamptz not null default now(),
  restored_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (restored_at is null or restored_at >= withdrawn_at)
);

alter table public.content_withdrawals
  add constraint content_withdrawals_version_belongs_to_item_fkey
  foreign key (version_id, sunnah_item_id)
  references public.sunnah_versions (id, sunnah_item_id)
  deferrable initially deferred;

create unique index content_withdrawals_one_active_version_idx
  on public.content_withdrawals (version_id)
  where restored_at is null;

create index sunnah_items_category_id_idx on public.sunnah_items (category_id);
create index sunnah_items_created_by_idx on public.sunnah_items (created_by);
create index sunnah_items_current_version_id_idx on public.sunnah_items (current_version_id);
create index sunnah_items_workflow_status_idx on public.sunnah_items (workflow_status);
create index sunnah_versions_sunnah_item_id_idx on public.sunnah_versions (sunnah_item_id);
create index sunnah_versions_created_by_idx on public.sunnah_versions (created_by);
create index sunnah_item_tags_tag_id_idx on public.sunnah_item_tags (tag_id);
create index evidence_records_source_id_idx on public.evidence_records (source_id);
create index evidence_records_created_by_idx on public.evidence_records (created_by);
create index version_evidences_evidence_id_idx on public.version_evidences (evidence_id);
create index content_reviews_reviewer_id_idx on public.content_reviews (reviewer_id);
create index content_reviews_version_id_idx on public.content_reviews (version_id);
create index content_reviews_supersedes_review_id_idx on public.content_reviews (supersedes_review_id);
create index content_approvals_reviewer_id_idx on public.content_approvals (reviewer_id);
create index content_approvals_version_id_idx on public.content_approvals (version_id);
create index daily_schedule_version_id_idx on public.daily_schedule (version_id);
create index daily_schedule_scheduled_by_idx on public.daily_schedule (scheduled_by);
create index collections_created_by_idx on public.collections (created_by);
create index collection_items_version_id_idx on public.collection_items (version_id);
create index content_reports_sunnah_item_id_idx on public.content_reports (sunnah_item_id);
create index content_reports_version_id_idx on public.content_reports (version_id);
create index content_reports_triaged_by_idx on public.content_reports (triaged_by);
create index corrections_sunnah_item_id_idx on public.corrections (sunnah_item_id);
create index corrections_from_version_id_idx on public.corrections (from_version_id);
create index corrections_to_version_id_idx on public.corrections (to_version_id);
create index corrections_report_id_idx on public.corrections (report_id);
create index corrections_created_by_idx on public.corrections (created_by);
create index content_withdrawals_sunnah_item_id_idx on public.content_withdrawals (sunnah_item_id);
create index content_withdrawals_version_id_idx on public.content_withdrawals (version_id);
create index content_withdrawals_withdrawn_by_idx on public.content_withdrawals (withdrawn_by);
