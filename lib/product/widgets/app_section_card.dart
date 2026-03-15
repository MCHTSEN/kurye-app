import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_colors.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    required this.title,
    required this.child,
    this.description,
    this.footer,
    this.trailing,
    this.accentColor,
    this.icon,
    super.key,
  });

  final String title;
  final Widget child;
  final String? description;
  final Widget? footer;
  final Widget? trailing;

  /// Optional left accent stripe color.
  final Color? accentColor;

  /// Optional icon displayed before the title.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    Widget card = ShadCard(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
      description: description != null ? Text(description!) : null,
      footer: footer,
      child: child,
    );

    if (accentColor != null) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentColor!, width: 4),
            ),
          ),
          child: card,
        ),
      );
    }

    return card;
  }
}
