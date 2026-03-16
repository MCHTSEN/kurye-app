import 'package:bursamotokurye/core/environment/app_environment.dart';
import 'package:bursamotokurye/core/environment/backend_provider.dart';
import 'package:bursamotokurye/core/environment/credit_access_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFlavor', () {
    test('fromValue parses known flavors', () {
      expect(AppFlavor.fromValue('dev'), AppFlavor.dev);
      expect(AppFlavor.fromValue('staging'), AppFlavor.staging);
      expect(AppFlavor.fromValue('prod'), AppFlavor.prod);
    });

    test('fromValue defaults to dev for unknown values', () {
      expect(AppFlavor.fromValue('unknown'), AppFlavor.dev);
      expect(AppFlavor.fromValue(''), AppFlavor.dev);
    });

    test('fromValue is case insensitive', () {
      expect(AppFlavor.fromValue('DEV'), AppFlavor.dev);
      expect(AppFlavor.fromValue('Staging'), AppFlavor.staging);
    });
  });

  group('BackendProvider', () {
    test('fromValue parses known providers', () {
      expect(BackendProvider.fromValue('mock'), BackendProvider.mock);
      expect(BackendProvider.fromValue('custom'), BackendProvider.custom);
      expect(BackendProvider.fromValue('supabase'), BackendProvider.supabase);
      expect(BackendProvider.fromValue('firebase'), BackendProvider.firebase);
    });

    test('fromValue defaults to mock for unknown values', () {
      expect(BackendProvider.fromValue('unknown'), BackendProvider.mock);
    });
  });

  group('CreditAccessProvider', () {
    test('fromValue parses known providers', () {
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

    test('fromValue defaults to navigationSignal for unknown values', () {
      expect(
        CreditAccessProvider.fromValue('unknown'),
        CreditAccessProvider.navigationSignal,
      );
    });
  });

  group('AppEnvironment', () {
    test('can be constructed with all fields', () {
      const env = AppEnvironment(
        flavor: AppFlavor.prod,
        backendProvider: BackendProvider.mock,
        creditAccessProvider: CreditAccessProvider.navigationSignal,
        customApiBaseUrl: 'https://api.test.com',
        supabaseUrl: '',
        supabaseAnonKey: '',
        mixpanelToken: 'mp-token',
        analyticsEnabled: true,
        sentryDsn: '',
        operasyonReportsPassword: 'rapor123',
      );

      expect(env.flavor, AppFlavor.prod);
      expect(env.backendProvider, BackendProvider.mock);
      expect(env.analyticsEnabled, isTrue);
      expect(env.operasyonReportsPassword, 'rapor123');
    });
  });
}
