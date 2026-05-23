import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/router/app_router.dart';
import '../../app/router/custom_route.dart';
import '../../core/notifications/local_notification_service.dart';
import '../../core/notifications/push_notification_service.dart';
import '../auth/auth_providers.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return LocalNotificationService();
}

/// Backend'den FCM token repository sağlar — backend desteklemiyorsa null.
@Riverpod(keepAlive: true)
PushTokenRepository? pushTokenRepository(Ref ref) {
  return ref.watch(backendModuleProvider).createPushTokenRepository();
}

/// Push notification (FCM) servisi — sadece supabase backend'de aktif.
/// Bootstrap sonrası ilk `read` çağrısında lazy oluşturulur; `init()` ayrıca
/// çağrılmalı (bootstrap'te yapılıyor).
@Riverpod(keepAlive: true)
PushNotificationService? pushNotificationService(Ref ref) {
  final tokenRepo = ref.watch(pushTokenRepositoryProvider);
  if (tokenRepo == null) return null;
  final local = ref.watch(notificationServiceProvider);
  final router = ref.watch(appRouterProvider);
  return PushNotificationService(
    tokenRepository: tokenRepo,
    localNotificationService: local,
    onNotificationTap: (data) {
      // Şu an tek payload tipi: new_order → kurye ana ekranına yönlendir.
      if (data['type'] == 'new_order') {
        unawaited(router.replacePath(CustomRoute.kuryeAna.path));
      }
    },
  );
}
