begin;

select * from no_plan();

-- BE-03 does not seed any human or religious-content data. These transaction-
-- scoped rows use structural labels only and roll back after the test run.
select is(
  (select count(*) from public.sunnah_items),
  0::bigint,
  'BE-03 starts without seeded content records'
);

select ok(
  to_regprocedure('public.advance_content_workflow(uuid,public.content_workflow_status,text)')
    is not null,
  'the narrow workflow transition RPC exists'
);

select ok(
  to_regprocedure('public.seal_version_for_publication(uuid)') is not null
  and to_regprocedure('public.schedule_daily_version(uuid,date,text,text)') is not null
  and to_regprocedure('public.publish_daily_schedule(uuid)') is not null,
  'the narrow publication RPCs exist'
);

select ok(
  to_regprocedure('private.assert_version_publication_eligible(uuid)') is not null
  and to_regprocedure('private.assert_daily_feed_eligible(uuid,text)') is not null
  and to_regprocedure('private.current_version_draft_checksum(uuid)') is not null,
  'private publication gate helpers exist'
);

select ok(
  (
    select class_row.relrowsecurity and class_row.relforcerowsecurity
    from pg_class as class_row
    where class_row.oid = 'public.version_sources'::regclass
  )
  and (
    select class_row.relrowsecurity and class_row.relforcerowsecurity
    from pg_class as class_row
    where class_row.oid = 'public.version_locale_states'::regclass
  )
  and (
    select class_row.relrowsecurity and class_row.relforcerowsecurity
    from pg_class as class_row
    where class_row.oid = 'public.content_workflow_events'::regclass
  ),
  'new BE-03 tables retain forced RLS'
);

select ok(
  not has_table_privilege('authenticated', 'public.sunnah_versions', 'SELECT')
  and not has_table_privilege('authenticated', 'public.content_reviews', 'INSERT')
  and not has_table_privilege('authenticated', 'public.daily_schedule', 'INSERT')
  and not has_table_privilege('authenticated', 'public.version_sources', 'SELECT'),
  'authenticated users receive no broad content, review, schedule or source-table grant'
);

select is(
  (
    select count(*)::bigint
    from (
      values
        ('public.advance_content_workflow(uuid,public.content_workflow_status,text)'::regprocedure),
        ('public.mark_version_human_reviewed(uuid)'::regprocedure),
        ('public.record_content_review(uuid,public.review_scope,text,text,text)'::regprocedure),
        ('public.record_final_publication_approval(uuid,text,text)'::regprocedure),
        ('public.seal_version_for_publication(uuid)'::regprocedure),
        ('public.schedule_daily_version(uuid,date,text,text)'::regprocedure),
        ('public.publish_daily_schedule(uuid)'::regprocedure),
        ('public.withdraw_published_version(uuid,text)'::regprocedure),
        ('public.create_correction_draft(uuid,text,jsonb)'::regprocedure)
    ) as expected(procedure)
    where not has_function_privilege('anon', expected.procedure::oid, 'EXECUTE')
      and has_function_privilege(
        'authenticated',
        expected.procedure::oid,
        'EXECUTE'
      )
  ),
  9::bigint,
  'only authenticated callers can execute every narrow workflow RPC'
);

select is(
  (
    select count(*)::bigint
    from (
      values
        ('public.advance_content_workflow(uuid,public.content_workflow_status,text)'::regprocedure),
        ('public.mark_version_human_reviewed(uuid)'::regprocedure),
        ('public.record_content_review(uuid,public.review_scope,text,text,text)'::regprocedure),
        ('public.record_final_publication_approval(uuid,text,text)'::regprocedure),
        ('public.seal_version_for_publication(uuid)'::regprocedure),
        ('public.schedule_daily_version(uuid,date,text,text)'::regprocedure),
        ('public.publish_daily_schedule(uuid)'::regprocedure),
        ('public.withdraw_published_version(uuid,text)'::regprocedure),
        ('public.create_correction_draft(uuid,text,jsonb)'::regprocedure)
    ) as expected(procedure)
    join pg_proc as procedure_row
      on procedure_row.oid = expected.procedure::oid
    where procedure_row.prosecdef
      and coalesce(array_to_string(procedure_row.proconfig, ','), '')
        ~ '(^|,)search_path='
  ),
  9::bigint,
  'every narrow workflow RPC is security definer with an explicit search path'
);

