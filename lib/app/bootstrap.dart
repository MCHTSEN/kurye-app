import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/environment/app_environment.dart';
import '../core/error/app_error_handler.dart';
import '../core/error/app_error_widget.dart';
import '../core/monitoring/sentry_service.dart';
import '../core/notifications/local_notification_service.dart';
import '../product/auth/auth_providers.dart';
import '../product/environment/environment_provider.dart';
import '../product/notifications/notification_providers.dart';
import '../product/riverpod/app_provider_observer.dart';
import 'app.dart';

Future<void> bootstrap({
  required BackendModule module,
  AppEnvironment? environment,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    logConfig = AppLogConfig(enabled: false);
  }

  final resolvedEnvironment = environment ?? AppEnvironment.fromDartDefine();

  // Initialize Sentry before anything else so all errors are captured.
  await SentryService.initialize(
    dsn: resolvedEnvironment.sentryDsn,
    environment: resolvedEnvironment.flavor.name,
  );

  AppErrorHandler.initialize();
  ErrorWidget.builder = (details) => AppErrorWidget(details: details);

  final log = AppLogger('Bootstrap')
    ..i('Initializing backend module: ${module.runtimeType}');

  await module.initialize();

  // Firebase — push notification için. `flutterfire configure` ile platform
  // config dosyaları (GoogleService-Info.plist + google-services.json) hazır
  // olmalı. Parametresiz initializeApp native config'i okur.
  // Web'de FirebaseOptions zorunlu; mevcut setup'ta web için config yok →
  // skip et. Push notifications zaten sadece mobil platformlarda çalışıyor.
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      log.i('Firebase initialized');
    } on Exception catch (e, st) {
      log.e(
        'Firebase init failed — push notifications disabled. '
        'Run `flutterfire configure` if config dosyaları yoksa.',
        error: e,
        stackTrace: st,
      );
    }
  } else {
    log.i('Firebase init skipped on web');
  }

  // Local notifications — bootstrap'te kanal + permission kurulumu.
  // iOS init.requestAlertPermission=true zaten prompt'u tetikler;
  // Android için ayrıca requestPermission çağrısı şart (manifest izni +
  // 13+ runtime prompt).
  final notificationService = LocalNotificationService();
  try {
    await notificationService.init();
    final granted = await notificationService.requestPermission();
    log.i('Notification permission granted: $granted');
  } on Exception catch (e, st) {
    log.e('Notification init failed', error: e, stackTrace: st);
  }

  log.i('Backend initialized, starting app');

  final container = ProviderContainer(
    overrides: [
      appEnvironmentProvider.overrideWithValue(resolvedEnvironment),
      backendModuleProvider.overrideWithValue(module),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
    observers: const [AppProviderObserver()],
  );

  // FCM (push) — Firebase init başarılıysa ve backend destekliyorsa.
  // Container üzerinden okuyoruz çünkü router/auth provider'larına ihtiyacı var.
  unawaited(_initPushNotifications(container, log));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const KuryemApp(),
    ),
  );
}

Future<void> _initPushNotifications(
  ProviderContainer container,
  AppLogger log,
) async {
  try {
    final push = container.read(pushNotificationServiceProvider);
    if (push == null) {
      log.i('Push notification service not available for this backend');
      return;
    }
    await push.init();
  } on Exception catch (e, st) {
    log.e('Push notification init failed', error: e, stackTrace: st);
  }
}
