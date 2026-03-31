import 'package:backend_mock/backend_mock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/core/environment/app_environment.dart';
import 'package:kuryem/core/environment/backend_provider.dart';
import 'package:kuryem/core/environment/credit_access_provider.dart';
import 'package:kuryem/product/auth/auth_providers.dart';
import 'package:kuryem/product/environment/environment_provider.dart';
import 'package:kuryem/product/network/api_client_provider.dart';

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
            operasyonReportsPassword: '',
          ),
        ),
        backendModuleProvider.overrideWithValue(MockBackendModule()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(apiClientProvider), isA<MockApiClient>());
  });
}
