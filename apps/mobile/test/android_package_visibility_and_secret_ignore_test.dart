import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const credentialRules = <String>{
    '.env',
    '.env.*',
    '!.env.example',
    '!.env.sample',
    '!.env.template',
    '*.jks',
    '*.keystore',
    '*.key',
    '*.pem',
    '*.p12',
    '*.pfx',
    '*.p8',
    'key.properties',
    'google-services.json',
    'service-account.json',
    'service_account.json',
    'credentials.json',
  };

  test(
    'Android main source manifest has no package-visibility declarations',
    () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, isNot(contains('<queries')));
      expect(manifest, isNot(contains('android.intent.action.PROCESS_TEXT')));
    },
  );

  test(
    'credential ignore rules protect secrets without hiding source or docs',
    () {
      final ignoreRules = File('../../.gitignore').readAsLinesSync().toSet();

      expect(ignoreRules, containsAll(credentialRules));
      expect(ignoreRules, isNot(contains('*.json')));
      expect(ignoreRules, isNot(contains('*.properties')));

      const ignoredPaths = <String>[
        '.env',
        'apps/mobile/.env.local',
        'secrets/upload.jks',
        'secrets/upload.keystore',
        'secrets/upload.key',
        'secrets/upload.pem',
        'secrets/upload.p12',
        'secrets/upload.pfx',
        'secrets/upload.p8',
        'apps/mobile/android/key.properties',
        'apps/mobile/android/app/google-services.json',
        'secrets/service-account.json',
        'secrets/service_account.json',
        'secrets/credentials.json',
      ];
      const trackablePaths = <String>[
        '.env.example',
        '.env.sample',
        '.env.template',
        'README.md',
        'docs/release/RELEASE_GATES.md',
        'docs/service-account-policy.json',
        'content/templates/source_register_schema.json',
        'apps/mobile/lib/main.dart',
        'apps/mobile/pubspec.yaml',
        'apps/mobile/android/key.properties.example',
        'apps/mobile/android/google-services.example.json',
      ];

      for (final path in ignoredPaths) {
        expect(_isIgnored(path), isTrue, reason: '$path must stay ignored');
      }
      for (final path in trackablePaths) {
        expect(_isIgnored(path), isFalse, reason: '$path must stay trackable');
      }
    },
  );
}

bool _isIgnored(String repositoryRelativePath) {
  final result = Process.runSync('git', <String>[
    'check-ignore',
    '--quiet',
    '--no-index',
    '--',
    repositoryRelativePath,
  ], workingDirectory: '../..');

  switch (result.exitCode) {
    case 0:
      return true;
    case 1:
      return false;
    default:
      throw StateError(
        'git check-ignore failed for $repositoryRelativePath: ${result.stderr}',
      );
  }
}
