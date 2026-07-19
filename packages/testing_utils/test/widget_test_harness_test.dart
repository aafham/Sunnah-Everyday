import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_utils/testing_utils.dart';

void main() {
  testWidgets('harness applies the requested viewport and media preferences', (
    tester,
  ) async {
    await pumpSunnahTestWidget(
      tester,
      Builder(
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);
          return Text(
            '${mediaQuery.size.width}|${mediaQuery.size.height}|'
            '${mediaQuery.platformBrightness.name}|'
            '${mediaQuery.disableAnimations}|'
            '${Directionality.of(context).name}|'
            '${mediaQuery.textScaler.scale(10)}',
          );
        },
      ),
      viewport: const TestViewport(
        logicalSize: Size(400, 900),
        devicePixelRatio: 2,
      ),
      platformBrightness: Brightness.dark,
      textScaler: const TextScaler.linear(1.5),
      disableAnimations: true,
      textDirection: TextDirection.rtl,
    );

    expect(tester.view.physicalSize, const Size(800, 1800));
    expect(find.text('400.0|900.0|dark|true|rtl|15.0'), findsOneWidget);
  });
}
