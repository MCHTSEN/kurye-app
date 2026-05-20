import 'dart:async';
import 'dart:io' show Platform;

import 'package:backend_core/backend_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// flutter_local_notifications tabanlı [NotificationService] implementasyonu.
///
/// Foreground'da banner/sound ile bildirim gösterir. Sipariş akışı için
/// `orders` kanalını kullanır.
class LocalNotificationService implements NotificationService {
  LocalNotificationService();

  static final _log = AppLogger(
    'LocalNotificationService',
    tag: LogTag.notification,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final _tapController = StreamController<NotificationMessage>.broadcast();
  bool _initialized = false;

  static const _ordersChannelId = 'orders';
  static const _ordersChannelName = 'Siparişler';
  static const _ordersChannelDescription = 'Yeni iş atamaları';

  /// Bootstrap'ten sonra bir kez çağırılır. İdempotent.
  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      _log.i('LocalNotificationService skipped on web');
      return;
    }
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS foreground'da banner + ses + badge otomatik göster.
    // İzin requestPermission()'da istenir; init'i bloke etme.
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        _tapController.add(
          NotificationMessage(
            id: response.id,
            data: response.payload != null
                ? {'payload': response.payload}
                : const <String, dynamic>{},
          ),
        );
      },
    );

    // Android 13+ için kanal oluştur (channel id ile show'da eşleşmeli).
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _ordersChannelId,
          _ordersChannelName,
          description: _ordersChannelDescription,
          importance: Importance.high,
        ),
      );
    }
    _initialized = true;
    _log.i('LocalNotificationService initialized');
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (Platform.isIOS || Platform.isMacOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted =
          await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  @override
  Future<bool> isPermissionGranted() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      // iOS için ayrıştırılmış kontrol yok; izin istendiğinde dönen değer
      // belirleyici. Burada permissive false dönüyoruz; çağıran istek
      // göndererek doğrulamalı.
      return true;
    }
    return false;
  }

  @override
  Future<void> show(NotificationMessage message) async {
    if (!_initialized) {
      _log.w('show() called before init() — skipping');
      return;
    }
    if (kIsWeb) return;
    await _plugin.show(
      message.id ?? DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      message.title,
      message.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ordersChannelId,
          _ordersChannelName,
          channelDescription: _ordersChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['payload'] as String?,
    );
  }

  @override
  Stream<NotificationMessage> get onMessageTapped => _tapController.stream;
}
