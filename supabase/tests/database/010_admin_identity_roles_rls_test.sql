begin;

select * from no_plan();

select is(
  (select count(*) from public.roles),
  9::bigint,
  'BE-02 seeds exactly the canonical technical role catalogue'
);

select is(
  (
    select array_agg(role_row.code::text order by role_row.code)
    from public.roles as role_row
  ),
  enum_range(null::public.admin_role_code)::text[],
  'the role catalogue exactly matches the defined admin-role enum'
);

select ok(
  (
    select bool_and(char_length(btrim(role_row.description)) > 0)
    from public.roles as role_row
  ),
  'every technical role has a non-empty operational description'
);

select is(
  (select count(*) from public.admin_profiles),
  0::bigint,
  'BE-02 does not seed administrator identities'
);

select is(
  (select count(*) from public.admin_role_assignments),
  0::bigint,
  'BE-02 does not seed administrator assignments'
);

select is(
  (select count(*) from public.reviewers),
  0::bigint,
  'BE-02 does not seed reviewers'
);

select is(
  (select count(*) from public.sources),
  0::bigint,
  'BE-02 does not seed sources'
);

select is(
  (select count(*) from public.sunnah_items),
  0::bigint,
  'BE-02 does not seed religious-content records'
);

select ok(
  to_regnamespace('private') is not null,
  'the private helper schema exists'
);

select ok(
  to_regprocedure('private.is_active_admin()') is not null,
  'private.is_active_admin exists'
);

select ok(
  to_regprocedure('private.has_active_admin_role(public.admin_role_code)') is not null,
  'private.has_active_admin_role exists'
);

select ok(
  (
    select procedure_row.prosecdef
    from pg_proc as procedure_row
    where procedure_row.oid = 'private.is_active_admin()'::regprocedure
  ),
  'is_active_admin is security definer'
);

select ok(
  (
    select procedure_row.prosecdef
    from pg_proc as procedure_row
    where procedure_row.oid =
      'private.has_active_admin_role(public.admin_role_code)'::regprocedure
  ),
  'has_active_admin_role is security definer'
);

select is(
  (
    select procedure_row.provolatile::text
    from pg_proc as procedure_row
    where procedure_row.oid = 'private.is_active_admin()'::regprocedure
  ),
  's',
  'is_active_admin is stable'
);

select is(
  (
    select procedure_row.provolatile::text
    from pg_proc as procedure_row
    where procedure_row.oid =
      'private.has_active_admin_role(public.admin_role_code)'::regprocedure
  ),
  's',
  'has_active_admin_role is stable'
);

select is(
  (
    select pg_get_userbyid(procedure_row.proowner)
    from pg_proc as procedure_row
    where procedure_row.oid = 'private.is_active_admin()'::regprocedure
  ),
  'postgres',
  'is_active_admin is owned by postgres'
);

select is(
  (
    select pg_get_userbyid(procedure_row.proowner)
    from pg_proc as procedure_row
    where procedure_row.oid =
      'private.has_active_admin_role(public.admin_role_code)'::regprocedure
  ),
  'postgres',
  'has_active_admin_role is owned by postgres'
);

select ok(
  exists (
    select 1
    from pg_proc as procedure_row
    where procedure_row.oid = 'private.is_active_admin()'::regprocedure
      and coalesce(array_to_string(procedure_row.proconfig, ','), '')
        ~ '(^|,)search_path='
  ),
  'is_active_admin locks its search path'
);

select ok(
  exists (
    select 1
    from pg_proc as procedure_row
    where procedure_row.oid =
      'private.has_active_admin_role(public.admin_role_code)'::regprocedure
      and coalesce(array_to_string(procedure_row.proconfig, ','), '')
        ~ '(^|,)search_path='
  ),
  'has_active_admin_role locks its search path'
);

select ok(
  not has_schema_privilege('anon', 'private', 'USAGE'),
  'anon cannot use the private helper schema'
);

select ok(
  not has_schema_privilege('authenticated', 'private', 'USAGE'),
  'authenticated cannot use the private helper schema directly'
);

select ok(
  not has_function_privilege(
    'anon',
    'private.is_active_admin()'::regprocedure,
    'EXECUTE'
  ),
  'anon cannot execute is_active_admin'
);

