import assert from 'node:assert/strict';
import { readdir, readFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const repositoryRoot = fileURLToPath(new URL('..', import.meta.url));
const templatesDirectory = join(repositoryRoot, 'content', 'templates');
const typesMigration = join(
  repositoryRoot,
  'supabase',
  'migrations',
  '20260719000100_baseline_types.sql',
);

const templateContracts = [
  {
    csv: 'sunnah_content_template.csv',
    schema: 'sunnah_content_schema.json',
  },
  {
    csv: 'source_register_template.csv',
    schema: 'source_register_schema.json',
  },
  {
    csv: 'reviewer_template.csv',
    schema: 'reviewer_schema.json',
  },
  {
    csv: 'evidence_template.csv',
    schema: 'evidence_schema.json',
  },
  {
    csv: 'content_evidence_template.csv',
    schema: 'content_evidence_schema.json',
  },
];

const requiredBoundaryFiles = new Set(['.gitignore', '.gitkeep', 'README.md']);
const requiredStagingValues = {
  schema_version: '1',
  import_mode: 'STAGING',
  non_publication_notice: 'KANDUNGAN DEMO — TIDAK UNTUK PENERBITAN',
};

function parseCsvHeader(csvText, filename) {
  const lines = csvText
    .replace(/\r\n/g, '\n')
    .split('\n')
    .filter((line) => line.length > 0);
  assert.equal(
    lines.length,
    1,
    `${filename} must remain header-only; examples belong in a reviewed non-public workflow.`,
  );
  return lines[0].split(',');
}

function enumValuesFromMigration(sql, enumName) {
  const match = sql.match(
    new RegExp(
      `create\\s+type\\s+public\\.${enumName}\\s+as\\s+enum\\s*\\(([\\s\\S]*?)\\);`,
      'i',
    ),
  );
  assert.ok(match, `BE-01 enum ${enumName} is missing.`);
  return [...match[1].matchAll(/'([^']+)'/g)].map((value) => value[1]);
}

async function readSchema(filename) {
  const raw = await readFile(join(templatesDirectory, filename), 'utf8');
  return JSON.parse(raw);
}

async function assertBoundaryDirectory(directoryName) {
  const directory = join(repositoryRoot, 'content', directoryName);
  const entries = await readdir(directory, { withFileTypes: true });
  const names = new Set(entries.map((entry) => entry.name));
  assert.deepEqual(
    names,
    requiredBoundaryFiles,
    `content/${directoryName} must contain only its boundary controls.`,
  );
  assert.ok(
    entries.every((entry) => entry.isFile()),
    `content/${directoryName} cannot contain nested candidate data.`,
  );
}

function assertStagingFields(schema, filename) {
  for (const [field, expectedValue] of Object.entries(requiredStagingValues)) {
    assert.equal(
      schema.properties?.[field]?.const,
      expectedValue,
      `${filename} must lock ${field} to ${expectedValue}.`,
    );
  }
}

function assertEnumContracts(schema, filename, migrationSql) {
  for (const [field, enumName] of Object.entries(schema['x-enum-contract'] ?? {})) {
    assert.deepEqual(
      schema.properties?.[field]?.enum,
      enumValuesFromMigration(migrationSql, enumName),
      `${filename} must match BE-01 enum ${enumName} for ${field}.`,
    );
  }
}

function resolveLocalReference(schema, reference) {
  assert.ok(reference.startsWith('#/'), `Only local schema references are supported: ${reference}`);
  return reference
    .slice(2)
    .split('/')
    .reduce((value, segment) => value?.[segment], schema);
}

function assertCsvMapping(schema, header, filename) {
  const mapping = schema['x-csv-to-json'];
  if (mapping == null) {
    return;
  }
  assert.deepEqual(
    Object.keys(mapping),
    header,
    `${filename} must map each CSV column exactly once.`,
  );
  assert.equal(
    new Set(Object.values(mapping)).size,
    header.length,
    `${filename} cannot map multiple CSV columns to one JSON path.`,
  );

  for (const jsonPath of Object.values(mapping)) {
    let cursor = schema;
    for (const segment of jsonPath.split('.')) {
      while (cursor.$ref != null) {
        cursor = resolveLocalReference(schema, cursor.$ref);
      }
      cursor = cursor.properties?.[segment];
      assert.ok(cursor, `${filename} maps to unknown JSON path ${jsonPath}.`);
    }
  }
}

function assertContentSafetySchema(schema) {
  assert.equal(
    schema.properties?.workflow_status?.const,
    'DRAFT',
    'Content intake must start as DRAFT.',
  );
  assert.deepEqual(
    schema['x-forbidden-server-fields'],
    [
      'content_checksum',
      'immutable_after_publish',
      'published_at',
      'scheduled_at',
      'daily_schedule',
      'public_bundle_id',
      'publication_event_id',
      'approval_id',
    ],
    'Content intake must not expose publication controls.',
  );
  assert.equal(schema.additionalProperties, false);
  assert.equal(schema.properties?.locales?.required?.includes('ms'), true);
  assert.equal(schema.properties?.locales?.required?.includes('en'), true);
}

async function assertAppAssetsExcludeContent() {
  for (const pubspec of [
    join(repositoryRoot, 'apps', 'mobile', 'pubspec.yaml'),
    join(repositoryRoot, 'apps', 'admin', 'pubspec.yaml'),
  ]) {
    const source = await readFile(pubspec, 'utf8');
    assert.equal(
      /content[\\/]/.test(source),
      false,
      `${pubspec} must not package draft content as an application asset.`,
    );
  }
}

export async function verifyContentContract() {
  const migrationSql = await readFile(typesMigration, 'utf8');
  const schemas = [];

  for (const contract of templateContracts) {
    const [csv, schema] = await Promise.all([
      readFile(join(templatesDirectory, contract.csv), 'utf8'),
      readSchema(contract.schema),
    ]);
    const header = parseCsvHeader(csv, contract.csv);
    assert.deepEqual(
      header,
      schema['x-csv-columns'],
      `${contract.csv} must exactly match ${contract.schema}.`,
    );
    assert.equal(schema.$schema, 'https://json-schema.org/draft/2020-12/schema');
    assert.equal(schema.type, 'object');
    assert.equal(schema.additionalProperties, false);
    assertCsvMapping(schema, header, contract.schema);
    assertStagingFields(schema, contract.schema);
    assertEnumContracts(schema, contract.schema, migrationSql);
    schemas.push(schema);
  }

  assertContentSafetySchema(schemas[0]);
  await Promise.all([
    assertBoundaryDirectory('staging'),
    assertBoundaryDirectory('approved'),
    assertAppAssetsExcludeContent(),
  ]);

  return {
    schemaCount: schemas.length,
    templateCount: templateContracts.length,
  };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const result = await verifyContentContract();
  console.log(
    `CNT-01 content contract passed: ${result.templateCount} header-only templates and ${result.schemaCount} draft-only schemas verified.`,
  );
}
