import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../analytics/analytics_provider.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
BackendModule backendModule(Ref ref) {
  throw UnimplementedError(
    'backendModuleProvider must be overridden in bootstrap',
  );
}

@Riverpod(keepAlive: true)
AuthGateway authGateway(Ref ref) {
  return ref.watch(backendModuleProvider).createAuthGateway();
}

@Riverpod(keepAlive: true)
TokenRefreshService tokenRefreshService(Ref ref) {
  return ref.watch(backendModuleProvider).createTokenRefreshService();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    gateway: ref.watch(authGatewayProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
}

@Riverpod(keepAlive: true)
Stream<AuthSession?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@Riverpod(keepAlive: true)
Set<SocialLoginMethod> supportedSocialLogins(Ref ref) {
  return ref.watch(authGatewayProvider).supportedSocialLogins;
}
