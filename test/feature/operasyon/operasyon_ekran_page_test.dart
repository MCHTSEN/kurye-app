import 'package:backend_core/backend_core.dart';
import 'package:bursamotokurye/feature/operasyon/presentation/operasyon_ekran_page.dart';
import 'package:bursamotokurye/product/kurye/kurye_providers.dart';
import 'package:bursamotokurye/product/musteri/musteri_providers.dart';
import 'package:bursamotokurye/product/services/order_alert_service.dart';
import 'package:bursamotokurye/product/siparis/siparis_log_providers.dart';
import 'package:bursamotokurye/product/siparis/siparis_providers.dart';
import 'package:bursamotokurye/product/ugrama/ugrama_providers.dart';
import 'package:bursamotokurye/product/user_profile/user_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_kurye_repository.dart';
import '../../helpers/fakes/fake_musteri_repository.dart';
import '../../helpers/fakes/fake_order_alert_service.dart';
import '../../helpers/fakes/fake_siparis_log_repository.dart';
import '../../helpers/fakes/fake_siparis_repository.dart';
import '../../helpers/fakes/fake_ugrama_repository.dart';
import '../../helpers/widgets/test_app.dart';

const _testUserId = 'op-user-id';

const _testProfile = AppUserProfile(
  id: _testUserId,
  role: UserRole.operasyon,
  displayName: 'Operasyon Test',
);

final _testMusteriler = [
  const Musteri(id: 'musteri-1', firmaKisaAd: 'Firma A'),
  const Musteri(id: 'musteri-2', firmaKisaAd: 'Firma B'),
];

final _testUgramalar = [
  const Ugrama(
    id: 'ugrama-1',
    ugramaAdi: 'Merkez Ofis',
  ),
  const Ugrama(
    id: 'ugrama-2',
    ugramaAdi: 'Şube A',
  ),
  const Ugrama(
    id: 'ugrama-3',
    ugramaAdi: 'Şube B',
  ),
];

final _testKuryeler = [
  const Kurye(id: 'kurye-1', ad: 'Ali Kurye'),
  const Kurye(id: 'kurye-2', ad: 'Veli Kurye', isActive: false),
];

