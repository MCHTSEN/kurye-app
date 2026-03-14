import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserProfileRepository implements UserProfileRepository {
  SupabaseUserProfileRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  static final _log = AppLogger(
    'SupabaseUserProfileRepository',
    tag: LogTag.auth,
  );

  @override
  Future<AppUserProfile?> getProfile(String userId) async {
    _log.d('getProfile called for $userId');

    final response = await _client
        .from('app_users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      _log.d('No profile found for $userId');
      return null;
    }

    final profile = AppUserProfile.fromJson(response);
    _log.d('Profile found: role=${profile.role.value}');
    return profile;
  }

  @override
  Future<AppUserProfile> createProfile(AppUserProfile profile) async {
    _log.i('createProfile called for ${profile.id}');

    await _client.from('app_users').insert(profile.toJson());

    _log.i('Profile created: role=${profile.role.value}');
    return profile;
  }
}
