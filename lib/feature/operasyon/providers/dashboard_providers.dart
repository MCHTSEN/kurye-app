import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../product/kurye/kurye_providers.dart';
import '../../../product/siparis/siparis_providers.dart';
import '../domain/dashboard_stats.dart';

part 'dashboard_providers.g.dart';

/// Fetches 90-day order history + all couriers, then computes dashboard
/// analytics via the pure [DashboardStats.compute] factory.
@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  final siparisRepo = ref.watch(siparisRepositoryProvider);
  final kuryeRepo = ref.watch(kuryeRepositoryProvider);

  final now = DateTime.now();
  final startDate = now.subtract(const Duration(days: 90));

  final results = await Future.wait([
    siparisRepo.getHistory(startDate: startDate),
    kuryeRepo.getAll(),
  ]);

  final orders = results[0] as List;
  final couriers = results[1] as List;

  return DashboardStats.compute(
    orders: orders.cast(),
    couriers: couriers.cast(),
    now: now,
  );
}
