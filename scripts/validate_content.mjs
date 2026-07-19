import Ajv2020 from 'ajv/dist/2020.js';
import addFormats from 'ajv-formats';
import { readFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { verifyContentContract } from './verify_content_contract.mjs';

const repositoryRoot = fileURLToPath(new URL('..', import.meta.url));
const templatesDirectory = join(repositoryRoot, 'content', 'templates');

const collectionDefinitions = Object.freeze([
  {
    key: 'sunnahContent',
    collection: 'sunnah_content',
    filename: 'sunnah_content.csv',
    schemaFilename: 'sunnah_content_schema.json',
  },
  {
    key: 'sourceRegister',
    collection: 'source_register',
    filename: 'source_register.csv',
    schemaFilename: 'source_register_schema.json',
  },
  {
    key: 'reviewers',
    collection: 'reviewer',
    filename: 'reviewer.csv',
    schemaFilename: 'reviewer_schema.json',
  },
  {
    key: 'evidence',
    collection: 'evidence',
    filename: 'evidence.csv',
    schemaFilename: 'evidence_schema.json',
  },
  {
    key: 'contentEvidence',
    collection: 'content_evidence',
    filename: 'content_evidence.csv',
    schemaFilename: 'content_evidence_schema.json',
  },
]);

const definitionByKey = new Map(
  collectionDefinitions.map((definition) => [definition.key, definition]),
);
const translationFields = Object.freeze([
  'title',
  'summary',
  'practical_steps',
  'when_to_practise',
  'context_note',
  'misunderstanding_note',
  'legal_classification_note',
]);
const usableLicensedStatuses = new Set(['GRANTED', 'PUBLIC_LICENSE']);
const unresolvedRightsStatuses = new Set([
  'UNKNOWN',
  'REQUESTED',
  'RESTRICTED',
  'EXPIRED',
  'REJECTED',
]);
const datePattern = /^\d{4}-\d{2}-\d{2}$/;

let validationResourcesPromise;

export const canonicalImportFiles = Object.freeze(
  Object.fromEntries(
    collectionDefinitions.map((definition) => [definition.key, definition.filename]),
  ),
);

function isRecord(value) {
  return value != null && typeof value === 'object' && !Array.isArray(value);
}

function isNonBlankString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function isUsableHttpUrl(value) {
  if (!isNonBlankString(value)) {
    return false;
  }
  try {
    const parsed = new URL(value);
    return (
      (parsed.protocol === 'http:' || parsed.protocol === 'https:') &&
      parsed.hostname.length > 0 &&
      parsed.username.length === 0 &&
      parsed.password.length === 0
    );
  } catch {
    return false;
  }
}

function isDateOnly(value) {
  if (typeof value !== 'string' || !datePattern.test(value)) {
    return false;
  }
  const date = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(date.valueOf()) && date.toISOString().slice(0, 10) === value;
}

function compareDateOnly(first, second) {
  return first.localeCompare(second);
}

function currentUtcDate() {
  return new Date().toISOString().slice(0, 10);
}

function makeIssue(code, definition, row = null, path = null) {
  return {
    code,
    collection: definition.collection,
    row,
    path,
  };
}

function sortIssues(issues) {
  return [...issues].sort((left, right) => {
    const leftKey = [
      left.collection,
      String(left.row ?? 0).padStart(8, '0'),
      left.path ?? '',
      left.code,
    ].join('\u0000');
    const rightKey = [
      right.collection,
      String(right.row ?? 0).padStart(8, '0'),
      right.path ?? '',
      right.code,
    ].join('\u0000');
    return leftKey.localeCompare(rightKey);
  });
}

function distinctIssues(issues) {
  const seen = new Set();
  return sortIssues(
    issues.filter((issue) => {
      const fingerprint = JSON.stringify(issue);
      if (seen.has(fingerprint)) {
        return false;
      }
      seen.add(fingerprint);
      return true;
    }),
  );
}

function resolveLocalReference(schema, reference) {
  if (!reference.startsWith('#/')) {
    throw new Error('Only local JSON Schema references are supported.');
  }
  return reference
    .slice(2)
    .split('/')
    .reduce((value, segment) => value?.[segment], schema);
}

function dereferenceSchema(schema, node) {
  let resolved = node;
  while (resolved?.$ref != null) {
    resolved = resolveLocalReference(schema, resolved.$ref);
  }
  return resolved;
}

function schemaAtPath(schema, path) {
  let cursor = schema;
  for (const segment of path.split('.')) {
    cursor = dereferenceSchema(schema, cursor);
    cursor = cursor?.properties?.[segment];
  }
  return dereferenceSchema(schema, cursor);
}

async function validationResources() {
  if (validationResourcesPromise == null) {
    validationResourcesPromise = (async () => {
      const schemas = await Promise.all(
        collectionDefinitions.map(async (definition) => {
          const raw = await readFile(
            join(templatesDirectory, definition.schemaFilename),
            'utf8',
          );
          return [definition.key, JSON.parse(raw)];
        }),
      );
      const ajv = new Ajv2020({ allErrors: true, strict: false });
      addFormats(ajv);
      return new Map(
        schemas.map(([key, schema]) => [
          key,
          {
            schema,
            validate: ajv.compile(schema),
          },
        ]),
      );
    })();
  }
  return validationResourcesPromise;
}

/**
 * Parse RFC 4180-style CSV without ever logging a cell value. The caller is
 * responsible for schema validation and reports only controlled paths/codes.
 */
export function parseCsv(csvText) {
  const source = csvText.charCodeAt(0) === 0xfeff ? csvText.slice(1) : csvText;
  const rows = [];
  let row = [];
  let field = '';
  let inQuotes = false;
  let quoteClosed = false;

  const finishField = () => {
    row.push(field);
    field = '';
    quoteClosed = false;
  };
  const finishRow = () => {
    finishField();
    rows.push(row);
    row = [];
  };

  for (let index = 0; index < source.length; index += 1) {
    const character = source[index];

    if (inQuotes) {
      if (character === '"') {
        if (source[index + 1] === '"') {
          field += '"';
          index += 1;
        } else {
          inQuotes = false;
          quoteClosed = true;
        }
      } else {
        field += character;
      }
      continue;
    }

    if (quoteClosed && character !== ',' && character !== '\r' && character !== '\n') {
      throw new Error('CSV_QUOTE_TERMINATION_INVALID');
    }

    if (character === '"') {
      if (field.length > 0) {
        throw new Error('CSV_QUOTE_POSITION_INVALID');
      }
      inQuotes = true;
      continue;
    }
    if (character === ',') {
      finishField();
      continue;
    }
    if (character === '\r') {
      if (source[index + 1] === '\n') {
        index += 1;
      }
      finishRow();
      continue;
    }
    if (character === '\n') {
      finishRow();
      continue;
    }
    field += character;
  }

  if (inQuotes) {
    throw new Error('CSV_UNTERMINATED_QUOTE');
  }
  if (field.length > 0 || row.length > 0) {
    finishRow();
  }
  return rows;
}

function setNestedValue(target, path, value) {
  const segments = path.split('.');
  let cursor = target;
  for (const segment of segments.slice(0, -1)) {
    cursor[segment] ??= {};
    cursor = cursor[segment];
  }
  cursor[segments.at(-1)] = value;
}

function permittedTypes(schema) {
  if (Array.isArray(schema?.type)) {
    return new Set(schema.type);
  }
  if (typeof schema?.type === 'string') {
    return new Set([schema.type]);
  }
  return new Set();
}

function coerceCsvCell(value, schema) {
  const types = permittedTypes(schema);
  if (value === '' && types.has('null')) {
    return null;
  }
  if (types.has('array')) {
    let parsed;
    try {
      parsed = JSON.parse(value);
    } catch {
      throw new Error('CSV_ARRAY_INVALID');
    }
    if (!Array.isArray(parsed)) {
      throw new Error('CSV_ARRAY_INVALID');
    }
    return parsed;
  }
  if (types.has('integer')) {
    if (!/^-?(?:0|[1-9]\d*)$/.test(value)) {
      throw new Error('CSV_INTEGER_INVALID');
    }
    const parsed = Number(value);
    if (!Number.isSafeInteger(parsed)) {
      throw new Error('CSV_INTEGER_INVALID');
    }
    return parsed;
  }
  if (types.has('boolean') || typeof schema?.const === 'boolean') {
    if (value === 'true') {
      return true;
    }
    if (value === 'false') {
      return false;
    }
    throw new Error('CSV_BOOLEAN_INVALID');
  }
  return value;
}

function sameHeader(actual, expected) {
  return (
    actual.length === expected.length &&
    actual.every((cell, index) => cell === expected[index])
  );
}

function parseCollectionCsv(csvText, definition, schema) {
  const errors = [];
  let rows;
  try {
    rows = parseCsv(csvText);
  } catch {
    return {
      records: [],
      errors: [makeIssue('CSV_SYNTAX_INVALID', definition, null, 'file')],
    };
  }

  const header = rows.shift();
  const expectedHeader = schema['x-csv-columns'];
  if (!Array.isArray(header) || !sameHeader(header, expectedHeader)) {
    return {
      records: [],
      errors: [makeIssue('CSV_HEADER_MISMATCH', definition, 1, 'header')],
    };
  }

  const mapping = schema['x-csv-to-json'] ?? Object.fromEntries(
    header.map((column) => [column, column]),
  );
  const records = [];
  rows.forEach((row, rowIndex) => {
    const csvRow = rowIndex + 2;
    if (row.every((cell) => cell.trim() === '')) {
      return;
    }
    if (row.length !== header.length) {
      errors.push(makeIssue('CSV_COLUMN_COUNT_INVALID', definition, csvRow, 'row'));
      return;
    }

    const record = {};
    row.forEach((cell, columnIndex) => {
      const path = mapping[header[columnIndex]];
      const fieldSchema = schemaAtPath(schema, path);
      try {
        setNestedValue(record, path, coerceCsvCell(cell, fieldSchema));
      } catch (error) {
        errors.push(makeIssue(error.message, definition, csvRow, `/${path.replaceAll('.', '/')}`));
      }
    });
    records.push(record);
  });

  return { records, errors };
}

/**
 * Reads the canonical five-file CSV batch. It never writes, imports, calls a
 * network service or logs data cells.
 */
export async function readDraftCsvDirectory(inputDirectory) {
  const resources = await validationResources();
  const batch = {};
  const errors = [];
  const directory = resolve(inputDirectory);

  await Promise.all(
    collectionDefinitions.map(async (definition) => {
      let csv;
      try {
        csv = await readFile(join(directory, definition.filename), 'utf8');
      } catch {
        batch[definition.key] = [];
        errors.push(makeIssue('INPUT_FILE_UNREADABLE', definition, null, 'file'));
        return;
      }
      const parsed = parseCollectionCsv(
        csv,
        definition,
        resources.get(definition.key).schema,
      );
      batch[definition.key] = parsed.records;
      errors.push(...parsed.errors);
    }),
  );

  return { batch, errors: distinctIssues(errors) };
}

function normaliseBatch(batch) {
  const collections = {};
  const errors = [];
  for (const definition of collectionDefinitions) {
    if (!Array.isArray(batch?.[definition.key])) {
      collections[definition.key] = [];
      errors.push(makeIssue('INPUT_COLLECTION_INVALID', definition, null, 'collection'));
      continue;
    }
    collections[definition.key] = batch[definition.key];
  }
  return { collections, errors };
}

function schemaIssueCode(definition, error) {
  const missingProperty = error.params?.missingProperty;
  const path = `${error.instancePath ?? ''}${
    missingProperty == null ? '' : `/${missingProperty}`
  }`;
  if (definition.key === 'sunnahContent' && path.startsWith('/locales')) {
    return 'TRANSLATION_INCOMPLETE';
  }
  if (definition.key === 'sourceRegister') {
    return 'SOURCE_METADATA_INVALID';
  }
  if (definition.key === 'evidence') {
    return 'EVIDENCE_METADATA_INVALID';
  }
  if (path === '/import_mode' || path === '/workflow_status' || path === '/non_publication_notice') {
    return 'DRAFT_BOUNDARY_INVALID';
  }
  return 'SCHEMA_INVALID';
}

function blankTextIssueCode(definition) {
  if (definition.key === 'sourceRegister') {
    return 'SOURCE_METADATA_BLANK';
  }
  if (definition.key === 'evidence') {
    return 'EVIDENCE_METADATA_BLANK';
  }
  if (definition.key === 'reviewers') {
    return 'REVIEWER_METADATA_BLANK';
  }
  if (definition.key === 'sunnahContent') {
    return 'CONTENT_METADATA_BLANK';
  }
  return 'METADATA_BLANK';
}

function validateTrimAwareRootStrings(errors, collections, resources) {
  for (const definition of collectionDefinitions) {
    const schema = resources.get(definition.key).schema;
    const stringFields = Object.entries(schema.properties ?? {})
      .filter(([, property]) => permittedTypes(property).has('string'))
      .map(([field]) => field);
    collections[definition.key].forEach((record, rowIndex) => {
      if (!isRecord(record)) {
        return;
      }
      for (const field of stringFields) {
        if (typeof record[field] === 'string' && record[field].trim().length === 0) {
          errors.push(
            makeIssue(blankTextIssueCode(definition), definition, rowIndex + 2, `/${field}`),
          );
        }
      }
    });
  }
}

function ajvPath(error) {
  const missingProperty = error.params?.missingProperty;
  return `${error.instancePath || '/'}${
    missingProperty == null ? '' : `/${missingProperty}`
  }`;
}

function indexedBy(records, keySelector) {
  const index = new Map();
  records.forEach((record, rowIndex) => {
    const key = keySelector(record);
    if (key != null && !index.has(key)) {
      index.set(key, { record, rowIndex });
    }
  });
  return index;
}

function addDuplicateErrors(errors, records, definition, keySelector, code, path) {
  const seen = new Map();
  records.forEach((record, rowIndex) => {
    const key = keySelector(record);
    if (key == null) {
      return;
    }
    if (seen.has(key)) {
      errors.push(makeIssue(code, definition, rowIndex + 2, path));
      return;
    }
    seen.set(key, rowIndex);
  });
}

function contentVersionKey(record) {
  if (
    !isRecord(record) ||
    typeof record.item_slug !== 'string' ||
    !Number.isInteger(record.version_number)
  ) {
    return null;
  }
  return `${record.item_slug}\u0000${record.version_number}`;
}

function contentEvidenceKey(record) {
  const contentKey = contentVersionKey(record);
  return contentKey != null && typeof record.evidence_key === 'string'
    ? `${contentKey}\u0000${record.evidence_key}`
    : null;
}

function contentDisplayOrderKey(record) {
  const contentKey = contentVersionKey(record);
  return contentKey != null && Number.isInteger(record.display_order)
    ? `${contentKey}\u0000${record.display_order}`
    : null;
}

function listOfStrings(record, field) {
  return isRecord(record) && Array.isArray(record[field])
    ? record[field].filter((value) => typeof value === 'string')
    : [];
}

function statusIsUsableForLicensedDisplay(status) {
  return usableLicensedStatuses.has(status);
}

function addLicensedStatusError(errors, definition, rowIndex, status, mode, path) {
  if (mode === 'LICENSED_CONTENT' && !statusIsUsableForLicensedDisplay(status)) {
    errors.push(makeIssue('LICENSED_RIGHTS_REQUIRED', definition, rowIndex + 2, path));
  }
}

function addRightsReadinessBlockers(
  blockers,
  definition,
  rowIndex,
  record,
  status,
  mode,
  path,
) {
  if (unresolvedRightsStatuses.has(status)) {
    blockers.push(makeIssue('RIGHTS_STATUS_BLOCKER', definition, rowIndex + 2, path));
  }
  if (
    mode === 'LINK_ONLY' &&
    definition.key === 'sourceRegister' &&
    !isUsableHttpUrl(record?.source_url)
  ) {
    blockers.push(makeIssue('LINK_ONLY_SOURCE_URL_REQUIRED', definition, rowIndex + 2, '/source_url'));
  }
}

function validateLocales(errors, blockers, contents) {
  const definition = definitionByKey.get('sunnahContent');
  contents.forEach((content, rowIndex) => {
    const locales = isRecord(content) ? content.locales : null;
    for (const localeCode of ['ms', 'en']) {
      const locale = isRecord(locales) ? locales[localeCode] : null;
      const localePath = `/locales/${localeCode}`;
      if (!isRecord(locale)) {
        errors.push(makeIssue('TRANSLATION_INCOMPLETE', definition, rowIndex + 2, localePath));
        continue;
      }
      if (locale.availability === 'COMPLETE') {
        for (const field of translationFields) {
          if (!isNonBlankString(locale[field])) {
            errors.push(
              makeIssue('TRANSLATION_INCOMPLETE', definition, rowIndex + 2, `${localePath}/${field}`),
            );
          }
        }
        if (locale.unavailable_rationale != null) {
          errors.push(
            makeIssue('TRANSLATION_STATE_CONTRADICTION', definition, rowIndex + 2, `${localePath}/unavailable_rationale`),
          );
        }
      } else if (locale.availability === 'UNAVAILABLE') {
        if (!isNonBlankString(locale.unavailable_rationale)) {
          errors.push(
            makeIssue('TRANSLATION_INCOMPLETE', definition, rowIndex + 2, `${localePath}/unavailable_rationale`),
          );
        }
        for (const field of translationFields) {
          if (locale[field] != null && locale[field] !== '') {
            errors.push(
              makeIssue('TRANSLATION_STATE_CONTRADICTION', definition, rowIndex + 2, `${localePath}/${field}`),
            );
          }
        }
        blockers.push(makeIssue('TRANSLATION_UNAVAILABLE_BLOCKER', definition, rowIndex + 2, localePath));
      } else {
        errors.push(makeIssue('TRANSLATION_INCOMPLETE', definition, rowIndex + 2, `${localePath}/availability`));
      }
    }
  });
}

function validateSourceDates(errors, blockers, sources, asOf) {
  const definition = definitionByKey.get('sourceRegister');
  sources.forEach((source, rowIndex) => {
    const accessedAt = source?.accessed_at;
    const reviewedAt = source?.reviewed_at;
    const expiresAt = source?.permission_expires_at;
    if (isDateOnly(accessedAt) && isDateOnly(reviewedAt) && compareDateOnly(reviewedAt, accessedAt) < 0) {
      errors.push(makeIssue('SOURCE_REVIEW_DATE_INVALID', definition, rowIndex + 2, '/reviewed_at'));
    }
    if (expiresAt != null && isDateOnly(expiresAt) && isDateOnly(reviewedAt) && compareDateOnly(expiresAt, reviewedAt) < 0) {
      errors.push(makeIssue('SOURCE_PERMISSION_DATE_INVALID', definition, rowIndex + 2, '/permission_expires_at'));
    }
    if (expiresAt != null && isDateOnly(expiresAt) && compareDateOnly(expiresAt, asOf) < 0) {
      blockers.push(makeIssue('RIGHTS_PERMISSION_EXPIRED', definition, rowIndex + 2, '/permission_expires_at'));
    }
  });
}

function validateSourcePermissionMetadata(blockers, sources) {
  const definition = definitionByKey.get('sourceRegister');
  sources.forEach((source, rowIndex) => {
    if (!isRecord(source)) {
      return;
    }
    if (source.permission_status === 'GRANTED' && !isNonBlankString(source.document_reference)) {
      blockers.push(makeIssue('RIGHTS_DOCUMENT_REFERENCE_REQUIRED', definition, rowIndex + 2, '/document_reference'));
    }
    if (source.permission_status === 'PUBLIC_LICENSE') {
      if (!isNonBlankString(source.licence)) {
        blockers.push(makeIssue('RIGHTS_LICENCE_REQUIRED', definition, rowIndex + 2, '/licence'));
      }
      if (!isNonBlankString(source.attribution_text)) {
        blockers.push(makeIssue('RIGHTS_ATTRIBUTION_REQUIRED', definition, rowIndex + 2, '/attribution_text'));
      }
    }
  });
}

function validateHttpUrls(errors, collections) {
  const sourceDefinition = definitionByKey.get('sourceRegister');
  const evidenceDefinition = definitionByKey.get('evidence');
  collections.sourceRegister.forEach((source, rowIndex) => {
    if (source?.source_url != null && !isUsableHttpUrl(source.source_url)) {
      errors.push(makeIssue('SOURCE_URL_INVALID', sourceDefinition, rowIndex + 2, '/source_url'));
    }
  });
  collections.evidence.forEach((item, rowIndex) => {
    if (item?.source_url != null && !isUsableHttpUrl(item.source_url)) {
      errors.push(makeIssue('EVIDENCE_URL_INVALID', evidenceDefinition, rowIndex + 2, '/source_url'));
    }
  });
}

function validateTrimAwareScopeLists(errors, contents) {
  const definition = definitionByKey.get('sunnahContent');
  contents.forEach((content, rowIndex) => {
    for (const field of ['audience_scopes', 'situation_scopes']) {
      if (!Array.isArray(content?.[field])) {
        continue;
      }
      if (content[field].some((scope) => typeof scope === 'string' && scope.trim().length === 0)) {
        errors.push(makeIssue('CONTENT_SCOPE_BLANK', definition, rowIndex + 2, `/${field}`));
      }
    }
  });
}

function validateReferencesAndRights(errors, blockers, collections) {
  const sources = indexedBy(collections.sourceRegister, (record) =>
    typeof record?.source_stable_key === 'string' ? record.source_stable_key : null,
  );
  const reviewers = indexedBy(collections.reviewers, (record) =>
    typeof record?.reviewer_code === 'string' ? record.reviewer_code : null,
  );
  const evidence = indexedBy(collections.evidence, (record) =>
    typeof record?.evidence_key === 'string' ? record.evidence_key : null,
  );
  const content = indexedBy(collections.sunnahContent, contentVersionKey);

  const sourceDefinition = definitionByKey.get('sourceRegister');
  const evidenceDefinition = definitionByKey.get('evidence');
  const contentDefinition = definitionByKey.get('sunnahContent');
  const linkDefinition = definitionByKey.get('contentEvidence');

  collections.sourceRegister.forEach((source, rowIndex) => {
    if (typeof source?.reviewed_by_reference === 'string' && !reviewers.has(source.reviewed_by_reference)) {
      errors.push(makeIssue('UNRESOLVED_REVIEWER_REFERENCE', sourceDefinition, rowIndex + 2, '/reviewed_by_reference'));
    }
    addLicensedStatusError(errors, sourceDefinition, rowIndex, source?.permission_status, source?.display_mode, '/permission_status');
    addRightsReadinessBlockers(
      blockers,
      sourceDefinition,
      rowIndex,
      source,
      source?.permission_status,
      source?.display_mode,
      '/permission_status',
    );
  });

  collections.evidence.forEach((item, rowIndex) => {
    const source = typeof item?.source_stable_key === 'string' ? sources.get(item.source_stable_key) : null;
    if (source == null) {
      errors.push(makeIssue('UNRESOLVED_SOURCE_REFERENCE', evidenceDefinition, rowIndex + 2, '/source_stable_key'));
    } else {
      if (item.source_permission_revision !== source.record.permission_revision) {
        errors.push(makeIssue('SOURCE_PERMISSION_REVISION_MISMATCH', evidenceDefinition, rowIndex + 2, '/source_permission_revision'));
      }
      if (item.rights_status !== source.record.permission_status) {
        errors.push(makeIssue('EVIDENCE_RIGHTS_MISMATCH', evidenceDefinition, rowIndex + 2, '/rights_status'));
      }
      if (item.display_mode !== source.record.display_mode) {
        errors.push(makeIssue('EVIDENCE_DISPLAY_MODE_MISMATCH', evidenceDefinition, rowIndex + 2, '/display_mode'));
      }
    }
    addLicensedStatusError(errors, evidenceDefinition, rowIndex, item?.rights_status, item?.display_mode, '/rights_status');
    addRightsReadinessBlockers(
      blockers,
      evidenceDefinition,
      rowIndex,
      item,
      item?.rights_status,
      item?.display_mode,
      '/rights_status',
    );
    for (const field of ['arabic_display_status', 'translation_status']) {
      if (
        item?.[field] === 'DISPLAY_RIGHTS_RECORDED' &&
        (item.display_mode !== 'LICENSED_CONTENT' || !statusIsUsableForLicensedDisplay(item.rights_status))
      ) {
        errors.push(makeIssue('EVIDENCE_TEXT_RIGHTS_CONTRADICTION', evidenceDefinition, rowIndex + 2, `/${field}`));
      }
      if (item?.[field] === 'RIGHTS_REVIEW_REQUIRED' && item.display_mode === 'LICENSED_CONTENT') {
        errors.push(makeIssue('EVIDENCE_TEXT_RIGHTS_CONTRADICTION', evidenceDefinition, rowIndex + 2, `/${field}`));
      }
    }
  });

  collections.sunnahContent.forEach((item, rowIndex) => {
    addLicensedStatusError(errors, contentDefinition, rowIndex, item?.source_rights_status, item?.display_mode, '/source_rights_status');
    addRightsReadinessBlockers(
      blockers,
      contentDefinition,
      rowIndex,
      item,
      item?.source_rights_status,
      item?.display_mode,
      '/source_rights_status',
    );

    for (const sourceKey of listOfStrings(item, 'source_stable_keys')) {
      const source = sources.get(sourceKey);
      if (source == null) {
        errors.push(makeIssue('UNRESOLVED_SOURCE_REFERENCE', contentDefinition, rowIndex + 2, '/source_stable_keys'));
        continue;
      }
      if (
        item.display_mode === 'LICENSED_CONTENT' &&
        (source.record.display_mode !== 'LICENSED_CONTENT' ||
          !statusIsUsableForLicensedDisplay(source.record.permission_status))
      ) {
        errors.push(makeIssue('CONTENT_SOURCE_RIGHTS_MISMATCH', contentDefinition, rowIndex + 2, '/source_stable_keys'));
      }
    }
    for (const evidenceKey of listOfStrings(item, 'evidence_keys')) {
      const evidenceRecord = evidence.get(evidenceKey);
      if (evidenceRecord == null) {
        errors.push(makeIssue('UNRESOLVED_EVIDENCE_REFERENCE', contentDefinition, rowIndex + 2, '/evidence_keys'));
        continue;
      }
      if (
        item.display_mode === 'LICENSED_CONTENT' &&
        (evidenceRecord.record.display_mode !== 'LICENSED_CONTENT' ||
          !statusIsUsableForLicensedDisplay(evidenceRecord.record.rights_status))
      ) {
        errors.push(makeIssue('CONTENT_EVIDENCE_RIGHTS_MISMATCH', contentDefinition, rowIndex + 2, '/evidence_keys'));
      }
      if (!listOfStrings(item, 'source_stable_keys').includes(evidenceRecord.record.source_stable_key)) {
        errors.push(makeIssue('CONTENT_EVIDENCE_SOURCE_UNDECLARED', contentDefinition, rowIndex + 2, '/source_stable_keys'));
      }
    }
    for (const reviewerCode of listOfStrings(item, 'reviewer_reference_keys')) {
      if (!reviewers.has(reviewerCode)) {
        errors.push(makeIssue('UNRESOLVED_REVIEWER_REFERENCE', contentDefinition, rowIndex + 2, '/reviewer_reference_keys'));
      }
    }
  });

  const linksByContent = new Map();
  const primaryLinksByContent = new Map();
  collections.contentEvidence.forEach((link, rowIndex) => {
    const contentKey = contentVersionKey(link);
    const contentRecord = contentKey == null ? null : content.get(contentKey);
    const evidenceRecord = typeof link?.evidence_key === 'string' ? evidence.get(link.evidence_key) : null;
    if (contentRecord == null) {
      errors.push(makeIssue('UNRESOLVED_CONTENT_REFERENCE', linkDefinition, rowIndex + 2, '/item_slug'));
    }
    if (evidenceRecord == null) {
      errors.push(makeIssue('UNRESOLVED_EVIDENCE_REFERENCE', linkDefinition, rowIndex + 2, '/evidence_key'));
    }
    if (contentRecord != null && evidenceRecord != null) {
      const declaredEvidence = listOfStrings(contentRecord.record, 'evidence_keys');
      if (!declaredEvidence.includes(link.evidence_key)) {
        errors.push(makeIssue('CONTENT_EVIDENCE_LINK_UNDECLARED', linkDefinition, rowIndex + 2, '/evidence_key'));
      }
      if (!listOfStrings(contentRecord.record, 'source_stable_keys').includes(evidenceRecord.record.source_stable_key)) {
        errors.push(makeIssue('CONTENT_EVIDENCE_SOURCE_UNDECLARED', linkDefinition, rowIndex + 2, '/evidence_key'));
      }
    }
    if (contentKey != null && typeof link?.evidence_key === 'string') {
      const evidenceKeys = linksByContent.get(contentKey) ?? new Set();
      evidenceKeys.add(link.evidence_key);
      linksByContent.set(contentKey, evidenceKeys);
      if (link.is_primary === true) {
        const primaryRows = primaryLinksByContent.get(contentKey) ?? [];
        primaryRows.push(rowIndex);
        primaryLinksByContent.set(contentKey, primaryRows);
      }
    }
  });

  content.forEach((contentRecord, contentKey) => {
    const linkedEvidence = linksByContent.get(contentKey) ?? new Set();
    for (const evidenceKey of listOfStrings(contentRecord.record, 'evidence_keys')) {
      if (!linkedEvidence.has(evidenceKey)) {
        errors.push(makeIssue('CONTENT_EVIDENCE_LINK_MISSING', contentDefinition, contentRecord.rowIndex + 2, '/evidence_keys'));
      }
    }
    const primaryRows = primaryLinksByContent.get(contentKey) ?? [];
    if (primaryRows.length !== 1) {
      errors.push(makeIssue('CONTENT_PRIMARY_EVIDENCE_INVALID', contentDefinition, contentRecord.rowIndex + 2, '/evidence_keys'));
    }
  });
}

function validateDuplicates(errors, collections) {
  addDuplicateErrors(
    errors,
    collections.sourceRegister,
    definitionByKey.get('sourceRegister'),
    (record) => (typeof record?.source_stable_key === 'string' ? record.source_stable_key : null),
    'DUPLICATE_SOURCE_STABLE_KEY',
    '/source_stable_key',
  );
  addDuplicateErrors(
    errors,
    collections.reviewers,
    definitionByKey.get('reviewers'),
    (record) => (typeof record?.reviewer_code === 'string' ? record.reviewer_code : null),
    'DUPLICATE_REVIEWER_CODE',
    '/reviewer_code',
  );
  addDuplicateErrors(
    errors,
    collections.evidence,
    definitionByKey.get('evidence'),
    (record) => (typeof record?.evidence_key === 'string' ? record.evidence_key : null),
    'DUPLICATE_EVIDENCE_KEY',
    '/evidence_key',
  );
  addDuplicateErrors(
    errors,
    collections.sunnahContent,
    definitionByKey.get('sunnahContent'),
    contentVersionKey,
    'DUPLICATE_CONTENT_VERSION',
    '/item_slug',
  );
  addDuplicateErrors(
    errors,
    collections.contentEvidence,
    definitionByKey.get('contentEvidence'),
    contentEvidenceKey,
    'DUPLICATE_CONTENT_EVIDENCE_LINK',
    '/evidence_key',
  );
  addDuplicateErrors(
    errors,
    collections.contentEvidence,
    definitionByKey.get('contentEvidence'),
    contentDisplayOrderKey,
    'DUPLICATE_CONTENT_EVIDENCE_ORDER',
    '/display_order',
  );
}

function reportFor(collections, errors, blockers, asOf) {
  const normalizedErrors = distinctIssues(errors);
  const normalizedBlockers = distinctIssues(blockers);
  const draftValid = normalizedErrors.length === 0;
  return {
    contract: 'STAGING_DRAFT_PREVIEW_ONLY',
    asOf,
    // `valid` is compatibility shorthand for the explicit draft-only state;
    // it never asserts publication readiness or human approval.
    valid: draftValid,
    draftValid,
    hasPublicReadinessBlockers: normalizedBlockers.length > 0,
    importedRecords: 0,
    publicationEligible: false,
    publicationEligibility: 'NOT_EVALUATED_BY_CNT_02',
    summary: {
      totalRows: Object.values(collections).reduce((total, rows) => total + rows.length, 0),
      collections: Object.fromEntries(
        collectionDefinitions.map((definition) => [
          definition.collection,
          collections[definition.key].length,
        ]),
      ),
      errorCount: normalizedErrors.length,
      blockerCount: normalizedBlockers.length,
    },
    errors: normalizedErrors,
    blockers: normalizedBlockers,
  };
}

/**
 * Validates canonical, parsed DRAFT/STAGING records. It is pure: no files,
 * database rows, network requests or publication actions are performed.
 */
export async function validateDraftBatch(batch, { asOf = currentUtcDate() } = {}) {
  if (!isDateOnly(asOf)) {
    throw new TypeError('asOf must be an ISO calendar date.');
  }
  const resources = await validationResources();
  const { collections, errors } = normaliseBatch(batch);
  const blockers = [];

  for (const definition of collectionDefinitions) {
    const validator = resources.get(definition.key).validate;
    collections[definition.key].forEach((record, rowIndex) => {
      if (validator(record)) {
        return;
      }
      for (const error of validator.errors ?? []) {
        errors.push(
          makeIssue(
            schemaIssueCode(definition, error),
            definition,
            rowIndex + 2,
            ajvPath(error),
          ),
        );
      }
    });
  }

  validateTrimAwareRootStrings(errors, collections, resources);
  validateTrimAwareScopeLists(errors, collections.sunnahContent);
  validateDuplicates(errors, collections);
  validateLocales(errors, blockers, collections.sunnahContent);
  validateSourceDates(errors, blockers, collections.sourceRegister, asOf);
  validateSourcePermissionMetadata(blockers, collections.sourceRegister);
  validateHttpUrls(errors, collections);
  validateReferencesAndRights(errors, blockers, collections);

  return reportFor(collections, errors, blockers, asOf);
}

/**
 * Verifies the CNT-01 contract, reads a CSV directory, then validates it.
 * This is still a preview: all writes/imports remain impossible here.
 */
export async function validateImportDirectory(inputDirectory, options = {}) {
  // A local ignored batch may legitimately sit in content/staging. Static
  // contract tests still assert that directory is clean in committed source,
  // while preview validation must not inspect or modify caller input first.
  await verifyContentContract({ assertBoundaryDirectories: false });
  const parsed = await readDraftCsvDirectory(inputDirectory);
  const report = await validateDraftBatch(parsed.batch, options);
  return reportFor(
    Object.fromEntries(
      collectionDefinitions.map((definition) => [
        definition.key,
        parsed.batch[definition.key] ?? [],
      ]),
    ),
    [...report.errors, ...parsed.errors],
    report.blockers,
    report.asOf,
  );
}

export function formatValidationReport(report, { json = false } = {}) {
  if (json) {
    return JSON.stringify(report, null, 2);
  }

  const lines = [
    'STAGING/DRAFT content validation preview',
    `Draft validation: ${report.draftValid ? 'PASSED' : 'FAILED'}.`,
    `Rows read: ${report.summary.totalRows}; records imported: 0.`,
    'Publication eligible: false (not evaluated by CNT-02).',
    `Errors: ${report.summary.errorCount}; public-readiness blockers: ${report.summary.blockerCount}.`,
  ];
  for (const issue of report.errors) {
    lines.push(`ERROR ${issue.code} ${issue.collection} row ${issue.row ?? '-'} ${issue.path ?? ''}`.trim());
  }
  for (const blocker of report.blockers) {
    lines.push(`BLOCKER ${blocker.code} ${blocker.collection} row ${blocker.row ?? '-'} ${blocker.path ?? ''}`.trim());
  }
  return lines.join('\n');
}

function usage() {
  return [
    'Usage: node scripts/validate_content.mjs --input <csv-batch-directory> [--as-of YYYY-MM-DD] [--json]',
    'Reads only the five canonical STAGING/DRAFT CSV files and never imports or publishes records.',
  ].join('\n');
}

function parseArguments(argv) {
  const options = { inputDirectory: null, asOf: currentUtcDate(), json: false };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === '--help' || argument === '-h') {
      return { help: true };
    }
    if (argument === '--json') {
      options.json = true;
      continue;
    }
    if (argument === '--input' || argument === '--as-of') {
      const value = argv[index + 1];
      if (value == null || value.startsWith('--')) {
        return { error: true };
      }
      if (argument === '--input') {
        options.inputDirectory = value;
      } else if (isDateOnly(value)) {
        options.asOf = value;
      } else {
        return { error: true };
      }
      index += 1;
      continue;
    }
    return { error: true };
  }
  return options.inputDirectory == null ? { error: true } : options;
}

export async function runContentValidationCli(
  argv,
  { stdout = console.log, stderr = console.error } = {},
) {
  const options = parseArguments(argv);
  if (options.help) {
    stdout(usage());
    return 0;
  }
  if (options.error) {
    stderr(usage());
    return 2;
  }
  try {
    const report = await validateImportDirectory(options.inputDirectory, {
      asOf: options.asOf,
    });
    stdout(formatValidationReport(report, { json: options.json }));
    return report.draftValid ? 0 : 1;
  } catch {
    stderr('Content validation could not complete. No data was imported or published.');
    return 2;
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  process.exitCode = await runContentValidationCli(process.argv.slice(2));
}
