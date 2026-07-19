import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app_router.dart';

/// A generic recovery surface for malformed or unavailable app routes.
///
/// It intentionally receives no route, exception, or external identifier, so
/// those values cannot reach the UI while public content delivery is absent.
class RouteUnavailablePage extends StatelessWidget {
  const RouteUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text(localizations.routeUnavailableTitle),
        ),
      ),
      body: SafeArea(
        child: SunnahContentFrame(
          child: Center(
            child: Padding(
              padding: SunnahLayout.mobilePagePadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SunnahEmptyState(
                    icon: Icons.link_off_outlined,
                    title: localizations.routeUnavailableTitle,
                    message: localizations.routeUnavailableMessage,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const ValueKey('route-unavailable-return-today'),
                    onPressed: () => context.go(MobilePath.today),
                    child: Text(localizations.returnToToday),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
