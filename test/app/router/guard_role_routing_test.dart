import 'package:backend_core/backend_core.dart';
import 'package:bursamotokurye/app/router/guards/app_access_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppAccessGuard.homePathForRole', () {
    test('musteri_personel maps to /musteri/siparis', () {
      expect(
        AppAccessGuard.homePathForRole(UserRole.musteriPersonel),
        '/musteri/siparis',
      );
    });

    test('operasyon maps to /operasyon/dashboard', () {
      expect(
        AppAccessGuard.homePathForRole(UserRole.operasyon),
        '/operasyon/dashboard',
      );
    });

    test('kurye maps to /kurye/ana', () {
      expect(
        AppAccessGuard.homePathForRole(UserRole.kurye),
        '/kurye/ana',
      );
    });

    test('null role maps to /home', () {
      expect(
        AppAccessGuard.homePathForRole(null),
        '/home',
      );
    });
  });
}
