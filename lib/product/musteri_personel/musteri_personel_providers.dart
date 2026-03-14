import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'musteri_personel_providers.g.dart';

@Riverpod(keepAlive: true)
MusteriPersonelRepository musteriPersonelRepository(Ref ref) {
  final repo =
      ref.watch(backendModuleProvider).createMusteriPersonelRepository();
  if (repo == null) {
    throw StateError(
      'MusteriPersonelRepository is not available for the current backend.',
    );
  }
  return repo;
}

@riverpod
Future<List<MusteriPersonel>> musteriPersonelList(Ref ref) async {
  final repo = ref.watch(musteriPersonelRepositoryProvider);
  return repo.getAll();
}

@riverpod
Future<List<MusteriPersonel>> musteriPersonelListByMusteri(
  Ref ref,
  String musteriId,
) async {
  final repo = ref.watch(musteriPersonelRepositoryProvider);
  return repo.getByMusteriId(musteriId);
}
