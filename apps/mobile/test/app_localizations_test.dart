import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/l10n/generated/app_localizations.dart';

void main() {
  test('generated localizations support exactly BM and English', () {
    expect(AppLocalizations.supportedLocales, const [
      Locale('ms'),
      Locale('en'),
    ]);
    expect(AppLocalizations.delegate.isSupported(const Locale('ms')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    expect(
      AppLocalizations.localizationsDelegates,
      contains(AppLocalizations.delegate),
    );
  });

  test(
    'localized shell semantics and text-scale formatting are available',
    () async {
      final malay = await AppLocalizations.delegate.load(const Locale('ms'));
      final english = await AppLocalizations.delegate.load(const Locale('en'));

      expect(malay.navigationSemantics, 'Navigasi utama');
      expect(english.navigationSemantics, 'Primary navigation');
      expect(malay.textScalePercent(125), '125%');
      expect(english.textScalePercent(125), '125%');
    },
  );
}
