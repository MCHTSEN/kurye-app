import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    required this.title,
    required this.child,
    this.description,
    this.footer,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget child;
  final String? description;
  final Widget? footer;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Row(
        children: [
          Expanded(
            child: Text(title, style: theme.textTheme.h4),
          ),
          if (trailing != null) trailing!,
        ],
      ),
      description: description != null ? Text(description!) : null,
      footer: footer,
      child: child,
    );
  }
}
