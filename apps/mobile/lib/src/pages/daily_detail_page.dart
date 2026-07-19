import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app_router.dart';
import '../daily_content.dart';

/// A safe detail surface for the daily-card status.
///
/// It has no item-id route parameter and reads only the fail-closed state until
/// verified public bundles and their publication gates are implemented.
class DailyDetailPage extends ConsumerWidget {
  const DailyDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(dailyDetailContentProvider);

    return switch (state) {
      NoApprovedDailyContent() => Scaffold(
        appBar: AppBar(
          leading: Semantics(
            label: localizations.backToToday,
            button: true,
            child: IconButton(
              key: const ValueKey('daily-detail-back'),
              tooltip: localizations.backToToday,
              onPressed: () => context.go(MobilePath.today),
              icon: const BackButtonIcon(),
            ),
          ),
          title: Text(localizations.dailyDetailTitle),
        ),
        body: SafeArea(
          child: SunnahContentFrame(
            child: ListView(
              padding: SunnahLayout.mobilePagePadding,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    localizations.dailyDetailTitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                const SizedBox(height: 24),
                SunnahEmptyState(
                  icon: Icons.verified_user_outlined,
                  title: localizations.dailyDetailUnavailableTitle,
                  message: localizations.noApprovedContentMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    };
  }
}
