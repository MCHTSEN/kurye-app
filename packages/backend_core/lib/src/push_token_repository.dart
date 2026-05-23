/// FCM device token persistence — backend bağımsız kontrat.
///
/// Sadece destekleyen backend'ler (Supabase) implement eder. Backend'in DB'sinde
/// kullanıcı başına çoklu cihaz token'ı tutulur; yeni token gelince upsert,
/// logout/uninstall'da remove.
abstract class PushTokenRepository {
  /// Token'ı veritabanına ekler ya da varsa `last_seen_at`/`updated_at` günceller.
  /// FCM aynı cihaz için yeni token üretebilir — `fcm_token` UNIQUE üzerinden
  /// conflict ile last_seen_at güncellenmesi yeterli.
  Future<void> upsert({
    required String token,
    required String platform,
    String? appVersion,
  });

  /// Token kaydını siler — logout sonrası veya invalid token tespitinde.
  Future<void> remove(String token);
}
