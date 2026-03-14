import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole', () {
    test('fromValue parses all valid values', () {
      expect(UserRole.fromValue('musteri_personel'), UserRole.musteriPersonel);
      expect(UserRole.fromValue('operasyon'), UserRole.operasyon);
      expect(UserRole.fromValue('kurye'), UserRole.kurye);
    });

    test('fromValue throws on invalid value', () {
      expect(() => UserRole.fromValue('admin'), throwsArgumentError);
      expect(() => UserRole.fromValue(''), throwsArgumentError);
    });

    test('value returns correct DB string', () {
      expect(UserRole.musteriPersonel.value, 'musteri_personel');
      expect(UserRole.operasyon.value, 'operasyon');
      expect(UserRole.kurye.value, 'kurye');
    });
  });

  group('AppUserProfile', () {
    test('fromJson creates correct profile', () {
      final json = {
        'id': 'test-id',
        'role': 'operasyon',
        'display_name': 'Test User',
        'phone': '555-1234',
        'is_active': true,
        'musteri_id': null,
      };

      final profile = AppUserProfile.fromJson(json);

      expect(profile.id, 'test-id');
      expect(profile.role, UserRole.operasyon);
      expect(profile.displayName, 'Test User');
      expect(profile.phone, '555-1234');
      expect(profile.isActive, true);
      expect(profile.musteriId, isNull);
    });

    test('toJson produces correct map', () {
      const profile = AppUserProfile(
        id: 'test-id',
        role: UserRole.kurye,
        displayName: 'Kurye Ali',
        phone: '555-5678',
      );

      final json = profile.toJson();

      expect(json['id'], 'test-id');
      expect(json['role'], 'kurye');
      expect(json['display_name'], 'Kurye Ali');
      expect(json['phone'], '555-5678');
      expect(json['is_active'], true);
      expect(json['musteri_id'], isNull);
    });

    test('fromJson with musteri_personel role and musteri_id', () {
      final json = {
        'id': 'mp-id',
        'role': 'musteri_personel',
        'display_name': 'Firma Personel',
        'musteri_id': 'musteri-abc',
      };

      final profile = AppUserProfile.fromJson(json);

      expect(profile.role, UserRole.musteriPersonel);
      expect(profile.musteriId, 'musteri-abc');
    });
  });
}
