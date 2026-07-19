import 'package:flutter/material.dart';

import 'sunnah_colors.dart';
import 'sunnah_layout.dart';

/// Returns the shared calm, high-contrast Material 3 theme.
ThemeData sunnahTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: SunnahColors.deepForest,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark
        ? SunnahColors.darkBackground
        : SunnahColors.warmIvory,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: SunnahLayout.navigationBarHeight,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SunnahLayout.controlRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SunnahLayout.controlRadius),
      ),
    ),
  );
}

ThemeData sunnahLightTheme() => sunnahTheme(Brightness.light);

ThemeData sunnahDarkTheme() => sunnahTheme(Brightness.dark);
