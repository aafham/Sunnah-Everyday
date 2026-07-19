import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/src/app_preferences.dart';
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
        configure: (container) {
          container.read(appPreferencesProvider.notifier).setTextScale(1.2);
        },
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
