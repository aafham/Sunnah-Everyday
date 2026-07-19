import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/app_preferences.dart';
import 'src/app_router.dart';

class SunnahEverydayApp extends ConsumerStatefulWidget {
  const SunnahEverydayApp({super.key});

  @override
  ConsumerState<SunnahEverydayApp> createState() => _SunnahEverydayAppState();
}

class _SunnahEverydayAppState extends ConsumerState<SunnahEverydayApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createMobileRouter();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesProvider);

    return MaterialApp.router(
      title: 'Sunnah Everyday',
      debugShowCheckedModeBanner: false,
      theme: sunnahLightTheme(),
      darkTheme: sunnahDarkTheme(),
      themeMode: preferences.themeSetting.themeMode,
      routerConfig: _router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: _PreferenceTextScaler(
              mediaQuery.textScaler,
              preferences.textScale,
            ),
            disableAnimations:
                mediaQuery.disableAnimations || preferences.reduceMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Applies the app preference without flattening the platform's nonlinear
/// accessibility scaling curve.
class _PreferenceTextScaler extends TextScaler {
  const _PreferenceTextScaler(this._platformScaler, this._multiplier)
    : assert(_multiplier >= 0);

  final TextScaler _platformScaler;
  final double _multiplier;

  @override
  double get textScaleFactor => _platformScaler.scale(1) * _multiplier;

  @override
  double scale(double fontSize) =>
      _platformScaler.scale(fontSize) * _multiplier;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PreferenceTextScaler &&
          _platformScaler == other._platformScaler &&
          _multiplier == other._multiplier;

  @override
  int get hashCode => Object.hash(_platformScaler, _multiplier);
}
