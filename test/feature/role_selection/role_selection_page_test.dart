import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/feature/role_selection/presentation/role_selection_page.dart';
import 'package:kuryem/product/auth/auth_providers.dart';
import 'package:kuryem/product/musteri/musteri_providers.dart';
import 'package:kuryem/product/role_request/role_request_providers.dart';

import '../../helpers/builders/auth_session_builder.dart';
import '../../helpers/fakes/fake_musteri_repository.dart';
import '../../helpers/widgets/test_app.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._session);

  final AuthSession _session;

  @override
  Stream<AuthSession?> authStateChanges() => Stream.value(_session);

  @override
  Future<AuthSession?> currentSession() async => _session;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> updatePassword({required String newPassword}) async {}

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async => _session;

  @override
  Future<AuthSession> signInAnonymously() async => _session;

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async => _session;

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async =>
      _session;

  @override
  Future<void> signOut() async {}

  @override
  Set<SocialLoginMethod> get supportedSocialLogins => const {};
}

class _FakeRoleRequestRepository implements RoleRequestRepository {
  RoleRequest? latestRequest;
  RoleRequest? createdRequest;

  @override
  Future<void> approveRequest({
    required String requestId,
    required String reviewerId,
    String? musteriId,
  }) async {}

  @override
  Future<RoleRequest> createRequest(RoleRequest request) async {
    createdRequest = RoleRequest(
      id: 'created-1',
      userId: request.userId,
      requestedRole: request.requestedRole,
      status: request.status,
      displayName: request.displayName,
      accountType: request.accountType,
      companyName: request.companyName,
      musteriId: request.musteriId,
      phone: request.phone,
      note: request.note,
    );
    latestRequest = createdRequest;
    return createdRequest!;
  }

  @override
  Future<RoleRequest?> getMyLatestRequest(String userId) async => latestRequest;

  @override
  Future<RoleRequest?> getMyPendingRequest(String userId) async =>
      latestRequest?.status == RoleRequestStatus.beklemede
      ? latestRequest
      : null;

  @override
  Future<List<RoleRequest>> getPendingRequests() async =>
      latestRequest == null ? [] : [latestRequest!];

  @override
  Future<void> rejectRequest({
    required String requestId,
    required String reviewerId,
    String? reason,
  }) async {}

  @override
  Stream<List<RoleRequest>> watchPendingRequests() async* {
    yield latestRequest == null ? [] : [latestRequest!];
  }
}

void main() {
  group('RoleSelectionPage', () {
    final fakeMusteriRepo = FakeMusteriRepository(
      seed: const [
        Musteri(id: 'm-1', firmaKisaAd: 'Acme'),
        Musteri(id: 'm-2', firmaKisaAd: 'Beta Lojistik'),
      ],
    );

    testWidgets('shows only musteri personeli option for new requests', (
      tester,
    ) async {
      await tester.pumpApp(
        const RoleSelectionPage(),
        overrides: [
          myRoleRequestProvider.overrideWithBuild((ref, notifier) => null),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Yeni Müşteri Oluştur'), findsOneWidget);
      expect(find.text('Var Olan Müşteriye Katıl'), findsOneWidget);
      expect(find.text('Kurye'), findsNothing);
    });

    testWidgets('submits new customer request with company name', (
      tester,
    ) async {
      final fakeRepo = _FakeRoleRequestRepository();
      final fakeAuthRepository = _FakeAuthRepository(
        buildAuthSession(id: 'user-1', email: 'test@example.com'),
      );

      await tester.pumpApp(
        const RoleSelectionPage(),
        overrides: [
          myRoleRequestProvider.overrideWithBuild((ref, notifier) => null),
          roleRequestRepositoryProvider.overrideWithValue(fakeRepo),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          musteriRepositoryProvider.overrideWithValue(fakeMusteriRepo),
        ],
      );
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Talep Gönder'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(find.text('Talep Gönder'), findsOneWidget);

      await tester.tap(find.text('Yeni Müşteri Oluştur'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Test Kullanici');
      await tester.enterText(
        find.widgetWithText(TextField, 'Firma Adı *'),
        'Deneme Ticaret',
      );
      await tester.pump();
      await tester.dragUntilVisible(
        find.text('Talep Gönder'),
        find.byType(ListView),
        const Offset(0, -200),
      );

      await tester.tap(find.text('Talep Gönder'));
      await tester.pumpAndSettle();

      expect(fakeRepo.createdRequest, isNotNull);
      expect(fakeRepo.createdRequest?.displayName, 'Test Kullanici');
      expect(
        fakeRepo.createdRequest?.requestedRole,
        UserRole.musteriPersonel,
      );
      expect(
        fakeRepo.createdRequest?.accountType,
        RoleRequestAccountType.newCustomer,
      );
      expect(fakeRepo.createdRequest?.companyName, 'Deneme Ticaret');
    });

    testWidgets('submits existing customer employee request with musteri id', (
      tester,
    ) async {
      final fakeRepo = _FakeRoleRequestRepository();
      final fakeAuthRepository = _FakeAuthRepository(
        buildAuthSession(id: 'user-1', email: 'test@example.com'),
      );

      await tester.pumpApp(
        const RoleSelectionPage(),
        overrides: [
          myRoleRequestProvider.overrideWithBuild((ref, notifier) => null),
          roleRequestRepositoryProvider.overrideWithValue(fakeRepo),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          musteriRepositoryProvider.overrideWithValue(fakeMusteriRepo),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Var Olan Müşteriye Katıl'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Test Kullanici');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Firmanızı seçin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acme').last);
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Talep Gönder'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(find.text('Talep Gönder'));
      await tester.pumpAndSettle();

      expect(
        fakeRepo.createdRequest?.accountType,
        RoleRequestAccountType.existingCustomerEmployee,
      );
      expect(fakeRepo.createdRequest?.musteriId, 'm-1');
      expect(fakeRepo.createdRequest?.companyName, 'Acme');
    });
  });
}
