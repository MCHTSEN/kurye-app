import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';

class MusteriGecmisPage extends ConsumerStatefulWidget {
  const MusteriGecmisPage({super.key});

  @override
  ConsumerState<MusteriGecmisPage> createState() => _MusteriGecmisPageState();
}

class _MusteriGecmisPageState extends ConsumerState<MusteriGecmisPage> {
  DateTimeRange? _selectedRange;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _selectedRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (range != null) {
      setState(() => _selectedRange = range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return ResponsiveScaffold(
      title: 'Geçmiş Siparişler',
      currentRoute: CustomRoute.musteriGecmis,
      navItems: musteriNavItems,
      headerSubtitle: 'Müşteri',
      onLogout: logoutCallback(ref),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null || profile.musteriId == null) {
            return const Center(
              child: Text('Müşteri bilgisi bulunamadı.'),
            );
          }
          return _buildContent(profile.musteriId!);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildContent(String musteriId) {
    final ordersAsync = ref.watch(siparisListByMusteriProvider(musteriId));
    final ugramaAsync = ref.watch(ugramaListByMusteriProvider(musteriId));

    // Build ugrama name map.
    final ugramaMap = <String, String>{};
    if (ugramaAsync case AsyncData(value: final ugramalar)) {
      for (final u in ugramalar) {
        ugramaMap[u.id] = u.ugramaAdi;
      }
    }

    final isDesktop = layoutTypeOf(context) != LayoutType.mobile;

    return ListView(
      padding: isDesktop ? ProjectPadding.all.large : ProjectPadding.all.normal,
      children: [
        // Date range filter
        AppSectionCard(
          title: 'Tarih Filtresi',
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedRange != null
                      ? '${_formatDate(_selectedRange!.start)} — '
                          '${_formatDate(_selectedRange!.end)}'
                      : 'Tüm tarihler',
                ),
              ),
              TextButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range),
                label: const Text('Filtrele'),
              ),
              if (_selectedRange != null)
                IconButton(
                  onPressed: () => setState(() => _selectedRange = null),
                  icon: const Icon(Icons.clear),
                  tooltip: 'Filtreyi temizle',
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Orders list
        ordersAsync.when(
          data: (orders) {
            // Filter to completed only.
            var completed = orders
                .where((s) => s.durum == SiparisDurum.tamamlandi)
                .toList();

            // Apply date range filter.
            if (_selectedRange != null) {
              final start = _selectedRange!.start;
              final end = _selectedRange!.end
                  .add(const Duration(days: 1)); // inclusive end
              completed = completed.where((s) {
                final dt = s.createdAt;
                if (dt == null) return false;
                return dt.isAfter(start) && dt.isBefore(end);
              }).toList();
            }

            // Sort newest first.
            completed.sort((a, b) {
              final aDate = a.createdAt ?? DateTime(2000);
              final bDate = b.createdAt ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });

            return AppSectionCard(
              title: 'Tamamlanan Siparişler (${completed.length})',
              child: completed.isEmpty
                  ? const Text('Tamamlanan sipariş bulunamadı.')
                  : Column(
                      children: completed
                          .map((s) => _buildOrderTile(s, ugramaMap))
                          .toList(),
                    ),
            );
          },
          loading: () => const AppSectionCard(
            title: 'Tamamlanan Siparişler',
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => AppSectionCard(
            title: 'Tamamlanan Siparişler',
            child: Text('Hata: $e'),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTile(Siparis siparis, Map<String, String> ugramaMap) {
    final cikisAdi = ugramaMap[siparis.cikisId] ?? siparis.cikisId;
    final ugramaAdi = ugramaMap[siparis.ugramaId] ?? siparis.ugramaId;

    return ListTile(
      title: Text('$cikisAdi → $ugramaAdi'),
      subtitle: Text(
        [
          if (siparis.ucret != null) '₺${siparis.ucret!.toStringAsFixed(2)}',
          if (siparis.createdAt != null) _formatDate(siparis.createdAt!),
        ].join(' • '),
      ),
      trailing: const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
}