void main() {
  group('OperasyonEkranPage', () {
    late FakeSiparisRepository fakeSiparisRepo;
    late FakeSiparisLogRepository fakeLogRepo;
    late FakeMusteriRepository fakeMusteriRepo;
    late FakeUgramaRepository fakeUgramaRepo;
    late FakeKuryeRepository fakeKuryeRepo;

    setUp(() {
      fakeSiparisRepo = FakeSiparisRepository();
      fakeLogRepo = FakeSiparisLogRepository();
      fakeMusteriRepo = FakeMusteriRepository(seed: _testMusteriler);
      fakeUgramaRepo = FakeUgramaRepository(seed: _testUgramalar);
      fakeKuryeRepo = FakeKuryeRepository(seed: _testKuryeler);
    });

    Future<void> pumpPage(
      WidgetTester tester, {
      OrderAlertService? alertService,
      Size size = const Size(390, 844),
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpApp(
        OperasyonEkranPage(alertService: alertService),
        overrides: [
          currentUserProfileProvider.overrideWithBuild(
            (ref, notifier) => _testProfile,
          ),
          siparisRepositoryProvider.overrideWithValue(fakeSiparisRepo),
          siparisLogRepositoryProvider.overrideWithValue(fakeLogRepo),
          musteriRepositoryProvider.overrideWithValue(fakeMusteriRepo),
          ugramaRepositoryProvider.overrideWithValue(fakeUgramaRepo),
          kuryeRepositoryProvider.overrideWithValue(fakeKuryeRepo),
        ],
      );
      await tester.pumpAndSettle();
    }

    Future<void> reveal(WidgetTester tester, Finder target) async {
      if (target.evaluate().isNotEmpty) {
        await tester.ensureVisible(target.first);
        await tester.pumpAndSettle();
        return;
      }

      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          target,
          200,
          scrollable: scrollables.first,
        );
      } else {
        await tester.ensureVisible(target);
      }
      await tester.pumpAndSettle();
    }

    testWidgets('(a) renders 3 panels with correct titles', (tester) async {
      await pumpPage(tester);

      expect(find.text('YENİ SİPARİŞ'), findsOneWidget);

      // Scroll down to see bottom panels.
      await reveal(tester, find.textContaining('KURYE BEKLEYENLER'));
      expect(find.textContaining('KURYE BEKLEYENLER'), findsOneWidget);

      await reveal(tester, find.textContaining('DEVAM EDEN İŞLER'));
      expect(find.textContaining('DEVAM EDEN İŞLER'), findsOneWidget);
    });

    testWidgets('(b) kurye bekleyenler shows waiting orders', (tester) async {
      // Seed a waiting order.
      fakeSiparisRepo.store['s1'] = const Siparis(
        id: 's1',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-2',
      );

      await pumpPage(tester);

      // Scroll to the waiting panel.
      await reveal(tester, find.textContaining('KURYE BEKLEYENLER'));

      expect(find.textContaining('KURYE BEKLEYENLER (1)'), findsOneWidget);
      // Name resolution: ugrama-1 → 'Merkez Ofis', ugrama-2 → 'Şube A'
      expect(find.text('Merkez Ofis → Şube A'), findsOneWidget);
    });

    testWidgets('(c) courier assignment flow — select, pick courier, tap Ata', (
      tester,
    ) async {
      // Seed a waiting order.
      fakeSiparisRepo.store['s1'] = const Siparis(
        id: 's1',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-2',
      );

      await pumpPage(tester);

      // Scroll to the waiting panel.
      await reveal(tester, find.byKey(const Key('waiting_s1')));

      // Select the order checkbox.
      await tester.tap(find.byKey(const Key('waiting_s1')));
      await tester.pumpAndSettle();

      // Scroll to see the kurye dropdown.
      await reveal(tester, find.byKey(const Key('kurye_dropdown')));

      // Select courier from dropdown.
      await tester.tap(find.byKey(const Key('kurye_dropdown')));
      await tester.pumpAndSettle();
      // Only active courier should appear — 'Ali Kurye' is active.
      await tester.tap(find.text('Ali Kurye').last);
      await tester.pumpAndSettle();

      // Scroll to see the Ata button.
      await reveal(tester, find.byKey(const Key('assign_courier_button')));

      // Tap Ata button.
      await tester.tap(find.byKey(const Key('assign_courier_button')));
      await tester.pumpAndSettle();

      // Verify update was called with correct fields.
      final updated = fakeSiparisRepo.store['s1']!;
      expect(updated.kuryeId, 'kurye-1');
      expect(updated.durum, SiparisDurum.devamEdiyor);
      expect(updated.atanmaSaat, isNotNull);

      // Verify a log was created.
      expect(fakeLogRepo.store.length, 1);
      final log = fakeLogRepo.store.values.first;
      expect(log.siparisId, 's1');
      expect(log.eskiDurum, SiparisDurum.kuryeBekliyor);
      expect(log.yeniDurum, SiparisDurum.devamEdiyor);
      expect(log.degistirenId, _testUserId);
    });

    testWidgets('(d) finish with auto-pricing — historical match found', (
      tester,
    ) async {
      // Seed an in-progress order.
      fakeSiparisRepo.store['s2'] = const Siparis(
        id: 's2',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-2',
        kuryeId: 'kurye-1',
        durum: SiparisDurum.devamEdiyor,
      );

      // Seed a historical completed order with the same route for pricing.
      fakeSiparisRepo.store['s-hist'] = Siparis(
        id: 's-hist',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-2',
        durum: SiparisDurum.tamamlandi,
        ucret: 75.5,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      await pumpPage(tester);

      // Scroll to active panel.
      await reveal(tester, find.textContaining('DEVAM EDEN İŞLER'));

      // Select the active order.
      await tester.tap(find.byKey(const Key('active_s2')));
      await tester.pumpAndSettle();

      // Scroll to and tap Bitir button.
      await reveal(tester, find.byKey(const Key('finish_s2')));
      await tester.tap(find.byKey(const Key('finish_s2')));
      await tester.pumpAndSettle();

      // Verify auto-pricing was applied.
      final updated = fakeSiparisRepo.store['s2']!;
      expect(updated.ucret, 75.5);
      expect(updated.durum, SiparisDurum.tamamlandi);
      expect(updated.bitisSaat, isNotNull);

      // Verify log entry.
      final logs = fakeLogRepo.store.values
          .where((l) => l.siparisId == 's2')
          .toList();
      expect(logs.length, 1);
      expect(logs.first.eskiDurum, SiparisDurum.devamEdiyor);
      expect(logs.first.yeniDurum, SiparisDurum.tamamlandi);
    });

    testWidgets('(e) manual pricing fallback — no historical match', (
      tester,
    ) async {
      // Seed an in-progress order with no historical pricing match.
      fakeSiparisRepo.store['s3'] = const Siparis(
        id: 's3',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-3', // Different ugrama — no match.
        kuryeId: 'kurye-1',
        durum: SiparisDurum.devamEdiyor,
      );

      await pumpPage(tester);

      // Scroll to active panel.
      await reveal(tester, find.textContaining('DEVAM EDEN İŞLER'));

      // Select the order.
      await tester.tap(find.byKey(const Key('active_s3')));
      await tester.pumpAndSettle();

      // Scroll to and tap Bitir.
      await reveal(tester, find.byKey(const Key('finish_s3')));
      await tester.tap(find.byKey(const Key('finish_s3')));
      // Use pump() instead of pumpAndSettle() — the async _onFinish is
      // awaiting the dialog, so the widget tree won't settle until the
      // dialog is dismissed.
      await tester.pump();
      await tester.pump();

      // Manual pricing dialog should appear.
      expect(find.text('Ücret Giriniz'), findsOneWidget);

      // Enter a price.
      await tester.enterText(
        find.byKey(const Key('manual_price_field')),
        '120',
      );
      await tester.pump();

      // Confirm.
      await tester.tap(find.byKey(const Key('manual_price_confirm')));
      await tester.pumpAndSettle();

      // Verify the order was completed with manual price.
      final updated = fakeSiparisRepo.store['s3']!;
      expect(updated.ucret, 120.0);
      expect(updated.durum, SiparisDurum.tamamlandi);
      expect(updated.bitisSaat, isNotNull);

      // Verify log entry.
      expect(
        fakeLogRepo.store.values.where((l) => l.siparisId == 's3').length,
        1,
      );
    });

    testWidgets('(f) active order can be edited and saved from row action', (
      tester,
    ) async {
      fakeSiparisRepo.store['s-edit'] = const Siparis(
        id: 's-edit',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-2',
        kuryeId: 'kurye-1',
        durum: SiparisDurum.devamEdiyor,
      );

      await pumpPage(tester);

      await reveal(tester, find.byKey(const Key('edit_active_s-edit')));
      await tester.tap(find.byKey(const Key('edit_active_s-edit')));
      await tester.pumpAndSettle();

      expect(find.text('Devam Eden Siparişi Düzenle'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('active_edit_note_field')),
        'Müşteri telefonda teyit edildi',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('active_edit_save_button')));
      await tester.pumpAndSettle();

      final updated = fakeSiparisRepo.store['s-edit']!;
      expect(updated.not1, 'Müşteri telefonda teyit edildi');
      expect(updated.durum, SiparisDurum.devamEdiyor);
    });

    testWidgets(
      '(g) sound alert fires only on genuinely new kurye_bekliyor orders',
      (tester) async {
        final fakeAlert = FakeOrderAlertService();

        // Seed one existing waiting order.
        fakeSiparisRepo.store['s1'] = const Siparis(
          id: 's1',
          musteriId: 'musteri-1',
          cikisId: 'ugrama-1',
          ugramaId: 'ugrama-2',
        );

        await pumpPage(tester, alertService: fakeAlert);

        // Initial load — should NOT trigger alert.
        expect(fakeAlert.alertCallCount, 0);

        // Emit a second list with one NEW waiting order added.
        fakeSiparisRepo.emitActive([
          const Siparis(
            id: 's1',
            musteriId: 'musteri-1',
            cikisId: 'ugrama-1',
            ugramaId: 'ugrama-2',
          ),
          const Siparis(
            id: 's-new',
            musteriId: 'musteri-1',
            cikisId: 'ugrama-2',
            ugramaId: 'ugrama-3',
          ),
        ]);
        await tester.pumpAndSettle();

        // Alert should fire once for the new order.
        expect(fakeAlert.alertCallCount, 1);

        // Emit same list again — no new IDs, no alert.
        fakeSiparisRepo.emitActive([
          const Siparis(
            id: 's1',
            musteriId: 'musteri-1',
            cikisId: 'ugrama-1',
            ugramaId: 'ugrama-2',
          ),
          const Siparis(
            id: 's-new',
            musteriId: 'musteri-1',
            cikisId: 'ugrama-2',
            ugramaId: 'ugrama-3',
          ),
        ]);
        await tester.pumpAndSettle();

        // Should still be 1 — no new IDs appeared.
        expect(fakeAlert.alertCallCount, 1);
      },
    );

    testWidgets('(h) active panel shows resolved stop and courier names', (
      tester,
    ) async {
      // Seed an in-progress order with known IDs.
      fakeSiparisRepo.store['s-act'] = const Siparis(
        id: 's-act',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1', // → Merkez Ofis
        ugramaId: 'ugrama-3', // → Şube B
        kuryeId: 'kurye-1', // → Ali Kurye
        durum: SiparisDurum.devamEdiyor,
      );

      await pumpPage(tester);

      // Scroll to active panel.
      await reveal(tester, find.textContaining('DEVAM EDEN İŞLER'));

      // Route label should show resolved stop names.
      expect(find.text('Merkez Ofis → Şube B'), findsOneWidget);
      // Action badge should show resolved courier name.
      expect(find.text('ALI KURYE'), findsOneWidget);
    });

    testWidgets('(i) unknown IDs fall back to raw UUID strings', (
      tester,
    ) async {
      // Seed an order with IDs that are NOT in our test ugrama/kurye sets.
      fakeSiparisRepo.store['s-unknown'] = const Siparis(
        id: 's-unknown',
        musteriId: 'musteri-1',
        cikisId: 'unknown-stop-x',
        ugramaId: 'unknown-stop-y',
        kuryeId: 'unknown-courier-z',
        durum: SiparisDurum.devamEdiyor,
      );

      await pumpPage(tester);

      // Scroll to active panel.
      await reveal(tester, find.textContaining('DEVAM EDEN İŞLER'));

      // Fallback: raw IDs should appear.
      expect(
        find.text('unknown-stop-x → unknown-stop-y'),
        findsOneWidget,
      );
      expect(find.text('ATANMADI'), findsOneWidget);
    });

    testWidgets('(j) desktop active row is resilient to missing customer/personnel data', (
      tester,
    ) async {
      fakeSiparisRepo.store['s-desktop'] = const Siparis(
        id: 's-desktop',
        musteriId: 'missing-musteri',
        personelId: 'missing-personel',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-2',
        kuryeId: 'kurye-1',
        durum: SiparisDurum.devamEdiyor,
      );

      await pumpPage(
        tester,
        size: const Size(1440, 1200),
      );

      await reveal(tester, find.textContaining('DEVAM EDEN İŞLER'));

      expect(find.text('missing-musteri'), findsOneWidget);
      expect(find.text('missing-personel'), findsOneWidget);
      expect(find.byKey(const Key('finish_s-desktop')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('(k) desktop summary shows today revenue from completed orders', (
      tester,
    ) async {
      final now = DateTime.now();
      fakeSiparisRepo.store['s-today-completed'] = Siparis(
        id: 's-today-completed',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-2',
        durum: SiparisDurum.tamamlandi,
        ucret: 150,
        createdAt: now,
      );
      fakeSiparisRepo.store['s-yesterday-completed'] = Siparis(
        id: 's-yesterday-completed',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-1',
        ugramaId: 'ugrama-2',
        durum: SiparisDurum.tamamlandi,
        ucret: 250,
        createdAt: now.subtract(const Duration(days: 1)),
      );

      await pumpPage(
        tester,
        size: const Size(1440, 1200),
      );

      expect(find.text('150 TL'), findsOneWidget);
    });

    testWidgets(
      '(l) finishing order updates today revenue without manual refresh',
      (tester) async {
        final now = DateTime.now();
        fakeSiparisRepo.store['s-live'] = Siparis(
          id: 's-live',
          musteriId: 'musteri-1',
          cikisId: 'ugrama-1',
          ugramaId: 'ugrama-2',
          kuryeId: 'kurye-1',
          durum: SiparisDurum.devamEdiyor,
          createdAt: now,
        );
        fakeSiparisRepo.store['s-hist-price'] = Siparis(
          id: 's-hist-price',
          musteriId: 'musteri-1',
          cikisId: 'ugrama-1',
          ugramaId: 'ugrama-2',
          durum: SiparisDurum.tamamlandi,
          ucret: 75,
          createdAt: now.subtract(const Duration(days: 1)),
        );

        await pumpPage(
          tester,
          size: const Size(1440, 1200),
        );

        expect(find.text('0 TL'), findsOneWidget);

        await reveal(tester, find.byKey(const Key('finish_s-live')));
        await tester.tap(find.byKey(const Key('finish_s-live')));
        await tester.pumpAndSettle();

        expect(find.text('75 TL'), findsOneWidget);
      },
    );
  });
}
