import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'mobile_navigation_shell.dart';
import 'pages/daily_detail_page.dart';
import 'pages/explore_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/route_unavailable_page.dart';
import 'pages/saved_page.dart';
import 'pages/settings_page.dart';
import 'pages/today_page.dart';

abstract final class MobilePath {
  static const onboarding = '/onboarding';
  static const today = '/today';
  static const dailyDetail = '/today/detail';
  static const routeUnavailable = '/route-unavailable';
  static const explore = '/explore';
  static const saved = '/saved';
  static const settings = '/settings';
}

const _safeDeepLinkHosts = {'daily', 'content', 'correction'};
final _safeOpaqueSegment = RegExp(r'^[A-Za-z0-9._~-]+$');

/// Maps a recognised external URI to a static, fail-closed in-app route.
///
/// The opaque path segment is validated only. It is never placed in router
/// state, rendered, persisted, or logged. Content delivery remains dependent
/// on a future verified public-bundle contract.
String? safeRouteForExternalUri(Uri uri) {
  if (uri.scheme != 'sunnah' ||
      !_safeDeepLinkHosts.contains(uri.host) ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      uri.hasQuery ||
      uri.hasFragment ||
      uri.pathSegments.length != 1 ||
      !_safeOpaqueSegment.hasMatch(uri.pathSegments.single)) {
    return null;
  }

  return switch (uri.host) {
    'daily' || 'content' => MobilePath.dailyDetail,
    'correction' => MobilePath.routeUnavailable,
    _ => null,
  };
}

GoRouter createMobileRouter({
  required ValueListenable<bool> onboardingCompleted,
  required String initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: onboardingCompleted,
    onException: (context, state, router) {
      final safeRoute = safeRouteForExternalUri(state.uri);
      router.go(safeRoute ?? MobilePath.routeUnavailable);
    },
    redirect: (context, state) {
      if (state.uri.hasScheme || state.uri.hasAuthority) {
        return safeRouteForExternalUri(state.uri) ??
            MobilePath.routeUnavailable;
      }

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
            path: MobilePath.routeUnavailable,
            builder: (context, state) => const RouteUnavailablePage(),
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
