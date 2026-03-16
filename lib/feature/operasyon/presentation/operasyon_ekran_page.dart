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
import '../../../product/kurye/kurye_providers.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/musteri_personel/musteri_personel_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/services/order_alert_service.dart';
import '../../../product/siparis/siparis_log_providers.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/searchable_dropdown.dart';

final _log = Logger();

class OperasyonEkranPage extends ConsumerStatefulWidget {
  const OperasyonEkranPage({super.key, this.alertService});

  /// Optional injectable alert service. When null a real instance is created.
  final OrderAlertService? alertService;

  @override
  ConsumerState<OperasyonEkranPage> createState() => _OperasyonEkranPageState();
}

class _OperasyonEkranPageState extends ConsumerState<OperasyonEkranPage> {
  // — Order creation form state —
  final _formKey = GlobalKey<FormState>();
  String? _selectedMusteriId;
  String? _selectedPersonelId;
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
      _selectedPersonelId = null;
      _selectedCikisId = null;
      _selectedUgramaId = null;
      _selectedUgrama1Id = null;
      _selectedNotId = null;
    });
  }

  Future<void> _onCreateOrder(String userId) async {
    final hasDropdownErrors =
        _selectedMusteriId == null || _selectedPersonelId == null || _selectedCikisId == null || _selectedUgramaId == null;

    if (!_formKey.currentState!.validate() || hasDropdownErrors) {
      return;
    }

    setState(() => _isCreating = true);

    try {
      final siparis = Siparis(
        id: '',
        musteriId: _selectedMusteriId!,
        personelId: _selectedPersonelId,
        cikisId: _selectedCikisId!,
        ugramaId: _selectedUgramaId!,
        ugrama1Id: _selectedUgrama1Id,
        notId: _selectedNotId,
        not1: _not1Controller.text.trim().isNotEmpty ? _not1Controller.text.trim() : null,
        olusturanId: userId,
      );

      await ref.read(siparisRepositoryProvider).create(siparis);

      // Reset form — clear everything including müşteri.
      setState(() {
        _selectedMusteriId = null;
        _selectedPersonelId = null;
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

      // Force provider refresh so assigned orders move immediately.
      ref.invalidate(siparisStreamActiveProvider);

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
        final matchingOrders = activeOrders.where((s) => s.id == orderId);
        if (matchingOrders.isEmpty) {
          _log.w('Finish skipped: active order not found for $orderId');
          continue;
        }
        final order = matchingOrders.first;

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

      // Force provider refresh so the UI doesn't wait for the next
      // Supabase Realtime event — completed orders disappear immediately.
      ref.invalidate(siparisStreamActiveProvider);

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
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return const _ManualPricingDialog(key: Key('manual_price_dialog'));
      },
    );
    return result;
  }

  // ──────────── Build ────────────

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final isDesktop = layoutTypeOf(context) == LayoutType.desktop;

    return ResponsiveScaffold(
      title: 'Operasyon Ekranı',
      currentRoute: CustomRoute.operasyonEkran,
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      showMobileDrawer: false,
      body: Shortcuts(
        shortcuts: isDesktop
            ? const {
                SingleActivator(LogicalKeyboardKey.escape): _ClearDeskSelectionIntent(),
              }
            : const {},
        child: Actions(
          actions: {
            _ClearDeskSelectionIntent: CallbackAction<_ClearDeskSelectionIntent>(
              onInvoke: (_) {
                setState(() {
                  _waitingSelected.clear();
                  _activeSelected.clear();
                });
                return null;
              },
            ),
          },
          child: Stack(
            children: [
              const _BackgroundEffect(),
              profileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return const Center(child: Text('Profil bulunamadı.'));
                  }
                  return _buildBody(profile);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Hata: $e')),
              ),
            ],
          ),
        ),
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
    if (type != LayoutType.desktop) {
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
      physics: const BouncingScrollPhysics(),
      children: [
        _buildOrderCreationPanel(userId),
        const SizedBox(height: AppSpacing.lg),
        streamAsync.when(
          data: (orders) => _buildDispatchPanelsMobile(orders, userId),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _PremiumCard(
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
      padding: ProjectPadding.all.large,
      child: ContentConstraint(
        maxWidth: 1680,
        child: Column(
          children: [
            _buildDesktopSummaryBar(streamAsync),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: streamAsync.when(
                data: (orders) => _buildDesktopWorkbench(orders, userId),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _PremiumCard(
                  title: 'Siparişler',
                  child: Text('Hata: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSummaryBar(AsyncValue<List<Siparis>> streamAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SİSTEM AKTİF',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUGÜNKÜ KAZANÇ',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '0 TL',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: logoutCallback(ref),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopWorkbench(List<Siparis> orders, String userId) {
    final data = _resolveDispatchData(orders);
    return Column(
      children: [
        _buildOrderCreationPanel(userId),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildWaitingPanel(
                  data.waiting,
                  userId,
                  ugramaMap: data.ugramaMap,
                  musteriMap: data.musteriMap,
                  personelMap: data.personelMap,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildActivePanel(
                  data.active,
                  userId,
                  ugramaMap: data.ugramaMap,
                  kuryeMap: data.kuryeMap,
                  musteriMap: data.musteriMap,
                  personelMap: data.personelMap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ({
    List<Siparis> waiting,
    List<Siparis> active,
    Map<String, String> ugramaMap,
    Map<String, String> kuryeMap,
    Map<String, String> musteriMap,
    Map<String, String> personelMap,
  })
  _resolveDispatchData(List<Siparis> allOrders) {
    final waiting = allOrders.where((s) => s.durum == SiparisDurum.kuryeBekliyor).toList();
    final active = allOrders.where((s) => s.durum == SiparisDurum.devamEdiyor).toList();

    // Build name-resolution maps (D027 pattern).
    final ugramaListAsync = ref.watch(ugramaListProvider);
    final kuryeListAsync = ref.watch(kuryeListProvider);
    final musteriListAsync = ref.watch(musteriListProvider);
    final personelListAsync = ref.watch(musteriPersonelListProvider);

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

    final musteriMap = <String, String>{};
    if (musteriListAsync case AsyncData(value: final musteriler)) {
      for (final m in musteriler) {
        musteriMap[m.id] = m.firmaKisaAd;
      }
    }

    final personelMap = <String, String>{};
    if (personelListAsync case AsyncData(value: final personeller)) {
      for (final p in personeller) {
        personelMap[p.id] = p.ad;
      }
    }

    return (
      waiting: waiting,
      active: active,
      ugramaMap: ugramaMap,
      kuryeMap: kuryeMap,
      musteriMap: musteriMap,
      personelMap: personelMap,
    );
  }

  Widget _buildDispatchPanelsMobile(
    List<Siparis> allOrders,
    String userId,
  ) {
    final data = _resolveDispatchData(allOrders);
    return Column(
      children: [
        _buildWaitingPanel(
          data.waiting,
          userId,
          ugramaMap: data.ugramaMap,
          musteriMap: data.musteriMap,
          personelMap: data.personelMap,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildActivePanel(
          data.active,
          userId,
          ugramaMap: data.ugramaMap,
          kuryeMap: data.kuryeMap,
          musteriMap: data.musteriMap,
          personelMap: data.personelMap,
        ),
      ],
    );
  }

  // ──────────── Panel 1: Order Creation ────────────

  Widget _buildOrderCreationPanel(String userId) {
    final musteriListAsync = ref.watch(musteriListProvider);

    return _PremiumCard(
      title: 'YENİ SİPARİŞ',
      icon: Icons.add_rounded,
      isDarkHeader: true,
      accentColor: Colors.white,
      child: musteriListAsync.when(
        data: (musteriler) => _buildOrderForm(musteriler: musteriler, userId: userId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Text('Müşteriler alınamadı.'),
      ),
    );
  }

  Widget _buildOrderForm({
    required List<Musteri> musteriler,
    required String userId,
  }) {
    final musteriItems = musteriler.map((m) => (value: m.id, label: m.firmaKisaAd)).toList();

    // Personel items: populated when müşteri is selected.
    final personelItems = <({String value, String label})>[];
    if (_selectedMusteriId != null) {
      final personelAsync = ref.watch(
        musteriPersonelListByMusteriProvider(_selectedMusteriId!),
      );
      if (personelAsync case AsyncData(value: final personeller)) {
        personelItems.addAll(
          personeller.map((p) => (value: p.id, label: p.ad)),
        );
      }
    }

    // Uğrama items: populated when müşteri is selected.
    final ugramaItems = <({String value, String label})>[];
    if (_selectedMusteriId != null) {
      final ugramaAsync = ref.watch(
        ugramaListByMusteriProvider(_selectedMusteriId!),
      );
      if (ugramaAsync case AsyncData(value: final ugramalar)) {
        ugramaItems.addAll(
          ugramalar.map((u) => (value: u.id, label: u.ugramaAdi)),
        );
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: SearchableDropdown<String>(
                  key: const Key('musteri_dropdown'),
                  value: _selectedMusteriId,
                  label: 'MÜŞTERİ',
                  placeholder: 'Seçiniz',
                  searchPlaceholder: 'Müşteri ara...',
                  items: musteriItems,
                  onChanged: _onMusteriChanged,
                  validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SearchableDropdown<String>(
                  key: const Key('personel_dropdown'),
                  value: _selectedPersonelId,
                  label: 'PERSONEL',
                  placeholder: 'Seçiniz',
                  searchPlaceholder: 'Personel ara...',
                  items: personelItems,
                  onChanged: (v) => setState(() => _selectedPersonelId = v),
                  validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SearchableDropdown<String>(
                  key: const Key('cikis_dropdown'),
                  value: _selectedCikisId,
                  label: 'ÇIKIŞ',
                  placeholder: 'Nereden?',
                  searchPlaceholder: 'Ara...',
                  items: ugramaItems,
                  onChanged: (v) => setState(() => _selectedCikisId = v),
                  validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SearchableDropdown<String>(
                  key: const Key('ugrama_dropdown'),
                  value: _selectedUgramaId,
                  label: 'UĞRAMA',
                  placeholder: 'Nereye?',
                  searchPlaceholder: 'Ara...',
                  items: ugramaItems,
                  onChanged: (v) => setState(() => _selectedUgramaId = v),
                  validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SearchableDropdown<String>(
                  key: const Key('ugrama1_dropdown'),
                  value: _selectedUgrama1Id,
                  label: 'UĞRAMA 1',
                  placeholder: 'Nereye? (2)',
                  searchPlaceholder: 'Ara...',
                  items: ugramaItems,
                  onChanged: (v) => setState(() => _selectedUgrama1Id = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SearchableDropdown<String>(
                  key: const Key('not_dropdown'),
                  value: _selectedNotId,
                  label: 'NOT (REHBER)',
                  placeholder: 'Seçim Yok',
                  searchPlaceholder: 'Ara...',
                  items: ugramaItems,
                  onChanged: (v) => setState(() => _selectedNotId = v),
                ),
              ),
              const SizedBox(width: 12),
              // Label (≈20) + padding-bottom (6) = 26 top offset to align
              // with dropdown boxes. Bottom padding matches error text area.
              Padding(
                padding: const EdgeInsets.only(top: 26, bottom: 18),
                child: SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _onCreateOrder(userId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'SİPARİŞ OLUŞTUR',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────── Panel 2: Kurye Bekleyenler ────────────

  Widget _buildWaitingPanel(
    List<Siparis> waiting,
    String userId, {
    required Map<String, String> ugramaMap,
    required Map<String, String> musteriMap,
    required Map<String, String> personelMap,
  }) {
    final kuryeListAsync = ref.watch(kuryeListProvider);

    return _PremiumCard(
      title: 'KURYE BEKLEYENLER (${waiting.length})',
      icon: Icons.access_time_filled_rounded,
      accentColor: const Color(0xFFF59E0B),
      action: kuryeListAsync.maybeWhen(
        data: (kuryeler) {
          final activeKuryeler = kuryeler.where((k) => k.isActive).toList();
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                child: SearchableDropdown<String>(
                  key: const Key('kurye_dropdown'),
                  items: activeKuryeler.map((k) => (value: k.id, label: k.ad)).toList(),
                  onChanged: (v) => setState(() => _selectedKuryeId = v),
                  value: _selectedKuryeId,
                  placeholder: 'Kurye Seç',
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 88,
                height: 38,
                child: ElevatedButton(
                  key: const Key('assign_courier_button'),
                  onPressed:
                      _waitingSelected.isNotEmpty && _selectedKuryeId != null && !_isAssigning
                      ? () => _onAssign(userId: userId, waitingOrders: waiting)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                  child: _isAssigning
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : Text('ATA (${_waitingSelected.length})'),
                ),
              ),
            ],
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
      child: Column(
        children: [
          _buildTableHeader(['MÜŞTERİ', 'SAAT', 'GÜZERGAH', 'İŞLEM']),
          const Divider(height: 1),
          if (waiting.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Bekleyen sipariş yok', style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ...waiting.map((s) => _buildWaitingRow(s, musteriMap, personelMap, ugramaMap)),
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
    required Map<String, String> musteriMap,
    required Map<String, String> personelMap,
  }) {
    return _PremiumCard(
      title: 'DEVAM EDEN İŞLER (${active.length})',
      icon: Icons.directions_bike_rounded,
      accentColor: const Color(0xFF6366F1),
      child: Column(
        children: [
          _buildTableHeader(['FİRMA/PERSONEL', 'SAAT', 'GÜZERGAH', 'DÜZENLE', 'KURYE & İŞLEM']),
          const Divider(height: 1),
          if (active.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Aktif iş yok', style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ...active.map(
              (s) => _buildActiveRow(
                s,
                userId,
                ugramaMap,
                kuryeMap,
                musteriMap,
                personelMap,
                active,
              ),
            ),
        ],
      ),
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
                  l,
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

  Widget _buildWaitingRow(
    Siparis s,
    Map<String, String> musteriMap,
    Map<String, String> personelMap,
    Map<String, String> ugramaMap,
  ) {
    final isSelected = _waitingSelected.contains(s.id);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    key: Key('waiting_${s.id}'),
                    value: isSelected,
                    onChanged: (v) {
                      setState(() {
                        if (v == true)
                          _waitingSelected.add(s.id);
                        else
                          _waitingSelected.remove(s.id);
                      });
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        musteriMap[s.musteriId] ?? s.musteriId,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                      if (s.personelId != null)
                        Text(
                          personelMap[s.personelId!] ?? '',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              s.createdAt != null
                  ? '${s.createdAt!.hour.toString().padLeft(2, '0')}:${s.createdAt!.minute.toString().padLeft(2, '0')}'
                  : '--:--',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _routeLabel(s, ugramaMap: ugramaMap),
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.edit_note_rounded, color: Color(0xFFF59E0B), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRow(
    Siparis s,
    String userId,
    Map<String, String> ugramaMap,
    Map<String, String> kuryeMap,
    Map<String, String> musteriMap,
    Map<String, String> personelMap,
    List<Siparis> active,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  key: Key('active_${s.id}'),
                  value: _activeSelected.contains(s.id),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _activeSelected.add(s.id);
                      } else {
                        _activeSelected.remove(s.id);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    musteriMap[s.musteriId] ?? s.musteriId,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  subtitle: s.personelId != null
                      ? Text(
                          personelMap[s.personelId!] ?? s.personelId!,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        )
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              s.createdAt != null
                  ? '${s.createdAt!.hour.toString().padLeft(2, '0')}:${s.createdAt!.minute.toString().padLeft(2, '0')}'
                  : '--:--',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _routeLabel(s, ugramaMap: ugramaMap),
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.edit_note_rounded, color: Color(0xFFF59E0B), size: 22),
            ),
          ),
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 150;
                final badge = Container(
                  width: isCompact ? double.infinity : null,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 8 : 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (kuryeMap[s.kuryeId] ?? 'Atanmadı').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
                final finishButton = SizedBox(
                  width: isCompact ? 36 : 72,
                  height: 32,
                  child: ElevatedButton(
                    key: Key('finish_${s.id}'),
                    onPressed: !_isFinishing
                        ? () {
                            _activeSelected.clear();
                            _activeSelected.add(s.id);
                            _onFinish(userId: userId, activeOrders: active);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isFinishing
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : isCompact
                        ? const Icon(Icons.check_rounded, size: 16)
                        : const Text(
                            'BİTTİ',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                  ),
                );

                return Row(
                  children: [
                    Flexible(child: badge),
                    SizedBox(width: isCompact ? 4 : 8),
                    finishButton,
                  ],
                );
              },
            ),
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
    final parts = [cikis, ugrama];
    if (s.ugrama1Id != null) {
      parts.add(ugramaMap[s.ugrama1Id!] ?? s.ugrama1Id!);
    }
    if (s.notId != null) {
      parts.add(ugramaMap[s.notId!] ?? s.notId!);
    }
    return parts.join(' → ');
  }
}

class _ClearDeskSelectionIntent extends Intent {
  const _ClearDeskSelectionIntent();
}

class _BackgroundEffect extends StatelessWidget {
  const _BackgroundEffect();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: const Color(0xFFF0F2F5),
          ),
        ),
        Positioned(
          top: -100,
          right: -100,
          child: _BlurredCircle(
            color: AppColors.primary.withValues(alpha: 0.08),
            size: 400,
          ),
        ),
        Positioned(
          bottom: -50,
          left: -100,
          child: _BlurredCircle(
            color: AppColors.secondary.withValues(alpha: 0.12),
            size: 350,
          ),
        ),
        Positioned(
          top: 200,
          left: 100,
          child: _BlurredCircle(
            color: AppColors.primary.withValues(alpha: 0.04),
            size: 200,
          ),
        ),
      ],
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  const _BlurredCircle({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: const SizedBox.shrink(),
    ).animate().scale(
      duration: 5.seconds,
      begin: const Offset(1, 1),
      end: const Offset(1.06, 1.06),
      curve: Curves.easeInOut,
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.title,
    required this.child,
    this.icon,
    this.accentColor,
    this.isDarkHeader = false,
    this.action,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Color? accentColor;
  final bool isDarkHeader;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final headerColor = isDarkHeader ? const Color(0xFF1D1B41) : Colors.white;
    final titleColor = isDarkHeader ? Colors.white : AppColors.textPrimary;

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
                    color: accentColor ?? (isDarkHeader ? Colors.white : AppColors.primary),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                ?action,
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

/// Stateful dialog that owns its own [TextEditingController] so it is
/// disposed together with the dialog widget, avoiding use-after-dispose
/// errors during the dismiss animation.
class _ManualPricingDialog extends StatefulWidget {
  const _ManualPricingDialog({super.key});

  @override
  State<_ManualPricingDialog> createState() => _ManualPricingDialogState();
}

class _ManualPricingDialogState extends State<_ManualPricingDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ücret Giriniz'),
      content: TextField(
        key: const Key('manual_price_field'),
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Ücret (₺)',
          hintText: '0.00',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        TextButton(
          key: const Key('manual_price_confirm'),
          onPressed: () {
            final parsed = double.tryParse(_controller.text);
            if (parsed != null && parsed > 0) {
              Navigator.of(context).pop(parsed);
            }
          },
          child: const Text('Onayla'),
        ),
      ],
    );
  }
}
