import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SiparisDurum', () {
    test('fromValue maps all enum values', () {
      expect(
        SiparisDurum.fromValue('kurye_bekliyor'),
        SiparisDurum.kuryeBekliyor,
      );
      expect(
        SiparisDurum.fromValue('devam_ediyor'),
        SiparisDurum.devamEdiyor,
      );
      expect(
        SiparisDurum.fromValue('tamamlandi'),
        SiparisDurum.tamamlandi,
      );
      expect(
        SiparisDurum.fromValue('iptal'),
        SiparisDurum.iptal,
      );
    });

    test('fromValue throws on unknown value', () {
      expect(
        () => SiparisDurum.fromValue('bilinmeyen'),
        throwsArgumentError,
      );
    });

    test('value roundtrips through fromValue', () {
      for (final durum in SiparisDurum.values) {
        expect(SiparisDurum.fromValue(durum.value), durum);
      }
    });
  });

  group('Siparis', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'musteri_id': 'musteri-1',
        'personel_id': 'personel-1',
        'kurye_id': 'kurye-1',
        'cikis_id': 'ugrama-cikis',
        'ugrama_id': 'ugrama-ugrama',
        'ugrama1_id': 'ugrama-ugrama1',
        'not_id': 'ugrama-not',
        'not1': 'Acil teslimat',
        'durum': 'kurye_bekliyor',
        'ucret': 150.50,
        'cikis_saat': '2026-03-15T09:00:00.000Z',
        'ugrama_saat': '2026-03-15T09:30:00.000Z',
        'ugrama1_saat': '2026-03-15T10:00:00.000Z',
        'atanma_saat': '2026-03-15T08:50:00.000Z',
        'bitis_saat': '2026-03-15T10:15:00.000Z',
        'olusturan_id': 'user-1',
        'created_at': '2026-03-15T08:00:00.000Z',
        'updated_at': '2026-03-15T10:15:00.000Z',
      };

      final siparis = Siparis.fromJson(json);
      expect(siparis.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(siparis.musteriId, 'musteri-1');
      expect(siparis.personelId, 'personel-1');
      expect(siparis.kuryeId, 'kurye-1');
      expect(siparis.cikisId, 'ugrama-cikis');
      expect(siparis.ugramaId, 'ugrama-ugrama');
      expect(siparis.ugrama1Id, 'ugrama-ugrama1');
      expect(siparis.notId, 'ugrama-not');
      expect(siparis.not1, 'Acil teslimat');
      expect(siparis.durum, SiparisDurum.kuryeBekliyor);
      expect(siparis.ucret, 150.50);
      expect(siparis.cikisSaat, isNotNull);
      expect(siparis.ugramaSaat, isNotNull);
      expect(siparis.ugrama1Saat, isNotNull);
      expect(siparis.atanmaSaat, isNotNull);
      expect(siparis.bitisSaat, isNotNull);
      expect(siparis.olusturanId, 'user-1');
      expect(siparis.createdAt, isNotNull);
      expect(siparis.updatedAt, isNotNull);

      final output = siparis.toJson();
      expect(output['musteri_id'], 'musteri-1');
      expect(output['durum'], 'kurye_bekliyor');
      expect(output['ucret'], 150.50);
      expect(output['not1'], 'Acil teslimat');
      expect(output['not_id'], 'ugrama-not');
    });

    test('fromJson handles nullable timestamp and ucret fields', () {
      final json = {
        'id': 'siparis-1',
        'musteri_id': 'musteri-1',
        'cikis_id': 'ugrama-cikis',
        'ugrama_id': 'ugrama-ugrama',
        'durum': 'devam_ediyor',
      };

      final siparis = Siparis.fromJson(json);
      expect(siparis.personelId, isNull);
      expect(siparis.kuryeId, isNull);
      expect(siparis.ugrama1Id, isNull);
      expect(siparis.notId, isNull);
      expect(siparis.not1, isNull);
      expect(siparis.ucret, isNull);
      expect(siparis.cikisSaat, isNull);
      expect(siparis.ugramaSaat, isNull);
      expect(siparis.ugrama1Saat, isNull);
      expect(siparis.atanmaSaat, isNull);
      expect(siparis.bitisSaat, isNull);
      expect(siparis.olusturanId, isNull);
      expect(siparis.createdAt, isNull);
      expect(siparis.updatedAt, isNull);
    });

    test('ucret handles integer num from JSON', () {
      final json = {
        'id': 'siparis-1',
        'musteri_id': 'musteri-1',
        'cikis_id': 'ugrama-cikis',
        'ugrama_id': 'ugrama-ugrama',
        'durum': 'tamamlandi',
        'ucret': 200,
      };

      final siparis = Siparis.fromJson(json);
      expect(siparis.ucret, 200.0);
      expect(siparis.ucret, isA<double>());
    });

    test('toJson preserves null fields', () {
      const siparis = Siparis(
        id: 'siparis-1',
        musteriId: 'musteri-1',
        cikisId: 'ugrama-cikis',
        ugramaId: 'ugrama-ugrama',
      );

      final json = siparis.toJson();
      expect(json['personel_id'], isNull);
      expect(json['kurye_id'], isNull);
      expect(json['ugrama1_id'], isNull);
      expect(json['not_id'], isNull);
      expect(json['not1'], isNull);
      expect(json['ucret'], isNull);
      expect(json['cikis_saat'], isNull);
      expect(json['ugrama_saat'], isNull);
      expect(json['created_at'], isNull);
    });
  });
}
