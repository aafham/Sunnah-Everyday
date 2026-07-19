import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, extname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseDocument } from 'yaml';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
export const repositoryRoot = resolve(scriptDirectory, '..');

const mobilePaths = Object.freeze({
  mainManifest: 'apps/mobile/android/app/src/main/AndroidManifest.xml',
  debugManifest: 'apps/mobile/android/app/src/debug/AndroidManifest.xml',
  profileManifest: 'apps/mobile/android/app/src/profile/AndroidManifest.xml',
  appBuildGradle: 'apps/mobile/android/app/build.gradle.kts',
  pubspec: 'apps/mobile/pubspec.yaml',
  dartSourceDirectory: 'apps/mobile/lib',
});

const prohibitedNetworkDependencies = new Set([
  'amplitude_flutter',
  'appsflyer_sdk',
  'chopper',
  'dio',
  'facebook_app_events',
  'firebase_analytics',
  'firebase_core',
  'firebase_crashlytics',
  'graphql_flutter',
  'http',
  'mixpanel_flutter',
  'posthog_flutter',
  'retrofit',
  'sentry_flutter',
  'segment_analytics',
  'supabase_flutter',
]);

const prohibitedImportPackages = [
  'amplitude_flutter',
  'appsflyer_sdk',
  'chopper',
  'dio',
  'facebook_app_events',
  'firebase_[A-Za-z0-9_]*',
  'graphql_flutter',
  'http',
  'mixpanel_flutter',
  'posthog_flutter',
  'retrofit',
  'sentry_flutter',
  'segment_analytics',
  'supabase_flutter',
].join('|');

const credentialFileExtensions = new Set([
  '.jks',
  '.keystore',
  '.key',
  '.p12',
  '.pem',
  '.pfx',
  '.p8',
]);

const textFileExtensions = new Set([
  '.bat',
  '.css',
  '.dart',
  '.gradle',
  '.html',
  '.java',
  '.js',
  '.json',
  '.kts',
  '.kt',
  '.md',
  '.mjs',
  '.ps1',
  '.properties',
  '.sh',
  '.sql',
  '.toml',
  '.txt',
  '.ts',
  '.tsx',
  '.xml',
  '.yaml',
  '.yml',
]);

const credentialPatterns = Object.freeze([
  Object.freeze({
    code: 'MOBILE_PRIVATE_KEY',
    pattern: /-----BEGIN(?: [A-Z0-9]+)? PRIVATE KEY-----/,
  }),
  Object.freeze({
    code: 'MOBILE_GOOGLE_API_KEY',
    pattern: /AIza[0-9A-Za-z_-]{35}/,
  }),
  Object.freeze({
    code: 'MOBILE_GITHUB_TOKEN',
    pattern: /(?:gh[pousr]_|github_pat_)[0-9A-Za-z_]{20,}/,
  }),
  Object.freeze({
    code: 'MOBILE_AWS_ACCESS_KEY',
    pattern: /\b(?:AKIA|ASIA)[A-Z0-9]{16}\b/,
  }),
  Object.freeze({
    code: 'MOBILE_STRIPE_LIVE_KEY',
    pattern: /\b(?:sk|rk)_live_[0-9A-Za-z]{16,}\b/,
  }),
  Object.freeze({
    code: 'MOBILE_SLACK_TOKEN',
    pattern: /\bxox[baprs]-[0-9A-Za-z-]{10,}\b/,
  }),
  Object.freeze({
    code: 'MOBILE_SUPABASE_SERVICE_ROLE_VALUE',
    pattern:
      /(?:SUPABASE_SERVICE_ROLE_KEY|service_role)\s*[:=]\s*['"][^'"\r\n]{8,}['"]/i,
  }),
  Object.freeze({
    code: 'MOBILE_SERVICE_ACCOUNT_JSON',
    pattern: /"type"\s*:\s*"service_account"/,
  }),
]);

function addFinding(findings, code, detail) {
  findings.push({ code, detail });
}

function normalisePath(path) {
  return path.replaceAll('\\', '/');
}

function permissionNames(manifest) {
  return [...manifest.matchAll(/<uses-permission(?:-[\w-]+)?\b[^>]*>/gi)]
    .map((match) =>
      /\bandroid:name\s*=\s*"([^"]+)"/i.exec(match[0])?.[1] ?? '',
    )
    .filter((name) => name.length > 0);
}

