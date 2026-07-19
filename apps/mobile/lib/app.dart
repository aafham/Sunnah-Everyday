import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/generated/app_localizations.dart';
import 'src/app_preferences.dart';
import 'src/app_router.dart';

class SunnahEverydayApp extends ConsumerStatefulWidget {
  const SunnahEverydayApp({
    super.key,
    this.initialLocation,
    this.testTextDirectionOverride,
  });

  /// Enables deterministic route coverage without changing the installed
  /// application's normal first destination.
  final String? initialLocation;

  /// Lets widget tests exercise generic RTL layout without adding an RTL
  /// locale, Arabic text, font, or content to the installed application.
  ///
  /// Production construction leaves this null so [MaterialApp] continues to
  /// derive directionality from the supported BM/English locale.
  final TextDirection? testTextDirectionOverride;

  @override
  ConsumerState<SunnahEverydayApp> createState() => _SunnahEverydayAppState();
}

class _SunnahEverydayAppState extends ConsumerState<SunnahEverydayApp> {
  late final GoRouter _router;
  late final ValueNotifier<bool> _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = ValueNotifier(
      ref.read(appPreferencesProvider).onboardingCompleted,
    );
    ref.listenManual<AppPreferencesState>(appPreferencesProvider, (
      previous,
      next,
    ) {
      _onboardingCompleted.value = next.onboardingCompleted;
    });
    _router = createMobileRouter(
      onboardingCompleted: _onboardingCompleted,
      initialLocation: widget.initialLocation ?? MobilePath.today,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _onboardingCompleted.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: preferences.locale.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: sunnahLightTheme(),
      darkTheme: sunnahDarkTheme(),
      themeMode: preferences.themeSetting.themeMode,
      routerConfig: _router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final routerChild = child ?? const SizedBox.shrink();
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: _PreferenceTextScaler(
              mediaQuery.textScaler,
              preferences.textScale,
            ),
            disableAnimations:
                mediaQuery.disableAnimations || preferences.reduceMotion,
          ),
          child: switch (widget.testTextDirectionOverride) {
            final textDirection? => Directionality(
              textDirection: textDirection,
              child: routerChild,
            ),
            null => routerChild,
          },
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