insert into auth.users (id, email, role, aud, created_at, updated_at)
values
  (
    '20000000-0000-4000-8000-000000000001',
    'workflow-author@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    'workflow-content-admin@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    'workflow-hadith-reviewer@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '20000000-0000-4000-8000-000000000004',
    'workflow-fiqh-reviewer@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '20000000-0000-4000-8000-000000000005',
    'workflow-language-reviewer@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '20000000-0000-4000-8000-000000000006',
    'workflow-publisher@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '20000000-0000-4000-8000-000000000007',
    'workflow-forged@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '20000000-0000-4000-8000-000000000008',
    'workflow-researcher-only@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  );

insert into public.admin_profiles (id, display_name, public_display_name, is_active)
values
  ('20000000-0000-4000-8000-000000000001', 'Structural author', 'Structural author', true),
  ('20000000-0000-4000-8000-000000000002', 'Structural content admin', 'Structural content admin', true),
  ('20000000-0000-4000-8000-000000000003', 'Structural source reviewer', 'Structural source reviewer', true),
  ('20000000-0000-4000-8000-000000000004', 'Structural fiqh reviewer', 'Structural fiqh reviewer', true),
  ('20000000-0000-4000-8000-000000000005', 'Structural language reviewer', 'Structural language reviewer', true),
  ('20000000-0000-4000-8000-000000000006', 'Structural publisher', 'Structural publisher', true),
  ('20000000-0000-4000-8000-000000000008', 'Structural researcher only', 'Structural researcher only', true);

insert into public.admin_role_assignments (
  admin_profile_id,
  role_code,
  assigned_by,
  assigned_at,
  reason
)
values
  (
    '20000000-0000-4000-8000-000000000001',
    'RESEARCHER',
    '20000000-0000-4000-8000-000000000001',
    now(),
    'Structural workflow fixture.'
  ),
  (
    '20000000-0000-4000-8000-000000000001',
    'PUBLISHER',
    '20000000-0000-4000-8000-000000000001',
    now(),
    'Structural self-approval denial fixture.'
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    'CONTENT_ADMIN',
    '20000000-0000-4000-8000-000000000001',
    now(),
    'Structural provenance fixture.'
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    'HADITH_REVIEWER',
    '20000000-0000-4000-8000-000000000001',
    now(),
    'Structural source-review fixture.'
  ),
  (
    '20000000-0000-4000-8000-000000000004',
    'FIQH_REVIEWER',
    '20000000-0000-4000-8000-000000000001',
    now(),
    'Structural fiqh-review fixture.'
  ),
  (
    '20000000-0000-4000-8000-000000000005',
    'LANGUAGE_EDITOR',
    '20000000-0000-4000-8000-000000000001',
    now(),
    'Structural language-review fixture.'
  ),
  (
    '20000000-0000-4000-8000-000000000006',
    'PUBLISHER',
    '20000000-0000-4000-8000-000000000001',
    now(),
    'Structural publication fixture.'
  ),
  (
    '20000000-0000-4000-8000-000000000008',
    'RESEARCHER',
    '20000000-0000-4000-8000-000000000001',
    now(),
    'Structural researcher-only denial fixture.'
  );

insert into public.reviewers (
  id,
  reviewer_code,
  admin_profile_id,
  public_display_name,
  is_active,
  verified_at
)
values
  (
    '21000000-0000-4000-8000-000000000001',
    'STRUCTURAL_AUTHOR_PUBLISHER',
    '20000000-0000-4000-8000-000000000001',
    'Structural author publisher',
    true,
    now()
  ),
  (
    '21000000-0000-4000-8000-000000000003',
    'STRUCTURAL_SOURCE_REVIEWER',
    '20000000-0000-4000-8000-000000000003',
    'Structural source reviewer',
    true,
    now()
  ),
  (
    '21000000-0000-4000-8000-000000000004',
    'STRUCTURAL_FIQH_REVIEWER',
    '20000000-0000-4000-8000-000000000004',
    'Structural fiqh reviewer',
    true,
    now()
  ),
  (
    '21000000-0000-4000-8000-000000000005',
    'STRUCTURAL_LANGUAGE_REVIEWER',
    '20000000-0000-4000-8000-000000000005',
    'Structural language reviewer',
    true,
    now()
  ),
  (
    '21000000-0000-4000-8000-000000000006',
    'STRUCTURAL_PUBLISHER',
    '20000000-0000-4000-8000-000000000006',
    'Structural publisher',
    true,
    now()
  );

insert into public.reviewer_qualifications (
  reviewer_id,
  qualification_type,
  specialism,
  evidence_reference,
  verified_by,
  valid_from
)
values
  (
    '21000000-0000-4000-8000-000000000001',
    'STRUCTURAL',
    'STRUCTURAL',
    'STRUCTURAL-QUAL-AUTHOR',
    '20000000-0000-4000-8000-000000000002',
    current_date
  ),
  (
    '21000000-0000-4000-8000-000000000003',
    'STRUCTURAL',
    'SOURCE',
    'STRUCTURAL-QUAL-SOURCE',
    '20000000-0000-4000-8000-000000000002',
    current_date
  ),
  (
    '21000000-0000-4000-8000-000000000004',
    'STRUCTURAL',
    'CONTEXT',
    'STRUCTURAL-QUAL-FIQH',
    '20000000-0000-4000-8000-000000000002',
    current_date
  ),
  (
    '21000000-0000-4000-8000-000000000005',
    'STRUCTURAL',
    'LANGUAGE',
    'STRUCTURAL-QUAL-LANGUAGE',
    '20000000-0000-4000-8000-000000000002',
    current_date
  ),
  (
    '21000000-0000-4000-8000-000000000006',
    'STRUCTURAL',
    'PUBLICATION',
    'STRUCTURAL-QUAL-PUBLISHER',
    '20000000-0000-4000-8000-000000000002',
    current_date
  );

insert into public.supported_locales (code, native_name, english_name, is_active)
values
  ('ms', 'Bahasa Melayu', 'Malay', true),
  ('en', 'English', 'English', true);

insert into public.reviewer_scopes (reviewer_id, review_scope, locale_code, is_active)
values
  (
    '21000000-0000-4000-8000-000000000003',
    'SOURCE_HADITH',
    null,
    true
  ),
  (
    '21000000-0000-4000-8000-000000000004',
    'FIQH_CONTEXT',
    null,
    true
  ),
  (
    '21000000-0000-4000-8000-000000000005',
    'LANGUAGE',
    'ms',
    true
  ),
  (
    '21000000-0000-4000-8000-000000000005',
    'LANGUAGE',
    'en',
    true
  );

insert into public.categories (id, slug, title_ms, title_en, is_active)
values (
  '30000000-0000-4000-8000-000000000001',
  'workflow-structural',
  'Structural BM category',
  'Structural English category',
  true
);

insert into public.tags (id, slug, title_ms, title_en, is_active)
values (
  '30000000-0000-4000-8000-000000000002',
  'workflow-structural-tag',
  'Structural BM tag',
  'Structural English tag',
  true
);

insert into public.sources (
  id,
  stable_key,
  source_name,
  owner_name,
  source_type,
  source_url,
  bibliographic_locator,
  edition,
  language_code,
  accessed_at,
  reviewed_at,
  created_by
)
values (
  '40000000-0000-4000-8000-000000000001',
  'workflow-structural-source',
  'Structural source',
  'Structural owner',
  'NARRATION_ASSESSMENT',
  'https://example.invalid/structural-source',
  'STRUCTURAL-LOCATOR',
  'STRUCTURAL-EDITION',
  'en',
  current_date - 2,
  current_date - 2,
  '20000000-0000-4000-8000-000000000001'
);

insert into public.source_permissions (
  id,
  source_id,
  revision_number,
  permission_status,
  display_mode,
  rights_basis,
  permission_scope,
  usage_notes,
  accessed_at,
  reviewed_at,
  reviewed_by
)
values (
  '40000000-0000-4000-8000-000000000002',
  '40000000-0000-4000-8000-000000000001',
  1,
  'LINK_ONLY',
  'LINK_ONLY',
  'STRUCTURAL-RIGHTS-BASIS',
  'STRUCTURAL-SCOPE',
  'STRUCTURAL-USAGE-NOTES',
  current_date - 2,
  current_date - 2,
  '20000000-0000-4000-8000-000000000002'
);

update public.sources
set current_permission_id = '40000000-0000-4000-8000-000000000002'
where id = '40000000-0000-4000-8000-000000000001';

insert into public.sunnah_items (
  id,
  slug,
  category_id,
  content_type,
  classification,
  prophetic_form,
  audience_scope,
  situation_scope,
  created_by
)
values (
  '50000000-0000-4000-8000-000000000001',
  'workflow-structural-item',
  '30000000-0000-4000-8000-000000000001',
  'STRUCTURAL_TEST',
  'ADAB',
  'NOT_APPLICABLE',
  array['STRUCTURAL_AUDIENCE'],
  array['STRUCTURAL_SITUATION'],
  '20000000-0000-4000-8000-000000000001'
);

insert into public.sunnah_item_tags (sunnah_item_id, tag_id)
values (
  '50000000-0000-4000-8000-000000000001',
  '30000000-0000-4000-8000-000000000002'
);

insert into public.sunnah_versions (
  id,
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
  created_by
)
values (
  '60000000-0000-4000-8000-000000000001',
  '50000000-0000-4000-8000-000000000001',
  1,
  'Structural BM title',
  'Structural English title',
  'Structural BM summary',
  'Structural English summary',
  'Structural BM steps',
  'Structural English steps',
  'Structural BM timing',
  'Structural English timing',
  'Structural BM context',
  'Structural English context',
  'Structural BM clarification',
  'Structural English clarification',
  'Structural BM classification',
  'Structural English classification',
  'LINK_ONLY',
  'LINK_ONLY',
  '20000000-0000-4000-8000-000000000001'
);

insert into public.version_sources (
  version_id,
  source_id,
  source_permission_id,
  usage_scope,
  display_mode
)
values (
  '60000000-0000-4000-8000-000000000001',
  '40000000-0000-4000-8000-000000000001',
  '40000000-0000-4000-8000-000000000002',
  'PRIMARY_CONTENT',
  'LINK_ONLY'
);

insert into public.evidence_records (
  id,
  evidence_type,
  translation_ms,
  translation_en,
  hadith_grade,
  grader_name,
  source_id,
  source_permission_id,
  source_locator,
  source_url,
  rights_status,
  display_mode,
  created_by
)
values (
  '70000000-0000-4000-8000-000000000001',
  'STRUCTURAL_EVIDENCE',
  null,
  null,
  'SAHIH',
  'STRUCTURAL-ASSESSOR',
  '40000000-0000-4000-8000-000000000001',
  '40000000-0000-4000-8000-000000000002',
  'STRUCTURAL-LOCATOR',
  'https://example.invalid/structural-evidence',
  'LINK_ONLY',
  'LINK_ONLY',
  '20000000-0000-4000-8000-000000000001'
);

insert into public.version_evidences (version_id, evidence_id, display_order, is_primary)
values (
  '60000000-0000-4000-8000-000000000001',
  '70000000-0000-4000-8000-000000000001',
  0,
  true
);

insert into public.version_locale_states (
  version_id,
  locale,
  is_available,
  unavailable_rationale
)
values
  ('60000000-0000-4000-8000-000000000001', 'ms', true, null),
  ('60000000-0000-4000-8000-000000000001', 'en', true, null);

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000007';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000007","role":"authenticated","app_metadata":{"role":"PUBLISHER"}}';
set local role authenticated;

select throws_ok(
  $$select id from public.sunnah_versions$$,
  '42501',
  null,
  'an unknown authenticated account cannot read content versions'
);

select throws_ok(
  $$
    select public.advance_content_workflow(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'RESEARCHED'::public.content_workflow_status
    )
  $$,
  '42501',
  null,
  'forged JWT metadata cannot advance the workflow'
);

select throws_ok(
  $$
    insert into public.daily_schedule (
      local_date,
      timezone_scope,
      version_id,
      locale,
      schedule_status
    )
    values (
      current_date,
      'Etc/UTC',
      '60000000-0000-4000-8000-000000000001'::uuid,
      'ms',
      'SCHEDULED'
    )
  $$,
  '42501',
  null,
  'authenticated callers cannot bypass the schedule RPC with direct DML'
);

reset role;
set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000008';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000008","role":"authenticated"}';
set local role authenticated;

select throws_ok(
  $$select public.seal_version_for_publication(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  '42501',
  null,
  'a RESEARCHER-only account cannot seal a version for publication'
);

select throws_ok(
  $$select public.schedule_daily_version(
      '60000000-0000-4000-8000-000000000001'::uuid,
      current_date,
      'Etc/UTC',
      'ms'
    )$$,
  '42501',
  null,
  'a RESEARCHER-only account cannot schedule a Daily Feed version'
);

select throws_ok(
  $$select public.publish_daily_schedule(
      '00000000-0000-4000-8000-000000000000'::uuid
    )$$,
  '42501',
  null,
  'a RESEARCHER-only account cannot publish a daily schedule'
);

reset role;
set local role anon;
reset request.jwt.claim.sub;
set local request.jwt.claim.role = 'anon';
set local request.jwt.claims = '{"role":"anon"}';

select throws_ok(
  $$select public.advance_content_workflow(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'RESEARCHED'::public.content_workflow_status
    )$$,
  '42501',
  null,
  'anon cannot execute the workflow RPC'
);

select throws_ok(
  $$select id from public.sunnah_versions$$,
  '42501',
  null,
  'anon cannot read draft content versions'
);

select throws_ok(
  $$select id from public.reviewer_qualifications$$,
  '42501',
  null,
  'anon cannot read reviewer qualification records'
);

select throws_ok(
  $$select id from public.content_workflow_events$$,
  '42501',
  null,
  'anon cannot read workflow events'
);

select throws_ok(
  $$
    insert into public.content_workflow_events (
      version_id,
      actor_id,
      event_type
    )
    values (
      '60000000-0000-4000-8000-000000000001'::uuid,
      '20000000-0000-4000-8000-000000000001'::uuid,
      'UNAUTHORISED_EVENT'
    )
  $$,
  '42501',
  null,
  'anon cannot append workflow events'
);

reset role;
update public.sunnah_versions
set provenance_status = 'DEMO'::public.content_provenance_status
where id = '60000000-0000-4000-8000-000000000001'::uuid;

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000002';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000002","role":"authenticated"}';
set local role authenticated;

select throws_ok(
  $$select public.mark_version_human_reviewed('60000000-0000-4000-8000-000000000001'::uuid)$$,
  'P0001',
  'Development-only versions must be recreated before human review.',
  'a development-only version cannot be promoted through human review'
);

reset role;
update public.sunnah_versions
set provenance_status = 'DRAFT'::public.content_provenance_status
where id = '60000000-0000-4000-8000-000000000001'::uuid;

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000002';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000002","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.mark_version_human_reviewed('60000000-0000-4000-8000-000000000001'::uuid)$$,
  'a content administrator can record human provenance review through the narrow RPC'
);

reset role;
set local timezone = 'UTC';
select set_config(
  'test.workflow_checksum_utc',
  private.current_version_draft_checksum(
    '60000000-0000-4000-8000-000000000001'::uuid
  ),
  true
);
set local timezone = 'Asia/Singapore';
select is(
  private.current_version_draft_checksum(
    '60000000-0000-4000-8000-000000000001'::uuid
  ),
  current_setting('test.workflow_checksum_utc'),
  'draft checksums canonicalize review timestamps across caller timezones'
);
set local timezone = 'UTC';

select throws_ok(
  $$
    update public.content_workflow_events
    set event_type = 'TAMPERED_EVENT'
    where version_id = '60000000-0000-4000-8000-000000000001'::uuid
  $$,
  '55000',
  null,
  'workflow events are append-only and cannot be updated'
);

select throws_ok(
  $$
    delete from public.content_workflow_events
    where version_id = '60000000-0000-4000-8000-000000000001'::uuid
  $$,
  '55000',
  null,
  'workflow events are append-only and cannot be deleted'
);

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000001';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000001","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.advance_content_workflow(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'RESEARCHED'::public.content_workflow_status
    )$$,
  'researcher can move a draft into researched state'
);

