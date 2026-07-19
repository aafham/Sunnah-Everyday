import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app_preferences.dart';

/// A short, local-only first-launch step. It deliberately contains no
/// religious-content records, claims, or approval metadata.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final preferences = ref.watch(appPreferencesProvider);
    final controller = ref.read(appPreferencesProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 48),
                Semantics(
                  header: true,
                  child: Text(
                    localizations.onboardingTitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.onboardingDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                Text(
                  localizations.onboardingLanguageHeading,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: localizations.languageLabel,
                  child: SegmentedButton<AppLocale>(
                    key: const ValueKey('onboarding-language'),
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
                const SizedBox(height: 40),
                FilledButton(
                  key: const ValueKey('onboarding-continue'),
                  onPressed: () {
                    unawaited(controller.completeOnboarding());
                  },
                  child: Text(localizations.continueLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
