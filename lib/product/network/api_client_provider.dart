import 'package:backend_core/backend_core.dart';
import 'package:backend_mock/backend_mock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/environment/backend_provider.dart';
import '../../core/network/dio_api_client.dart';
import '../auth/auth_providers.dart';
import '../credit/credit_providers.dart';
import '../environment/environment_provider.dart';
import '../navigation/navigation_providers.dart';

part 'api_client_provider.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final tokenRefreshService = ref.watch(tokenRefreshServiceProvider);
  final navigationState = ref.watch(appNavigationStateProvider);
  final useNetworkCreditSignal = ref.watch(
    isNetworkCreditSignalEnabledProvider,
  );

  if (environment.backendProvider == BackendProvider.mock) {
    return MockApiClient();
  }

  return DioApiClient(
    baseUrl: environment.customApiBaseUrl,
    tryRefreshToken: tokenRefreshService.tryRefreshToken,
    onUnauthorized: navigationState.requireLogin,
    onInsufficientCredit: useNetworkCreditSignal
        ? navigationState.requireCreditPurchase
        : null,
  );
}
