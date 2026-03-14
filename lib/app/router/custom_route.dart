enum CustomRoute {
  root('/'),
  splash('/splash'),
  onboarding('/onboarding'),
  auth('/auth'),
  home('/home'),
  exampleFeed('/example-feed'),
  profile('/profile'),
  buyCredit('/buy-credit'),
  notFound('*');

  const CustomRoute(this.path);

  final String path;

  String get routeName {
    switch (this) {
      case CustomRoute.root:
        return 'RootRoute';
      case CustomRoute.splash:
        return 'SplashRoute';
      case CustomRoute.onboarding:
        return 'OnboardingRoute';
      case CustomRoute.auth:
        return 'AuthRoute';
      case CustomRoute.home:
        return 'HomeRoute';
      case CustomRoute.exampleFeed:
        return 'ExampleFeedRoute';
      case CustomRoute.profile:
        return 'ProfileRoute';
      case CustomRoute.buyCredit:
        return 'BuyCreditRoute';
      case CustomRoute.notFound:
        return 'NotFoundRoute';
    }
  }
}
