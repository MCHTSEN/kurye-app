import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../auth/application/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );
    final authController = ref.read(authControllerProvider.notifier);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Moto Kurye')),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          profileAsync.when(
            data: (profile) {
              if (profile == null) {
                return const AppSectionCard(
                  title: 'Hesap Beklemede',
                  child: Text(
                    'Hesabınız henüz sisteme tanımlanmamış.\n\n'
                    'Operasyon personeliniz hesabınıza rol ataması '
                    'yapana kadar bekleyiniz.',
                  ),
                );
              }
              return AppSectionCard(
                title: 'Hoş geldiniz, ${profile.displayName}',
                child: Text('Rol: ${profile.role.value}'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppSectionCard(
              title: 'Profil Hatası',
              child: Text('$e'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Çıkış Yap',
            isLoading: isLoading,
            onPressed: authController.signOut,
          ),
        ],
      ),
    );
  }
}
