import 'dart:async';

import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:flutter/material.dart';

import '../../app/router/custom_route.dart';
import 'responsive_layout.dart';

/// Navigation item definition shared between Drawer and NavigationRail.
class NavItem {
  const NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final CustomRoute route;
}

/// A scaffold that shows a NavigationRail sidebar on desktop/tablet
/// and a Drawer on mobile.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    required this.title,
    required this.body,
    required this.navItems,
    required this.currentRoute,
    super.key,
    this.headerTitle = 'Moto Kurye',
    this.headerSubtitle,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<NavItem> navItems;
  final CustomRoute currentRoute;
  final String headerTitle;
  final String? headerSubtitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  int get _selectedIndex {
    final idx = navItems.indexWhere((n) => n.route == currentRoute);
    return idx >= 0 ? idx : 0;
  }

  void _onNavigate(BuildContext context, int index) {
    final target = navItems[index].route;
    if (target == currentRoute) return;
    try {
      unawaited(context.router.replacePath(target.path));
    } on Object {
      // Fallback when auto_route is not mounted (e.g. test harness).
      unawaited(Navigator.of(context).pushReplacementNamed(target.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = layoutTypeOf(context);
    if (type == LayoutType.mobile) {
      return _buildMobileScaffold(context);
    }
    return _buildDesktopScaffold(context, type);
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: _buildDrawer(context),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopScaffold(BuildContext context, LayoutType type) {
    final extended = type == LayoutType.desktop;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => _onNavigate(context, i),
            leading: extended
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          headerTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (headerSubtitle != null)
                          Text(
                            headerSubtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  )
                : null,
            destinations: navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            child: Text(
              '$headerTitle\n${headerSubtitle ?? ''}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          for (var i = 0; i < navItems.length; i++)
            ListTile(
              leading: Icon(navItems[i].icon),
              title: Text(navItems[i].label),
              selected: i == _selectedIndex,
              onTap: () {
                Navigator.pop(context);
                _onNavigate(context, i);
              },
            ),
        ],
      ),
    );
  }
}
