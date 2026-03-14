import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import '../../../core/runtime/app_permission.dart';
import '../../../core/runtime/permission_service.dart';

class PermissionHandlerService implements PermissionService {
  @override
  Future<PermissionStatusState> check(AppPermission permission) async {
    final status = await _mapPermission(permission).status;
    return _mapStatus(status);
  }

  @override
  Future<PermissionStatusState> request(AppPermission permission) async {
    final status = await _mapPermission(permission).request();
    return _mapStatus(status);
  }

  permission_handler.Permission _mapPermission(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return permission_handler.Permission.camera;
      case AppPermission.photos:
        return permission_handler.Permission.photos;
      case AppPermission.notifications:
        return permission_handler.Permission.notification;
    }
  }

  PermissionStatusState _mapStatus(permission_handler.PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return PermissionStatusState.granted;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      return PermissionStatusState.permanentlyDenied;
    }

    return PermissionStatusState.denied;
  }
}
