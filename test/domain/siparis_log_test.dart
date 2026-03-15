import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SiparisLog', () {
    test('fromJson/toJson roundtrip with all fields', () {
      final json = {
        'id': 'log-1',
        'siparis_id': 'siparis-1',
        'eski_durum': 'kurye_bekliyor',
        'yeni_durum': 'devam_ediyor',
        'degistiren_id': 'user-1',
        'aciklama': 'Kurye atandı',
        'created_at': '2026-03-15T09:00:00.000Z',
      };

      final log = SiparisLog.fromJson(json);
      expect(log.id, 'log-1');
      expect(log.siparisId, 'siparis-1');
      expect(log.eskiDurum, SiparisDurum.kuryeBekliyor);
      expect(log.yeniDurum, SiparisDurum.devamEdiyor);
      expect(log.degistirenId, 'user-1');
      expect(log.aciklama, 'Kurye atandı');
      expect(log.createdAt, isNotNull);

      final output = log.toJson();
      expect(output['siparis_id'], 'siparis-1');
      expect(output['eski_durum'], 'kurye_bekliyor');
      expect(output['yeni_durum'], 'devam_ediyor');
      expect(output['degistiren_id'], 'user-1');
      expect(output['aciklama'], 'Kurye atandı');
    });

    test('fromJson handles nullable eskiDurum', () {
      final json = {
        'id': 'log-2',
        'siparis_id': 'siparis-2',
        'eski_durum': null,
        'yeni_durum': 'kurye_bekliyor',
        'degistiren_id': null,
        'aciklama': null,
        'created_at': '2026-03-15T09:00:00.000Z',
      };

      final log = SiparisLog.fromJson(json);
      expect(log.eskiDurum, isNull);
      expect(log.yeniDurum, SiparisDurum.kuryeBekliyor);
      expect(log.degistirenId, isNull);
      expect(log.aciklama, isNull);
    });

    test('toJson preserves null eskiDurum as null', () {
      const log = SiparisLog(
        id: 'log-3',
        siparisId: 'siparis-3',
        yeniDurum: SiparisDurum.tamamlandi,
      );

      final json = log.toJson();
      expect(json['eski_durum'], isNull);
      expect(json['yeni_durum'], 'tamamlandi');
      expect(json['degistiren_id'], isNull);
      expect(json['aciklama'], isNull);
      expect(json['created_at'], isNull);
    });

    test('all SiparisDurum enum values roundtrip through JSON', () {
      for (final durum in SiparisDurum.values) {
        final json = {
          'id': 'log-rt',
          'siparis_id': 'siparis-rt',
          'eski_durum': durum.value,
          'yeni_durum': durum.value,
          'created_at': '2026-03-15T09:00:00.000Z',
        };

        final log = SiparisLog.fromJson(json);
        expect(log.eskiDurum, durum);
        expect(log.yeniDurum, durum);

        final output = log.toJson();
        expect(output['eski_durum'], durum.value);
        expect(output['yeni_durum'], durum.value);
      }
    });

    test('fromJson without eski_durum key treats as null', () {
      final json = {
        'id': 'log-4',
        'siparis_id': 'siparis-4',
        'yeni_durum': 'iptal',
        'created_at': '2026-03-15T09:00:00.000Z',
      };

      final log = SiparisLog.fromJson(json);
      expect(log.eskiDurum, isNull);
      expect(log.yeniDurum, SiparisDurum.iptal);
    });
  });
}
