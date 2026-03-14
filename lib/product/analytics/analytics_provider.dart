import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/analytics/mixpanel_analytics_service.dart';
import '../../core/analytics/noop_analytics_service.dart';
import '../environment/environment_provider.dart';

part 'analytics_provider.g.dart';

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  final environment = ref.watch(appEnvironmentProvider);

  if (!environment.analyticsEnabled || environment.mixpanelToken.isEmpty) {
    return const NoopAnalyticsService();
  }

  return MixpanelAnalyticsService(token: environment.mixpanelToken);
}
