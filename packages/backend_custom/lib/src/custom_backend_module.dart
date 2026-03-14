import 'package:backend_core/backend_core.dart';

import 'custom_api_auth_gateway.dart';
import 'noop_token_refresh_service.dart';

class CustomBackendModule extends BackendModule {
  CustomBackendModule({required this.baseUrl});

  final String baseUrl;

  static final _log = AppLogger('CustomBackendModule');

  @override
  Future<void> initialize() async {
    _log.i('Custom API backend initialized (baseUrl: $baseUrl)');
  }

  @override
  AuthGateway createAuthGateway() {
    return CustomApiAuthGateway(baseUrl: baseUrl);
  }

  @override
  TokenRefreshService createTokenRefreshService() {
    return const NoopTokenRefreshService();
  }

  @override
  CreditAccessService? createCreditAccessService() {
    return null;
  }
}
