import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Android only registers the supported custom-scheme deep-link hosts',
    () {
      const manifestPath = 'android/app/src/main/AndroidManifest.xml';
      final manifest = File(manifestPath).readAsStringSync();
      final intentFilters = RegExp(
        r'<intent-filter>[\s\S]*?</intent-filter>',
      ).allMatches(manifest).map((match) => match.group(0)!);
      final deepLinkFilter = intentFilters.singleWhere(
        (filter) =>
            filter.contains('android.intent.action.VIEW') &&
            filter.contains('android:scheme="sunnah"'),
        orElse: () => '',
      );

      expect(deepLinkFilter, isNotEmpty);
      expect(deepLinkFilter, contains('android.intent.action.VIEW'));
      expect(deepLinkFilter, contains('android.intent.category.DEFAULT'));
      expect(deepLinkFilter, contains('android.intent.category.BROWSABLE'));
      final hosts = RegExp(
        r'android:host="([^"]+)"',
      ).allMatches(deepLinkFilter).map((match) => match.group(1)!);
      final schemes = RegExp(
        r'android:scheme="([^"]+)"',
      ).allMatches(deepLinkFilter).map((match) => match.group(1)!);
      expect(hosts, unorderedEquals(['daily', 'content', 'correction']));
      expect(schemes, ['sunnah', 'sunnah', 'sunnah']);
      expect(deepLinkFilter, isNot(contains('android:autoVerify')));
      expect(
        manifest,
        isNot(contains('flutter_deeplinking_enabled" android:value="false"')),
      );
      expect(manifest, contains('android:launchMode="singleTop"'));
      expect(manifest, isNot(contains('<uses-permission')));
    },
  );
}
