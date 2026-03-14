import 'domain/auth_session.dart';

abstract class AuthGateway {
  Stream<AuthSession?> authStateChanges();

  Future<AuthSession?> currentSession();

  Future<AuthSession> signInAnonymously();

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthSession> signInWithGoogle({required String idToken});

  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();

  /// Which social login methods this gateway supports.
  Set<SocialLoginMethod> get supportedSocialLogins;
}

enum SocialLoginMethod { google, apple }
