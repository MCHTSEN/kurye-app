import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/musteri_personel/musteri_personel_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/ugrama/ugrama_resolution_service.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/searchable_dropdown.dart';
import '../../../product/widgets/typeahead_field.dart';

const _createNewChoiceValue = '__create_new__';

class MusteriSiparisPage extends ConsumerStatefulWidget {
  const MusteriSiparisPage({super.key});

  @override
  ConsumerState<MusteriSiparisPage> createState() => _MusteriSiparisPageState();
}

class _MusteriSiparisPageState extends ConsumerState<MusteriSiparisPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCikisId;
  String? _selectedUgramaId;
  String? _selectedUgrama1Id;
  String? _selectedNotId;
  final _not1Controller = TextEditingController();
  String _cikisInput = '';
  String _ugramaInput = '';
  final _resolvedStopLabels = <String, String>{};

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
      _cikisInput = '';
      _ugramaInput = '';
      _not1Controller.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit({
    required String musteriId,
    required String userId,
  }) async {
    // Manual validation for SearchableDropdown fields (not FormField).
    final hasValidationErrors =
        (_selectedCikisId == null && _cikisInput.trim().isEmpty) ||
        (_selectedUgramaId == null && _ugramaInput.trim().isEmpty);

    if (!_formKey.currentState!.validate() || hasValidationErrors) {
      if (hasValidationErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen zorunlu alanları doldurunuz')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final resolvedCikisId = await _resolveRequiredStopId(
        musteriId: musteriId,
        fieldLabel: 'Çıkış',
        selectedId: _selectedCikisId,
        rawInput: _cikisInput,
      );
      if (resolvedCikisId == null) {
        return;
      }

      final resolvedUgramaId = await _resolveRequiredStopId(
        musteriId: musteriId,
        fieldLabel: 'Uğrama',
        selectedId: _selectedUgramaId,
        rawInput: _ugramaInput,
      );
      if (resolvedUgramaId == null) {
        return;
      }

      // Resolve personel_id — allowed to be null.
      final personelRepo = ref.read(musteriPersonelRepositoryProvider);
      final personel = await personelRepo.getByUserId(userId);

      final siparis = Siparis(
        id: '',
        musteriId: musteriId,
        cikisId: resolvedCikisId,
        ugramaId: resolvedUgramaId,
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

  Future<String?> _resolveRequiredStopId({
    required String musteriId,
    required String fieldLabel,
    required String? selectedId,
    required String rawInput,
  }) async {
    if (selectedId != null && selectedId.isNotEmpty) {
      return selectedId;
    }

    final input = rawInput.trim();
    if (input.isEmpty) return null;

    final service = ref.read(ugramaResolutionServiceProvider);
    var result = await service.resolveForMusteri(
      musteriId: musteriId,
      ugramaAdi: input,
      strategy: UgramaResolutionStrategy.auto,
    );

    if (result.resolutionType == UgramaResolutionType.notFound) {
      final shouldCreate = await _showCreateConfirmDialog(
        fieldLabel: fieldLabel,
        input: input,
      );
      if (shouldCreate != true) return null;
      result = await service.resolveForMusteri(
        musteriId: musteriId,
        ugramaAdi: input,
        strategy: UgramaResolutionStrategy.createNew,
      );
    } else if (result.resolutionType == UgramaResolutionType.ambiguousName) {
      final choice = await _showAmbiguousChoiceDialog(
        fieldLabel: fieldLabel,
        input: input,
        candidates: result.candidates,
      );
      if (choice == null) return null;

      if (choice == _createNewChoiceValue) {
        result = await service.resolveForMusteri(
          musteriId: musteriId,
          ugramaAdi: input,
          strategy: UgramaResolutionStrategy.createNew,
        );
      } else {
        result = await service.resolveForMusteri(
          musteriId: musteriId,
          ugramaAdi: input,
          strategy: UgramaResolutionStrategy.useExisting,
          preferredUgramaId: choice,
        );
      }
    }

    final resolvedId = result.resolvedUgramaId;
    if (resolvedId == null || resolvedId.isEmpty) {
      return null;
    }

    _resolvedStopLabels[resolvedId] = input;
    ref.invalidate(ugramaListByMusteriProvider(musteriId));
    return resolvedId;
  }

  Future<bool?> _showCreateConfirmDialog({
    required String fieldLabel,
    required String input,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Yeni Uğrama'),
          content: Text(
            '$fieldLabel için "$input" kaydı bulunamadı. Yeni uğrama olarak eklemek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hayır'),
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

  Future<String?> _showAmbiguousChoiceDialog({
    required String fieldLabel,
    required String input,
    required List<UgramaResolutionCandidate> candidates,
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$fieldLabel için Eşleşen Uğramalar'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$input" adına uygun kayıtlar bulundu. Mevcut bir kaydı seçebilir ya da yeni kayıt oluşturabilirsiniz.',
                ),
                const SizedBox(height: AppSpacing.sm),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      final subtitle =
                          (candidate.adres == null ||
                              candidate.adres!.trim().isEmpty)
                          ? 'Adres yok'
                          : candidate.adres!;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(candidate.ugramaAdi),
                        subtitle: Text(subtitle),
                        onTap: () =>
                            Navigator.of(dialogContext).pop(candidate.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_createNewChoiceValue),
              child: const Text('Yeni Oluştur'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    final isMobile = layoutTypeOf(context) == LayoutType.mobile;

    return ResponsiveScaffold(
      title: 'Sipariş Oluştur',
      currentRoute: CustomRoute.musteriSiparis,
      navItems: musteriNavItems,
      headerSubtitle: 'Müşteri',
      onLogout: logoutCallback(ref),
      showMobileDrawer: !isMobile,
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
    final activeOrdersAsync = ref.watch(
      siparisStreamByMusteriProvider(musteriId),
    );

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
        .map((u) => (value: u.id, label: u.ugramaAdi))
        .toList();

    return AppSectionCard(
      title: 'Siparis Formu',
      icon: Icons.edit_note_rounded,
      accentColor: AppColors.primary,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TypeaheadField<String>(
              key: const Key('cikis_typeahead'),
              value: _selectedCikisId,
              label: 'Çıkış *',
              placeholder: 'Çıkış Seç',
              items: dropdownItems,
              onChanged: (v) => setState(() => _selectedCikisId = v),
              onInputChanged: (value) => _cikisInput = value,
            ),
            const SizedBox(height: AppSpacing.xs),
            TypeaheadField<String>(
              key: const Key('ugrama_typeahead'),
              value: _selectedUgramaId,
              label: 'Uğrama *',
              placeholder: 'Uğrama Seç',
              items: dropdownItems,
              onChanged: (v) => setState(() => _selectedUgramaId = v),
              onInputChanged: (value) => _ugramaInput = value,
            ),
            const SizedBox(height: AppSpacing.xs),
            SearchableDropdown<String>(
              key: const Key('ugrama1_dropdown'),
              value: _selectedUgrama1Id,
              label: 'Uğrama1',
              placeholder: 'Seçilmedi',
              searchPlaceholder: 'Uğrama ara...',
              items: dropdownItems,
              onChanged: (v) => setState(() => _selectedUgrama1Id = v),
            ),
            const SizedBox(height: AppSpacing.xs),
            SearchableDropdown<String>(
              key: const Key('not_dropdown'),
              value: _selectedNotId,
              label: 'Not',
              placeholder: 'Seçilmedi',
              searchPlaceholder: 'Uğrama ara...',
              items: dropdownItems,
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
              onPressed: () => _onSubmit(musteriId: musteriId, userId: userId),
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
    final parts = [
      _displayStopLabel(siparis.cikisId, ugramaMap),
      _displayStopLabel(siparis.ugramaId, ugramaMap),
    ];
    if (siparis.ugrama1Id != null) {
      parts.add(_displayStopLabel(siparis.ugrama1Id!, ugramaMap));
    }
    if (siparis.notId != null) {
      parts.add(_displayStopLabel(siparis.notId!, ugramaMap));
    }
    final routeLabel = parts.join(' → ');
    final durumLabel = _durumLabel(siparis.durum);
    final durumColor = _durumColor(siparis.durum);

    return Card(
      child: ListTile(
        title: Text(routeLabel),
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

  String _displayStopLabel(String stopId, Map<String, String> ugramaMap) {
    return ugramaMap[stopId] ?? _resolvedStopLabels[stopId] ?? stopId;
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
      SiparisDurum.kuryeBekliyor => AppColors.secondary,
      SiparisDurum.devamEdiyor => AppColors.primary,
      SiparisDurum.tamamlandi => AppColors.secondaryDark,
      SiparisDurum.iptal => AppColors.primaryDark,
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
