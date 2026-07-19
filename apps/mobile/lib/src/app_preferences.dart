import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeSetting { system, light, dark }

extension AppThemeSettingX on AppThemeSetting {
  ThemeMode get themeMode => switch (this) {
    AppThemeSetting.system => ThemeMode.system,
    AppThemeSetting.light => ThemeMode.light,
    AppThemeSetting.dark => ThemeMode.dark,
  };
}

class AppPreferencesState {
  const AppPreferencesState({
    this.themeSetting = AppThemeSetting.system,
    this.reduceMotion = false,
    this.textScale = 1,
  });

  final AppThemeSetting themeSetting;
  final bool reduceMotion;
  final double textScale;

  AppPreferencesState copyWith({
    AppThemeSetting? themeSetting,
    bool? reduceMotion,
    double? textScale,
  }) {
    return AppPreferencesState(
      themeSetting: themeSetting ?? this.themeSetting,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      textScale: textScale ?? this.textScale,
    );
  }
}

class AppPreferencesController extends Notifier<AppPreferencesState> {
  @override
  AppPreferencesState build() => const AppPreferencesState();

  void selectTheme(AppThemeSetting themeSetting) {
    state = state.copyWith(themeSetting: themeSetting);
  }

  void setReduceMotion(bool value) {
    state = state.copyWith(reduceMotion: value);
  }

  void setTextScale(double value) {
    state = state.copyWith(textScale: value);
  }
}

final appPreferencesProvider =
    NotifierProvider<AppPreferencesController, AppPreferencesState>(
      AppPreferencesController.new,
    );
