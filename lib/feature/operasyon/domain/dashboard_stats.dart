import 'package:backend_core/backend_core.dart';

/// Per-courier job statistics for the dashboard.
///
/// Immutable value object — all fields are final.
class CourierStat {
  const CourierStat({
    required this.kuryeId,
    required this.ad,
    required this.monthlyJobs,
    required this.dailyJobs,
  });

  final String kuryeId;
  final String ad;

  /// Number of completed deliveries in the last 30 days.
  final int monthlyJobs;

  /// Number of completed deliveries today.
  final int dailyJobs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourierStat &&
          runtimeType == other.runtimeType &&
          kuryeId == other.kuryeId &&
          ad == other.ad &&
          monthlyJobs == other.monthlyJobs &&
          dailyJobs == other.dailyJobs;

  @override
  int get hashCode => Object.hash(kuryeId, ad, monthlyJobs, dailyJobs);

  @override
  String toString() =>
      'CourierStat(kuryeId: $kuryeId, ad: $ad, '
      'monthlyJobs: $monthlyJobs, dailyJobs: $dailyJobs)';
}

/// Aggregated analytics for the operations dashboard.
///
/// All computation is in the [DashboardStats.compute] factory — no side
/// effects, fully testable with seeded data. Immutable value object.
class DashboardStats {
  const DashboardStats({
    required this.revenue3mo,
    required this.revenue1mo,
    required this.revenue1wk,
    required this.dailyAvg,
    required this.courierStats,
    required this.activeCourierCount,
    required this.activeCourierNames,
  });

  /// Pure computation factory.
  ///
  /// Filters [orders] to [SiparisDurum.tamamlandi] only, treats null
  /// `ucret` as 0, and uses `createdAt` for period bucketing.
  factory DashboardStats.compute({
    required List<Siparis> orders,
    required List<Kurye> couriers,
    required DateTime now,
  }) {
    final cutoff90 = now.subtract(const Duration(days: 90));
    final cutoff30 = now.subtract(const Duration(days: 30));
    final cutoff7 = now.subtract(const Duration(days: 7));
    final todayStart = DateTime(now.year, now.month, now.day);

    // Only completed orders contribute to revenue & stats.
    final completed = orders
        .where((o) => o.durum == SiparisDurum.tamamlandi)
        .toList();

    var rev3mo = 0.0;
    var rev1mo = 0.0;
    var rev1wk = 0.0;

    // Per-courier accumulators: kuryeId → {monthly, daily}
    final monthlyJobMap = <String, int>{};
    final dailyJobMap = <String, int>{};

    for (final order in completed) {
      final created = order.createdAt;
      if (created == null) continue;

      final fee = order.ucret ?? 0;

      if (!created.isBefore(cutoff90)) rev3mo += fee;
      if (!created.isBefore(cutoff30)) rev1mo += fee;
      if (!created.isBefore(cutoff7)) rev1wk += fee;

      final kid = order.kuryeId;
      if (kid != null) {
        if (!created.isBefore(cutoff30)) {
          monthlyJobMap[kid] = (monthlyJobMap[kid] ?? 0) + 1;
        }
        if (!created.isBefore(todayStart)) {
          dailyJobMap[kid] = (dailyJobMap[kid] ?? 0) + 1;
        }
      }
    }

    // Days elapsed in current month (minimum 1).
    final daysElapsed = now.day < 1 ? 1 : now.day;
    final dailyAvg = rev1mo / daysElapsed;

    // Build courier-level stats — every courier with deliveries gets a row.
    final allKuryeIds = <String>{
      ...monthlyJobMap.keys,
      ...dailyJobMap.keys,
    };

    // Map courier id → name for label lookup.
    final nameMap = <String, String>{
      for (final k in couriers) k.id: k.ad,
    };

    final stats = allKuryeIds.map((kid) {
      return CourierStat(
        kuryeId: kid,
        ad: nameMap[kid] ?? kid,
        monthlyJobs: monthlyJobMap[kid] ?? 0,
        dailyJobs: dailyJobMap[kid] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.monthlyJobs.compareTo(a.monthlyJobs));

    // Active couriers — those with isOnline == true.
    final onlineCouriers = couriers.where((k) => k.isOnline).toList();

    return DashboardStats(
      revenue3mo: rev3mo,
      revenue1mo: rev1mo,
      revenue1wk: rev1wk,
      dailyAvg: dailyAvg,
      courierStats: stats,
      activeCourierCount: onlineCouriers.length,
      activeCourierNames: onlineCouriers.map((k) => k.ad).toList(),
    );
  }

  /// Total revenue from completed orders in the last 90 days.
  final double revenue3mo;

  /// Total revenue from completed orders in the last 30 days.
  final double revenue1mo;

  /// Total revenue from completed orders in the last 7 days.
  final double revenue1wk;

  /// Average daily revenue for the current month (30-day revenue / days
  /// elapsed in current month, minimum 1 to avoid division by zero).
  final double dailyAvg;

  /// Per-courier delivery statistics.
  final List<CourierStat> courierStats;

  /// Number of couriers currently online.
  final int activeCourierCount;

  /// Names of couriers currently online.
  final List<String> activeCourierNames;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardStats &&
          runtimeType == other.runtimeType &&
          revenue3mo == other.revenue3mo &&
          revenue1mo == other.revenue1mo &&
          revenue1wk == other.revenue1wk &&
          dailyAvg == other.dailyAvg &&
          activeCourierCount == other.activeCourierCount;

  @override
  int get hashCode => Object.hash(
        revenue3mo,
        revenue1mo,
        revenue1wk,
        dailyAvg,
        activeCourierCount,
      );

  @override
  String toString() =>
      'DashboardStats(rev3mo: $revenue3mo, rev1mo: $revenue1mo, '
      'rev1wk: $revenue1wk, dailyAvg: $dailyAvg, '
      'couriers: ${courierStats.length}, '
      'active: $activeCourierCount)';
}
