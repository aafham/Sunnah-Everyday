begin;

select * from no_plan();

select has_table('public', table_name, format('public.%I exists', table_name))
from unnest(array[
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
]::text[]) as required_tables(table_name);

select has_table('public', 'sunnah_item_tags', 'public.sunnah_item_tags exists');

select ok(
  exists (
    select 1
    from pg_type type_row
    join pg_namespace namespace_row on namespace_row.oid = type_row.typnamespace
    where namespace_row.nspname = 'public'
      and type_row.typname = type_name
      and type_row.typtype = 'e'
  ),
  format('public.%I enum exists', type_name)
)
from unnest(array[
  'admin_role_code',
  'source_permission_status',
  'source_display_mode',
  'source_type',
  'hadith_grade',
  'practice_classification',
  'prophetic_form',
  'content_workflow_status',
  'review_scope'
]::text[]) as required_types(type_name);

select is(
  enum_range(null::public.hadith_grade)::text[],
  array['SAHIH', 'HASAN', 'DAIF', 'VERY_WEAK', 'FABRICATED', 'DISPUTED', 'UNGRADED', 'NOT_APPLICABLE']::text[],
  'hadith grades retain every required policy value'
);

select is(
  enum_range(null::public.content_workflow_status)::text[],
  array[
    'DRAFT',
    'RESEARCHED',
    'HADITH_REVIEW_PENDING',
    'HADITH_VERIFIED',
    'FIQH_REVIEW_PENDING',
    'FIQH_REVIEWED',
    'LANGUAGE_REVIEW_PENDING',
    'LANGUAGE_REVIEWED',
    'FINAL_APPROVAL_PENDING',
    'APPROVED',
    'SCHEDULED',
    'PUBLISHED',
    'CORRECTION_PENDING',
    'CORRECTED',
    'SUSPENDED',
    'WITHDRAWN',
    'ARCHIVED'
  ]::text[],
  'workflow states retain every required policy value'
);

select has_column('public', 'sunnah_items', column_name, format('sunnah_items.%I exists', column_name))
from unnest(array[
  'id',
  'slug',
  'category_id',
  'content_type',
  'classification',
  'prophetic_form',
  'current_version_id',
  'workflow_status',
  'created_by',
  'created_at',
  'updated_at'
]::text[]) as required_columns(column_name);

select has_column('public', 'sunnah_versions', column_name, format('sunnah_versions.%I exists', column_name))
from unnest(array[
  'sunnah_item_id',
  'version_number',
  'title_ms',
  'title_en',
  'summary_ms',
  'summary_en',
  'practical_steps_ms',
  'practical_steps_en',
  'when_to_practise_ms',
  'when_to_practise_en',
  'context_note_ms',
  'context_note_en',
  'misunderstanding_note_ms',
  'misunderstanding_note_en',
  'legal_classification_note_ms',
  'legal_classification_note_en',
  'source_rights_status',
  'content_checksum',
  'immutable_after_publish'
]::text[]) as required_columns(column_name);

select ok(
  exists (
    select 1
    from pg_constraint
    where conname = constraint_name
      and contype in ('f', 'u', 'p')
  ),
  format('%I integrity constraint exists', constraint_name)
)
from unnest(array[
  'sources_current_permission_belongs_to_source_fkey',
  'sunnah_items_current_version_belongs_to_item_fkey',
  'content_reports_version_belongs_to_item_fkey',
  'corrections_from_version_belongs_to_item_fkey',
  'corrections_to_version_belongs_to_item_fkey',
  'corrections_report_belongs_to_item_fkey',
  'content_withdrawals_version_belongs_to_item_fkey',
  'publication_events_version_belongs_to_item_fkey',
  'sunnah_versions_sunnah_item_id_version_number_key',
  'daily_schedule_local_date_timezone_scope_locale_key'
]::text[]) as required_constraints(constraint_name);

select ok(to_regclass('public.bookmarks') is null, 'no backend bookmarks table exists');
select ok(to_regclass('public.reflections') is null, 'no backend reflections table exists');

select ok(
  relrowsecurity and relforcerowsecurity,
  format('RLS is enabled and forced on public.%I', table_name)
)
from unnest(array[
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
]::text[]) as secured_tables(table_name)
join pg_class class_row on class_row.relname = table_name
join pg_namespace namespace_row on namespace_row.oid = class_row.relnamespace
  and namespace_row.nspname = 'public';

