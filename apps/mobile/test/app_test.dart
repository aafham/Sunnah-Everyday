import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunnaheveryday/app.dart';
import 'package:sunnaheveryday/src/app_preferences.dart';

void main() {
  testWidgets('mobile shell starts with a safe approved-content empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SunnahEverydayApp()));
    await tester.pumpAndSettle();

    expect(find.text('Hari Ini'), findsWidgets);
    expect(find.text('Belum ada kandungan yang diluluskan'), findsOneWidget);
    expect(find.text('Teroka'), findsOneWidget);
    expect(find.text('Simpanan'), findsOneWidget);
    expect(find.text('Tetapan'), findsOneWidget);
  });

  testWidgets('settings route exposes real display controls', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SunnahEverydayApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tetapan'));
    await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const ProviderScope(child: SunnahEverydayApp()));
    await tester.pumpAndSettle();

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
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appPreferencesProvider.notifier).setTextScale(1.2);

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            textScaler: const _NonlinearTextScaler(),
            disableAnimations: true,
          ),
          child: UncontrolledProviderScope(
            container: container,
            child: const SunnahEverydayApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();

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
