import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTokenRefreshService implements TokenRefreshService {
  SupabaseTokenRefreshService({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  static final _log = AppLogger('SupabaseTokenRefresh', tag: LogTag.auth);

  @override
  Future<bool> tryRefreshToken() async {
    try {
      final response = await _client.auth.refreshSession();
      final success = response.session != null;
      _log.i('tryRefreshToken: ${success ? "success" : "no session"}');
      return success;
    } on Object catch (e) {
      _log.e('tryRefreshToken failed', error: e);
      return false;
    }
  }
}