-- The BE-01 migration itself verifies the temporary zero-policy/no-privilege
-- baseline. Later tasks intentionally add narrowly scoped policies, so this
-- persistent test checks that RLS remains forced rather than freezing BE-01.

insert into public.sunnah_items (slug, content_type)
values ('schema-constraint-test', 'STRUCTURAL_TEST');

select throws_ok(
  $$
    insert into public.sunnah_items (slug, content_type)
    values ('schema-constraint-test', 'STRUCTURAL_TEST')
  $$,
  '23505',
  null,
  'duplicate content slugs are rejected'
);

insert into public.sunnah_versions (sunnah_item_id, version_number)
select id, 1
from public.sunnah_items
where slug = 'schema-constraint-test';

insert into public.sunnah_items (slug, content_type)
values ('schema-constraint-second', 'STRUCTURAL_TEST');

insert into public.sunnah_versions (sunnah_item_id, version_number)
select id, 1
from public.sunnah_items
where slug = 'schema-constraint-second';

set constraints sunnah_items_current_version_belongs_to_item_fkey immediate;

select throws_ok(
  $$
    update public.sunnah_items
    set current_version_id = (
      select version_row.id
      from public.sunnah_versions version_row
      join public.sunnah_items item_row on item_row.id = version_row.sunnah_item_id
      where item_row.slug = 'schema-constraint-second'
    )
    where slug = 'schema-constraint-test'
  $$,
  '23503',
  null,
  'a content item cannot point at another item''s version'
);

select throws_ok(
  $$
    insert into public.sunnah_versions (sunnah_item_id, version_number)
    select id, 1
    from public.sunnah_items
    where slug = 'schema-constraint-test'
  $$,
  '23505',
  null,
  'duplicate version numbers are rejected'
);

insert into public.content_reports (
  sunnah_item_id,
  version_id,
  report_category,
  report_body
)
select item_row.id, version_row.id, 'STRUCTURAL_TEST', 'Structural test only.'
from public.sunnah_items item_row
join public.sunnah_versions version_row on version_row.sunnah_item_id = item_row.id
where item_row.slug = 'schema-constraint-second';

set constraints corrections_report_belongs_to_item_fkey immediate;

select throws_ok(
  $$
    insert into public.corrections (
      sunnah_item_id,
      from_version_id,
      report_id,
      reason
    )
    values (
      (
        select id
        from public.sunnah_items
        where slug = 'schema-constraint-test'
      ),
      (
        select version_row.id
        from public.sunnah_versions version_row
        join public.sunnah_items item_row on item_row.id = version_row.sunnah_item_id
        where item_row.slug = 'schema-constraint-test'
      ),
      (
        select report_row.id
        from public.content_reports report_row
        join public.sunnah_items item_row on item_row.id = report_row.sunnah_item_id
        where item_row.slug = 'schema-constraint-second'
      ),
      'STRUCTURAL_TEST'
    )
  $$,
  '23503',
  null,
  'a correction cannot reference a report from another content item'
);

insert into public.supported_locales (code, native_name, english_name)
values ('zz', 'Schema Test', 'Schema Test');

insert into public.daily_schedule (
  local_date,
  timezone_scope,
  version_id,
  locale,
  schedule_status
)
select date '2099-01-01', 'Etc/UTC', version_row.id, 'zz', 'STRUCTURAL_TEST'
from public.sunnah_versions version_row
join public.sunnah_items item_row on item_row.id = version_row.sunnah_item_id
where item_row.slug = 'schema-constraint-test';

select throws_ok(
  $$
    insert into public.daily_schedule (
      local_date,
      timezone_scope,
      version_id,
      locale,
      schedule_status
    )
    select date '2099-01-01', 'Etc/UTC', version_row.id, 'zz', 'STRUCTURAL_TEST'
    from public.sunnah_versions version_row
    join public.sunnah_items item_row on item_row.id = version_row.sunnah_item_id
    where item_row.slug = 'schema-constraint-test'
  $$,
  '23505',
  null,
  'duplicate daily schedule slots are rejected'
);

select throws_ok(
  $$select 'NOT_A_GRADE'::public.hadith_grade$$,
  '22P02',
  null,
  'unknown narration grades are rejected'
);

select * from finish();

rollback;
