import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/navigation/logout_helper.dart';
import '../domain/dashboard_stats.dart';
import '../providers/dashboard_providers.dart';

class OperasyonDashboardPage extends ConsumerWidget {
  const OperasyonDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return ResponsiveScaffold(
      title: 'Dashboard',
      currentRoute: CustomRoute.operasyonDashboard,
      navItems: operasyonNavItems,
      headerTitle: 'Moto Kurye',
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      body: profileAsync.when(
        data: (profile) {
          final name = profile?.displayName ?? 'Operasyon';
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardStatsProvider);
              await ref.read(dashboardStatsProvider.future);
            },
            child: ResponsiveBuilder(
              mobile: _MobileDashboard(name: name),
              desktop: _DesktopDashboard(name: name),
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
// Mobile layout
// ---------------------------------------------------------------------------

class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        _WelcomeHeader(name: name, theme: theme),
        const SizedBox(height: AppSpacing.md),
        const _CiroAnaliziCard(),
        const SizedBox(height: AppSpacing.md),
        const _KuryePerformansCard(),
        const SizedBox(height: AppSpacing.md),
        const _AktifKuryelerCard(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop layout
// ---------------------------------------------------------------------------

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return SingleChildScrollView(
      padding: ProjectPadding.all.large,
      child: ContentConstraint(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WelcomeHeader(name: name, theme: theme),
            const SizedBox(height: AppSpacing.lg),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CiroAnaliziCard()),
                SizedBox(width: AppSpacing.lg),
                Expanded(child: _KuryePerformansCard()),
                SizedBox(width: AppSpacing.lg),
                Expanded(child: _AktifKuryelerCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome header
// ---------------------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name, required this.theme});

  final String name;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hoş geldiniz, $name', style: theme.textTheme.h4),
                Text(
                  'Operasyon kontrol paneli',
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
        ],
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
    final theme = ShadTheme.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return ShadCard(
      title: Row(
        children: [
          Icon(Icons.trending_up, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('Ciro Analizi', style: theme.textTheme.h4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: statsAsync.when(
          data: (stats) => _CiroContent(stats: stats, theme: theme),
          loading: _CardLoading.new,
          error: (e, _) => _CardError(message: e.toString()),
        ),
      ),
    );
  }
}

class _CiroContent extends StatelessWidget {
  const _CiroContent({required this.stats, required this.theme});

  final DashboardStats stats;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _RevenueCell(label: '3 Aylık', amount: stats.revenue3mo, theme: theme)),
            Expanded(child: _RevenueCell(label: '1 Aylık', amount: stats.revenue1mo, theme: theme)),
            Expanded(child: _RevenueCell(label: '1 Haftalık', amount: stats.revenue1wk, theme: theme)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Günlük Ortalama: ${_formatCurrency(stats.dailyAvg)}',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}

class _RevenueCell extends StatelessWidget {
  const _RevenueCell({
    required this.label,
    required this.amount,
    required this.theme,
  });

  final String label;
  final double amount;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.muted),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: theme.textTheme.h4,
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
    final theme = ShadTheme.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return ShadCard(
      title: Row(
        children: [
          Icon(Icons.speed, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('Kurye Performansı', style: theme.textTheme.h4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: statsAsync.when(
          data: (stats) => _KuryePerformansContent(stats: stats, theme: theme),
          loading: _CardLoading.new,
          error: (e, _) => _CardError(message: e.toString()),
        ),
      ),
    );
  }
}

class _KuryePerformansContent extends StatelessWidget {
  const _KuryePerformansContent({
    required this.stats,
    required this.theme,
  });

  final DashboardStats stats;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (stats.courierStats.isEmpty) {
      return Text('Veri yok', style: theme.textTheme.muted);
    }

    return Column(
      children: [
        for (final cs in stats.courierStats)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                ShadAvatar(
                  '',
                  size: const Size.square(28),
                  placeholder: Text(
                    cs.ad.isNotEmpty ? cs.ad[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(cs.ad, style: theme.textTheme.small)),
                ShadBadge.secondary(child: Text('Ay: ${cs.monthlyJobs}')),
                const SizedBox(width: 4),
                ShadBadge(child: Text('Bugün: ${cs.dailyJobs}')),
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
    final theme = ShadTheme.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return ShadCard(
      title: Row(
        children: [
          Icon(Icons.people, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('Aktif Kuryeler', style: theme.textTheme.h4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: statsAsync.when(
          data: (stats) => _AktifKuryelerContent(stats: stats, theme: theme),
          loading: _CardLoading.new,
          error: (e, _) => _CardError(message: e.toString()),
        ),
      ),
    );
  }
}

class _AktifKuryelerContent extends StatelessWidget {
  const _AktifKuryelerContent({required this.stats, required this.theme});

  final DashboardStats stats;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (stats.activeCourierCount == 0) {
      return Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: 8),
          Text('Aktif kurye yok', style: theme.textTheme.muted),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${stats.activeCourierCount}',
              style: theme.textTheme.h1.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text('aktif', style: theme.textTheme.muted),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final name in stats.activeCourierNames)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(name),
              ],
            ),
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
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ShadAlert.destructive(
      icon: const Icon(LucideIcons.circleAlert),
      title: const Text('Hata'),
      description: Text(message),
    );
  }
}
