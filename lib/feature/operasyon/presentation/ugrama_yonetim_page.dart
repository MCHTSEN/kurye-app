import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_scaffold.dart';

class UgramaYonetimPage extends ConsumerStatefulWidget {
  const UgramaYonetimPage({super.key});

  @override
  ConsumerState<UgramaYonetimPage> createState() => _UgramaYonetimPageState();
}

class _UgramaYonetimPageState extends ConsumerState<UgramaYonetimPage> {
  final _formKey = GlobalKey<FormState>();
  final _ugramaAdiController = TextEditingController();
  final _adresController = TextEditingController();

  String? _editingId;
  bool _isSubmitting = false;

  /// Seçili müşteri ID'leri (atama için).
  final Set<String> _selectedMusteriIds = {};

  @override
  void dispose() {
    _ugramaAdiController.dispose();
    _adresController.dispose();
    super.dispose();
  }

  void _populateForm(Ugrama ugrama, List<String> musteriIds) {
    setState(() {
      _editingId = ugrama.id;
      _ugramaAdiController.text = ugrama.ugramaAdi;
      _adresController.text = ugrama.adres ?? '';
      _selectedMusteriIds
        ..clear()
        ..addAll(musteriIds);
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _ugramaAdiController.clear();
      _adresController.clear();
      _selectedMusteriIds.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final ugramaRepo = ref.read(ugramaRepositoryProvider);
      final bridgeRepo = ref.read(musteriUgramaRepositoryProvider);

      final ugrama = Ugrama(
        id: _editingId ?? '',
        ugramaAdi: _ugramaAdiController.text.trim(),
        adres: _adresController.text.trim().isNotEmpty
            ? _adresController.text.trim()
            : null,
      );

      String ugramaId;

      if (_editingId != null) {
        await ugramaRepo.update(ugrama);
        ugramaId = _editingId!;
      } else {
        final created = await ugramaRepo.create(ugrama);
        ugramaId = created.id;
      }

      // Müşteri atamalarını sync et.
      await bridgeRepo.syncMusterilerForUgrama(
        ugramaId,
        _selectedMusteriIds.toList(),
      );

      ref
        ..invalidate(ugramaListProvider)
        ..invalidate(musteriIdsByUgramaProvider);
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingId != null ? 'Uğrama güncellendi' : 'Uğrama oluşturuldu',
            ),
          ),
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
    final musteriAsync = ref.watch(musteriListProvider);
    final ugramaAsync = ref.watch(ugramaListProvider);

    return ResponsiveScaffold(
      title: 'Uğrama Yönetimi',
      currentRoute: CustomRoute.ugramaYonetim,
      navItems: operasyonNavItems,
      headerTitle: 'Moto Kurye',
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          _buildForm(musteriAsync),
          const SizedBox(height: AppSpacing.md),
          _buildUgramaList(ugramaAsync, musteriAsync),
        ],
      ),
    );
  }

  Widget _buildForm(AsyncValue<List<Musteri>> musteriAsync) {
    return AppSectionCard(
      title: _editingId != null ? 'Uğrama Düzenle' : 'Yeni Uğrama',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _ugramaAdiController,
              decoration: const InputDecoration(labelText: 'Uğrama Adı *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _adresController,
              decoration: const InputDecoration(labelText: 'Adres'),
            ),
            const SizedBox(height: AppSpacing.md),
            // Müşteri atama — multi-select chips
            Text(
              'Müşteri Ataması',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            musteriAsync.when(
              data: (musteriler) => _buildMusteriChips(musteriler),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Müşteri yüklenemedi: $e'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: _editingId != null ? 'Güncelle' : 'Kaydet',
                    onPressed: _onSubmit,
                    isLoading: _isSubmitting,
                  ),
                ),
                if (_editingId != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      child: const Text('İptal'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusteriChips(List<Musteri> musteriler) {
    if (musteriler.isEmpty) {
      return const Text('Henüz müşteri yok.');
    }

    return Wrap(
      spacing: AppSpacing.xxs,
      runSpacing: AppSpacing.xxs,
      children: musteriler.map((m) {
        final selected = _selectedMusteriIds.contains(m.id);
        return FilterChip(
          label: Text(m.firmaKisaAd),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedMusteriIds.add(m.id);
              } else {
                _selectedMusteriIds.remove(m.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildUgramaList(
    AsyncValue<List<Ugrama>> ugramaAsync,
    AsyncValue<List<Musteri>> musteriAsync,
  ) {
    return ugramaAsync.when(
      data: (list) {
        // Müşteri isim lookup map'i.
        final musteriMap = <String, String>{};
        if (musteriAsync case AsyncData(value: final musteriler)) {
          for (final m in musteriler) {
            musteriMap[m.id] = m.firmaKisaAd;
          }
        }

        return AppSectionCard(
          title: 'Uğramalar (${list.length})',
          child: list.isEmpty
              ? const Text('Henüz uğrama yok.')
              : Column(
                  children: list
                      .map(
                        (u) => _UgramaListTile(
                          ugrama: u,
                          musteriMap: musteriMap,
                          onTap: (musteriIds) => _populateForm(u, musteriIds),
                        ),
                      )
                      .toList(),
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppSectionCard(
        title: 'Uğramalar',
        child: Text('Hata: $e'),
      ),
    );
  }
}

/// Uğrama listesinde her uğrama için tile — atanmış müşterileri gösterir.
class _UgramaListTile extends ConsumerWidget {
  const _UgramaListTile({
    required this.ugrama,
    required this.musteriMap,
    required this.onTap,
  });

  final Ugrama ugrama;
  final Map<String, String> musteriMap;
  final void Function(List<String> musteriIds) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musteriIdsAsync = ref.watch(musteriIdsByUgramaProvider(ugrama.id));

    return musteriIdsAsync.when(
      data: (musteriIds) {
        final chipLabels = musteriIds
            .map((id) => musteriMap[id] ?? id)
            .toList();

        return ListTile(
          title: Text(ugrama.ugramaAdi),
          subtitle: chipLabels.isEmpty
              ? const Text(
                  'Atanmamış',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                )
              : Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: chipLabels
                      .map(
                        (label) => Chip(
                          label: Text(label, style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
          trailing: Icon(
            Icons.circle,
            size: 12,
            color: ugrama.isActive ? AppColors.secondary : AppColors.textMuted,
          ),
          onTap: () => onTap(musteriIds),
        );
      },
      loading: () => ListTile(
        title: Text(ugrama.ugramaAdi),
        subtitle: const LinearProgressIndicator(),
      ),
      error: (_, __) => ListTile(
        title: Text(ugrama.ugramaAdi),
        subtitle: const Text('Müşteri bilgisi yüklenemedi'),
        onTap: () => onTap([]),
      ),
    );
  }
}
