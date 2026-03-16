import 'package:backend_core/backend_core.dart';
import 'package:bursamotokurye/feature/operasyon/presentation/operasyon_dashboard_page.dart';
import 'package:bursamotokurye/product/kurye/kurye_providers.dart';
import 'package:bursamotokurye/product/siparis/siparis_providers.dart';
import 'package:bursamotokurye/product/user_profile/user_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../helpers/fakes/fake_kurye_repository.dart';
import '../../helpers/fakes/fake_siparis_repository.dart';
import '../../helpers/widgets/test_app.dart';

void main() {
  // -----------------------------------------------------------------------
  // Shared seed data — fixed point-in-time for deterministic results.
  // -----------------------------------------------------------------------
  final now = DateTime(2026, 3, 15, 12);

  final orders = <Siparis>[
    // Within last 7 days (also within 30d and 90d)
    Siparis(
      id: 'o1',
      musteriId: 'm1',
      kuryeId: 'k1',
      cikisId: 'c1',
      ugramaId: 'u1',
      durum: SiparisDurum.tamamlandi,
      ucret: 100,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    Siparis(
      id: 'o2',
      musteriId: 'm2',
      kuryeId: 'k2',
      cikisId: 'c1',
      ugramaId: 'u1',
      durum: SiparisDurum.tamamlandi,
      ucret: 50,
      createdAt: now.subtract(const Duration(days: 5)),
    ),
    // Within last 30 days but NOT last 7 days
    Siparis(
      id: 'o3',
      musteriId: 'm1',
      kuryeId: 'k1',
      cikisId: 'c1',
      ugramaId: 'u1',
      durum: SiparisDurum.tamamlandi,
      ucret: 200,
      createdAt: now.subtract(const Duration(days: 20)),
    ),
    // Within last 90 days but NOT last 30 days
    Siparis(
      id: 'o4',
      musteriId: 'm2',
      kuryeId: 'k2',
      cikisId: 'c1',
      ugramaId: 'u1',
      durum: SiparisDurum.tamamlandi,
      ucret: 300,
      createdAt: now.subtract(const Duration(days: 60)),
    ),
    // Today's order — for daily job count
    Siparis(
      id: 'o5',
      musteriId: 'm1',
      kuryeId: 'k1',
      cikisId: 'c1',
      ugramaId: 'u1',
      durum: SiparisDurum.tamamlandi,
      ucret: 75,
      createdAt: DateTime(2026, 3, 15, 10),
    ),
  ];

  // Expected totals:
  // 1wk  = o1(100) + o2(50) + o5(75) = 225
  // 1mo  = o1(100) + o2(50) + o3(200) + o5(75) = 425
  // 3mo  = o1(100) + o2(50) + o3(200) + o4(300) + o5(75) = 725
  // dailyAvg = 425 / 15 ≈ 28.33

  final couriers = <Kurye>[
    const Kurye(
      id: 'k1',
      userId: 'u1',
      ad: 'Ali Kurye',
      telefon: '5001112233',
      plaka: '16ABC01',
      isOnline: true,
    ),
    const Kurye(
      id: 'k2',
      userId: 'u2',
      ad: 'Veli Kurye',
      telefon: '5004445566',
      plaka: '16ABC02',
    ),
    const Kurye(
      id: 'k3',
      userId: 'u3',
      ad: 'Hasan Kurye',
      telefon: '5007778899',
      plaka: '16ABC03',
      isOnline: true,
    ),
  ];

  List<Override> buildOverrides({
    List<Siparis>? seedOrders,
    List<Kurye>? seedCouriers,
  }) {
    final siparisRepo = FakeSiparisRepository(seed: seedOrders ?? orders);
    final kuryeRepo = FakeKuryeRepository(seed: seedCouriers ?? couriers);

    return [
      siparisRepositoryProvider.overrideWithValue(siparisRepo),
      kuryeRepositoryProvider.overrideWithValue(kuryeRepo),
      currentUserProfileProvider.overrideWithBuild(
        (ref, notifier) => null,
      ),
    ];
  }

  group('OperasyonDashboardPage', () {
    Future<void> pumpDashboard(
      WidgetTester tester, {
      List<Siparis>? seedOrders,
      List<Kurye>? seedCouriers,
      Size size = const Size(1440, 1200),
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpApp(
        const OperasyonDashboardPage(),
        overrides: buildOverrides(
          seedOrders: seedOrders,
          seedCouriers: seedCouriers,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders revenue totals from seeded orders', (tester) async {
      await pumpDashboard(tester);

      expect(find.text('725,00 TL'), findsOneWidget); // 3-month
      expect(find.text('425,00 TL'), findsOneWidget); // 1-month
      expect(find.text('225,00 TL'), findsOneWidget); // 1-week

      expect(find.text('Gunluk Ortalama'), findsOneWidget);
    });

    testWidgets('renders courier performance stats', (tester) async {
      await pumpDashboard(tester);

      // Courier names (may appear in avatar + name text)
      expect(find.text('Ali Kurye'), findsWidgets);
      expect(find.text('Veli Kurye'), findsWidgets);

      // k1 (Ali): monthly = o1 + o3 + o5 = 3, daily = o5 = 1
      expect(find.text('Ay: 3'), findsOneWidget);

      // k2 (Veli): monthly = o2 = 1
      expect(find.text('Ay: 1'), findsOneWidget);
    });

    testWidgets('renders active courier count and names', (tester) async {
      await pumpDashboard(tester);

      // 2 online couriers
      expect(find.text('2'), findsOneWidget);

      // Their names listed (no bullet in new layout)
      expect(find.text('Ali Kurye'), findsWidgets);
      expect(find.text('Hasan Kurye'), findsWidgets);
    });

    testWidgets('shows "Aktif kurye yok" when no couriers online', (
      tester,
    ) async {
      final offlineCouriers = couriers
          .map(
            (k) => Kurye(
              id: k.id,
              userId: k.userId,
              ad: k.ad,
              telefon: k.telefon,
              plaka: k.plaka,
            ),
          )
          .toList();

      await pumpDashboard(tester, seedCouriers: offlineCouriers);

      expect(find.text('Aktif kurye yok'), findsOneWidget);
    });

    testWidgets('shows "Veri yok" when no courier stats', (tester) async {
      await pumpDashboard(tester, seedOrders: []);

      expect(find.text('Henüz veri bulunamadı'), findsOneWidget);
    });

    testWidgets('renders without error on initial pump', (tester) async {
      await pumpDashboard(tester);

      // Scaffold is present — the page built successfully.
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('card titles are visible', (tester) async {
      await pumpDashboard(tester);

      expect(find.text('Ciro Analizi'), findsOneWidget);
      expect(find.text('Kurye Performansi'), findsOneWidget);
      expect(find.text('Aktif Kuryeler'), findsOneWidget);
    });

    testWidgets('desktop quick actions are visible', (tester) async {
      await pumpDashboard(tester);

      expect(find.text('Hızlı Geçiş'), findsOneWidget);
      expect(find.text('Operasyon Ekranı'), findsWidgets);
      expect(find.text('Geçmiş Siparişler'), findsWidgets);
      expect(find.text('Kurye Yönetimi'), findsWidgets);
    });
  });
}
