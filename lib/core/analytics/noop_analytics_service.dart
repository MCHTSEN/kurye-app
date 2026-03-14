import 'package:backend_core/backend_core.dart';

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object?> traits = const <String, Object?>{},
  }) async {}

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {}

  @override
  Future<void> track(AnalyticsEvent event) async {}
}
