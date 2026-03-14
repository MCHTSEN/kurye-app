import 'package:eipat/core/environment/app_environment.dart';
import 'package:eipat/core/environment/backend_provider.dart';
import 'package:eipat/core/environment/credit_access_provider.dart';
import 'package:eipat/product/credit/credit_providers.dart';
import 'package:eipat/product/environment/environment_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppEnvironment makeEnvironment(CreditAccessProvider creditAccessProvider) {
    return AppEnvironment(
      flavor: AppFlavor.dev,
      backendProvider: BackendProvider.mock,
      creditAccessProvider: creditAccessProvider,
      customApiBaseUrl: 'https://api.example.com',
      supabaseUrl: '',
      supabaseAnonKey: '',
      mixpanelToken: '',
      analyticsEnabled: false,
      sentryDsn: '',
    );
  }

  group('credit providers', () {
    test('network signal toggle follows environment', () {
      final container = ProviderContainer(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            makeEnvironment(CreditAccessProvider.navigationSignal),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isNetworkCreditSignalEnabledProvider), isTrue);
    });

    test('network signal is disabled for non-navigation providers', () {
      final container = ProviderContainer(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            makeEnvironment(CreditAccessProvider.revenueCat),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isNetworkCreditSignalEnabledProvider), isFalse);
    });

    test('revenueCat checker can be overridden', () async {
      final container = ProviderContainer(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            makeEnvironment(CreditAccessProvider.revenueCat),
          ),
          revenueCatCreditAvailabilityCheckerProvider.overrideWithValue(
            () async => false,
          ),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(creditAccessServiceProvider);
      expect(await service.hasSufficientCredit(), isFalse);
    });
  });
}
