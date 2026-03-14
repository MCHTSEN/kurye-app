import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLogConfig', () {
    test('isEnabled returns true for enabled tags', () {
      final config = AppLogConfig();

      for (final tag in LogTag.values) {
        expect(config.isEnabled(tag), isTrue);
      }
    });

    test('master switch disables all tags', () {
      final config = AppLogConfig(enabled: false);

      for (final tag in LogTag.values) {
        expect(config.isEnabled(tag), isFalse);
      }
    });

    test('individual tags can be disabled', () {
      final config = AppLogConfig(auth: false, network: false);

      expect(config.isEnabled(LogTag.auth), isFalse);
      expect(config.isEnabled(LogTag.network), isFalse);
      expect(config.isEnabled(LogTag.router), isTrue);
      expect(config.isEnabled(LogTag.general), isTrue);
    });

    test('global logConfig can be replaced', () {
      final original = logConfig;

      logConfig = AppLogConfig(auth: false);
      expect(logConfig.isEnabled(LogTag.auth), isFalse);
      expect(logConfig.isEnabled(LogTag.network), isTrue);

      logConfig = original;
    });
  });
}
