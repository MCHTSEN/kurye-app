import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/role_request/role_request_providers.dart';
import '../../../product/widgets/app_section_card.dart';

class RolOnayPage extends ConsumerStatefulWidget {
  const RolOnayPage({super.key});

  @override
  ConsumerState<RolOnayPage> createState() => _RolOnayPageState();
}

class _RolOnayPageState extends ConsumerState<RolOnayPage> {
  /// Tracks selected müşteri per request (for müşteri_personel approvals).
  final _musteriSelections = <String, String?>{};

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingRoleRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rol Onayları')),
      body: pendingAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text('Bekleyen rol talebi yok.'),
            );
          }
          return ListView.builder(
            padding: ProjectPadding.all.normal,
            itemCount: requests.length,
            itemBuilder: (context, index) =>
                _RequestCard(
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
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Future<void> _approve(RoleRequest request) async {
    final isMusteriPersonel =
        request.requestedRole == UserRole.musteriPersonel;
    final musteriId = _musteriSelections[request.id];

    if (isMusteriPersonel && (musteriId == null || musteriId.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Müşteri personeli onayı için müşteri seçimi zorunlu.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${request.displayName} onaylandı.'),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Onay hatası: $e')),
        );
      }
    }
  }

  Future<void> _reject(RoleRequest request) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => _RejectReasonDialog(),
    );
    // null means cancelled, empty string means no reason given
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${request.displayName} reddedildi.'),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Red hatası: $e')),
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
    final isMusteriPersonel =
        request.requestedRole == UserRole.musteriPersonel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSectionCard(
        title: request.displayName,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.phone != null)
              Text('Telefon: ${request.phone}'),
            Text('Rol: ${request.requestedRole.value}'),
            if (request.note != null && request.note!.isNotEmpty)
              Text('Not: ${request.note}'),
            if (request.createdAt != null)
              Text(
                'Tarih: ${_formatDate(request.createdAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (isMusteriPersonel) ...[
              const SizedBox(height: 8),
              _MusteriDropdown(
                selectedId: musteriSelection,
                onChanged: onMusteriChanged,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reddet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 18),
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
        return DropdownButtonFormField<String>(
          initialValue: selectedId,
          decoration: const InputDecoration(
            labelText: 'Müşteri Seçimi *',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: musteriler
              .map(
                (m) => DropdownMenuItem<String>(
                  value: m.id,
                  child: Text(m.firmaKisaAd),
                ),
              )
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
    return AlertDialog(
      title: const Text('Red Sebebi'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Opsiyonel — boş bırakabilirsiniz',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Reddet'),
        ),
      ],
    );
  }
}
