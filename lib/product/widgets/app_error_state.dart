import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import 'app_primary_button.dart';
import 'app_section_card.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    required this.retryLabel,
    super.key,
    this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(message),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(label: retryLabel, onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}
