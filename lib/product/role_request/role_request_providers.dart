import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'role_request_providers.g.dart';

@Riverpod(keepAlive: true)
RoleRequestRepository roleRequestRepository(Ref ref) {
  final repo = ref.watch(backendModuleProvider).createRoleRequestRepository();
  if (repo == null) {
    throw StateError(
      'RoleRequestRepository is not available for the current backend.',
    );
  }
  return repo;
}

/// Kullanıcının en son rol talebini dinler.
@Riverpod(keepAlive: true)
class MyRoleRequest extends _$MyRoleRequest {
  @override
  Future<RoleRequest?> build() async {
    final authSession = await ref.watch(authStateProvider.future);
    if (authSession == null) return null;

    final repo = ref.read(roleRequestRepositoryProvider);
    return repo.getMyLatestRequest(authSession.user.id);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Beklemedeki tüm talepler (operasyon ekranı için).
/// Uses one-shot fetch instead of realtime stream because Supabase Realtime
/// streams evaluate RLS with limited auth context, causing empty results
/// for custom `get_my_role()` policies.
@riverpod
Future<List<RoleRequest>> pendingRoleRequests(Ref ref) {
  final repo = ref.watch(roleRequestRepositoryProvider);
  return repo.getPendingRequests();
}
