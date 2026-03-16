import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/searchable_dropdown.dart';
import '../../../product/widgets/workbench_split_view.dart';

final _log = Logger();

class OperasyonGecmisPage extends ConsumerStatefulWidget {
  const OperasyonGecmisPage({super.key});

  @override
  ConsumerState<OperasyonGecmisPage> createState() => _OperasyonGecmisPageState();
}

class _OperasyonGecmisPageState extends ConsumerState<OperasyonGecmisPage> {
  // — Filter state —
  late DateTimeRange _dateRange;
  String? _filterMusteriId;
  String? _filterCikisId;
  String? _filterUgramaId;
  String? _statusFilter;

  // — Search state —
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

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
    _searchController.dispose();
    _searchFocusNode.dispose();
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
      _statusFilter = null;
      _searchController.clear();
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

  List<Siparis> _applyLocalFilters(
    List<Siparis> orders, {
    required Map<String, String> musteriMap,
    required Map<String, String> ugramaMap,
    required Map<String, String> kuryeMap,
  }) {
    final query = _searchController.text.trim().toLowerCase();

    return orders.where((order) {
      if (_statusFilter != null && order.durum.value != _statusFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchableText = <String>[
        order.id,
        musteriMap[order.musteriId] ?? order.musteriId,
        ugramaMap[order.cikisId] ?? order.cikisId,
        ugramaMap[order.ugramaId] ?? order.ugramaId,
        if (order.kuryeId != null) kuryeMap[order.kuryeId!] ?? order.kuryeId!,
        order.durum.value,
        order.not1 ?? '',
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  // ──────────── Edit panel helpers ────────────

  void _selectOrder(Siparis order) {
    setState(() {
      _selectedOrder = order;
      _editMusteriId = order.musteriId;
      _editCikisId = order.cikisId;
      _editUgramaId = order.ugramaId;
      _editDurum = order.durum.value;
      _editUcretController.text = order.ucret != null ? order.ucret!.toStringAsFixed(2) : '';
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
        'not1': _editNot1Controller.text.trim().isNotEmpty ? _editNot1Controller.text.trim() : null,
      };

      final parsedUcret = double.tryParse(_editUcretController.text);
      if (parsedUcret != null) {
        fields['ucret'] = parsedUcret;
      }

      await ref.read(siparisRepositoryProvider).update(_selectedOrder!.id, fields);

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
    final isDesktop = layoutTypeOf(context) == LayoutType.desktop;

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

    final filteredHistoryAsync = historyAsync.whenData(
      (orders) => _applyLocalFilters(
        orders,
        musteriMap: musteriMap,
        ugramaMap: ugramaMap,
        kuryeMap: kuryeMap,
      ),
    );

    if (filteredHistoryAsync case AsyncData(
      value: final orders,
    ) when _selectedOrder != null && orders.every((item) => item.id != _selectedOrder!.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedOrder != null) {
          _clearEditPanel();
        }
      });
    }

    return ResponsiveScaffold(
      title: 'Geçmiş Siparişler',
      currentRoute: CustomRoute.operasyonGecmis,
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      showMobileDrawer: false,
      body: Shortcuts(
        shortcuts: isDesktop
            ? const {
                SingleActivator(LogicalKeyboardKey.slash): _FocusHistorySearchIntent(),
                SingleActivator(LogicalKeyboardKey.escape): _ClearHistorySelectionIntent(),
              }
            : const {},
        child: Actions(
          actions: {
            _FocusHistorySearchIntent: CallbackAction<_FocusHistorySearchIntent>(
              onInvoke: (_) {
                _searchFocusNode.requestFocus();
                return null;
              },
            ),
            _ClearHistorySelectionIntent: CallbackAction<_ClearHistorySelectionIntent>(
              onInvoke: (_) {
                _clearEditPanel();
                return null;
              },
            ),
          },
          child: isDesktop
              ? WorkbenchSplitView(
                  header: switch (filteredHistoryAsync) {
                    AsyncData(value: final orders) => _buildDesktopHeader(
                      orders,
                    ),
                    _ => null,
                  },
                  editorPane: _buildDesktopEditorPane(
                    musteriListAsync,
                    ugramaListAsync,
                  ),
                  contentPane: ListView(
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      _buildSearchAndStatusCard(historyAsync),
                      const SizedBox(height: AppSpacing.md),
                      _buildFilterBar(musteriListAsync, ugramaListAsync),
                      const SizedBox(height: AppSpacing.md),
                      _buildDataTableCard(
                        filteredHistoryAsync,
                        musteriMap: musteriMap,
                        ugramaMap: ugramaMap,
                        kuryeMap: kuryeMap,
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: ProjectPadding.all.normal,
                  children: [
                    _buildRevenueCard(filteredHistoryAsync),
                    const SizedBox(height: AppSpacing.md),
                    if (_selectedOrder != null) _buildEditPanel(musteriListAsync, ugramaListAsync),
                    if (_selectedOrder != null) const SizedBox(height: AppSpacing.md),
                    _buildSearchAndStatusCard(historyAsync),
                    const SizedBox(height: AppSpacing.md),
                    _buildFilterBar(musteriListAsync, ugramaListAsync),
                    const SizedBox(height: AppSpacing.md),
                    _buildDataTableCard(
                      filteredHistoryAsync,
                      musteriMap: musteriMap,
                      ugramaMap: ugramaMap,
                      kuryeMap: kuryeMap,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(List<Siparis> orders) {
    final total = orders.fold<double>(
      0,
      (sum, item) => sum + (item.ucret ?? 0),
    );
    final completedCount = orders.where((item) => item.durum == SiparisDurum.tamamlandi).length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B41),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          _buildHeaderMetric('GÖRÜNEN SİPARİŞ', '${orders.length}', const Color(0xFF6366F1)),
          const SizedBox(width: 32),
          _buildHeaderMetric('TAMAMLANAN', '$completedCount', const Color(0xFF10B981)),
          const SizedBox(width: 32),
          _buildHeaderMetric(
            'TOPLAM CİRO',
            '₺${total.toStringAsFixed(2)}',
            const Color(0xFFF59E0B),
          ),
          const Spacer(),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SİSTEM AKTİF',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '/ arama, Esc kapatır',
                style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ],
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
        '₺${total.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDesktopEditorPane(
    AsyncValue<List<Musteri>> musteriListAsync,
    AsyncValue<List<Ugrama>> ugramaListAsync,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _buildSelectionSummaryCard(),
        const SizedBox(height: AppSpacing.md),
        if (_selectedOrder == null)
          const AppSectionCard(
            title: 'Sipariş Detayı',
            description: 'Tablodan bir sipariş seçildiğinde düzenleme paneli burada açılır.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sağ panel yerine burada sabit detay alanı kullanılır.'),
                SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Chip(label: Text('Esc kapatır')),
                    Chip(label: Text('/ arama')),
                  ],
                ),
              ],
            ),
          )
        else
          _buildEditPanel(musteriListAsync, ugramaListAsync),
      ],
    );
  }

  Widget _buildSelectionSummaryCard() {
    final selected = _selectedOrder;

    return AppSectionCard(
      title: 'Seçili Sipariş',
      icon: Icons.receipt_long_rounded,
      accentColor: AppColors.secondary,
      child: selected == null
          ? const Text(
              'Henüz sipariş seçilmedi. Tablo üzerinden bir kayıt seçin.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sipariş ID: ${selected.id}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Durum: ${selected.durum.value}'),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  selected.ucret != null
                      ? 'Ücret: ₺${selected.ucret!.toStringAsFixed(2)}'
                      : 'Ücret henüz girilmedi',
                ),
              ],
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

    final filteredStops = ugramalar;

    final musteriItems = musteriler.map((m) => (value: m.id, label: m.firmaKisaAd)).toList();

    final stopItems = filteredStops.map((u) => (value: u.id, label: u.ugramaAdi)).toList();

    final durumItems = [
      SiparisDurum.tamamlandi,
      SiparisDurum.iptal,
    ].map((d) => (value: d.value, label: d.value)).toList();

    return AppSectionCard(
      title: 'Sipariş Düzenle',
      description: 'Seçili siparişi hızlıca güncelleyin ya da iptal edin.',
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

  Widget _buildSearchAndStatusCard(AsyncValue<List<Siparis>> historyAsync) {
    final counts = historyAsync.maybeWhen(
      data: (orders) {
        return <String, int>{
          SiparisDurum.tamamlandi.value: orders
              .where((item) => item.durum == SiparisDurum.tamamlandi)
              .length,
          SiparisDurum.iptal.value: orders.where((item) => item.durum == SiparisDurum.iptal).length,
          SiparisDurum.devamEdiyor.value: orders
              .where((item) => item.durum == SiparisDurum.devamEdiyor)
              .length,
          SiparisDurum.kuryeBekliyor.value: orders
              .where((item) => item.durum == SiparisDurum.kuryeBekliyor)
              .length,
        };
      },
      orElse: () => const <String, int>{},
    );

    return AppSectionCard(
      title: 'Hızlı Arama',
      description: 'Sipariş ID, müşteri, uğrama, kurye veya not ile filtreleyin.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('history_search_field'),
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Sipariş, müşteri, uğrama ya da kurye ara',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildStatusChip(label: 'Tümü', value: null),
              _buildStatusChip(
                label: 'Tamamlandı',
                value: SiparisDurum.tamamlandi.value,
                count: counts[SiparisDurum.tamamlandi.value] ?? 0,
              ),
              _buildStatusChip(
                label: 'İptal',
                value: SiparisDurum.iptal.value,
                count: counts[SiparisDurum.iptal.value] ?? 0,
              ),
              _buildStatusChip(
                label: 'Devam Eden',
                value: SiparisDurum.devamEdiyor.value,
                count: counts[SiparisDurum.devamEdiyor.value] ?? 0,
              ),
              _buildStatusChip(
                label: 'Kurye Bekliyor',
                value: SiparisDurum.kuryeBekliyor.value,
                count: counts[SiparisDurum.kuryeBekliyor.value] ?? 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required String? value,
    int? count,
  }) {
    final isSelected = _statusFilter == value;
    final chipLabel = count == null ? label : '$label ($count)';

    return FilterChip(
      selected: isSelected,
      label: Text(chipLabel),
      selectedColor: AppColors.primary.withValues(alpha: 0.14),
      checkmarkColor: AppColors.primary,
      onSelected: (_) {
        setState(() {
          _statusFilter = value;
        });
      },
    );
  }

  // ──────────── Filter bar ────────────

  Widget _buildFilterBar(
    AsyncValue<List<Musteri>> musteriListAsync,
    AsyncValue<List<Ugrama>> ugramaListAsync,
  ) {
    final musteriler = musteriListAsync.maybeWhen(data: (d) => d, orElse: () => <Musteri>[]);
    final ugramalar = ugramaListAsync.maybeWhen(data: (d) => d, orElse: () => <Ugrama>[]);

    return _PremiumCard(
      title: 'FİLTRELER',
      icon: Icons.filter_list_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;

          final dateField = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TARİH ARALIĞI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateRange,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_formatDate(_dateRange.start)} - ${_formatDate(_dateRange.end)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

          final musteriField = SearchableDropdown<String>(
            key: const Key('filter_musteri_dropdown'),
            value: _filterMusteriId,
            label: 'MÜŞTERİ',
            placeholder: 'Hepsi',
            items: musteriler.map((m) => (value: m.id, label: m.firmaKisaAd)).toList(),
            onChanged: _onFilterMusteriChanged,
          );

          final guzergahField = SearchableDropdown<String>(
            value: _filterCikisId,
            label: 'GÜZERGAH',
            placeholder: 'Hepsi',
            items: ugramalar.map((u) => (value: u.id, label: u.ugramaAdi)).toList(),
            onChanged: (v) => setState(() => _filterCikisId = v),
          );

          final clearButton = SizedBox(
            width: 56,
            height: 48,
            child: ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Icon(Icons.refresh_rounded),
            ),
          );

          if (isCompact) {
            return Column(
              children: [
                dateField,
                const SizedBox(height: 16),
                musteriField,
                const SizedBox(height: 16),
                guzergahField,
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight, child: clearButton),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: dateField),
              const SizedBox(width: 16),
              Expanded(child: musteriField),
              const SizedBox(width: 16),
              Expanded(child: guzergahField),
              const SizedBox(width: 16),
              clearButton,
            ],
          );
        },
      ),
    );
  }

  // ──────────── Data table ────────────

  Widget _buildDataTableCard(
    AsyncValue<List<Siparis>> historyAsync, {
    required Map<String, String> musteriMap,
    required Map<String, String> ugramaMap,
    required Map<String, String> kuryeMap,
  }) {
    return historyAsync.when(
      data: (orders) {
        return _PremiumCard(
          title: 'SİPARİŞ GEÇMİŞİ (${orders.length})',
          icon: Icons.history_rounded,
          child: Column(
            key: const Key('history_data_table'),
            children: [
              _buildTableHeader(['Tarih', 'Müşteri', 'Çıkış', 'Uğrama', 'Kurye', 'Ücret', 'Durum']),
              const Divider(height: 1),
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('Kayıt bulunamadı', style: TextStyle(color: AppColors.textMuted)),
                )
              else
                ...orders.map((s) => _buildDataRow(s, musteriMap, ugramaMap, kuryeMap)),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Hata: $e'),
    );
  }

  Widget _buildTableHeader(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: labels
            .map(
              (l) => Expanded(
                child: Text(
                  l.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDataRow(
    Siparis s,
    Map<String, String> musteriMap,
    Map<String, String> ugramaMap,
    Map<String, String> kuryeMap,
  ) {
    final isSelected = _selectedOrder?.id == s.id;
    return InkWell(
      onTap: () => _selectOrder(s),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.05) : null,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                s.createdAt != null ? _formatDate(s.createdAt!) : '-',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Text(
                musteriMap[s.musteriId] ?? s.musteriId,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Text(ugramaMap[s.cikisId] ?? s.cikisId, style: const TextStyle(fontSize: 13)),
            ),
            Expanded(
              child: Text(
                ugramaMap[s.ugramaId] ?? s.ugramaId,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                kuryeMap[s.kuryeId] ?? '-',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Text(
                s.ucret != null ? '₺${s.ucret!.toStringAsFixed(2)}' : '-',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(s.durum).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.durum.value.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getStatusColor(s.durum),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SiparisDurum durum) {
    switch (durum) {
      case SiparisDurum.tamamlandi:
        return const Color(0xFF10B981);
      case SiparisDurum.iptal:
        return const Color(0xFFEF4444);
      case SiparisDurum.devamEdiyor:
        return const Color(0xFF6366F1);
      case SiparisDurum.kuryeBekliyor:
        return const Color(0xFFF59E0B);
    }
  }

  // ──────────── Helpers ────────────

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
}

class _FocusHistorySearchIntent extends Intent {
  const _FocusHistorySearchIntent();
}

class _ClearHistorySelectionIntent extends Intent {
  const _ClearHistorySelectionIntent();
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.title,
    required this.child,
    this.icon,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    const headerColor = Colors.white;
    const titleColor = AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            color: headerColor,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}
