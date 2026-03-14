import 'package:backend_core/backend_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTokenRefreshService implements TokenRefreshService {
  FirebaseTokenRefreshService({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  static final _log = AppLogger('FirebaseTokenRefresh', tag: LogTag.auth);

  @override
  Future<bool> tryRefreshToken() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      _log.w('tryRefreshToken: no current user');
      return false;
    }

    try {
      await user.getIdToken(true);
      _log.i('tryRefreshToken success');
      return true;
    } on Object catch (e) {
      _log.e('tryRefreshToken failed', error: e);
      return false;
    }
  }
}
