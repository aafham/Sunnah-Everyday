import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A logical device surface for deterministic widget tests.
@immutable
class TestViewport {
  const TestViewport({required this.logicalSize, this.devicePixelRatio = 1})
    : assert(devicePixelRatio > 0);

  final Size logicalSize;
  final double devicePixelRatio;
}

/// Standard test surfaces used by the public app and responsive admin shell.
abstract final class SunnahTestViewports {
  static const mobile = TestViewport(logicalSize: Size(360, 800));
  static const tablet = TestViewport(logicalSize: Size(768, 1024));
  static const desktop = TestViewport(logicalSize: Size(1200, 800));
}

/// Applies [viewport] and always restores the Flutter test view after the test.
void configureTestViewport(WidgetTester tester, TestViewport viewport) {
  tester.view.physicalSize = Size(
    viewport.logicalSize.width * viewport.devicePixelRatio,
    viewport.logicalSize.height * viewport.devicePixelRatio,
  );
  tester.view.devicePixelRatio = viewport.devicePixelRatio;
  addTearDown(tester.view.reset);
}

/// Pumps [child] with deterministic platform display preferences.
///
/// The helper deliberately does not create a nested [MaterialApp], router,
/// provider container or fake content. Application-specific test harnesses own
/// those decisions and can safely compose this wrapper.
Future<void> pumpSunnahTestWidget(
  WidgetTester tester,
  Widget child, {
  TestViewport? viewport,
  Brightness platformBrightness = Brightness.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  if (viewport != null) {
    configureTestViewport(tester, viewport);
  }

  final mediaQuery = MediaQueryData.fromView(tester.view).copyWith(
    platformBrightness: platformBrightness,
    textScaler: textScaler,
    disableAnimations: disableAnimations,
  );
  await tester.pumpWidget(
    MediaQuery(
      data: mediaQuery,
      child: Directionality(textDirection: textDirection, child: child),
    ),
  );
  await tester.pump();
}

/// Settles a known UI transition with a short, explicit timeout.
///
/// Use this only after an interaction that intentionally starts a route or
/// Material transition. The bounded timeout prevents a broken repeating
/// animation from stalling the full test suite for Flutter's default ten
/// minutes.
Future<int> settleSunnahTestWidget(
  WidgetTester tester, {
  Duration step = const Duration(milliseconds: 16),
  Duration timeout = const Duration(seconds: 2),
}) => tester.pumpAndSettle(step, EnginePhase.sendSemanticsUpdate, timeout);
