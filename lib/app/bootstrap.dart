import 'package:backend_core/backend_core.dart';
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

  // Local notifications — bootstrap'te kanal + handler kurulumu.
  final notificationService = LocalNotificationService();
  try {
    await notificationService.init();
  } on Exception catch (e, st) {
    log.e('Notification init failed', error: e, stackTrace: st);
  }

  log.i('Backend initialized, starting app');

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(resolvedEnvironment),
        backendModuleProvider.overrideWithValue(module),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      observers: const [AppProviderObserver()],
      child: const KuryemApp(),
    ),
  );
}
