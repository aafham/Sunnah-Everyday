import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_utils/testing_utils.dart';

void main() {
  test('shared themes preserve the requested brightness', () {
    expect(sunnahLightTheme().brightness, Brightness.light);
    expect(sunnahDarkTheme().brightness, Brightness.dark);
  });

  test('shared themes keep readable on-surface contrast', () {
    for (final theme in [sunnahLightTheme(), sunnahDarkTheme()]) {
      expect(
        _contrastRatio(
          theme.colorScheme.onSurface,
          theme.scaffoldBackgroundColor,
        ),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('deep forest token remains stable for brand consistency', () {
    expect(SunnahColors.deepForest, const Color(0xFF123F35));
  });

  test('palette and layout tokens retain the documented UI contract', () {
    expect(SunnahColors.warmIvory, const Color(0xFFF7F4EC));
    expect(SunnahColors.deepForest, const Color(0xFF123F35));
    expect(SunnahColors.sage, const Color(0xFFA8BFAF));
    expect(SunnahColors.mutedGold, const Color(0xFFC6A15B));
    expect(SunnahColors.charcoal, const Color(0xFF17211D));
    expect(SunnahColors.darkBackground, const Color(0xFF0D1714));
    expect(SunnahLayout.navigationBarHeight, 72);
    expect(SunnahLayout.controlRadius, 16);
    expect(SunnahLayout.mobileContentMaxWidth, 560);
    expect(
      SunnahLayout.mobilePagePadding,
      const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 32),
    );
    expect(SunnahLayout.adminNavigationBreakpoint, 960);
    expect(SunnahLayout.adminContentMaxWidth, 1040);
  });

  test('shared theme applies the documented Material 3 contract', () {
    final lightTheme = sunnahLightTheme();
    final darkTheme = sunnahDarkTheme();

    expect(lightTheme.useMaterial3, isTrue);
    expect(lightTheme.scaffoldBackgroundColor, SunnahColors.warmIvory);
    expect(darkTheme.scaffoldBackgroundColor, SunnahColors.darkBackground);
    expect(
      lightTheme.navigationBarTheme.height,
      SunnahLayout.navigationBarHeight,
    );
    expect(lightTheme.appBarTheme.backgroundColor, Colors.transparent);
    expect(lightTheme.appBarTheme.elevation, 0);
    expect(lightTheme.appBarTheme.scrolledUnderElevation, 0);

    final snackBarShape =
        lightTheme.snackBarTheme.shape! as RoundedRectangleBorder;
    final inputBorder =
        lightTheme.inputDecorationTheme.border! as OutlineInputBorder;
    final expectedRadius = BorderRadius.circular(SunnahLayout.controlRadius);
    expect(snackBarShape.borderRadius, expectedRadius);
    expect(inputBorder.borderRadius, expectedRadius);
  });

  testWidgets('shared primitives render an explicit optional action', (
    tester,
  ) async {
    var actionWasTapped = false;

    await pumpSunnahTestWidget(
      tester,
      MaterialApp(
        theme: sunnahLightTheme(),
        home: Scaffold(
          body: SunnahContentFrame(
            child: SunnahSectionCard(
              eyebrow: 'Status',
              title: 'Tajuk ujian',
              trailing: const Icon(Icons.more_horiz),
              child: SunnahEmptyState(
                icon: Icons.info_outline,
                title: 'Keadaan kosong',
                message: 'Tiada rekod ujian untuk dipaparkan.',
                actionLabel: 'Tindakan',
                onAction: () => actionWasTapped = true,
              ),
            ),
          ),
        ),
      ),
      viewport: SunnahTestViewports.mobile,
    );

    expect(find.text('Tajuk ujian'), findsOneWidget);
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('Keadaan kosong'), findsOneWidget);
    expect(find.bySemanticsLabel('Tindakan'), findsOneWidget);
    await tester.tap(find.text('Tindakan'));
    await tester.pump();

    expect(actionWasTapped, isTrue);
    expect(
      tester
          .widget<SunnahContentFrame>(find.byType(SunnahContentFrame))
          .maxWidth,
      SunnahLayout.mobileContentMaxWidth,
    );
  });

  testWidgets('empty-state action stays absent unless it is actionable', (
    tester,
  ) async {
    await pumpSunnahTestWidget(
      tester,
      MaterialApp(
        theme: sunnahLightTheme(),
        home: const Scaffold(
          body: Column(
            children: [
              SunnahEmptyState(
                icon: Icons.info_outline,
                title: 'Tanpa tindakan satu',
                message: 'Mesej ujian.',
                actionLabel: 'Tidak dipaparkan',
              ),
              SunnahEmptyState(
                icon: Icons.info_outline,
                title: 'Tanpa tindakan dua',
                message: 'Mesej ujian.',
              ),
            ],
          ),
        ),
      ),
      viewport: SunnahTestViewports.mobile,
    );

    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.text('Tidak dipaparkan'), findsNothing);
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
