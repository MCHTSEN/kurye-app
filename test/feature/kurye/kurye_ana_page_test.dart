import 'package:backend_core/backend_core.dart';
import 'package:bursamotokurye/feature/kurye/presentation/kurye_ana_page.dart';
import 'package:bursamotokurye/product/kurye/kurye_providers.dart';
import 'package:bursamotokurye/product/siparis/siparis_providers.dart';
import 'package:bursamotokurye/product/ugrama/ugrama_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_kurye_repository.dart';
import '../../helpers/fakes/fake_siparis_repository.dart';
import '../../helpers/fakes/fake_ugrama_repository.dart';
import '../../helpers/widgets/test_app.dart';

const _testKuryeId = 'kurye-test-1';
const _testUserId = 'auth-uid-1';

const _testKurye = Kurye(
  id: _testKuryeId,
  ad: 'Test Kurye',
  userId: _testUserId,
  isOnline: false,
);

final _testUgramalar = [
  const Ugrama(id: 'cikis-a', ugramaAdi: 'Depo A'),
  const Ugrama(id: 'ugrama-b', ugramaAdi: 'Şube B'),
  const Ugrama(id: 'ugrama-c', ugramaAdi: 'Şube C'),
];

void main() {
  group('KuryeAnaPage', () {
    late FakeKuryeRepository fakeKuryeRepo;
    late FakeSiparisRepository fakeSiparisRepo;
    late FakeUgramaRepository fakeUgramaRepo;

    setUp(() {
      fakeKuryeRepo = FakeKuryeRepository(seed: [_testKurye]);
      fakeSiparisRepo = FakeSiparisRepository();
      fakeUgramaRepo = FakeUgramaRepository(seed: _testUgramalar);
    });

    Future<void> pumpPage(
      WidgetTester tester, {
      Kurye? kurye,
      bool nullKurye = false,
    }) async {
      final kuryeValue = nullKurye
          ? const AsyncValue<Kurye?>.data(null)
          : AsyncValue<Kurye?>.data(kurye ?? _testKurye);

      await tester.pumpApp(
        const KuryeAnaPage(),
        overrides: [
          currentKuryeProvider.overrideWith((_) => kuryeValue.value),
          kuryeRepositoryProvider.overrideWithValue(fakeKuryeRepo),
          siparisRepositoryProvider.overrideWithValue(fakeSiparisRepo),
          ugramaRepositoryProvider.overrideWithValue(fakeUgramaRepo),
        ],
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      '(a) toggle renders with correct initial state '
      'and toggling fires updateOnlineStatus',
      (tester) async {
        await pumpPage(tester);

        // Initial state: offline → "Pasif".
        expect(find.text('Pasif'), findsOneWidget);
        expect(find.text('Aktif'), findsNothing);

        // Find the switch and verify it's off.
        final switchFinder = find.byKey(const Key('online_toggle'));
        expect(switchFinder, findsOneWidget);
        final switchWidget = tester.widget<Switch>(switchFinder);
        expect(switchWidget.value, isFalse);

        // Toggle it.
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Should now say "Aktif".
        expect(find.text('Aktif'), findsOneWidget);
        expect(find.text('Pasif'), findsNothing);

        // Verify repository was called.
        final updated = fakeKuryeRepo.store[_testKuryeId]!;
        expect(updated.isOnline, isTrue);
      },
    );

    testWidgets(
      '(b) order list renders assigned devam_ediyor orders with route info',
      (tester) async {
        // Seed orders.
        fakeSiparisRepo.store['s1'] = const Siparis(
          id: 's1',
          musteriId: 'musteri-1',
          kuryeId: _testKuryeId,
          cikisId: 'cikis-a',
          ugramaId: 'ugrama-b',
          ugrama1Id: 'ugrama-c',
          durum: SiparisDurum.devamEdiyor,
        );
        // This one is tamamlandi — should not appear.
        fakeSiparisRepo.store['s2'] = const Siparis(
          id: 's2',
          musteriId: 'musteri-1',
          kuryeId: _testKuryeId,
          cikisId: 'cikis-x',
          ugramaId: 'ugrama-y',
          durum: SiparisDurum.tamamlandi,
        );

        await pumpPage(tester);

        // Active order route info should show resolved names.
        expect(find.text('Depo A → Şube B → Şube C'), findsOneWidget);
        // Section title shows count (1 active).
        expect(find.text('Siparişlerim (1)'), findsOneWidget);
        // Completed order should not appear (raw IDs not in ugrama seed).
        expect(find.text('cikis-x → ugrama-y'), findsNothing);
      },
    );

    testWidgets(
      '(c) tapping a timestamp button calls update() with the correct field',
      (tester) async {
        fakeSiparisRepo.store['s1'] = const Siparis(
          id: 's1',
          musteriId: 'musteri-1',
          kuryeId: _testKuryeId,
          cikisId: 'cikis-a',
          ugramaId: 'ugrama-b',
          durum: SiparisDurum.devamEdiyor,
        );

        await pumpPage(tester);

        // Tap "Çıkış" button.
        final cikisBtnFinder = find.byKey(const Key('cikis_btn_s1'));
        expect(cikisBtnFinder, findsOneWidget);
        await tester.tap(cikisBtnFinder);
        await tester.pumpAndSettle();

        // Verify the repo was updated with cikis_saat.
        final updated = fakeSiparisRepo.store['s1']!;
        expect(updated.cikisSaat, isNotNull);
      },
    );

    testWidgets(
      '(d) already-set timestamp shows formatted time and button is disabled',
      (tester) async {
        final setTime = DateTime(2026, 3, 15, 14, 30);
        fakeSiparisRepo.store['s1'] = Siparis(
          id: 's1',
          musteriId: 'musteri-1',
          kuryeId: _testKuryeId,
          cikisId: 'cikis-a',
          ugramaId: 'ugrama-b',
          durum: SiparisDurum.devamEdiyor,
          cikisSaat: setTime,
        );

        await pumpPage(tester);

        // Should show formatted time.
        expect(find.text('Çıkış 14:30'), findsOneWidget);

        // The button should be an OutlinedButton with onPressed: null.
        final btnFinder = find.descendant(
          of: find.byKey(const Key('cikis_btn_s1')),
          matching: find.byType(OutlinedButton),
        );
        expect(btnFinder, findsOneWidget);
        final btn = tester.widget<OutlinedButton>(btnFinder);
        expect(btn.onPressed, isNull);
      },
    );

    testWidgets(
      '(e) ugrama1 button hidden when order has no ugrama1_id',
      (tester) async {
        fakeSiparisRepo.store['s1'] = const Siparis(
          id: 's1',
          musteriId: 'musteri-1',
          kuryeId: _testKuryeId,
          cikisId: 'cikis-a',
          ugramaId: 'ugrama-b',
          // ugrama1Id is null.
          durum: SiparisDurum.devamEdiyor,
        );

        await pumpPage(tester);

        // Çıkış and Uğrama buttons should exist.
        expect(find.byKey(const Key('cikis_btn_s1')), findsOneWidget);
        expect(find.byKey(const Key('ugrama_btn_s1')), findsOneWidget);
        // Uğrama1 button should not exist.
        expect(find.byKey(const Key('ugrama1_btn_s1')), findsNothing);
      },
    );

    testWidgets(
      '(f) missing kurye record shows error, not crash',
      (tester) async {
        await pumpPage(tester, nullKurye: true);

        expect(find.text('Kurye kaydı bulunamadı'), findsOneWidget);
        // No crash, no spinner.
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      '(g) unknown stop IDs fall back to raw UUID strings',
      (tester) async {
        fakeSiparisRepo.store['s-unk'] = const Siparis(
          id: 's-unk',
          musteriId: 'musteri-1',
          kuryeId: _testKuryeId,
          cikisId: 'unknown-x',
          ugramaId: 'unknown-y',
          durum: SiparisDurum.devamEdiyor,
        );

        await pumpPage(tester);

        // Should fall back to raw IDs.
        expect(find.text('unknown-x → unknown-y'), findsOneWidget);
      },
    );
  });
}
