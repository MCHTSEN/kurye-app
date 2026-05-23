import 'dart:async';
import 'dart:io' show Platform;

import 'package:backend_core/backend_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Firebase Cloud Messaging entegrasyonu.
///
/// init():
///   - iOS/Android için permission ister
///   - Mevcut token'ı [PushTokenRepository.upsert] ile DB'ye kaydeder
///   - onTokenRefresh dinler → re-upsert
///   - onMessage (foreground) → [LocalNotificationService.show] fallback
///   - onMessageOpenedApp + getInitialMessage → tap handler çağrılır
///
/// shutdown(): logout sırasında çağrılır; cihaz token'ını DB'den siler ve
/// FCM kaydını da temizler ki kullanıcı bir daha o cihazda push almasın.
class PushNotificationService {
  PushNotificationService({
    required PushTokenRepository tokenRepository,
    required NotificationService localNotificationService,
    required this.onNotificationTap,
  })  : _tokenRepository = tokenRepository,
        _localNotificationService = localNotificationService;

  final PushTokenRepository _tokenRepository;
  final NotificationService _localNotificationService;
  final void Function(Map<String, dynamic> data) onNotificationTap;

  static final _log = AppLogger('PushNotif', tag: LogTag.notification);

  StreamSubscription<String>? _refreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      _initialized = true;
      return;
    }

    final messaging = FirebaseMessaging.instance;

    // iOS: alert/badge/sound + provisional fallback. flutter_local_notifications
    // izni de zaten bootstrap'te isteniyor; FCM kendi auth flow'unu paylaşır.
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    _log.i('FCM permission: ${settings.authorizationStatus}');

    // iOS APNs token gelmeden FCM token alınamaz. APNs hazır olmasını bekle.
    if (Platform.isIOS) {
      final apnsToken = await messaging.getAPNSToken();
      _log.d('APNs token present: ${apnsToken != null}');
    }

    final token = await messaging.getToken();
    if (token != null) {
      await _safeUpsert(token);
    } else {
      _log.w('FCM token null on init');
    }

    _refreshSub = messaging.onTokenRefresh.listen(
      _safeUpsert,
      onError: (Object e, StackTrace st) =>
          _log.e('onTokenRefresh error', error: e, stackTrace: st),
    );

    // Foreground: APNs/Android banner sistem tarafından gösterilmez —
    // LocalNotificationService.show ile manuel göster.
    _foregroundSub = FirebaseMessaging.onMessage.listen(
      _handleForeground,
      onError: (Object e, StackTrace st) =>
          _log.e('onMessage error', error: e, stackTrace: st),
    );

    // Bildirim tap → app açıkken background'dan dönüş
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedApp,
      onError: (Object e, StackTrace st) =>
          _log.e('onMessageOpenedApp error', error: e, stackTrace: st),
    );

    // Cold start — app kapalıyken bildirim ile açıldı
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _log.i('getInitialMessage: ${initial.messageId}');
      onNotificationTap(_dataFrom(initial));
    }

    _initialized = true;
  }

  Future<void> _safeUpsert(String token) async {
    try {
      await _tokenRepository.upsert(
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      _log.i('token upserted (${token.length} chars)');
    } on Exception catch (e, st) {
      _log.e('token upsert failed', error: e, stackTrace: st);
    }
  }

  /// Login sonrası çağrılır — token'ı tekrar fetch eder ve auth'lu user için
  /// upsert eder. init() bootstrap'te auth olmadan da çalışabilir; gerçek
  /// kullanıcı login olunca bu metod tetiklenmeli.
  Future<void> refreshToken() async {
    if (!_initialized || kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        _log.w('refreshToken: FCM token null');
        return;
      }
      await _safeUpsert(token);
    } on Exception catch (e, st) {
      _log.e('refreshToken failed', error: e, stackTrace: st);
    }
  }

  Future<void> _handleForeground(RemoteMessage msg) async {
    _log.i('onMessage: ${msg.messageId} data=${msg.data}');
    final notification = msg.notification;
    final title = notification?.title ?? msg.data['title'] as String? ?? 'Yeni iş';
    final body = notification?.body ??
        msg.data['body'] as String? ??
        'Size yeni bir sipariş atandı';
    // Aynı siparis_id için idempotent — çift bildirim önlemi
    final id = (msg.data['siparis_id'] as String?)?.hashCode;
    await _localNotificationService.show(
      NotificationMessage(
        id: id,
        title: title,
        body: body,
        data: {for (final e in msg.data.entries) e.key: e.value},
      ),
    );
  }

  void _handleOpenedApp(RemoteMessage msg) {
    _log.i('onMessageOpenedApp: ${msg.messageId} data=${msg.data}');
    onNotificationTap(_dataFrom(msg));
  }

  Map<String, dynamic> _dataFrom(RemoteMessage msg) =>
      <String, dynamic>{...msg.data};

  /// Logout öncesi çağrılır — bu cihazın push token'ını sil ve FCM kaydını boş.
  Future<void> shutdown() async {
    if (!_initialized) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _tokenRepository.remove(token);
      }
      await FirebaseMessaging.instance.deleteToken();
    } on Exception catch (e, st) {
      _log.e('shutdown failed', error: e, stackTrace: st);
    }
    await _refreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
    _initialized = false;
  }
}
