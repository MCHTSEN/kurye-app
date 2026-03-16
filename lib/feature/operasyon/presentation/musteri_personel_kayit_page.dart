import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/musteri_personel/musteri_personel_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/searchable_dropdown.dart';
import '../../../product/widgets/workbench_split_view.dart';

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
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String? _editingId;
  String? _selectedMusteriId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _adController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
    final isDesktop = layoutTypeOf(context) == LayoutType.desktop;

    return ResponsiveScaffold(
      title: 'Personel Kayıt',
      currentRoute: CustomRoute.musteriPersonelKayit,
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
            header: personelAsync.maybeWhen(
              data: (list) => _buildHeader(list),
              orElse: () => null,
            ),
            editorPane: _buildEditorPane(musteriAsync),
            contentPane: personelAsync.when(
              data: (list) => _buildListPane(list, musteriAsync),
              loading: () => const AppSectionCard(
                title: 'Personeller',
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => AppSectionCard(
                title: 'Personeller',
                child: Text('Hata: $e'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<MusteriPersonel> list) {
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
                label: 'Toplam Personel',
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

  Widget _buildEditorPane(AsyncValue<List<Musteri>> musteriAsync) {
    return AppSectionCard(
      title: _editingId != null ? 'Personel Düzenle' : 'Yeni Personel',
      description:
          'Sol panel formu korur, sağ panel listede hızlı arama sağlar.',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              musteriAsync.when(
                data: (musteriler) => SearchableDropdown<String>(
                  value: _selectedMusteriId,
                  label: 'Müşteri *',
                  placeholder: 'Müşteri Seç',
                  searchPlaceholder: 'Müşteri ara...',
                  items: musteriler
                      .map(
                        (m) => (value: m.id, label: m.firmaKisaAd),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedMusteriId = v),
                  validator: (v) => v == null ? 'Müşteri seçiniz' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Müşteri yüklenemedi: $e'),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(labelText: 'Ad *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
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
    );
  }

  Widget _buildListPane(
    List<MusteriPersonel> list,
    AsyncValue<List<Musteri>> musteriAsync,
  ) {
    final musteriMap = <String, String>{};
    musteriAsync.whenData((musteriler) {
      for (final musteri in musteriler) {
        musteriMap[musteri.id] = musteri.firmaKisaAd;
      }
    });

    final isMobile = layoutTypeOf(context) == LayoutType.mobile;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = list.where((personel) {
      if (query.isEmpty) {
        return true;
      }

      return personel.ad.toLowerCase().contains(query) ||
          (personel.telefon?.toLowerCase().contains(query) ?? false) ||
          (personel.email?.toLowerCase().contains(query) ?? false) ||
          (musteriMap[personel.musteriId]?.toLowerCase().contains(query) ??
              false);
    }).toList();

    final listView = filtered.isEmpty
        ? const Text('Henüz personel yok.')
        : ListView.separated(
            shrinkWrap: isMobile,
            physics: isMobile ? const NeverScrollableScrollPhysics() : null,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final personel = filtered[index];
              final isSelected = personel.id == _editingId;
              return Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(personel.ad),
                  subtitle: Text(
                    [
                      musteriMap[personel.musteriId] ?? personel.musteriId,
                      personel.email ?? 'Email yok',
                    ].join(' · '),
                  ),
                  trailing: Icon(
                    Icons.circle,
                    size: 12,
                    color: personel.isActive
                        ? AppColors.secondary
                        : AppColors.textMuted,
                  ),
                  onTap: () => _populateForm(personel),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
          );

    final card = AppSectionCard(
      title: 'Personeller (${filtered.length})',
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
