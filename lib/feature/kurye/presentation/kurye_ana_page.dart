import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_section_card.dart';

class KuryeAnaPage extends ConsumerWidget {
  const KuryeAnaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kurye Paneli')),
      body: profileAsync.when(
        data: (profile) {
          final name = profile?.displayName ?? 'Kurye';
          return ListView(
            padding: ProjectPadding.all.normal,
            children: [
              AppSectionCard(
                title: 'Hoş geldiniz, $name',
                child: const Text('Kurye kontrol paneli.'),
              ),
              const SizedBox(height: 16),
              // TODO(sprint5): Aktif/pasif toggle
              const AppSectionCard(
                title: 'Durum',
                child: Text("Sprint 5'te implement edilecek."),
              ),
              const SizedBox(height: 16),
              // TODO(sprint5): Sipariş listesi
              const AppSectionCard(
                title: 'Siparişlerim',
                child: Text("Sprint 5'te implement edilecek."),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
