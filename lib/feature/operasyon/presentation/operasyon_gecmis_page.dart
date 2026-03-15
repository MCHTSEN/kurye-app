import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

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
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/searchable_dropdown.dart';

final _log = Logger();

class OperasyonGecmisPage extends ConsumerStatefulWidget {
  const OperasyonGecmisPage({super.key});

  @override
  ConsumerState<OperasyonGecmisPage> createState() =>
      _OperasyonGecmisPageState();
}

class _OperasyonGecmisPageState extends ConsumerState<OperasyonGecmisPage> {
  // — Filter state —
  late DateTimeRange _dateRange;
  String? _filterMusteriId;
  String? _filterCikisId;
  String? _filterUgramaId;

  // — Edit panel state —
  Siparis? _selectedOrder;
  String? _editMusteriId;
  String? _editCikisId;
  String? _editUgramaId;
  String? _editDurum;
  final _editUcretController = TextEditingController();
  final _editNot1Controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 30)),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  @override
  void dispose() {
    _editUcretController.dispose();
    _editNot1Controller.dispose();
    super.dispose();
  }

  // ──────────── Filter helpers ────────────

  void _onFilterMusteriChanged(String? musteriId) {
    setState(() {
      _filterMusteriId = musteriId;
      _filterCikisId = null;
      _filterUgramaId = null;
    });
  }

  void _clearFilters() {
    final now = DateTime.now();
    setState(() {
      _dateRange = DateTimeRange(
        start: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 30)),
        end: DateTime(now.year, now.month, now.day),
      );
      _filterMusteriId = null;
      _filterCikisId = null;
      _filterUgramaId = null;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  // ──────────── Edit panel helpers ────────────

  void _selectOrder(Siparis order) {
    setState(() {
      _selectedOrder = order;
      _editMusteriId = order.musteriId;
      _editCikisId = order.cikisId;
      _editUgramaId = order.ugramaId;
      _editDurum = order.durum.value;
      _editUcretController.text = order.ucret != null
          ? order.ucret!.toStringAsFixed(2)
          : '';
      _editNot1Controller.text = order.not1 ?? '';
    });
  }

  void _clearEditPanel() {
    setState(() {
      _selectedOrder = null;
      _editMusteriId = null;
      _editCikisId = null;
      _editUgramaId = null;
      _editDurum = null;
      _editUcretController.clear();
      _editNot1Controller.clear();
    });
  }

  Future<void> _onSave() async {
    if (_selectedOrder == null) return;

    setState(() => _isSaving = true);

    try {
      final fields = <String, dynamic>{
        'musteri_id': _editMusteriId,
        'cikis_id': _editCikisId,
        'ugrama_id': _editUgramaId,
        'durum': _editDurum,
        'not1': _editNot1Controller.text.trim().isNotEmpty
            ? _editNot1Controller.text.trim()
            : null,
      };

      final parsedUcret = double.tryParse(_editUcretController.text);
      if (parsedUcret != null) {
        fields['ucret'] = parsedUcret;
      }

      await ref
          .read(siparisRepositoryProvider)
          .update(_selectedOrder!.id, fields);

      // Invalidate the history provider to refresh the table.
      ref.invalidate(siparisHistoryProvider);

      _clearEditPanel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sipariş güncellendi')),
        );
      }
    } on Exception catch (e) {
      _log.e('Order update failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _onIptal() async {
    if (_selectedOrder == null) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(siparisRepositoryProvider).update(
        _selectedOrder!.id,
        {'durum': SiparisDurum.iptal.value},
      );

      ref.invalidate(siparisHistoryProvider);
      _clearEditPanel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sipariş iptal edildi')),
        );
      }
    } on Exception catch (e) {
      _log.e('Order cancel failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ──────────── Build ────────────

  @override
  Widget build(BuildContext context) {
    // Watch history with current filter values.
    // Pass end of day for endDate to make the range inclusive.
    final endOfDay = DateTime(
      _dateRange.end.year,
      _dateRange.end.month,
      _dateRange.end.day,
      23,
      59,
      59,
    );

    final historyAsync = ref.watch(
      siparisHistoryProvider(
        startDate: _dateRange.start,
        endDate: endOfDay,
        musteriId: _filterMusteriId,
        cikisId: _filterCikisId,
        ugramaId: _filterUgramaId,
      ),
    );

    // Build name maps from list providers.
    final musteriListAsync = ref.watch(musteriListProvider);
    final ugramaListAsync = ref.watch(ugramaListProvider);
    final kuryeListAsync = ref.watch(kuryeListProvider);

    final musteriMap = <String, String>{};
    if (musteriListAsync case AsyncData(value: final musteriler)) {
      for (final m in musteriler) {
        musteriMap[m.id] = m.firmaKisaAd;
      }
    }

    final ugramaMap = <String, String>{};
    if (ugramaListAsync case AsyncData(value: final ugramalar)) {
      for (final u in ugramalar) {
        ugramaMap[u.id] = u.ugramaAdi;
      }
    }

    final kuryeMap = <String, String>{};
    if (kuryeListAsync case AsyncData(value: final kuryeler)) {
      for (final k in kuryeler) {
        kuryeMap[k.id] = k.ad;
      }
    }

    return ResponsiveScaffold(
      title: 'Geçmiş Siparişler',
      currentRoute: CustomRoute.operasyonGecmis,
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      showMobileDrawer: false,
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          // Revenue total
          _buildRevenueCard(historyAsync),
          const SizedBox(height: AppSpacing.md),
          // Edit panel (visible only when a row is selected)
          if (_selectedOrder != null)
            _buildEditPanel(musteriListAsync, ugramaListAsync),
          if (_selectedOrder != null) const SizedBox(height: AppSpacing.md),
          // Filter bar
          _buildFilterBar(musteriListAsync, ugramaListAsync),
          const SizedBox(height: AppSpacing.md),
          // Data table
          _buildDataTable(
            historyAsync,
            musteriMap: musteriMap,
            ugramaMap: ugramaMap,
            kuryeMap: kuryeMap,
          ),
        ],
      ),
    );
  }

  // ──────────── Revenue card ────────────

  Widget _buildRevenueCard(AsyncValue<List<Siparis>> historyAsync) {
    final total = historyAsync.maybeWhen(
      data: (orders) => orders.fold<double>(
        0,
        (sum, s) => sum + (s.ucret ?? 0),
      ),
      orElse: () => 0.0,
    );

    return AppSectionCard(
      title: 'Toplam Ciro',
      icon: Icons.trending_up_rounded,
      accentColor: AppColors.primary,
      child: Text(
        key: const Key('revenue_total'),
        '${total.toStringAsFixed(2)} TL',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ──────────── Edit panel ────────────

  Widget _buildEditPanel(
    AsyncValue<List<Musteri>> musteriListAsync,
    AsyncValue<List<Ugrama>> ugramaListAsync,
  ) {
    final musteriler = musteriListAsync is AsyncData<List<Musteri>>
        ? musteriListAsync.value
        : <Musteri>[];
    final ugramalar = ugramaListAsync is AsyncData<List<Ugrama>>
        ? ugramaListAsync.value
        : <Ugrama>[];

    // All stops shown — operasyon sees the full ugrama pool.
    // Müşteri-based stop filtering will use the köprü table (S02).
    final filteredStops = ugramalar;

    final musteriItems = musteriler
        .map((m) => (value: m.id, label: m.firmaKisaAd))
        .toList();

    final stopItems = filteredStops
        .map((u) => (value: u.id, label: u.ugramaAdi))
        .toList();

    final durumItems = [
      SiparisDurum.tamamlandi,
      SiparisDurum.iptal,
    ].map((d) => (value: d.value, label: d.value)).toList();

    return AppSectionCard(
      title: 'Sipariş Düzenle',
      child: Column(
        children: [
          SearchableDropdown<String>(
            key: const Key('edit_musteri_dropdown'),
            value: _editMusteriId,
            label: 'Müşteri',
            placeholder: 'Müşteri Seç',
            searchPlaceholder: 'Müşteri ara...',
            items: musteriItems,
            onChanged: (v) {
              setState(() {
                _editMusteriId = v;
                _editCikisId = null;
                _editUgramaId = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          SearchableDropdown<String>(
            key: const Key('edit_cikis_dropdown'),
            value: _editCikisId,
            label: 'Çıkış',
            placeholder: 'Çıkış Seç',
            searchPlaceholder: 'Uğrama ara...',
            items: stopItems,
            onChanged: (v) => setState(() => _editCikisId = v),
          ),
          const SizedBox(height: AppSpacing.xs),
          SearchableDropdown<String>(
            key: const Key('edit_ugrama_dropdown'),
            value: _editUgramaId,
            label: 'Uğrama',
            placeholder: 'Uğrama Seç',
            searchPlaceholder: 'Uğrama ara...',
            items: stopItems,
            onChanged: (v) => setState(() => _editUgramaId = v),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            key: const Key('edit_ucret_field'),
            controller: _editUcretController,
            decoration: const InputDecoration(labelText: 'Ücret (₺)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.xs),
          SearchableDropdown<String>(
            key: const Key('edit_durum_dropdown'),
            value: _editDurum,
            label: 'Durum',
            placeholder: 'Durum Seç',
            items: durumItems,
            onChanged: (v) => setState(() => _editDurum = v),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            key: const Key('edit_not1_field'),
            controller: _editNot1Controller,
            decoration: const InputDecoration(labelText: 'Not1'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  key: const Key('edit_save_button'),
                  label: 'Kaydet',
                  onPressed: _isSaving ? null : _onSave,
                  isLoading: _isSaving,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppPrimaryButton(
                  key: const Key('edit_iptal_button'),
                  label: 'İptal Et',
                  onPressed: _isSaving ? null : _onIptal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            key: const Key('edit_close_button'),
            onPressed: _clearEditPanel,
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // ──────────── Filter bar ────────────

  Widget _buildFilterBar(
    AsyncValue<List<Musteri>> musteriListAsync,
    AsyncValue<List<Ugrama>> ugramaListAsync,
  ) {
    final musteriler = musteriListAsync is AsyncData<List<Musteri>>
        ? musteriListAsync.value
        : <Musteri>[];
    final ugramalar = ugramaListAsync is AsyncData<List<Ugrama>>
        ? ugramaListAsync.value
        : <Ugrama>[];

    // All stops shown — operasyon sees the full ugrama pool.
    final filteredStops = ugramalar;

    return AppSectionCard(
      title: 'Filtreler',
      child: Column(
        children: [
          // Date range row
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatDate(_dateRange.start)} — '
                  '${_formatDate(_dateRange.end)}',
                ),
              ),
              TextButton.icon(
                key: const Key('filter_date_button'),
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range),
                label: const Text('Tarih'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Müşteri filter
          SearchableDropdown<String>(
            key: const Key('filter_musteri_dropdown'),
            value: _filterMusteriId,
            label: 'Müşteri',
            placeholder: 'Tümü',
            searchPlaceholder: 'Müşteri ara...',
            items: musteriler
                .map((m) => (value: m.id, label: m.firmaKisaAd))
                .toList(),
            onChanged: _onFilterMusteriChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          // Çıkış filter
          SearchableDropdown<String>(
            key: const Key('filter_cikis_dropdown'),
            value: _filterCikisId,
            label: 'Çıkış',
            placeholder: 'Tümü',
            searchPlaceholder: 'Uğrama ara...',
            items: filteredStops
                .map((u) => (value: u.id, label: u.ugramaAdi))
                .toList(),
            onChanged: (v) => setState(() => _filterCikisId = v),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Uğrama filter
          SearchableDropdown<String>(
            key: const Key('filter_ugrama_dropdown'),
            value: _filterUgramaId,
            label: 'Uğrama',
            placeholder: 'Tümü',
            searchPlaceholder: 'Uğrama ara...',
            items: filteredStops
                .map((u) => (value: u.id, label: u.ugramaAdi))
                .toList(),
            onChanged: (v) => setState(() => _filterUgramaId = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('filter_clear_button'),
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Temizle'),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────── Data table ────────────

  Widget _buildDataTable(
    AsyncValue<List<Siparis>> historyAsync, {
    required Map<String, String> musteriMap,
    required Map<String, String> ugramaMap,
    required Map<String, String> kuryeMap,
  }) {
    return historyAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const AppSectionCard(
            title: 'Siparişler',
            child: Text('Sipariş bulunamadı.'),
          );
        }

        return AppSectionCard(
          title: 'Siparişler (${orders.length})',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              key: const Key('history_data_table'),
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text('Tarih')),
                DataColumn(label: Text('Müşteri')),
                DataColumn(label: Text('Çıkış')),
                DataColumn(label: Text('Uğrama')),
                DataColumn(label: Text('Kurye')),
                DataColumn(label: Text('Ücret'), numeric: true),
                DataColumn(label: Text('Durum')),
              ],
              rows: orders.map((s) {
                final isSelected = _selectedOrder?.id == s.id;
                return DataRow(
                  key: ValueKey('row_${s.id}'),
                  selected: isSelected,
                  onSelectChanged: (_) => _selectOrder(s),
                  cells: [
                    DataCell(
                      Text(
                        s.createdAt != null ? _formatDate(s.createdAt!) : '-',
                      ),
                    ),
                    DataCell(Text(musteriMap[s.musteriId] ?? s.musteriId)),
                    DataCell(Text(ugramaMap[s.cikisId] ?? s.cikisId)),
                    DataCell(Text(ugramaMap[s.ugramaId] ?? s.ugramaId)),
                    DataCell(
                      Text(
                        s.kuryeId != null
                            ? (kuryeMap[s.kuryeId!] ?? s.kuryeId!)
                            : '-',
                      ),
                    ),
                    DataCell(
                      Text(
                        s.ucret != null
                            ? '₺${s.ucret!.toStringAsFixed(2)}'
                            : '-',
                      ),
                    ),
                    DataCell(Text(s.durum.value)),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const AppSectionCard(
        title: 'Siparişler',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppSectionCard(
        title: 'Siparişler',
        child: Text('Hata: $e'),
      ),
    );
  }

  // ──────────── Helpers ────────────

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
}
