import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const androidPath = 'android/app/src/main';
  const excludedDomains = <String>[
    'root',
    'file',
    'database',
    'sharedpref',
    'external',
    'device_root',
    'device_file',
    'device_database',
    'device_sharedpref',
  ];

  test(
    'Android private-storage backup configuration is explicitly fail-closed',
    () {
      final manifest = File(
        '$androidPath/AndroidManifest.xml',
      ).readAsStringSync();
      final legacyRules = File(
        '$androidPath/res/xml/backup_rules.xml',
      ).readAsStringSync();
      final extractionRules = File(
        '$androidPath/res/xml/data_extraction_rules.xml',
      ).readAsStringSync();

      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, isNot(contains('<uses-permission')));
      expect(
        manifest,
        contains('android:fullBackupContent="@xml/backup_rules"'),
      );
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
      expect(legacyRules, contains('<full-backup-content>'));
      expect(extractionRules, contains('<cloud-backup'));
      expect(extractionRules, contains('<device-transfer>'));
      expect(legacyRules, isNot(contains('<include')));
      expect(extractionRules, isNot(contains('<include')));

      for (final domain in excludedDomains) {
        final exclusion = '<exclude domain="$domain" path="." />';
        expect(legacyRules, contains(exclusion));
        expect(extractionRules, contains(exclusion));
      }
    },
  );
}
