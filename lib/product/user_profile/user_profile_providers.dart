import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'user_profile_providers.g.dart';

@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) {
  final repo = ref.watch(backendModuleProvider).createUserProfileRepository();
  if (repo == null) {
    throw StateError(
      'UserProfileRepository is not available for the current backend. '
      'This app requires Supabase backend.',
    );
  }
  return repo;
}

/// Login olan kullanıcının profili.
/// Auth state değiştiğinde yeniden sorgulanır.
@Riverpod(keepAlive: true)
class CurrentUserProfile extends _$CurrentUserProfile {
  @override
  Future<AppUserProfile?> build() async {
    final authSession = await ref.watch(authStateProvider.future);
    if (authSession == null) return null;

    final repo = ref.read(userProfileRepositoryProvider);
    return repo.getProfile(authSession.user.id);
  }

  /// Profili yeniden yükle (login sonrası çağrılır).
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
