import 'package:backend_core/backend_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_auth_gateway.dart';
import 'firebase_claims_credit_access_service.dart';
import 'firebase_token_refresh_service.dart';

class FirebaseBackendModule extends BackendModule {
  static final _log = AppLogger('FirebaseBackendModule');

  @override
  Future<void> initialize() async {
    _log.i('Initializing Firebase...');
    await Firebase.initializeApp();
    _log.i('Firebase initialized successfully');
  }

  @override
  AuthGateway createAuthGateway() {
    return FirebaseAuthGateway(firebaseAuth: FirebaseAuth.instance);
  }

  @override
  TokenRefreshService createTokenRefreshService() {
    return FirebaseTokenRefreshService(firebaseAuth: FirebaseAuth.instance);
  }

  @override
  CreditAccessService? createCreditAccessService() {
    return FirebaseClaimsCreditAccessService(
      firebaseAuth: FirebaseAuth.instance,
    );
  }
}
