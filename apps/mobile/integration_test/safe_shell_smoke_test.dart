import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunnaheveryday/main.dart' as app;
import 'package:sunnaheveryday/src/app_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_clearUiPreferences);
  tearDownAll(_clearUiPreferences);

  testWidgets(
    'Android safe shell keeps onboarding, approved-content status, navigation and settings usable',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      expect(find.text('Selamat datang'), findsOneWidget);
      expect(find.bySemanticsLabel('Bahasa'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Belum ada kandungan yang diluluskan'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('onboarding-continue')));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Navigasi utama'), findsOneWidget);
      expect(find.text('Belum ada kandungan yang diluluskan'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Teroka'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Belum ada koleksi untuk diterokai'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Tetapan'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paparan'), findsOneWidget);
      expect(find.bySemanticsLabel('Tema'), findsWidgets);
      expect(find.bySemanticsLabel('Kurangkan animasi'), findsWidgets);
      expect(find.bySemanticsLabel('Saiz teks'), findsWidgets);
    },
  );
}

/// Clears only the app's allowlisted UI-preference keys so device test runs
/// begin and end independently without touching reflections or other storage.
Future<void> _clearUiPreferences() =>
    SharedPreferencesAsync().clear(allowList: AppPreferencesStorageKey.all);
