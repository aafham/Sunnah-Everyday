-- BE-02: provisioned admin identity, canonical roles and least-privilege RLS.
-- This migration intentionally creates no people, reviewer, source, rights or
-- religious-content records. Admin/profile and assignment provisioning remains
-- a trusted database-owner operation.

create schema if not exists private;

-- Security-definer policy helpers stay outside the API-exposed public schema.
-- Policies retain a stored reference to these functions, so callers need
-- EXECUTE but never schema USAGE or a direct RPC path.
revoke all on schema private from public, anon, authenticated;

insert into public.roles (code, description)
values
  ('RESEARCHER', 'Draft and source research preparation role.'),
  ('HADITH_REVIEWER', 'Narration-source review role.'),
  ('FIQH_REVIEWER', 'Context and legal-review role.'),
  ('LANGUAGE_EDITOR', 'Language-quality review role.'),
  ('TRANSLATOR', 'Translation preparation role.'),
  ('PUBLISHER', 'Controlled publication-operation role.'),
  ('CONTENT_ADMIN', 'Content administration role.'),
  ('TECHNICAL_ADMIN', 'Technical administration role.'),
  ('SUPER_ADMIN', 'Restricted platform-administration role.')
on conflict (code) do nothing;

create or replace function private.is_active_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.admin_profiles as profile
    join public.admin_role_assignments as assignment
      on assignment.admin_profile_id = profile.id
    where profile.id = (select auth.uid())
      and profile.is_active
      and assignment.revoked_at is null
  );
$$;

create or replace function private.has_active_admin_role(
  required_role_code public.admin_role_code
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.admin_profiles as profile
    join public.admin_role_assignments as assignment
      on assignment.admin_profile_id = profile.id
    where profile.id = (select auth.uid())
      and profile.is_active
      and assignment.revoked_at is null
      and assignment.role_code = $1
  );
$$;

alter function private.is_active_admin() owner to postgres;
alter function private.has_active_admin_role(public.admin_role_code) owner to postgres;

-- PostgreSQL grants EXECUTE to PUBLIC by default. Make both helpers callable
-- only while an authenticated policy is evaluated; private schema access stays
-- revoked so they are not direct client RPCs.
revoke all on function private.is_active_admin() from public, anon, authenticated;
revoke all on function private.has_active_admin_role(public.admin_role_code)
  from public, anon, authenticated;
grant execute on function private.is_active_admin() to authenticated;
grant execute on function private.has_active_admin_role(public.admin_role_code)
  to authenticated;

-- Defend against drift from the BE-01 deny-by-default baseline before adding
-- the smallest possible column-level grants for the future admin client.
revoke all on table public.admin_profiles, public.roles, public.admin_role_assignments
  from public, anon, authenticated;

grant select (id, display_name, public_display_name)
  on table public.admin_profiles to authenticated;
grant update (display_name, public_display_name)
  on table public.admin_profiles to authenticated;
grant select (code, description) on table public.roles to authenticated;
grant select (role_code) on table public.admin_role_assignments to authenticated;

create policy active_admins_read_own_profile
on public.admin_profiles
for select
to authenticated
using (
  id = (select auth.uid())
  and is_active
);

create policy active_admins_update_own_profile
on public.admin_profiles
for update
to authenticated
using (
  id = (select auth.uid())
  and is_active
)
with check (
  id = (select auth.uid())
  and is_active
);

create policy active_admins_read_role_catalogue
on public.roles
for select
to authenticated
using ((select private.is_active_admin()));

create policy active_admins_read_own_current_role_codes
on public.admin_role_assignments
for select
to authenticated
using (
  admin_profile_id = (select auth.uid())
  and revoked_at is null
  and (select private.is_active_admin())
);
