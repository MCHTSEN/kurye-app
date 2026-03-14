import 'package:backend_core/backend_core.dart';

/// Mock profil deposu — email'e göre rol atar.
///
/// Test kullanımı:
///   operasyon@test.com  → operasyon
///   kurye@test.com      → kurye
///   diğer               → musteri_personel
class MockUserProfileRepository implements UserProfileRepository {
  final Map<String, AppUserProfile> _store = {};

  /// Mock'ta email bazlı otomatik rol atama.
  UserRole _roleFromEmail(String? email) {
    if (email == null) return UserRole.musteriPersonel;
    if (email.startsWith('operasyon')) return UserRole.operasyon;
    if (email.startsWith('kurye')) return UserRole.kurye;
    return UserRole.musteriPersonel;
  }

  @override
  Future<AppUserProfile?> getProfile(String userId) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _store[userId];
  }

  @override
  Future<AppUserProfile> createProfile(AppUserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _store[profile.id] = profile;
    return profile;
  }

  /// Mock: Login sonrası profil yoksa otomatik oluştur.
  Future<AppUserProfile> getOrCreateProfile({
    required String userId,
    required String? email,
    String? displayName,
  }) async {
    var profile = await getProfile(userId);
    if (profile != null) return profile;

    profile = AppUserProfile(
      id: userId,
      role: _roleFromEmail(email),
      displayName: displayName ?? email ?? 'Anonim',
      musteriId: _roleFromEmail(email) == UserRole.musteriPersonel
          ? 'mock-musteri-1'
          : null,
    );
    return createProfile(profile);
  }
}
