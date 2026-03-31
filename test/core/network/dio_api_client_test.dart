import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/core/network/dio_api_client.dart';

void main() {
  group('DioApiClient', () {
    test('can be constructed with required parameters', () {
      final client = DioApiClient(
        baseUrl: 'https://api.example.com',
        tryRefreshToken: () async => false,
        onUnauthorized: () {},
        onInsufficientCredit: null,
      );

      expect(client, isNotNull);
    });

    test('can be constructed with onInsufficientCredit callback', () {
      var creditCallbackInvoked = false;

      final client = DioApiClient(
        baseUrl: 'https://api.example.com',
        tryRefreshToken: () async => false,
        onUnauthorized: () {},
        onInsufficientCredit: () {
          creditCallbackInvoked = true;
        },
      );

      expect(client, isNotNull);
      expect(creditCallbackInvoked, isFalse);
    });
  });
}
