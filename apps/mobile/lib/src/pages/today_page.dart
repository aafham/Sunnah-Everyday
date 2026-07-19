import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app_router.dart';
import '../daily_content.dart';
import '../widgets/daily_card.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final dailyContent = ref.watch(todayDailyContentProvider);

    return SafeArea(
      child: SunnahContentFrame(
        child: ListView(
          padding: SunnahLayout.mobilePagePadding,
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
            DailyCard(
              state: dailyContent,
              onViewStatus: () => context.push(MobilePath.dailyDetail),
            ),
            const SizedBox(height: 24),
            SunnahEmptyState(
              icon: Icons.verified_user_outlined,
              title: localizations.accuracyFirstTitle,
              message: localizations.accuracyFirstMessage,
            ),
          ],
        ),
      ),
    );
  }
}
