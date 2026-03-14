import 'domain/analytics_event.dart';

abstract class AnalyticsService {
  Future<void> track(AnalyticsEvent event);

  Future<void> identify({
    required String userId,
    Map<String, Object?> traits = const <String, Object?>{},
  });

  Future<void> setUserProperties(Map<String, Object?> properties);
}
