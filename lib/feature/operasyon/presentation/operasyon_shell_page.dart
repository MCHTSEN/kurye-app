import 'dart:async';

import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../product/analytics/analytics_provider.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';

class OperasyonShellPage extends ConsumerWidget {
  const OperasyonShellPage({super.key});

  static final _tabRoutes = <PageRouteInfo>[
    PageRouteInfo(CustomRoute.operasyonEkran.routeName),
    PageRouteInfo(CustomRoute.ugramaYonetim.routeName),
    PageRouteInfo(CustomRoute.operasyonDashboard.routeName),
    PageRouteInfo(CustomRoute.operasyonAyarlar.routeName),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutType = layoutTypeOf(context);
    if (layoutType != LayoutType.mobile) {
      return const AutoRouter();
    }

    final analytics = ref.read(analyticsServiceProvider);

    return AutoTabsScaffold(
      routes: _tabRoutes,
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: (index) {
            if (tabsRouter.activeIndex == index) {
              return;
            }

            tabsRouter.setActiveIndex(index);
            final selectedItem = operasyonPrimaryMobileNavItems[index];
            unawaited(
              analytics.track(
                AppEvents.operasyonTabSelected(selectedItem.label),
              ),
            );
          },
          destinations: operasyonPrimaryMobileNavItems
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  label: item.label,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class OperasyonSettingsScaffold extends StatelessWidget {
  const OperasyonSettingsScaffold({
    required this.title,
    required this.body,
    super.key,
    this.actions,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: title,
      body: body,
      actions: actions,
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      showMobileDrawer: false,
    );
  }
}
