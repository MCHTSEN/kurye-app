import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/kurye/kurye_providers.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/widgets/app_section_card.dart';

/// Courier main screen — active/passive toggle + assigned order list
/// with timestamp punching (çıkış, uğrama, uğrama1).
class KuryeAnaPage extends ConsumerWidget {
  const KuryeAnaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kuryeAsync = ref.watch(currentKuryeProvider);

    final logout = logoutCallback(ref);

    return Scaffold(
      appBar: AppBar(
        title: kuryeAsync.when(
          data: (kurye) => Text(
            kurye != null ? kurye.ad : 'Kurye Paneli',
          ),
          loading: () => const Text('Kurye Paneli'),
          error: (_, __) => const Text('Kurye Paneli'),
        ),
        actions: [
          IconButton(
            key: const Key('kurye_logout_btn'),
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: logout,
          ),
        ],
      ),
      body: kuryeAsync.when(
        data: (kurye) {
          if (kurye == null) {
            return const Center(
              child: Text('Kurye kaydı bulunamadı'),
            );
          }
          return _KuryeBody(kurye: kurye);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

/// Main body — shown when the kurye record is resolved.
class _KuryeBody extends ConsumerWidget {
  const _KuryeBody({required this.kurye});

  final Kurye kurye;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync =
        ref.watch(siparisStreamByKuryeProvider(kurye.id));

    // Build ugrama name map (D027 pattern).
    final ugramaListAsync = ref.watch(ugramaListProvider);
    final ugramaMap = <String, String>{};
    if (ugramaListAsync case AsyncData(value: final ugramalar)) {
      for (final u in ugramalar) {
        ugramaMap[u.id] = u.ugramaAdi;
      }
    }

    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        _OnlineToggleCard(kurye: kurye),
        const SizedBox(height: AppSpacing.md),
        _OrderListSection(ordersAsync: ordersAsync, ugramaMap: ugramaMap),
      ],
    );
  }
}

/// Active/passive toggle card.
class _OnlineToggleCard extends ConsumerStatefulWidget {
  const _OnlineToggleCard({required this.kurye});

  final Kurye kurye;

  @override
  ConsumerState<_OnlineToggleCard> createState() => _OnlineToggleCardState();
}

class _OnlineToggleCardState extends ConsumerState<_OnlineToggleCard> {
  late bool _isOnline;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.kurye.isOnline;
  }

  Future<void> _onToggle(bool value) async {
    if (_updating) return;
    setState(() {
      _isOnline = value;
      _updating = true;
    });
    try {
      final repo = ref.read(kuryeRepositoryProvider);
      await repo.updateOnlineStatus(widget.kurye.id, isOnline: value);
    } on Exception {
      // Revert on failure.
      if (mounted) {
        setState(() => _isOnline = !value);
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isOnline ? 'Aktif' : 'Pasif';

    return AppSectionCard(
      title: 'Durum',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _isOnline ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Switch(
            key: const Key('online_toggle'),
            value: _isOnline,
            onChanged: _updating ? null : _onToggle,
          ),
        ],
      ),
    );
  }
}

/// Order list section showing `devam_ediyor` orders.
class _OrderListSection extends StatelessWidget {
  const _OrderListSection({
    required this.ordersAsync,
    required this.ugramaMap,
  });

  final AsyncValue<List<Siparis>> ordersAsync;
  final Map<String, String> ugramaMap;

  @override
  Widget build(BuildContext context) {
    return ordersAsync.when(
      data: (allOrders) {
        final activeOrders = allOrders
            .where((s) => s.durum == SiparisDurum.devamEdiyor)
            .toList();

        return AppSectionCard(
          title: 'Siparişlerim (${activeOrders.length})',
          child: activeOrders.isEmpty
              ? const Text('Aktif sipariş yok.')
              : Column(
                  children: [
                    for (final order in activeOrders) ...[
                      _OrderCard(order: order, ugramaMap: ugramaMap),
                      if (order != activeOrders.last)
                        const Divider(height: AppSpacing.lg),
                    ],
                  ],
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppSectionCard(
        title: 'Siparişlerim',
        child: Text('Sipariş yüklenemedi: $e'),
      ),
    );
  }
}

/// Individual order card with route info and timestamp buttons.
class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.ugramaMap});

  final Siparis order;
  final Map<String, String> ugramaMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cikis = ugramaMap[order.cikisId] ?? order.cikisId;
    final ugrama = ugramaMap[order.ugramaId] ?? order.ugramaId;
    final ugrama1 = order.ugrama1Id != null
        ? ugramaMap[order.ugrama1Id] ?? order.ugrama1Id
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route info.
        Text(
          '$cikis → $ugrama'
          '${ugrama1 != null ? ' → $ugrama1' : ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Timestamp buttons row.
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _TimestampButton(
              key: Key('cikis_btn_${order.id}'),
              label: 'Çıkış',
              timestamp: order.cikisSaat,
              onPunch: () => _punchTimestamp(ref, 'cikis_saat'),
            ),
            _TimestampButton(
              key: Key('ugrama_btn_${order.id}'),
              label: 'Uğrama',
              timestamp: order.ugramaSaat,
              onPunch: () => _punchTimestamp(ref, 'ugrama_saat'),
            ),
            if (order.ugrama1Id != null)
              _TimestampButton(
                key: Key('ugrama1_btn_${order.id}'),
                label: 'Uğrama1',
                timestamp: order.ugrama1Saat,
                onPunch: () => _punchTimestamp(ref, 'ugrama1_saat'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _punchTimestamp(WidgetRef ref, String field) async {
    final repo = ref.read(siparisRepositoryProvider);
    await repo.update(order.id, {field: DateTime.now().toIso8601String()});
  }
}

/// A single timestamp button — shows formatted time when set, or action button
/// when not.
class _TimestampButton extends StatelessWidget {
  const _TimestampButton({
    required this.label,
    required this.timestamp,
    required this.onPunch,
    super.key,
  });

  final String label;
  final DateTime? timestamp;
  final VoidCallback onPunch;

  static final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    if (timestamp != null) {
      return OutlinedButton(
        onPressed: null, // Disabled — already set.
        child: Text('$label ${_timeFormat.format(timestamp!)}'),
      );
    }
    return ElevatedButton(
      onPressed: onPunch,
      child: Text(label),
    );
  }
}
