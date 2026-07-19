import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

import {
  canonicalImportFiles,
  formatValidationReport,
  parseCsv,
  readDraftCsvDirectory,
  validateDraftBatch,
  validateImportDirectory,
} from './validate_content.mjs';

const repositoryRoot = fileURLToPath(new URL('..', import.meta.url));
const fixtureDirectory = join(
  repositoryRoot,
  'scripts',
  'fixtures',
  'content-import',
  'valid',
);
const invalidWorkflowFixtureDirectory = join(
  repositoryRoot,
  'scripts',
  'fixtures',
  'content-import',
  'invalid-workflow',
);
const asOf = '2099-01-01';

async function validBatch() {
  const parsed = await readDraftCsvDirectory(fixtureDirectory);
  assert.deepEqual(parsed.errors, []);
  return parsed.batch;
}

function errorCodes(report) {
  return new Set(report.errors.map((issue) => issue.code));
}

function blockerCodes(report) {
  return new Set(report.blockers.map((issue) => issue.code));
}

test('CSV parser accepts quoted commas, escaped quotes, embedded newlines and a BOM', () => {
  const rows = parseCsv('\ufefffirst,second\r\n"one, two","line one\nline ""two"""\r\n');

  assert.deepEqual(rows, [
    ['first', 'second'],
    ['one, two', 'line one\nline "two"'],
  ]);
});

test('canonical input names stay aligned to the draft intake contract', () => {
  assert.deepEqual(canonicalImportFiles, {
    sunnahContent: 'sunnah_content.csv',
    sourceRegister: 'source_register.csv',
    reviewers: 'reviewer.csv',
    evidence: 'evidence.csv',
    contentEvidence: 'content_evidence.csv',
  });
});

test('the valid non-claiming CSV fixture is a read-only STAGING/DRAFT preview', async () => {
  const report = await validateImportDirectory(fixtureDirectory, { asOf });

  assert.equal(report.valid, true);
  assert.equal(report.draftValid, true);
  assert.equal(report.hasPublicReadinessBlockers, true);
  assert.equal(report.importedRecords, 0);
  assert.equal(report.publicationEligible, false);
  assert.equal(report.publicationEligibility, 'NOT_EVALUATED_BY_CNT_02');
  assert.equal(report.summary.totalRows, 5);
  assert.deepEqual(report.errors, []);
  assert.deepEqual(blockerCodes(report), new Set([
    'LINK_ONLY_SOURCE_URL_REQUIRED',
    'TRANSLATION_UNAVAILABLE_BLOCKER',
  ]));
  assert.doesNotMatch(JSON.stringify(report), /STRUCTURAL_TEST/);
  assert.doesNotMatch(formatValidationReport(report), /STRUCTURAL_TEST/);
});

test('validator rejects every logical duplicate key and link order', async () => {
  const batch = await validBatch();
  batch.sourceRegister.push(structuredClone(batch.sourceRegister[0]));
  batch.reviewers.push(structuredClone(batch.reviewers[0]));
  batch.evidence.push(structuredClone(batch.evidence[0]));
  batch.sunnahContent.push(structuredClone(batch.sunnahContent[0]));
  batch.contentEvidence.push(structuredClone(batch.contentEvidence[0]));

  const report = await validateDraftBatch(batch, { asOf });
  const codes = errorCodes(report);

  assert.equal(report.valid, false);
  for (const code of [
    'DUPLICATE_SOURCE_STABLE_KEY',
    'DUPLICATE_REVIEWER_CODE',
    'DUPLICATE_EVIDENCE_KEY',
    'DUPLICATE_CONTENT_VERSION',
    'DUPLICATE_CONTENT_EVIDENCE_LINK',
    'DUPLICATE_CONTENT_EVIDENCE_ORDER',
    'CONTENT_PRIMARY_EVIDENCE_INVALID',
  ]) {
    assert.equal(codes.has(code), true, `expected ${code}`);
  }
});

