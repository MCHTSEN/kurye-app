import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'siparis_log_providers.g.dart';

@Riverpod(keepAlive: true)
SiparisLogRepository siparisLogRepository(Ref ref) {
  final repo = ref.watch(backendModuleProvider).createSiparisLogRepository();
  if (repo == null) {
    throw StateError(
      'SiparisLogRepository is not available for the current backend.',
    );
  }
  return repo;
}
