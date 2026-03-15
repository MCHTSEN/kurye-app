import 'dart:async';

import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/router/custom_route.dart';
import '../../core/theme/app_colors.dart';
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
    this.onLogout,
  });

  final String title;
  final Widget body;
  final List<NavItem> navItems;
  final CustomRoute currentRoute;
  final String headerTitle;
  final String? headerSubtitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// Optional callback for logout. When provided, a logout button is shown
  /// at the bottom of the drawer and navigation rail.
  final VoidCallback? onLogout;

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
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: _buildDrawer(context),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopScaffold(BuildContext context, LayoutType type) {
    final extended = type == LayoutType.desktop;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => _onNavigate(context, i),
            leading: extended
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.two_wheeler,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headerTitle,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (headerSubtitle != null)
                              Text(
                                headerSubtitle!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.two_wheeler,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
            trailing: onLogout != null
                ? Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          tooltip: 'Cikis Yap',
                          onPressed: onLogout,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                : null,
            destinations: navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: AppColors.border,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final subtitle = headerSubtitle;
    final initials = subtitle != null && subtitle.isNotEmpty
        ? subtitle[0].toUpperCase()
        : 'M';

    return Drawer(
      child: Column(
        children: [
          // ─── Gradient header ───
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  headerTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          // ─── Nav items ───
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (var i = 0; i < navItems.length; i++)
                  _DrawerNavTile(
                    icon: navItems[i].icon,
                    label: navItems[i].label,
                    isSelected: i == _selectedIndex,
                    onTap: () {
                      Navigator.pop(context);
                      _onNavigate(context, i);
                    },
                  ),
              ],
            ),
          ),
          // ─── Logout ───
          if (onLogout != null) ...[
            const Divider(height: 1),
            _DrawerNavTile(
              icon: Icons.logout_rounded,
              label: 'Cikis Yap',
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                onLogout!();
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
