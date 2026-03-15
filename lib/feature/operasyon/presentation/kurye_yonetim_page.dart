import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/kurye/kurye_providers.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/navigation/logout_helper.dart';

class KuryeYonetimPage extends ConsumerStatefulWidget {
  const KuryeYonetimPage({super.key});

  @override
  ConsumerState<KuryeYonetimPage> createState() => _KuryeYonetimPageState();
}

class _KuryeYonetimPageState extends ConsumerState<KuryeYonetimPage> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _telefonController = TextEditingController();
  final _plakaController = TextEditingController();

  String? _editingId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _adController.dispose();
    _telefonController.dispose();
    _plakaController.dispose();
    super.dispose();
  }

  void _populateForm(Kurye kurye) {
    setState(() {
      _editingId = kurye.id;
      _adController.text = kurye.ad;
      _telefonController.text = kurye.telefon ?? '';
      _plakaController.text = kurye.plaka ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _adController.clear();
      _telefonController.clear();
      _plakaController.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(kuryeRepositoryProvider);

      final kurye = Kurye(
        id: _editingId ?? '',
        ad: _adController.text.trim(),
        telefon: _telefonController.text.trim().isNotEmpty
            ? _telefonController.text.trim()
            : null,
        plaka: _plakaController.text.trim().isNotEmpty
            ? _plakaController.text.trim()
            : null,
      );

      if (_editingId != null) {
        await repo.update(kurye);
      } else {
        await repo.create(kurye);
      }

      ref.invalidate(kuryeListProvider);
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingId != null ? 'Kurye güncellendi' : 'Kurye oluşturuldu',
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
    final listAsync = ref.watch(kuryeListProvider);

    return ResponsiveScaffold(
      title: 'Kurye Yönetimi',
      currentRoute: CustomRoute.kuryeYonetim,
      navItems: operasyonNavItems,
      headerTitle: 'Moto Kurye',
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          AppSectionCard(
            title: _editingId != null ? 'Kurye Düzenle' : 'Yeni Kurye',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                    controller: _plakaController,
                    decoration: const InputDecoration(labelText: 'Plaka'),
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
              title: 'Kuryeler (${list.length})',
              child: list.isEmpty
                  ? const Text('Henüz kurye yok.')
                  : Column(
                      children: list
                          .map(
                            (k) => ListTile(
                              title: Text(k.ad),
                              subtitle: Text(
                                [
                                  k.telefon ?? '—',
                                  if (k.plaka != null) k.plaka!,
                                ].join(' · '),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    k.isOnline
                                        ? Icons.wifi
                                        : Icons.wifi_off,
                                    size: 16,
                                    color: k.isOnline
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: k.isActive
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                              onTap: () => _populateForm(k),
                            ),
                          )
                          .toList(),
                    ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppSectionCard(
              title: 'Kuryeler',
              child: Text('Hata: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
