import 'dart:async';
import 'dart:ui';

import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
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
import '../../../product/widgets/app_primary_button.dart';
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
    final hasDropdownErrors =
        _selectedMusteriId == null || _selectedCikisId == null || _selectedUgramaId == null;

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
        not1: _not1Controller.text.trim().isNotEmpty ? _not1Controller.text.trim() : null,
        olusturanId: userId,
      );

      await ref.read(siparisRepositoryProvider).create(siparis);

      // Reset form — clear everything including müşteri.
      setState(() {
        _selectedMusteriId = null;
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

    return ResponsiveScaffold(
      title: 'Operasyon Ekranı',
      currentRoute: CustomRoute.operasyonEkran,
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      showMobileDrawer: false,
      body: Stack(
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
      padding: ProjectPadding.all.normal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel 1: Order creation
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: _buildOrderCreationPanel(userId),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Panel 2 + 3: Dispatch
          Expanded(
            flex: 7,
            child: streamAsync.when(
              data: (orders) => _buildDispatchPanelsDesktop(orders, userId),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _PremiumCard(
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
          ),
        ),
      ],
    );
  }

  // ──────────── Panel 1: Order Creation ────────────

  Widget _buildOrderCreationPanel(String userId) {
    final musteriListAsync = ref.watch(musteriListProvider);

    return _PremiumCard(
      title: 'Sipariş Oluştur',
      icon: Icons.add_rounded,
      accentColor: AppColors.primary,
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

    return Form(
      key: _formKey,
      child: Column(
        children: [
          SearchableDropdown<String>(
            key: const Key('musteri_dropdown'),
            value: _selectedMusteriId,
            label: 'Müşteri',
            placeholder: 'Müşteri Seç',
            searchPlaceholder: 'Müşteri ara...',
            items: musteriItems,
            onChanged: _onMusteriChanged,
            validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_selectedMusteriId != null) ...[
            _buildStopDropdowns(),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _not1Controller,
              decoration: InputDecoration(
                labelText: 'Ek Not',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'SİPARİŞİ TAMAMLA',
              onPressed: () => _onCreateOrder(userId),
              isLoading: _isCreating,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStopDropdowns() {
    final ugramaAsync = ref.watch(ugramaListByMusteriProvider(_selectedMusteriId!));

    return ugramaAsync.when(
      data: (ugramalar) {
        final items = ugramalar.map((u) => (value: u.id, label: u.ugramaAdi)).toList();

        return Column(
          children: [
            SearchableDropdown<String>(
              key: const Key('cikis_dropdown'),
              value: _selectedCikisId,
              label: 'Çıkış',
              placeholder: 'Çıkış Noktası',
              searchPlaceholder: 'Ara...',
              items: items,
              onChanged: (v) => setState(() => _selectedCikisId = v),
              validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            SearchableDropdown<String>(
              key: const Key('ugrama_dropdown'),
              value: _selectedUgramaId,
              label: 'Varış',
              placeholder: 'Varış Noktası',
              searchPlaceholder: 'Ara...',
              items: items,
              onChanged: (v) => setState(() => _selectedUgramaId = v),
              validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            SearchableDropdown<String>(
              key: const Key('ugrama1_dropdown'),
              value: _selectedUgrama1Id,
              label: 'Ara Uğrama (Opsiyonel)',
              placeholder: 'Seçilmedi',
              searchPlaceholder: 'Ara...',
              items: items,
              onChanged: (v) => setState(() => _selectedUgrama1Id = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            SearchableDropdown<String>(
              key: const Key('not_dropdown'),
              value: _selectedNotId,
              label: 'Özel Not',
              placeholder: 'Seçilmedi',
              searchPlaceholder: 'Ara...',
              items: items,
              onChanged: (v) => setState(() => _selectedNotId = v),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => const Text('Uğramalar yüklenemedi.'),
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
      title: 'Bekleyenler',
      subtitle: '${waiting.length} Sipariş Bekliyor',
      icon: Icons.timer_rounded,
      accentColor: AppColors.secondary,
      child: Column(
        children: [
          if (waiting.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 48),
                    SizedBox(height: 8),
                    Text('Her şey yolunda, bekleyen yok.'),
                  ],
                ),
              ),
            )
          else
            ...waiting.map(
              (s) {
                final musteriAd = musteriMap[s.musteriId] ?? s.musteriId;
                final personelAd = s.personelId != null ? personelMap[s.personelId!] : null;
                final subtitle = [
                  if (personelAd != null) '$musteriAd / $personelAd' else musteriAd,
                  if (s.not1 != null) s.not1!,
                ].join(' — ');

                final isSelected = _waitingSelected.contains(s.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: CheckboxListTile(
                    key: Key('waiting_${s.id}'),
                    title: Text(
                      _routeLabel(s, ugramaMap: ugramaMap),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _waitingSelected.add(s.id);
                        } else {
                          _waitingSelected.remove(s.id);
                        }
                      });
                    },
                    checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: AppColors.secondary,
                    checkColor: AppColors.textPrimary,
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          kuryeListAsync.when(
            data: (kuryeler) {
              final activeKuryeler = kuryeler.where((k) => k.isActive).toList();
              return Column(
                children: [
                  SearchableDropdown<String>(
                    key: const Key('kurye_dropdown'),
                    value: _selectedKuryeId,
                    label: 'Kurye Ata',
                    placeholder: 'Kurye Seç',
                    searchPlaceholder: 'Kurye ara...',
                    items: activeKuryeler.map((k) => (value: k.id, label: k.ad)).toList(),
                    onChanged: (v) => setState(() => _selectedKuryeId = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _waitingSelected.isNotEmpty && _selectedKuryeId != null && !_isAssigning
                          ? () => _onAssign(
                              userId: userId,
                              waitingOrders: waiting,
                            )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isAssigning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : const Text('KURYE ATA', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('Kuryeler alınamadı.'),
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
    return _PremiumCard(
      title: 'Devam Edenler',
      subtitle: '${active.length} Kurye Yolda',
      icon: Icons.delivery_dining_rounded,
      accentColor: AppColors.primary,
      child: Column(
        children: [
          if (active.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  children: [
                    Icon(Icons.directions_bike_rounded, size: 48),
                    SizedBox(height: 8),
                    Text('Şu an aktif teslimat yok.'),
                  ],
                ),
              ),
            )
          else
            ...active.map(
              (s) {
                final isSelected = _activeSelected.contains(s.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: CheckboxListTile(
                    key: Key('active_${s.id}'),
                    title: Text(
                      _routeLabel(s, ugramaMap: ugramaMap),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Kurye: ${kuryeMap[s.kuryeId] ?? s.kuryeId ?? '-'}',
                    ),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _activeSelected.add(s.id);
                        } else {
                          _activeSelected.remove(s.id);
                        }
                      });
                    },
                    checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: AppColors.primary,
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _activeSelected.isNotEmpty && !_isFinishing
                  ? () => _onFinish(
                      userId: userId,
                      activeOrders: active,
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: _isFinishing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('TESLİMATI BİTİR', style: TextStyle(fontWeight: FontWeight.w800)),
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
    final cikis = ugramaMap[s.cikisId] ?? '?';
    final ugrama = ugramaMap[s.ugramaId] ?? '?';
    return '$cikis → $ugrama';
  }
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
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: 5.seconds,
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          curve: Curves.easeInOut,
        );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.accentColor,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (accentColor ?? AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor ?? AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1, color: Color(0x1A000000)),
              ),
              child,
            ],
          ),
        ),
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
