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
    if (!nextState.hasError) await _navigateAfterAuth();
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
    final nextState = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
    if (!ref.mounted) return;
    state = nextState;
    ref.invalidate(currentUserProfileProvider);
    ref.read(appNavigationStateProvider).requireLogin();
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

    final targetPath = AppAccessGuard.homePathForRole(profile?.role);
    final router = ref.read(appRouterProvider);
    router.replacePath(targetPath);
  }
}
