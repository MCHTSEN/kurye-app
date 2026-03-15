import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/kurye/kurye_providers.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/siparis/siparis_log_providers.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';

final _log = Logger();

class OperasyonEkranPage extends ConsumerStatefulWidget {
  const OperasyonEkranPage({super.key});

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

  @override
  void dispose() {
    _not1Controller.dispose();
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
    if (!_formKey.currentState!.validate()) return;

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

    return Scaffold(
      appBar: AppBar(title: const Text('Operasyon Ekranı')),
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

    // Clear selections when stream emits new data.
    ref.listen(siparisStreamActiveProvider, (prev, next) {
      if (next is AsyncData<List<Siparis>>) {
        setState(() {
          _waitingSelected.clear();
          _activeSelected.clear();
        });
      }
    });

    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        _buildOrderCreationPanel(profile.id),
        const SizedBox(height: AppSpacing.md),
        streamAsync.when(
          data: (orders) => _buildDispatchPanels(orders, profile.id),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppSectionCard(
            title: 'Siparişler',
            child: Text('Hata: $e'),
          ),
        ),
      ],
    );
  }

  Widget _buildDispatchPanels(List<Siparis> allOrders, String userId) {
    final waiting = allOrders
        .where((s) => s.durum == SiparisDurum.kuryeBekliyor)
        .toList();
    final active = allOrders
        .where((s) => s.durum == SiparisDurum.devamEdiyor)
        .toList();

    return Column(
      children: [
        _buildWaitingPanel(waiting, userId),
        const SizedBox(height: AppSpacing.md),
        _buildActivePanel(active, userId),
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
        .map(
          (m) => DropdownMenuItem<String>(
            value: m.id,
            child: Text(m.firmaKisaAd),
          ),
        )
        .toList();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: const Key('musteri_dropdown'),
            value: _selectedMusteriId,
            decoration: const InputDecoration(labelText: 'Müşteri *'),
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
            .map(
              (u) => DropdownMenuItem<String>(
                value: u.id,
                child: Text(u.ugramaAdi),
              ),
            )
            .toList();

        return Column(
          children: [
            DropdownButtonFormField<String>(
              key: const Key('cikis_dropdown'),
              value: _selectedCikisId,
              decoration: const InputDecoration(labelText: 'Çıkış *'),
              items: items,
              onChanged: (v) => setState(() => _selectedCikisId = v),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              key: const Key('ugrama_dropdown'),
              value: _selectedUgramaId,
              decoration: const InputDecoration(labelText: 'Uğrama *'),
              items: items,
              onChanged: (v) => setState(() => _selectedUgramaId = v),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              key: const Key('ugrama1_dropdown'),
              value: _selectedUgrama1Id,
              decoration: const InputDecoration(labelText: 'Uğrama1'),
              items: [
                const DropdownMenuItem<String>(
                  child: Text('— Seçilmedi —'),
                ),
                ...items,
              ],
              onChanged: (v) => setState(() => _selectedUgrama1Id = v),
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              key: const Key('not_dropdown'),
              value: _selectedNotId,
              decoration: const InputDecoration(labelText: 'Not'),
              items: [
                const DropdownMenuItem<String>(
                  child: Text('— Seçilmedi —'),
                ),
                ...items,
              ],
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

  Widget _buildWaitingPanel(List<Siparis> waiting, String userId) {
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
                title: Text(_routeLabel(s)),
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
                  DropdownButtonFormField<String>(
                    key: const Key('kurye_dropdown'),
                    value: _selectedKuryeId,
                    decoration:
                        const InputDecoration(labelText: 'Kurye Seç'),
                    items: activeKuryeler
                        .map(
                          (k) => DropdownMenuItem<String>(
                            value: k.id,
                            child: Text(k.ad),
                          ),
                        )
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

  Widget _buildActivePanel(List<Siparis> active, String userId) {
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
                title: Text(_routeLabel(s)),
                subtitle: Text('Kurye: ${s.kuryeId ?? '-'}'),
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

  String _routeLabel(Siparis s) => '${s.cikisId} → ${s.ugramaId}';
}
