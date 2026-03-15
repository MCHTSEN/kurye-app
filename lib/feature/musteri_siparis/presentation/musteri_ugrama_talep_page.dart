import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_scaffold.dart';

class MusteriUgramaTalepPage extends ConsumerStatefulWidget {
  const MusteriUgramaTalepPage({super.key});

  @override
  ConsumerState<MusteriUgramaTalepPage> createState() =>
      _MusteriUgramaTalepPageState();
}

class _MusteriUgramaTalepPageState
    extends ConsumerState<MusteriUgramaTalepPage> {
  final _formKey = GlobalKey<FormState>();
  final _ugramaAdiController = TextEditingController();
  final _adresController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _ugramaAdiController.dispose();
    _adresController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _ugramaAdiController.clear();
    _adresController.clear();
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit({
    required String musteriId,
    required String userId,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(ugramaTalebiRepositoryProvider);

      final talep = UgramaTalebi(
        id: '',
        musteriId: musteriId,
        talepEdenId: userId,
        ugramaAdi: _ugramaAdiController.text.trim(),
        adres: _adresController.text.trim().isNotEmpty
            ? _adresController.text.trim()
            : null,
      );

      await repo.create(talep);

      ref.invalidate(taleplerByMusteriProvider(musteriId));
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uğrama talebi gönderildi')),
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
      title: 'Uğrama Talepleri',
      currentRoute: CustomRoute.musteriUgramaTalep,
      navItems: musteriNavItems,
      headerTitle: 'Moto Kurye',
      headerSubtitle: 'Müşteri',
      onLogout: logoutCallback(ref),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null || profile.musteriId == null) {
            return const Center(
              child: Text('Müşteri bilgisi bulunamadı.'),
            );
          }
          return _buildContent(
            musteriId: profile.musteriId!,
            userId: profile.id,
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
  }) {
    final taleplerAsync = ref.watch(taleplerByMusteriProvider(musteriId));

    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        _buildForm(musteriId: musteriId, userId: userId),
        const SizedBox(height: AppSpacing.md),
        _buildTalepList(taleplerAsync),
      ],
    );
  }

  Widget _buildForm({
    required String musteriId,
    required String userId,
  }) {
    return AppSectionCard(
      title: 'Yeni Uğrama Talebi',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _ugramaAdiController,
              decoration: const InputDecoration(
                labelText: 'Uğrama Adı *',
                hintText: 'Örn: Merkez Ofis',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _adresController,
              decoration: const InputDecoration(
                labelText: 'Adres',
                hintText: 'Örn: Nilüfer, Bursa',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Talep Gönder',
              onPressed: () =>
                  _onSubmit(musteriId: musteriId, userId: userId),
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTalepList(AsyncValue<List<UgramaTalebi>> taleplerAsync) {
    return taleplerAsync.when(
      data: (talepler) {
        return AppSectionCard(
          title: 'Talepleriniz (${talepler.length})',
          child: talepler.isEmpty
              ? const Text('Henüz talep göndermediniz.')
              : Column(
                  children: talepler.map(_buildTalepCard).toList(),
                ),
        );
      },
      loading: () => const AppSectionCard(
        title: 'Talepleriniz',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppSectionCard(
        title: 'Talepleriniz',
        child: Text('Hata: $e'),
      ),
    );
  }

  Widget _buildTalepCard(UgramaTalebi talep) {
    final durumLabel = _durumLabel(talep.durum);
    final durumColor = _durumColor(talep.durum);

    return Card(
      child: ListTile(
        title: Text(talep.ugramaAdi),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (talep.adres != null) Text(talep.adres!),
            if (talep.durum == UgramaTalepDurum.reddedildi &&
                talep.redNotu != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Red notu: ${talep.redNotu}',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (talep.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _formatDate(talep.createdAt!),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
          ],
        ),
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

  String _durumLabel(UgramaTalepDurum durum) {
    return switch (durum) {
      UgramaTalepDurum.beklemede => 'Beklemede',
      UgramaTalepDurum.onaylandi => 'Onaylandı',
      UgramaTalepDurum.reddedildi => 'Reddedildi',
    };
  }

  Color _durumColor(UgramaTalepDurum durum) {
    return switch (durum) {
      UgramaTalepDurum.beklemede => Colors.orange,
      UgramaTalepDurum.onaylandi => Colors.green,
      UgramaTalepDurum.reddedildi => Colors.red,
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
