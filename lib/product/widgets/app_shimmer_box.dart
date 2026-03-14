import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';

/// Shimmer loading placeholder box.
///
/// Use this for skeleton loading states in lists, cards, or any content area.
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    this.width,
    this.height = 16,
    this.borderRadius,
    super.key,
  });

  /// Creates a circular shimmer (e.g., for avatar placeholders).
  const AppShimmerBox.circle({
    required double size,
    super.key,
  })  : width = size,
        height = size,
        borderRadius = null;

  /// Creates a card-shaped shimmer placeholder.
  const AppShimmerBox.card({super.key})
      : width = double.infinity,
        height = 120,
        borderRadius = null;

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCircle = width == height && borderRadius == null && width != null;
    final effectiveRadius = borderRadius ??
        (isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(AppRadius.small));

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerLow,
      highlightColor: colorScheme.surfaceContainerHigh,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: effectiveRadius,
        ),
      ),
    );
  }
}

/// Pre-built shimmer skeleton for a typical list item.
class AppShimmerListTile extends StatelessWidget {
  const AppShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          const AppShimmerBox.circle(size: 48),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  height: 14,
                ),
                const SizedBox(height: AppSpacing.xs),
                const AppShimmerBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
