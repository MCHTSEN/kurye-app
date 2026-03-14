import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusteriPersonel', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'personel-1',
        'musteri_id': 'musteri-1',
        'user_id': 'user-1',
        'ad': 'Ahmet Yılmaz',
        'telefon': '05559876543',
        'email': 'ahmet@abc.com',
        'is_active': true,
        'created_at': '2026-03-15T00:00:00.000Z',
      };

      final personel = MusteriPersonel.fromJson(json);
      expect(personel.id, 'personel-1');
      expect(personel.musteriId, 'musteri-1');
      expect(personel.userId, 'user-1');
      expect(personel.ad, 'Ahmet Yılmaz');
      expect(personel.telefon, '05559876543');
      expect(personel.email, 'ahmet@abc.com');
      expect(personel.isActive, true);
      expect(personel.createdAt, isNotNull);

      final output = personel.toJson();
      expect(output['musteri_id'], 'musteri-1');
      expect(output['ad'], 'Ahmet Yılmaz');
      expect(output['user_id'], 'user-1');
    });

    test('fromJson handles nullable fields', () {
      final json = {
        'id': 'personel-2',
        'musteri_id': 'musteri-1',
        'ad': 'Veli',
      };

      final personel = MusteriPersonel.fromJson(json);
      expect(personel.userId, isNull);
      expect(personel.telefon, isNull);
      expect(personel.email, isNull);
      expect(personel.isActive, true);
      expect(personel.createdAt, isNull);
    });
  });
}