select ok(
  has_function_privilege(
    'authenticated',
    'private.is_active_admin()'::regprocedure,
    'EXECUTE'
  ),
  'authenticated may execute is_active_admin inside a policy'
);

select ok(
  not has_function_privilege(
    'anon',
    'private.has_active_admin_role(public.admin_role_code)'::regprocedure,
    'EXECUTE'
  ),
  'anon cannot execute has_active_admin_role'
);

select ok(
  has_function_privilege(
    'authenticated',
    'private.has_active_admin_role(public.admin_role_code)'::regprocedure,
    'EXECUTE'
  ),
  'authenticated may execute has_active_admin_role inside a policy'
);

select ok(
  (
    select class_row.relrowsecurity and class_row.relforcerowsecurity
    from pg_class as class_row
    where class_row.oid = 'public.admin_profiles'::regclass
  ),
  'RLS remains enabled and forced on admin_profiles'
);

select ok(
  (
    select class_row.relrowsecurity and class_row.relforcerowsecurity
    from pg_class as class_row
    where class_row.oid = 'public.roles'::regclass
  ),
  'RLS remains enabled and forced on roles'
);

select ok(
  (
    select class_row.relrowsecurity and class_row.relforcerowsecurity
    from pg_class as class_row
    where class_row.oid = 'public.admin_role_assignments'::regclass
  ),
  'RLS remains enabled and forced on admin_role_assignments'
);

select is(
  (
    select count(*)
    from pg_policies as policy_row
    where policy_row.schemaname = 'public'
      and policy_row.tablename in (
        'admin_profiles',
        'roles',
        'admin_role_assignments'
      )
  ),
  4::bigint,
  'BE-02 adds exactly the four reviewed identity policies'
);

select ok(
  has_column_privilege(
    'authenticated',
    'public.admin_profiles',
    'id',
    'SELECT'
  ),
  'authenticated may select its profile identifier'
);

select ok(
  has_column_privilege(
    'authenticated',
    'public.admin_profiles',
    'display_name',
    'SELECT, UPDATE'
  ),
  'authenticated may read and update its display name'
);

select ok(
  has_column_privilege(
    'authenticated',
    'public.admin_profiles',
    'public_display_name',
    'SELECT, UPDATE'
  ),
  'authenticated may read and update its public display name'
);

select ok(
  not has_column_privilege(
    'authenticated',
    'public.admin_profiles',
    'is_active',
    'SELECT, UPDATE'
  ),
  'authenticated cannot read or change profile activation state'
);

select ok(
  not has_column_privilege(
    'authenticated',
    'public.admin_profiles',
    'updated_at',
    'SELECT, UPDATE'
  ),
  'authenticated cannot read or change profile timestamps'
);

select ok(
  has_column_privilege('authenticated', 'public.roles', 'code', 'SELECT')
  and has_column_privilege(
    'authenticated',
    'public.roles',
    'description',
    'SELECT'
  ),
  'authenticated receives only role-code and role-description read grants'
);

select ok(
  not has_column_privilege(
    'authenticated',
    'public.roles',
    'created_at',
    'SELECT'
  ),
  'authenticated cannot read role timestamps'
);

select ok(
  has_column_privilege(
    'authenticated',
    'public.admin_role_assignments',
    'role_code',
    'SELECT'
  ),
  'authenticated may read only an allowed role code'
);

select ok(
  not has_column_privilege(
    'authenticated',
    'public.admin_role_assignments',
    'assigned_by',
    'SELECT'
  )
  and not has_column_privilege(
    'authenticated',
    'public.admin_role_assignments',
    'reason',
    'SELECT'
  )
  and not has_column_privilege(
    'authenticated',
    'public.admin_role_assignments',
    'revoked_at',
    'SELECT'
  ),
  'authenticated cannot read assignment metadata or history'
);

select ok(
  not has_table_privilege('authenticated', 'public.admin_profiles', 'SELECT')
  and not has_table_privilege('authenticated', 'public.roles', 'SELECT')
  and not has_table_privilege(
    'authenticated',
    'public.admin_role_assignments',
    'SELECT'
  ),
  'BE-02 uses no broad authenticated table SELECT grants'
);

