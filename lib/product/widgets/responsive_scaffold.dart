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
class ResponsiveScaffold extends StatefulWidget {
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

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  bool _isDesktopSidebarExpanded = false;

  int? get _selectedIndex {
    final current = widget.currentRoute;
    if (current == null) {
      return null;
    }
    final idx = widget.navItems.indexWhere((n) => n.route == current);
    return idx >= 0 ? idx : null;
  }

  void _onNavigate(BuildContext context, int index) {
    final target = widget.navItems[index].route;
    if (target == widget.currentRoute) return;
    if (_isDesktopSidebarExpanded) {
      setState(() => _isDesktopSidebarExpanded = false);
    }
    try {
      unawaited(
        context.navigateToPath(target.path),
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
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title),
              actions: widget.actions,
            )
          : null,
      drawer: widget.showMobileDrawer ? _buildDrawer(context) : null,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildDesktopScaffold(BuildContext context, LayoutType type) {
    if (type == LayoutType.desktop) {
      final width = MediaQuery.sizeOf(context).width;
      final expandedWidth = (width * 0.22).clamp(280.0, 340.0);
      final sidebarWidth = _isDesktopSidebarExpanded ? expandedWidth : 96.0;
      return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(widget.title),
                actions: widget.actions,
              )
            : null,
        floatingActionButton: widget.floatingActionButton,
        body: Row(
          children: [
            _buildDesktopSidebar(
              context,
              width: sidebarWidth,
              isExpanded: _isDesktopSidebarExpanded,
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: _NavigationTheme.divider,
            ),
            Expanded(child: widget.body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title),
              actions: widget.actions,
            )
          : null,
      floatingActionButton: widget.floatingActionButton,
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
            trailing: widget.onLogout != null
                ? Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          tooltip: 'Cikis Yap',
                          onPressed: widget.onLogout,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                : null,
            destinations: widget.navItems
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
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  Widget _wrapWithDesktopShortcuts({
    required BuildContext context,
    required Widget child,
  }) {
    final shortcutMap = <ShortcutActivator, Intent>{};
    final maxItems = widget.navItems.length > 9 ? 9 : widget.navItems.length;

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

  Widget _buildDesktopSidebar(
    BuildContext context, {
    required double width,
    required bool isExpanded,
  }) {
    final groupedItems = <String, List<(int, NavItem)>>{};
    for (var i = 0; i < widget.navItems.length; i++) {
      final item = widget.navItems[i];
      groupedItems.putIfAbsent(item.section, () => <(int, NavItem)>[]).add((
        i,
        item,
      ));
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      color: _NavigationTheme.bg,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showExpandedContent =
                isExpanded && constraints.maxWidth > 220;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    showExpandedContent ? 24 : 16,
                    18,
                    showExpandedContent ? 24 : 16,
                    14,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _NavigationTheme.surfaceAlt,
                        _NavigationTheme.surface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: showExpandedContent
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: showExpandedContent
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
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
                          if (showExpandedContent) ...[
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.headerTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                      color: _NavigationTheme.textPrimary,
                                    ),
                                  ),
                                  if (widget.headerSubtitle != null)
                                    Text(
                                      widget.headerSubtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: _NavigationTheme.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SidebarToggleButton(
                        isExpanded: showExpandedContent,
                        onPressed: () {
                          setState(
                            () => _isDesktopSidebarExpanded =
                                !_isDesktopSidebarExpanded,
                          );
                        },
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
                            showExpandedContent ? entry.key : '',
                            textAlign: showExpandedContent
                                ? TextAlign.left
                                : TextAlign.center,
                            style: TextStyle(
                              fontSize: showExpandedContent ? 14 : 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                              color: _NavigationTheme.textMuted,
                            ),
                          ),
                        ),
                        for (final indexedItem in entry.value)
                          _DesktopNavTile(
                            icon: indexedItem.$2.icon,
                            label: indexedItem.$2.label,
                            shortcutLabel: _shortcutLabelFor(indexedItem.$1),
                            isExpanded: showExpandedContent,
                            isSelected: indexedItem.$1 == _selectedIndex,
                            onTap: () => _onNavigate(context, indexedItem.$1),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
                if (widget.onLogout != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      showExpandedContent ? 16 : 12,
                      0,
                      showExpandedContent ? 16 : 12,
                      20,
                    ),
                    child: showExpandedContent
                        ? FilledButton.tonalIcon(
                            onPressed: widget.onLogout,
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text(
                              'Çıkış Yap',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : IconButton.filledTonal(
                            tooltip: 'Çıkış Yap',
                            onPressed: widget.onLogout,
                            icon: const Icon(Icons.logout_rounded),
                          ),
                  ),
              ],
            );
          },
        ),
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
                for (var i = 0; i < widget.navItems.length; i++)
                  _DrawerNavTile(
                    icon: widget.navItems[i].icon,
                    label: widget.navItems[i].label,
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
          if (widget.onLogout != null) ...[
            const Divider(height: 1, color: _NavigationTheme.divider),
            _DrawerNavTile(
              icon: Icons.logout_rounded,
              label: 'Cikis Yap',
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                widget.onLogout!();
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  const _SidebarToggleButton({
    required this.isExpanded,
    required this.onPressed,
  });

  final bool isExpanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tooltip = isExpanded ? 'Menüyü daralt' : 'Menüyü aç';

    if (!isExpanded) {
      return Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 52,
          height: 56,
          child: Material(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _NavigationTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: _NavigationTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
        label: const Text(
          'Menüyü daralt',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
    required this.isExpanded,
    this.shortcutLabel,
  });

  final IconData icon;
  final String label;
  final String? shortcutLabel;
  final bool isSelected;
  final bool isExpanded;
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
            borderRadius: BorderRadius.circular(isExpanded ? 18 : 14),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 14 : 8,
                vertical: isExpanded ? 14 : 10,
              ),
              child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
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
                  if (isExpanded) ...[
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
