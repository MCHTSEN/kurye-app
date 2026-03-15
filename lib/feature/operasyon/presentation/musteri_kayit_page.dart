import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/navigation/logout_helper.dart';

class MusteriKayitPage extends ConsumerStatefulWidget {
  const MusteriKayitPage({super.key});

  @override
  ConsumerState<MusteriKayitPage> createState() => _MusteriKayitPageState();
}

class _MusteriKayitPageState extends ConsumerState<MusteriKayitPage> {
  final _formKey = GlobalKey<FormState>();
  final _firmaKisaAdController = TextEditingController();
  final _firmaTamAdController = TextEditingController();
  final _telefonController = TextEditingController();
  final _adresController = TextEditingController();
  final _emailController = TextEditingController();
  final _vergiNoController = TextEditingController();

  String? _editingId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firmaKisaAdController.dispose();
    _firmaTamAdController.dispose();
    _telefonController.dispose();
    _adresController.dispose();
    _emailController.dispose();
    _vergiNoController.dispose();
    super.dispose();
  }

  void _populateForm(Musteri musteri) {
    setState(() {
      _editingId = musteri.id;
      _firmaKisaAdController.text = musteri.firmaKisaAd;
      _firmaTamAdController.text = musteri.firmaTamAd ?? '';
      _telefonController.text = musteri.telefon ?? '';
      _adresController.text = musteri.adres ?? '';
      _emailController.text = musteri.email ?? '';
      _vergiNoController.text = musteri.vergiNo ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _firmaKisaAdController.clear();
      _firmaTamAdController.clear();
      _telefonController.clear();
      _adresController.clear();
      _emailController.clear();
      _vergiNoController.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(musteriRepositoryProvider);

      final musteri = Musteri(
        id: _editingId ?? '',
        firmaKisaAd: _firmaKisaAdController.text.trim(),
        firmaTamAd: _firmaTamAdController.text.trim().isNotEmpty
            ? _firmaTamAdController.text.trim()
            : null,
        telefon: _telefonController.text.trim().isNotEmpty
            ? _telefonController.text.trim()
            : null,
        adres: _adresController.text.trim().isNotEmpty
            ? _adresController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        vergiNo: _vergiNoController.text.trim().isNotEmpty
            ? _vergiNoController.text.trim()
            : null,
      );

      if (_editingId != null) {
        await repo.update(musteri);
      } else {
        await repo.create(musteri);
      }

      ref.invalidate(musteriListProvider);
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingId != null
                  ? 'Müşteri güncellendi'
                  : 'Müşteri oluşturuldu',
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
    final listAsync = ref.watch(musteriListProvider);

    return ResponsiveScaffold(
      title: 'Müşteri Kayıt',
      currentRoute: CustomRoute.musteriKayit,
      navItems: operasyonNavItems,
      headerTitle: 'Moto Kurye',
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          AppSectionCard(
            title: _editingId != null ? 'Müşteri Düzenle' : 'Yeni Müşteri',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firmaKisaAdController,
                    decoration:
                        const InputDecoration(labelText: 'Firma Kısa Ad *'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Zorunlu alan'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _firmaTamAdController,
                    decoration:
                        const InputDecoration(labelText: 'Firma Tam Ad'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _telefonController,
                    decoration: const InputDecoration(labelText: 'Telefon'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _adresController,
                    decoration: const InputDecoration(labelText: 'Adres'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _vergiNoController,
                    decoration: const InputDecoration(labelText: 'Vergi No'),
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
          listAsync.when(
            data: (list) => AppSectionCard(
              title: 'Müşteriler (${list.length})',
              child: list.isEmpty
                  ? const Text('Henüz müşteri yok.')
                  : Column(
                      children: list
                          .map(
                            (m) => ListTile(
                              title: Text(m.firmaKisaAd),
                              subtitle: Text(m.telefon ?? '—'),
                              trailing: Icon(
                                Icons.circle,
                                size: 12,
                                color:
                                    m.isActive ? Colors.green : Colors.grey,
                              ),
                              onTap: () => _populateForm(m),
                            ),
                          )
                          .toList(),
                    ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppSectionCard(
              title: 'Müşteriler',
              child: Text('Hata: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
