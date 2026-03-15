import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/searchable_dropdown.dart';

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
  String? _selectedMusteriId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _ugramaAdiController.dispose();
    _adresController.dispose();
    super.dispose();
  }

  void _populateForm(Ugrama ugrama) {
    setState(() {
      _editingId = ugrama.id;
      _selectedMusteriId = ugrama.musteriId;
      _ugramaAdiController.text = ugrama.ugramaAdi;
      _adresController.text = ugrama.adres ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedMusteriId = null;
      _ugramaAdiController.clear();
      _adresController.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(ugramaRepositoryProvider);

      final ugrama = Ugrama(
        id: _editingId ?? '',
        musteriId: _selectedMusteriId!,
        ugramaAdi: _ugramaAdiController.text.trim(),
        adres: _adresController.text.trim().isNotEmpty
            ? _adresController.text.trim()
            : null,
      );

      if (_editingId != null) {
        await repo.update(ugrama);
      } else {
        await repo.create(ugrama);
      }

      ref.invalidate(ugramaListProvider);
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
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          AppSectionCard(
            title: _editingId != null ? 'Uğrama Düzenle' : 'Yeni Uğrama',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  musteriAsync.when(
                    data: (musteriler) =>
                        SearchableDropdown<String>(
                      value: _selectedMusteriId,
                      label: 'Müşteri *',
                      placeholder: 'Müşteri Seç',
                      searchPlaceholder: 'Müşteri ara...',
                      items: musteriler
                          .map(
                            (m) => (value: m.id, label: m.firmaKisaAd),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedMusteriId = v),
                      validator: (v) =>
                          v == null ? 'Müşteri seçiniz' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Müşteri yüklenemedi: $e'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _ugramaAdiController,
                    decoration:
                        const InputDecoration(labelText: 'Uğrama Adı *'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Zorunlu alan'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _adresController,
                    decoration: const InputDecoration(labelText: 'Adres'),
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
          ),
          const SizedBox(height: AppSpacing.md),
          ugramaAsync.when(
            data: (list) {
              // Build a müşteri name lookup
              final musteriMap = <String, String>{};
              musteriAsync.whenData((musteriler) {
                for (final m in musteriler) {
                  musteriMap[m.id] = m.firmaKisaAd;
                }
              });

              return AppSectionCard(
                title: 'Uğramalar (${list.length})',
                child: list.isEmpty
                    ? const Text('Henüz uğrama yok.')
                    : Column(
                        children: list
                            .map(
                              (u) => ListTile(
                                title: Text(u.ugramaAdi),
                                subtitle: Text(
                                  musteriMap[u.musteriId] ?? u.musteriId,
                                ),
                                trailing: Icon(
                                  Icons.circle,
                                  size: 12,
                                  color:
                                      u.isActive ? Colors.green : Colors.grey,
                                ),
                                onTap: () => _populateForm(u),
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
          ),
        ],
      ),
    );
  }
}
