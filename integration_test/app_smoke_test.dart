import 'package:backend_core/backend_core.dart';
import 'package:backend_mock/backend_mock.dart';
import 'package:bursamotokurye/app/app.dart';
import 'package:bursamotokurye/core/environment/app_environment.dart';
import 'package:bursamotokurye/core/environment/backend_provider.dart';
import 'package:bursamotokurye/core/environment/credit_access_provider.dart';
import 'package:bursamotokurye/product/auth/auth_providers.dart';
import 'package:bursamotokurye/product/environment/environment_provider.dart';
import 'package:bursamotokurye/product/onboarding/onboarding_providers.dart';
import 'package:bursamotokurye/product/runtime/runtime_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/fakes/fake_connectivity_service.dart';
import '../test/helpers/fakes/fake_crash_reporting_service.dart';
import '../test/helpers/fakes/fake_onboarding_repository.dart';
import '../test/helpers/fakes/fake_secure_storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mock backend smoke flow reaches example feed', (tester) async {
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
          authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
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
        child: const BursamotoKuryeApp(),
      ),
    );

    await _pumpUntilFound(tester, find.text('Open Example Feed'));

    expect(find.text('Open Example Feed'), findsOneWidget);

    await tester.tap(find.text('Open Example Feed'));
    await _pumpUntilFound(tester, find.text('Mock onboarding checklist'));

    expect(find.text('Mock onboarding checklist'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 100),
  int maxAttempts = 30,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure('Could not find widget: $finder');
}

class _SignedInAuthRepository implements AuthRepository {
  final _session = AuthSession(
    user: const AuthUser(id: 'integration-user'),
    authenticatedAt: DateTime(2026, 3, 8),
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