select lives_ok(
  $$select public.advance_content_workflow(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'HADITH_REVIEW_PENDING'::public.content_workflow_status
    )$$,
  'researcher can submit researched work for source review'
);

select throws_ok(
  $$select public.record_content_review(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'SOURCE_HADITH'::public.review_scope
    )$$,
  '42501',
  null,
  'a researcher without the source-review role cannot submit source review'
);

reset role;
set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000003';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000003","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.record_content_review(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'SOURCE_HADITH'::public.review_scope
    )$$,
  'qualified source reviewer can record source review'
);

reset role;
select is(
  (
    select workflow_status::text
    from public.sunnah_versions
    where id = '60000000-0000-4000-8000-000000000001'
  ),
  'HADITH_VERIFIED',
  'approved source review advances the version only to hadith verified'
);

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000001';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000001","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.advance_content_workflow(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'FIQH_REVIEW_PENDING'::public.content_workflow_status
    )$$,
  'researcher can submit the version for fiqh/context review'
);

reset role;
set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000004';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000004","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.record_content_review(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'FIQH_CONTEXT'::public.review_scope
    )$$,
  'qualified fiqh/context reviewer can record review'
);

reset role;
set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000001';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000001","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.advance_content_workflow(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'LANGUAGE_REVIEW_PENDING'::public.content_workflow_status
    )$$,
  'researcher can submit the version for language review'
);

