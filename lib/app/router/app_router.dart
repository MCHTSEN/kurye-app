import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feature/auth/presentation/auth_page.dart';
import '../../feature/buy_credit/presentation/buy_credit_page.dart';
import '../../feature/example_feed/presentation/example_feed_page.dart';
import '../../feature/home/presentation/home_page.dart';
import '../../feature/not_found/presentation/not_found_page.dart';
import '../../feature/onboarding/presentation/onboarding_page.dart';
import '../../feature/profile/presentation/profile_page.dart';
import '../../feature/splash/presentation/splash_page.dart';
import 'custom_route.dart';
import 'guards/app_access_guard.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
RootStackRouter appRouter(Ref ref) {
  final guard = AppAccessGuard(ref);

  return RootStackRouter.build(
    guards: <AutoRouteGuard>[guard],
    routes: <AutoRoute>[
      NamedRouteDef(
        name: CustomRoute.root.routeName,
        path: CustomRoute.root.path,
        builder: (context, data) => const SplashPage(),
      ),
      NamedRouteDef(
        name: CustomRoute.splash.routeName,
        path: CustomRoute.splash.path,
        builder: (context, data) => const SplashPage(),
      ),
      NamedRouteDef(
        name: CustomRoute.onboarding.routeName,
        path: CustomRoute.onboarding.path,
        builder: (context, data) => const OnboardingPage(),
      ),
      NamedRouteDef(
        name: CustomRoute.auth.routeName,
        path: CustomRoute.auth.path,
        builder: (context, data) => const AuthPage(),
      ),
      NamedRouteDef(
        name: CustomRoute.home.routeName,
        path: CustomRoute.home.path,
        builder: (context, data) => const HomePage(),
      ),
      NamedRouteDef(
        name: CustomRoute.exampleFeed.routeName,
        path: CustomRoute.exampleFeed.path,
        builder: (context, data) => const ExampleFeedPage(),
      ),

      NamedRouteDef(
        name: CustomRoute.profile.routeName,
        path: CustomRoute.profile.path,
        builder: (context, data) => const ProfilePage(),
      ),
      NamedRouteDef(
        name: CustomRoute.buyCredit.routeName,
        path: CustomRoute.buyCredit.path,
        builder: (context, data) => const BuyCreditPage(),
      ),
      NamedRouteDef(
        name: CustomRoute.notFound.routeName,
        path: CustomRoute.notFound.path,
        builder: (context, data) => const NotFoundPage(),
      ),
    ],
  );
}
