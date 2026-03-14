import 'auth_gateway.dart';
import 'credit_access_service.dart';
import 'noop_payment_service.dart';
import 'payment_service.dart';
import 'token_refresh_service.dart';

abstract class BackendModule {
  Future<void> initialize();

  AuthGateway createAuthGateway();

  TokenRefreshService createTokenRefreshService();

  CreditAccessService? createCreditAccessService();

  PaymentService createPaymentService() => const NoopPaymentService();
}
