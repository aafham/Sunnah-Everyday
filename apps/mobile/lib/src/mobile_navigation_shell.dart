import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_router.dart';

class MobileNavigationShell extends StatelessWidget {
  const MobileNavigationShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  static const _destinations = <_MobileDestination>[
    _MobileDestination(MobilePath.today, Icons.wb_sunny_outlined),
    _MobileDestination(MobilePath.explore, Icons.explore_outlined),
    _MobileDestination(MobilePath.saved, Icons.bookmark_outline),
    _MobileDestination(MobilePath.settings, Icons.tune_outlined),
  ];

  int get _currentIndex {
    final index = _destinations.indexWhere(
      (destination) => location.startsWith(destination.path),
    );
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final labels = <String>[
      localizations.navToday,
      localizations.navExplore,
      localizations.navSaved,
      localizations.navSettings,
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Semantics(
        label: localizations.navigationSemantics,
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              context.go(_destinations[index].path),
          destinations: [
            for (var index = 0; index < _destinations.length; index++)
              NavigationDestination(
                icon: Icon(_destinations[index].icon),
                selectedIcon: Icon(_destinations[index].icon),
                label: labels[index],
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileDestination {
  const _MobileDestination(this.path, this.icon);

  final String path;
  final IconData icon;
}
