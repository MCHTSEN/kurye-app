import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ugrama', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'ugrama-1',
        'ugrama_adi': 'Merkez Depo',
        'adres': 'Ataşehir, İstanbul',
        'is_active': true,
        'created_at': '2026-03-15T00:00:00.000Z',
      };

      final ugrama = Ugrama.fromJson(json);
      expect(ugrama.id, 'ugrama-1');
      expect(ugrama.ugramaAdi, 'Merkez Depo');
      expect(ugrama.adres, 'Ataşehir, İstanbul');
      expect(ugrama.isActive, true);
      expect(ugrama.createdAt, isNotNull);

      final output = ugrama.toJson();
      expect(output['ugrama_adi'], 'Merkez Depo');
      // musteri_id no longer part of Ugrama model (many-to-many via bridge)
      expect(output.containsKey('musteri_id'), false);
    });

    test('lokasyon null handling — field not present in model', () {
      // lokasyon (Geography) is intentionally excluded from the model.
      // JSON from Supabase with explicit column selection won't include it.
      final json = {
        'id': 'ugrama-2',
        'ugrama_adi': 'Şube',
        'adres': null,
        'is_active': true,
        'created_at': null,
      };

      final ugrama = Ugrama.fromJson(json);
      expect(ugrama.adres, isNull);
      expect(ugrama.createdAt, isNull);

      final output = ugrama.toJson();
      expect(output.containsKey('lokasyon'), false);
    });
  });
}