reset role;
set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000005';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000005","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.record_content_review(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'LANGUAGE'::public.review_scope,
      'ms'
    )$$,
  'qualified language reviewer can record BM review'
);

reset role;
select is(
  (
    select workflow_status::text
    from public.sunnah_versions
    where id = '60000000-0000-4000-8000-000000000001'
  ),
  'LANGUAGE_REVIEW_PENDING',
  'one language review is insufficient to leave language-review pending state'
);

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000005';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000005","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.record_content_review(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'LANGUAGE'::public.review_scope,
      'en'
    )$$,
  'qualified language reviewer can record English review'
);

reset role;
set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000001';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000001","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.advance_content_workflow(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'FINAL_APPROVAL_PENDING'::public.content_workflow_status
    )$$,
  'researcher can submit a fully language-reviewed version for final approval'
);

select throws_ok(
  $$select public.record_final_publication_approval(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  '42501',
  null,
  'the author cannot self-approve even when assigned publisher role'
);

reset role;
set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000006';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000006","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.record_final_publication_approval(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'independent qualified publisher can record final approval'
);

reset role;
set local timezone = 'UTC';
select set_config(
  'test.workflow_publication_snapshot_utc',
  private.publication_snapshot(
    '60000000-0000-4000-8000-000000000001'::uuid
  )::text,
  true
);
set local timezone = 'Asia/Singapore';
select is(
  private.publication_snapshot(
    '60000000-0000-4000-8000-000000000001'::uuid
  )::text,
  current_setting('test.workflow_publication_snapshot_utc'),
  'publication snapshots canonicalize review and approval timestamps across caller timezones'
);
set local timezone = 'UTC';

