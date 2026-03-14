import 'domain/app_user_profile.dart';

/// Login sonrası kullanıcı profil/rol sorgulama kontratı.
abstract class UserProfileRepository {
  /// Auth UID ile `app_users` tablosundan profil çeker.
  /// Kayıt yoksa `null` döner.
  Future<AppUserProfile?> getProfile(String userId);

  /// Profil oluşturma (ilk kayıtta).
  Future<AppUserProfile> createProfile(AppUserProfile profile);
}
