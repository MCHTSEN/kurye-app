import 'package:backend_core/backend_core.dart';

/// No-op implementation for when notifications are not needed.
class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> show(NotificationMessage message) async {}

  @override
  Stream<NotificationMessage> get onMessageTapped => const Stream.empty();

  @override
  Future<bool> isPermissionGranted() async => false;
}
