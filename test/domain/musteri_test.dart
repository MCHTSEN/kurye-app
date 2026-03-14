import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Musteri', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'firma_kisa_ad': 'ABC',
        'firma_tam_ad': 'ABC Lojistik Ltd.',
        'telefon': '05551234567',
        'adres': 'İstanbul, Kadıköy',
        'email': 'info@abc.com',
        'vergi_no': '1234567890',
        'is_active': true,
        'created_at': '2026-03-15T00:00:00.000Z',
        'updated_at': '2026-03-15T00:00:00.000Z',
      };

      final musteri = Musteri.fromJson(json);
      expect(musteri.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(musteri.firmaKisaAd, 'ABC');
      expect(musteri.firmaTamAd, 'ABC Lojistik Ltd.');
      expect(musteri.telefon, '05551234567');
      expect(musteri.adres, 'İstanbul, Kadıköy');
      expect(musteri.email, 'info@abc.com');
      expect(musteri.vergiNo, '1234567890');
      expect(musteri.isActive, true);
      expect(musteri.createdAt, isNotNull);
      expect(musteri.updatedAt, isNotNull);

      final output = musteri.toJson();
      expect(output['firma_kisa_ad'], 'ABC');
      expect(output['firma_tam_ad'], 'ABC Lojistik Ltd.');
      expect(output['vergi_no'], '1234567890');
    });

    test('fromJson handles nullable fields', () {
      final json = {
        'id': 'abc',
        'firma_kisa_ad': 'Test',
      };

      final musteri = Musteri.fromJson(json);
      expect(musteri.firmaTamAd, isNull);
      expect(musteri.telefon, isNull);
      expect(musteri.adres, isNull);
      expect(musteri.email, isNull);
      expect(musteri.vergiNo, isNull);
      expect(musteri.isActive, true);
      expect(musteri.createdAt, isNull);
      expect(musteri.updatedAt, isNull);
    });
  });
}
