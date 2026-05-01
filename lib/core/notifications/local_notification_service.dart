import 'dart:async';

import 'package:backend_core/backend_core.dart';

/// No-op implementation of [NotificationService].
///
/// Satisfies the interface without depending on flutter_local_notifications.
/// Replace with a real implementation when local notifications are needed.
class LocalNotificationService implements NotificationService {
  final _tapController = StreamController<NotificationMessage>.broadcast();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> show(NotificationMessage message) async {}

  @override
  Stream<NotificationMessage> get onMessageTapped => _tapController.stream;

  @override
  Future<bool> isPermissionGranted() async => false;
}
