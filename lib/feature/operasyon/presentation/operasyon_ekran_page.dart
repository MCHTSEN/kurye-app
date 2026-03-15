import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/kurye/kurye_providers.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/services/order_alert_service.dart';
import '../../../product/siparis/siparis_log_providers.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/searchable_dropdown.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';

final _log = Logger();

class OperasyonEkranPage extends ConsumerStatefulWidget {
  const OperasyonEkranPage({super.key, this.alertService});

  /// Optional injectable alert service. When null a real instance is created.
  final OrderAlertService? alertService;

  @override
  ConsumerState<OperasyonEkranPage> createState() =>
      _OperasyonEkranPageState();
}

class _OperasyonEkranPageState extends ConsumerState<OperasyonEkranPage> {
  // — Order creation form state —
  final _formKey = GlobalKey<FormState>();
  String? _selectedMusteriId;
  String? _selectedCikisId;
  String? _selectedUgramaId;
  String? _selectedUgrama1Id;
  String? _selectedNotId;
  final _not1Controller = TextEditingController();
  bool _isCreating = false;

  // — Kurye Bekleyenler panel state —
  final _waitingSelected = <String>{};
  String? _selectedKuryeId;
  bool _isAssigning = false;

  // — Devam Edenler panel state —
  final _activeSelected = <String>{};
  bool _isFinishing = false;

