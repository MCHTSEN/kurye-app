import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../product/widgets/responsive_layout.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/workbench_split_view.dart';

class UgramaYonetimPage extends ConsumerStatefulWidget {
  const UgramaYonetimPage({super.key});

  @override
  ConsumerState<UgramaYonetimPage> createState() => _UgramaYonetimPageState();
}

class _UgramaYonetimPageState extends ConsumerState<UgramaYonetimPage> {
  final _formKey = GlobalKey<FormState>();
  final _ugramaAdiController = TextEditingController();
  final _adresController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String? _editingId;
  bool _isSubmitting = false;
  final Set<String> _selectedMusteriIds = {};

  @override
  void dispose() {
    _ugramaAdiController.dispose();
    _adresController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final musteriAsync = ref.watch(musteriListProvider);
    final ugramaAsync = ref.watch(ugramaListProvider);
    final isDesktop = layoutTypeOf(context) == LayoutType.desktop;

    return ResponsiveScaffold(
      title: 'Uğrama Yönetimi',
      currentRoute: CustomRoute.ugramaYonetim,
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
            header: ugramaAsync.maybeWhen(
              data: _buildHeader,
              orElse: () => null,
            ),
            editorPane: _buildFormPane(musteriAsync),
            contentPane: _buildUgramaListPane(ugramaAsync, musteriAsync),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Ugrama> list) {
    final isMobile = layoutTypeOf(context) == LayoutType.mobile;
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
                label: 'Toplam Uğrama',
                value: '${list.length}',
                accentColor: AppColors.primary,
              ),
              _HeaderMetric(
                label: 'Atama',
                value: _selectedMusteriIds.isEmpty
                    ? 'Boş'
                    : '${_selectedMusteriIds.length}',
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

  Widget _buildFormPane(AsyncValue<List<Musteri>> musteriAsync) {
    return AppSectionCard(
      title: _editingId != null ? 'Uğrama Düzenle' : 'Yeni Uğrama',
      description: 'Sol panel atama ve düzenlemeyi sabit tutar.',
      child: SingleChildScrollView(
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
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Müşteri Ataması',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              musteriAsync.when(
                data: _buildMusteriChips,
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
      children: musteriler.map((musteri) {
        final selected = _selectedMusteriIds.contains(musteri.id);
        return FilterChip(
          label: Text(musteri.firmaKisaAd),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedMusteriIds.add(musteri.id);
              } else {
                _selectedMusteriIds.remove(musteri.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildUgramaListPane(
    AsyncValue<List<Ugrama>> ugramaAsync,
    AsyncValue<List<Musteri>> musteriAsync,
  ) {
    return ugramaAsync.when(
      data: (list) {
        final musteriMap = <String, String>{};
        if (musteriAsync case AsyncData(value: final musteriler)) {
          for (final musteri in musteriler) {
            musteriMap[musteri.id] = musteri.firmaKisaAd;
          }
        }

        final isMobile = layoutTypeOf(context) == LayoutType.mobile;
        final query = _searchController.text.trim().toLowerCase();
        final filtered = list.where((ugrama) {
          if (query.isEmpty) {
            return true;
          }
          return ugrama.ugramaAdi.toLowerCase().contains(query) ||
              (ugrama.adres?.toLowerCase().contains(query) ?? false);
        }).toList();

        final listView = filtered.isEmpty
            ? const Text('Henüz uğrama yok.')
            : ListView.separated(
                shrinkWrap: isMobile,
                physics: isMobile ? const NeverScrollableScrollPhysics() : null,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final ugrama = filtered[index];
                  return _UgramaListTile(
                    ugrama: ugrama,
                    musteriMap: musteriMap,
                    isSelected: ugrama.id == _editingId,
                    onTap: (musteriIds) => _populateForm(ugrama, musteriIds),
                  );
                },
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
              );

        final card = AppSectionCard(
          title: 'Uğramalar (${filtered.length})',
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
      },
      loading: () => const AppSectionCard(
        title: 'Uğramalar',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppSectionCard(
        title: 'Uğramalar',
        child: Text('Hata: $e'),
      ),
    );
  }
}

class _UgramaListTile extends ConsumerWidget {
  const _UgramaListTile({
    required this.ugrama,
    required this.musteriMap,
    required this.onTap,
    required this.isSelected,
  });

  final Ugrama ugrama;
  final Map<String, String> musteriMap;
  final void Function(List<String> musteriIds) onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musteriIdsAsync = ref.watch(musteriIdsByUgramaProvider(ugrama.id));

    return musteriIdsAsync.when(
      data: (musteriIds) {
        final chipLabels = musteriIds
            .map((id) => musteriMap[id] ?? id)
            .toList();
        return Material(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
                            label: Text(
                              label,
                              style: const TextStyle(fontSize: 11),
                            ),
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
              color: ugrama.isActive
                  ? AppColors.secondary
                  : AppColors.textMuted,
            ),
            onTap: () => onTap(musteriIds),
          ),
        );
      },
      loading: () => ListTile(
        title: Text(ugrama.ugramaAdi),
        subtitle: const LinearProgressIndicator(),
      ),
      error: (_, _) => ListTile(
        title: Text(ugrama.ugramaAdi),
        subtitle: const Text('Müşteri bilgisi yüklenemedi'),
        onTap: () => onTap(const []),
      ),
    );
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
