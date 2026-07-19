import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sunnaheveryday/src/app_preferences.dart';
import 'package:sunnaheveryday/src/app_router.dart';
import 'package:testing_utils/testing_utils.dart';

import 'support/mobile_app_harness.dart';

void main() {
  test(
    'external URI classifier keeps every destination static and fail-closed',
    () {
      expect(
        safeRouteForExternalUri(Uri.parse('sunnah://daily/opaque-item_1')),
        MobilePath.dailyDetail,
      );
      expect(
        safeRouteForExternalUri(Uri.parse('sunnah://content/opaque-item_2')),
        MobilePath.dailyDetail,
      );
      expect(
        safeRouteForExternalUri(Uri.parse('sunnah://correction/opaque-item_3')),
        MobilePath.routeUnavailable,
      );

      for (final uri in [
        Uri.parse('sunnah://unknown/opaque-item'),
        Uri.parse('sunnah://daily'),
        Uri.parse('sunnah://daily/too/many'),
        Uri.parse('sunnah://daily/opaque-item?next=today'),
        Uri.parse('sunnah://daily/opaque-item#fragment'),
        Uri.parse('sunnah://owner@daily/opaque-item'),
        Uri.parse('sunnah://daily:7000/opaque-item'),
        Uri.parse('sunnah://daily/opaque%20item'),
        Uri.parse('sunnah://daily/opaque%2Fitem'),
        Uri.parse('https://daily/opaque-item'),
        Uri.parse('/unknown-route'),
      ]) {
        expect(safeRouteForExternalUri(uri), isNull);
      }
    },
  );

  testWidgets(
    'cold and runtime content links only show the static safe status',
    (tester) async {
      const coldToken = 'opaque-cold-token';
      const runtimeToken = 'opaque-runtime-token';
      await pumpMobileApp(tester, initialLocation: 'sunnah://daily/$coldToken');
      await settleSunnahTestWidget(tester);

      expect(find.text('Butiran belum tersedia'), findsOneWidget);
      expect(find.text(coldToken), findsNothing);
      expect(find.bySemanticsLabel(coldToken), findsNothing);
      expect(find.byKey(const ValueKey('daily-detail-back')), findsOneWidget);

      _routerFor(tester).go('sunnah://content/$runtimeToken');
      await settleSunnahTestWidget(tester);

      expect(find.text('Butiran belum tersedia'), findsOneWidget);
      expect(find.text(runtimeToken), findsNothing);
      expect(find.bySemanticsLabel(runtimeToken), findsNothing);
      expect(find.byKey(const ValueKey('daily-detail-back')), findsOneWidget);
    },
  );

  testWidgets(
    'correction, malformed and unknown routes use a friendly fallback',
    (tester) async {
      const correctionToken = 'opaque-correction-token';
      const malformedToken = 'opaque-malformed-token';
      await pumpMobileApp(tester);

      _routerFor(tester).go('sunnah://correction/$correctionToken');
      await settleSunnahTestWidget(tester);
      expect(find.text('Pautan ini tidak tersedia'), findsWidgets);
      expect(find.text(correctionToken), findsNothing);
      expect(find.bySemanticsLabel(correctionToken), findsNothing);
      expect(
        find.byKey(const ValueKey('route-unavailable-return-today')),
        findsOneWidget,
      );

      _routerFor(tester).go('sunnah://daily/$malformedToken/extra');
      await settleSunnahTestWidget(tester);
      expect(find.text('Pautan ini tidak tersedia'), findsWidgets);
      expect(find.text(malformedToken), findsNothing);

      _routerFor(tester).go('/unknown-route');
      await settleSunnahTestWidget(tester);
      expect(find.text('Pautan ini tidak tersedia'), findsWidgets);
      expect(find.textContaining('GoException'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('route-unavailable-return-today')),
      );
      await settleSunnahTestWidget(tester);
      expect(find.text('Hari Ini'), findsWidgets);
      expect(find.text('Pautan ini tidak tersedia'), findsNothing);
    },
  );

  testWidgets('external authorities cannot reach matching internal paths', (
    tester,
  ) async {
    await pumpMobileApp(tester, initialLocation: 'sunnah://evil/today');
    await settleSunnahTestWidget(tester);

    expect(find.text('Pautan ini tidak tersedia'), findsWidgets);
    expect(find.text('Belum ada kandungan yang diluluskan'), findsNothing);

    _routerFor(tester).go('sunnah://daily/today/detail');
    await settleSunnahTestWidget(tester);
    expect(find.text('Pautan ini tidak tersedia'), findsWidgets);
    expect(find.text('Butiran belum tersedia'), findsNothing);

    _routerFor(tester).go('sunnah://daily/onboarding');
    await settleSunnahTestWidget(tester);
    expect(find.text('Butiran belum tersedia'), findsOneWidget);
    expect(find.text('Selamat datang'), findsNothing);
  });

  testWidgets('incomplete onboarding wins over an incoming external link', (
    tester,
  ) async {
    await pumpMobileApp(
      tester,
      onboardingCompleted: false,
      initialLocation: 'sunnah://daily/onboarding',
    );
    await settleSunnahTestWidget(tester);

    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('Butiran belum tersedia'), findsNothing);
    expect(find.text('Pautan ini tidak tersedia'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets(
    'English invalid routes keep recovery copy and semantics localized',
    (tester) async {
      final store = InMemoryAppPreferencesStore(
        initialValues: {
          AppPreferencesStorageKey.onboardingCompleted: true,
          AppPreferencesStorageKey.locale: AppLocale.english.languageCode,
        },
      );
      await pumpMobileApp(tester, preferencesStore: store);

      _routerFor(tester).go('/unknown-route');
      await settleSunnahTestWidget(tester);

      expect(find.text('This link is unavailable'), findsWidgets);
      final semantics = tester.ensureSemantics();
      final returnAction = find.byKey(
        const ValueKey('route-unavailable-return-today'),
      );
      expect(
        tester.getSemantics(returnAction),
        matchesSemantics(
          isButton: true,
          isFocusable: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Return to Today',
        ),
      );
      semantics.dispose();

      await tester.tap(
        find.byKey(const ValueKey('route-unavailable-return-today')),
      );
      await settleSunnahTestWidget(tester);
      expect(find.text('Today'), findsWidgets);
    },
  );
}

GoRouter _routerFor(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(NavigationBar)));
