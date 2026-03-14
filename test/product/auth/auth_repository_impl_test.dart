import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGateway implements AuthGateway {
  final _controller = StreamController<AuthSession?>.broadcast();
  AuthSession? _session;
  bool signInAnonymousCalled = false;
  bool signInWithEmailCalled = false;
  bool signOutCalled = false;

  @override
  Stream<AuthSession?> authStateChanges() => _controller.stream;

  @override
  Future<AuthSession?> currentSession() async => _session;

  @override
  Future<AuthSession> signInAnonymously() async {
    signInAnonymousCalled = true;
    final session = AuthSession(
      user: const AuthUser(id: 'anon-1'),
      authenticatedAt: DateTime.now(),
    );
    _session = session;
    _controller.add(session);
    return session;
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInWithEmailCalled = true;
    final session = AuthSession(
      user: AuthUser(id: 'email-1', email: email),
      authenticatedAt: DateTime.now(),
    );
    _session = session;
    _controller.add(session);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final session = AuthSession(
      user: AuthUser(id: 'reg-1', email: email),
      authenticatedAt: DateTime.now(),
    );
    _session = session;
    _controller.add(session);
    return session;
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    final session = AuthSession(
      user: const AuthUser(id: 'google-1', email: 'google@test.com'),
      authenticatedAt: DateTime.now(),
    );
    _session = session;
    _controller.add(session);
    return session;
  }

  @override
  Set<SocialLoginMethod> get supportedSocialLogins =>
      const {SocialLoginMethod.google};

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _session = null;
    _controller.add(null);
  }
}

class _FakeAnalytics implements AnalyticsService {
  final List<String> trackedEvents = [];
  String? identifiedUserId;

  @override
  Future<void> track(AnalyticsEvent event) async {
    trackedEvents.add(event.name);
  }

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object?> traits = const {},
  }) async {
    identifiedUserId = userId;
  }

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {}
}

void main() {
  late _FakeGateway gateway;
  late _FakeAnalytics analytics;
  late AuthRepositoryImpl repository;

  setUp(() {
    gateway = _FakeGateway();
    analytics = _FakeAnalytics();
    repository = AuthRepositoryImpl(
      gateway: gateway,
      analytics: analytics,
    );
  });

  group('AuthRepositoryImpl', () {
    test(
      'signInAnonymously delegates to gateway and tracks analytics',
      () async {
        final session = await repository.signInAnonymously();

        expect(session.user.id, 'anon-1');
        expect(gateway.signInAnonymousCalled, isTrue);
        expect(analytics.identifiedUserId, 'anon-1');
        expect(analytics.trackedEvents, contains('auth_sign_in_success'));
      },
    );

    test('signInWithEmail delegates to gateway and tracks analytics', () async {
      final session = await repository.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(session.user.id, 'email-1');
      expect(session.user.email, 'test@example.com');
      expect(gateway.signInWithEmailCalled, isTrue);
      expect(analytics.identifiedUserId, 'email-1');
      expect(analytics.trackedEvents, contains('auth_sign_in_success'));
    });

    test('signOut delegates to gateway and tracks analytics', () async {
      await repository.signOut();

      expect(gateway.signOutCalled, isTrue);
      expect(analytics.trackedEvents, contains('auth_sign_out'));
    });

    test('currentSession delegates to gateway', () async {
      expect(await repository.currentSession(), isNull);

      await repository.signInAnonymously();

      final session = await repository.currentSession();
      expect(session?.user.id, 'anon-1');
    });
  });
}