function validateMainManifest(mainManifest, findings) {
  if (/<uses-permission(?:-[\w-]+)?\b/i.test(mainManifest)) {
    addFinding(
      findings,
      'MOBILE_MAIN_PERMISSION',
      'The shipped Android manifest must not request a permission.',
    );
  }
  if (!/\bandroid:allowBackup\s*=\s*"false"/i.test(mainManifest)) {
    addFinding(
      findings,
      'MOBILE_BACKUP_GUARD',
      'The shipped Android manifest must explicitly disable backups.',
    );
  }
  if (/\bandroid:usesCleartextTraffic\s*=\s*"true"/i.test(mainManifest)) {
    addFinding(
      findings,
      'MOBILE_CLEARTEXT_TRAFFIC',
      'The shipped Android manifest must not enable cleartext traffic.',
    );
  }
  if (/\bandroid:debuggable\s*=\s*"true"/i.test(mainManifest)) {
    addFinding(
      findings,
      'MOBILE_DEBUGGABLE_RELEASE',
      'The shipped Android manifest must not mark the app debuggable.',
    );
  }
  if (/\bandroid:autoVerify\s*=/i.test(mainManifest)) {
    addFinding(
      findings,
      'MOBILE_UNVERIFIED_APP_LINK',
      'No Android App Link may be claimed before a verified public domain exists.',
    );
  }
}

function validateToolingManifest(manifest, flavor, findings) {
  const permissions = permissionNames(manifest);
  if (
    permissions.length !== 1 ||
    permissions[0] !== 'android.permission.INTERNET'
  ) {
    addFinding(
      findings,
      'MOBILE_TOOLING_PERMISSION_ALLOWLIST',
      `${flavor} may request only INTERNET for local Flutter tooling.`,
    );
  }
}

