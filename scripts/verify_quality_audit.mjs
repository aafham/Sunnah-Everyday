import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, statSync } from 'node:fs';
import { dirname, extname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseDocument } from 'yaml';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
export const qualityAuditRepositoryRoot = resolve(scriptDirectory, '..');

export const maximumBundledPayloadBytes = 512 * 1024;

/**
 * This guard intentionally complements QLT-02 rather than re-implementing it.
 * QLT-02 remains the authority for Android manifest, signing and credential
 * checks. This audit inventories every direct manifest dependency and applies
 * a broader, static Dart-network boundary across every production workspace.
 */
export const qualityAuditScopeLimitations = Object.freeze([
  'Examines tracked direct dependency manifests and tracked production Dart source only.',
  'Does not resolve transitive dependencies, inspect runtime traffic, or prove SDK behaviour.',
  'Uses a no-declared-Flutter-bundle and bounded-binary structural baseline; it does not measure built APK/web output, startup time, memory, or dynamic downloads.',
  'Does not replace QLT-02, a signed-release audit, Play Data Safety review, privacy assessment, or content/release gate.',
]);

const dependencySectionsByType = Object.freeze({
  node: Object.freeze([
    'dependencies',
    'devDependencies',
    'optionalDependencies',
    'peerDependencies',
    'bundledDependencies',
  ]),
  pubspec: Object.freeze([
    'dependencies',
    'dev_dependencies',
    'dependency_overrides',
  ]),
});

const manifestDefinitions = Object.freeze([
  Object.freeze({
    path: 'package.json',
    type: 'node',
    expectedDependencies: Object.freeze({
      dependencies: Object.freeze([]),
      devDependencies: Object.freeze(['ajv', 'ajv-formats', 'yaml']),
      optionalDependencies: Object.freeze([]),
      peerDependencies: Object.freeze([]),
      bundledDependencies: Object.freeze([]),
    }),
  }),
  Object.freeze({
    path: 'apps/mobile/pubspec.yaml',
    type: 'pubspec',
    expectedDependencies: Object.freeze({
      dependencies: Object.freeze([
        'characters',
        'design_system',
        'flutter',
        'flutter_localizations',
        'flutter_riverpod',
        'flutter_secure_storage',
        'go_router',
        'intl',
        'shared_preferences',
      ]),
      dev_dependencies: Object.freeze([
        'flutter_lints',
        'flutter_test',
        'integration_test',
        'testing_utils',
      ]),
      dependency_overrides: Object.freeze([]),
    }),
  }),
  Object.freeze({
    path: 'apps/admin/pubspec.yaml',
    type: 'pubspec',
    expectedDependencies: Object.freeze({
      dependencies: Object.freeze([
        'design_system',
        'flutter',
        'flutter_riverpod',
        'go_router',
      ]),
      dev_dependencies: Object.freeze([
        'flutter_lints',
        'flutter_test',
        'testing_utils',
      ]),
      dependency_overrides: Object.freeze([]),
    }),
  }),
  Object.freeze({
    path: 'packages/content_models/pubspec.yaml',
    type: 'pubspec',
    expectedDependencies: Object.freeze({
      dependencies: Object.freeze([]),
      dev_dependencies: Object.freeze(['lints', 'test']),
      dependency_overrides: Object.freeze([]),
    }),
  }),
  Object.freeze({
    path: 'packages/design_system/pubspec.yaml',
    type: 'pubspec',
    expectedDependencies: Object.freeze({
      dependencies: Object.freeze(['flutter']),
      dev_dependencies: Object.freeze([
        'flutter_lints',
        'flutter_test',
        'testing_utils',
      ]),
      dependency_overrides: Object.freeze([]),
    }),
  }),
  Object.freeze({
    path: 'packages/testing_utils/pubspec.yaml',
    type: 'pubspec',
    expectedDependencies: Object.freeze({
      dependencies: Object.freeze(['flutter', 'flutter_test']),
      dev_dependencies: Object.freeze(['flutter_lints']),
      dependency_overrides: Object.freeze([]),
    }),
  }),
]);

export const qualityAuditManifestPaths = Object.freeze(
  manifestDefinitions.map(({ path }) => path),
);

