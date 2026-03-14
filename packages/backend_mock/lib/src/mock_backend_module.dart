import 'package:backend_core/backend_core.dart';

import 'mock_auth_gateway.dart';
import 'mock_credit_access_service.dart';
import 'mock_token_refresh_service.dart';

class MockBackendModule extends BackendModule {
  static final _log = AppLogger('MockBackendModule');

  @override
  Future<void> initialize() async {
    _log.i('Mock backend initialized');
  }

  @override
  AuthGateway createAuthGateway() {
    return MockAuthGateway();
  }

  @override
  CreditAccessService? createCreditAccessService() {
    return const MockCreditAccessService();
  }

  @override
  TokenRefreshService createTokenRefreshService() {
    return const MockTokenRefreshService();
  }
}
