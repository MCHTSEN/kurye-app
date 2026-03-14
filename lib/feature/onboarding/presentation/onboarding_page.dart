import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/project_padding.dart';
import '../../../l10n/app_localizations.dart';
import '../../../product/onboarding/onboarding_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(
      onboardingStatusControllerProvider.select((state) => state.isLoading),
    );
    final onboardingController = ref.read(
      onboardingStatusControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingTitle)),
      body: Padding(
        padding: ProjectPadding.all.normal,
        child: Column(
          children: <Widget>[
            AppSectionCard(
              title: l10n.onboardingTitle,
              child: Text(l10n.onboardingBody),
            ),
            const Spacer(),
            AppPrimaryButton(
              label: l10n.onboardingContinue,
              isLoading: isLoading,
              onPressed: () async {
                await onboardingController.completeOnboarding();
                if (context.mounted) {
                  await context.router.replacePath(CustomRoute.auth.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
