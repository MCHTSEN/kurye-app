import 'package:eipat/core/runtime/app_permission.dart';
import 'package:eipat/core/runtime/permission_service.dart';

class FakePermissionService implements PermissionService {
  FakePermissionService({
    this.status = PermissionStatusState.granted,
  });

  PermissionStatusState status;

  @override
  Future<PermissionStatusState> check(AppPermission permission) async => status;

  @override
  Future<PermissionStatusState> request(AppPermission permission) async =>
      status;
}
