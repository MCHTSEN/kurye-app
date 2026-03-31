import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/core/environment/credit_access_provider.dart';

void main() {
  group('CreditAccessProvider', () {
    test('fromValue resolves known values', () {
      expect(
        CreditAccessProvider.fromValue('navigationSignal'),
        CreditAccessProvider.navigationSignal,
      );
      expect(
        CreditAccessProvider.fromValue('backend'),
        CreditAccessProvider.backend,
      );
      expect(
        CreditAccessProvider.fromValue('revenueCat'),
        CreditAccessProvider.revenueCat,
      );
    });

    test('fromValue falls back to navigationSignal', () {
      expect(
        CreditAccessProvider.fromValue('unknown'),
        CreditAccessProvider.navigationSignal,
      );
    });
  });
}
