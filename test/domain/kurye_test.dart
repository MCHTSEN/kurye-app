import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kurye', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'kurye-1',
        'user_id': 'user-2',
        'ad': 'Mehmet Demir',
        'telefon': '05551112233',
        'plaka': '34 ABC 123',
        'is_active': true,
        'is_online': true,
        'created_at': '2026-03-15T00:00:00.000Z',
        'updated_at': '2026-03-15T00:00:00.000Z',
      };

      final kurye = Kurye.fromJson(json);
      expect(kurye.id, 'kurye-1');
      expect(kurye.userId, 'user-2');
      expect(kurye.ad, 'Mehmet Demir');
      expect(kurye.telefon, '05551112233');
      expect(kurye.plaka, '34 ABC 123');
      expect(kurye.isActive, true);
      expect(kurye.isOnline, true);
      expect(kurye.createdAt, isNotNull);
      expect(kurye.updatedAt, isNotNull);

      final output = kurye.toJson();
      expect(output['ad'], 'Mehmet Demir');
      expect(output['plaka'], '34 ABC 123');
      expect(output['is_online'], true);
    });

    test('fromJson defaults is_online to false', () {
      final json = {
        'id': 'kurye-2',
        'ad': 'Ali',
      };

      final kurye = Kurye.fromJson(json);
      expect(kurye.userId, isNull);
      expect(kurye.telefon, isNull);
      expect(kurye.plaka, isNull);
      expect(kurye.isActive, true);
      expect(kurye.isOnline, false);
      expect(kurye.createdAt, isNull);
      expect(kurye.updatedAt, isNull);
    });
  });
}
