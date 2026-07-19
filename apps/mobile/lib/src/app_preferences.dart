import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeSetting { system, light, dark }

extension AppThemeSettingX on AppThemeSetting {
  ThemeMode get themeMode => switch (this) {
    AppThemeSetting.system => ThemeMode.system,
    AppThemeSetting.light => ThemeMode.light,
    AppThemeSetting.dark => ThemeMode.dark,
  };

  static AppThemeSetting? fromStorageValue(Object? value) {
    if (value is! String) {
      return null;
    }
    for (final setting in AppThemeSetting.values) {
      if (setting.name == value) {
        return setting;
      }
    }
    return null;
  }
}

enum AppLocale {
  malay('ms'),
  english('en');

  const AppLocale(this.languageCode);

  final String languageCode;

  Locale get locale => Locale(languageCode);

  static AppLocale? fromStorageValue(Object? value) {
    if (value is! String) {
      return null;
    }
    for (final locale in AppLocale.values) {
      if (locale.languageCode == value) {
        return locale;
      }
    }
    return null;
  }
}

abstract final class AppPreferencesStorageKey {
  static const schemaVersion = 'preferences_schema_version';
  static const onboardingCompleted = 'onboarding_completed';
  static const locale = 'app_locale';
  static const theme = 'theme_setting';
  static const reduceMotion = 'reduce_motion';
  static const textScale = 'text_scale';

  static const all = <String>{
    schemaVersion,
    onboardingCompleted,
    locale,
    theme,
    reduceMotion,
    textScale,
  };
}

@immutable
class AppPreferencesState {
  const AppPreferencesState({
    this.onboardingCompleted = false,
    this.locale = AppLocale.malay,
    this.themeSetting = AppThemeSetting.system,
    this.reduceMotion = false,
    this.textScale = 1,
  });

  static const minimumTextScale = 0.9;
  static const maximumTextScale = 1.5;

  final bool onboardingCompleted;
  final AppLocale locale;
  final AppThemeSetting themeSetting;
  final bool reduceMotion;
  final double textScale;

  factory AppPreferencesState.fromPersistedValues(Map<String, Object?> values) {
    final persistedTextScale = values[AppPreferencesStorageKey.textScale];
    final textScale =
        persistedTextScale is num &&
            persistedTextScale.isFinite &&
            persistedTextScale >= minimumTextScale &&
            persistedTextScale <= maximumTextScale
        ? persistedTextScale.toDouble()
        : 1.0;

    return AppPreferencesState(
      onboardingCompleted:
          values[AppPreferencesStorageKey.onboardingCompleted] == true,
      locale:
          AppLocale.fromStorageValue(values[AppPreferencesStorageKey.locale]) ??
          AppLocale.malay,
      themeSetting:
          AppThemeSettingX.fromStorageValue(
            values[AppPreferencesStorageKey.theme],
          ) ??
          AppThemeSetting.system,
      reduceMotion: values[AppPreferencesStorageKey.reduceMotion] == true,
      textScale: textScale,
    );
  }

  Map<String, Object> toPersistedValues() => <String, Object>{
    AppPreferencesStorageKey.schemaVersion: 1,
    AppPreferencesStorageKey.onboardingCompleted: onboardingCompleted,
    AppPreferencesStorageKey.locale: locale.languageCode,
    AppPreferencesStorageKey.theme: themeSetting.name,
    AppPreferencesStorageKey.reduceMotion: reduceMotion,
    AppPreferencesStorageKey.textScale: textScale,
  };

  AppPreferencesState copyWith({
    bool? onboardingCompleted,
    AppLocale? locale,
    AppThemeSetting? themeSetting,
    bool? reduceMotion,
    double? textScale,
  }) {
    return AppPreferencesState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      locale: locale ?? this.locale,
      themeSetting: themeSetting ?? this.themeSetting,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      textScale: textScale ?? this.textScale,
    );
  }
}

abstract interface class AppPreferencesStore {
  AppPreferencesState read();

  Future<void> write(AppPreferencesState state);
}

/// A store used by widget/unit tests and as the safe in-memory fallback if the
/// non-sensitive platform preferences cannot be initialized.
class InMemoryAppPreferencesStore implements AppPreferencesStore {
  InMemoryAppPreferencesStore({Map<String, Object?> initialValues = const {}})
    : _values = Map<String, Object?>.of(initialValues);

