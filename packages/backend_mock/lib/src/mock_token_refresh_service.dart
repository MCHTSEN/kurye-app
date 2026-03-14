import 'package:backend_core/backend_core.dart';

class MockTokenRefreshService implements TokenRefreshService {
  const MockTokenRefreshService();

  @override
  Future<bool> tryRefreshToken() async => false;
}