const manifestDefinitionByPath = new Map(
  manifestDefinitions.map((definition) => [definition.path, definition]),
);

const productionDartRoots = Object.freeze([
  'apps/admin/lib/',
  'apps/mobile/lib/',
  'packages/content_models/lib/',
  'packages/design_system/lib/',
  'packages/testing_utils/lib/',
]);

const prohibitedDependencyNames = new Set([
  '@apollo/client',
  '@supabase/supabase-js',
  'admob_flutter',
  'adjust_sdk',
  'amplitude_flutter',
  'analytics-node',
  'apollo-client',
  'appsflyer_sdk',
  'axios',
  'branch_sdk',
  'bugsnag_flutter',
  'chopper',
  'clevertap_plugin',
  'countly_flutter',
  'datadog_flutter_plugin',
  'dio',
  'facebook_app_events',
  'firebase',
  'firebase-admin',
  'firebase_analytics',
  'firebase_core',
  'firebase_crashlytics',
  'firebase_messaging',
  'firebase_performance',
  'google_mobile_ads',
  'got',
  'graphql_flutter',
  'graphql-request',
  'http',
  'instabug_flutter',
  'mixpanel',
  'mixpanel_flutter',
  'newrelic_mobile',
  'node-fetch',
  'onesignal_flutter',
  'posthog_flutter',
  'posthog-node',
  'request',
  'retrofit',
  'sentry_flutter',
  'segment_analytics',
  'socket.io-client',
  'stripe',
  'superagent',
  'supabase_flutter',
  'undici',
  'universal_io',
  'web_socket_channel',
  'ws',
]);

const prohibitedDependencyPatterns = Object.freeze([
  /^@(?:amplitude|apollo|bugsnag|datadog|firebase|google-analytics|posthog|segment|sentry|supabase)\//,
  /^(?:firebase|sentry|supabase)(?:[_-]|$)/,
  /(?:^|[_-])(?:analytics?|telemetry|crash(?:lytics|reporting)?|advertis(?:ing|ement)|ads?|attribution)(?:[_-]|$)/,
]);

