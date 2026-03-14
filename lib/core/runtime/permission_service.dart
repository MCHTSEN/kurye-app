import 'app_permission.dart';

abstract class PermissionService {
  Future<PermissionStatusState> check(AppPermission permission);

  Future<PermissionStatusState> request(AppPermission permission);
}
