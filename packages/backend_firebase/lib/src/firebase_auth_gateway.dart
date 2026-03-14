import 'package:backend_core/backend_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  static final _log = AppLogger('FirebaseAuthGateway', tag: LogTag.auth);

  @override
  Stream<AuthSession?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapUserToSession);
  }

  @override
  Future<AuthSession?> currentSession() async {
    return _mapUserToSession(_firebaseAuth.currentUser);
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    _log.i('signInAnonymously called');
    final result = await _firebaseAuth.signInAnonymously();
    final session = _mapUserToSession(result.user);

    if (session == null) {
      throw StateError(
        'Firebase anonymous login did not return a user session.',
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
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final session = _mapUserToSession(result.user);

    if (session == null) {
      throw StateError(
        'Firebase email login did not return a user session.',
      );
    }

    _log.i('signInWithEmail success: ${session.user.id}');
    return session;
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    _log.i('signInWithGoogle called');
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _firebaseAuth.signInWithCredential(credential);
    final session = _mapUserToSession(result.user);

    if (session == null) {
      throw StateError(
        'Firebase Google login did not return a user session.',
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
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user?.updateDisplayName(name);
    final session = _mapUserToSession(result.user);

    if (session == null) {
      throw StateError('Firebase register did not return a user session.');
    }

    _log.i('register success: ${session.user.id}');
    return session;
  }

  @override
  Set<SocialLoginMethod> get supportedSocialLogins =>
      const {SocialLoginMethod.google};

  @override
  Future<void> signOut() {
    _log.i('signOut called');
    return _firebaseAuth.signOut();
  }

  AuthSession? _mapUserToSession(User? user) {
    if (user == null) {
      return null;
    }

    return AuthSession(
      user: AuthUser(id: user.uid, email: user.email),
      authenticatedAt: DateTime.now(),
    );
  }
}
