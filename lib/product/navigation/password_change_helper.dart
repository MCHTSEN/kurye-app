import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_spacing.dart';
import '../../feature/auth/application/auth_controller.dart';

Future<void> showChangePasswordDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var showPassword = false;
  var isSubmitting = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            setState(() => isSubmitting = true);

            await ref
                .read(authControllerProvider.notifier)
                .updatePassword(
                  newPassword: newPasswordController.text,
                );

            final authState = ref.read(authControllerProvider);
            if (!dialogContext.mounted) return;

            setState(() => isSubmitting = false);
            if (authState.hasError) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text('Şifre değiştirilemedi: ${authState.error}'),
                ),
              );
              return;
            }

            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Şifre güncellendi')),
            );
          }

          return AlertDialog(
            title: const Text('Şifre Değiştir'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const Key('change_password_new_field'),
                    controller: newPasswordController,
                    obscureText: !showPassword,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        onPressed: isSubmitting
                            ? null
                            : () =>
                                  setState(() => showPassword = !showPassword),
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    key: const Key('change_password_confirm_field'),
                    controller: confirmPasswordController,
                    obscureText: !showPassword,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Yeni Şifre Tekrar',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                    ),
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('İptal'),
              ),
              FilledButton(
                key: const Key('change_password_submit_btn'),
                onPressed: isSubmitting ? null : submit,
                child: isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Güncelle'),
              ),
            ],
          );
        },
      );
    },
  );

  newPasswordController.dispose();
  confirmPasswordController.dispose();
}
