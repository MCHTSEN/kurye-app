import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_section_card.dart';

class MusteriSiparisPage extends ConsumerWidget {
  const MusteriSiparisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sipariş Oluştur')),
      body: profileAsync.when(
        data: (profile) {
          final name = profile?.displayName ?? 'Müşteri';
          return ListView(
            padding: ProjectPadding.all.normal,
            children: [
              AppSectionCard(
                title: 'Hoş geldiniz, $name',
                child: const Text(
                  'Yeni sipariş oluşturmak için formu doldurun.',
                ),
              ),
              const SizedBox(height: 16),
              // TODO(sprint2): Sipariş oluşturma formu
              const AppSectionCard(
                title: 'Sipariş Formu',
                child: Text("Sprint 2'de implement edilecek."),
              ),
              const SizedBox(height: 16),
              // TODO(sprint2): Aktif siparişler listesi
              const AppSectionCard(
                title: 'Aktif Siparişler',
                child: Text("Sprint 2'de implement edilecek."),
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
