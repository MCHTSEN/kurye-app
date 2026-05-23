import 'dart:async';

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
import '../../../core/utils/app_time.dart';
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
  bool _editFaturalandirildi = false;
  final _editUcretController = TextEditingController();
  final _editNot1Controller = TextEditingController();
  bool _isSaving = false;
  bool _isBulkUpdating = false;

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
      _editFaturalandirildi = order.faturalandirildi;
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
      _editFaturalandirildi = false;
      _editUcretController.clear();
      _editNot1Controller.clear();
    });
  }

  Future<void> _onSave() async {
    if (_selectedOrder == null) return;

    setState(() => _isSaving = true);

    final selectedOrder = _selectedOrder!;
    try {
      final fields = <String, dynamic>{
        'musteri_id': _editMusteriId,
        'cikis_id': _editCikisId,
        'ugrama_id': _editUgramaId,
        'durum': _editDurum,
        'faturalandirildi': _editFaturalandirildi,
        'not1': _editNot1Controller.text.trim().isNotEmpty ? _editNot1Controller.text.trim() : null,
      };

      final parsedUcret = double.tryParse(_editUcretController.text);
      if (parsedUcret != null) {
        fields['ucret'] = parsedUcret;
      }

      await ref.read(siparisRepositoryProvider).update(selectedOrder.id, fields);

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

  Future<void> _onListFaturalandirildiToggle(
    Siparis order, {
    required bool nextValue,
  }) async {
    setState(() => _isSaving = true);

    try {
      final updated = await ref.read(siparisRepositoryProvider).update(
        order.id,
        {
          'faturalandirildi': nextValue,
        },
      );

      ref.invalidate(siparisHistoryProvider);

      if (mounted) {
        setState(() {
          if (_selectedOrder?.id == order.id) {
            _selectedOrder = updated;
            _editFaturalandirildi = updated.faturalandirildi;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextValue
                  ? 'Sipariş faturalandırıldı olarak işaretlendi'
                  : 'Siparişin faturalandırıldı işareti kaldırıldı',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      _log.e('Billing toggle failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _onBulkFaturalandirildiToggle(
    List<Siparis> visibleOrders, {
    required bool nextValue,
  }) async {
    if (visibleOrders.isEmpty) return;

    final confirmed = await _showBulkFaturalandirmaConfirmDialog(
      willMarkAsBilled: nextValue,
      orderCount: visibleOrders.length,
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    setState(() => _isBulkUpdating = true);

    try {
      final repo = ref.read(siparisRepositoryProvider);
      var updatedCount = 0;
      Siparis? selectedUpdated;

      for (final order in visibleOrders) {
        if (order.faturalandirildi == nextValue) continue;
        final updated = await repo.update(order.id, {
          'faturalandirildi': nextValue,
        });
        updatedCount++;

        if (_selectedOrder?.id == order.id) {
          selectedUpdated = updated;
        }
      }

      ref.invalidate(siparisHistoryProvider);

      if (mounted) {
        if (selectedUpdated != null) {
          setState(() {
            _selectedOrder = selectedUpdated;
            _editFaturalandirildi = selectedUpdated!.faturalandirildi;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedCount == 0
                  ? 'Değişiklik yok'
                  : nextValue
                  ? '$updatedCount sipariş faturalandırıldı olarak işaretlendi'
                  : '$updatedCount siparişin faturalandırıldı işareti kaldırıldı',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      _log.e('Bulk billing toggle failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        setState(() => _isBulkUpdating = false);
      }
    }
  }

  Future<bool?> _showBulkFaturalandirmaConfirmDialog({
    required bool willMarkAsBilled,
    required int orderCount,
  }) {
    final verb = willMarkAsBilled ? 'işaretlemek' : 'kaldırmak';
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Toplu Faturalandırma'),
          content: Text(
            '$orderCount sipariş için faturalandırıldı durumunu $verb istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );
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

  Future<void> _onDelete() async {
    if (_selectedOrder == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('history_delete_confirm'),
        title: const Text('Siparişi sil'),
        content: const Text(
          'Bu siparişi kalıcı olarak silmek istediğinizden emin misiniz? '
          'İşlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(siparisRepositoryProvider).delete(_selectedOrder!.id);
      ref.invalidate(siparisHistoryProvider);
      _clearEditPanel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sipariş silindi')),
        );
      }
    } on Exception catch (e) {
      _log.e('Order delete failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silme hatası: $e')),
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
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    _buildEditPanel(musteriListAsync, ugramaListAsync),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildSearchAndStatusCard(historyAsync)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildFilterBar(musteriListAsync, ugramaListAsync),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildDataTableCard(
                      filteredHistoryAsync,
                      musteriMap: musteriMap,
                      ugramaMap: ugramaMap,
                      kuryeMap: kuryeMap,
                    ),
                  ],
                )
              : ListView(
                  padding: ProjectPadding.all.normal,
                  children: [
                    _buildEditPanel(musteriListAsync, ugramaListAsync),
                    const SizedBox(height: AppSpacing.md),
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

    final musteriField = SearchableDropdown<String>(
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
    );
    final cikisField = SearchableDropdown<String>(
      key: const Key('edit_cikis_dropdown'),
      value: _editCikisId,
      label: 'Çıkış',
      placeholder: 'Çıkış Seç',
      searchPlaceholder: 'Uğrama ara...',
      items: stopItems,
      onChanged: (v) => setState(() => _editCikisId = v),
    );
    final ugramaField = SearchableDropdown<String>(
      key: const Key('edit_ugrama_dropdown'),
      value: _editUgramaId,
      label: 'Uğrama',
      placeholder: 'Uğrama Seç',
      searchPlaceholder: 'Uğrama ara...',
      items: stopItems,
      onChanged: (v) => setState(() => _editUgramaId = v),
    );
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500);

    Widget labeled(String label, Widget child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: labelStyle),
          ),
          child,
        ],
      );
    }

    final ucretField = labeled(
      'Ücret (₺)',
      TextFormField(
        key: const Key('edit_ucret_field'),
        controller: _editUcretController,
        decoration: const InputDecoration(
          isDense: true,
          prefixIcon: Icon(Icons.payments_outlined, size: 18),
          hintText: '0.00',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
    final durumField = SearchableDropdown<String>(
      key: const Key('edit_durum_dropdown'),
      value: _editDurum,
      label: 'Durum',
      placeholder: 'Durum Seç',
      items: durumItems,
      onChanged: (v) => setState(() => _editDurum = v),
    );
    final not1Field = labeled(
      'Not',
      TextFormField(
        key: const Key('edit_not1_field'),
        controller: _editNot1Controller,
        decoration: const InputDecoration(
          isDense: true,
          prefixIcon: Icon(Icons.notes_outlined, size: 18),
          hintText: 'Not ekle...',
        ),
      ),
    );
    final faturaField = labeled(
      'Faturalandırma',
      Container(
        decoration: BoxDecoration(
          color: _editFaturalandirildi ? AppColors.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _editFaturalandirildi
                ? AppColors.primary.withValues(alpha: 0.4)
                : theme.dividerColor,
          ),
        ),
        child: CheckboxListTile(
          key: const Key('edit_faturalandirildi_checkbox'),
          value: _editFaturalandirildi,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(
            _editFaturalandirildi ? 'Faturalandırıldı' : 'Faturalandırılmadı',
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _editFaturalandirildi = value);
          },
        ),
      ),
    );

    final hasSelection = _selectedOrder != null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = AppSpacing.sm;
                const minItem = 170.0;
                const fields = 7;
                final maxW = constraints.maxWidth;
                final fitCount = ((maxW + gap) / (minItem + gap)).floor().clamp(1, fields);
                final itemWidth = (maxW - gap * (fitCount - 1)) / fitCount;
                final children = <Widget>[
                  musteriField,
                  durumField,
                  cikisField,
                  ugramaField,
                  ucretField,
                  faturaField,
                  not1Field,
                ];
                return Wrap(
                  spacing: gap,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final child in children) SizedBox(width: itemWidth, child: child),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                TextButton.icon(
                  key: const Key('edit_delete_button'),
                  onPressed: (!hasSelection || _isSaving) ? null : _onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Sil'),
                ),
                TextButton.icon(
                  key: const Key('edit_close_button'),
                  onPressed: hasSelection ? _clearEditPanel : null,
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Kapat'),
                ),
                SizedBox(
                  width: 120,
                  child: AppPrimaryButton(
                    key: const Key('edit_iptal_button'),
                    label: 'İptal Et',
                    onPressed: (!hasSelection || _isSaving) ? null : _onIptal,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: AppPrimaryButton(
                    key: const Key('edit_save_button'),
                    label: 'Kaydet',
                    onPressed: (!hasSelection || _isSaving) ? null : _onSave,
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final musteriler = musteriListAsync.maybeWhen(
      data: (d) => d,
      orElse: () => <Musteri>[],
    );
    final ugramalar = ugramaListAsync.maybeWhen(
      data: (d) => d,
      orElse: () => <Ugrama>[],
    );

    return _PremiumCard(
      title: 'FİLTRELER',
      icon: Icons.filter_list_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
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
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.refresh_rounded, size: 20),
            ),
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 2, child: dateField),
              const SizedBox(width: 12),
              Expanded(child: musteriField),
              const SizedBox(width: 12),
              Expanded(child: guzergahField),
              const SizedBox(width: 12),
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
              _buildTableHeader(
                [
                  'Tarih',
                  'Müşteri',
                  'Çıkış',
                  'Uğrama',
                  'Kurye',
                  'Ücret',
                  'Durum',
                  'Faturalandırıldı',
                ],
                visibleOrders: orders,
              ),
              const Divider(height: 1),
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Kayıt bulunamadı',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              else
                ...orders.map(
                  (s) => _buildDataRow(s, musteriMap, ugramaMap, kuryeMap),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Hata: $e'),
    );
  }

  Widget _buildTableHeader(
    List<String> labels, {
    required List<Siparis> visibleOrders,
  }) {
    final allBilled =
        visibleOrders.isNotEmpty && visibleOrders.every((order) => order.faturalandirildi);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
      ),
      child: Row(
        children: [
          for (final label in labels.take(labels.length - 1))
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showLabel = constraints.maxWidth >= 140;
                final toggleButton = _isBulkUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        key: const Key('history_billed_bulk_toggle'),
                        tooltip: allBilled
                            ? 'Hepsinin faturalandırıldı işaretini kaldır'
                            : 'Hepsini faturalandırıldı olarak işaretle',
                        onPressed: _isSaving
                            ? null
                            : () => unawaited(
                                _onBulkFaturalandirildiToggle(
                                  visibleOrders,
                                  nextValue: !allBilled,
                                ),
                              ),
                        constraints: const BoxConstraints.tightFor(
                          width: 22,
                          height: 22,
                        ),
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: Icon(
                          Icons.done_all_rounded,
                          color: allBilled ? const Color(0xFF10B981) : AppColors.textMuted,
                        ),
                      );

                if (!showLabel) {
                  return Center(child: toggleButton);
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      labels.last.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    toggleButton,
                  ],
                );
              },
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.05) : null,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                s.createdAt != null ? _formatDate(s.createdAt!) : '-',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                musteriMap[s.musteriId] ?? s.musteriId,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                ugramaMap[s.cikisId] ?? s.cikisId,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                ugramaMap[s.ugramaId] ?? s.ugramaId,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                kuryeMap[s.kuryeId] ?? '-',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                s.ucret != null ? '₺${s.ucret!.toStringAsFixed(2)}' : '-',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(s.durum).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  s.durum.value.toUpperCase(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _getStatusColor(s.durum),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    key: Key('history_billed_${s.id}'),
                    value: s.faturalandirildi,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value == null || value == s.faturalandirildi) {
                              return;
                            }
                            unawaited(
                              _onListFaturalandirildiToggle(
                                s,
                                nextValue: value,
                              ),
                            );
                          },
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

  String _formatDate(DateTime dt) => AppTime.dmy(dt);
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}
