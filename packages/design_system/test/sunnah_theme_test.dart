import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_utils/testing_utils.dart';

void main() {
  test('shared themes preserve the requested brightness', () {
    expect(sunnahLightTheme().brightness, Brightness.light);
    expect(sunnahDarkTheme().brightness, Brightness.dark);
  });

  test('deep forest token remains stable for brand consistency', () {
    expect(SunnahColors.deepForest, const Color(0xFF123F35));
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
          body: SunnahSectionCard(
            title: 'Tajuk ujian',
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
      viewport: SunnahTestViewports.mobile,
    );

    expect(find.text('Tajuk ujian'), findsOneWidget);
    expect(find.text('Keadaan kosong'), findsOneWidget);
    await tester.tap(find.text('Tindakan'));
    await tester.pump();

    expect(actionWasTapped, isTrue);
  });
}
