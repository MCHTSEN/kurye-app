import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/app/router/custom_route.dart';
import 'package:kuryem/feature/operasyon/presentation/operasyon_shell_page.dart';
import 'package:kuryem/product/analytics/analytics_provider.dart';

import '../../helpers/fakes/fake_analytics_service.dart';

void main() {
  group('OperasyonShellPage', () {
    late FakeAnalyticsService analytics;

    setUp(() {
      analytics = FakeAnalyticsService();
    });

    testWidgets('renders a four-item mobile navigation bar', (tester) async {
      await _pumpShell(tester, analytics: analytics);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Operasyon'), findsOneWidget);
      expect(find.text('Uğrama'), findsOneWidget);
      expect(find.text('Raporlar'), findsOneWidget);
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('Operasyon tab'), findsOneWidget);
    });

    testWidgets('preserves tab state when switching tabs', (tester) async {
      await _pumpShell(tester, analytics: analytics);

      await tester.enterText(
        find.byKey(const Key('operasyon_form_field')),
        'Korunacak veri',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Raporlar'));
      await tester.pumpAndSettle();

      expect(find.text('Raporlar tab'), findsOneWidget);

      await tester.tap(find.text('Operasyon'));
      await tester.pumpAndSettle();

      expect(find.text('Korunacak veri'), findsOneWidget);
      expect(
        analytics.trackedEvents
            .where((event) => event.name == 'operasyon_tab_selected')
            .length,
        2,
      );
    });
  });
}

Future<void> _pumpShell(
  WidgetTester tester, {
  required FakeAnalyticsService analytics,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = RootStackRouter.build(
    routes: [
      NamedRouteDef(
        name: CustomRoute.operasyonShell.routeName,
        path: CustomRoute.operasyonShell.path,
        builder: (context, data) => const OperasyonShellPage(),
        children: [
          NamedRouteDef(
            name: CustomRoute.operasyonDashboard.routeName,
            path: 'dashboard',
            builder: (context, data) => const Scaffold(
              body: Center(child: Text('Raporlar tab')),
            ),
          ),
          NamedRouteDef(
            name: CustomRoute.operasyonEkran.routeName,
            path: 'ekran',
            initial: true,
            builder: (context, data) => const Scaffold(
              body: Center(child: _FakeOperasyonTabLabel()),
            ),
          ),
          NamedRouteDef(
            name: CustomRoute.ugramaYonetim.routeName,
            path: 'ugrama',
            builder: (context, data) => const Scaffold(
              body: Center(child: Text('Uğrama tab')),
            ),
          ),
          NamedRouteDef(
            name: CustomRoute.operasyonAyarlar.routeName,
            path: 'ayarlar',
            builder: (context, data) => const Scaffold(
              body: Center(child: Text('Ayarlar tab')),
            ),
          ),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
      child: MaterialApp.router(
        routerConfig: router.config(
          deepLinkBuilder: (_) =>
              DeepLink.path(CustomRoute.operasyonShell.path),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeOperasyonTab extends StatefulWidget {
  const _FakeOperasyonTab();

  @override
  State<_FakeOperasyonTab> createState() => _FakeOperasyonTabState();
}

class _FakeOperasyonTabLabel extends StatelessWidget {
  const _FakeOperasyonTabLabel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Operasyon tab'),
        SizedBox(height: 12),
        _FakeOperasyonTab(),
      ],
    );
  }
}

class _FakeOperasyonTabState extends State<_FakeOperasyonTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        key: const Key('operasyon_form_field'),
        controller: _controller,
      ),
    );
  }
}
