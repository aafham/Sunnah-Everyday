import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'mobile_navigation_shell.dart';
import 'pages/daily_detail_page.dart';
import 'pages/explore_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/saved_page.dart';
import 'pages/settings_page.dart';
import 'pages/today_page.dart';

abstract final class MobilePath {
  static const onboarding = '/onboarding';
  static const today = '/today';
  static const dailyDetail = '/today/detail';
  static const explore = '/explore';
  static const saved = '/saved';
  static const settings = '/settings';
}

GoRouter createMobileRouter({
  required ValueListenable<bool> onboardingCompleted,
  required String initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: onboardingCompleted,
    redirect: (context, state) {
      final isOnboarding = state.uri.path == MobilePath.onboarding;
      if (!onboardingCompleted.value) {
        return isOnboarding ? null : MobilePath.onboarding;
      }
      return isOnboarding ? MobilePath.today : null;
    },
    routes: [
      GoRoute(
        path: MobilePath.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            MobileNavigationShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: MobilePath.today,
            builder: (context, state) => const TodayPage(),
          ),
          GoRoute(
            path: MobilePath.dailyDetail,
            builder: (context, state) => const DailyDetailPage(),
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
