import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.savedTitle)),
      body: SunnahEmptyState(
        icon: Icons.bookmark_outline,
        title: localizations.savedEmptyTitle,
        message: localizations.savedEmptyMessage,
      ),
    );
  }
}
