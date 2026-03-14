import 'package:flutter/widgets.dart';

import 'app_spacing.dart';

abstract final class ProjectPadding {
  static const all = _ProjectAllPadding();
  static const horizontal = _ProjectHorizontalPadding();
  static const vertical = _ProjectVerticalPadding();
}

final class _ProjectAllPadding {
  const _ProjectAllPadding();

  EdgeInsets get small => const EdgeInsets.all(AppSpacing.sm);
  EdgeInsets get normal => const EdgeInsets.all(AppSpacing.md);
  EdgeInsets get large => const EdgeInsets.all(AppSpacing.lg);
}

final class _ProjectHorizontalPadding {
  const _ProjectHorizontalPadding();

  EdgeInsets get small => const EdgeInsets.symmetric(horizontal: AppSpacing.sm);
  EdgeInsets get normal =>
      const EdgeInsets.symmetric(horizontal: AppSpacing.md);
  EdgeInsets get large => const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
}

final class _ProjectVerticalPadding {
  const _ProjectVerticalPadding();

  EdgeInsets get small => const EdgeInsets.symmetric(vertical: AppSpacing.sm);
  EdgeInsets get normal => const EdgeInsets.symmetric(vertical: AppSpacing.md);
  EdgeInsets get large => const EdgeInsets.symmetric(vertical: AppSpacing.lg);
}
