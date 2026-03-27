import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:bursamotokurye/app/router/custom_route.dart';
import 'package:bursamotokurye/feature/musteri_siparis/presentation/musteri_shell_page.dart';
import 'package:bursamotokurye/product/navigation/role_nav_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mobile musteri shell switches tabs across child routes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = RootStackRouter.build(
      routes: [
        NamedRouteDef(
          name: 'MusteriShellRoute',
          path: '/musteri',
          builder: (context, data) => const MusteriShellPage(),
          children: [
            NamedRouteDef(
              name: CustomRoute.musteriSiparis.routeName,
              path: 'siparis',
              initial: true,
              builder: (context, data) => const Scaffold(
                body: Center(child: Text('Sipariş body')),
              ),
            ),
            NamedRouteDef(
              name: CustomRoute.musteriGecmis.routeName,
              path: 'gecmis',
              builder: (context, data) => const Scaffold(
                body: Center(child: Text('Geçmiş body')),
              ),
            ),
            NamedRouteDef(
              name: CustomRoute.musteriUgramaTalep.routeName,
              path: 'ugrama-talep',
              builder: (context, data) => const Scaffold(
                body: Center(child: Text('Uğrama body')),
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router.config(
            deepLinkBuilder: (_) => DeepLink.path(CustomRoute.musteriSiparis.path),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sipariş body'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text(musteriPrimaryMobileNavItems[1].label));
    await tester.pumpAndSettle();
    expect(find.text('Geçmiş body'), findsOneWidget);

    await tester.tap(find.text(musteriPrimaryMobileNavItems[2].label));
    await tester.pumpAndSettle();
    expect(find.text('Uğrama body'), findsOneWidget);
  });
}
