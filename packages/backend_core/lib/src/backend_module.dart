import 'auth_gateway.dart';
import 'credit_access_service.dart';
import 'kurye_repository.dart';
import 'musteri_personel_repository.dart';
import 'musteri_repository.dart';
import 'noop_payment_service.dart';
import 'payment_service.dart';
import 'role_request_repository.dart';
import 'siparis_log_repository.dart';
import 'siparis_repository.dart';
import 'token_refresh_service.dart';
import 'ugrama_repository.dart';
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

  /// Master data repositories — sadece destekleyen backend'ler implement eder.
  MusteriRepository? createMusteriRepository() => null;
  UgramaRepository? createUgramaRepository() => null;
  MusteriPersonelRepository? createMusteriPersonelRepository() => null;
  KuryeRepository? createKuryeRepository() => null;
  SiparisRepository? createSiparisRepository() => null;
  SiparisLogRepository? createSiparisLogRepository() => null;
}
