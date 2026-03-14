import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'ugrama_providers.g.dart';

@Riverpod(keepAlive: true)
UgramaRepository ugramaRepository(Ref ref) {
  final repo = ref.watch(backendModuleProvider).createUgramaRepository();
  if (repo == null) {
    throw StateError(
      'UgramaRepository is not available for the current backend.',
    );
  }
  return repo;
}

@riverpod
Future<List<Ugrama>> ugramaList(Ref ref) async {
  final repo = ref.watch(ugramaRepositoryProvider);
  return repo.getAll();
}

@riverpod
Future<List<Ugrama>> ugramaListByMusteri(Ref ref, String musteriId) async {
  final repo = ref.watch(ugramaRepositoryProvider);
  return repo.getByMusteriId(musteriId);
}
