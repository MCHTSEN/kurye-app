import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/workbench_split_view.dart';

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
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

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
    _searchController.dispose();
    _searchFocusNode.dispose();
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
    final isDesktop = layoutTypeOf(context) == LayoutType.desktop;

    return ResponsiveScaffold(
      title: 'Müşteri Kayıt',
      currentRoute: CustomRoute.musteriKayit,
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      showMobileDrawer: false,
      body: Shortcuts(
        shortcuts: isDesktop
            ? const {
                SingleActivator(LogicalKeyboardKey.slash): _FocusSearchIntent(),
                SingleActivator(LogicalKeyboardKey.escape):
                    _ClearSelectionIntent(),
              }
            : const {},
        child: Actions(
          actions: {
            _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
              onInvoke: (_) {
                _searchFocusNode.requestFocus();
                return null;
              },
            ),
            _ClearSelectionIntent: CallbackAction<_ClearSelectionIntent>(
              onInvoke: (_) {
                _clearForm();
                return null;
              },
            ),
          },
          child: WorkbenchSplitView(
            header: listAsync.maybeWhen(
              data: (list) => _buildHeader(list),
              orElse: () => null,
            ),
            editorPane: _buildEditorPane(),
            contentPane: listAsync.when(
              data: _buildListPane,
              loading: () => const AppSectionCard(
                title: 'Müşteriler',
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => AppSectionCard(
                title: 'Müşteriler',
                child: Text('Hata: $e'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Musteri> list) {
    final isMobile = layoutTypeOf(context) == LayoutType.mobile;
    final activeCount = list.where((item) => item.isActive).length;

    return Container(
      padding: ProjectPadding.all.normal,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _HeaderMetric(
                label: 'Toplam Müşteri',
                value: '${list.length}',
                accentColor: AppColors.primary,
              ),
              _HeaderMetric(
                label: 'Aktif',
                value: '$activeCount',
                accentColor: AppColors.secondary,
              ),
            ],
          ),
          if (!isMobile) const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: isMobile ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              _editingId == null ? 'Yeni kayıt modu' : 'Düzenleme modu açık',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorPane() {
    return AppSectionCard(
      title: _editingId != null ? 'Müşteri Düzenle' : 'Yeni Müşteri',
      description:
          'Desktop akışında form solda sabit kalır, liste sağda filtrelenir.',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firmaKisaAdController,
                decoration: const InputDecoration(
                  labelText: 'Firma Kısa Ad *',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _firmaTamAdController,
                decoration: const InputDecoration(labelText: 'Firma Tam Ad'),
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
                maxLines: 2,
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
    );
  }

  Widget _buildListPane(List<Musteri> list) {
    final isMobile = layoutTypeOf(context) == LayoutType.mobile;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = list.where((item) {
      if (query.isEmpty) {
        return true;
      }

      return item.firmaKisaAd.toLowerCase().contains(query) ||
          (item.firmaTamAd?.toLowerCase().contains(query) ?? false) ||
          (item.telefon?.toLowerCase().contains(query) ?? false) ||
          (item.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    final listView = filtered.isEmpty
        ? const Text('Henüz müşteri yok.')
        : ListView.separated(
            shrinkWrap: isMobile,
            physics: isMobile ? const NeverScrollableScrollPhysics() : null,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final musteri = filtered[index];
              final isSelected = musteri.id == _editingId;

              return Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(musteri.firmaKisaAd),
                  subtitle: Text(
                    [
                      musteri.telefon ?? 'Telefon yok',
                      musteri.email ?? 'Email yok',
                    ].join(' · '),
                  ),
                  trailing: Icon(
                    Icons.circle,
                    size: 12,
                    color: musteri.isActive
                        ? AppColors.secondary
                        : AppColors.textMuted,
                  ),
                  onTap: () => _populateForm(musteri),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
          );

    final card = AppSectionCard(
      title: 'Müşteriler (${filtered.length})',
      trailing: SizedBox(
        width: 260,
        child: TextField(
          focusNode: _searchFocusNode,
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Ara... (/)',
            prefixIcon: Icon(Icons.search_rounded),
            isDense: true,
          ),
        ),
      ),
      child: listView,
    );

    return isMobile ? card : SizedBox.expand(child: card);
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _ClearSelectionIntent extends Intent {
  const _ClearSelectionIntent();
}