test('validator rejects unresolved references, stale permission revisions and nonmatching link coverage', async () => {
  const batch = await validBatch();
  batch.evidence[0].source_permission_revision = 2;
  batch.sunnahContent[0].source_stable_keys = ['missing-structural-source'];
  batch.sunnahContent[0].evidence_keys.push('missing-structural-evidence');
  batch.contentEvidence[0].is_primary = false;

  const report = await validateDraftBatch(batch, { asOf });
  const codes = errorCodes(report);

  for (const code of [
    'SOURCE_PERMISSION_REVISION_MISMATCH',
    'UNRESOLVED_SOURCE_REFERENCE',
    'UNRESOLVED_EVIDENCE_REFERENCE',
    'CONTENT_EVIDENCE_LINK_MISSING',
    'CONTENT_PRIMARY_EVIDENCE_INVALID',
    'CONTENT_EVIDENCE_SOURCE_UNDECLARED',
  ]) {
    assert.equal(codes.has(code), true, `expected ${code}`);
  }
});

test('validator rejects a licensed-content declaration when linked records are only link-only', async () => {
  const batch = await validBatch();
  batch.sunnahContent[0].source_rights_status = 'GRANTED';
  batch.sunnahContent[0].display_mode = 'LICENSED_CONTENT';
  batch.evidence[0].arabic_display_status = 'DISPLAY_RIGHTS_RECORDED';

  const report = await validateDraftBatch(batch, { asOf });
  const codes = errorCodes(report);

  assert.equal(codes.has('CONTENT_SOURCE_RIGHTS_MISMATCH'), true);
  assert.equal(codes.has('CONTENT_EVIDENCE_RIGHTS_MISMATCH'), true);
  assert.equal(codes.has('EVIDENCE_TEXT_RIGHTS_CONTRADICTION'), true);
});

test('translation validation is trim-aware and rejects text in an unavailable locale', async () => {
  const incompleteBatch = await validBatch();
  incompleteBatch.sunnahContent[0].locales.en = {
    availability: 'COMPLETE',
    unavailable_rationale: null,
    title: ' ',
    summary: 'STRUCTURAL_TEST',
    practical_steps: 'STRUCTURAL_TEST',
    when_to_practise: 'STRUCTURAL_TEST',
    context_note: 'STRUCTURAL_TEST',
    misunderstanding_note: 'STRUCTURAL_TEST',
    legal_classification_note: 'STRUCTURAL_TEST',
  };
  const incompleteReport = await validateDraftBatch(incompleteBatch, { asOf });
  assert.equal(errorCodes(incompleteReport).has('TRANSLATION_INCOMPLETE'), true);

  const contradictoryBatch = await validBatch();
  contradictoryBatch.sunnahContent[0].locales.ms.title = 'STRUCTURAL_TEST';
  const contradictoryReport = await validateDraftBatch(contradictoryBatch, { asOf });
  assert.equal(
    errorCodes(contradictoryReport).has('TRANSLATION_STATE_CONTRADICTION'),
    true,
  );
});

test('required source metadata is trim-aware like the shared Dart contract', async () => {
  const batch = await validBatch();
  batch.sourceRegister[0].source_name = '   ';

  const report = await validateDraftBatch(batch, { asOf });
  assert.equal(errorCodes(report).has('SOURCE_METADATA_BLANK'), true);
  assert.equal(report.draftValid, false);
});

test('source URLs need a usable HTTP(S) host and scopes cannot be blank', async () => {
  const batch = await validBatch();
  batch.sourceRegister[0].source_url = 'https://structural:fixture@example.invalid';
  batch.evidence[0].source_url = 'https://';
  batch.sunnahContent[0].audience_scopes = ['   '];

  const report = await validateDraftBatch(batch, { asOf });
  const codes = errorCodes(report);

  assert.equal(codes.has('SOURCE_URL_INVALID'), true);
  assert.equal(codes.has('EVIDENCE_URL_INVALID'), true);
  assert.equal(codes.has('CONTENT_SCOPE_BLANK'), true);
  assert.equal(blockerCodes(report).has('LINK_ONLY_SOURCE_URL_REQUIRED'), true);
});

