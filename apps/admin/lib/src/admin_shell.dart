import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin_router.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _destinations = [
    _AdminDestination(
      AdminPath.dashboard,
      'Papan pemuka',
      Icons.dashboard_outlined,
    ),
    _AdminDestination(AdminPath.drafts, 'Draf', Icons.edit_note_outlined),
    _AdminDestination(AdminPath.reviews, 'Semakan', Icons.fact_check_outlined),
    _AdminDestination(AdminPath.sources, 'Sumber', Icons.source_outlined),
    _AdminDestination(AdminPath.reports, 'Laporan', Icons.flag_outlined),
  ];

  int get _selectedIndex {
    final index = _destinations.indexWhere(
      (destination) => location.startsWith(destination.path),
    );
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wideLayout =
            constraints.maxWidth >= SunnahLayout.adminNavigationBreakpoint;

        void navigate(int index) {
          context.go(_destinations[index].path);
          if (!wideLayout) {
            Navigator.of(context).pop();
          }
        }

        if (wideLayout) {
          return Scaffold(
            body: Row(
              children: [
                Semantics(
                  key: const ValueKey('admin-navigation'),
                  label: 'Navigasi admin',
                  container: true,
                  explicitChildNodes: true,
                  child: NavigationRail(
                    extended: true,
                    minExtendedWidth: SunnahLayout.adminNavigationRailWidth,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: navigate,
                    leading: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 20),
                      child: _AdminBrand(),
                    ),
                    destinations: [
                      for (final destination in _destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.icon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Sunnah Everyday Admin')),
          drawer: Semantics(
            key: const ValueKey('admin-navigation'),
            label: 'Navigasi admin',
            container: true,
            explicitChildNodes: true,
            child: Drawer(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: _AdminBrand(),
                    ),
                    for (var index = 0; index < _destinations.length; index++)
                      ListTile(
                        leading: Icon(_destinations[index].icon),
                        title: Text(_destinations[index].label),
                        selected: index == _selectedIndex,
                        onTap: () => navigate(index),
                      ),
                  ],
                ),
              ),
            ),
          ),
          body: child,
        );
      },
    );
  }
}

class _AdminBrand extends StatelessWidget {
  const _AdminBrand();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sunnah Everyday',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text('Admin CMS', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _AdminDestination {
  const _AdminDestination(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}
