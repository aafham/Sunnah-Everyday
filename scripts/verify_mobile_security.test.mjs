import assert from 'node:assert/strict';
import test from 'node:test';

import {
  readMobileSecuritySurface,
  validateMobileSecuritySurface,
  verifyMobileSecurity,
} from './verify_mobile_security.mjs';

function baselineSurface() {
  return structuredClone(readMobileSecuritySurface());
}

function findingCodes(result) {
  return result.findings.map(({ code }) => code);
}

test('the current shipped-mobile security boundary passes', () => {
  assert.deepEqual(verifyMobileSecurity(), { valid: true, findings: [] });
});

test('the main Android manifest rejects permissions and weakened privacy flags', () => {
  const permissionSurface = baselineSurface();
  permissionSurface.mainManifest = permissionSurface.mainManifest.replace(
    '<application',
    '<uses-permission android:name="android.permission.CAMERA" />\n    <application',
  );
  const permissionResult = validateMobileSecuritySurface(permissionSurface);
  assert.ok(findingCodes(permissionResult).includes('MOBILE_MAIN_PERMISSION'));

  const privacySurface = baselineSurface();
  privacySurface.mainManifest = privacySurface.mainManifest
    .replace('android:allowBackup="false"', 'android:allowBackup="true"')
    .replace('<application', '<application android:usesCleartextTraffic="true"');
  const privacyResult = validateMobileSecuritySurface(privacySurface);
  assert.ok(findingCodes(privacyResult).includes('MOBILE_BACKUP_GUARD'));
  assert.ok(findingCodes(privacyResult).includes('MOBILE_CLEARTEXT_TRAFFIC'));
});

test('tooling manifests allow only their isolated INTERNET permission', () => {
  const surface = baselineSurface();
  surface.debugManifest = surface.debugManifest.replace(
    '</manifest>',
    '    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>\n</manifest>',
  );

  const result = validateMobileSecuritySurface(surface);
  assert.ok(
    findingCodes(result).includes('MOBILE_TOOLING_PERMISSION_ALLOWLIST'),
  );
});

test('release signing and debug-signing fallback are rejected', () => {
  const surface = baselineSurface();
  surface.appBuildGradle = surface.appBuildGradle.replace(
    'release {',
    'signingConfigs { create("release") }\n    release {\n            signingConfig = signingConfigs.getByName("debug")',
  );

  const result = validateMobileSecuritySurface(surface);
  assert.ok(findingCodes(result).includes('MOBILE_RELEASE_SIGNING_CONFIG'));
  assert.ok(findingCodes(result).includes('MOBILE_DEBUG_SIGNING_REUSE'));
});

test('unreviewed production networking is rejected at both dependency and source boundaries', () => {
  const surface = baselineSurface();
  surface.mobilePubspec = surface.mobilePubspec.replace(
    'dependencies:',
    'dependencies:\n  firebase_remote_config: ^5.0.0',
  );
  surface.dartSources['apps/mobile/lib/src/network_probe.dart'] =
    "import 'package:http/http.dart' as http;\n";

  const result = validateMobileSecuritySurface(surface);
  assert.ok(findingCodes(result).includes('MOBILE_NETWORK_DEPENDENCY'));
  assert.ok(findingCodes(result).includes('MOBILE_NETWORK_SOURCE'));
});

test('credential-shaped values and credential files fail without exposing values', () => {
  const surface = baselineSurface();
  const googleKey = `AIza${'A'.repeat(35)}`;
  surface.credentialCandidates['apps/mobile/lib/src/config.dart'] =
    `const key = '${googleKey}';`;
  surface.credentialCandidates['android/upload-key.jks'] = '';

  const result = validateMobileSecuritySurface(surface);
  assert.ok(findingCodes(result).includes('MOBILE_GOOGLE_API_KEY'));
  assert.ok(
    findingCodes(result).includes('MOBILE_COMMITTED_CREDENTIAL_FILE'),
  );
  assert.ok(result.findings.every(({ detail }) => !detail.includes(googleKey)));
});
