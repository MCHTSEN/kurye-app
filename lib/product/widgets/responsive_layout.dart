import 'package:flutter/material.dart';

/// Breakpoints for responsive layout decisions.
abstract final class AppBreakpoint {
  /// Mobile: < 600
  static const double mobile = 600;

  /// Tablet: 600..1024
  static const double tablet = 1024;

  /// Desktop: >= 1024
  static const double desktop = 1024;
}

/// Returns the current layout type based on screen width.
LayoutType layoutTypeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < AppBreakpoint.mobile) return LayoutType.mobile;
  if (width < AppBreakpoint.desktop) return LayoutType.tablet;
  return LayoutType.desktop;
}

enum LayoutType { mobile, tablet, desktop }

/// A builder widget that provides layout-aware children.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final type = layoutTypeOf(context);
    return switch (type) {
      LayoutType.desktop => desktop ?? tablet ?? mobile,
      LayoutType.tablet => tablet ?? mobile,
      LayoutType.mobile => mobile,
    };
  }
}

/// Constrains content to a max width and centers it (useful for web).
class ContentConstraint extends StatelessWidget {
  const ContentConstraint({
    required this.child,
    super.key,
    this.maxWidth = 1200,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
