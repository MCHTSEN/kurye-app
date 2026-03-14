import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.authenticatedAt,
  });

  final AuthUser user;
  final DateTime authenticatedAt;
}
