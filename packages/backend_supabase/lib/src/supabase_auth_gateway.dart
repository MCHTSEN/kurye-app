import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  static final _log = AppLogger('SupabaseAuthGateway', tag: LogTag.auth);

  @override
  Stream<AuthSession?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) {
      return _mapSession(event.session);
    });
  }

  @override
  Future<AuthSession?> currentSession() async {
    return _mapSession(_client.auth.currentSession);
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    _log.i('signInAnonymously called');
    final response = await _client.auth.signInAnonymously();
    final session = _mapSession(response.session);

    if (session == null) {
      throw StateError(
        'Supabase anonymous login did not return a user session.',
      );
    }

    _log.i('signInAnonymously success: ${session.user.id}');
    return session;
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _log.i('signInWithEmail called for $email');
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = _mapSession(response.session);

    if (session == null) {
      throw StateError(
        'Supabase email login did not return a user session.',
      );
    }

    _log.i('signInWithEmail success: ${session.user.id}');
    return session;
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    _log.i('signInWithGoogle called');
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    final session = _mapSession(response.session);

    if (session == null) {
      throw StateError(
        'Supabase Google login did not return a user session.',
      );
    }

    _log.i('signInWithGoogle success: ${session.user.id}');
    return session;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _log.i('register called for $email');
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final session = _mapSession(response.session);

    if (session == null) {
      // Email onayı açıksa Supabase session dönmez.
      throw EmailConfirmationRequiredException(email);
    }

    _log.i('register success: ${session.user.id}');
    return session;
  }

  @override
  Set<SocialLoginMethod> get supportedSocialLogins =>
      const {SocialLoginMethod.google};

  @override
  Future<void> signOut() async {
    _log.i('signOut called');
    await _client.auth.signOut();
  }

  AuthSession? _mapSession(Session? session) {
    if (session == null) {
      return null;
    }

    return AuthSession(
      user: AuthUser(
        id: session.user.id,
        email: session.user.email,
      ),
      authenticatedAt: DateTime.now(),
    );
  }
}
