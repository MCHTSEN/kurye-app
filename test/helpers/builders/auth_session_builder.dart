import 'package:backend_core/backend_core.dart';

AuthSession buildAuthSession({
  String id = 'test-user',
  String? email,
  DateTime? authenticatedAt,
}) {
  return AuthSession(
    user: AuthUser(id: id, email: email),
    authenticatedAt: authenticatedAt ?? DateTime(2026),
  );
}
