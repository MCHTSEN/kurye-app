import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_time.dart';
import '../../../product/kurye/kurye_providers.dart';
import '../../../product/navigation/account_delete_helper.dart';
import '../../../product/navigation/logout_helper.dart';
import '../../../product/navigation/password_change_helper.dart';
import '../../../product/notifications/notification_providers.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../../../product/ugrama/ugrama_providers.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../auth/application/auth_controller.dart';

/// Courier main screen — active/passive toggle + assigned order list
/// with timestamp punching (çıkış, uğrama, uğrama1).
class KuryeAnaPage extends ConsumerWidget {
  const KuryeAnaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kuryeAsync = ref.watch(currentKuryeProvider);
    final authActionLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );

    final logout = logoutCallback(ref);

    return Scaffold(
      appBar: AppBar(
        title: kuryeAsync.when(
          data: (kurye) => Text(
            kurye != null ? kurye.ad : 'Kurye Paneli',
          ),
          loading: () => const Text('Kurye Paneli'),
          error: (_, _) => const Text('Kurye Paneli'),
        ),
        actions: [
          IconButton(
            key: const Key('kurye_change_password_btn'),
            icon: const Icon(Icons.lock_reset_rounded),
            tooltip: 'Şifre Değiştir',
            onPressed: authActionLoading
                ? null
                : () => showChangePasswordDialog(context, ref),
          ),
          IconButton(
            key: const Key('kurye_logout_btn'),
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: authActionLoading ? null : logout,
          ),
          IconButton(
            key: const Key('kurye_delete_account_btn'),
            icon: const Icon(Icons.delete_forever_rounded),
            tooltip: 'Hesabı Sil',
            onPressed: authActionLoading
                ? null
                : () => confirmAndDeleteAccount(context, ref),
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
class _KuryeBody extends ConsumerStatefulWidget {
  const _KuryeBody({required this.kurye});

  final Kurye kurye;

  @override
  ConsumerState<_KuryeBody> createState() => _KuryeBodyState();
}

class _KuryeBodyState extends ConsumerState<_KuryeBody> {
  static final _notifLog = AppLogger(
    'KuryeOrderNotif',
    tag: LogTag.notification,
  );

  @override
  void initState() {
    super.initState();
    // İlk açılışta tek seferlik bildirim izni iste + FCM token'ı kurye user'ı
    // için DB'ye upsert et (bootstrap'te auth yoksa skip edilmişti).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notif = ref.read(notificationServiceProvider);
      final granted = await notif.isPermissionGranted();
      _notifLog.i('initState permission check — granted=$granted');
      if (!granted) {
        final r = await notif.requestPermission();
        _notifLog.i('initState requestPermission → $r');
      }
      final push = ref.read(pushNotificationServiceProvider);
      if (push != null) {
        await push.refreshToken();
        _notifLog.i('initState push refreshToken complete');
      }
    });
  }

  Kurye get kurye => widget.kurye;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(siparisStreamByKuryeProvider(kurye.id));

    // Yeni atanan siparişler için local notification tetikleyici.
    ref.listen<AsyncValue<List<Siparis>>>(
      siparisStreamByKuryeProvider(kurye.id),
      (prev, next) {
        final prevList = prev is AsyncData<List<Siparis>> ? prev.value : null;
        final nextList = next is AsyncData<List<Siparis>>
            ? next.value
            : const <Siparis>[];
        _notifLog.i(
          'stream change — prevCount=${prevList?.length ?? "null"} '
          'nextCount=${nextList.length}',
        );
        // İlk yüklemede mevcut siparişleri "yeni" sayma.
        if (prevList == null) return;
        final prevIds = prevList.map((s) => s.id).toSet();
        final nextIds = nextList.map((s) => s.id).toSet();
        final newOrders = nextIds.difference(prevIds);
        if (newOrders.isEmpty) {
          _notifLog.i('no new orders, diff empty');
          return;
        }
        _notifLog.i('new orders detected: ${newOrders.length} → show()');
        unawaited(
          ref
              .read(notificationServiceProvider)
              .show(
                NotificationMessage(
                  title: 'Yeni iş',
                  body: newOrders.length == 1
                      ? 'Size yeni bir sipariş atandı'
                      : '${newOrders.length} yeni sipariş atandı',
                ),
              )
              .then((_) => _notifLog.i('show() completed'))
              .catchError((Object e, StackTrace st) {
            _notifLog.e('show() failed', error: e, stackTrace: st);
          }),
        );
        // Read receipt: kurye uygulamayı açık ve siparişler ekranda göründüğünde
        // "gördü" sayılır. Idempotent — server-side WHERE kurye_gordu_at IS NULL.
        final repo = ref.read(siparisRepositoryProvider);
        for (final id in newOrders) {
          unawaited(
            repo.markAsSeenByKurye(id).catchError((Object e, StackTrace st) {
              _notifLog.e('markAsSeenByKurye failed for $id',
                  error: e, stackTrace: st);
            }),
          );
        }
      },
    );

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
      icon: Icons.power_settings_new_rounded,
      accentColor: _isOnline ? AppColors.secondary : AppColors.textMuted,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isOnline ? AppColors.secondary : AppColors.textMuted,
                  shape: BoxShape.circle,
                  boxShadow: _isOnline
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                statusText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _isOnline ? AppColors.secondary : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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

/// Individual order card with stop names as timestamp buttons + finish action.
class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.ugramaMap});

  final Siparis order;
  final Map<String, String> ugramaMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cikisLabel = ugramaMap[order.cikisId] ?? order.cikisId;
    final ugramaLabel = ugramaMap[order.ugramaId] ?? order.ugramaId;
    final ugrama1Label = order.ugrama1Id != null
        ? ugramaMap[order.ugrama1Id] ?? order.ugrama1Id
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _TimestampButton(
              key: Key('cikis_btn_${order.id}'),
              label: cikisLabel,
              timestamp: order.cikisSaat,
              onPunch: () => _punchTimestamp(ref, 'cikis_saat'),
            ),
            _TimestampButton(
              key: Key('ugrama_btn_${order.id}'),
              label: ugramaLabel,
              timestamp: order.ugramaSaat,
              onPunch: () => _punchTimestamp(ref, 'ugrama_saat'),
            ),
            if (order.ugrama1Id != null && ugrama1Label != null)
              _TimestampButton(
                key: Key('ugrama1_btn_${order.id}'),
                label: ugrama1Label,
                timestamp: order.ugrama1Saat,
                onPunch: () => _punchTimestamp(ref, 'ugrama1_saat'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            key: Key('finish_btn_${order.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('İşi Bitir'),
            onPressed: () => _confirmFinish(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _punchTimestamp(WidgetRef ref, String field) async {
    final repo = ref.read(siparisRepositoryProvider);
    await repo.update(order.id, {field: DateTime.now().toIso8601String()});
  }

  Future<void> _confirmFinish(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: Key('finish_confirm_${order.id}'),
        title: const Text('İşi bitir'),
        content: const Text(
          'Bu siparişi tamamlandı olarak işaretlemek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Bitir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = ref.read(siparisRepositoryProvider);
    // Otomatik fiyat lookup — geçmişten eşleşen rota varsa kullan.
    final match = await repo.getRecentPricing(
      musteriId: order.musteriId,
      cikisId: order.cikisId,
      ugramaId: order.ugramaId,
    );
    await repo.update(order.id, {
      'durum': SiparisDurum.tamamlandi.value,
      'bitis_saat': DateTime.now().toIso8601String(),
      if (match?.ucret != null) 'ucret': match!.ucret,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İş tamamlandı')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    if (timestamp != null) {
      return OutlinedButton(
        onPressed: null, // Disabled — already set.
        child: Text('$label ${AppTime.hm(timestamp)}'),
      );
    }
    return ElevatedButton(
      onPressed: onPunch,
      child: Text(label),
    );
  }
}
