import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/musteri_personel/musteri_personel_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';

class MusteriPersonelKayitPage extends ConsumerStatefulWidget {
  const MusteriPersonelKayitPage({super.key});

  @override
  ConsumerState<MusteriPersonelKayitPage> createState() =>
      _MusteriPersonelKayitPageState();
}

class _MusteriPersonelKayitPageState
    extends ConsumerState<MusteriPersonelKayitPage> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();

  String? _editingId;
  String? _selectedMusteriId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _adController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateForm(MusteriPersonel personel) {
    setState(() {
      _editingId = personel.id;
      _selectedMusteriId = personel.musteriId;
      _adController.text = personel.ad;
      _telefonController.text = personel.telefon ?? '';
      _emailController.text = personel.email ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedMusteriId = null;
      _adController.clear();
      _telefonController.clear();
      _emailController.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(musteriPersonelRepositoryProvider);

      final personel = MusteriPersonel(
        id: _editingId ?? '',
        musteriId: _selectedMusteriId!,
        ad: _adController.text.trim(),
        telefon: _telefonController.text.trim().isNotEmpty
            ? _telefonController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
      );

      if (_editingId != null) {
        await repo.update(personel);
      } else {
        await repo.create(personel);
      }

      ref.invalidate(musteriPersonelListProvider);
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingId != null
                  ? 'Personel güncellendi'
                  : 'Personel oluşturuldu',
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
    final personelAsync = ref.watch(musteriPersonelListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Personel Kayıt')),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          AppSectionCard(
            title:
                _editingId != null ? 'Personel Düzenle' : 'Yeni Personel',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  musteriAsync.when(
                    data: (musteriler) =>
                        DropdownButtonFormField<String>(
                      initialValue: _selectedMusteriId,
                      decoration:
                          const InputDecoration(labelText: 'Müşteri *'),
                      items: musteriler
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.firmaKisaAd),
                            ),
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
                    controller: _adController,
                    decoration: const InputDecoration(labelText: 'Ad *'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Zorunlu alan'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _telefonController,
                    decoration: const InputDecoration(labelText: 'Telefon'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
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
          personelAsync.when(
            data: (list) {
              final musteriMap = <String, String>{};
              musteriAsync.whenData((musteriler) {
                for (final m in musteriler) {
                  musteriMap[m.id] = m.firmaKisaAd;
                }
              });

              return AppSectionCard(
                title: 'Personeller (${list.length})',
                child: list.isEmpty
                    ? const Text('Henüz personel yok.')
                    : Column(
                        children: list
                            .map(
                              (p) => ListTile(
                                title: Text(p.ad),
                                subtitle: Text(
                                  musteriMap[p.musteriId] ?? p.musteriId,
                                ),
                                trailing: Icon(
                                  Icons.circle,
                                  size: 12,
                                  color:
                                      p.isActive ? Colors.green : Colors.grey,
                                ),
                                onTap: () => _populateForm(p),
                              ),
                            )
                            .toList(),
                      ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppSectionCard(
              title: 'Personeller',
              child: Text('Hata: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
