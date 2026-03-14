import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract final class SentryService {
  static final _log = AppLogger('SentryService');

  static bool get isInitialized => Sentry.isEnabled;

  static Future<void> initialize({
    required String dsn,
    required String environment,
  }) async {
    if (dsn.isEmpty) {
      _log.i('Sentry DSN is empty, skipping initialization');
      return;
    }

    await SentryFlutter.init(
      (options) {
        options
          ..dsn = dsn
          ..environment = environment
          ..tracesSampleRate = kDebugMode ? 1.0 : 0.2
          ..sendDefaultPii = false
          ..attachScreenshot = !kDebugMode
          ..debug = kDebugMode;
      },
    );

    _log.i('Sentry initialized for environment: $environment');
  }

  static Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    String? hint,
  }) async {
    if (!isInitialized) return;
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint != null ? Hint.withMap({'message': hint}) : null,
    );
  }

  static Future<void> captureMessage(
    String message, {
    SentryLevel? level,
  }) async {
    if (!isInitialized) return;
    await Sentry.captureMessage(message, level: level);
  }

  static Future<void> setUser({required String id, String? email}) async {
    if (!isInitialized) return;
    await Sentry.configureScope(
      (scope) => scope.setUser(SentryUser(id: id, email: email)),
    );
  }

  static Future<void> clearUser() async {
    if (!isInitialized) return;
    await Sentry.configureScope((scope) => scope.setUser(null));
  }

  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (!isInitialized) return;
    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          data: data,
          timestamp: DateTime.now(),
        ),
      ),
    );
  }
}