select ok(
  not has_table_privilege('authenticated', 'public.admin_profiles', 'INSERT')
  and not has_table_privilege('authenticated', 'public.admin_profiles', 'DELETE')
  and not has_table_privilege('authenticated', 'public.roles', 'INSERT')
  and not has_table_privilege('authenticated', 'public.roles', 'UPDATE')
  and not has_table_privilege('authenticated', 'public.roles', 'DELETE')
  and not has_table_privilege(
    'authenticated',
    'public.admin_role_assignments',
    'INSERT'
  )
  and not has_table_privilege(
    'authenticated',
    'public.admin_role_assignments',
    'UPDATE'
  )
  and not has_table_privilege(
    'authenticated',
    'public.admin_role_assignments',
    'DELETE'
  ),
  'no authenticated direct profile, role or assignment provisioning privilege exists'
);

insert into auth.users (id, email, role, aud, created_at, updated_at)
values
  (
    '10000000-0000-4000-8000-000000000001',
    'active-admin@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'peer-admin@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    'inactive-admin@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '10000000-0000-4000-8000-000000000004',
    'roleless-admin@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '10000000-0000-4000-8000-000000000005',
    'revoked-admin@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  ),
  (
    '10000000-0000-4000-8000-000000000006',
    'unknown-admin@fixture.invalid',
    'authenticated',
    'authenticated',
    now(),
    now()
  );

insert into public.admin_profiles (
  id,
  display_name,
  public_display_name,
  is_active
)
values
  (
    '10000000-0000-4000-8000-000000000001',
    'Fixture active administrator',
    'Fixture active public name',
    true
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'Fixture peer administrator',
    'Fixture peer public name',
    true
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    'Fixture inactive administrator',
    'Fixture inactive public name',
    false
  ),
  (
    '10000000-0000-4000-8000-000000000004',
    'Fixture roleless administrator',
    'Fixture roleless public name',
    true
  ),
  (
    '10000000-0000-4000-8000-000000000005',
    'Fixture revoked administrator',
    'Fixture revoked public name',
    true
  );

insert into public.admin_role_assignments (
  admin_profile_id,
  role_code,
  assigned_by,
  assigned_at,
  revoked_at,
  revoked_by,
  reason
)
values
  (
    '10000000-0000-4000-8000-000000000001',
    'RESEARCHER',
    '10000000-0000-4000-8000-000000000001',
    now() - interval '1 minute',
    null,
    null,
    'Fixture-only role assignment.'
  ),
  (
    '10000000-0000-4000-8000-000000000001',
    'SUPER_ADMIN',
    '10000000-0000-4000-8000-000000000001',
    now() - interval '1 minute',
    null,
    null,
    'Fixture-only elevated assignment.'
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'PUBLISHER',
    '10000000-0000-4000-8000-000000000001',
    now() - interval '1 minute',
    null,
    null,
    'Fixture-only peer assignment.'
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    'RESEARCHER',
    '10000000-0000-4000-8000-000000000001',
    now() - interval '1 minute',
    null,
    null,
    'Fixture-only inactive assignment.'
  ),
  (
    '10000000-0000-4000-8000-000000000005',
    'LANGUAGE_EDITOR',
    '10000000-0000-4000-8000-000000000001',
    now() - interval '2 minutes',
    now() - interval '1 minute',
    '10000000-0000-4000-8000-000000000001',
    'Fixture-only revoked assignment.'
  );

set local request.jwt.claim.sub = '10000000-0000-4000-8000-000000000001';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated"}';

select is(
  auth.uid(),
  '10000000-0000-4000-8000-000000000001'::uuid,
  'the active fixture claim resolves to auth.uid()'
);

select is(
  private.is_active_admin(),
  true,
  'the active fixture has an active profile and current role'
);

select is(
  private.has_active_admin_role('RESEARCHER'::public.admin_role_code),
  true,
  'the active fixture has its assigned researcher role'
);

select is(
  private.has_active_admin_role('PUBLISHER'::public.admin_role_code),
  false,
  'the active fixture does not gain an unassigned publisher role'
);

set local role authenticated;

select results_eq(
  $$
    select profile.id::text, profile.display_name, profile.public_display_name
    from public.admin_profiles as profile
    order by profile.id
  $$,
  $$
    values (
      '10000000-0000-4000-8000-000000000001'::text,
      'Fixture active administrator',
      'Fixture active public name'
    )
  $$,
  'an active administrator sees only its own allowed profile fields'
);

select throws_ok(
  $$select * from public.admin_profiles$$,
  '42501',
  null,
  'an active administrator cannot wildcard-read profile state or timestamps'
);

select throws_ok(
  $$select is_active from public.admin_profiles$$,
  '42501',
  null,
  'an active administrator cannot read profile activation state'
);

select lives_ok(
  $$
    update public.admin_profiles
    set
      display_name = 'Fixture active administrator updated',
      public_display_name = 'Fixture active public name updated'
    where id = '10000000-0000-4000-8000-000000000001'::uuid
  $$,
  'an active administrator can update only its own display fields'
);

select results_eq(
  $$
    select profile.display_name, profile.public_display_name
    from public.admin_profiles as profile
  $$,
  $$
    values (
      'Fixture active administrator updated',
      'Fixture active public name updated'
    )
  $$,
  'the own display-field update is visible to the active administrator'
);

select throws_ok(
  $$
    update public.admin_profiles
    set is_active = false
    where id = '10000000-0000-4000-8000-000000000001'::uuid
  $$,
  '42501',
  null,
  'an active administrator cannot deactivate itself'
);

select results_eq(
  $$
    with changed as (
      update public.admin_profiles
      set display_name = 'Cross-profile update blocked'
      where id = '10000000-0000-4000-8000-000000000002'::uuid
      returning id::text
    )
    select changed.id
    from changed
  $$,
  $$select null::text where false$$,
  'an active administrator cannot update another profile'
);

select results_eq(
  $$
    select array_agg(role_row.code::text order by role_row.code)
    from public.roles as role_row
  $$,
  $$
    values (
      array[
        'RESEARCHER',
        'HADITH_REVIEWER',
        'FIQH_REVIEWER',
        'LANGUAGE_EDITOR',
        'TRANSLATOR',
        'PUBLISHER',
        'CONTENT_ADMIN',
        'TECHNICAL_ADMIN',
        'SUPER_ADMIN'
      ]::text[]
    )
  $$,
  'an active assigned administrator can read the canonical role codes'
);

select lives_ok(
  $$select code, description from public.roles order by code$$,
  'an active assigned administrator can read role descriptions'
);

select throws_ok(
  $$select created_at from public.roles$$,
  '42501',
  null,
  'an active administrator cannot read role timestamps'
);

select results_eq(
  $$
    select array_agg(assignment.role_code::text order by assignment.role_code)
    from public.admin_role_assignments as assignment
  $$,
  $$values (array['RESEARCHER', 'SUPER_ADMIN']::text[])$$,
  'an active administrator sees only its current role codes'
);

select throws_ok(
  $$select * from public.admin_role_assignments$$,
  '42501',
  null,
  'an active administrator cannot wildcard-read assignment metadata'
);

select throws_ok(
  $$select reason from public.admin_role_assignments$$,
  '42501',
  null,
  'an active administrator cannot read assignment reasons'
);

select throws_ok(
  $$select private.is_active_admin()$$,
  '42501',
  null,
  'the private helper is not directly callable through the authenticated schema path'
);

select throws_ok(
  $$
    insert into public.admin_profiles (id, display_name)
    values (
      '10000000-0000-4000-8000-000000000006'::uuid,
      'Self-provision attempt'
    )
  $$,
  '42501',
  null,
  'even a SUPER_ADMIN fixture cannot self-provision an admin profile'
);

select throws_ok(
  $$
    insert into public.roles (code, description)
    values ('TRANSLATOR', 'Attempted role rewrite')
  $$,
  '42501',
  null,
  'even a SUPER_ADMIN fixture cannot add or rewrite roles directly'
);

select throws_ok(
  $$
    insert into public.admin_role_assignments (
      admin_profile_id,
      role_code,
      assigned_by
    )
    values (
      '10000000-0000-4000-8000-000000000001'::uuid,
      'PUBLISHER',
      '10000000-0000-4000-8000-000000000001'::uuid
    )
  $$,
  '42501',
  null,
  'even a SUPER_ADMIN fixture cannot self-assign another role'
);

select throws_ok(
  $$
    update public.admin_role_assignments
    set revoked_at = now()
    where role_code = 'RESEARCHER'
  $$,
  '42501',
  null,
  'even a SUPER_ADMIN fixture cannot revoke assignments directly'
);

select throws_ok(
  $$select id from public.reviewers$$,
  '42501',
  null,
  'BE-02 does not open reviewer records'
);

select throws_ok(
  $$select id from public.sources$$,
  '42501',
  null,
  'BE-02 does not open source-rights records'
);

select throws_ok(
  $$select id from public.sunnah_items$$,
  '42501',
  null,
  'BE-02 does not open content drafts or published records'
);

select throws_ok(
  $$select id from public.public_content_bundles$$,
  '42501',
  null,
  'BE-02 does not open public-bundle records'
);

reset role;
set local request.jwt.claim.sub = '10000000-0000-4000-8000-000000000003';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"10000000-0000-4000-8000-000000000003","role":"authenticated"}';

