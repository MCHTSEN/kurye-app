import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/notifications/local_notification_service.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return LocalNotificationService();
}
