import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const repositoryRoot = fileURLToPath(new URL('..', import.meta.url));
const migrationDirectory = join(repositoryRoot, 'supabase', 'migrations');
const testFile = join(
  repositoryRoot,
  'supabase',
  'tests',
  'database',
  '000_initial_schema_test.sql',
);
const publicationGateTestFile = join(
  repositoryRoot,
  'supabase',
  'tests',
  'database',
  '020_review_workflow_publication_gate_test.sql',
);

const requiredTables = [
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
  'supported_locales',
];

const securedTables = [...requiredTables, 'sunnah_item_tags'];
const migrationFiles = (await readdir(migrationDirectory))
  .filter((file) => file.endsWith('.sql'))
  .sort();

const baselineMigrationFiles = [
  '20260719000100_baseline_types.sql',
  '20260719000200_identity_sources_taxonomy.sql',
  '20260719000300_content_review_structures.sql',
  '20260719000400_delivery_audit_and_deny_by_default.sql',
];
const publicationGateMigrationFile =
  '20260719000600_review_workflow_publication_gate.sql';

if (migrationFiles.length === 0) {
  throw new Error('No Supabase migration files were found.');
}

const missingBaselineMigrations = baselineMigrationFiles.filter(
  (file) => !migrationFiles.includes(file),
);

if (missingBaselineMigrations.length > 0) {
  throw new Error(
    `Missing BE-01 migrations: ${missingBaselineMigrations.join(', ')}`,
  );
}

if (!migrationFiles.includes(publicationGateMigrationFile)) {
  throw new Error(`Missing BE-03 migration: ${publicationGateMigrationFile}`);
}

const baselineSql = (
  await Promise.all(
    baselineMigrationFiles.map(async (file) =>
      readFile(join(migrationDirectory, file), 'utf8'),
    ),
  )
).join('\n');

const missingTables = requiredTables.filter(
  (table) =>
    !new RegExp(`\\bcreate\\s+table\\s+public\\.${table}\\b`, 'i').test(
      baselineSql,
    ),
);

if (missingTables.length > 0) {
  throw new Error(`Missing required tables: ${missingTables.join(', ')}`);
}

if (/\binsert\s+into\b/i.test(baselineSql)) {
  throw new Error('Baseline migrations must not seed any records.');
}

if (/\bcreate\s+policy\b/i.test(baselineSql)) {
  throw new Error('BE-01 must not create an access policy before BE-02.');
}

if (/\bcreate\s+table\s+public\.(bookmarks|reflections)\b/i.test(baselineSql)) {
  throw new Error('Bookmarks and reflections must remain local-only.');
}

for (const table of securedTables) {
  if (!baselineSql.includes(`'${table}'`)) {
    throw new Error(`RLS baseline does not enumerate ${table}.`);
  }
}

for (const requiredFragment of [
  'enable row level security',
  'force row level security',
  'revoke all on table public.%I from public, anon, authenticated',
  'sunnah_items_current_version_belongs_to_item_fkey',
  'sources_current_permission_belongs_to_source_fkey',
  'content_withdrawals_version_belongs_to_item_fkey',
]) {
  if (!baselineSql.includes(requiredFragment)) {
    throw new Error(`Missing required baseline guard: ${requiredFragment}`);
  }
}

const [testSql, publicationGateTestSql, publicationGateSql] = await Promise.all([
  readFile(testFile, 'utf8'),
  readFile(publicationGateTestFile, 'utf8'),
  readFile(join(migrationDirectory, publicationGateMigrationFile), 'utf8'),
]);
const allTestSql = `${testSql}\n${publicationGateTestSql}`;
for (const requiredFragment of [
  'no_plan()',
  'has_table',
  'relrowsecurity and relforcerowsecurity',
  'corrections_report_belongs_to_item_fkey',
  'a content item cannot point at another item',
  'duplicate version numbers are rejected',
  'duplicate daily schedule slots are rejected',
]) {
  if (!allTestSql.includes(requiredFragment)) {
    throw new Error(`pgTAP coverage is missing: ${requiredFragment}`);
  }
}

for (const requiredFragment of [
  'create table public.version_sources',
  'create table public.version_locale_states',
  'create table public.content_workflow_events',
  'private.assert_version_publication_eligible',
  'private.assert_daily_feed_eligible',
  'public.seal_version_for_publication',
  'public.schedule_daily_version',
  'private.prevent_sealed_version_mutation',
  'private.prevent_workflow_event_mutation',
  'Development-only marker blocks publication.',
  'Granted source permissions require a written reference.',
  'Public-license source permissions require licence and attribution.',
  'Link-only evidence cannot include source text or translations.',
  "set timezone = 'UTC'",
]) {
  if (!publicationGateSql.includes(requiredFragment)) {
    throw new Error(`BE-03 publication gate is missing: ${requiredFragment}`);
  }
}

for (const requiredFragment of [
  'the author cannot self-approve',
  'every prohibited or non-applicable primary grade is blocked',
  'a sealed version cannot be edited in place',
  'expired source rights block publication eligibility',
  'withdrawn content no longer passes Daily Feed eligibility',
  'a RESEARCHER-only account cannot seal a version for publication',
  'a RESEARCHER-only account cannot publish a daily schedule',
  'only authenticated callers can execute every narrow workflow RPC',
  'every narrow workflow RPC is security definer with an explicit search path',
  'anon cannot read draft content versions',
  'anon cannot read reviewer qualification records',
  'anon cannot append workflow events',
  'workflow events are append-only and cannot be updated',
  'workflow events are append-only and cannot be deleted',
  'development-only marker blocks publication eligibility',
  'a development-only version cannot be promoted through human review',
  'draft checksums canonicalize review timestamps across caller timezones',
  'publication snapshots canonicalize review and approval timestamps across caller timezones',
  'granted source rights without a written reference block publication',
  'public-license rights without licence and attribution block publication',
  'link-only evidence text blocks publication',
  'evidence rights status must match its bound source permission',
  'sealed tag metadata changes fail the generic publication gate',
  'sealed category metadata changes fail the generic publication gate',
  'sealed evidence metadata changes fail the generic publication gate',
  'sealed source metadata changes fail the generic publication gate',
]) {
  if (!publicationGateTestSql.includes(requiredFragment)) {
    throw new Error(`BE-03 pgTAP coverage is missing: ${requiredFragment}`);
  }
}

console.log(
  `Supabase static guard passed: ${requiredTables.length} BE-01 tables, ${baselineMigrationFiles.length} baseline migrations, and BE-03 publication-gate coverage found.`,
);