update public.source_permissions
set permission_status = 'GRANTED'
where id = '40000000-0000-4000-8000-000000000002'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'Granted source permissions require a written reference.',
  'granted source rights without a written reference block publication'
);

update public.source_permissions
set permission_status = 'PUBLIC_LICENSE'
where id = '40000000-0000-4000-8000-000000000002'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'Public-license source permissions require licence and attribution.',
  'public-license rights without licence and attribution block publication'
);

update public.source_permissions
set permission_status = 'LINK_ONLY'
where id = '40000000-0000-4000-8000-000000000002'::uuid;

update public.evidence_records
set translation_ms = 'STRUCTURAL-LINK-ONLY-TEXT'
where id = '70000000-0000-4000-8000-000000000001'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'Link-only evidence cannot include source text or translations.',
  'link-only evidence text blocks publication'
);

update public.evidence_records
set translation_ms = null
where id = '70000000-0000-4000-8000-000000000001'::uuid;

update public.evidence_records
set rights_status = 'GRANTED'
where id = '70000000-0000-4000-8000-000000000001'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'Evidence is not bound to the version source permission.',
  'evidence rights status must match its bound source permission'
);

update public.evidence_records
set rights_status = 'LINK_ONLY'
where id = '70000000-0000-4000-8000-000000000001'::uuid;

