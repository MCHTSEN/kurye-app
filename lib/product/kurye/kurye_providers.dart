import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'kurye_providers.g.dart';

@Riverpod(keepAlive: true)
KuryeRepository kuryeRepository(Ref ref) {
  final repo = ref.watch(backendModuleProvider).createKuryeRepository();
  if (repo == null) {
    throw StateError(
      'KuryeRepository is not available for the current backend.',
    );
  }
  return repo;
}

@riverpod
Future<List<Kurye>> kuryeList(Ref ref) async {
  final repo = ref.watch(kuryeRepositoryProvider);
  return repo.getAll();
}
