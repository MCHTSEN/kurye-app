import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/kurye/kurye_providers.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/workbench_split_view.dart';

class KuryeYonetimPage extends ConsumerStatefulWidget {
  const KuryeYonetimPage({super.key});

  @override
  ConsumerState<KuryeYonetimPage> createState() => _KuryeYonetimPageState();
}

class _KuryeYonetimPageState extends ConsumerState<KuryeYonetimPage> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _telefonController = TextEditingController();
  final _plakaController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String? _editingId;
  bool _isSubmitting = false;

  // History filter state
  String? _historyKuryeId;
  _HistoryPeriod _historyPeriod = _HistoryPeriod.last30Days;

  @override
  void dispose() {
    _adController.dispose();
    _telefonController.dispose();
    _plakaController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _populateForm(Kurye kurye) {
    setState(() {
      _editingId = kurye.id;
      _historyKuryeId = kurye.id;
      _adController.text = kurye.ad;
      _telefonController.text = kurye.telefon ?? '';
      _plakaController.text = kurye.plaka ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _adController.clear();
      _telefonController.clear();
      _plakaController.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(kuryeRepositoryProvider);

      final kurye = Kurye(
        id: _editingId ?? '',
        ad: _adController.text.trim(),
        telefon: _telefonController.text.trim().isNotEmpty
            ? _telefonController.text.trim()
            : null,
        plaka: _plakaController.text.trim().isNotEmpty
            ? _plakaController.text.trim()
            : null,
      );

      if (_editingId != null) {
        await repo.update(kurye);
      } else {
        await repo.create(kurye);
      }

      ref.invalidate(kuryeListProvider);
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingId != null ? 'Kurye güncellendi' : 'Kurye oluşturuldu',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(kuryeListProvider);
    final isDesktop = layoutTypeOf(context) == LayoutType.desktop;

    return ResponsiveScaffold(
      title: 'Kurye Yönetimi',
      currentRoute: CustomRoute.kuryeYonetim,
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      showMobileDrawer: false,
      body: Shortcuts(
        shortcuts: isDesktop
            ? const {
                SingleActivator(LogicalKeyboardKey.slash): _FocusSearchIntent(),
                SingleActivator(LogicalKeyboardKey.escape):
                    _ClearSelectionIntent(),
              }
            : const {},
        child: Actions(
          actions: {
            _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
              onInvoke: (_) {
                _searchFocusNode.requestFocus();
                return null;
              },
            ),
            _ClearSelectionIntent: CallbackAction<_ClearSelectionIntent>(
              onInvoke: (_) {
                _clearForm();
                return null;
              },
            ),
          },
          child: WorkbenchSplitView(
            header: listAsync.maybeWhen(
              data: _buildHeader,
              orElse: () => null,
            ),
            editorPane: Column(
              children: [
                _buildEditorPane(),
                if (_historyKuryeId != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Expanded(child: _buildHistoryPane()),
                ],
              ],
            ),
            contentPane: listAsync.when(
              data: _buildListPane,
              loading: () => const AppSectionCard(
                title: 'Kuryeler',
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => AppSectionCard(
                title: 'Kuryeler',
                child: Text('Hata: $e'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Kurye> list) {
    final isMobile = layoutTypeOf(context) == LayoutType.mobile;
    final activeCount = list.where((item) => item.isActive).length;
    final onlineCount = list.where((item) => item.isOnline).length;

    return Container(
      padding: ProjectPadding.all.normal,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _HeaderMetric(
                label: 'Toplam Kurye',
                value: '${list.length}',
                accentColor: AppColors.primary,
              ),
              _HeaderMetric(
                label: 'Aktif',
                value: '$activeCount',
                accentColor: AppColors.secondary,
              ),
              _HeaderMetric(
                label: 'Online',
                value: '$onlineCount',
                accentColor: AppColors.primary,
              ),
            ],
          ),
          if (!isMobile) const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: isMobile ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              _editingId == null ? 'Yeni kayıt modu' : 'Düzenleme modu açık',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorPane() {
    return AppSectionCard(
      title: _editingId != null ? 'Kurye Düzenle' : 'Yeni Kurye',
      description: 'Form solda sabit, liste sağda hız odaklı taranır.',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(labelText: 'Ad *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _telefonController,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _plakaController,
                decoration: const InputDecoration(labelText: 'Plaka'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppPrimaryButton(
                      label: _editingId != null ? 'Güncelle' : 'Kaydet',
                      onPressed: _onSubmit,
                      isLoading: _isSubmitting,
                    ),
                  ),
                  if (_editingId != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearForm,
                        child: const Text('İptal'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPane() {
    final now = DateTime.now();
    final startDate = switch (_historyPeriod) {
      _HistoryPeriod.today => DateTime(now.year, now.month, now.day),
      _HistoryPeriod.last7Days => now.subtract(const Duration(days: 7)),
      _HistoryPeriod.last30Days => now.subtract(const Duration(days: 30)),
      _HistoryPeriod.last90Days => now.subtract(const Duration(days: 90)),
      _HistoryPeriod.all => null,
    };

    final historyAsync = ref.watch(
      siparisHistoryProvider(
        kuryeId: _historyKuryeId,
        startDate: startDate,
      ),
    );

    // Resolve names for display.
    final ugramaListAsync = ref.watch(ugramaListProvider);
    final musteriListAsync = ref.watch(musteriListProvider);
    final ugramaMap = <String, String>{};
    if (ugramaListAsync case AsyncData(value: final ugramalar)) {
      for (final u in ugramalar) {
        ugramaMap[u.id] = u.ugramaAdi;
      }
    }
    final musteriMap = <String, String>{};
    if (musteriListAsync case AsyncData(value: final musteriler)) {
      for (final m in musteriler) {
        musteriMap[m.id] = m.firmaKisaAd;
      }
    }

    return AppSectionCard(
      title: 'Geçmiş İşler',
      trailing: DropdownButton<_HistoryPeriod>(
        value: _historyPeriod,
        underline: const SizedBox.shrink(),
        isDense: true,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        items: const [
          DropdownMenuItem(
            value: _HistoryPeriod.today,
            child: Text('Bugün'),
          ),
          DropdownMenuItem(
            value: _HistoryPeriod.last7Days,
            child: Text('Son 7 Gün'),
          ),
          DropdownMenuItem(
            value: _HistoryPeriod.last30Days,
            child: Text('Son 30 Gün'),
          ),
          DropdownMenuItem(
            value: _HistoryPeriod.last90Days,
            child: Text('Son 90 Gün'),
          ),
          DropdownMenuItem(
            value: _HistoryPeriod.all,
            child: Text('Tümü'),
          ),
        ],
        onChanged: (v) {
          if (v != null) setState(() => _historyPeriod = v);
        },
      ),
      child: historyAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Bu dönemde tamamlanmış iş yok.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          final completedCount = orders
              .where((s) => s.durum == SiparisDurum.tamamlandi)
              .length;
          final cancelledCount = orders
              .where((s) => s.durum == SiparisDurum.iptal)
              .length;
          final totalRevenue = orders
              .where((s) => s.durum == SiparisDurum.tamamlandi)
              .fold<double>(0, (sum, s) => sum + (s.ucret ?? 0));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats summary
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _StatChip(
                    label: 'Tamamlanan',
                    value: '$completedCount',
                    color: AppColors.secondary,
                  ),
                  if (cancelledCount > 0)
                    _StatChip(
                      label: 'İptal',
                      value: '$cancelledCount',
                      color: Colors.red,
                    ),
                  _StatChip(
                    label: 'Toplam Ciro',
                    value: '${totalRevenue.toStringAsFixed(0)} TL',
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              // Order list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final s = orders[index];
                  final musteri = musteriMap[s.musteriId] ?? '-';
                  final cikis = ugramaMap[s.cikisId] ?? '-';
                  final ugrama = ugramaMap[s.ugramaId] ?? '-';
                  final route = StringBuffer('$cikis → $ugrama');
                  if (s.ugrama1Id != null) {
                    route.write(
                      ' → ${ugramaMap[s.ugrama1Id!] ?? '-'}',
                    );
                  }
                  final durum = s.durum == SiparisDurum.tamamlandi
                      ? 'Tamamlandı'
                      : 'İptal';
                  final durumColor = s.durum == SiparisDurum.tamamlandi
                      ? AppColors.secondary
                      : Colors.red;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                musteri,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                route.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            s.createdAt != null
                                ? '${s.createdAt!.day.toString().padLeft(2, '0')}.${s.createdAt!.month.toString().padLeft(2, '0')} ${s.createdAt!.hour.toString().padLeft(2, '0')}:${s.createdAt!.minute.toString().padLeft(2, '0')}'
                                : '-',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            s.ucret != null
                                ? '${s.ucret!.toStringAsFixed(0)} TL'
                                : '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: durumColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            durum,
                            style: TextStyle(
                              color: durumColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Hata: $e'),
      ),
    );
  }

  Widget _buildListPane(List<Kurye> list) {
    final isMobile = layoutTypeOf(context) == LayoutType.mobile;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = list.where((kurye) {
      if (query.isEmpty) {
        return true;
      }

      return kurye.ad.toLowerCase().contains(query) ||
          (kurye.telefon?.toLowerCase().contains(query) ?? false) ||
          (kurye.plaka?.toLowerCase().contains(query) ?? false);
    }).toList();

    final listView = filtered.isEmpty
        ? const Text('Henüz kurye yok.')
        : ListView.separated(
            shrinkWrap: isMobile,
            physics: isMobile ? const NeverScrollableScrollPhysics() : null,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final kurye = filtered[index];
              final isSelected = kurye.id == _editingId;
              final isHistoryTarget = kurye.id == _historyKuryeId;
              return Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(kurye.ad),
                  subtitle: Text(
                    [
                      kurye.telefon ?? 'Telefon yok',
                      kurye.plaka ?? 'Plaka yok',
                    ].join(' · '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isHistoryTarget)
                        const Icon(
                          Icons.history_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      const SizedBox(width: 4),
                      Icon(
                        kurye.isOnline ? Icons.wifi : Icons.wifi_off,
                        size: 16,
                        color: kurye.isOnline
                            ? AppColors.secondary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: kurye.isActive
                            ? AppColors.secondary
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                  onTap: () => _populateForm(kurye),
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          );

    final card = AppSectionCard(
      title: 'Kuryeler (${filtered.length})',
      trailing: SizedBox(
        width: 260,
        child: TextField(
          focusNode: _searchFocusNode,
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Ara... (/)',
            prefixIcon: Icon(Icons.search_rounded),
            isDense: true,
          ),
        ),
      ),
      child: listView,
    );

    return isMobile ? card : SizedBox.expand(child: card);
  }
}

enum _HistoryPeriod { today, last7Days, last30Days, last90Days, all }

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _ClearSelectionIntent extends Intent {
  const _ClearSelectionIntent();
}
