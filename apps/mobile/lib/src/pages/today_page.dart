import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Semantics(
            header: true,
            child: Text(
              localizations.todayHeading,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.todayIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          SunnahSectionCard(
            eyebrow: localizations.contentStatusEyebrow,
            title: localizations.noApprovedContentTitle,
            child: Text(localizations.noApprovedContentMessage),
          ),
          const SizedBox(height: 24),
          SunnahEmptyState(
            icon: Icons.verified_user_outlined,
            title: localizations.accuracyFirstTitle,
            message: localizations.accuracyFirstMessage,
          ),
        ],
      ),
    );
  }
}