update public.sunnah_versions
set title_ms = 'KANDUNGAN DEMO — TIDAK UNTUK PENERBITAN'
where id = '60000000-0000-4000-8000-000000000001'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'Development-only marker blocks publication.',
  'development-only marker blocks publication eligibility'
);

update public.sunnah_versions
set title_ms = 'Structural BM title'
where id = '60000000-0000-4000-8000-000000000001'::uuid;

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000006';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000006","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.seal_version_for_publication(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'independent publisher can create the server publication seal after every gate passes'
);

reset role;
select ok(
  (
    select publication_snapshot is not null
      and publication_checksum ~ '^[a-f0-9]{64}$'
      and content_checksum = publication_checksum
      and publication_sealed_at is not null
    from public.sunnah_versions
    where id = '60000000-0000-4000-8000-000000000001'
  ),
  'seal stores a server-calculated immutable snapshot and checksum'
);

select is(
  private.current_approved_reviewer_count(
    '60000000-0000-4000-8000-000000000001'::uuid
  ),
  4,
  'the sealed structural version has four distinct current qualified reviewers'
);

update public.tags
set title_ms = 'Changed structural tag'
where id = '30000000-0000-4000-8000-000000000002'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'The server publication seal no longer matches the version inputs.',
  'sealed tag metadata changes fail the generic publication gate'
);

