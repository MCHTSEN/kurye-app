import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_auth_gateway.dart';
import 'supabase_role_request_repository.dart';
import 'supabase_token_refresh_service.dart';
import 'supabase_user_profile_repository.dart';

class SupabaseBackendModule extends BackendModule {
  SupabaseBackendModule({
    required this.url,
    required this.anonKey,
  });

  final String url;
  final String anonKey;

  static final _log = AppLogger('SupabaseBackendModule');

  @override
  Future<void> initialize() async {
    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Supabase backend selected but url or anonKey is missing.',
      );
    }

    _log.i('Initializing Supabase...');
    await Supabase.initialize(url: url, anonKey: anonKey);
    _log.i('Supabase initialized successfully');
  }

  @override
  AuthGateway createAuthGateway() {
    return SupabaseAuthGateway(client: Supabase.instance.client);
  }

  @override
  TokenRefreshService createTokenRefreshService() {
    return SupabaseTokenRefreshService(client: Supabase.instance.client);
  }

  @override
  CreditAccessService? createCreditAccessService() {
    return null;
  }

  @override
  UserProfileRepository createUserProfileRepository() {
    return SupabaseUserProfileRepository(client: Supabase.instance.client);
  }

  @override
  RoleRequestRepository createRoleRequestRepository() {
    return SupabaseRoleRequestRepository(client: Supabase.instance.client);
  }
}
