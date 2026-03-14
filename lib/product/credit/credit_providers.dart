import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/environment/credit_access_provider.dart';
import '../auth/auth_providers.dart';
import '../environment/environment_provider.dart';
import '../navigation/navigation_providers.dart';
import 'data/callback_credit_access_service.dart';
import 'data/navigation_signal_credit_access_service.dart';

part 'credit_providers.g.dart';

@Riverpod(keepAlive: true)
CreditAvailabilityChecker revenueCatCreditAvailabilityChecker(Ref ref) {
  return () async => true;
}

@Riverpod(keepAlive: true)
CreditAccessService creditAccessService(Ref ref) {
  final environment = ref.watch(appEnvironmentProvider);

  switch (environment.creditAccessProvider) {
    case CreditAccessProvider.navigationSignal:
      return NavigationSignalCreditAccessService(
        navigationState: ref.watch(appNavigationStateProvider),
      );
    case CreditAccessProvider.backend:
      final module = ref.watch(backendModuleProvider);
      final service = module.createCreditAccessService();
      if (service != null) return service;
      return NavigationSignalCreditAccessService(
        navigationState: ref.watch(appNavigationStateProvider),
      );
    case CreditAccessProvider.revenueCat:
      return CallbackCreditAccessService(
        checker: ref.watch(revenueCatCreditAvailabilityCheckerProvider),
      );
  }
}

@Riverpod(keepAlive: true)
bool isNetworkCreditSignalEnabled(Ref ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return environment.creditAccessProvider ==
      CreditAccessProvider.navigationSignal;
}