update public.tags
set title_ms = 'Structural BM tag'
where id = '30000000-0000-4000-8000-000000000002'::uuid;

update public.categories
set title_ms = 'Changed structural category'
where id = '30000000-0000-4000-8000-000000000001'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'The server publication seal no longer matches the version inputs.',
  'sealed category metadata changes fail the generic publication gate'
);

update public.categories
set title_ms = 'Structural BM category'
where id = '30000000-0000-4000-8000-000000000001'::uuid;

update public.evidence_records
set narrator = 'Changed structural evidence metadata'
where id = '70000000-0000-4000-8000-000000000001'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'The server publication seal no longer matches the version inputs.',
  'sealed evidence metadata changes fail the generic publication gate'
);

update public.evidence_records
set narrator = null
where id = '70000000-0000-4000-8000-000000000001'::uuid;

update public.sources
set source_url = 'https://example.invalid/changed-structural-source'
where id = '40000000-0000-4000-8000-000000000001'::uuid;

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  'The server publication seal no longer matches the version inputs.',
  'sealed source metadata changes fail the generic publication gate'
);

update public.sources
set source_url = 'https://example.invalid/structural-source'
where id = '40000000-0000-4000-8000-000000000001'::uuid;

select throws_ok(
  $$
    update public.sunnah_versions
    set title_ms = 'Changed structural text'
    where id = '60000000-0000-4000-8000-000000000001'::uuid
  $$,
  '55000',
  null,
  'a sealed version cannot be edited in place'
);

select throws_ok(
  $$
    delete from public.version_sources
    where version_id = '60000000-0000-4000-8000-000000000001'::uuid
  $$,
  '55000',
  null,
  'a sealed version cannot lose its source-permission linkage'
);

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000001';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000001","role":"authenticated"}';
set local role authenticated;

select throws_ok(
  $$select public.schedule_daily_version(
      '60000000-0000-4000-8000-000000000001'::uuid,
      current_date,
      'Etc/UTC',
      'ms'
    )$$,
  '42501',
  null,
  'the author cannot schedule its own approved sealed version'
);

reset role;
set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000006';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000006","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.schedule_daily_version(
      '60000000-0000-4000-8000-000000000001'::uuid,
      current_date,
      'Etc/UTC',
      'ms'
    )$$,
  'independent publisher can schedule only a sealed Daily Feed eligible version'
);

reset role;
select set_config(
  'test.workflow_schedule_id',
  (
    select id::text
    from public.daily_schedule
    where version_id = '60000000-0000-4000-8000-000000000001'::uuid
  ),
  true
);

select throws_ok(
  $$
    insert into public.daily_schedule (
      local_date,
      timezone_scope,
      version_id,
      locale,
      schedule_status
    )
    values (
      current_date,
      'Etc/UTC',
      '60000000-0000-4000-8000-000000000001'::uuid,
      'ms',
      'SCHEDULED'
    )
  $$,
  '23505',
  null,
  'duplicate daily schedule slots are rejected after the publication gate'
);

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000006';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000006","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.publish_daily_schedule(
      current_setting('test.workflow_schedule_id')::uuid
    )$$,
  'independent publisher can publish a currently eligible schedule'
);

