import 'auth_gateway.dart';
import 'credit_access_service.dart';
import 'noop_payment_service.dart';
import 'payment_service.dart';
import 'token_refresh_service.dart';
import 'role_request_repository.dart';
import 'user_profile_repository.dart';

abstract class BackendModule {
  Future<void> initialize();

  AuthGateway createAuthGateway();

  TokenRefreshService createTokenRefreshService();

  CreditAccessService? createCreditAccessService();

  PaymentService createPaymentService() => const NoopPaymentService();

  /// Sadece destekleyen backend'ler implement eder.
  UserProfileRepository? createUserProfileRepository() => null;

  /// Rol talep sistemi. Sadece destekleyen backend'ler implement eder.
  RoleRequestRepository? createRoleRequestRepository() => null;
}
