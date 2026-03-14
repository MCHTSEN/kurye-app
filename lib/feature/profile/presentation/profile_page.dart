import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../l10n/app_localizations.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/widgets/app_section_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: Padding(
        padding: ProjectPadding.all.normal,
        child: authState.when(
          data: (session) {
            if (session == null) {
              return AppSectionCard(
                title: l10n.profileUser,
                child: Text(l10n.profileNoSession),
              );
            }

            return AppSectionCard(
              title: l10n.profileUser,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('ID: ${session.user.id}'),
                  Text('Email: ${session.user.email ?? 'N/A'}'),
                ],
              ),
            );
          },
          error: (error, stackTrace) => AppSectionCard(
            title: l10n.profileError,
            child: Text(l10n.errorLoadFailed),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
