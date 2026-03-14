import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/auth/auth_providers.dart';
import '../../../product/credit/credit_providers.dart';
import '../../../product/navigation/navigation_providers.dart';
import '../../../product/onboarding/onboarding_providers.dart';
import '../custom_route.dart';

class AppAccessGuard extends AutoRouteGuard {
  AppAccessGuard(this._ref);

  final Ref _ref;

  static final _log = AppLogger('AppAccessGuard', tag: LogTag.router);

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
    final requiresCreditPurchase = await _requiresCreditPurchase(
      isAuthenticated: isAuthenticated,
    );

    final targetPath = resolver.route.path;
    _log.d(
      'onNavigation: target=$targetPath, authenticated=$isAuthenticated, '
      'onboarded=$onboardingCompleted, creditRequired=$requiresCreditPurchase',
    );

    if (!onboardingCompleted && targetPath != CustomRoute.onboarding.path) {
      _log.i('Redirecting to onboarding (not completed)');
      await router.replacePath(CustomRoute.onboarding.path);
      resolver.next(false);
      return;
    }

    if (onboardingCompleted &&
        !isAuthenticated &&
        targetPath != CustomRoute.auth.path) {
      _log.i('Redirecting to auth (not authenticated)');
      await router.replacePath(CustomRoute.auth.path);
      resolver.next(false);
      return;
    }

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

    if (isAuthenticated &&
        (targetPath == CustomRoute.root.path ||
            targetPath == CustomRoute.splash.path ||
            targetPath == CustomRoute.auth.path ||
            targetPath == CustomRoute.onboarding.path)) {
      _log.i('Redirecting authenticated user to home');
      await router.replacePath(CustomRoute.home.path);
      resolver.next(false);
      return;
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
