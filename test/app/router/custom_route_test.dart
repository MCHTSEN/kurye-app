import 'package:bursamotokurye/app/router/custom_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomRoute', () {
    test('paths are stable and explicit', () {
      expect(CustomRoute.root.path, '/');
      expect(CustomRoute.splash.path, '/splash');
      expect(CustomRoute.onboarding.path, '/onboarding');
      expect(CustomRoute.auth.path, '/auth');
      expect(CustomRoute.home.path, '/home');
      expect(CustomRoute.exampleFeed.path, '/example-feed');
      expect(CustomRoute.profile.path, '/profile');
      expect(CustomRoute.buyCredit.path, '/buy-credit');

      // Müşteri rotaları
      expect(CustomRoute.musteriSiparis.path, '/musteri/siparis');
      expect(CustomRoute.musteriGecmis.path, '/musteri/gecmis');

      // Operasyon rotaları
      expect(CustomRoute.operasyonDashboard.path, '/operasyon/dashboard');
      expect(CustomRoute.operasyonEkran.path, '/operasyon/ekran');
      expect(CustomRoute.musteriKayit.path, '/operasyon/musteri-kayit');
      expect(
        CustomRoute.musteriPersonelKayit.path,
        '/operasyon/personel-kayit',
      );
      expect(CustomRoute.operasyonGecmis.path, '/operasyon/gecmis');
      expect(CustomRoute.ugramaYonetim.path, '/operasyon/ugrama');

      // Kurye rotaları
      expect(CustomRoute.kuryeAna.path, '/kurye/ana');

      expect(CustomRoute.notFound.path, '*');
    });

    test('route names are enum-driven and stable', () {
      expect(CustomRoute.root.routeName, 'RootRoute');
      expect(CustomRoute.splash.routeName, 'SplashRoute');
      expect(CustomRoute.onboarding.routeName, 'OnboardingRoute');
      expect(CustomRoute.auth.routeName, 'AuthRoute');
      expect(CustomRoute.home.routeName, 'HomeRoute');
      expect(CustomRoute.exampleFeed.routeName, 'ExampleFeedRoute');
      expect(CustomRoute.profile.routeName, 'ProfileRoute');
      expect(CustomRoute.buyCredit.routeName, 'BuyCreditRoute');

      // Müşteri
      expect(CustomRoute.musteriSiparis.routeName, 'MusteriSiparisRoute');
      expect(CustomRoute.musteriGecmis.routeName, 'MusteriGecmisRoute');

      // Operasyon
      expect(
        CustomRoute.operasyonDashboard.routeName,
        'OperasyonDashboardRoute',
      );
      expect(CustomRoute.operasyonEkran.routeName, 'OperasyonEkranRoute');
      expect(CustomRoute.musteriKayit.routeName, 'MusteriKayitRoute');
      expect(
        CustomRoute.musteriPersonelKayit.routeName,
        'MusteriPersonelKayitRoute',
      );
      expect(CustomRoute.operasyonGecmis.routeName, 'OperasyonGecmisRoute');
      expect(CustomRoute.ugramaYonetim.routeName, 'UgramaYonetimRoute');

      // Kurye
      expect(CustomRoute.kuryeAna.routeName, 'KuryeAnaRoute');

      expect(CustomRoute.notFound.routeName, 'NotFoundRoute');
    });

    test('all enum values have a unique path', () {
      final paths = CustomRoute.values.map((r) => r.path).toList();
      expect(paths.toSet().length, paths.length);
    });

    test('all enum values have a unique routeName', () {
      final names = CustomRoute.values.map((r) => r.routeName).toList();
      expect(names.toSet().length, names.length);
    });
  });
}
