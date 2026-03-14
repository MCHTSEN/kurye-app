import 'dart:async';

import 'package:flutter/foundation.dart';

import '../monitoring/sentry_service.dart';

abstract final class AppErrorHandler {
  static void initialize() {
    FlutterError.onError = _handleFlutterError;
    PlatformDispatcher.instance.onError = _handlePlatformError;
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);

    unawaited(
      SentryService.captureException(
        details.exception,
        stackTrace: details.stack,
        hint: details.context?.toString(),
      ),
    );

    if (!kDebugMode) {
      Zone.current.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    }
  }

  static bool _handlePlatformError(Object error, StackTrace stack) {
    debugPrint('[AppError] $error');
    debugPrint('$stack');

    unawaited(SentryService.captureException(error, stackTrace: stack));

    return true;
  }
}
