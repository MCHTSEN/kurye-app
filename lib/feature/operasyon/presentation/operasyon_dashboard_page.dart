import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_section_card.dart';
import '../domain/dashboard_stats.dart';
import '../providers/dashboard_providers.dart';

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
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardStatsProvider);
              // Wait for the provider to re-resolve so the indicator
              // stays visible until data arrives.
              await ref.read(dashboardStatsProvider.future);
            },
            child: ListView(
              padding: ProjectPadding.all.normal,
              children: [
                AppSectionCard(
                  title: 'Hoş geldiniz, $name',
                  child: const Text('Operasyon kontrol paneli.'),
                ),
                const SizedBox(height: AppSpacing.md),
                const _CiroAnaliziCard(),
                const SizedBox(height: AppSpacing.md),
                const _KuryePerformansCard(),
                const SizedBox(height: AppSpacing.md),
                const _AktifKuryelerCard(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ciro Analizi card
// ---------------------------------------------------------------------------

class _CiroAnaliziCard extends ConsumerWidget {
  const _CiroAnaliziCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return AppSectionCard(
      title: 'Ciro Analizi',
      child: statsAsync.when(
        data: (stats) => _CiroContent(stats: stats),
        loading: () => const _CardLoading(),
        error: (e, _) => _CardError(message: e.toString()),
      ),
    );
  }
}

class _CiroContent extends StatelessWidget {
  const _CiroContent({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _RevenueCell(
                label: '3 Aylık',
                amount: stats.revenue3mo,
              ),
            ),
            Expanded(
              child: _RevenueCell(
                label: '1 Aylık',
                amount: stats.revenue1mo,
              ),
            ),
            Expanded(
              child: _RevenueCell(
                label: '1 Haftalık',
                amount: stats.revenue1wk,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Günlük Ortalama: ${_formatCurrency(stats.dailyAvg)}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _RevenueCell extends StatelessWidget {
  const _RevenueCell({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          _formatCurrency(amount),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kurye Performansı card
// ---------------------------------------------------------------------------

class _KuryePerformansCard extends ConsumerWidget {
  const _KuryePerformansCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return AppSectionCard(
      title: 'Kurye Performansı',
      child: statsAsync.when(
        data: (stats) => _KuryePerformansContent(stats: stats),
        loading: () => const _CardLoading(),
        error: (e, _) => _CardError(message: e.toString()),
      ),
    );
  }
}

class _KuryePerformansContent extends StatelessWidget {
  const _KuryePerformansContent({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.courierStats.isEmpty) {
      return const Text('Veri yok');
    }

    return Column(
      children: [
        for (final cs in stats.courierStats)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(cs.ad),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Ay: ${cs.monthlyJobs}',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Bugün: ${cs.dailyJobs}',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Aktif Kuryeler card
// ---------------------------------------------------------------------------

class _AktifKuryelerCard extends ConsumerWidget {
  const _AktifKuryelerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return AppSectionCard(
      title: 'Aktif Kuryeler',
      child: statsAsync.when(
        data: (stats) => _AktifKuryelerContent(stats: stats),
        loading: () => const _CardLoading(),
        error: (e, _) => _CardError(message: e.toString()),
      ),
    );
  }
}

class _AktifKuryelerContent extends StatelessWidget {
  const _AktifKuryelerContent({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (stats.activeCourierCount == 0) {
      return const Text('Aktif kurye yok');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${stats.activeCourierCount}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final name in stats.activeCourierNames)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs / 2),
            child: Text('• $name'),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

String _formatCurrency(double amount) {
  return '₺${amount.toStringAsFixed(2)}';
}

class _CardLoading extends StatelessWidget {
  const _CardLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hata: $message',
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Drawer (unchanged)
// ---------------------------------------------------------------------------

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
              unawaited(Navigator.pushNamed(
                context,
                CustomRoute.operasyonEkran.path,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Müşteri Kayıt'),
            onTap: () {
              Navigator.pop(context);
              unawaited(Navigator.pushNamed(
                context,
                CustomRoute.musteriKayit.path,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Personel Kayıt'),
            onTap: () {
              Navigator.pop(context);
              unawaited(Navigator.pushNamed(
                context,
                CustomRoute.musteriPersonelKayit.path,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Uğrama Yönetimi'),
            onTap: () {
              Navigator.pop(context);
              unawaited(Navigator.pushNamed(
                context,
                CustomRoute.ugramaYonetim.path,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.two_wheeler),
            title: const Text('Kurye Yönetimi'),
            onTap: () {
              Navigator.pop(context);
              unawaited(Navigator.pushNamed(
                context,
                CustomRoute.kuryeYonetim.path,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_reg),
            title: const Text('Rol Onayları'),
            onTap: () {
              Navigator.pop(context);
              unawaited(Navigator.pushNamed(
                context,
                CustomRoute.rolOnay.path,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Geçmiş Siparişler'),
            onTap: () {
              Navigator.pop(context);
              unawaited(Navigator.pushNamed(
                context,
                CustomRoute.operasyonGecmis.path,
              ));
            },
          ),
        ],
      ),
    );
  }
}