  final Map<String, Object?> _values;

  Map<String, Object?> get persistedValues => Map.unmodifiable(_values);

  @override
  AppPreferencesState read() =>
      AppPreferencesState.fromPersistedValues(_values);

  @override
  Future<void> write(AppPreferencesState state) async {
    _values
      ..clear()
      ..addAll(state.toPersistedValues());
  }
}

/// Stores UI-only preferences in an allowlisted on-device cache.
///
/// This intentionally never stores reflections, bookmarks, source text,
/// reviewer data, credentials, or religious-content records.
class SharedPreferencesAppPreferencesStore implements AppPreferencesStore {
  SharedPreferencesAppPreferencesStore(this._preferences);

  final SharedPreferencesWithCache _preferences;

  @override
  AppPreferencesState read() {
    return AppPreferencesState.fromPersistedValues({
      for (final key in AppPreferencesStorageKey.all)
        key: _preferences.get(key),
    });
  }

  @override
  Future<void> write(AppPreferencesState state) async {
    final values = state.toPersistedValues();
    await Future.wait<void>([
      _preferences.setInt(
        AppPreferencesStorageKey.schemaVersion,
        values[AppPreferencesStorageKey.schemaVersion]! as int,
      ),
      _preferences.setBool(
        AppPreferencesStorageKey.onboardingCompleted,
        values[AppPreferencesStorageKey.onboardingCompleted]! as bool,
      ),
      _preferences.setString(
        AppPreferencesStorageKey.locale,
        values[AppPreferencesStorageKey.locale]! as String,
      ),
      _preferences.setString(
        AppPreferencesStorageKey.theme,
        values[AppPreferencesStorageKey.theme]! as String,
      ),
      _preferences.setBool(
        AppPreferencesStorageKey.reduceMotion,
        values[AppPreferencesStorageKey.reduceMotion]! as bool,
      ),
      _preferences.setDouble(
        AppPreferencesStorageKey.textScale,
        values[AppPreferencesStorageKey.textScale]! as double,
      ),
    ]);
  }
}

/// Opens the allowlisted preference cache used by the installed application.
///
/// A device can still use the safe shell if platform preferences are
/// temporarily unavailable. In that case, only non-sensitive UI preferences
/// are kept for the current session.
Future<AppPreferencesStore> createLocalAppPreferencesStore() async {
  try {
    final preferences = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: AppPreferencesStorageKey.all,
      ),
    );
    return SharedPreferencesAppPreferencesStore(preferences);
  } catch (_) {
    return InMemoryAppPreferencesStore();
  }
}

final appPreferencesStoreProvider = Provider<AppPreferencesStore>(
  (ref) => InMemoryAppPreferencesStore(),
);

class AppPreferencesController extends Notifier<AppPreferencesState> {
  Future<void> _pendingWrite = Future<void>.value();

  AppPreferencesStore get _store => ref.read(appPreferencesStoreProvider);

  @override
  AppPreferencesState build() => _store.read();

  Future<void> selectTheme(AppThemeSetting themeSetting) =>
      _update(state.copyWith(themeSetting: themeSetting));

  Future<void> selectLocale(AppLocale locale) =>
      _update(state.copyWith(locale: locale));

  Future<void> setReduceMotion(bool value) =>
      _update(state.copyWith(reduceMotion: value));

  Future<void> setTextScale(double value) {
    final normalizedValue = value
        .clamp(
          AppPreferencesState.minimumTextScale,
          AppPreferencesState.maximumTextScale,
        )
        .toDouble();
    return _update(state.copyWith(textScale: normalizedValue));
  }

  Future<void> completeOnboarding() =>
      _update(state.copyWith(onboardingCompleted: true));

  Future<void> _update(AppPreferencesState nextState) {
    state = nextState;
    final write = _pendingWrite.then<void>(
      (_) => _store.write(nextState),
      onError: (_, _) => _store.write(nextState),
    );
    _pendingWrite = write;

    // Keep the current session usable if platform storage becomes unavailable.
    // The next mutation still gets a chance to persist through the queued write.
    return write.onError((_, _) {});
  }
}

final appPreferencesProvider =
    NotifierProvider<AppPreferencesController, AppPreferencesState>(
      AppPreferencesController.new,
    );
