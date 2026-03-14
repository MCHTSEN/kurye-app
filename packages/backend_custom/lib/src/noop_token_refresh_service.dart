import 'package:backend_core/backend_core.dart';

class NoopTokenRefreshService implements TokenRefreshService {
  const NoopTokenRefreshService();

  @override
  Future<bool> tryRefreshToken() async {
    return false;
  }
}
