class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    this.properties = const <String, Object?>{},
  });

  factory AnalyticsEvent.screenViewed(String screenName) {
    return AnalyticsEvent(
      name: 'screen_viewed',
      properties: <String, Object?>{'screen_name': screenName},
    );
  }

  final String name;
  final Map<String, Object?> properties;
}
