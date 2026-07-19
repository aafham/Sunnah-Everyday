import assert from 'node:assert/strict';
import test from 'node:test';

import {
  maximumBundledPayloadBytes,
  qualityAuditScopeLimitations,
  readQualityAuditSurface,
  validateQualityAuditSurface,
  verifyQualityAudit,
} from './verify_quality_audit.mjs';

function baselineSurface() {
  return structuredClone(readQualityAuditSurface());
}

function findingCodes(result) {
  return result.findings.map(({ code }) => code);
}

test('the tracked repository satisfies the reviewed quality audit baseline', () => {
  assert.deepEqual(verifyQualityAudit(), { valid: true, findings: [] });
  assert.ok(
    qualityAuditScopeLimitations.some((limitation) =>
      limitation.includes('Does not resolve transitive dependencies'),
    ),
  );
});

test('direct dependency inventories fail closed for missing and unreviewed packages', () => {
  const surface = baselineSurface();
  surface.manifests['apps/admin/pubspec.yaml'] = surface.manifests[
    'apps/admin/pubspec.yaml'
  ]
    .replace(/dependencies:\r?\n/, 'dependencies:\n  collection: ^1.19.0\n')
    .replace('go_router: ^17.3.0', '');

  const result = validateQualityAuditSurface(surface);
  assert.ok(
    findingCodes(result).includes('QUALITY_AUDIT_UNREVIEWED_DIRECT_DEPENDENCY'),
  );
  assert.ok(
    findingCodes(result).includes('QUALITY_AUDIT_DEPENDENCY_INVENTORY_DRIFT'),
  );
});

test('analytics, ads, network and crash SDK dependencies are prohibited across manifest types', () => {
  const surface = baselineSurface();
  surface.manifests['package.json'] = surface.manifests['package.json'].replace(
    /"devDependencies"\s*:\s*\{/,
    '"devDependencies": {\n    "posthog-node": "9.9.9",',
  );

  const result = validateQualityAuditSurface(surface);
  assert.ok(
    findingCodes(result).includes('QUALITY_AUDIT_UNREVIEWED_DIRECT_DEPENDENCY'),
  );
  assert.ok(findingCodes(result).includes('QUALITY_AUDIT_PROHIBITED_SDK'));
});

test('untracked manifest inventory and malformed manifest input fail closed', () => {
  const untrackedManifestSurface = baselineSurface();
  untrackedManifestSurface.trackedPaths.push('packages/unreviewed/pubspec.yaml');

  const untrackedManifestResult = validateQualityAuditSurface(
    untrackedManifestSurface,
  );
  assert.ok(
    findingCodes(untrackedManifestResult).includes(
      'QUALITY_AUDIT_UNINVENTORIED_MANIFEST',
    ),
  );

  const malformedManifestSurface = baselineSurface();
  malformedManifestSurface.manifests['apps/mobile/pubspec.yaml'] = 'dependencies: [';

  const malformedManifestResult = validateQualityAuditSurface(
    malformedManifestSurface,
  );
  assert.ok(
    findingCodes(malformedManifestResult).includes(
      'QUALITY_AUDIT_MANIFEST_PARSE',
    ),
  );
});

test('direct Dart networking APIs fail closed without inspecting source values', () => {
  const surface = baselineSurface();
  const path = 'apps/admin/lib/src/network_probe.dart';
  surface.trackedPaths.push(path);
  surface.dartSources[path] = "import 'dart:io';\nfinal probe = HttpClient();\n";

  const result = validateQualityAuditSurface(surface);
  assert.ok(
    findingCodes(result).includes('QUALITY_AUDIT_DIRECT_DART_NETWORK_API'),
  );
  assert.ok(result.findings.every(({ detail }) => !detail.includes('probe =')));
});

test('literal Uri.parse network targets fail closed across production workspaces', () => {
  const surface = baselineSurface();
  const path = 'packages/design_system/lib/src/network_probe.dart';
  surface.trackedPaths.push(path);
  surface.dartSources[path] =
    "final networkProbe = Uri.parse('https://example.invalid/health');\n";

  const result = validateQualityAuditSurface(surface);
  assert.ok(
    findingCodes(result).includes('QUALITY_AUDIT_DIRECT_DART_NETWORK_API'),
  );
  assert.ok(
    result.findings.every(({ detail }) => !detail.includes('example.invalid')),
  );
});

test('literal Uri.http and Uri.https network targets fail closed', () => {
  for (const constructor of ['http', 'https']) {
    const surface = baselineSurface();
    const path = `packages/testing_utils/lib/src/${constructor}_probe.dart`;
    surface.trackedPaths.push(path);
    surface.dartSources[path] =
      `final networkProbe = Uri.${constructor}('example.invalid', '/health');\n`;

    const result = validateQualityAuditSurface(surface);
    assert.ok(
      findingCodes(result).includes('QUALITY_AUDIT_DIRECT_DART_NETWORK_API'),
    );
    assert.ok(
      result.findings.every(({ detail }) => !detail.includes('example.invalid')),
    );
  }
});

test('the bounded structural payload baseline rejects content, asset declarations and large binary payloads', () => {
  const surface = baselineSurface();
  surface.manifests['apps/mobile/pubspec.yaml'] = surface.manifests[
    'apps/mobile/pubspec.yaml'
  ].replace(
    /uses-material-design:\s*true/,
    'uses-material-design: true\n  assets:\n    - assets/unreviewed/',
  );
  const binaryPath = 'apps/mobile/assets/unreviewed.bin';
  surface.trackedPaths.push(binaryPath, 'content/approved/unreviewed.json');
  surface.trackedFileSizes[binaryPath] = maximumBundledPayloadBytes + 1;
  surface.trackedFileSizes['content/approved/unreviewed.json'] = 1;

  const result = validateQualityAuditSurface(surface);
  assert.ok(
    findingCodes(result).includes('QUALITY_AUDIT_BUNDLED_ASSET_DECLARATION'),
  );
  assert.ok(
    findingCodes(result).includes('QUALITY_AUDIT_LARGE_BUNDLED_PAYLOAD'),
  );
  assert.ok(
    findingCodes(result).includes('QUALITY_AUDIT_CONTENT_BOUNDARY_PAYLOAD'),
  );
});
