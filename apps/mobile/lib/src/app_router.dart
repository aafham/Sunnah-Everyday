import 'package:go_router/go_router.dart';

import 'mobile_navigation_shell.dart';
import 'pages/explore_page.dart';
import 'pages/saved_page.dart';
import 'pages/settings_page.dart';
import 'pages/today_page.dart';

abstract final class MobilePath {
  static const today = '/today';
  static const explore = '/explore';
  static const saved = '/saved';
  static const settings = '/settings';
}

GoRouter createMobileRouter() {
  return GoRouter(
    initialLocation: MobilePath.today,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            MobileNavigationShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: MobilePath.today,
            builder: (context, state) => const TodayPage(),
          ),
          GoRoute(
            path: MobilePath.explore,
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: MobilePath.saved,
            builder: (context, state) => const SavedPage(),
          ),
          GoRoute(
            path: MobilePath.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
