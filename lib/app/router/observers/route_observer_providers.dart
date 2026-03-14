import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../product/analytics/analytics_provider.dart';
import 'analytics_route_observer.dart';

part 'route_observer_providers.g.dart';

@Riverpod(keepAlive: true)
NavigatorObserversBuilder appNavigatorObserversBuilder(Ref ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);

  return () {
    return <NavigatorObserver>[
      AnalyticsRouteObserver(analyticsService: analyticsService),
    ];
  };
}
