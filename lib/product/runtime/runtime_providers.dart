import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/runtime/runtime.dart';
import 'services/connectivity_plus_service.dart';
import 'services/flutter_secure_storage_service.dart';
import 'services/in_memory_feature_flag_service.dart';
import 'services/noop_crash_reporting_service.dart';
import 'services/permission_handler_service.dart';

part 'runtime_providers.g.dart';

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) {
  return FlutterSecureStorageService();
}

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityPlusService();
}

@Riverpod(keepAlive: true)
FeatureFlagService featureFlagService(Ref ref) {
  return InMemoryFeatureFlagService(
    flags: const <String, bool>{
      'example_feed_enabled': true,
    },
  );
}

@Riverpod(keepAlive: true)
CrashReportingService crashReportingService(Ref ref) {
  return const NoopCrashReportingService();
}

@Riverpod(keepAlive: true)
PermissionService permissionService(Ref ref) {
  return PermissionHandlerService();
}

@Riverpod(keepAlive: true)
CachePolicy defaultCachePolicy(Ref ref) {
  return const CachePolicy.standard();
}

@Riverpod(keepAlive: true)
RetryPolicy defaultRetryPolicy(Ref ref) {
  return const RetryPolicy.networkDefault();
}
