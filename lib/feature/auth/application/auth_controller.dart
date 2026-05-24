import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/router/app_router.dart';
import '../../../app/router/guards/app_access_guard.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/navigation/app_access_snapshot.dart';
import '../../../product/navigation/navigation_providers.dart';
import '../../../product/notifications/notification_providers.dart';

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
    invalidateAppAccessCachesForProvider(ref);
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
    invalidateAppAccessCachesForProvider(ref);
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
    invalidateAppAccessCachesForProvider(ref);
    ref.read(appNavigationStateProvider).clearAll();

    final snapshot = await ref.read(appAccessSnapshotProvider.future);
    if (!ref.mounted) return;

    final targetPath = AppAccessGuard.landingPathForUserState(
      profile: snapshot.profile,
      hasPendingRoleRequest: snapshot.hasPendingRoleRequest,
    );
    await ref.read(appRouterProvider).replacePath(targetPath);
  }
}