test('rights dates and metadata are reportable blockers without turning a DRAFT into public content', async () => {
  const batch = await validBatch();
  batch.sourceRegister[0].permission_status = 'GRANTED';
  batch.sourceRegister[0].display_mode = 'LICENSED_CONTENT';
  batch.sourceRegister[0].permission_expires_at = '2098-12-31';
  batch.sourceRegister[0].reviewed_at = '2099-01-01';
  batch.evidence[0].rights_status = 'GRANTED';
  batch.evidence[0].display_mode = 'LICENSED_CONTENT';
  batch.sunnahContent[0].source_rights_status = 'GRANTED';
  batch.sunnahContent[0].display_mode = 'LICENSED_CONTENT';

  const report = await validateDraftBatch(batch, { asOf });
  const errors = errorCodes(report);
  const blockers = blockerCodes(report);

  assert.equal(errors.has('SOURCE_PERMISSION_DATE_INVALID'), true);
  assert.equal(blockers.has('RIGHTS_PERMISSION_EXPIRED'), true);
  assert.equal(blockers.has('RIGHTS_DOCUMENT_REFERENCE_REQUIRED'), true);
  assert.equal(report.publicationEligible, false);
});

test('CLI JSON output is deterministic, safe, and leaves import count at zero', async () => {
  const result = spawnSync(
    process.execPath,
    [
      'scripts/validate_content.mjs',
      '--input',
      'scripts/fixtures/content-import/valid',
      '--as-of',
      asOf,
      '--json',
    ],
    { cwd: repositoryRoot, encoding: 'utf8' },
  );

  assert.equal(result.status, 0, result.stderr);
  const report = JSON.parse(result.stdout);
  assert.equal(report.valid, true);
  assert.equal(report.importedRecords, 0);
  assert.equal(report.publicationEligible, false);
  assert.doesNotMatch(result.stdout, /STRUCTURAL_TEST/);
});

test('CLI rejects the committed invalid workflow fixture without exposing row values', () => {
  const result = spawnSync(
    process.execPath,
    [
      'scripts/validate_content.mjs',
      '--input',
      'scripts/fixtures/content-import/invalid-workflow',
      '--as-of',
      asOf,
      '--json',
    ],
    { cwd: repositoryRoot, encoding: 'utf8' },
  );

  assert.equal(result.status, 1, result.stderr);
  const report = JSON.parse(result.stdout);
  assert.equal(report.valid, false);
  assert.equal(errorCodes(report).has('DRAFT_BOUNDARY_INVALID'), true);
  assert.equal(report.importedRecords, 0);
  assert.doesNotMatch(result.stdout, /STRUCTURAL_TEST/);
});

test('the import executable refuses a valid batch instead of writing it', () => {
  const result = spawnSync(
    process.execPath,
    [
      'scripts/import_content.mjs',
      '--input',
      'scripts/fixtures/content-import/valid',
      '--as-of',
      asOf,
    ],
    { cwd: repositoryRoot, encoding: 'utf8' },
  );

  assert.equal(result.status, 3);
  assert.match(result.stderr, /Import refused/);
  assert.doesNotMatch(`${result.stdout}${result.stderr}`, /STRUCTURAL_TEST/);
});

test('fixture CSV files remain outside the guarded content staging boundary', async () => {
  const source = await readFile(join(fixtureDirectory, 'source_register.csv'), 'utf8');
  assert.match(source, /STRUCTURAL_TEST, QUOTED/);
  assert.equal(fixtureDirectory.includes(`${join('content', 'staging')}`), false);
});
