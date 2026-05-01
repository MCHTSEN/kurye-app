import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/feature/home/presentation/home_page.dart';
import 'package:kuryem/product/musteri/musteri_providers.dart';
import 'package:kuryem/product/role_request/role_request_providers.dart';
import 'package:kuryem/product/user_profile/user_profile_providers.dart';

import '../../helpers/fakes/fake_musteri_repository.dart';
import '../../helpers/widgets/test_app.dart';

const _pendingRequest = RoleRequest(
  id: 'req-1',
  userId: 'user-1',
  requestedRole: UserRole.musteriPersonel,
  status: RoleRequestStatus.beklemede,
  displayName: 'Test Personel',
);

const _newCustomerRequest = RoleRequest(
  id: 'req-2',
  userId: 'user-2',
  requestedRole: UserRole.musteriPersonel,
  status: RoleRequestStatus.beklemede,
  displayName: 'Yeni Musteri Kullanici',
  accountType: RoleRequestAccountType.newCustomer,
  companyName: 'Deneme Ticaret',
  musteriId: 'm-1',
);

void main() {
  group('HomePage', () {
    testWidgets('shows in-app pending account state', (tester) async {
      await tester.pumpApp(
        const HomePage(),
        overrides: [
          currentUserProfileProvider.overrideWithBuild(
            (ref, notifier) => null,
          ),
          myRoleRequestProvider.overrideWithBuild(
            (ref, notifier) => _pendingRequest,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Hesap İnceleniyor'), findsOneWidget);
      expect(find.textContaining('Rol talebiniz alındı'), findsOneWidget);
      expect(find.text('Ad: Test Personel'), findsOneWidget);
      expect(find.text('Talep edilen rol: Müşteri Personeli'), findsOneWidget);
      expect(find.text('Durumu Yenile'), findsOneWidget);
      expect(find.text('Hesabı Sil'), findsOneWidget);
    });

    testWidgets('shows provisional new customer setup state', (tester) async {
      final fakeMusteriRepo = FakeMusteriRepository(
        seed: const [
          Musteri(
            id: 'm-1',
            firmaKisaAd: 'Deneme Ticaret',
            isActive: false,
          ),
        ],
      );

      await tester.pumpApp(
        const HomePage(),
        overrides: [
          currentUserProfileProvider.overrideWithBuild(
            (ref, notifier) => const AppUserProfile(
              id: 'user-2',
              role: UserRole.musteriPersonel,
              displayName: 'Yeni Musteri Kullanici',
              musteriId: 'm-1',
              isActive: false,
            ),
          ),
          myRoleRequestProvider.overrideWithBuild(
            (ref, notifier) => _newCustomerRequest,
          ),
          musteriRepositoryProvider.overrideWithValue(fakeMusteriRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Hesabınız Kullanıma Açıldı'), findsOneWidget);
      expect(find.text('Firma Bilgilerini Tamamla'), findsOneWidget);
      expect(find.text('Müşteri Panelini Aç'), findsOneWidget);
      expect(find.text('Firma Kısa Adı *'), findsOneWidget);
    });

    testWidgets('opens delete-account confirmation dialog', (tester) async {
      await tester.pumpApp(
        const HomePage(),
        overrides: [
          currentUserProfileProvider.overrideWithBuild(
            (ref, notifier) => null,
          ),
          myRoleRequestProvider.overrideWithBuild(
            (ref, notifier) => _pendingRequest,
          ),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('home_delete_account_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Hesabı Sil'), findsWidgets);
      expect(find.textContaining('Bu işlem geri alınamaz'), findsOneWidget);
    });
  });
}
