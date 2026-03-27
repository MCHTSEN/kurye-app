import 'dart:async';

import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../product/analytics/analytics_provider.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/widgets/responsive_layout.dart';

class MusteriShellPage extends ConsumerWidget {
  const MusteriShellPage({super.key});

  static final _tabRoutes = <PageRouteInfo>[
    PageRouteInfo(CustomRoute.musteriSiparis.routeName),
    PageRouteInfo(CustomRoute.musteriGecmis.routeName),
    PageRouteInfo(CustomRoute.musteriUgramaTalep.routeName),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutType = layoutTypeOf(context);
    if (layoutType != LayoutType.mobile) {
      return const AutoRouter();
    }

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
            final selectedItem = musteriPrimaryMobileNavItems[index];
            try {
              final analytics = ref.read(analyticsServiceProvider);
              unawaited(
                analytics.track(
                  AppEvents.musteriTabSelected(selectedItem.label),
                ),
              );
            } on Object {
              // Tests and bootstrap-light contexts may omit analytics env.
            }
          },
          destinations: musteriPrimaryMobileNavItems
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
