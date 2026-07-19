import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/src/app_preferences.dart';

void main() {
  test('corrupt preference values fall back to the safe defaults', () {
    final preferences = AppPreferencesState.fromPersistedValues({
      AppPreferencesStorageKey.onboardingCompleted: 'true',
      AppPreferencesStorageKey.locale: 'unsupported',
      AppPreferencesStorageKey.theme: 'unknown',
      AppPreferencesStorageKey.reduceMotion: 'yes',
      AppPreferencesStorageKey.textScale: double.nan,
    });

    expect(preferences.onboardingCompleted, isFalse);
    expect(preferences.locale, AppLocale.malay);
    expect(preferences.themeSetting, AppThemeSetting.system);
    expect(preferences.reduceMotion, isFalse);
    expect(preferences.textScale, 1);
  });

  test(
    'preferences persist across provider containers and clamp text scale',
    () async {
      final store = InMemoryAppPreferencesStore();
      final firstContainer = ProviderContainer(
        overrides: [appPreferencesStoreProvider.overrideWithValue(store)],
      );

      final controller = firstContainer.read(appPreferencesProvider.notifier);
      await controller.selectLocale(AppLocale.english);
      await controller.selectTheme(AppThemeSetting.dark);
      await controller.setReduceMotion(true);
      await controller.setTextScale(0);
      expect(
        firstContainer.read(appPreferencesProvider).textScale,
        AppPreferencesState.minimumTextScale,
      );
      await controller.setTextScale(9);
      await controller.completeOnboarding();

      expect(
        firstContainer.read(appPreferencesProvider).textScale,
        AppPreferencesState.maximumTextScale,
      );
      firstContainer.dispose();

      final secondContainer = ProviderContainer(
        overrides: [appPreferencesStoreProvider.overrideWithValue(store)],
      );
      addTearDown(secondContainer.dispose);
      final rehydrated = secondContainer.read(appPreferencesProvider);

      expect(rehydrated.onboardingCompleted, isTrue);
      expect(rehydrated.locale, AppLocale.english);
      expect(rehydrated.themeSetting, AppThemeSetting.dark);
      expect(rehydrated.reduceMotion, isTrue);
      expect(rehydrated.textScale, AppPreferencesState.maximumTextScale);
    },
  );
}
