import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/auth/auth_providers.dart';
import '../../../product/navigation/navigation_providers.dart';
import '../../../product/onboarding/onboarding_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../custom_route.dart';

class AppAccessGuard extends AutoRouteGuard {
  AppAccessGuard(this._ref);

  final Ref _ref;

  static final _log = AppLogger('AppAccessGuard', tag: LogTag.router);

  /// Rol için varsayılan ana sayfa.
  static String homePathForRole(UserRole? role) {
    switch (role) {
      case UserRole.musteriPersonel:
        return CustomRoute.musteriSiparis.path;
      case UserRole.operasyon:
        return CustomRoute.operasyonShell.path;
      case UserRole.kurye:
        return CustomRoute.kuryeAna.path;
      case null:
        return CustomRoute.roleSelection.path;
    }
  }

  static bool _isRoleRestrictedRoute(String path) =>
      path.startsWith('/musteri') ||
      path.startsWith('/operasyon') ||
      path.startsWith('/kurye');

  static bool _canAccessRoute(UserRole role, String path) {
    if (path.startsWith('/musteri')) return role == UserRole.musteriPersonel;
    if (path.startsWith('/operasyon')) return role == UserRole.operasyon;
    if (path.startsWith('/kurye')) return role == UserRole.kurye;
    return true;
  }

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final navState = _ref.read(appNavigationStateProvider);
    final onboardingCompleted = await _ref
        .read(onboardingRepositoryProvider)
        .isCompleted();
    final session = await _ref.read(authRepositoryProvider).currentSession();
    final isAuthenticated = session != null && !navState.requiresLogin;

    final targetPath = resolver.route.path;
    _log.d(
      'guard: target=$targetPath auth=$isAuthenticated '
      'onboarded=$onboardingCompleted',
    );

    // 1. Onboarding
    if (!onboardingCompleted && targetPath != CustomRoute.onboarding.path) {
      _redirect(router, resolver, CustomRoute.onboarding.path, 'onboarding');
      return;
    }

    // 2. Auth
    if (onboardingCompleted &&
        !isAuthenticated &&
        targetPath != CustomRoute.auth.path) {
      _redirect(router, resolver, CustomRoute.auth.path, 'auth');
      return;
    }

    // 3. Authenticated kullanıcı
    if (isAuthenticated) {
      // Profili doğrudan repository'den çek (stream bekleme yok)
      final role = await _getUserRole(session.user.id);
      final homePath = homePathForRole(role);

      _log.d('guard: role=${role?.value ?? "none"} home=$homePath');

      // 3a. Rol kısıtlı rotalara erişim kontrolü
      if (_isRoleRestrictedRoute(targetPath)) {
        if (role == null || !_canAccessRoute(role, targetPath)) {
          _redirect(router, resolver, homePath, 'role-restricted');
          return;
        }
      }

      // 3b. Profil yoksa → rol seçim
      if (role == null && targetPath != CustomRoute.roleSelection.path) {
        _redirect(router, resolver, CustomRoute.roleSelection.path, 'no-role');
        return;
      }

      // 3c. Auth/splash/root/home → doğru ana sayfaya
      if (targetPath == CustomRoute.root.path ||
          targetPath == CustomRoute.splash.path ||
          targetPath == CustomRoute.auth.path ||
          targetPath == CustomRoute.onboarding.path ||
          targetPath == CustomRoute.home.path) {
        _redirect(router, resolver, homePath, 'to-home');
        return;
      }

      // 3d. Rolü var ama hâlâ rol seçimde → ana sayfaya
      if (role != null && targetPath == CustomRoute.roleSelection.path) {
        _redirect(router, resolver, homePath, 'has-role');
        return;
      }
    }

    _log.d('guard: allowed $targetPath');
    resolver.next();
  }

  Future<UserRole?> _getUserRole(String userId) async {
    try {
      final repo = _ref.read(userProfileRepositoryProvider);
      final profile = await repo.getProfile(userId);
      return profile?.role;
    } on Object catch (e) {
      _log.e('Failed to get user role', error: e);
      return null;
    }
  }

  void _redirect(
    StackRouter router,
    NavigationResolver resolver,
    String path,
    String reason,
  ) {
    _log.i('guard: redirect to $path ($reason)');
    router.replacePath(path);
    resolver.next(false);
  }
}
