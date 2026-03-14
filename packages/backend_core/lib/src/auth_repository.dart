import 'auth_gateway.dart';
import 'domain/auth_session.dart';

abstract class AuthRepository {
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

  Set<SocialLoginMethod> get supportedSocialLogins;
}