select is(
  private.is_active_admin(),
  false,
  'an inactive profile never qualifies as an active administrator'
);

set local role authenticated;

select results_eq(
  $$select id::text from public.admin_profiles$$,
  $$select null::text where false$$,
  'an inactive profile cannot read its own profile'
);

select results_eq(
  $$select code::text from public.roles$$,
  $$select null::text where false$$,
  'an inactive profile cannot read the role catalogue'
);

select results_eq(
  $$select role_code::text from public.admin_role_assignments$$,
  $$select null::text where false$$,
  'an inactive profile cannot read any role assignment'
);

reset role;
set local request.jwt.claim.sub = '10000000-0000-4000-8000-000000000004';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"10000000-0000-4000-8000-000000000004","role":"authenticated"}';

select is(
  private.is_active_admin(),
  false,
  'an active profile without a role does not qualify as an administrator'
);

set local role authenticated;

select results_eq(
  $$select id::text from public.admin_profiles$$,
  $$values ('10000000-0000-4000-8000-000000000004'::text)$$,
  'a roleless active profile can still read its own allowed profile fields'
);

select results_eq(
  $$select code::text from public.roles$$,
  $$select null::text where false$$,
  'a roleless active profile cannot read the role catalogue'
);

reset role;
set local request.jwt.claim.sub = '10000000-0000-4000-8000-000000000005';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"10000000-0000-4000-8000-000000000005","role":"authenticated"}';

