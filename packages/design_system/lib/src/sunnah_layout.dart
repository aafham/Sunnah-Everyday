import 'package:flutter/widgets.dart';

/// Shared layout tokens for the current mobile and admin shells.
///
/// These values are deliberately limited to observable layout behaviour. They
/// carry no content, localization, routing, or publication semantics.
abstract final class SunnahLayout {
  static const navigationBarHeight = 72.0;
  static const controlRadius = 16.0;

  static const sectionCardPadding = EdgeInsets.all(20);
  static const emptyStatePadding = EdgeInsets.all(32);
  static const mobilePagePadding = EdgeInsetsDirectional.fromSTEB(
    20,
    24,
    20,
    32,
  );
  static const compactPagePadding = EdgeInsets.all(20);
  static const onboardingPagePadding = EdgeInsets.all(24);

  /// Keeps mobile text and controls readable on larger Android surfaces.
  static const mobileContentMaxWidth = 560.0;

  static const adminNavigationBreakpoint = 960.0;
  static const adminNavigationRailWidth = 248.0;
  static const adminContentMaxWidth = 1040.0;
  static const adminPagePadding = EdgeInsets.all(32);
}
