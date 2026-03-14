import 'dart:async';

import 'package:backend_core/backend_core.dart';

class MockAuthGateway implements AuthGateway {
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();

  AuthSession? _session;

  @override
  Stream<AuthSession?> authStateChanges() async* {
    yield _session;
    yield* _controller.stream;
  }

  @override
  Future<AuthSession?> currentSession() async => _session;

  @override
  Future<AuthSession> signInAnonymously() async {
    final session = AuthSession(
      user: const AuthUser(id: 'mock-anon-user'),
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
    final session = AuthSession(
      user: AuthUser(id: 'mock-email-user', email: email),
      authenticatedAt: DateTime.now(),
    );
    _session = session;
    _controller.add(session);
    return session;
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    final session = AuthSession(
      user: const AuthUser(id: 'mock-google-user', email: 'mock@google.com'),
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
      user: AuthUser(id: 'mock-reg-user', email: email),
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
    _session = null;
    _controller.add(null);
  }
}
