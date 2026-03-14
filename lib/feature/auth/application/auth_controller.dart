import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/router/app_router.dart';
import '../../../app/router/guards/app_access_guard.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/navigation/navigation_providers.dart';
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

    if (!nextState.hasError) {
      await _navigateAfterAuth();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(
        email: email,
        password: password,
        name: name,
      ),
    );
    if (!ref.mounted) return;
    state = nextState;

    if (!nextState.hasError) {
      await _navigateAfterAuth();
    }
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInAnonymously(),
    );
    if (!ref.mounted) return;
    state = nextState;

    if (!nextState.hasError) {
      await _navigateAfterAuth();
    }
  }

  Future<void> signInWithGoogle({required String idToken}) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(idToken: idToken),
    );
    if (!ref.mounted) return;
    state = nextState;

    if (!nextState.hasError) {
      await _navigateAfterAuth();
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
    if (!ref.mounted) return;
    state = nextState;

    ref.invalidate(currentUserProfileProvider);
    ref.read(appNavigationStateProvider).requireLogin();
  }

  /// Login başarılı → profil sorgula → doğru sayfaya yönlendir.
  Future<void> _navigateAfterAuth() async {
    ref.invalidate(currentUserProfileProvider);

    AppUserProfile? profile;
    try {
      profile = await ref.read(currentUserProfileProvider.future);
    } on Object {
      // profil yoksa null kalır → role selection'a gider
    }

    if (!ref.mounted) return;

    ref.read(appNavigationStateProvider).clearAll();

    final targetPath = AppAccessGuard.homePathForRole(profile?.role);
    final router = ref.read(appRouterProvider);
    await router.replacePath(targetPath);
  }
}