select is(
  private.is_active_admin(),
  false,
  'a profile with only revoked roles does not qualify as an administrator'
);

set local role authenticated;

select results_eq(
  $$select code::text from public.roles$$,
  $$select null::text where false$$,
  'a profile with only revoked roles cannot read the role catalogue'
);

select results_eq(
  $$select role_code::text from public.admin_role_assignments$$,
  $$select null::text where false$$,
  'a profile with only revoked roles cannot read role history'
);

reset role;
set local role anon;
reset request.jwt.claim.sub;
set local request.jwt.claim.role = 'anon';
set local request.jwt.claims = '{"role":"anon"}';

select throws_ok(
  $$select id from public.admin_profiles$$,
  '42501',
  null,
  'anon cannot read administrator profiles'
);

select throws_ok(
  $$select code from public.roles$$,
  '42501',
  null,
  'anon cannot read the role catalogue'
);

select throws_ok(
  $$select role_code from public.admin_role_assignments$$,
  '42501',
  null,
  'anon cannot read role assignments'
);

reset role;
set local request.jwt.claim.sub = '10000000-0000-4000-8000-000000000006';
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claims =
  '{"sub":"10000000-0000-4000-8000-000000000006","role":"authenticated","app_metadata":{"role":"SUPER_ADMIN"}}';
set local role authenticated;

select results_eq(
  $$select id::text from public.admin_profiles$$,
  $$select null::text where false$$,
  'an unknown authenticated user cannot read profiles'
);

select results_eq(
  $$select code::text from public.roles$$,
  $$select null::text where false$$,
  'forged JWT metadata cannot grant role-catalogue access'
);

select results_eq(
  $$select role_code::text from public.admin_role_assignments$$,
  $$select null::text where false$$,
  'forged JWT metadata cannot grant assignment access'
);

select * from finish();

rollback;
