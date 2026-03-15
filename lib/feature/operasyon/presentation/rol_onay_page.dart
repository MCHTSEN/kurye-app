import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/role_nav_items.dart';
import '../../../product/role_request/role_request_providers.dart';
import '../../../product/widgets/responsive_scaffold.dart';
import '../../../product/widgets/searchable_dropdown.dart';

class RolOnayPage extends ConsumerStatefulWidget {
  const RolOnayPage({super.key});

  @override
  ConsumerState<RolOnayPage> createState() => _RolOnayPageState();
}

class _RolOnayPageState extends ConsumerState<RolOnayPage> {
  final _musteriSelections = <String, String?>{};

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingRoleRequestsProvider);

    return ResponsiveScaffold(
      title: 'Rol Onayları',
      currentRoute: CustomRoute.rolOnay,
      navItems: operasyonNavItems,
      headerTitle: 'Moto Kurye',
      headerSubtitle: 'Operasyon',
      body: pendingAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Bekleyen rol talebi yok.',
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: ProjectPadding.all.normal,
            itemCount: requests.length,
            itemBuilder: (context, index) => _RequestCard(
              request: requests[index],
              musteriSelection: _musteriSelections[requests[index].id],
              onMusteriChanged: (value) {
                setState(() {
                  _musteriSelections[requests[index].id] = value;
                });
              },
              onApprove: () => _approve(requests[index]),
              onReject: () => _reject(requests[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: ShadAlert.destructive(
            icon: const Icon(LucideIcons.circleAlert),
            title: const Text('Hata'),
            description: Text('$e'),
          ),
        ),
      ),
    );
  }

  Future<void> _approve(RoleRequest request) async {
    final isMusteriPersonel =
        request.requestedRole == UserRole.musteriPersonel;
    final musteriId = _musteriSelections[request.id];

    if (isMusteriPersonel && (musteriId == null || musteriId.isEmpty)) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Hata'),
          description:
              Text('Müşteri personeli onayı için müşteri seçimi zorunlu.'),
        ),
      );
      return;
    }

    try {
      final authSession = await ref.read(authStateProvider.future);
      if (authSession == null) return;

      final repo = ref.read(roleRequestRepositoryProvider);
      await repo.approveRequest(
        requestId: request.id,
        reviewerId: authSession.user.id,
        musteriId: isMusteriPersonel ? musteriId : null,
      );

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text('${request.displayName} onaylandı'),
            description: const Text('Kullanıcı rolü aktif edildi.'),
          ),
        );
        ref.invalidate(pendingRoleRequestsProvider);
      }
    } on Exception catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Onay hatası'),
            description: Text('$e'),
          ),
        );
      }
    }
  }

  Future<void> _reject(RoleRequest request) async {
    final reason = await showShadDialog<String>(
      context: context,
      builder: (ctx) => _RejectReasonDialog(),
    );
    if (reason == null) return;

    try {
      final authSession = await ref.read(authStateProvider.future);
      if (authSession == null) return;

      final repo = ref.read(roleRequestRepositoryProvider);
      await repo.rejectRequest(
        requestId: request.id,
        reviewerId: authSession.user.id,
        reason: reason.isEmpty ? null : reason,
      );

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text('${request.displayName} reddedildi'),
          ),
        );
        ref.invalidate(pendingRoleRequestsProvider);
      }
    } on Exception catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Red hatası'),
            description: Text('$e'),
          ),
        );
      }
    }
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({
    required this.request,
    required this.musteriSelection,
    required this.onMusteriChanged,
    required this.onApprove,
    required this.onReject,
  });

  final RoleRequest request;
  final String? musteriSelection;
  final ValueChanged<String?> onMusteriChanged;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final isMusteriPersonel =
        request.requestedRole == UserRole.musteriPersonel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ShadCard(
        title: Row(
          children: [
            ShadAvatar(
              '',
              size: const Size.square(32),
              placeholder: Text(
                request.displayName.isNotEmpty
                    ? request.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.displayName, style: theme.textTheme.h4),
                  ShadBadge.secondary(
                    child: Text(request.requestedRole.value),
                  ),
                ],
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (request.phone != null)
                _InfoRow(icon: Icons.phone, text: request.phone!),
              if (request.note != null && request.note!.isNotEmpty)
                _InfoRow(icon: Icons.note, text: request.note!),
              if (request.createdAt != null)
                _InfoRow(
                  icon: Icons.calendar_today,
                  text: _formatDate(request.createdAt!),
                ),
              if (isMusteriPersonel) ...[
                const SizedBox(height: AppSpacing.md),
                _MusteriDropdown(
                  selectedId: musteriSelection,
                  onChanged: onMusteriChanged,
                ),
              ],
            ],
          ),
        ),
        footer: Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            ShadButton.outline(
              onPressed: onReject,
              leading: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.close, size: 16),
              ),
              child: const Text('Reddet'),
            ),
            ShadButton(
              onPressed: onApprove,
              leading: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check, size: 16),
              ),
              child: const Text('Onayla'),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.small)),
        ],
      ),
    );
  }
}

class _MusteriDropdown extends ConsumerWidget {
  const _MusteriDropdown({
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musteriListAsync = ref.watch(musteriListProvider);

    return musteriListAsync.when(
      data: (musteriler) {
        return SearchableDropdown<String>(
          value: selectedId,
          label: 'Müşteri Seçimi *',
          placeholder: 'Müşteri Seç',
          searchPlaceholder: 'Müşteri ara...',
          items: musteriler
              .map((m) => (value: m.id, label: m.firmaKisaAd))
              .toList(),
          onChanged: onChanged,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Müşteri listesi yüklenemedi: $e'),
    );
  }
}

class _RejectReasonDialog extends StatefulWidget {
  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Red Sebebi'),
      description: const Text('Opsiyonel — boş bırakabilirsiniz'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ShadInput(
          controller: _controller,
          placeholder: const Text('Sebep (opsiyonel)'),
          maxLines: 3,
        ),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ShadButton.destructive(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Reddet'),
        ),
      ],
    );
  }
}
