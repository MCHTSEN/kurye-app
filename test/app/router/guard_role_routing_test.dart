import 'package:backend_core/backend_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/app/router/guards/app_access_guard.dart';
import 'package:kuryem/product/auth/auth_providers.dart';
import 'package:kuryem/product/navigation/app_access_snapshot.dart';
import 'package:kuryem/product/onboarding/onboarding_providers.dart';
import 'package:kuryem/product/onboarding/onboarding_repository.dart';
import 'package:kuryem/product/role_request/role_request_providers.dart';
import 'package:kuryem/product/user_profile/user_profile_providers.dart';

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

  group('appAccessSnapshotProvider', () {
    test('caches profile lookup across repeated guard reads', () async {
      final profileRepo = _CountingUserProfileRepository(
        profile: const AppUserProfile(
          id: 'user-1',
          role: UserRole.operasyon,
          displayName: 'Operasyon',
        ),
      );
      final roleRequestRepo = _CountingRoleRequestRepository();
      final container = _createContainer(
        profileRepository: profileRepo,
        roleRequestRepository: roleRequestRepo,
      );
      addTearDown(container.dispose);

      final first = await container.read(appAccessSnapshotProvider.future);
      final second = await container.read(appAccessSnapshotProvider.future);

      expect(first.profile?.role, UserRole.operasyon);
      expect(second.profile?.role, UserRole.operasyon);
      expect(profileRepo.getProfileCalls, 1);
      expect(roleRequestRepo.getMyPendingRequestCalls, 0);
    });

    test('refreshes profile lookup after snapshot invalidation', () async {
      final profileRepo = _CountingUserProfileRepository(
        profile: const AppUserProfile(
          id: 'user-1',
          role: UserRole.operasyon,
          displayName: 'Operasyon',
        ),
      );
      final container = _createContainer(profileRepository: profileRepo);
      addTearDown(container.dispose);

      final first = await container.read(appAccessSnapshotProvider.future);
      expect(
        AppAccessGuard.landingPathForUserState(
          profile: first.profile,
          hasPendingRoleRequest: first.hasPendingRoleRequest,
        ),
        '/operasyon',
      );

      profileRepo.profile = const AppUserProfile(
        id: 'user-1',
        role: UserRole.kurye,
        displayName: 'Kurye',
      );
      container.invalidate(appAccessSnapshotProvider);

      final refreshed = await container.read(appAccessSnapshotProvider.future);
      expect(
        AppAccessGuard.landingPathForUserState(
          profile: refreshed.profile,
          hasPendingRoleRequest: refreshed.hasPendingRoleRequest,
        ),
        '/kurye/ana',
      );
      expect(profileRepo.getProfileCalls, 2);
    });
  });
}

ProviderContainer _createContainer({
  UserProfileRepository? profileRepository,
  RoleRequestRepository? roleRequestRepository,
}) {
  return ProviderContainer(
    overrides: [
      onboardingRepositoryProvider.overrideWithValue(
        _FakeOnboardingRepository(completed: true),
      ),
      authRepositoryProvider.overrideWithValue(
        _FakeAuthRepository(
          session: AuthSession(
            user: const AuthUser(id: 'user-1', email: 'user@example.com'),
            authenticatedAt: DateTime(2026),
          ),
        ),
      ),
      userProfileRepositoryProvider.overrideWithValue(
        profileRepository ??
            _CountingUserProfileRepository(
              profile: const AppUserProfile(
                id: 'user-1',
                role: UserRole.operasyon,
                displayName: 'Operasyon',
              ),
            ),
      ),
      roleRequestRepositoryProvider.overrideWithValue(
        roleRequestRepository ?? _CountingRoleRequestRepository(),
      ),
    ],
  );
}

final class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({required this.completed});

  bool completed;

  @override
  Future<void> complete() async {
    completed = true;
  }

  @override
  Future<bool> isCompleted() async => completed;
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.session});

  AuthSession? session;

  @override
  Stream<AuthSession?> authStateChanges() => Stream.value(session);

  @override
  Future<AuthSession?> currentSession() async => session;

  @override
  Future<void> deleteAccount() async {
    session = null;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    session = null;
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    throw UnimplementedError();
  }

  @override
  Set<SocialLoginMethod> get supportedSocialLogins => const {};

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}

final class _CountingUserProfileRepository implements UserProfileRepository {
  _CountingUserProfileRepository({required this.profile});

  AppUserProfile? profile;
  int getProfileCalls = 0;

  @override
  Future<AppUserProfile> createProfile(AppUserProfile profile) async {
    this.profile = profile;
    return profile;
  }

  @override
  Future<AppUserProfile?> getProfile(String userId) async {
    getProfileCalls++;
    return profile;
  }
}

final class _CountingRoleRequestRepository implements RoleRequestRepository {
  int getMyPendingRequestCalls = 0;

  @override
  Future<void> approveRequest({
    required String requestId,
    required String reviewerId,
    String? musteriId,
  }) async {}

  @override
  Future<RoleRequest> createRequest(RoleRequest request) async => request;

  @override
  Future<List<RoleRequest>> getPendingRequests() async => const [];

  @override
  Future<RoleRequest?> getMyLatestRequest(String userId) async => null;

  @override
  Future<RoleRequest?> getMyPendingRequest(String userId) async {
    getMyPendingRequestCalls++;
    return null;
  }

  @override
  Future<void> rejectRequest({
    required String requestId,
    required String reviewerId,
    String? reason,
  }) async {}

  @override
  Stream<List<RoleRequest>> watchPendingRequests() => const Stream.empty();
}
