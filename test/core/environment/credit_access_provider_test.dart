import 'package:eipat/core/environment/credit_access_provider.dart';
import 'package:flutter_test/flutter_test.dart';

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
