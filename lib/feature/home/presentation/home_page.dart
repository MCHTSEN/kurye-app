import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../l10n/app_localizations.dart';
import '../../../product/runtime/runtime_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../auth/application/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );
    final authController = ref.read(authControllerProvider.notifier);
    final exampleFeedEnabled = ref.watch(
      featureFlagServiceProvider.select(
        (service) => service.isEnabled('example_feed_enabled'),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          AppSectionCard(
            title: l10n.homeSkeletonReady,
            child: Text(l10n.homeSkeletonDescription),
          ),
          if (exampleFeedEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: l10n.homeOpenExampleFeed,
              onPressed: () =>
                  context.router.pushPath(CustomRoute.exampleFeed.path),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: l10n.homeGoToProfile,
            onPressed: () => context.router.pushPath(CustomRoute.profile.path),
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: l10n.homeBuyCredit,
            onPressed: () =>
                context.router.pushPath(CustomRoute.buyCredit.path),
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: l10n.homeSignOut,
            isLoading: isLoading,
            onPressed: authController.signOut,
          ),
        ],
      ),
    );
  }
}
