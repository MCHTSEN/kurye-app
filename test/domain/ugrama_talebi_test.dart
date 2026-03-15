import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UgramaTalebi', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'talep-1',
        'musteri_id': 'musteri-1',
        'talep_eden_id': 'user-1',
        'ugrama_adi': 'Yeni Şube',
        'adres': 'Nilüfer, Bursa',
        'durum': 'beklemede',
        'red_notu': null,
        'islem_yapan_id': null,
        'onaylanan_ugrama_id': null,
        'created_at': '2026-03-15T12:00:00.000Z',
        'updated_at': '2026-03-15T12:00:00.000Z',
      };

      final talep = UgramaTalebi.fromJson(json);
      expect(talep.id, 'talep-1');
      expect(talep.musteriId, 'musteri-1');
      expect(talep.talepEdenId, 'user-1');
      expect(talep.ugramaAdi, 'Yeni Şube');
      expect(talep.adres, 'Nilüfer, Bursa');
      expect(talep.durum, UgramaTalepDurum.beklemede);
      expect(talep.redNotu, isNull);
      expect(talep.islemYapanId, isNull);
      expect(talep.onaylananUgramaId, isNull);
      expect(talep.createdAt, isNotNull);

      final output = talep.toJson();
      expect(output['musteri_id'], 'musteri-1');
      expect(output['ugrama_adi'], 'Yeni Şube');
      expect(output['durum'], 'beklemede');
    });

    test('fromJson handles approved state', () {
      final json = {
        'id': 'talep-2',
        'musteri_id': 'musteri-1',
        'talep_eden_id': 'user-1',
        'ugrama_adi': 'Onaylanan Şube',
        'adres': null,
        'durum': 'onaylandi',
        'red_notu': null,
        'islem_yapan_id': 'ops-1',
        'onaylanan_ugrama_id': 'ugrama-new',
        'created_at': null,
        'updated_at': null,
      };

      final talep = UgramaTalebi.fromJson(json);
      expect(talep.durum, UgramaTalepDurum.onaylandi);
      expect(talep.islemYapanId, 'ops-1');
      expect(talep.onaylananUgramaId, 'ugrama-new');
    });

    test('fromJson handles rejected state with red_notu', () {
      final json = {
        'id': 'talep-3',
        'musteri_id': 'musteri-1',
        'talep_eden_id': 'user-1',
        'ugrama_adi': 'Reddedilen Şube',
        'adres': null,
        'durum': 'reddedildi',
        'red_notu': 'Bu adres zaten mevcut.',
        'islem_yapan_id': 'ops-1',
        'onaylanan_ugrama_id': null,
        'created_at': null,
        'updated_at': null,
      };

      final talep = UgramaTalebi.fromJson(json);
      expect(talep.durum, UgramaTalepDurum.reddedildi);
      expect(talep.redNotu, 'Bu adres zaten mevcut.');
    });
  });

  group('UgramaTalepDurum', () {
    test('all enum values roundtrip through value string', () {
      for (final durum in UgramaTalepDurum.values) {
        final parsed = UgramaTalepDurum.fromValue(durum.value);
        expect(parsed, durum);
      }
    });

    test('fromValue throws on unknown value', () {
      expect(
        () => UgramaTalepDurum.fromValue('bilinmeyen'),
        throwsArgumentError,
      );
    });
  });
}
