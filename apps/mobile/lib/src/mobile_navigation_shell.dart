import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

class MobileNavigationShell extends StatelessWidget {
  const MobileNavigationShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  static const _destinations = [
    _MobileDestination(MobilePath.today, 'Hari Ini', Icons.wb_sunny_outlined),
    _MobileDestination(MobilePath.explore, 'Teroka', Icons.explore_outlined),
    _MobileDestination(MobilePath.saved, 'Simpanan', Icons.bookmark_outline),
    _MobileDestination(MobilePath.settings, 'Tetapan', Icons.tune_outlined),
  ];

  int get _currentIndex {
    final index = _destinations.indexWhere(
      (destination) => location.startsWith(destination.path),
    );
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Semantics(
        label: 'Navigasi utama',
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              context.go(_destinations[index].path),
          destinations: [
            for (final destination in _destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.icon),
                label: destination.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileDestination {
  const _MobileDestination(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}
