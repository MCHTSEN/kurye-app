import 'package:logger/logger.dart';

import 'app_log_config.dart';

class AppLogger {
  AppLogger(this.name, {this.tag = LogTag.general});

  final String name;
  final LogTag tag;

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  void d(String message) {
    if (!logConfig.isEnabled(tag)) return;
    _logger.d('[$name] $message');
  }

  void i(String message) {
    if (!logConfig.isEnabled(tag)) return;
    _logger.i('[$name] $message');
  }

  void w(String message) {
    if (!logConfig.isEnabled(tag)) return;
    _logger.w('[$name] $message');
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    if (!logConfig.isEnabled(tag)) return;
    _logger.e('[$name] $message', error: error, stackTrace: stackTrace);
  }
}
