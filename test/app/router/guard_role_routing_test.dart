import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/app/router/guards/app_access_guard.dart';

void main() {
  group('AppAccessGuard.homePathForRole', () {
    test('musteri_personel maps to /musteri/siparis', () {
      expect(
        AppAccessGuard.homePathForRole(UserRole.musteriPersonel),
        '/musteri/siparis',
      );
    });

    test('operasyon maps to /operasyon', () {
      expect(
        AppAccessGuard.homePathForRole(UserRole.operasyon),
        '/operasyon',
      );
    });

    test('kurye maps to /kurye/ana', () {
      expect(
        AppAccessGuard.homePathForRole(UserRole.kurye),
        '/kurye/ana',
      );
    });

    test('null role maps to /role-selection', () {
      expect(
        AppAccessGuard.homePathForRole(null),
        '/role-selection',
      );
    });
  });

  group('AppAccessGuard.landingPathForUserState', () {
    test('pending request without profile maps to /home', () {
      expect(
        AppAccessGuard.landingPathForUserState(
          profile: null,
          hasPendingRoleRequest: true,
        ),
        '/home',
      );
    });

    test('no profile and no pending request maps to /role-selection', () {
      expect(
        AppAccessGuard.landingPathForUserState(
          profile: null,
          hasPendingRoleRequest: false,
        ),
        '/role-selection',
      );
    });

    test('musteri profile without musteri mapping stays on /home', () {
      expect(
        AppAccessGuard.landingPathForUserState(
          profile: const AppUserProfile(
            id: 'user-1',
            role: UserRole.musteriPersonel,
            displayName: 'Pending User',
          ),
          hasPendingRoleRequest: false,
        ),
        '/home',
      );
    });

    test('inactive musteri profile lands on /home first', () {
      expect(
        AppAccessGuard.landingPathForUserState(
          profile: const AppUserProfile(
            id: 'user-2',
            role: UserRole.musteriPersonel,
            displayName: 'Yeni Musteri',
            musteriId: 'musteri-1',
            isActive: false,
          ),
          hasPendingRoleRequest: false,
        ),
        '/home',
      );
    });
  });
}