const directDartNetworkPatterns = Object.freeze([
  /\bimport\s+['"]dart:(?:io|html)['"]/i,
  /\b(?:HttpClient|HttpClientRequest|HttpClientResponse|HttpRequest|HttpServer|InternetAddress|RawDatagramSocket|SecureSocket|Socket|WebSocket|XmlHttpRequest)\b/,
  /\bUri\.parse\s*\(\s*['"]https?:\/\//i,
  /\bUri\.(?:http|https)\s*\(\s*['"]/i,
]);

const allowedContentBoundaryPaths = new Set([
  'content/approved/.gitignore',
  'content/approved/.gitkeep',
  'content/approved/README.md',
  'content/staging/.gitignore',
  'content/staging/.gitkeep',
  'content/staging/README.md',
]);

const bundledBinaryExtensions = new Set([
  '.7z',
  '.aac',
  '.avi',
  '.bin',
  '.bmp',
  '.br',
  '.dat',
  '.flac',
  '.gif',
  '.gz',
  '.ico',
  '.jar',
  '.jpeg',
  '.jpg',
  '.m4a',
  '.mov',
  '.mp3',
  '.mp4',
  '.ogg',
  '.otf',
  '.pdf',
  '.png',
  '.tar',
  '.ttf',
  '.wav',
  '.webm',
  '.webp',
  '.woff',
  '.woff2',
  '.zip',
]);

function addFinding(findings, code, detail) {
  findings.push({ code, detail });
}

function normalisePath(path) {
  return path.replaceAll('\\', '/');
}

function stablePaths(paths) {
  return [...new Set(paths.map(normalisePath))].sort();
}

function isPlainObject(value) {
  return value != null && typeof value === 'object' && !Array.isArray(value);
}

function isTrackedManifestPath(path) {
  return (
    path === 'package.json' ||
    path.endsWith('/package.json') ||
    path.endsWith('/pubspec.yaml')
  );
}

function isProductionDartPath(path) {
  return (
    path.endsWith('.dart') &&
    productionDartRoots.some((root) => path.startsWith(root))
  );
}

function parseManifestSource(definition, source, findings) {
  if (typeof source !== 'string') {
    addFinding(
      findings,
      'QUALITY_AUDIT_MANIFEST_MISSING',
      `Required dependency manifest is unavailable: ${definition.path}.`,
    );
    return null;
  }

  if (definition.type === 'node') {
    try {
      const manifest = JSON.parse(source);
      if (!isPlainObject(manifest)) {
        addFinding(
          findings,
          'QUALITY_AUDIT_MANIFEST_SHAPE',
          `${definition.path} must be a JSON object.`,
        );
        return null;
      }
      return manifest;
    } catch {
      addFinding(
        findings,
        'QUALITY_AUDIT_MANIFEST_PARSE',
        `${definition.path} must be valid JSON.`,
      );
      return null;
    }
  }

  const document = parseDocument(source, { uniqueKeys: true });
  if (document.errors.length > 0) {
    addFinding(
      findings,
      'QUALITY_AUDIT_MANIFEST_PARSE',
      `${definition.path} must be valid YAML with unique keys.`,
    );
    return null;
  }
  const manifest = document.toJS();
  if (!isPlainObject(manifest)) {
    addFinding(
      findings,
      'QUALITY_AUDIT_MANIFEST_SHAPE',
      `${definition.path} must be a YAML mapping.`,
    );
    return null;
  }
  return manifest;
}

function parseDependencySection({ manifest, section, definition, findings }) {
  const value = manifest[section];
  if (value == null) {
    return [];
  }

  if (definition.type === 'node' && section === 'bundledDependencies') {
    if (!Array.isArray(value) || value.some((name) => typeof name !== 'string')) {
      addFinding(
        findings,
        'QUALITY_AUDIT_DEPENDENCY_SECTION_SHAPE',
        `${definition.path} ${section} must be an array of package names.`,
      );
      return [];
    }
    return [...new Set(value)].sort();
  }

  if (!isPlainObject(value)) {
    addFinding(
      findings,
      'QUALITY_AUDIT_DEPENDENCY_SECTION_SHAPE',
      `${definition.path} ${section} must be a dependency mapping.`,
    );
    return [];
  }
  return Object.keys(value).sort();
}

function isProhibitedProductionDependency(name) {
  const normalisedName = name.toLowerCase();
  return (
    prohibitedDependencyNames.has(normalisedName) ||
    prohibitedDependencyPatterns.some((pattern) => pattern.test(normalisedName))
  );
}

function validateDependencyInventory(definition, manifest, findings) {
  const inventory = {};
  const sectionNames = dependencySectionsByType[definition.type];
  const seenNames = new Map();

  for (const section of sectionNames) {
    const actualNames = parseDependencySection({
      manifest,
      section,
      definition,
      findings,
    });
    inventory[section] = actualNames;
    const expectedNames = definition.expectedDependencies[section] ?? [];
    const actualNameSet = new Set(actualNames);
    const expectedNameSet = new Set(expectedNames);

    for (const name of actualNames) {
      if (!expectedNameSet.has(name)) {
        addFinding(
          findings,
          'QUALITY_AUDIT_UNREVIEWED_DIRECT_DEPENDENCY',
          `Unreviewed direct dependency ${name} in ${definition.path} (${section}).`,
        );
      }
      if (isProhibitedProductionDependency(name)) {
        addFinding(
          findings,
          'QUALITY_AUDIT_PROHIBITED_SDK',
          `Prohibited analytics, ads, networking, or crash SDK ${name} in ${definition.path}.`,
        );
      }
      if (seenNames.has(name)) {
        addFinding(
          findings,
          'QUALITY_AUDIT_DUPLICATE_DIRECT_DEPENDENCY',
          `Direct dependency ${name} appears in both ${seenNames.get(name)} and ${section} of ${definition.path}.`,
        );
      } else {
        seenNames.set(name, section);
      }
    }

    for (const name of expectedNames) {
      if (!actualNameSet.has(name)) {
        addFinding(
          findings,
          'QUALITY_AUDIT_DEPENDENCY_INVENTORY_DRIFT',
          `Reviewed direct dependency ${name} is missing from ${definition.path} (${section}).`,
        );
      }
    }
  }

  return inventory;
}

function validateManifestInventories(surface, findings) {
  const trackedManifestPaths = stablePaths(surface.trackedPaths).filter(
    isTrackedManifestPath,
  );
  const trackedManifestPathSet = new Set(trackedManifestPaths);
  const parsedManifests = {};

  for (const definition of manifestDefinitions) {
    if (!trackedManifestPathSet.has(definition.path)) {
      addFinding(
        findings,
        'QUALITY_AUDIT_MANIFEST_UNTRACKED',
        `Required dependency manifest is not tracked: ${definition.path}.`,
      );
    }
    const manifest = parseManifestSource(
      definition,
      surface.manifests[definition.path],
      findings,
    );
    if (manifest == null) {
      continue;
    }
    parsedManifests[definition.path] = manifest;
    validateDependencyInventory(definition, manifest, findings);
  }

  for (const path of trackedManifestPaths) {
    if (!manifestDefinitionByPath.has(path)) {
      addFinding(
        findings,
        'QUALITY_AUDIT_UNINVENTORIED_MANIFEST',
        `Tracked dependency manifest is outside the reviewed inventory: ${path}.`,
      );
    }
  }

  return parsedManifests;
}

function validateDartNetworkSurface(surface, findings) {
  const trackedDartPaths = stablePaths(surface.trackedPaths).filter(
    isProductionDartPath,
  );
  const sourcePaths = stablePaths(Object.keys(surface.dartSources));
  const sourcePathSet = new Set(sourcePaths);
  const trackedDartPathSet = new Set(trackedDartPaths);

  for (const path of trackedDartPaths) {
    if (!sourcePathSet.has(path)) {
      addFinding(
        findings,
        'QUALITY_AUDIT_DART_SOURCE_MISSING',
        `Tracked production Dart source was not available for audit: ${path}.`,
      );
    }
  }
  for (const path of sourcePaths) {
    if (!trackedDartPathSet.has(path)) {
      addFinding(
        findings,
        'QUALITY_AUDIT_DART_SOURCE_UNTRACKED',
        `Dart source outside the tracked production inventory was supplied: ${path}.`,
      );
      continue;
    }
    const source = surface.dartSources[path];
    if (typeof source !== 'string') {
      addFinding(
        findings,
        'QUALITY_AUDIT_DART_SOURCE_MISSING',
        `Tracked production Dart source was not readable: ${path}.`,
      );
      continue;
    }
    if (directDartNetworkPatterns.some((pattern) => pattern.test(source))) {
      addFinding(
        findings,
        'QUALITY_AUDIT_DIRECT_DART_NETWORK_API',
        `Direct Dart networking API is not allowed in production source: ${path}.`,
      );
    }
  }
}

function validateFlutterBundleDeclarations(parsedManifests, findings) {
  for (const [path, manifest] of Object.entries(parsedManifests).sort(
    ([left], [right]) => left.localeCompare(right),
  )) {
    const flutter = manifest.flutter;
    if (flutter == null) {
      continue;
    }
    if (!isPlainObject(flutter)) {
      addFinding(
        findings,
        'QUALITY_AUDIT_FLUTTER_SECTION_SHAPE',
        `${path} flutter configuration must be a mapping.`,
      );
      continue;
    }
    for (const field of ['assets', 'fonts']) {
      const declared = flutter[field];
      if (declared == null) {
        continue;
      }
      if (!Array.isArray(declared)) {
        addFinding(
          findings,
          'QUALITY_AUDIT_BUNDLE_DECLARATION_SHAPE',
          `${path} flutter.${field} must be a list when present.`,
        );
        continue;
      }
      if (declared.length > 0) {
        addFinding(
          findings,
          'QUALITY_AUDIT_BUNDLED_ASSET_DECLARATION',
          `${path} declares bundled Flutter ${field}; the current no-declared-Flutter-bundle baseline requires review.`,
        );
      }
    }
  }
}

function isContentBoundaryPath(path) {
  return path.startsWith('content/approved/') || path.startsWith('content/staging/');
}

function isAllowedContentBoundaryFile(path) {
  return allowedContentBoundaryPaths.has(path);
}

function isPotentialBundlePath(path) {
  return (
    path.startsWith('assets/') ||
    /^apps\/(?:admin|mobile)\/assets\//.test(path) ||
    /^apps\/mobile\/android\/app\/src\/main\/res\//.test(path) ||
    /^apps\/admin\/web\/(?:assets|icons)\//.test(path) ||
    /^packages\/[^/]+\/(?:assets|fonts)\//.test(path)
  );
}

function validateStructuralPerformanceBaseline(surface, parsedManifests, findings) {
  validateFlutterBundleDeclarations(parsedManifests, findings);

  for (const path of stablePaths(surface.trackedPaths)) {
    if (isContentBoundaryPath(path) && !isAllowedContentBoundaryFile(path)) {
      addFinding(
        findings,
        'QUALITY_AUDIT_CONTENT_BOUNDARY_PAYLOAD',
        `A tracked content payload is present in an empty boundary: ${path}.`,
      );
    }

    if (!isPotentialBundlePath(path) || !bundledBinaryExtensions.has(extname(path).toLowerCase())) {
      continue;
    }
    const size = surface.trackedFileSizes[path];
    if (!Number.isSafeInteger(size) || size < 0) {
      addFinding(
        findings,
        'QUALITY_AUDIT_BUNDLED_PAYLOAD_SIZE_UNKNOWN',
        `Bundled payload size is unavailable: ${path}.`,
      );
      continue;
    }
    if (size > maximumBundledPayloadBytes) {
      addFinding(
        findings,
        'QUALITY_AUDIT_LARGE_BUNDLED_PAYLOAD',
        `Bundled binary payload exceeds ${maximumBundledPayloadBytes} bytes: ${path}.`,
      );
    }
  }
}

/**
 * Validates a read-only source snapshot. Findings contain only policy codes,
 * paths and dependency names; they never include source text, values or secrets.
 */
export function validateQualityAuditSurface(surface) {
  const findings = [];
  const parsedManifests = validateManifestInventories(surface, findings);
  validateDartNetworkSurface(surface, findings);
  validateStructuralPerformanceBaseline(surface, parsedManifests, findings);
  return { valid: findings.length === 0, findings };
}

function trackedPaths(root) {
  return stablePaths(
    execFileSync('git', ['-C', root, 'ls-files', '-z'], {
      encoding: 'utf8',
      windowsHide: true,
    })
      .split('\0')
      .filter((path) => path.length > 0),
  );
}

function readTrackedText(root, path) {
  const absolutePath = join(root, path);
  return existsSync(absolutePath) ? readFileSync(absolutePath, 'utf8') : undefined;
}

/**
 * Reads only local tracked files. It does not write files, resolve packages,
 * call a network service, or print dependency values/source content.
 */
export function readQualityAuditSurface({ root = qualityAuditRepositoryRoot } = {}) {
  const paths = trackedPaths(root);
  const manifests = Object.fromEntries(
    manifestDefinitions.map(({ path }) => [path, readTrackedText(root, path)]),
  );
  const dartSources = {};
  const trackedFileSizes = {};

  for (const path of paths) {
    const absolutePath = join(root, path);
    if (!existsSync(absolutePath)) {
      continue;
    }
    trackedFileSizes[path] = statSync(absolutePath).size;
    if (isProductionDartPath(path)) {
      dartSources[path] = readFileSync(absolutePath, 'utf8');
    }
  }

  return {
    manifests,
    trackedPaths: paths,
    dartSources,
    trackedFileSizes,
  };
}

export function verifyQualityAudit({ root = qualityAuditRepositoryRoot } = {}) {
  const result = validateQualityAuditSurface(readQualityAuditSurface({ root }));
  if (!result.valid) {
    const summary = result.findings
      .map(({ code, detail }) => `${code}: ${detail}`)
      .join('\n');
    throw new Error(`Quality audit verification failed.\n${summary}`);
  }
  return result;
}

const isDirectExecution =
  process.argv[1] != null &&
  resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isDirectExecution) {
  verifyQualityAudit();
  process.stdout.write(
    'Quality audit passed. Static scope only: tracked direct manifests, Dart APIs and the no-declared-Flutter-bundle baseline; not a release or Data Safety audit.\n',
  );
}
