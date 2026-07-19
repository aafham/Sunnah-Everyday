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

const testSql = await readFile(testFile, 'utf8');
for (const requiredFragment of [
  'no_plan()',
  'has_table',
  'relrowsecurity and relforcerowsecurity',
  'corrections_report_belongs_to_item_fkey',
  'a content item cannot point at another item',
  'duplicate version numbers are rejected',
  'duplicate daily schedule slots are rejected',
]) {
  if (!testSql.includes(requiredFragment)) {
    throw new Error(`pgTAP coverage is missing: ${requiredFragment}`);
  }
}

console.log(
  `BE-01 static schema guard passed: ${requiredTables.length} required tables, ${baselineMigrationFiles.length} baseline migrations, and pgTAP coverage found.`,
);
