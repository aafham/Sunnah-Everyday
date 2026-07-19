import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/src/app_preferences.dart';
import 'package:sunnaheveryday/src/app_router.dart';
import 'package:testing_utils/testing_utils.dart';

import 'support/mobile_app_harness.dart';

void main() {
  testWidgets('mobile shell starts with a safe approved-content empty state', (
    tester,
  ) async {
    await pumpMobileApp(tester);

    expect(find.text('Hari Ini'), findsWidgets);
    expect(find.text('Belum ada kandungan yang diluluskan'), findsOneWidget);
    expect(find.text('Teroka'), findsOneWidget);
    expect(find.text('Simpanan'), findsOneWidget);
    expect(find.text('Tetapan'), findsOneWidget);
  });

  testWidgets('settings route exposes real display controls', (tester) async {
    await pumpMobileApp(tester);

    await tester.tap(find.text('Tetapan'));
    await settleSunnahTestWidget(tester);

    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Kurangkan animasi'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('first launch chooses a locale before opening the shell', (
    tester,
  ) async {
    final store = InMemoryAppPreferencesStore();

    await pumpMobileApp(tester, preferencesStore: store);

    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('onboarding-language')),
        matching: find.text('English'),
      ),
    );
    await settleSunnahTestWidget(tester);

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding-continue')));
    await settleSunnahTestWidget(tester);

    expect(find.text('Today'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(store.read().onboardingCompleted, isTrue);
    expect(store.read().locale, AppLocale.english);
  });

  testWidgets('incomplete onboarding gates a deep shell route', (tester) async {
    await pumpMobileApp(
      tester,
      onboardingCompleted: false,
      initialLocation: MobilePath.settings,
    );

    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('Tetapan'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('settings updates the language for the active shell', (
    tester,
  ) async {
    await pumpMobileApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Tetapan'),
      ),
    );
    await settleSunnahTestWidget(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('settings-language')),
        matching: find.text('English'),
      ),
    );
    await settleSunnahTestWidget(tester);

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Language'), findsOneWidget);
    expect(find.bySemanticsLabel('Primary navigation'), findsOneWidget);
    expect(find.text('Tetapan'), findsNothing);
  });

  testWidgets('primary navigation reaches every safe shell destination', (
    tester,
  ) async {
    Future<void> navigateTo(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await settleSunnahTestWidget(tester);
    }

    await pumpMobileApp(tester);

    await navigateTo('Teroka');
    expect(find.text('Belum ada koleksi untuk diterokai'), findsOneWidget);

    await navigateTo('Simpanan');
    expect(find.text('Belum ada simpanan'), findsOneWidget);

    await navigateTo('Tetapan');
    expect(find.text('Paparan'), findsOneWidget);

    await navigateTo('Hari Ini');
    expect(find.text('Belum ada kandungan yang diluluskan'), findsOneWidget);
  });

  testWidgets(
    'app preserves nonlinear accessibility scaling and motion settings',
    (tester) async {
      await pumpMobileApp(
        tester,
        textScaler: const _NonlinearTextScaler(),
        disableAnimations: true,
        configure: (container) =>
            container.read(appPreferencesProvider.notifier).setTextScale(1.2),
      );

      final context = tester.element(
        find.text('Belum ada kandungan yang diluluskan'),
      );
      final mediaQuery = MediaQuery.of(context);

      expect(mediaQuery.textScaler.scale(10), 18);
      expect(mediaQuery.textScaler.scale(30), closeTo(43.2, 0.001));
      expect(mediaQuery.disableAnimations, isTrue);
    },
  );
}

class _NonlinearTextScaler extends TextScaler {
  const _NonlinearTextScaler();

  @override
  double get textScaleFactor => 1.5;

  @override
  double scale(double fontSize) =>
      fontSize <= 16 ? fontSize * 1.5 : fontSize * 1.2;
}
