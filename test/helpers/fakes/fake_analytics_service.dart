import 'package:backend_core/backend_core.dart';

class FakeAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> trackedEvents = <AnalyticsEvent>[];
  String? identifiedUserId;

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object?> traits = const <String, Object?>{},
  }) async {
    identifiedUserId = userId;
  }

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {}

  @override
  Future<void> track(AnalyticsEvent event) async {
    trackedEvents.add(event);
  }
}
