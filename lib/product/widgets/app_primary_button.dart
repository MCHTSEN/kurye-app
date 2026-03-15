import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ShadButton(
        enabled: !isLoading,
        onPressed: isLoading ? null : onPressed,
        leading: isLoading
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon,
        size: ShadButtonSize.lg,
        child: Text(label),
      ),
    );
  }
}
