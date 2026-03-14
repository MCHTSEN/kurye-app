import 'package:backend_mock/backend_mock.dart';
import 'package:bursamotokurye/core/environment/app_environment.dart';
import 'package:bursamotokurye/core/environment/backend_provider.dart';
import 'package:bursamotokurye/core/environment/credit_access_provider.dart';
import 'package:bursamotokurye/product/auth/auth_providers.dart';
import 'package:bursamotokurye/product/environment/environment_provider.dart';
import 'package:bursamotokurye/product/network/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns MockApiClient when backend provider is mock', () {
    final container = ProviderContainer(
      overrides: [
        appEnvironmentProvider.overrideWithValue(
          const AppEnvironment(
            flavor: AppFlavor.dev,
            backendProvider: BackendProvider.mock,
            creditAccessProvider: CreditAccessProvider.navigationSignal,
            customApiBaseUrl: 'https://api.example.com',
            supabaseUrl: '',
            supabaseAnonKey: '',
            mixpanelToken: '',
            analyticsEnabled: false,
            sentryDsn: '',
          ),
        ),
        backendModuleProvider.overrideWithValue(MockBackendModule()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(apiClientProvider), isA<MockApiClient>());
  });
}
