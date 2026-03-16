import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/kurye/kurye_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/workbench_split_view.dart';

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
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String? _editingId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _adController.dispose();
    _telefonController.dispose();
    _plakaController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
    final isDesktop = layoutTypeOf(context) == LayoutType.desktop;

    return ResponsiveScaffold(
      title: 'Kurye Yönetimi',
      currentRoute: CustomRoute.kuryeYonetim,
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
                title: 'Kuryeler',
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => AppSectionCard(
                title: 'Kuryeler',
                child: Text('Hata: $e'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Kurye> list) {
    final isMobile = layoutTypeOf(context) == LayoutType.mobile;
    final activeCount = list.where((item) => item.isActive).length;
    final onlineCount = list.where((item) => item.isOnline).length;

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
                label: 'Toplam Kurye',
                value: '${list.length}',
                accentColor: AppColors.primary,
              ),
              _HeaderMetric(
                label: 'Aktif',
                value: '$activeCount',
                accentColor: AppColors.secondary,
              ),
              _HeaderMetric(
                label: 'Online',
                value: '$onlineCount',
                accentColor: AppColors.primary,
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
      title: _editingId != null ? 'Kurye Düzenle' : 'Yeni Kurye',
      description: 'Form solda sabit, liste sağda hız odaklı taranır.',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
    );
  }

  Widget _buildListPane(List<Kurye> list) {
    final isMobile = layoutTypeOf(context) == LayoutType.mobile;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = list.where((kurye) {
      if (query.isEmpty) {
        return true;
      }

      return kurye.ad.toLowerCase().contains(query) ||
          (kurye.telefon?.toLowerCase().contains(query) ?? false) ||
          (kurye.plaka?.toLowerCase().contains(query) ?? false);
    }).toList();

    final listView = filtered.isEmpty
        ? const Text('Henüz kurye yok.')
        : ListView.separated(
            shrinkWrap: isMobile,
            physics: isMobile ? const NeverScrollableScrollPhysics() : null,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final kurye = filtered[index];
              final isSelected = kurye.id == _editingId;
              return Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(kurye.ad),
                  subtitle: Text(
                    [
                      kurye.telefon ?? 'Telefon yok',
                      kurye.plaka ?? 'Plaka yok',
                    ].join(' · '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        kurye.isOnline ? Icons.wifi : Icons.wifi_off,
                        size: 16,
                        color: kurye.isOnline
                            ? AppColors.secondary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: kurye.isActive
                            ? AppColors.secondary
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                  onTap: () => _populateForm(kurye),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
          );

    final card = AppSectionCard(
      title: 'Kuryeler (${filtered.length})',
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
