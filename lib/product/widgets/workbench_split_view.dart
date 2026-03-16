import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/project_padding.dart';
import 'responsive_layout.dart';

class WorkbenchSplitView extends StatelessWidget {
  const WorkbenchSplitView({
    required this.editorPane,
    required this.contentPane,
    super.key,
    this.header,
    this.editorWidth = 420,
    this.maxContentWidth = 1480,
  });

  final Widget? header;
  final Widget editorPane;
  final Widget contentPane;
  final double editorWidth;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final layoutType = layoutTypeOf(context);
    if (layoutType == LayoutType.mobile) {
      return ListView(
        padding: ProjectPadding.all.normal,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: AppSpacing.md),
          ],
          editorPane,
          const SizedBox(height: AppSpacing.md),
          contentPane,
        ],
      );
    }

    return Padding(
      padding: ProjectPadding.all.large,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
              if (header != null) ...[
                header!,
                const SizedBox(height: AppSpacing.lg),
              ],
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: editorWidth, child: editorPane),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: contentPane),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
