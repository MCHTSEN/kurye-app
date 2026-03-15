import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../product/onboarding/onboarding_providers.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = ShadTheme.of(context);
    final isLoading = ref.watch(
      onboardingStatusControllerProvider.select((state) => state.isLoading),
    );
    final onboardingController = ref.read(
      onboardingStatusControllerProvider.notifier,
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.two_wheeler,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Moto Kurye', style: theme.textTheme.h1),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.onboardingBody,
                  style: theme.textTheme.muted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    enabled: !isLoading,
                    onPressed: isLoading
                        ? null
                        : () async {
                            await onboardingController.completeOnboarding();
                            if (context.mounted) {
                              await context.router
                                  .replacePath(CustomRoute.auth.path);
                            }
                          },
                    leading: isLoading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    size: ShadButtonSize.lg,
                    child: Text(l10n.onboardingContinue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