reset role;
select ok(
  (
    select schedule_status = 'PUBLISHED'
      and published_at is not null
    from public.daily_schedule
    where id = current_setting('test.workflow_schedule_id')::uuid
  )
  and (
    select workflow_status = 'PUBLISHED'::public.content_workflow_status
      and immutable_after_publish
    from public.sunnah_versions
    where id = '60000000-0000-4000-8000-000000000001'::uuid
  ),
  'publication marks only the sealed version and schedule as published'
);

select lives_ok(
  $outer$
    do $grade_gate$
    declare
      prohibited_grade public.hadith_grade;
    begin
      foreach prohibited_grade in array array[
        'DAIF'::public.hadith_grade,
        'VERY_WEAK'::public.hadith_grade,
        'FABRICATED'::public.hadith_grade,
        'DISPUTED'::public.hadith_grade,
        'UNGRADED'::public.hadith_grade,
        'NOT_APPLICABLE'::public.hadith_grade
      ] loop
        update public.evidence_records
        set hadith_grade = prohibited_grade
        where id = '70000000-0000-4000-8000-000000000001'::uuid;

        begin
          perform private.assert_daily_feed_eligible(
            '60000000-0000-4000-8000-000000000001'::uuid,
            'ms'
          );
          raise exception using
            errcode = 'P0002',
            message = 'A prohibited Daily Feed grade was accepted.';
        exception
          when sqlstate 'P0001' then null;
        end;
      end loop;

      update public.evidence_records
      set hadith_grade = 'SAHIH'::public.hadith_grade
      where id = '70000000-0000-4000-8000-000000000001'::uuid;
    end;
    $grade_gate$;
  $outer$,
  'every prohibited or non-applicable primary grade is blocked from Daily Feed validation'
);

update public.source_permissions
set expires_at = current_date - 1
where id = '40000000-0000-4000-8000-000000000002';

select throws_ok(
  $$select private.assert_version_publication_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid
    )$$,
  'P0001',
  null,
  'expired source rights block publication eligibility'
);

update public.source_permissions
set expires_at = null
where id = '40000000-0000-4000-8000-000000000002';

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000002';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000002","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.create_correction_draft(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'STRUCTURAL-CORRECTION',
      '{"kind":"STRUCTURAL"}'::jsonb
    )$$,
  'content administrator can clone a sealed published version into a fresh correction draft'
);

reset role;
select ok(
  exists (
    select 1
    from public.sunnah_versions as version_row
    where version_row.sunnah_item_id = '50000000-0000-4000-8000-000000000001'::uuid
      and version_row.version_number = 2
      and version_row.workflow_status = 'CORRECTION_PENDING'::public.content_workflow_status
      and version_row.provenance_status = 'NEEDS_REVIEW'::public.content_provenance_status
      and version_row.publication_snapshot is null
  )
  and exists (
    select 1
    from public.corrections as correction_row
    where correction_row.from_version_id = '60000000-0000-4000-8000-000000000001'::uuid
      and correction_row.to_version_id = (
        select id
        from public.sunnah_versions
        where sunnah_item_id = '50000000-0000-4000-8000-000000000001'::uuid
          and version_number = 2
      )
  ),
  'correction retains immutable lineage and starts a new unreviewed version'
);

set local request.jwt.claim.sub = '20000000-0000-4000-8000-000000000006';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"20000000-0000-4000-8000-000000000006","role":"authenticated"}';
set local role authenticated;

select lives_ok(
  $$select public.withdraw_published_version(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'STRUCTURAL-WITHDRAWAL'
    )$$,
  'independent publisher can withdraw a published version through the server action'
);

reset role;
select ok(
  (
    select workflow_status = 'WITHDRAWN'::public.content_workflow_status
    from public.sunnah_versions
    where id = '60000000-0000-4000-8000-000000000001'::uuid
  )
  and (
    select schedule_status = 'WITHDRAWN'
    from public.daily_schedule
    where id = current_setting('test.workflow_schedule_id')::uuid
  ),
  'withdrawal blocks the version and its active daily schedule'
);

select throws_ok(
  $$select private.assert_daily_feed_eligible(
      '60000000-0000-4000-8000-000000000001'::uuid,
      'ms'
    )$$,
  'P0001',
  null,
  'withdrawn content no longer passes Daily Feed eligibility'
);

select * from finish();

rollback;
