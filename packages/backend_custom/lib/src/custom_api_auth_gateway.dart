import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:dio/dio.dart';

class CustomApiAuthGateway implements AuthGateway {
  CustomApiAuthGateway({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

  final Dio _dio;
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();

  AuthSession? _session;

  static final _log = AppLogger('CustomApiAuthGateway', tag: LogTag.auth);

  @override
  Stream<AuthSession?> authStateChanges() async* {
    yield _session;
    yield* _controller.stream;
  }

  @override
  Future<AuthSession?> currentSession() async {
    return _session;
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    _log.i('signInAnonymously called');
    var userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final response = await _dio.post<Map<String, dynamic>>('/auth/anonymous');
      final remoteUserId = response.data?['userId'] as String?;
      if (remoteUserId != null && remoteUserId.isNotEmpty) {
        userId = remoteUserId;
      }
    } on Object {
      _log.w('signInAnonymously: API call failed, using fallback guest id');
    }

    final session = AuthSession(
      user: AuthUser(id: userId),
      authenticatedAt: DateTime.now(),
    );

    _session = session;
    _controller.add(session);

    _log.i('signInAnonymously success: $userId');
    return session;
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _log.i('signInWithEmail called for $email');
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    final userId = response.data?['userId'] as String? ?? '';
    if (userId.isEmpty) {
      throw StateError('Custom API login did not return a userId.');
    }

    final session = AuthSession(
      user: AuthUser(id: userId, email: email),
      authenticatedAt: DateTime.now(),
    );

    _session = session;
    _controller.add(session);

    _log.i('signInWithEmail success: $userId');
    return session;
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    _log.i('signInWithGoogle called');
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/google/token',
      data: <String, dynamic>{'credential': idToken},
    );

    final userId = response.data?['userId'] as String? ?? '';
    final email = response.data?['email'] as String?;
    if (userId.isEmpty) {
      throw StateError('Custom API Google login did not return a userId.');
    }

    final session = AuthSession(
      user: AuthUser(id: userId, email: email),
      authenticatedAt: DateTime.now(),
    );

    _session = session;
    _controller.add(session);

    _log.i('signInWithGoogle success: $userId');
    return session;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _log.i('register called for $email');
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, dynamic>{
        'email': email,
        'password': password,
        'name': name,
      },
    );

    final userId = response.data?['userId'] as String? ?? '';
    if (userId.isEmpty) {
      throw StateError('Custom API register did not return a userId.');
    }

    final session = AuthSession(
      user: AuthUser(id: userId, email: email),
      authenticatedAt: DateTime.now(),
    );

    _session = session;
    _controller.add(session);

    _log.i('register success: $userId');
    return session;
  }

  @override
  Set<SocialLoginMethod> get supportedSocialLogins =>
      const {SocialLoginMethod.google};

  @override
  Future<void> signOut() async {
    _log.i('signOut called');
    _session = null;
    _controller.add(null);
  }
}
