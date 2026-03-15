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
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../../product/widgets/responsive_scaffold.dart';

class UgramaTalepYonetimPage extends ConsumerWidget {
  const UgramaTalepYonetimPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taleplerAsync = ref.watch(bekleyenTaleplerProvider);
    final musteriAsync = ref.watch(musteriListProvider);

    // Müşteri isim lookup.
    final musteriMap = <String, String>{};
    if (musteriAsync case AsyncData(value: final musteriler)) {
      for (final m in musteriler) {
        musteriMap[m.id] = m.firmaKisaAd;
      }
    }

    return ResponsiveScaffold(
      title: 'Uğrama Talepleri',
      currentRoute: CustomRoute.ugramaTalepYonetim,
      navItems: operasyonDesktopNavItems,
      headerSubtitle: 'Operasyon',
      onLogout: logoutCallback(ref),
      showMobileDrawer: false,
      body: taleplerAsync.when(
        data: (talepler) {
          if (talepler.isEmpty) {
            return Center(
              child: Padding(
                padding: ProjectPadding.all.normal,
                child: const AppSectionCard(
                  title: 'Bekleyen Talepler',
                  child: Text('Bekleyen uğrama talebi yok.'),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: ProjectPadding.all.normal,
            itemCount: talepler.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppSectionCard(
                    title: 'Bekleyen Talepler (${talepler.length})',
                    child: const Text(
                      'Müşteri personellerinden gelen uğrama ekleme talepleri.',
                    ),
                  ),
                );
              }
              final talep = talepler[index - 1];
              return _TalepCard(
                talep: talep,
                musteriAdi: musteriMap[talep.musteriId] ?? talep.musteriId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class _TalepCard extends ConsumerStatefulWidget {
  const _TalepCard({
    required this.talep,
    required this.musteriAdi,
  });

  final UgramaTalebi talep;
  final String musteriAdi;

  @override
  ConsumerState<_TalepCard> createState() => _TalepCardState();
}

class _TalepCardState extends ConsumerState<_TalepCard> {
  bool _isProcessing = false;

  Future<void> _onApprove() async {
    setState(() => _isProcessing = true);

    try {
      final profileAsync = ref.read(currentUserProfileProvider);
      final profile = switch (profileAsync) {
        AsyncData(value: final p) => p,
        _ => null,
      };
      if (profile == null) return;

      final repo = ref.read(ugramaTalebiRepositoryProvider);
      await repo.approve(
        talepId: widget.talep.id,
        islemYapanId: profile.id,
      );

      ref
        ..invalidate(bekleyenTaleplerProvider)
        ..invalidate(ugramaListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "'${widget.talep.ugramaAdi}' onaylandı ve oluşturuldu.",
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onReject() async {
    final redNotu = await _showRedNotuDialog();
    if (redNotu == null) return; // Kullanıcı iptal etti.

    setState(() => _isProcessing = true);

    try {
      final profileAsync = ref.read(currentUserProfileProvider);
      final profile = switch (profileAsync) {
        AsyncData(value: final p) => p,
        _ => null,
      };
      if (profile == null) return;

      final repo = ref.read(ugramaTalebiRepositoryProvider);
      await repo.reject(
        talepId: widget.talep.id,
        islemYapanId: profile.id,
        redNotu: redNotu,
      );

      ref.invalidate(bekleyenTaleplerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${widget.talep.ugramaAdi}' reddedildi."),
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<String?> _showRedNotuDialog() {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Red Notu'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Red sebebini yazınız...',
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(context).pop(text);
            },
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final talep = widget.talep;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: ProjectPadding.all.normal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    talep.ugramaAdi,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    widget.musteriAdi,
                    style: const TextStyle(fontSize: 12),
                  ),
                  avatar: const Icon(Icons.business, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (talep.adres != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: Text(talep.adres!)),
                ],
              ),
            ],
            if (talep.createdAt != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _formatDate(talep.createdAt!),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reddet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _isProcessing ? null : _onApprove,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: const Text('Onayla'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
