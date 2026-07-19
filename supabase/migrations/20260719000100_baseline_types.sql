-- Sunnah Everyday BE-01: structural types only.
-- This migration contains no source, reviewer, rights, content, or approval data.

create extension if not exists pgcrypto;

create type public.admin_role_code as enum (
  'RESEARCHER',
  'HADITH_REVIEWER',
  'FIQH_REVIEWER',
  'LANGUAGE_EDITOR',
  'TRANSLATOR',
  'PUBLISHER',
  'CONTENT_ADMIN',
  'TECHNICAL_ADMIN',
  'SUPER_ADMIN'
);

create type public.source_permission_status as enum (
  'UNKNOWN',
  'REQUESTED',
  'GRANTED',
  'PUBLIC_LICENSE',
  'LINK_ONLY',
  'RESTRICTED',
  'EXPIRED',
  'REJECTED'
);

create type public.source_display_mode as enum (
  'LINK_ONLY',
  'LICENSED_CONTENT'
);

create type public.source_type as enum (
  'PRIMARY_TEXT',
  'NARRATION_ASSESSMENT',
  'AUTHORITATIVE_EXPLANATION',
  'EDITORIAL_SUMMARY'
);

create type public.hadith_grade as enum (
  'SAHIH',
  'HASAN',
  'DAIF',
  'VERY_WEAK',
  'FABRICATED',
  'DISPUTED',
  'UNGRADED',
  'NOT_APPLICABLE'
);

create type public.practice_classification as enum (
  'SUNNAH_RECOMMENDED',
  'ADAB',
  'AKHLAQ',
  'OBLIGATORY',
  'PERMISSIBLE',
  'PROPHETIC_HABIT',
  'PROPHET_SPECIFIC',
  'CONTEXT_SPECIFIC',
  'DISPUTED',
  'HISTORICAL_INFORMATION',
  'DUA',
  'DHIKR'
);

create type public.prophetic_form as enum (
  'QAWLIYYAH',
  'FI_LIYYAH',
  'TAQRIRIYYAH',
  'MIXED',
  'NOT_APPLICABLE'
);

create type public.content_workflow_status as enum (
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
);

create type public.review_scope as enum (
  'SOURCE_HADITH',
  'FIQH_CONTEXT',
  'LANGUAGE'
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
