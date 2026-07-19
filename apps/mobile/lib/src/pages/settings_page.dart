import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app_preferences.dart';
import '../private_reflections.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final preferences = ref.watch(appPreferencesProvider);
    final controller = ref.read(appPreferencesProvider.notifier);
    final privateReflectionState = ref
        .watch(privateReflectionProvider)
        .asData
        ?.value;
    final canDeletePrivateData = switch (privateReflectionState) {
      PrivateReflectionReady(:final snapshot, :final isMutating) =>
        !snapshot.isEmpty && !isMutating,
      _ => false,
    };
    final privateStorageUnavailable = switch (privateReflectionState) {
      PrivateReflectionUnavailable() => true,
      _ => false,
    };
    final isPrivateStorageMutating = switch (privateReflectionState) {
      PrivateReflectionUnavailable(:final isMutating) => isMutating,
      _ => false,
    };
    final canAttemptPrivateDataRecovery =
        privateStorageUnavailable &&
        !isPrivateStorageMutating &&
        ref.read(privateReflectionStoreProvider).canAttemptRecoveryDeletion;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text(localizations.settingsTitle),
        ),
      ),
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
            Semantics(
              container: true,
              label: localizations.themeLabel,
              child: SegmentedButton<AppThemeSetting>(
                key: const ValueKey('settings-theme'),
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
            ),
            const SizedBox(height: 24),
            Semantics(
              container: true,
              label: localizations.reduceMotionTitle,
              child: SwitchListTile.adaptive(
                key: const ValueKey('settings-reduce-motion'),
                contentPadding: EdgeInsets.zero,
                title: Text(localizations.reduceMotionTitle),
                subtitle: Text(localizations.reduceMotionSubtitle),
                value: preferences.reduceMotion,
                onChanged: (value) {
                  unawaited(controller.setReduceMotion(value));
                },
              ),
            ),
            const Divider(height: 32),
            Text(
              localizations.textSizeTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Semantics(
              container: true,
              label: localizations.textSizeTitle,
              child: Slider(
                key: const ValueKey('settings-text-scale'),
                value: preferences.textScale,
                min: 0.9,
                max: 1.5,
                divisions: 6,
                label: localizations.textScalePercent(
                  (preferences.textScale * 100).round(),
                ),
                semanticFormatterCallback: (value) =>
                    localizations.textScalePercent((value * 100).round()),
                onChanged: (value) {
                  unawaited(controller.setTextScale(value));
                },
              ),
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
            const Divider(height: 40),
            Semantics(
              header: true,
              child: Text(
                localizations.privateDataHeading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(localizations.privateDataMessage),
            if (privateStorageUnavailable) ...[
              const SizedBox(height: 8),
              Text(localizations.privateReflectionStorageUnavailableMessage),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const ValueKey('private-data-delete-all'),
              onPressed: canDeletePrivateData || canAttemptPrivateDataRecovery
                  ? () => unawaited(_confirmDeletePrivateData(context, ref))
                  : null,
              icon: const Icon(Icons.delete_outline),
              label: Text(localizations.deleteAllPrivateData),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeletePrivateData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.deleteAllPrivateDataTitle),
        content: Text(localizations.deleteAllPrivateDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final didDelete = await ref
        .read(privateReflectionProvider.notifier)
        .deleteAllReflections();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          didDelete
              ? localizations.privateDataDeleted
              : localizations.privateDataDeleteFailed,
        ),
      ),
    );
  }
}
