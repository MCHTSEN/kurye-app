import 'dart:async';

import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/navigation/app_access_snapshot.dart';
import '../../../product/navigation/navigation_providers.dart';
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

  static String landingPathForUserState({
    required AppUserProfile? profile,
    required bool hasPendingRoleRequest,
  }) {
    final role = profile?.role;
    if (role != null) {
      if (role == UserRole.musteriPersonel && profile?.isActive == false) {
        return CustomRoute.home.path;
      }

      if (role == UserRole.musteriPersonel && profile?.musteriId == null) {
        return CustomRoute.home.path;
      }

      return homePathForRole(role);
    }

    if (hasPendingRoleRequest) {
      return CustomRoute.home.path;
    }

    return CustomRoute.roleSelection.path;
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
    final guardTimer = Stopwatch()..start();
    final navState = _ref.read(appNavigationStateProvider);
    final snapshot = await _ref.read(appAccessSnapshotProvider.future);
    guardTimer.stop();

    final session = snapshot.session;
    final onboardingCompleted = snapshot.onboardingCompleted;
    final isAuthenticated = session != null && !navState.requiresLogin;

    final targetPath = resolver.route.path;
    _log.d(
      'guard: target=$targetPath auth=$isAuthenticated '
      'onboarded=$onboardingCompleted '
      '${snapshot.timings.toLogFields()} '
      'guard_total=${guardTimer.elapsed.inMilliseconds}ms',
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
      final profile = snapshot.profile;
      final role = profile?.role;
      final hasPendingRoleRequest = snapshot.hasPendingRoleRequest;
      final homePath = landingPathForUserState(
        profile: profile,
        hasPendingRoleRequest: hasPendingRoleRequest,
      );

      _log.d('guard: role=${role?.value ?? "none"} home=$homePath');

      // 3a. Rol kısıtlı rotalara erişim kontrolü
      if (_isRoleRestrictedRoute(targetPath)) {
        final hasCompleteMusteriAccess =
            role != UserRole.musteriPersonel || profile?.musteriId != null;

        if (role == null ||
            !_canAccessRoute(role, targetPath) ||
            !hasCompleteMusteriAccess) {
          _redirect(router, resolver, homePath, 'role-restricted');
          return;
        }
      }

      // 3b. Profil yoksa:
      // - pending talep varsa uygulama içi bekleme ekranında kal
      // - talep yoksa rol seçime dön
      if (role == null &&
          !hasPendingRoleRequest &&
          targetPath != CustomRoute.roleSelection.path) {
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

  void _redirect(
    StackRouter router,
    NavigationResolver resolver,
    String path,
    String reason,
  ) {
    if (resolver.route.path == path) {
      _log.d('guard: skip redirect to same path $path ($reason)');
      resolver.next();
      return;
    }

    _log.i('guard: redirect to $path ($reason)');
    unawaited(router.replacePath(path));
    resolver.next(false);
  }
}
