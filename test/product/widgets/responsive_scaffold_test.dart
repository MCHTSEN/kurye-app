import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/app/router/custom_route.dart';
import 'package:kuryem/product/widgets/responsive_scaffold.dart';

void main() {
  testWidgets('desktop sidebar navigates across nested operasyon routes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = RootStackRouter.build(
      routes: [
        NamedRouteDef(
          name: CustomRoute.operasyonShell.routeName,
          path: CustomRoute.operasyonShell.path,
          builder: (context, data) => const AutoRouter(),
          children: [
            NamedRouteDef(
              name: CustomRoute.operasyonDashboard.routeName,
              path: 'dashboard',
              initial: true,
              builder: (context, data) => const ResponsiveScaffold(
                title: 'Dashboard',
                currentRoute: CustomRoute.operasyonDashboard,
                navItems: [
                  NavItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    route: CustomRoute.operasyonDashboard,
                  ),
                  NavItem(
                    icon: Icons.history,
                    label: 'Geçmiş',
                    route: CustomRoute.operasyonGecmis,
                  ),
                ],
                body: Center(child: Text('Dashboard body')),
              ),
            ),
            NamedRouteDef.shell(
              name: CustomRoute.operasyonAyarlar.routeName,
              path: 'ayarlar',
              children: [
                NamedRouteDef(
                  name: 'OperasyonAyarlarHomeRoute',
                  path: '',
                  initial: true,
                  builder: (context, data) => const SizedBox.shrink(),
                ),
                NamedRouteDef(
                  name: CustomRoute.operasyonGecmis.routeName,
                  path: 'gecmis',
                  builder: (context, data) => const ResponsiveScaffold(
                    title: 'Geçmiş',
                    currentRoute: CustomRoute.operasyonGecmis,
                    navItems: [
                      NavItem(
                        icon: Icons.dashboard,
                        label: 'Dashboard',
                        route: CustomRoute.operasyonDashboard,
                      ),
                      NavItem(
                        icon: Icons.history,
                        label: 'Geçmiş',
                        route: CustomRoute.operasyonGecmis,
                      ),
                    ],
                    body: Center(child: Text('Geçmiş body')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router.config(
          deepLinkBuilder: (_) =>
              DeepLink.path(CustomRoute.operasyonDashboard.path),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard body'), findsOneWidget);

    await tester.tap(find.text('Geçmiş'));
    await tester.pumpAndSettle();

    expect(find.text('Geçmiş body'), findsOneWidget);
  });
}
