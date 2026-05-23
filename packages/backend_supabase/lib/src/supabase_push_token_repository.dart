import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// `user_devices` tablosuna FCM token upsert eder.
///
/// RLS: kullanıcı sadece kendi token'ını yazabilir (auth.uid() = user_id).
/// `fcm_token` UNIQUE — aynı token ikinci kez gelirse `onConflict: 'fcm_token'`
/// ile `last_seen_at` + `user_id` (cihaz devredildiyse) güncellenir.
class SupabasePushTokenRepository implements PushTokenRepository {
  SupabasePushTokenRepository({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger('SupabasePushTokenRepo', tag: LogTag.notification);

  static const _table = 'user_devices';

  @override
  Future<void> upsert({
    required String token,
    required String platform,
    String? appVersion,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _log.w('upsert skipped — no authenticated user');
      return;
    }
    _log.i('upsert: user=$userId platform=$platform token=${_mask(token)}');
    await _client.from(_table).upsert({
      'user_id': userId,
      'fcm_token': token,
      'platform': platform,
      'app_version': appVersion,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'fcm_token');
    _log.d('upsert complete');
  }

  @override
  Future<void> remove(String token) async {
    _log.i('remove: token=${_mask(token)}');
    await _client.from(_table).delete().eq('fcm_token', token);
  }

  String _mask(String token) =>
      token.length > 10 ? '${token.substring(0, 6)}...${token.substring(token.length - 4)}' : '***';
}
