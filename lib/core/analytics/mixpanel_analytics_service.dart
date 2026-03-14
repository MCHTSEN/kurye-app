import 'package:backend_core/backend_core.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelAnalyticsService implements AnalyticsService {
  MixpanelAnalyticsService({required String token})
    : _mixpanelFuture = Mixpanel.init(
        token,
        trackAutomaticEvents: false,
      );

  final Future<Mixpanel> _mixpanelFuture;

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object?> traits = const <String, Object?>{},
  }) async {
    final mixpanel = await _mixpanelFuture;
    await mixpanel.identify(userId);

    if (traits.isNotEmpty) {
      final people = mixpanel.getPeople();
      for (final entry in traits.entries) {
        people.set(entry.key, entry.value);
      }
    }
  }

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {
    final mixpanel = await _mixpanelFuture;
    final people = mixpanel.getPeople();
    for (final entry in properties.entries) {
      people.set(entry.key, entry.value);
    }
  }

  @override
  Future<void> track(AnalyticsEvent event) async {
    final mixpanel = await _mixpanelFuture;
    await mixpanel.track(
      event.name,
      properties: _normalizeMap(event.properties),
    );
  }

  Map<String, dynamic> _normalizeMap(Map<String, Object?> input) {
    return input.map<String, dynamic>((key, value) {
      return MapEntry<String, dynamic>(key, value);
    });
  }
}
