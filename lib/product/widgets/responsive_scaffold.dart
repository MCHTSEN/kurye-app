import 'dart:async';

import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/router/custom_route.dart';
import '../../core/theme/app_colors.dart';
import 'responsive_layout.dart';

final class _NavigationTheme {
  static const bg = Color(0xFF111827);
  static const surface = Color(0xFF1F2937);
  static const surfaceAlt = Color(0xFF0B1220);
  static const divider = Color(0xFF374151);
  static const textPrimary = Color(0xFFE5E7EB);
  static const textMuted = Color(0xFF9CA3AF);
}

/// Navigation item definition shared between Drawer and NavigationRail.
class NavItem {
  const NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.section = 'Genel',
  });

  final IconData icon;
  final String label;
  final CustomRoute route;
  final String section;
}

/// A scaffold that shows a NavigationRail sidebar on desktop/tablet
/// and a Drawer on mobile.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    required this.title,
    required this.body,
    required this.navItems,
    this.currentRoute,
    super.key,
    this.headerTitle = 'Moto Kurye',
    this.headerSubtitle,
    this.actions,
    this.floatingActionButton,
    this.onLogout,
    this.showMobileDrawer = true,
    this.showAppBar = true,
  });

  final String title;
  final Widget body;
  final List<NavItem> navItems;
  final CustomRoute? currentRoute;
  final String headerTitle;
  final String? headerSubtitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// Optional callback for logout. When provided, a logout button is shown
  /// at the bottom of the drawer and navigation rail.
  final VoidCallback? onLogout;
  final bool showMobileDrawer;
  final bool showAppBar;

  int? get _selectedIndex {
    final current = currentRoute;
    if (current == null) {
      return null;
    }
    final idx = navItems.indexWhere((n) => n.route == current);
    return idx >= 0 ? idx : null;
  }

  void _onNavigate(BuildContext context, int index) {
    final target = navItems[index].route;
    if (target == currentRoute) return;
    try {
      unawaited(
        context.navigateToPath(
          target.path,
          includePrefixMatches: true,
        ),
      );
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
    return _wrapWithDesktopShortcuts(
      context: context,
      child: _buildDesktopScaffold(context, type),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: actions,
            )
          : null,
      drawer: showMobileDrawer ? _buildDrawer(context) : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopScaffold(BuildContext context, LayoutType type) {
    if (type == LayoutType.desktop) {
      final width = MediaQuery.sizeOf(context).width;
      final sidebarWidth = (width * 0.22).clamp(280.0, 360.0);
      return Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: Text(title),
                actions: actions,
              )
            : null,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            _buildDesktopSidebar(context, width: sidebarWidth),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: _NavigationTheme.divider,
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: actions,
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => _onNavigate(context, i),
            leading: Padding(
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
            color: _NavigationTheme.divider,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _wrapWithDesktopShortcuts({
    required BuildContext context,
    required Widget child,
  }) {
    final shortcutMap = <ShortcutActivator, Intent>{};
    final maxItems = navItems.length > 9 ? 9 : navItems.length;

    for (var i = 0; i < maxItems; i++) {
      final digitKey = switch (i) {
        0 => LogicalKeyboardKey.digit1,
        1 => LogicalKeyboardKey.digit2,
        2 => LogicalKeyboardKey.digit3,
        3 => LogicalKeyboardKey.digit4,
        4 => LogicalKeyboardKey.digit5,
        5 => LogicalKeyboardKey.digit6,
        6 => LogicalKeyboardKey.digit7,
        7 => LogicalKeyboardKey.digit8,
        _ => LogicalKeyboardKey.digit9,
      };
      shortcutMap[SingleActivator(
        digitKey,
        control: true,
      )] = _NavShortcutIntent(
        i,
      );
      shortcutMap[SingleActivator(digitKey, meta: true)] = _NavShortcutIntent(
        i,
      );
    }

    return Shortcuts(
      shortcuts: shortcutMap,
      child: Actions(
        actions: {
          _NavShortcutIntent: CallbackAction<_NavShortcutIntent>(
            onInvoke: (intent) {
              _onNavigate(context, intent.index);
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, {required double width}) {
    final groupedItems = <String, List<(int, NavItem)>>{};
    for (var i = 0; i < navItems.length; i++) {
      final item = navItems[i];
      groupedItems.putIfAbsent(item.section, () => <(int, NavItem)>[]).add((
        i,
        item,
      ));
    }

    return Container(
      width: width,
      color: _NavigationTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_NavigationTheme.surfaceAlt, _NavigationTheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.two_wheeler_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headerTitle,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: _NavigationTheme.textPrimary,
                            ),
                          ),
                          if (headerSubtitle != null)
                            Text(
                              headerSubtitle!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _NavigationTheme.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    'Kısayollar: Ctrl/Cmd + 1-${navItems.length > 9 ? 9 : navItems.length}',
                    style: const TextStyle(
                      color: _NavigationTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              children: [
                for (final entry in groupedItems.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: _NavigationTheme.textMuted,
                      ),
                    ),
                  ),
                  for (final indexedItem in entry.value)
                    _DesktopNavTile(
                      icon: indexedItem.$2.icon,
                      label: indexedItem.$2.label,
                      shortcutLabel: _shortcutLabelFor(indexedItem.$1),
                      isSelected: indexedItem.$1 == _selectedIndex,
                      onTap: () => _onNavigate(context, indexedItem.$1),
                    ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          if (onLogout != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: FilledButton.tonalIcon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Çıkış Yap'),
              ),
            ),
        ],
      ),
    );
  }

  String? _shortcutLabelFor(int index) {
    if (index > 8) {
      return null;
    }
    return 'Ctrl+${index + 1}';
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: _NavigationTheme.bg,
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_NavigationTheme.surfaceAlt, _NavigationTheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 240,
                  maxHeight: 140,
                ),
                child: Image.asset(
                  'assets/images/bmk-logo.png',
                  fit: BoxFit.contain,
                ),
              ),
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
            const Divider(height: 1, color: _NavigationTheme.divider),
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
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 400;
    final labelFontSize = isCompact ? 16.0 : 18.0;
    final iconSize = isCompact ? 22.0 : 24.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.2)
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
                  size: iconSize,
                  color: isSelected
                      ? AppColors.primary
                      : _NavigationTheme.textMuted,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : _NavigationTheme.textPrimary,
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

class _DesktopNavTile extends StatelessWidget {
  const _DesktopNavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.shortcutLabel,
  });

  final IconData icon;
  final String label;
  final String? shortcutLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final labelFontSize = width < 1280 ? 15.0 : 17.0;
    final shortcutFontSize = width < 1280 ? 11.0 : 12.0;
    return Tooltip(
      message: shortcutLabel == null ? label : '$label ($shortcutLabel)',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Material(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.14)
                          : _NavigationTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? _NavigationTheme.textPrimary
                            : _NavigationTheme.textMuted,
                      ),
                    ),
                  ),
                  if (shortcutLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _NavigationTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _NavigationTheme.divider),
                      ),
                      child: Text(
                        shortcutLabel!,
                        style: TextStyle(
                          fontSize: shortcutFontSize,
                          fontWeight: FontWeight.w600,
                          color: _NavigationTheme.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavShortcutIntent extends Intent {
  const _NavShortcutIntent(this.index);

  final int index;
}