  // — Sound alert state —
  late final OrderAlertService _alertService;
  bool _ownsAlertService = false;
  final _knownWaitingIds = <String>{};
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    if (widget.alertService != null) {
      _alertService = widget.alertService!;
    } else {
      _alertService = OrderAlertService();
      _ownsAlertService = true;
    }
  }

  @override
  void dispose() {
    _not1Controller.dispose();
    if (_ownsAlertService) {
      unawaited(_alertService.dispose());
    }
    super.dispose();
  }

  // ──────────── Order creation ────────────

  void _onMusteriChanged(String? musteriId) {
    setState(() {
      _selectedMusteriId = musteriId;
      _selectedCikisId = null;
      _selectedUgramaId = null;
      _selectedUgrama1Id = null;
      _selectedNotId = null;
    });
  }

  Future<void> _onCreateOrder(String userId) async {
    final hasDropdownErrors = _selectedMusteriId == null ||
        _selectedCikisId == null ||
        _selectedUgramaId == null;

    if (!_formKey.currentState!.validate() || hasDropdownErrors) {
      return;
    }

    setState(() => _isCreating = true);

    try {
      final siparis = Siparis(
        id: '',
        musteriId: _selectedMusteriId!,
        cikisId: _selectedCikisId!,
        ugramaId: _selectedUgramaId!,
        ugrama1Id: _selectedUgrama1Id,
        notId: _selectedNotId,
        not1: _not1Controller.text.trim().isNotEmpty
            ? _not1Controller.text.trim()
            : null,
        olusturanId: userId,
      );

      await ref.read(siparisRepositoryProvider).create(siparis);

      // Reset form.
      setState(() {
        _selectedCikisId = null;
        _selectedUgramaId = null;
        _selectedUgrama1Id = null;
        _selectedNotId = null;
        _not1Controller.clear();
      });
      _formKey.currentState?.reset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sipariş oluşturuldu')),
        );
      }
    } on Exception catch (e) {
      _log.e('Order create failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  // ──────────── Assign (Ata) flow ────────────

  Future<void> _onAssign({
    required String userId,
    required List<Siparis> waitingOrders,
  }) async {
    if (_waitingSelected.isEmpty || _selectedKuryeId == null) return;

    setState(() => _isAssigning = true);

    try {
      final repo = ref.read(siparisRepositoryProvider);
      final logRepo = ref.read(siparisLogRepositoryProvider);
      final selectedIds = Set<String>.of(_waitingSelected);

      for (final orderId in selectedIds) {
        await repo.update(orderId, {
          'kurye_id': _selectedKuryeId,
          'atanma_saat': DateTime.now().toIso8601String(),
          'durum': SiparisDurum.devamEdiyor.value,
        });

        await logRepo.create(
          SiparisLog(
            id: '',
            siparisId: orderId,
            eskiDurum: SiparisDurum.kuryeBekliyor,
            yeniDurum: SiparisDurum.devamEdiyor,
            degistirenId: userId,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedIds.length} sipariş kurye atandı',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      _log.e('Assignment failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Atama hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _waitingSelected.clear();
          _isAssigning = false;
        });
      }
    }
  }

  // ──────────── Finish (Bitir) flow with auto-pricing ────────────

  Future<void> _onFinish({
    required String userId,
    required List<Siparis> activeOrders,
  }) async {
    if (_activeSelected.isEmpty) return;

    setState(() => _isFinishing = true);

    try {
      final repo = ref.read(siparisRepositoryProvider);
      final logRepo = ref.read(siparisLogRepositoryProvider);
      final selectedIds = Set<String>.of(_activeSelected);

      for (final orderId in selectedIds) {
        final order = activeOrders.firstWhere((s) => s.id == orderId);

        // Auto-pricing lookup.
        final pricingMatch = await repo.getRecentPricing(
          musteriId: order.musteriId,
          cikisId: order.cikisId,
          ugramaId: order.ugramaId,
        );

        var price = pricingMatch?.ucret;

        if (price == null) {
          _log.w(
            'Auto-pricing miss: musteri=${order.musteriId} '
            'cikis=${order.cikisId} ugrama=${order.ugramaId}',
          );
          // Show manual pricing dialog.
          if (mounted) {
            price = await _showManualPricingDialog();
          }
          // User cancelled the dialog — skip this order.
          if (price == null) continue;
        }

        await repo.update(orderId, {
          'ucret': price,
          'bitis_saat': DateTime.now().toIso8601String(),
          'durum': SiparisDurum.tamamlandi.value,
        });

        await logRepo.create(
          SiparisLog(
            id: '',
            siparisId: orderId,
            eskiDurum: SiparisDurum.devamEdiyor,
            yeniDurum: SiparisDurum.tamamlandi,
            degistirenId: userId,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedIds.length} sipariş tamamlandı',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      _log.e('Finish failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bitirme hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _activeSelected.clear();
          _isFinishing = false;
        });
      }
    }
  }

  Future<double?> _showManualPricingDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ücret Giriniz'),
          content: TextField(
            key: const Key('manual_price_field'),
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Ücret (₺)',
              hintText: '0.00',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              key: const Key('manual_price_confirm'),
              onPressed: () {
                final parsed = double.tryParse(controller.text);
                if (parsed != null && parsed > 0) {
                  Navigator.of(ctx).pop(parsed);
                }
              },
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  // ──────────── Build ────────────

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return ResponsiveScaffold(
      title: 'Operasyon Ekranı',
      currentRoute: CustomRoute.operasyonEkran,
      navItems: operasyonNavItems,
      headerTitle: 'Moto Kurye',
      headerSubtitle: 'Operasyon',
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profil bulunamadı.'));
          }
          return _buildBody(profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildBody(AppUserProfile profile) {
    final streamAsync = ref.watch(siparisStreamActiveProvider);

    // Clear selections and detect new waiting orders for sound alert.
    ref.listen(siparisStreamActiveProvider, (prev, next) {
      if (next is AsyncData<List<Siparis>>) {
        final currentWaitingIds = next.value
            .where((s) => s.durum == SiparisDurum.kuryeBekliyor)
            .map((s) => s.id)
            .toSet();

        if (_initialLoadDone) {
          // Fire alert only for genuinely new IDs.
          final newIds = currentWaitingIds.difference(_knownWaitingIds);
          if (newIds.isNotEmpty) {
            unawaited(_alertService.playNewOrderAlert());
          }
        }

        _knownWaitingIds
          ..clear()
          ..addAll(currentWaitingIds);
        _initialLoadDone = true;

        setState(() {
          _waitingSelected.clear();
          _activeSelected.clear();
        });
      }
    });

    final type = layoutTypeOf(context);
    if (type == LayoutType.mobile) {
      return _buildMobileBody(streamAsync, profile.id);
    }
    return _buildDesktopBody(streamAsync, profile.id);
  }

  Widget _buildMobileBody(
    AsyncValue<List<Siparis>> streamAsync,
    String userId,
  ) {
    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        _buildOrderCreationPanel(userId),
        const SizedBox(height: AppSpacing.md),
        streamAsync.when(
          data: (orders) => _buildDispatchPanelsMobile(orders, userId),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppSectionCard(
            title: 'Siparişler',
            child: Text('Hata: $e'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBody(
    AsyncValue<List<Siparis>> streamAsync,
    String userId,
  ) {
    return Padding(
      padding: ProjectPadding.all.normal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel 1: Order creation
          Expanded(
            child: SingleChildScrollView(
              child: _buildOrderCreationPanel(userId),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Panel 2 + 3: Dispatch
          Expanded(
            flex: 2,
            child: streamAsync.when(
              data: (orders) =>
                  _buildDispatchPanelsDesktop(orders, userId),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppSectionCard(
                title: 'Siparişler',
                child: Text('Hata: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({
    List<Siparis> waiting,
    List<Siparis> active,
    Map<String, String> ugramaMap,
    Map<String, String> kuryeMap,
  }) _resolveDispatchData(List<Siparis> allOrders) {
    final waiting = allOrders
        .where((s) => s.durum == SiparisDurum.kuryeBekliyor)
        .toList();
    final active = allOrders
        .where((s) => s.durum == SiparisDurum.devamEdiyor)
        .toList();

    // Build name-resolution maps (D027 pattern).
    final ugramaListAsync = ref.watch(ugramaListProvider);
    final kuryeListAsync = ref.watch(kuryeListProvider);

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

    return (
      waiting: waiting,
      active: active,
      ugramaMap: ugramaMap,
      kuryeMap: kuryeMap,
    );
  }

  Widget _buildDispatchPanelsMobile(
    List<Siparis> allOrders,
    String userId,
  ) {
    final data = _resolveDispatchData(allOrders);
    return Column(
      children: [
        _buildWaitingPanel(data.waiting, userId,
            ugramaMap: data.ugramaMap),
        const SizedBox(height: AppSpacing.md),
        _buildActivePanel(
          data.active,
          userId,
          ugramaMap: data.ugramaMap,
          kuryeMap: data.kuryeMap,
        ),
      ],
    );
  }

  Widget _buildDispatchPanelsDesktop(
    List<Siparis> allOrders,
    String userId,
  ) {
    final data = _resolveDispatchData(allOrders);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: _buildWaitingPanel(
              data.waiting,
              userId,
              ugramaMap: data.ugramaMap,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SingleChildScrollView(
            child: _buildActivePanel(
              data.active,
              userId,
              ugramaMap: data.ugramaMap,
              kuryeMap: data.kuryeMap,
            ),
          ),
        ),
      ],
    );
  }

  // ──────────── Panel 1: Order Creation ────────────

  Widget _buildOrderCreationPanel(String userId) {
    final musteriListAsync = ref.watch(musteriListProvider);

    return AppSectionCard(
      title: 'Sipariş Oluşturma Paneli',
      child: musteriListAsync.when(
        data: (musteriler) =>
            _buildOrderForm(musteriler: musteriler, userId: userId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Müşteri listesi yüklenemedi: $e'),
      ),
    );
  }

  Widget _buildOrderForm({
    required List<Musteri> musteriler,
    required String userId,
  }) {
    final musteriItems = musteriler
        .map((m) => (value: m.id, label: m.firmaKisaAd))
        .toList();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          SearchableDropdown<String>(
            key: const Key('musteri_dropdown'),
            value: _selectedMusteriId,
            label: 'Müşteri *',
            placeholder: 'Müşteri Seç',
            searchPlaceholder: 'Müşteri ara...',
            items: musteriItems,
            onChanged: _onMusteriChanged,
            validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (_selectedMusteriId != null) ...[
            _buildStopDropdowns(),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _not1Controller,
              decoration: const InputDecoration(labelText: 'Not1'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Sipariş Oluştur',
              onPressed: () => _onCreateOrder(userId),
              isLoading: _isCreating,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStopDropdowns() {
    final ugramaAsync =
        ref.watch(ugramaListByMusteriProvider(_selectedMusteriId!));

    return ugramaAsync.when(
      data: (ugramalar) {
        final items = ugramalar
            .map((u) => (value: u.id, label: u.ugramaAdi))
            .toList();

        return Column(
          children: [
            SearchableDropdown<String>(
              key: const Key('cikis_dropdown'),
              value: _selectedCikisId,
              label: 'Çıkış *',
              placeholder: 'Çıkış Seç',
              searchPlaceholder: 'Uğrama ara...',
              items: items,
              onChanged: (v) => setState(() => _selectedCikisId = v),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            SearchableDropdown<String>(
              key: const Key('ugrama_dropdown'),
              value: _selectedUgramaId,
              label: 'Uğrama *',
              placeholder: 'Uğrama Seç',
              searchPlaceholder: 'Uğrama ara...',
              items: items,
              onChanged: (v) => setState(() => _selectedUgramaId = v),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            SearchableDropdown<String>(
              key: const Key('ugrama1_dropdown'),
              value: _selectedUgrama1Id,
              label: 'Uğrama1',
              placeholder: 'Seçilmedi',
              searchPlaceholder: 'Uğrama ara...',
              items: items,
              onChanged: (v) => setState(() => _selectedUgrama1Id = v),
            ),
            const SizedBox(height: AppSpacing.xs),
            SearchableDropdown<String>(
              key: const Key('not_dropdown'),
              value: _selectedNotId,
              label: 'Not',
              placeholder: 'Seçilmedi',
              searchPlaceholder: 'Uğrama ara...',
              items: items,
              onChanged: (v) => setState(() => _selectedNotId = v),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Uğrama listesi yüklenemedi: $e'),
    );
  }

  // ──────────── Panel 2: Kurye Bekleyenler ────────────

  Widget _buildWaitingPanel(
    List<Siparis> waiting,
    String userId, {
    required Map<String, String> ugramaMap,
  }) {
    final kuryeListAsync = ref.watch(kuryeListProvider);

    return AppSectionCard(
      title: 'Kurye Bekleyenler (${waiting.length})',
      child: Column(
        children: [
          if (waiting.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text('Bekleyen sipariş yok.'),
            )
          else
            ...waiting.map(
              (s) => CheckboxListTile(
                key: Key('waiting_${s.id}'),
                title: Text(_routeLabel(s, ugramaMap: ugramaMap)),
                subtitle: s.not1 != null ? Text(s.not1!) : null,
                value: _waitingSelected.contains(s.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _waitingSelected.add(s.id);
                    } else {
                      _waitingSelected.remove(s.id);
                    }
                  });
                },
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          kuryeListAsync.when(
            data: (kuryeler) {
              final activeKuryeler =
                  kuryeler.where((k) => k.isActive).toList();
              return Column(
                children: [
                  SearchableDropdown<String>(
                    key: const Key('kurye_dropdown'),
                    value: _selectedKuryeId,
                    label: 'Kurye Seç',
                    placeholder: 'Kurye Seç',
                    searchPlaceholder: 'Kurye ara...',
                    items: activeKuryeler
                        .map((k) => (value: k.id, label: k.ad))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedKuryeId = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppPrimaryButton(
                    label: 'Ata',
                    onPressed: _waitingSelected.isNotEmpty &&
                            _selectedKuryeId != null &&
                            !_isAssigning
                        ? () => _onAssign(
                              userId: userId,
                              waitingOrders: waiting,
                            )
                        : null,
                    isLoading: _isAssigning,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Kurye listesi yüklenemedi: $e'),
          ),
        ],
      ),
    );
  }

  // ──────────── Panel 3: Devam Edenler ────────────

  Widget _buildActivePanel(
    List<Siparis> active,
    String userId, {
    required Map<String, String> ugramaMap,
    required Map<String, String> kuryeMap,
  }) {
    return AppSectionCard(
      title: 'Devam Edenler (${active.length})',
      child: Column(
        children: [
          if (active.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text('Devam eden sipariş yok.'),
            )
          else
            ...active.map(
              (s) => CheckboxListTile(
                key: Key('active_${s.id}'),
                title: Text(_routeLabel(s, ugramaMap: ugramaMap)),
                subtitle: Text(
                  'Kurye: ${kuryeMap[s.kuryeId] ?? s.kuryeId ?? '-'}',
                ),
                value: _activeSelected.contains(s.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _activeSelected.add(s.id);
                    } else {
                      _activeSelected.remove(s.id);
                    }
                  });
                },
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          AppPrimaryButton(
            label: 'Bitir',
            onPressed:
                _activeSelected.isNotEmpty && !_isFinishing
                    ? () => _onFinish(
                          userId: userId,
                          activeOrders: active,
                        )
                    : null,
            isLoading: _isFinishing,
          ),
        ],
      ),
    );
  }

  // ──────────── Helpers ────────────

  String _routeLabel(
    Siparis s, {
    required Map<String, String> ugramaMap,
  }) {
    final cikis = ugramaMap[s.cikisId] ?? s.cikisId;
    final ugrama = ugramaMap[s.ugramaId] ?? s.ugramaId;
    return '$cikis → $ugrama';
  }
}
