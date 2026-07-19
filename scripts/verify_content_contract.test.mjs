import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

import Ajv2020 from 'ajv/dist/2020.js';
import addFormats from 'ajv-formats';

import { verifyContentContract } from './verify_content_contract.mjs';

const repositoryRoot = fileURLToPath(new URL('..', import.meta.url));
const templatesDirectory = join(repositoryRoot, 'content', 'templates');
const marker = 'KANDUNGAN DEMO — TIDAK UNTUK PENERBITAN';

const stagingEnvelope = () => ({
  schema_version: '1',
  import_mode: 'STAGING',
  non_publication_notice: marker,
});

const unavailableLocale = () => ({
  availability: 'UNAVAILABLE',
  unavailable_rationale: marker,
  title: null,
  summary: null,
  practical_steps: null,
  when_to_practise: null,
  context_note: null,
  misunderstanding_note: null,
  legal_classification_note: null,
});

const validRecords = {
  'sunnah_content_schema.json': {
    ...stagingEnvelope(),
    workflow_status: 'DRAFT',
    item_slug: 'structural-test-item',
    version_number: 1,
    content_type: 'STRUCTURAL_TEST',
    category_slug: 'structural-test-category',
    tag_slugs: [],
    classification: 'DISPUTED',
    prophetic_form: 'NOT_APPLICABLE',
    audience_scopes: [],
    situation_scopes: [],
    difficulty_level: 1,
    frequency_label: null,
    has_scholarly_difference: false,
    is_prophet_specific: false,
    requires_medical_note: false,
    locales: { ms: unavailableLocale(), en: unavailableLocale() },
    source_rights_status: 'LINK_ONLY',
    display_mode: 'LINK_ONLY',
    source_stable_keys: ['structural-test-source'],
    evidence_keys: ['structural-test-evidence'],
    reviewer_reference_keys: [],
  },
  'source_register_schema.json': {
    ...stagingEnvelope(),
    source_stable_key: 'structural-test-source',
    source_name: 'STRUCTURAL_TEST',
    owner_name: 'STRUCTURAL_TEST',
    source_type: 'EDITORIAL_SUMMARY',
    source_url: null,
    bibliographic_locator: 'STRUCTURAL_TEST',
    edition: 'STRUCTURAL_TEST',
    language_code: 'zz',
    accessed_at: '2099-01-01',
    reviewed_at: '2099-01-01',
    permission_revision: 1,
    permission_status: 'LINK_ONLY',
    display_mode: 'LINK_ONLY',
    rights_basis: 'STRUCTURAL_TEST',
    licence: null,
    permission_scope: 'STRUCTURAL_TEST',
    document_reference: null,
    usage_notes: 'STRUCTURAL_TEST',
    attribution_text: null,
    permission_expires_at: null,
    reviewed_by_reference: 'structural-test-reviewer',
  },
  'reviewer_schema.json': {
    ...stagingEnvelope(),
    reviewer_code: 'structural-test-reviewer',
    public_display_name: 'STRUCTURAL_TEST',
    restricted_profile_reference: 'STRUCTURAL_TEST',
    qualification_type: 'STRUCTURAL_TEST',
    specialism: 'STRUCTURAL_TEST',
    qualification_evidence_reference: 'STRUCTURAL_TEST',
    review_scope: 'LANGUAGE',
    locale_code: null,
    verified_at: null,
    is_active: false,
  },
  'evidence_schema.json': {
    ...stagingEnvelope(),
    evidence_key: 'structural-test-evidence',
    source_stable_key: 'structural-test-source',
    source_permission_revision: 1,
    evidence_type: 'STRUCTURAL_TEST',
    source_locator: 'STRUCTURAL_TEST',
    source_url: null,
    collection_name: null,
    book_name: null,
    chapter_name: null,
    reference_number: null,
    narrator: null,
    hadith_grade: 'NOT_APPLICABLE',
    grader_reference: 'STRUCTURAL_TEST',
    arabic_display_status: 'NOT_INCLUDED',
    translation_status: 'NOT_INCLUDED',
    verification_date: null,
    verification_note: null,
    rights_status: 'LINK_ONLY',
    display_mode: 'LINK_ONLY',
  },
  'content_evidence_schema.json': {
    ...stagingEnvelope(),
    item_slug: 'structural-test-item',
    version_number: 1,
    evidence_key: 'structural-test-evidence',
    display_order: 0,
    is_primary: true,
  },
};

async function schema(filename) {
  return JSON.parse(await readFile(join(templatesDirectory, filename), 'utf8'));
}

function validator(schemaDefinition) {
  const ajv = new Ajv2020({ allErrors: true, strict: false });
  addFormats(ajv);
  return ajv.compile(schemaDefinition);
}

test('content templates remain draft-only and aligned with BE-01 enums', async () => {
  const result = await verifyContentContract();

  assert.equal(result.templateCount, 5);
  assert.equal(result.schemaCount, 5);
});

test('schemas accept only non-claiming structural draft records', async () => {
  for (const [filename, record] of Object.entries(validRecords)) {
    const validate = validator(await schema(filename));
    assert.equal(
      validate(record),
      true,
      `${filename} rejected its structural record: ${JSON.stringify(validate.errors)}`,
    );
  }
});

test('content schema rejects release-shaped, unreviewed and malformed records', async () => {
  const validateContent = validator(await schema('sunnah_content_schema.json'));
  const licensedWithoutRights = structuredClone(
    validRecords['sunnah_content_schema.json'],
  );
  licensedWithoutRights.display_mode = 'LICENSED_CONTENT';
  licensedWithoutRights.source_rights_status = 'REQUESTED';
  assert.equal(validateContent(licensedWithoutRights), false);

  const scheduled = structuredClone(validRecords['sunnah_content_schema.json']);
  scheduled.workflow_status = 'SCHEDULED';
  assert.equal(validateContent(scheduled), false);

  const releaseShaped = structuredClone(validRecords['sunnah_content_schema.json']);
  releaseShaped.published_at = '2099-01-01T00:00:00Z';
  assert.equal(validateContent(releaseShaped), false);

  const missingLocale = structuredClone(validRecords['sunnah_content_schema.json']);
  delete missingLocale.locales.en;
  assert.equal(validateContent(missingLocale), false);
});

test('source and evidence schemas require traceability and display metadata', async () => {
  const validateSource = validator(await schema('source_register_schema.json'));
  const missingLocator = structuredClone(validRecords['source_register_schema.json']);
  missingLocator.bibliographic_locator = '';
  assert.equal(validateSource(missingLocator), false);

  const validateEvidence = validator(await schema('evidence_schema.json'));
  const missingTranslationStatus = structuredClone(validRecords['evidence_schema.json']);
  delete missingTranslationStatus.translation_status;
  assert.equal(validateEvidence(missingTranslationStatus), false);
});
