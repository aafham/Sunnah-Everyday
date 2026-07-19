import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app_preferences.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final preferences = ref.watch(appPreferencesProvider);
    final controller = ref.read(appPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: SunnahContentFrame(
        child: ListView(
          padding: SunnahLayout.compactPagePadding,
          children: [
            Semantics(
              header: true,
              child: Text(
                localizations.displayHeading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.languageLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Semantics(
              label: localizations.languageLabel,
              child: SegmentedButton<AppLocale>(
                key: const ValueKey('settings-language'),
                segments: [
                  ButtonSegment(
                    value: AppLocale.malay,
                    label: Text(localizations.malayLanguage),
                  ),
                  ButtonSegment(
                    value: AppLocale.english,
                    label: Text(localizations.englishLanguage),
                  ),
                ],
                selected: {preferences.locale},
                onSelectionChanged: (selection) {
                  unawaited(controller.selectLocale(selection.first));
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.themeLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<AppThemeSetting>(
              segments: [
                ButtonSegment(
                  value: AppThemeSetting.system,
                  label: Text(localizations.themeSystem),
                  icon: const Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: AppThemeSetting.light,
                  label: Text(localizations.themeLight),
                  icon: const Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: AppThemeSetting.dark,
                  label: Text(localizations.themeDark),
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {preferences.themeSetting},
              onSelectionChanged: (selection) {
                unawaited(controller.selectTheme(selection.first));
              },
            ),
            const SizedBox(height: 24),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(localizations.reduceMotionTitle),
              subtitle: Text(localizations.reduceMotionSubtitle),
              value: preferences.reduceMotion,
              onChanged: (value) {
                unawaited(controller.setReduceMotion(value));
              },
            ),
            const Divider(height: 32),
            Text(
              localizations.textSizeTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: preferences.textScale,
              min: 0.9,
              max: 1.5,
              divisions: 6,
              label: localizations.textScalePercent(
                (preferences.textScale * 100).round(),
              ),
              onChanged: (value) {
                unawaited(controller.setTextScale(value));
              },
            ),
            Text(
              localizations.textSizePreview,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 40),
            Semantics(
              header: true,
              child: Text(
                localizations.privacyHeading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(localizations.privacyMessage),
          ],
        ),
      ),
    );
  }
}
