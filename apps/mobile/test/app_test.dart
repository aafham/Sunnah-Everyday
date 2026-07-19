import 'package:design_system/design_system.dart';
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

  testWidgets('daily status card opens and returns from a safe detail view', (
    tester,
  ) async {
    await pumpMobileApp(tester);

    expect(find.byKey(const ValueKey('daily-card')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('daily-card-status')));
    await settleSunnahTestWidget(tester);

    expect(find.text('Butiran belum tersedia'), findsOneWidget);
    expect(find.text('Status kandungan'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('daily-detail-back')));
    await settleSunnahTestWidget(tester);

    expect(find.byKey(const ValueKey('daily-card')), findsOneWidget);
    expect(find.text('Hari Ini'), findsWidgets);
  });

  testWidgets('direct daily detail route remains fail-closed', (tester) async {
    await pumpMobileApp(tester, initialLocation: MobilePath.dailyDetail);

    expect(find.text('Butiran belum tersedia'), findsOneWidget);
    expect(find.text('Status kandungan'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('incomplete onboarding gates the daily detail route', (
    tester,
  ) async {
    await pumpMobileApp(
      tester,
      onboardingCompleted: false,
      initialLocation: MobilePath.dailyDetail,
    );

    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('Butiran belum tersedia'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('daily status surface is localized after choosing English', (
    tester,
  ) async {
    final store = InMemoryAppPreferencesStore(
      initialValues: {
        AppPreferencesStorageKey.onboardingCompleted: true,
        AppPreferencesStorageKey.locale: AppLocale.english.languageCode,
      },
    );

    await pumpMobileApp(tester, preferencesStore: store);

    await tester.tap(find.byKey(const ValueKey('daily-card-status')));
    await settleSunnahTestWidget(tester);

    expect(find.text('Details are not available yet'), findsOneWidget);
    expect(find.text('Content status'), findsWidgets);
    expect(find.byKey(const ValueKey('daily-detail-back')), findsOneWidget);
    expect(find.bySemanticsLabel('Back to Today'), findsOneWidget);
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

  testWidgets('safe app-bar titles expose semantic headers', (tester) async {
    await pumpMobileApp(tester);
    final semantics = tester.ensureSemantics();

    Future<void> navigateAndExpectHeader(String label, String title) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await settleSunnahTestWidget(tester);

      final appBarTitle = find.descendant(
        of: find.byType(AppBar),
        matching: find.text(title),
      );
      expect(appBarTitle, findsOneWidget);
      expect(
        tester.getSemantics(appBarTitle),
        matchesSemantics(isHeader: true),
      );
    }

    try {
      await navigateAndExpectHeader('Teroka', 'Teroka');
      await navigateAndExpectHeader('Simpanan', 'Simpanan');
      await navigateAndExpectHeader('Tetapan', 'Tetapan');
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'generic RTL layout preserves safe navigation and mirrors return affordance',
    (tester) async {
      await pumpMobileApp(
        tester,
        initialLocation: MobilePath.dailyDetail,
        textDirectionOverride: TextDirection.rtl,
      );

      final back = find.byKey(const ValueKey('daily-detail-back'));
      expect(back, findsOneWidget);
      expect(Directionality.of(tester.element(back)), TextDirection.rtl);
      expect(find.bySemanticsLabel('Kembali ke Hari Ini'), findsOneWidget);
      expect(find.byType(BackButtonIcon), findsOneWidget);

      final icon = find.descendant(of: back, matching: find.byType(Icon));
      expect(icon, findsOneWidget);
      final iconData = tester.widget<Icon>(icon).icon;
      expect(iconData, isNotNull);
      expect(iconData!.matchTextDirection, isTrue);
    },
  );

  testWidgets(
    'large text keeps the daily status action and primary navigation usable',
    (tester) async {
      await pumpMobileApp(
        tester,
        viewport: SunnahTestViewports.mobile,
        textScaler: const TextScaler.linear(1.5),
      );

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.destinations, hasLength(4));
      expect(find.bySemanticsLabel('Navigasi utama'), findsOneWidget);
      expect(find.bySemanticsLabel('Lihat status kandungan'), findsOneWidget);
      expect(
        tester
            .widget<SunnahContentFrame>(find.byType(SunnahContentFrame))
            .maxWidth,
        SunnahLayout.mobileContentMaxWidth,
      );

      final statusAction = find.byKey(const ValueKey('daily-card-status'));
      final pageScrollable = find.descendant(
        of: find.byType(SunnahContentFrame),
        matching: find.byType(Scrollable),
      );
      expect(pageScrollable, findsOneWidget);
      await tester.scrollUntilVisible(
        statusAction,
        240,
        scrollable: pageScrollable,
      );
      await tester.pump();
      final actionRect = tester.getRect(statusAction);
      final pageRect = tester.getRect(pageScrollable);
      expect(actionRect.top, greaterThanOrEqualTo(pageRect.top));
      expect(actionRect.bottom, lessThanOrEqualTo(pageRect.bottom));
      await tester.tap(statusAction);
      await settleSunnahTestWidget(tester);

      expect(find.text('Butiran belum tersedia'), findsOneWidget);
    },
  );

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
