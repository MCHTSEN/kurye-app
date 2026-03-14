import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      // Profil provider'ı yenile (rol bilgisi için)
      ref.invalidate(currentUserProfileProvider);
      ref.read(appNavigationStateProvider).clearAll();
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
      ref.invalidate(currentUserProfileProvider);
      ref.read(appNavigationStateProvider).clearAll();
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
      ref.invalidate(currentUserProfileProvider);
      ref.read(appNavigationStateProvider).clearAll();
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
      ref.invalidate(currentUserProfileProvider);
      ref.read(appNavigationStateProvider).clearAll();
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
}