function validateReleaseGuard(appBuildGradle, findings) {
  const requiredFragments = [
    /tasks\.configureEach/,
    /name\.contains\(\s*"Release"\s*,\s*ignoreCase\s*=\s*true\s*\)/,
    /throw\s+GradleException\s*\(/,
  ];
  if (requiredFragments.some((fragment) => !fragment.test(appBuildGradle))) {
    addFinding(
      findings,
      'MOBILE_RELEASE_GUARD',
      'Release Gradle tasks must fail closed until REL-03 signing readiness.',
    );
  }
  if (
    /\bsigningConfigs?\b|\bstore(?:File|Password)\b|\bkey(?:Alias|Password)\b/i.test(
      appBuildGradle,
    )
  ) {
    addFinding(
      findings,
      'MOBILE_RELEASE_SIGNING_CONFIG',
      'Release signing material/configuration is not allowed before REL-03.',
    );
  }
  if (/signingConfig\s*=\s*signingConfigs\.getByName\(\s*"debug"/i.test(appBuildGradle)) {
    addFinding(
      findings,
      'MOBILE_DEBUG_SIGNING_REUSE',
      'Release builds must never reuse the debug signing configuration.',
    );
  }
}

function parseDependencyNames(mobilePubspec, findings) {
  const document = parseDocument(mobilePubspec, { uniqueKeys: true });
  if (document.errors.length > 0) {
    addFinding(
      findings,
      'MOBILE_PUBSPEC_PARSE',
      'apps/mobile/pubspec.yaml must remain valid YAML.',
    );
    return [];
  }
  const dependencies = document.toJS()?.dependencies;
  if (dependencies == null || typeof dependencies !== 'object') {
    addFinding(
      findings,
      'MOBILE_DEPENDENCIES_MISSING',
      'apps/mobile/pubspec.yaml must define dependencies.',
    );
    return [];
  }
  return Object.keys(dependencies);
}

function validateNetworkSurface(mobilePubspec, dartSources, findings) {
  const dependencies = parseDependencyNames(mobilePubspec, findings);
  for (const dependency of dependencies) {
    if (
      prohibitedNetworkDependencies.has(dependency) ||
      dependency.startsWith('firebase_')
    ) {
      addFinding(
        findings,
        'MOBILE_NETWORK_DEPENDENCY',
        `Unreviewed production network/telemetry dependency: ${dependency}.`,
      );
    }
  }

  const importPattern = new RegExp(
    `import\\s+['"]package:(?:${prohibitedImportPackages})(?:/|['"])`,
    'i',
  );
  const staticNetworkUriPattern = /Uri\.parse\(\s*['"]https?:\/\//i;
  for (const [path, source] of Object.entries(dartSources)) {
    if (importPattern.test(source) || staticNetworkUriPattern.test(source)) {
      addFinding(
        findings,
        'MOBILE_NETWORK_SOURCE',
        `Unreviewed production network access in ${path}.`,
      );
    }
  }
}

function isForbiddenCredentialPath(path) {
  const normalized = normalisePath(path);
  const fileName = normalized.slice(normalized.lastIndexOf('/') + 1).toLowerCase();
  return (
    credentialFileExtensions.has(extname(fileName)) ||
    fileName === '.env' ||
    /^\.env\.(?:development|local|production|staging)$/i.test(fileName) ||
    fileName === 'google-services.json' ||
    fileName.includes('service-account')
  );
}

function isCredentialCandidatePath(path) {
  const normalized = normalisePath(path);
  const fileName = normalized.slice(normalized.lastIndexOf('/') + 1).toLowerCase();
  if (
    /(?:^|\/)build(?:\/|$)/.test(normalized) ||
    normalized.endsWith('.lock')
  ) {
    return false;
  }
  return (
    fileName.startsWith('.env') ||
    fileName === 'dockerfile' ||
    fileName === 'makefile' ||
    textFileExtensions.has(extname(normalized))
  );
}

function validateCredentialCandidates(credentialCandidates, findings) {
  for (const [path, source] of Object.entries(credentialCandidates)) {
    if (isForbiddenCredentialPath(path)) {
      addFinding(
        findings,
        'MOBILE_COMMITTED_CREDENTIAL_FILE',
        `Credential-bearing file is tracked: ${path}.`,
      );
      continue;
    }
    for (const { code, pattern } of credentialPatterns) {
      if (pattern.test(source)) {
        addFinding(
          findings,
          code,
          `Credential-shaped value found in ${path}.`,
        );
      }
    }
  }
}

/**
 * Validates the reviewed, shipped-mobile security boundary and tracked
 * credential surface. It never reports credential values.
 */
export function validateMobileSecuritySurface({
  mainManifest,
  debugManifest,
  profileManifest,
  appBuildGradle,
  mobilePubspec,
  dartSources,
  credentialCandidates,
}) {
  const findings = [];
  validateMainManifest(mainManifest, findings);
  validateToolingManifest(debugManifest, 'debug', findings);
  validateToolingManifest(profileManifest, 'profile', findings);
  validateReleaseGuard(appBuildGradle, findings);
  validateNetworkSurface(mobilePubspec, dartSources, findings);
  validateCredentialCandidates(credentialCandidates, findings);
  return { valid: findings.length === 0, findings };
}

function collectDartSources(root, directory) {
  const sources = {};
  const visit = (currentDirectory) => {
    for (const entry of readdirSync(currentDirectory, { withFileTypes: true })) {
      const filePath = join(currentDirectory, entry.name);
      if (entry.isDirectory()) {
        visit(filePath);
      } else if (entry.isFile() && extname(entry.name) === '.dart') {
        sources[normalisePath(relative(root, filePath))] = readFileSync(
          filePath,
          'utf8',
        );
      }
    }
  };
  visit(directory);
  return sources;
}

function trackedCredentialCandidates(root) {
  const trackedPaths = execFileSync('git', ['-C', root, 'ls-files', '-z'], {
    encoding: 'utf8',
  })
    .split('\0')
    .filter((path) => path.length > 0)
    .map(normalisePath);
  const candidates = {};
  for (const path of trackedPaths) {
    if (isForbiddenCredentialPath(path)) {
      candidates[path] = '';
      continue;
    }
    if (!isCredentialCandidatePath(path)) {
      continue;
    }
    const absolutePath = join(root, path);
    if (existsSync(absolutePath)) {
      candidates[path] = readFileSync(absolutePath, 'utf8');
    }
  }
  return candidates;
}

export function readMobileSecuritySurface({ root = repositoryRoot } = {}) {
  const read = (path) => readFileSync(join(root, path), 'utf8');
  return {
    mainManifest: read(mobilePaths.mainManifest),
    debugManifest: read(mobilePaths.debugManifest),
    profileManifest: read(mobilePaths.profileManifest),
    appBuildGradle: read(mobilePaths.appBuildGradle),
    mobilePubspec: read(mobilePaths.pubspec),
    dartSources: collectDartSources(
      root,
      join(root, mobilePaths.dartSourceDirectory),
    ),
    credentialCandidates: trackedCredentialCandidates(root),
  };
}

export function verifyMobileSecurity({ root = repositoryRoot } = {}) {
  const result = validateMobileSecuritySurface(readMobileSecuritySurface({ root }));
  if (!result.valid) {
    const summary = result.findings
      .map(({ code, detail }) => `${code}: ${detail}`)
      .join('\n');
    throw new Error(`Mobile security verification failed.\n${summary}`);
  }
  return result;
}

const isDirectExecution =
  process.argv[1] != null &&
  resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isDirectExecution) {
  verifyMobileSecurity();
  process.stdout.write('Mobile security verification passed.\n');
}
