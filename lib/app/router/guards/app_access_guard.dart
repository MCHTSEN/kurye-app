import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/auth/auth_providers.dart';
import '../../../product/credit/credit_providers.dart';
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
        return CustomRoute.operasyonDashboard.path;
      case UserRole.kurye:
        return CustomRoute.kuryeAna.path;
      case null:
        return CustomRoute.home.path;
    }
  }

  /// Bir rotanın belirli bir role ait olup olmadığını kontrol eder.
  static bool _isMusteriRoute(String path) =>
      path.startsWith('/musteri');

  static bool _isOperasyonRoute(String path) =>
      path.startsWith('/operasyon');

  static bool _isKuryeRoute(String path) =>
      path.startsWith('/kurye');

  /// Rotanın rol kısıtlaması var mı kontrol eder.
  static bool _isRoleRestrictedRoute(String path) =>
      _isMusteriRoute(path) ||
      _isOperasyonRoute(path) ||
      _isKuryeRoute(path);

  /// Kullanıcının bu rotaya erişim hakkı var mı?
  static bool _canAccessRoute(UserRole role, String path) {
    if (_isMusteriRoute(path)) return role == UserRole.musteriPersonel;
    if (_isOperasyonRoute(path)) return role == UserRole.operasyon;
    if (_isKuryeRoute(path)) return role == UserRole.kurye;
    return true; // Kısıtsız rotalar
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
      'onNavigation: target=$targetPath, authenticated=$isAuthenticated, '
      'onboarded=$onboardingCompleted',
    );

    // 1. Onboarding kontrolü
    if (!onboardingCompleted && targetPath != CustomRoute.onboarding.path) {
      _log.i('Redirecting to onboarding (not completed)');
      await router.replacePath(CustomRoute.onboarding.path);
      resolver.next(false);
      return;
    }

    // 2. Auth kontrolü
    if (onboardingCompleted &&
        !isAuthenticated &&
        targetPath != CustomRoute.auth.path) {
      _log.i('Redirecting to auth (not authenticated)');
      await router.replacePath(CustomRoute.auth.path);
      resolver.next(false);
      return;
    }

    // 3. Credit kontrolü
    final requiresCreditPurchase = await _requiresCreditPurchase(
      isAuthenticated: isAuthenticated,
    );
    if (isAuthenticated &&
        requiresCreditPurchase &&
        targetPath != CustomRoute.buyCredit.path) {
      _log.i('Redirecting to buy credit (insufficient credit)');
      await router.replacePath(CustomRoute.buyCredit.path);
      resolver.next(false);
      return;
    }

    if (!isAuthenticated && targetPath == CustomRoute.buyCredit.path) {
      _log.i('Redirecting to auth (buy credit requires auth)');
      await router.replacePath(CustomRoute.auth.path);
      resolver.next(false);
      return;
    }

    // 4. Authenticated → rol bazlı yönlendirme
    if (isAuthenticated) {
      // Profil bilgisini al
      AppUserProfile? profile;
      try {
        profile = await _ref.read(currentUserProfileProvider.future);
      } on Object catch (e) {
        _log.e('Failed to load user profile', error: e);
      }

      final role = profile?.role;

      // Rol kısıtlı rotalara erişim kontrolü
      if (_isRoleRestrictedRoute(targetPath)) {
        if (role == null || !_canAccessRoute(role, targetPath)) {
          final fallback = homePathForRole(role);
          _log.i(
            'Role ${role?.value ?? "none"} cannot access $targetPath, '
            'redirecting to $fallback',
          );
          await router.replacePath(fallback);
          resolver.next(false);
          return;
        }
      }

      // Profil yoksa → rol seçim ekranına yönlendir
      if (role == null &&
          targetPath != CustomRoute.roleSelection.path &&
          targetPath != CustomRoute.home.path) {
        _log.i('No profile, redirecting to role selection');
        await router.replacePath(CustomRoute.roleSelection.path);
        resolver.next(false);
        return;
      }

      // Splash/root/auth/onboarding → rol bazlı ana sayfaya yönlendir
      if (targetPath == CustomRoute.root.path ||
          targetPath == CustomRoute.splash.path ||
          targetPath == CustomRoute.auth.path ||
          targetPath == CustomRoute.onboarding.path) {
        if (role == null) {
          _log.i('No profile, redirecting to role selection');
          await router.replacePath(CustomRoute.roleSelection.path);
        } else {
          final homePath = homePathForRole(role);
          _log.i('Redirecting authenticated user to $homePath');
          await router.replacePath(homePath);
        }
        resolver.next(false);
        return;
      }

      // /home veya /role-selection'a gelince: rolü varsa kendi sayfasına
      if (role != null &&
          (targetPath == CustomRoute.home.path ||
              targetPath == CustomRoute.roleSelection.path)) {
        final homePath = homePathForRole(role);
        _log.i('Redirecting $role user to $homePath');
        await router.replacePath(homePath);
        resolver.next(false);
        return;
      }
    }

    _log.d('Navigation allowed to $targetPath');
    resolver.next();
  }

  Future<bool> _requiresCreditPurchase({required bool isAuthenticated}) async {
    if (!isAuthenticated) {
      return false;
    }

    try {
      final hasSufficientCredit = await _ref
          .read(creditAccessServiceProvider)
          .hasSufficientCredit();
      return !hasSufficientCredit;
    } on Object {
      return _ref.read(appNavigationStateProvider).requiresCreditPurchase;
    }
  }
}
