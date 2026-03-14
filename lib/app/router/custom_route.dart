enum CustomRoute {
  root('/'),
  splash('/splash'),
  onboarding('/onboarding'),
  auth('/auth'),
  home('/home'),
  exampleFeed('/example-feed'),
  profile('/profile'),
  buyCredit('/buy-credit'),

  // Rol seçimi (register sonrası)
  roleSelection('/role-selection'),

  // Müşteri rotaları
  musteriSiparis('/musteri/siparis'),
  musteriGecmis('/musteri/gecmis'),

  // Operasyon rotaları
  operasyonDashboard('/operasyon/dashboard'),
  operasyonEkran('/operasyon/ekran'),
  musteriKayit('/operasyon/musteri-kayit'),
  musteriPersonelKayit('/operasyon/personel-kayit'),
  operasyonGecmis('/operasyon/gecmis'),
  ugramaYonetim('/operasyon/ugrama'),

  // Kurye rotaları
  kuryeAna('/kurye/ana'),

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
      case CustomRoute.roleSelection:
        return 'RoleSelectionRoute';
      case CustomRoute.musteriSiparis:
        return 'MusteriSiparisRoute';
      case CustomRoute.musteriGecmis:
        return 'MusteriGecmisRoute';
      case CustomRoute.operasyonDashboard:
        return 'OperasyonDashboardRoute';
      case CustomRoute.operasyonEkran:
        return 'OperasyonEkranRoute';
      case CustomRoute.musteriKayit:
        return 'MusteriKayitRoute';
      case CustomRoute.musteriPersonelKayit:
        return 'MusteriPersonelKayitRoute';
      case CustomRoute.operasyonGecmis:
        return 'OperasyonGecmisRoute';
      case CustomRoute.ugramaYonetim:
        return 'UgramaYonetimRoute';
      case CustomRoute.kuryeAna:
        return 'KuryeAnaRoute';
      case CustomRoute.notFound:
        return 'NotFoundRoute';
    }
  }
}
