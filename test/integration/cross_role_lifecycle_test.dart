import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes/fake_kurye_repository.dart';
import '../helpers/fakes/fake_musteri_personel_repository.dart';
import '../helpers/fakes/fake_siparis_log_repository.dart';
import '../helpers/fakes/fake_siparis_repository.dart';
import '../helpers/fakes/fake_ugrama_repository.dart';

/// Cross-role integration test proving the full order lifecycle:
///
///   müşteri creates → ops sees in waiting → ops assigns courier →
///   courier sees order → courier punches timestamps →
///   ops finishes with price → tamamlandı
///
/// This is the R008 validation gate and M001 definition-of-done proof.
void main() {
  // ---------------------------------------------------------------------------
  // Shared IDs
  // ---------------------------------------------------------------------------
  const musteriId = 'musteri-1';
  const personelId = 'personel-1';
  const kuryeId = 'kurye-1';
  const cikisUgramaId = 'ugrama-cikis';
  const varisUgramaId = 'ugrama-varis';

  // ---------------------------------------------------------------------------
  // Fake repositories
  // ---------------------------------------------------------------------------
  late FakeSiparisRepository siparisRepo;
  late FakeSiparisLogRepository logRepo;
  late FakeKuryeRepository kuryeRepo;
  late FakeUgramaRepository ugramaRepo;
  late FakeMusteriPersonelRepository personelRepo;

  setUp(() {
    siparisRepo = FakeSiparisRepository();
    logRepo = FakeSiparisLogRepository();

    kuryeRepo = FakeKuryeRepository(
      seed: [
        const Kurye(
          id: kuryeId,
          ad: 'Ali Kurye',
          telefon: '555-0001',
          plaka: '34 AB 123',
        ),
      ],
    );

    ugramaRepo = FakeUgramaRepository(
      seed: [
        const Ugrama(
          id: cikisUgramaId,
          musteriId: musteriId,
          ugramaAdi: 'Merkez Ofis',
        ),
        const Ugrama(
          id: varisUgramaId,
          musteriId: musteriId,
          ugramaAdi: 'Şube Depo',
        ),
      ],
    );

    personelRepo = FakeMusteriPersonelRepository(
      seed: [
        const MusteriPersonel(
          id: personelId,
          musteriId: musteriId,
          ad: 'Ayşe Personel',
          telefon: '555-0002',
        ),
      ],
    );
  });

  tearDown(() async {
    await siparisRepo.dispose();
  });

  group('Cross-role order lifecycle', () {
    test('full lifecycle: create → wait → assign → courier → timestamps → finish', () async {
      // -----------------------------------------------------------------------
      // Step 1: Müşteri creates order
      // -----------------------------------------------------------------------
      final created = await siparisRepo.create(
        const Siparis(
          id: '',
          musteriId: musteriId,
          personelId: personelId,
          cikisId: cikisUgramaId,
          ugramaId: varisUgramaId,
          olusturanId: personelId,
        ),
      );

      // Log the creation transition
      await logRepo.create(
        SiparisLog(
          id: '',
          siparisId: created.id,
          yeniDurum: SiparisDurum.kuryeBekliyor,
          degistirenId: personelId,
          aciklama: 'Sipariş oluşturuldu',
        ),
      );

      expect(created.id, isNotEmpty);
      expect(created.musteriId, musteriId);
      expect(created.cikisId, cikisUgramaId);
      expect(created.ugramaId, varisUgramaId);
      expect(created.durum, SiparisDurum.kuryeBekliyor);
      expect(created.kuryeId, isNull);
      expect(created.ucret, isNull);
      expect(created.atanmaSaat, isNull);
      expect(created.bitisSaat, isNull);

      // -----------------------------------------------------------------------
      // Step 2: Ops sees order in active stream (waiting panel)
      // -----------------------------------------------------------------------
      final activeCompleter = Completer<List<Siparis>>();
      final activeSub = siparisRepo.streamActive().listen((orders) {
        if (!activeCompleter.isCompleted) {
          activeCompleter.complete(orders);
        }
      });

      final activeOrders = await activeCompleter.future;
      expect(activeOrders, hasLength(1));
      expect(activeOrders.first.id, created.id);
      expect(activeOrders.first.durum, SiparisDurum.kuryeBekliyor);
      await activeSub.cancel();

      // Verify courier and ugrama data are available for dispatch display
      final courier = await kuryeRepo.getById(kuryeId);
      expect(courier, isNotNull);
      expect(courier!.ad, 'Ali Kurye');

      final cikisUgrama = await ugramaRepo.getById(cikisUgramaId);
      final varisUgrama = await ugramaRepo.getById(varisUgramaId);
      expect(cikisUgrama!.ugramaAdi, 'Merkez Ofis');
      expect(varisUgrama!.ugramaAdi, 'Şube Depo');

      // -----------------------------------------------------------------------
      // Step 3: Ops assigns courier → devam_ediyor
      // -----------------------------------------------------------------------
      final atanmaSaat = DateTime.now();
      final assigned = await siparisRepo.update(created.id, {
        'kurye_id': kuryeId,
        'atanma_saat': atanmaSaat.toIso8601String(),
        'durum': SiparisDurum.devamEdiyor.value,
      });

      // Log the assign transition
      await logRepo.create(
        SiparisLog(
          id: '',
          siparisId: created.id,
          eskiDurum: SiparisDurum.kuryeBekliyor,
          yeniDurum: SiparisDurum.devamEdiyor,
          degistirenId: 'ops-user',
          aciklama: 'Kurye atandı',
        ),
      );

      expect(assigned.durum, SiparisDurum.devamEdiyor);
      expect(assigned.kuryeId, kuryeId);
      expect(assigned.atanmaSaat, isNotNull);
      // Order still retains origin data
      expect(assigned.musteriId, musteriId);
      expect(assigned.cikisId, cikisUgramaId);
      expect(assigned.ugramaId, varisUgramaId);

      // -----------------------------------------------------------------------
      // Step 4: Courier sees order on their stream
      // -----------------------------------------------------------------------
      final kuryeCompleter = Completer<List<Siparis>>();
      final kuryeSub = siparisRepo.streamByKuryeId(kuryeId).listen((orders) {
        if (!kuryeCompleter.isCompleted) {
          kuryeCompleter.complete(orders);
        }
      });

      final kuryeOrders = await kuryeCompleter.future;
      expect(kuryeOrders, hasLength(1));
      expect(kuryeOrders.first.id, created.id);
      expect(kuryeOrders.first.durum, SiparisDurum.devamEdiyor);
      expect(kuryeOrders.first.kuryeId, kuryeId);
      await kuryeSub.cancel();

      // -----------------------------------------------------------------------
      // Step 5: Courier punches timestamps (çıkış, uğrama)
      // -----------------------------------------------------------------------
      final cikisSaat = DateTime.now();
      final withCikis = await siparisRepo.update(created.id, {
        'cikis_saat': cikisSaat.toIso8601String(),
      });
      expect(withCikis.cikisSaat, isNotNull);
      expect(withCikis.durum, SiparisDurum.devamEdiyor); // still in progress

      final ugramaSaat = DateTime.now().add(const Duration(minutes: 15));
      final withUgrama = await siparisRepo.update(created.id, {
        'ugrama_saat': ugramaSaat.toIso8601String(),
      });
      expect(withUgrama.ugramaSaat, isNotNull);
      expect(withUgrama.cikisSaat, isNotNull); // previous timestamp preserved
      expect(withUgrama.durum, SiparisDurum.devamEdiyor);

      // -----------------------------------------------------------------------
      // Step 6: Ops finishes with price → tamamlandı
      // -----------------------------------------------------------------------
      final bitisSaat = DateTime.now().add(const Duration(minutes: 30));
      const ucret = 150.0;
      final finished = await siparisRepo.update(created.id, {
        'durum': SiparisDurum.tamamlandi.value,
        'ucret': ucret,
        'bitis_saat': bitisSaat.toIso8601String(),
      });

      // Log the finish transition
      await logRepo.create(
        SiparisLog(
          id: '',
          siparisId: created.id,
          eskiDurum: SiparisDurum.devamEdiyor,
          yeniDurum: SiparisDurum.tamamlandi,
          degistirenId: 'ops-user',
          aciklama: 'Sipariş tamamlandı',
        ),
      );

      // --- Final state assertions ---
      expect(finished.durum, SiparisDurum.tamamlandi);
      expect(finished.ucret, ucret);
      expect(finished.bitisSaat, isNotNull);
      expect(finished.kuryeId, kuryeId);
      expect(finished.musteriId, musteriId);
      expect(finished.cikisId, cikisUgramaId);
      expect(finished.ugramaId, varisUgramaId);

      // --- Verify all timestamps are populated ---
      expect(finished.atanmaSaat, isNotNull, reason: 'atanma_saat must be set');
      expect(finished.cikisSaat, isNotNull, reason: 'cikis_saat must be set');
      expect(finished.ugramaSaat, isNotNull, reason: 'ugrama_saat must be set');
      expect(finished.bitisSaat, isNotNull, reason: 'bitis_saat must be set');

      // --- Verify siparis_log entries ---
      final logs = await logRepo.getBySiparisId(created.id);
      expect(logs, hasLength(3));

      // Log 1: creation
      final createLog = logs[0];
      expect(createLog.yeniDurum, SiparisDurum.kuryeBekliyor);
      expect(createLog.eskiDurum, isNull);
      expect(createLog.degistirenId, personelId);

      // Log 2: assign
      final assignLog = logs[1];
      expect(assignLog.eskiDurum, SiparisDurum.kuryeBekliyor);
      expect(assignLog.yeniDurum, SiparisDurum.devamEdiyor);
      expect(assignLog.degistirenId, 'ops-user');

      // Log 3: finish
      final finishLog = logs[2];
      expect(finishLog.eskiDurum, SiparisDurum.devamEdiyor);
      expect(finishLog.yeniDurum, SiparisDurum.tamamlandi);
      expect(finishLog.degistirenId, 'ops-user');

      // --- Verify the finished order no longer appears on active stream ---
      final finalActiveOrders =
          await siparisRepo.getByDurum(SiparisDurum.kuryeBekliyor);
      expect(finalActiveOrders, isEmpty);
      final finalInProgress =
          await siparisRepo.getByDurum(SiparisDurum.devamEdiyor);
      expect(finalInProgress, isEmpty);

      // --- Verify it appears in history ---
      final history = await siparisRepo.getHistory();
      expect(history, hasLength(1));
      expect(history.first.durum, SiparisDurum.tamamlandi);
      expect(history.first.ucret, ucret);
    });

    test('stream reactivity: active stream updates on each status transition', () async {
      // Track all emissions from the active stream
      final emissions = <List<Siparis>>[];
      final sub = siparisRepo.streamActive().listen(emissions.add);

      // Allow initial empty emission
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, isEmpty);

      // Create order → should appear in active
      final order = await siparisRepo.create(
        const Siparis(
          id: '',
          musteriId: musteriId,
          personelId: personelId,
          cikisId: cikisUgramaId,
          ugramaId: varisUgramaId,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, hasLength(1));
      expect(emissions.last.first.durum, SiparisDurum.kuryeBekliyor);

      // Assign courier → still active but devam_ediyor
      await siparisRepo.update(order.id, {
        'kurye_id': kuryeId,
        'durum': SiparisDurum.devamEdiyor.value,
        'atanma_saat': DateTime.now().toIso8601String(),
      });
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, hasLength(1));
      expect(emissions.last.first.durum, SiparisDurum.devamEdiyor);

      // Finish → no longer active
      await siparisRepo.update(order.id, {
        'durum': SiparisDurum.tamamlandi.value,
        'ucret': 100.0,
        'bitis_saat': DateTime.now().toIso8601String(),
      });
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, isEmpty);

      await sub.cancel();
    });

    test('courier stream only shows orders assigned to that courier', () async {
      const otherKuryeId = 'kurye-other';

      // Create two orders, assign to different couriers
      final order1 = await siparisRepo.create(
        const Siparis(
          id: '',
          musteriId: musteriId,
          cikisId: cikisUgramaId,
          ugramaId: varisUgramaId,
        ),
      );
      final order2 = await siparisRepo.create(
        const Siparis(
          id: '',
          musteriId: musteriId,
          cikisId: cikisUgramaId,
          ugramaId: varisUgramaId,
        ),
      );

      // Assign order1 to our courier, order2 to other courier
      await siparisRepo.update(order1.id, {
        'kurye_id': kuryeId,
        'durum': SiparisDurum.devamEdiyor.value,
      });
      await siparisRepo.update(order2.id, {
        'kurye_id': otherKuryeId,
        'durum': SiparisDurum.devamEdiyor.value,
      });

      // Courier stream for our courier should only show order1
      final completer = Completer<List<Siparis>>();
      final sub = siparisRepo.streamByKuryeId(kuryeId).listen((orders) {
        if (!completer.isCompleted) {
          completer.complete(orders);
        }
      });

      final kuryeOrders = await completer.future;
      expect(kuryeOrders, hasLength(1));
      expect(kuryeOrders.first.id, order1.id);
      await sub.cancel();
    });

    test('name resolution data available for all entities in lifecycle', () async {
      // Verify that all supporting repositories provide the names
      // that the dispatch and courier screens need to resolve IDs.

      // Ugrama names
      final allUgramalar = await ugramaRepo.getAll();
      expect(allUgramalar, hasLength(2));
      final ugramaMap = {for (final u in allUgramalar) u.id: u.ugramaAdi};
      expect(ugramaMap[cikisUgramaId], 'Merkez Ofis');
      expect(ugramaMap[varisUgramaId], 'Şube Depo');

      // Courier names
      final allKuryeler = await kuryeRepo.getAll();
      expect(allKuryeler, hasLength(1));
      final kuryeMap = {for (final k in allKuryeler) k.id: k.ad};
      expect(kuryeMap[kuryeId], 'Ali Kurye');

      // Personnel names
      final personel = await personelRepo.getById(personelId);
      expect(personel, isNotNull);
      expect(personel!.ad, 'Ayşe Personel');
    });

    test('recent pricing lookup works after completed order', () async {
      // Complete a full order lifecycle first
      final order = await siparisRepo.create(
        const Siparis(
          id: '',
          musteriId: musteriId,
          cikisId: cikisUgramaId,
          ugramaId: varisUgramaId,
        ),
      );

      await siparisRepo.update(order.id, {
        'kurye_id': kuryeId,
        'durum': SiparisDurum.devamEdiyor.value,
        'atanma_saat': DateTime.now().toIso8601String(),
      });

      await siparisRepo.update(order.id, {
        'durum': SiparisDurum.tamamlandi.value,
        'ucret': 200.0,
        'bitis_saat': DateTime.now().toIso8601String(),
      });

      // Auto-pricing lookup should find this completed order
      final recentPricing = await siparisRepo.getRecentPricing(
        musteriId: musteriId,
        cikisId: cikisUgramaId,
        ugramaId: varisUgramaId,
      );

      expect(recentPricing, isNotNull);
      expect(recentPricing!.ucret, 200.0);
      expect(recentPricing.durum, SiparisDurum.tamamlandi);
    });
  });
}
