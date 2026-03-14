import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/project_padding.dart';
import '../../../l10n/app_localizations.dart';
import '../../../product/analytics/analytics_provider.dart';
import '../../../product/navigation/navigation_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';

class BuyCreditPage extends ConsumerWidget {
  const BuyCreditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.buyCreditTitle)),
      body: Padding(
        padding: ProjectPadding.all.normal,
        child: Column(
          children: <Widget>[
            AppSectionCard(
              title: l10n.buyCreditInsufficientTitle,
              child: Text(l10n.buyCreditDescription),
            ),
            const Spacer(),
            AppPrimaryButton(
              label: l10n.buyCreditSendIntent,
              onPressed: () async {
                await ref
                    .read(analyticsServiceProvider)
                    .track(AppEvents.creditPurchaseIntent);

                ref.read(appNavigationStateProvider).clearCreditRequirement();

                if (context.mounted) {
                  await context.router.replacePath(CustomRoute.home.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
