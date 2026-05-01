import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/feature/operasyon/domain/dashboard_stats.dart';

void main() {
  /// Fixed reference time: 2026-03-15 12:00:00
  final now = DateTime(2026, 3, 15, 12);

  Siparis makeOrder({
    required String id,
    required DateTime createdAt,
    SiparisDurum durum = SiparisDurum.tamamlandi,
    double? ucret,
    String? kuryeId,
  }) {
    return Siparis(
      id: id,
      musteriId: 'm1',
      cikisId: 'c1',
      ugramaId: 'u1',
      kuryeId: kuryeId,
      durum: durum,
      ucret: ucret,
      createdAt: createdAt,
    );
  }

  Kurye makeKurye({
    required String id,
    required String ad,
    bool isOnline = false,
  }) {
    return Kurye(id: id, ad: ad, isOnline: isOnline);
  }

  group('DashboardStats.compute', () {
    test('empty orders returns all-zero stats', () {
      final stats = DashboardStats.compute(
        orders: [],
        couriers: [makeKurye(id: 'k1', ad: 'Ali')],
        now: now,
      );

      expect(stats.revenue3mo, 0.0);
      expect(stats.revenue1mo, 0.0);
      expect(stats.revenue1wk, 0.0);
      expect(stats.dailyAvg, 0.0);
      expect(stats.courierStats, isEmpty);
      expect(stats.activeCourierCount, 0);
      expect(stats.activeCourierNames, isEmpty);
    });

    test('filters to tamamlandi only — iptal orders excluded', () {
      final orders = [
        makeOrder(
          id: '1',
          createdAt: now.subtract(const Duration(days: 5)),
          ucret: 100,
          kuryeId: 'k1',
        ),
        makeOrder(
          id: '2',
          createdAt: now.subtract(const Duration(days: 5)),
          durum: SiparisDurum.iptal,
          ucret: 200,
          kuryeId: 'k1',
        ),
      ];

      final stats = DashboardStats.compute(
        orders: orders,
        couriers: [makeKurye(id: 'k1', ad: 'Ali')],
        now: now,
      );

      // Only the 100 TL completed order counted.
      expect(stats.revenue3mo, 100.0);
      expect(stats.revenue1mo, 100.0);
      expect(stats.revenue1wk, 100.0);
    });

    test('null ucret treated as 0', () {
      final orders = [
        makeOrder(
          id: '1',
          createdAt: now.subtract(const Duration(days: 2)),
          // ucret intentionally omitted (null by default)
          kuryeId: 'k1',
        ),
        makeOrder(
          id: '2',
          createdAt: now.subtract(const Duration(days: 2)),
          ucret: 50,
          kuryeId: 'k1',
        ),
      ];

      final stats = DashboardStats.compute(
        orders: orders,
        couriers: [makeKurye(id: 'k1', ad: 'Ali')],
        now: now,
      );

      expect(stats.revenue1wk, 50.0);
    });

    test('revenue buckets: 3mo, 1mo, 1wk are correct', () {
      final orders = [
        // 60 days ago — in 3mo, NOT in 1mo or 1wk
        makeOrder(
          id: '1',
          createdAt: now.subtract(const Duration(days: 60)),
          ucret: 1000,
          kuryeId: 'k1',
        ),
        // 20 days ago — in 3mo and 1mo, NOT in 1wk
        makeOrder(
          id: '2',
          createdAt: now.subtract(const Duration(days: 20)),
          ucret: 500,
          kuryeId: 'k1',
        ),
        // 3 days ago — in all buckets
        makeOrder(
          id: '3',
          createdAt: now.subtract(const Duration(days: 3)),
          ucret: 200,
          kuryeId: 'k2',
        ),
        // 100 days ago — outside all buckets
        makeOrder(
          id: '4',
          createdAt: now.subtract(const Duration(days: 100)),
          ucret: 9999,
          kuryeId: 'k1',
        ),
      ];

      final stats = DashboardStats.compute(
        orders: orders,
        couriers: [
          makeKurye(id: 'k1', ad: 'Ali'),
          makeKurye(id: 'k2', ad: 'Veli'),
        ],
        now: now,
      );

      expect(stats.revenue3mo, 1700.0); // 1000 + 500 + 200
      expect(stats.revenue1mo, 700.0); // 500 + 200
      expect(stats.revenue1wk, 200.0); // 200
    });

    test('daily average uses days elapsed in current month', () {
      // now = 2026-03-15 → 15 days elapsed
      final orders = [
        makeOrder(
          id: '1',
          createdAt: now.subtract(const Duration(days: 10)),
          ucret: 1500,
          kuryeId: 'k1',
        ),
      ];

      final stats = DashboardStats.compute(
        orders: orders,
        couriers: [],
        now: now,
      );

      // dailyAvg = 1500 / 15 = 100
      expect(stats.dailyAvg, 100.0);
    });

    test('daily average minimum 1 day to prevent divide-by-zero', () {
      // Edge: now.day == 0 is impossible with DateTime, but we test day=1
      // to verify the min-1 logic doesn't break.
      final dayOne = DateTime(2026, 3, 1, 8);
      final orders = [
        makeOrder(
          id: '1',
          createdAt: dayOne.subtract(const Duration(days: 2)),
          ucret: 300,
          kuryeId: 'k1',
        ),
      ];

      final stats = DashboardStats.compute(
        orders: orders,
        couriers: [],
        now: dayOne,
      );

      // dailyAvg = 300 / 1 = 300
      expect(stats.dailyAvg, 300.0);
    });

    test('courier stats group by kuryeId with correct counts', () {
      final orders = [
        // k1: 2 monthly, 1 today
        makeOrder(
          id: '1',
          createdAt: now.subtract(const Duration(days: 20)),
          ucret: 100,
          kuryeId: 'k1',
        ),
        makeOrder(
          id: '2',
          createdAt: now, // today
          ucret: 100,
          kuryeId: 'k1',
        ),
        // k2: 1 monthly, 0 today
        makeOrder(
          id: '3',
          createdAt: now.subtract(const Duration(days: 10)),
          ucret: 50,
          kuryeId: 'k2',
        ),
      ];

      final stats = DashboardStats.compute(
        orders: orders,
        couriers: [
          makeKurye(id: 'k1', ad: 'Ali'),
          makeKurye(id: 'k2', ad: 'Veli'),
        ],
        now: now,
      );

      expect(stats.courierStats.length, 2);

      // Sorted by monthlyJobs descending, so k1 first
      final k1 = stats.courierStats.firstWhere((s) => s.kuryeId == 'k1');
      expect(k1.ad, 'Ali');
      expect(k1.monthlyJobs, 2); // both within 30 days
      expect(k1.dailyJobs, 1); // only today's order

      final k2 = stats.courierStats.firstWhere((s) => s.kuryeId == 'k2');
      expect(k2.ad, 'Veli');
      expect(k2.monthlyJobs, 1);
      expect(k2.dailyJobs, 0);
    });

    test('active courier count uses isOnline == true', () {
      final couriers = [
        makeKurye(id: 'k1', ad: 'Ali', isOnline: true),
        makeKurye(id: 'k2', ad: 'Veli'),
        makeKurye(id: 'k3', ad: 'Can', isOnline: true),
      ];

      final stats = DashboardStats.compute(
        orders: [],
        couriers: couriers,
        now: now,
      );

      expect(stats.activeCourierCount, 2);
      expect(stats.activeCourierNames, containsAll(['Ali', 'Can']));
      expect(stats.activeCourierNames, isNot(contains('Veli')));
    });

    test('orders with null createdAt are skipped', () {
      final orders = [
        const Siparis(
          id: '1',
          musteriId: 'm1',
          cikisId: 'c1',
          ugramaId: 'u1',
          kuryeId: 'k1',
          durum: SiparisDurum.tamamlandi,
          ucret: 500,
          // createdAt intentionally omitted (null) — verifies skip behavior
        ),
        makeOrder(
          id: '2',
          createdAt: now.subtract(const Duration(days: 2)),
          ucret: 100,
          kuryeId: 'k1',
        ),
      ];

      final stats = DashboardStats.compute(
        orders: orders,
        couriers: [makeKurye(id: 'k1', ad: 'Ali')],
        now: now,
      );

      // Only the 100 TL order with a timestamp counted
      expect(stats.revenue3mo, 100.0);
      expect(stats.revenue1mo, 100.0);
    });

    test('orders with null kuryeId still count toward revenue', () {
      final orders = [
        makeOrder(
          id: '1',
          createdAt: now.subtract(const Duration(days: 5)),
          ucret: 250,
          // kuryeId intentionally omitted (null)
        ),
      ];

      final stats = DashboardStats.compute(
        orders: orders,
        couriers: [],
        now: now,
      );

      expect(stats.revenue1wk, 250.0);
      expect(stats.courierStats, isEmpty);
    });
  });
}
