import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backend_core/backend_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notification service using [FlutterLocalNotificationsPlugin].
///
/// Handles notification display, permission requests, and tap routing
/// without any dependency on FCM or remote push services.
class LocalNotificationService implements NotificationService {
  LocalNotificationService() {
    unawaited(_initialize());
  }

  static final _log = AppLogger(
    'LocalNotificationService',
    tag: LogTag.notification,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<NotificationMessage>.broadcast();

  int _nextId = 0;

  static const _androidChannel = AndroidNotificationChannel(
    'default_channel',
    'Default',
    description: 'Default notification channel.',
    importance: Importance.high,
  );

  Future<void> _initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTapped,
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    _log.i('Local notification service initialized');
  }

  void _onTapped(NotificationResponse response) {
    _log.d('Notification tapped: ${response.id}');

    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _tapController.add(NotificationMessage(data: data));
      } on FormatException {
        _log.w('Failed to parse notification payload');
      }
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      _log.i('Android notification permission: $granted');
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      _log.i('iOS notification permission: $granted');
      return granted ?? false;
    }

    return false;
  }

  @override
  Future<void> show(NotificationMessage message) async {
    final id = message.id ?? _nextId++;

    unawaited(
      _plugin.show(
        id,
        message.title,
        message.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      ),
    );

    _log.d('Notification shown: id=$id, title=${message.title}');
  }

  @override
  Stream<NotificationMessage> get onMessageTapped => _tapController.stream;

  @override
  Future<bool> isPermissionGranted() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.areNotificationsEnabled();
      return granted ?? false;
    }
    // iOS doesn't have a simple check via this plugin
    return true;
  }
}
