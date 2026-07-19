import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/src/app_preferences.dart';
import 'package:sunnaheveryday/src/pages/route_unavailable_page.dart';
import 'package:sunnaheveryday/src/pages/today_page.dart';
import 'package:testing_utils/testing_utils.dart';

import 'support/mobile_app_harness.dart';

void main() {
  testWidgets(
    'Malay 150% Today state keeps its semantic heading and status action reachable by tap',
    (tester) async {
      await pumpMobileApp(tester, textScaler: const TextScaler.linear(1.5));

      final heading = find.descendant(
        of: find.byType(TodayPage),
        matching: find.text('Hari Ini'),
      );
      final statusAction = find.byKey(const ValueKey('daily-card-status'));
      final headingSemantics = tester.ensureSemantics();
      try {
        expect(heading, findsOneWidget);
        expect(tester.getSemantics(heading), matchesSemantics(isHeader: true));
      } finally {
        headingSemantics.dispose();
      }
      final scrollable = find.descendant(
        of: find.byType(SunnahContentFrame),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        statusAction,
        240,
        scrollable: scrollable,
      );
      await tester.pump();

      final semantics = tester.ensureSemantics();
      try {
        expect(
          tester.getSemantics(statusAction),
          matchesSemantics(
            label: 'Lihat status kandungan',
            isButton: true,
            isFocusable: true,
            hasFocusAction: true,
            hasTapAction: true,
            hasEnabledState: true,
            isEnabled: true,
          ),
        );
      } finally {
        semantics.dispose();
      }

      final actionRect = tester.getRect(statusAction);
      final viewportRect = tester.getRect(scrollable);
      expect(actionRect.top, greaterThanOrEqualTo(viewportRect.top));
      expect(actionRect.bottom, lessThanOrEqualTo(viewportRect.bottom));

      await tester.tap(statusAction);
      await settleSunnahTestWidget(tester);
      expect(find.text('Butiran belum tersedia'), findsOneWidget);
    },
  );

  testWidgets(
    'English 150% safe link fallback has a semantic recovery button operable by keyboard',
    (tester) async {
      const opaqueToken = 'opaque-route-token';
      final preferencesStore = InMemoryAppPreferencesStore(
        initialValues: {
          AppPreferencesStorageKey.onboardingCompleted: true,
          AppPreferencesStorageKey.locale: AppLocale.english.languageCode,
        },
      );
      await pumpMobileApp(
        tester,
        preferencesStore: preferencesStore,
        initialLocation: 'sunnah://daily/$opaqueToken/extra',
        textScaler: const TextScaler.linear(1.5),
      );
      await settleSunnahTestWidget(tester);

      final heading = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('This link is unavailable'),
      );
      final recoveryButton = find.byKey(
        const ValueKey('route-unavailable-return-today'),
      );
      final scrollable = find.descendant(
        of: find.byType(RouteUnavailablePage),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        recoveryButton,
        240,
        scrollable: scrollable,
      );
      await tester.pump();

      final semantics = tester.ensureSemantics();
      try {
        expect(heading, findsOneWidget);
        expect(tester.getSemantics(heading), matchesSemantics(isHeader: true));
        expect(
          tester.getSemantics(recoveryButton),
          matchesSemantics(
            label: 'Return to Today',
            isButton: true,
            isFocusable: true,
            hasFocusAction: true,
            hasTapAction: true,
            hasEnabledState: true,
            isEnabled: true,
          ),
        );
      } finally {
        semantics.dispose();
      }
      expect(find.text(opaqueToken), findsNothing);
      expect(find.bySemanticsLabel(opaqueToken), findsNothing);

      final buttonFocus = find.descendant(
        of: recoveryButton,
        matching: find.byType(Focus),
      );
      expect(buttonFocus, findsOneWidget);
      final focusSemantics = find
          .descendant(of: buttonFocus, matching: find.byType(Semantics))
          .first;
      final focusNode = Focus.of(tester.element(focusSemantics));
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settleSunnahTestWidget(tester);
      expect(find.text('Today'), findsWidgets);
      expect(find.byType(RouteUnavailablePage), findsNothing);
    },
  );
}
