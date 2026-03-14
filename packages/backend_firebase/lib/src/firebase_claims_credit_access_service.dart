import 'package:backend_core/backend_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseClaimsCreditAccessService implements CreditAccessService {
  FirebaseClaimsCreditAccessService({
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  static final _log = AppLogger('FirebaseCreditAccess', tag: LogTag.credit);

  @override
  Future<bool> hasSufficientCredit() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        _log.w('hasSufficientCredit: no current user');
        return false;
      }

      final tokenResult = await user.getIdTokenResult(true);
      final claims = tokenResult.claims ?? <String, Object?>{};

      final hasCreditFlag = claims['has_credit'];
      if (hasCreditFlag is bool) {
        _log.i('hasSufficientCredit: has_credit=$hasCreditFlag');
        return hasCreditFlag;
      }

      final credits = claims['credits'];
      if (credits is num) {
        final result = credits > 0;
        _log.i('hasSufficientCredit: credits=$credits, result=$result');
        return result;
      }

      _log.i('hasSufficientCredit: no credit claims, defaulting to true');
      return true;
    } on Object catch (e) {
      _log.e('hasSufficientCredit failed, defaulting to true', error: e);
      return true;
    }
  }
}
