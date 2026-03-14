import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'musteri_providers.g.dart';

@Riverpod(keepAlive: true)
MusteriRepository musteriRepository(Ref ref) {
  final repo = ref.watch(backendModuleProvider).createMusteriRepository();
  if (repo == null) {
    throw StateError(
      'MusteriRepository is not available for the current backend.',
    );
  }
  return repo;
}

@riverpod
Future<List<Musteri>> musteriList(Ref ref) async {
  final repo = ref.watch(musteriRepositoryProvider);
  return repo.getAll();
}
