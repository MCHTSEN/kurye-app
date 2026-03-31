import 'package:backend_core/backend_core.dart';
import 'package:backend_mock/backend_mock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kuryem/app/app.dart';
import 'package:kuryem/core/environment/app_environment.dart';
import 'package:kuryem/core/environment/backend_provider.dart';
import 'package:kuryem/core/environment/credit_access_provider.dart';
import 'package:kuryem/product/auth/auth_providers.dart';
import 'package:kuryem/product/environment/environment_provider.dart';
import 'package:kuryem/product/onboarding/onboarding_providers.dart';
import 'package:kuryem/product/runtime/runtime_providers.dart';
import 'package:kuryem/product/user_profile/user_profile_providers.dart';

import '../test/helpers/fakes/fake_connectivity_service.dart';
import '../test/helpers/fakes/fake_crash_reporting_service.dart';
import '../test/helpers/fakes/fake_onboarding_repository.dart';
import '../test/helpers/fakes/fake_secure_storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('operasyon user reaches mobile bottom navigation flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            const AppEnvironment(
              flavor: AppFlavor.dev,
              backendProvider: BackendProvider.mock,
              creditAccessProvider: CreditAccessProvider.navigationSignal,
              customApiBaseUrl: 'https://api.example.com',
              supabaseUrl: '',
              supabaseAnonKey: '',
              mixpanelToken: '',
              analyticsEnabled: false,
              sentryDsn: '',
              operasyonReportsPassword: '',
            ),
          ),
          backendModuleProvider.overrideWithValue(MockBackendModule()),
          authRepositoryProvider.overrideWithValue(
            _SignedInOperasyonAuthRepo(),
          ),
          userProfileRepositoryProvider.overrideWithValue(
            const _OperasyonUserProfileRepository(),
          ),
          secureStorageServiceProvider.overrideWithValue(
            FakeSecureStorageService(),
          ),
          connectivityServiceProvider.overrideWithValue(
            FakeConnectivityService(),
          ),
          crashReportingServiceProvider.overrideWithValue(
            FakeCrashReportingService(),
          ),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(),
          ),
        ],
        child: const KuryemApp(),
      ),
    );

    await _pumpUntilFound(tester, find.text('Operasyon'));
    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Sipariş Oluşturma Paneli'), findsOneWidget);

    await tester.tap(find.text('Ayarlar'));
    await _pumpUntilFound(tester, find.text('Kurye Yönetimi'));
    expect(find.text('Kurye Yönetimi'), findsWidgets);

    await tester.tap(find.text('Raporlar'));
    await _pumpUntilFound(tester, find.text('Ciro Analizi'));
    expect(find.text('Ciro Analizi'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 100),
  int maxAttempts = 60,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure('Could not find widget: $finder');
}

class _SignedInOperasyonAuthRepo implements AuthRepository {
  final _session = AuthSession(
    user: const AuthUser(id: 'operasyon-user', email: 'operasyon@test.com'),
    authenticatedAt: DateTime(2026, 3, 16),
  );

  @override
  Stream<AuthSession?> authStateChanges() async* {
    yield _session;
  }

  @override
  Future<AuthSession?> currentSession() async => _session;

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
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async => _session;

  @override
  Set<SocialLoginMethod> get supportedSocialLogins => const {
    SocialLoginMethod.google,
  };

  @override
  Future<void> signOut() async {}
}

class _OperasyonUserProfileRepository implements UserProfileRepository {
  const _OperasyonUserProfileRepository();

  @override
  Future<AppUserProfile?> getProfile(String userId) async {
    if (userId != 'operasyon-user') {
      return null;
    }

    return const AppUserProfile(
      id: 'operasyon-user',
      role: UserRole.operasyon,
      displayName: 'Operasyon Test',
    );
  }

  @override
  Future<AppUserProfile> createProfile(AppUserProfile profile) async => profile;
}
