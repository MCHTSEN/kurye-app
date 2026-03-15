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
  musteriUgramaTalep('/musteri/ugrama-talep'),

  // Operasyon rotaları
  operasyonShell('/operasyon'),
  operasyonDashboard('/operasyon/dashboard'),
  operasyonEkran('/operasyon/ekran'),
  operasyonAyarlar('/operasyon/ayarlar'),
  musteriKayit('/operasyon/ayarlar/musteri-kayit'),
  musteriPersonelKayit('/operasyon/ayarlar/personel-kayit'),
  operasyonGecmis('/operasyon/ayarlar/gecmis'),
  ugramaYonetim('/operasyon/ugrama'),

  // Operasyon — Talep Yönetimi
  ugramaTalepYonetim('/operasyon/ayarlar/ugrama-talep'),

  // Operasyon — Kurye Yönetimi
  kuryeYonetim('/operasyon/ayarlar/kurye'),

  // Operasyon — Rol Onayları
  rolOnay('/operasyon/ayarlar/rol-onay'),

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
      case CustomRoute.musteriUgramaTalep:
        return 'MusteriUgramaTalepRoute';
      case CustomRoute.operasyonShell:
        return 'OperasyonShellRoute';
      case CustomRoute.operasyonDashboard:
        return 'OperasyonDashboardRoute';
      case CustomRoute.operasyonEkran:
        return 'OperasyonEkranRoute';
      case CustomRoute.operasyonAyarlar:
        return 'OperasyonAyarlarRoute';
      case CustomRoute.musteriKayit:
        return 'MusteriKayitRoute';
      case CustomRoute.musteriPersonelKayit:
        return 'MusteriPersonelKayitRoute';
      case CustomRoute.operasyonGecmis:
        return 'OperasyonGecmisRoute';
      case CustomRoute.ugramaYonetim:
        return 'UgramaYonetimRoute';
      case CustomRoute.ugramaTalepYonetim:
        return 'UgramaTalepYonetimRoute';
      case CustomRoute.kuryeYonetim:
        return 'KuryeYonetimRoute';
      case CustomRoute.rolOnay:
        return 'RolOnayRoute';
      case CustomRoute.kuryeAna:
        return 'KuryeAnaRoute';
      case CustomRoute.notFound:
        return 'NotFoundRoute';
    }
  }
}
