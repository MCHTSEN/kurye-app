import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_section_card.dart';

class OperasyonDashboardPage extends ConsumerWidget {
  const OperasyonDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const _OperasyonDrawer(),
      body: profileAsync.when(
        data: (profile) {
          final name = profile?.displayName ?? 'Operasyon';
          return ListView(
            padding: ProjectPadding.all.normal,
            children: [
              AppSectionCard(
                title: 'Hoş geldiniz, $name',
                child: const Text('Operasyon kontrol paneli.'),
              ),
              const SizedBox(height: 16),
              // TODO(sprint3): Ciro analiz kartları
              const AppSectionCard(
                title: 'Ciro Analizi',
                child: Text("Sprint 3'te implement edilecek."),
              ),
              const SizedBox(height: 16),
              // TODO(sprint3): Kurye performans
              const AppSectionCard(
                title: 'Kurye Performansı',
                child: Text("Sprint 3'te implement edilecek."),
              ),
              const SizedBox(height: 16),
              // TODO(sprint3): Aktif kuryeler
              const AppSectionCard(
                title: 'Aktif Kuryeler',
                child: Text("Sprint 3'te implement edilecek."),
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

class _OperasyonDrawer extends StatelessWidget {
  const _OperasyonDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text(
              'Moto Kurye\nOperasyon',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Operasyon Ekranı'),
            onTap: () {
              Navigator.pop(context);
              // TODO(sprint3): Navigate to operasyon ekranı
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Müşteri Kayıt'),
            onTap: () {
              Navigator.pop(context);
              // TODO(sprint4): Navigate to müşteri kayıt
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Personel Kayıt'),
            onTap: () {
              Navigator.pop(context);
              // TODO(sprint4): Navigate to personel kayıt
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Uğrama Yönetimi'),
            onTap: () {
              Navigator.pop(context);
              // TODO(sprint4): Navigate to uğrama yönetim
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Geçmiş Siparişler'),
            onTap: () {
              Navigator.pop(context);
              // TODO(sprint4): Navigate to geçmiş siparişler
            },
          ),
        ],
      ),
    );
  }
}
