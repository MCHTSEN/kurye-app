import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_radius.dart';

/// Cached network image with shimmer loading and error placeholder.
///
/// Wraps [CachedNetworkImage] with a consistent shimmer loading effect
/// and a fallback icon for failed loads.
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.broken_image_outlined,
    super.key,
  });

  /// URL of the image to load and cache.
  final String imageUrl;

  /// Fixed width. If null, expands to parent.
  final double? width;

  /// Fixed height. If null, expands to parent.
  final double? height;

  /// How the image should fit within its bounds.
  final BoxFit fit;

  /// Border radius for clipping. Defaults to [AppRadius.small].
  final BorderRadius? borderRadius;

  /// Icon shown when image fails to load.
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius =
        borderRadius ?? BorderRadius.circular(AppRadius.small);

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _ShimmerPlaceholder(
          width: width,
          height: height,
        ),
        errorWidget: (context, url, error) => _ErrorPlaceholder(
          width: width,
          height: height,
          icon: errorIcon,
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerLow,
      highlightColor: colorScheme.surfaceContainerHigh,
      child: Container(
        width: width,
        height: height,
        color: colorScheme.surfaceContainerLow,
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({
    required this.icon,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerLow,
      child: Center(
        child: Icon(
          icon,
          color: colorScheme.onSurfaceVariant,
          size: 32,
        ),
      ),
    );
  }
}
