import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/musteri_personel/musteri_personel_providers.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';

class MusteriSiparisPage extends ConsumerStatefulWidget {
  const MusteriSiparisPage({super.key});

  @override
  ConsumerState<MusteriSiparisPage> createState() =>
      _MusteriSiparisPageState();
}

class _MusteriSiparisPageState extends ConsumerState<MusteriSiparisPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCikisId;
  String? _selectedUgramaId;
  String? _selectedUgrama1Id;
  String? _selectedNotId;
  final _not1Controller = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _not1Controller.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _selectedCikisId = null;
      _selectedUgramaId = null;
      _selectedUgrama1Id = null;
      _selectedNotId = null;
      _not1Controller.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit({
    required String musteriId,
    required String userId,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Resolve personel_id — allowed to be null.
      final personelRepo = ref.read(musteriPersonelRepositoryProvider);
      final personel = await personelRepo.getByUserId(userId);

      final siparis = Siparis(
        id: '',
        musteriId: musteriId,
        cikisId: _selectedCikisId!,
        ugramaId: _selectedUgramaId!,
        ugrama1Id: _selectedUgrama1Id,
        notId: _selectedNotId,
        not1: _not1Controller.text.trim().isNotEmpty
            ? _not1Controller.text.trim()
            : null,
        personelId: personel?.id,
        olusturanId: userId,
        // durum defaults to kuryeBekliyor in constructor
      );

      await ref.read(siparisRepositoryProvider).create(siparis);

      // Invalidate stream so active orders list refreshes.
      ref.invalidate(siparisStreamByMusteriProvider(musteriId));

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sipariş oluşturuldu')),
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
    final profileAsync = ref.watch(currentUserProfileProvider);

    return ResponsiveScaffold(
      title: 'Sipariş Oluştur',
      currentRoute: CustomRoute.musteriSiparis,
      navItems: musteriNavItems,
      headerTitle: 'Moto Kurye',
      headerSubtitle: 'Müşteri',
      body: profileAsync.when(
        data: (profile) {
          if (profile == null || profile.musteriId == null) {
            return const Center(
              child: Text('Müşteri bilgisi bulunamadı.'),
            );
          }

          final musteriId = profile.musteriId!;
          return _buildContent(
            musteriId: musteriId,
            userId: profile.id,
            displayName: profile.displayName,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildContent({
    required String musteriId,
    required String userId,
    required String displayName,
  }) {
    final ugramaListAsync = ref.watch(ugramaListByMusteriProvider(musteriId));
    final activeOrdersAsync =
        ref.watch(siparisStreamByMusteriProvider(musteriId));

    final type = layoutTypeOf(context);
    if (type == LayoutType.mobile) {
      return _buildMobileContent(
        musteriId: musteriId,
        userId: userId,
        displayName: displayName,
        ugramaListAsync: ugramaListAsync,
        activeOrdersAsync: activeOrdersAsync,
      );
    }
    return _buildDesktopContent(
      musteriId: musteriId,
      userId: userId,
      displayName: displayName,
      ugramaListAsync: ugramaListAsync,
      activeOrdersAsync: activeOrdersAsync,
    );
  }

  Widget _buildMobileContent({
    required String musteriId,
    required String userId,
    required String displayName,
    required AsyncValue<List<Ugrama>> ugramaListAsync,
    required AsyncValue<List<Siparis>> activeOrdersAsync,
  }) {
    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        AppSectionCard(
          title: 'Hoş geldiniz, $displayName',
          child: const Text('Yeni sipariş oluşturmak için formu doldurun.'),
        ),
        const SizedBox(height: AppSpacing.md),
        ugramaListAsync.when(
          data: (ugramalar) => _buildOrderForm(
            ugramalar: ugramalar,
            musteriId: musteriId,
            userId: userId,
          ),
          loading: () => const AppSectionCard(
            title: 'Sipariş Formu',
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => AppSectionCard(
            title: 'Sipariş Formu',
            child: Text('Uğrama listesi yüklenemedi: $e'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActiveOrders(activeOrdersAsync, ugramaListAsync),
      ],
    );
  }

  Widget _buildDesktopContent({
    required String musteriId,
    required String userId,
    required String displayName,
    required AsyncValue<List<Ugrama>> ugramaListAsync,
    required AsyncValue<List<Siparis>> activeOrdersAsync,
  }) {
    return Padding(
      padding: ProjectPadding.all.large,
      child: ContentConstraint(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSectionCard(
                      title: 'Hoş geldiniz, $displayName',
                      child: const Text(
                        'Yeni sipariş oluşturmak için formu doldurun.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ugramaListAsync.when(
                      data: (ugramalar) => _buildOrderForm(
                        ugramalar: ugramalar,
                        musteriId: musteriId,
                        userId: userId,
                      ),
                      loading: () => const AppSectionCard(
                        title: 'Sipariş Formu',
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => AppSectionCard(
                        title: 'Sipariş Formu',
                        child: Text('Uğrama listesi yüklenemedi: $e'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                child: _buildActiveOrders(
                  activeOrdersAsync,
                  ugramaListAsync,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderForm({
    required List<Ugrama> ugramalar,
    required String musteriId,
    required String userId,
  }) {
    final dropdownItems = ugramalar
        .map(
          (u) => DropdownMenuItem<String>(
            value: u.id,
            child: Text(u.ugramaAdi),
          ),
        )
        .toList();

    return AppSectionCard(
      title: 'Sipariş Formu',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              key: const Key('cikis_dropdown'),
              value: _selectedCikisId,
              decoration: const InputDecoration(labelText: 'Çıkış *'),
              items: dropdownItems,
              onChanged: (v) => setState(() => _selectedCikisId = v),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              key: const Key('ugrama_dropdown'),
              value: _selectedUgramaId,
              decoration: const InputDecoration(labelText: 'Uğrama *'),
              items: dropdownItems,
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
                ...dropdownItems,
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
                ...dropdownItems,
              ],
              onChanged: (v) => setState(() => _selectedNotId = v),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _not1Controller,
              decoration: const InputDecoration(labelText: 'Not1'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Sipariş Oluştur',
              onPressed: () =>
                  _onSubmit(musteriId: musteriId, userId: userId),
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrders(
    AsyncValue<List<Siparis>> ordersAsync,
    AsyncValue<List<Ugrama>> ugramaAsync,
  ) {
    return ordersAsync.when(
      data: (orders) {
        final activeOrders = orders
            .where(
              (s) =>
                  s.durum == SiparisDurum.kuryeBekliyor ||
                  s.durum == SiparisDurum.devamEdiyor,
            )
            .toList();

        // Build ugrama name map for display.
        final ugramaMap = <String, String>{};
        if (ugramaAsync case AsyncData(value: final ugramalar)) {
          for (final u in ugramalar) {
            ugramaMap[u.id] = u.ugramaAdi;
          }
        }

        return AppSectionCard(
          title: 'Aktif Siparişler (${activeOrders.length})',
          child: activeOrders.isEmpty
              ? const Text('Aktif sipariş yok.')
              : Column(
                  children: activeOrders
                      .map((s) => _buildOrderCard(s, ugramaMap))
                      .toList(),
                ),
        );
      },
      loading: () => const AppSectionCard(
        title: 'Aktif Siparişler',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppSectionCard(
        title: 'Aktif Siparişler',
        child: Text('Hata: $e'),
      ),
    );
  }

  Widget _buildOrderCard(Siparis siparis, Map<String, String> ugramaMap) {
    final cikisAdi = ugramaMap[siparis.cikisId] ?? siparis.cikisId;
    final ugramaAdi = ugramaMap[siparis.ugramaId] ?? siparis.ugramaId;
    final durumLabel = _durumLabel(siparis.durum);
    final durumColor = _durumColor(siparis.durum);

    return Card(
      child: ListTile(
        title: Text('$cikisAdi → $ugramaAdi'),
        subtitle: siparis.createdAt != null
            ? Text(_formatDate(siparis.createdAt!))
            : null,
        trailing: Chip(
          label: Text(
            durumLabel,
            style: TextStyle(color: durumColor, fontSize: 12),
          ),
          backgroundColor: durumColor.withValues(alpha: 0.1),
          side: BorderSide.none,
        ),
      ),
    );
  }

  String _durumLabel(SiparisDurum durum) {
    return switch (durum) {
      SiparisDurum.kuryeBekliyor => 'Kurye Bekliyor',
      SiparisDurum.devamEdiyor => 'Devam Ediyor',
      SiparisDurum.tamamlandi => 'Tamamlandı',
      SiparisDurum.iptal => 'İptal',
    };
  }

  Color _durumColor(SiparisDurum durum) {
    return switch (durum) {
      SiparisDurum.kuryeBekliyor => Colors.orange,
      SiparisDurum.devamEdiyor => Colors.blue,
      SiparisDurum.tamamlandi => Colors.green,
      SiparisDurum.iptal => Colors.red,
    };
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
