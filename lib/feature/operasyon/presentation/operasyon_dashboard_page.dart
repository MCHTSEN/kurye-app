import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
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
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      showMobileDrawer: false,
      body: profileAsync.when(
        data: (profile) {
          final name = profile?.displayName ?? 'Operasyon';
          return RefreshIndicator(
            color: AppColors.primary,
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
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
    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        _WelcomeHeader(name: name),
        const SizedBox(height: AppSpacing.lg),
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
    return SingleChildScrollView(
      padding: ProjectPadding.all.large,
      child: ContentConstraint(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WelcomeHeader(name: name),
            const SizedBox(height: AppSpacing.lg),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _CiroAnaliziCard()),
                SizedBox(width: AppSpacing.md),
                Expanded(flex: 2, child: _KuryePerformansCard()),
                SizedBox(width: AppSpacing.md),
                Expanded(flex: 2, child: _AktifKuryelerCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome header — gradient card
// ---------------------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.dashboard_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hos geldiniz,',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Aktif',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    final statsAsync = ref.watch(dashboardStatsProvider);

    return ShadCard(
      padding: const EdgeInsets.all(20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.insights_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Ciro Analizi',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: statsAsync.when(
          data: (stats) => _CiroContent(stats: stats),
          loading: _CardLoading.new,
          error: (e, _) => _CardError(message: e.toString()),
        ),
      ),
    );
  }
}

class _CiroContent extends StatelessWidget {
  const _CiroContent({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _RevenueCell(
                      label: '3 Aylik',
                      amount: stats.revenue3mo,
                      isPrimary: true,
                    ),
                  ),
                  Expanded(
                    child: _RevenueCell(
                      label: '1 Aylik',
                      amount: stats.revenue1mo,
                      isPrimary: false,
                    ),
                  ),
                  Expanded(
                    child: _RevenueCell(
                      label: '1 Haftalik',
                      amount: stats.revenue1wk,
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gunluk Ortalama',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    _formatCurrency(stats.dailyAvg),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RevenueCell extends StatelessWidget {
  const _RevenueCell({
    required this.label,
    required this.amount,
    required this.isPrimary,
  });

  final String label;
  final double amount;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: isPrimary
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPrimary ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(amount),
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isPrimary ? AppColors.primary : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kurye Performansi card
// ---------------------------------------------------------------------------

class _KuryePerformansCard extends ConsumerWidget {
  const _KuryePerformansCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return ShadCard(
      padding: const EdgeInsets.all(20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sports_motorsports_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Kurye Performansi',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: statsAsync.when(
          data: (stats) => _KuryePerformansContent(stats: stats),
          loading: _CardLoading.new,
          error: (e, _) => _CardError(message: e.toString()),
        ),
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
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          'Henüz veri bulunamadı',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < stats.courierStats.length; i++) ...[
          _CourierPerformanceItem(cs: stats.courierStats[i]),
          if (i != stats.courierStats.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppColors.surfaceMid,
              ),
            ),
        ],
      ],
    );
  }
}

class _CourierPerformanceItem extends StatelessWidget {
  const _CourierPerformanceItem({required this.cs});

  final CourierStat cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                cs.ad.isNotEmpty ? cs.ad[0].toUpperCase() : '?',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cs.ad,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Kdv Dahil Performans',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Bugun: ${cs.dailyJobs}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ay: ${cs.monthlyJobs}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
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

    return ShadCard(
      padding: const EdgeInsets.all(20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.online_prediction_rounded,
              size: 20,
              color: AppColors.secondaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Aktif Kuryeler',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: statsAsync.when(
          data: (stats) => _AktifKuryelerContent(stats: stats),
          loading: _CardLoading.new,
          error: (e, _) => _CardError(message: e.toString()),
        ),
      ),
    );
  }
}

class _AktifKuryelerContent extends StatelessWidget {
  const _AktifKuryelerContent({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.activeCourierCount == 0) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded, size: 32, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              'Aktif kurye yok',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text(
                '${stats.activeCourierCount}',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'SAHADAKİ KURYE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final name in stats.activeCourierNames)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                _PulseDot(),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary.withValues(alpha: 1 - _controller.value),
            border: Border.all(
              color: AppColors.secondary,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

String _formatCurrency(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  // Add thousands separator.
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '$intPart,${parts[1]} TL';
}

class _CardLoading extends StatelessWidget {
  const _CardLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.circleAlert, size: 16, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
