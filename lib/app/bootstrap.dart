import 'package:backend_core/backend_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/environment/app_environment.dart';
import '../core/error/app_error_handler.dart';
import '../core/error/app_error_widget.dart';
import '../core/monitoring/sentry_service.dart';
import '../product/auth/auth_providers.dart';
import '../product/environment/environment_provider.dart';
import '../product/riverpod/app_provider_observer.dart';
import 'app.dart';

Future<void> bootstrap({
  required BackendModule module,
  AppEnvironment? environment,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent Google Fonts from fetching over HTTP — avoids Objective-C FFI
  // crash on iOS Simulator and ensures offline-first font loading.
  GoogleFonts.config.allowRuntimeFetching = false;

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

  log.i('Backend initialized, starting app');

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(resolvedEnvironment),
        backendModuleProvider.overrideWithValue(module),
      ],
      observers: const [AppProviderObserver()],
      child: const BursamotoKuryeApp(),
    ),
  );
}
