import 'dart:async';

import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/analytics/analytics_provider.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_section_card.dart';
import 'operasyon_shell_page.dart';

class OperasyonAyarlarPage extends ConsumerWidget {
  const OperasyonAyarlarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final authState = ref.watch(authStateProvider);

    return OperasyonSettingsScaffold(
      title: 'Ayarlar',
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          profileAsync.when(
            data: (profile) {
              final email = authState.asData?.value?.user.email ?? 'Bilinmiyor';
              return AppSectionCard(
                title: 'Hesap',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.displayName ?? 'Operasyon Kullanıcısı',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Rol: ${profile?.role.value ?? 'operasyon'}'),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Email: $email'),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: logoutCallback(ref),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Çıkış Yap'),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const AppSectionCard(
              title: 'Hesap',
              child: LinearProgressIndicator(),
            ),
            error: (error, _) => AppSectionCard(
              title: 'Hesap',
              child: Text('Hesap bilgisi yüklenemedi: $error'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SettingsSection(
            title: 'Yönetim',
            items: [
              _SettingsItem(
                title: 'Müşteri Kayıt',
                subtitle: 'Müşteri firmalarını oluştur ve düzenle',
                icon: Icons.business,
                route: CustomRoute.musteriKayit,
              ),
              _SettingsItem(
                title: 'Personel Kayıt',
                subtitle: 'Müşteri personel hesaplarını yönet',
                icon: Icons.people,
                route: CustomRoute.musteriPersonelKayit,
              ),
              _SettingsItem(
                title: 'Kurye Yönetimi',
                subtitle: 'Kurye listesi ve aktiflik durumları',
                icon: Icons.two_wheeler,
                route: CustomRoute.kuryeYonetim,
              ),
              _SettingsItem(
                title: 'Rol Onayları',
                subtitle: 'Bekleyen rol taleplerini incele',
                icon: Icons.how_to_reg,
                route: CustomRoute.rolOnay,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SettingsSection(
            title: 'Kayıt ve Talepler',
            items: [
              _SettingsItem(
                title: 'Geçmiş Siparişler',
                subtitle: 'Tamamlanan ve iptal edilen siparişleri filtrele',
                icon: Icons.history,
                route: CustomRoute.operasyonGecmis,
              ),
              _SettingsItem(
                title: 'Uğrama Talepleri',
                subtitle: 'Yeni uğrama isteklerini değerlendir',
                icon: Icons.playlist_add_check,
                route: CustomRoute.ugramaTalepYonetim,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  const _SettingsSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);

    return AppSectionCard(
      title: title,
      child: Column(
        children: [
          for (final item in items) ...[
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                unawaited(
                  analytics.track(
                    AppEvents.operasyonSettingsItemSelected(item.title),
                  ),
                );
                unawaited(
                  context.router.push(
                    PageRouteInfo(item.route.routeName),
                  ),
                );
              },
            ),
            if (item != items.last) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final CustomRoute route;
}
