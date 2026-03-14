/// Abstract interface for local notification handling.
///
/// Implementations handle permission requests, notification display,
/// and tap response routing.
abstract class NotificationService {
  /// Requests notification permission from the user.
  Future<bool> requestPermission();

  /// Shows a local notification with the given [message].
  Future<void> show(NotificationMessage message);

  /// Stream of messages when user taps a notification.
  Stream<NotificationMessage> get onMessageTapped;

  /// Checks if notifications are currently permitted.
  Future<bool> isPermissionGranted();
}

/// Platform-agnostic notification message model.
class NotificationMessage {
  const NotificationMessage({
    this.id,
    this.title,
    this.body,
    this.data = const <String, dynamic>{},
    this.imageUrl,
  });

  /// Optional notification ID for deduplication.
  final int? id;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final String? imageUrl;
}
