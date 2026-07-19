import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.exploreTitle)),
      body: SunnahContentFrame(
        child: SunnahEmptyState(
          icon: Icons.explore_outlined,
          title: localizations.exploreEmptyTitle,
          message: localizations.exploreEmptyMessage,
        ),
      ),
    );
  }
}
