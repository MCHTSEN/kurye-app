import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/router/app_router.dart';
import '../../../app/router/guards/app_access_guard.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/navigation/navigation_providers.dart';
import '../../../product/notifications/notification_providers.dart';
import '../../../product/role_request/role_request_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<void> build() async {}

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password),
    );
    if (!ref.mounted) return;
    state = nextState;
    if (!nextState.hasError) await _navigateAfterAuth();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .register(
            email: email,
            password: password,
            name: name,
          ),
    );
    if (!ref.mounted) return;
    state = nextState;
    if (!nextState.hasError) await _navigateAfterAuth();
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInAnonymously(),
    );
    if (!ref.mounted) return;
    state = nextState;
    if (!nextState.hasError) await _navigateAfterAuth();
  }

  Future<void> signInWithGoogle({required String idToken}) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(idToken: idToken),
    );
    if (!ref.mounted) return;
    state = nextState;
    if (!nextState.hasError) await _navigateAfterAuth();
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    // Logout öncesi cihaz token'ını temizle ki bu kullanıcı bir daha o cihazda
    // push almasın (cihaz başkasına teslim edilirse de eski push'u almasın).
    final push = ref.read(pushNotificationServiceProvider);
    if (push != null) {
      await push.shutdown();
    }
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
    if (!ref.mounted) return;
    state = nextState;
    ref.invalidate(currentUserProfileProvider);
    ref.read(appNavigationStateProvider).requireLogin();
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).deleteAccount(),
    );
    if (!ref.mounted) return;
    state = nextState;
    if (nextState.hasError) return;
    ref.invalidate(currentUserProfileProvider);
    ref.read(appNavigationStateProvider).requireLogin();
  }

  Future<void> updatePassword({required String newPassword}) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .updatePassword(newPassword: newPassword),
    );
    if (!ref.mounted) return;
    state = nextState;
  }

  Future<void> _navigateAfterAuth() async {
    ref.invalidate(currentUserProfileProvider);
    ref.read(appNavigationStateProvider).clearAll();

    // Profili doğrudan repository'den çek
    final session = await ref.read(authRepositoryProvider).currentSession();
    if (session == null || !ref.mounted) return;

    AppUserProfile? profile;
    try {
      final repo = ref.read(userProfileRepositoryProvider);
      profile = await repo.getProfile(session.user.id);
    } on Object {
      // profil yoksa null → role selection
    }

    if (!ref.mounted) return;

    var hasPendingRoleRequest = false;
    if (profile == null) {
      try {
        final roleRequestRepo = ref.read(roleRequestRepositoryProvider);
        hasPendingRoleRequest =
            await roleRequestRepo.getMyPendingRequest(session.user.id) != null;
      } on Object {
        hasPendingRoleRequest = false;
      }
    }

    final targetPath = AppAccessGuard.landingPathForUserState(
      profile: profile,
      hasPendingRoleRequest: hasPendingRoleRequest,
    );
    await ref.read(appRouterProvider).replacePath(targetPath);
  }
}
