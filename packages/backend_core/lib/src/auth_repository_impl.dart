import 'analytics_service.dart';
import 'auth_gateway.dart';
import 'auth_repository.dart';
import 'domain/app_events.dart';
import 'domain/auth_session.dart';
import 'logging/app_log_config.dart';
import 'logging/app_logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthGateway gateway,
    required AnalyticsService analytics,
  }) : _gateway = gateway,
       _analytics = analytics;

  final AuthGateway _gateway;
  final AnalyticsService _analytics;

  static final _log = AppLogger('AuthRepository', tag: LogTag.auth);

  @override
  Stream<AuthSession?> authStateChanges() {
    return _gateway.authStateChanges();
  }

  @override
  Future<AuthSession?> currentSession() {
    return _gateway.currentSession();
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    _log.i('signInAnonymously called');
    try {
      final session = await _gateway.signInAnonymously();

      await _analytics.identify(
        userId: session.user.id,
        traits: <String, Object?>{'auth_type': 'anonymous'},
      );

      await _analytics.track(AppEvents.authSignInSuccess('anonymous'));

      _log.i('signInAnonymously success: ${session.user.id}');
      return session;
    } catch (e, st) {
      _log.e('signInAnonymously failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _log.i('signInWithEmail called for $email');
    try {
      final session = await _gateway.signInWithEmail(
        email: email,
        password: password,
      );

      await _analytics.identify(
        userId: session.user.id,
        traits: <String, Object?>{'auth_type': 'email', 'email': email},
      );

      await _analytics.track(AppEvents.authSignInSuccess('email'));

      _log.i('signInWithEmail success: ${session.user.id}');
      return session;
    } catch (e, st) {
      _log.e('signInWithEmail failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Set<SocialLoginMethod> get supportedSocialLogins =>
      _gateway.supportedSocialLogins;

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    _log.i('signInWithGoogle called');
    try {
      final session = await _gateway.signInWithGoogle(idToken: idToken);

      await _analytics.identify(
        userId: session.user.id,
        traits: <String, Object?>{
          'auth_type': 'google',
          'email': session.user.email,
        },
      );

      await _analytics.track(AppEvents.authSignInSuccess('google'));

      _log.i('signInWithGoogle success: ${session.user.id}');
      return session;
    } catch (e, st) {
      _log.e('signInWithGoogle failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _log.i('register called for $email');
    try {
      final session = await _gateway.register(
        email: email,
        password: password,
        name: name,
      );

      await _analytics.identify(
        userId: session.user.id,
        traits: <String, Object?>{
          'auth_type': 'email',
          'email': email,
          'name': name,
        },
      );

      await _analytics.track(AppEvents.authSignInSuccess('register'));

      _log.i('register success: ${session.user.id}');
      return session;
    } catch (e, st) {
      _log.e('register failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    _log.i('signOut called');
    try {
      await _gateway.signOut();
      await _analytics.track(AppEvents.authSignOut);
      _log.i('signOut success');
    } catch (e, st) {
      _log.e('signOut failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}
