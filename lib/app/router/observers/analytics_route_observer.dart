import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:backend_core/backend_core.dart';
import 'package:flutter/widgets.dart';

class AnalyticsRouteObserver extends AutoRouterObserver {
  AnalyticsRouteObserver({required AnalyticsService analyticsService})
    : _analyticsService = analyticsService;

  final AnalyticsService _analyticsService;

  static final _log = AppLogger(
    'AnalyticsRouteObserver',
    tag: LogTag.analytics,
  );

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    super.didInitTabRoute(route, previousRoute);
    _trackWithPath(route.path);
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    super.didChangeTabRoute(route, previousRoute);
    _trackWithPath(route.path);
  }

  void _trackRoute(Route<dynamic> route) {
    final routeData = route.data;
    if (routeData == null) {
      return;
    }

    _trackWithPath(routeData.path);
  }

  void _trackWithPath(String routePath) {
    final screenName = _toScreenName(routePath);
    _log.d('Tracking screen: $screenName');
    unawaited(
      _analyticsService.track(
        AnalyticsEvent.screenViewed(screenName),
      ),
    );
  }

  String _toScreenName(String path) {
    final trimmed = path.trim();
    if (trimmed == '/' || trimmed.isEmpty) {
      return 'root';
    }

    return trimmed
        .replaceAll('/', '_')
        .replaceAll('-', '_')
        .replaceAll('__', '_')
        .replaceFirst('_', '');
  }
}
