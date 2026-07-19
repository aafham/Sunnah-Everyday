import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../daily_content.dart';

/// A presentation-safe daily card.
///
/// The current state has no content payload. Keeping this switch exhaustive
/// makes any future renderable state an intentional, reviewed addition rather
/// than an accidental path from draft data to the public UI.
class DailyCard extends StatelessWidget {
  const DailyCard({required this.state, required this.onViewStatus, super.key});

  final DailyContentState state;
  final VoidCallback onViewStatus;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return switch (state) {
      NoApprovedDailyContent() => SunnahSectionCard(
        key: const ValueKey('daily-card'),
        eyebrow: localizations.dailyCardEyebrow,
        title: localizations.noApprovedContentTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.noApprovedContentMessage),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const ValueKey('daily-card-status'),
              onPressed: onViewStatus,
              icon: const Icon(Icons.info_outline),
              label: Text(localizations.dailyCardStatusAction),
            ),
          ],
        ),
      ),
    };
  }
}
