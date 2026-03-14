import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'siparis_providers.g.dart';

@Riverpod(keepAlive: true)
SiparisRepository siparisRepository(Ref ref) {
  final repo = ref.watch(backendModuleProvider).createSiparisRepository();
  if (repo == null) {
    throw StateError(
      'SiparisRepository is not available for the current backend.',
    );
  }
  return repo;
}

@riverpod
Stream<List<Siparis>> siparisStreamByMusteri(Ref ref, String musteriId) {
  final repo = ref.watch(siparisRepositoryProvider);
  return repo.streamByMusteriId(musteriId);
}

@riverpod
Stream<List<Siparis>> siparisStreamActive(Ref ref) {
  final repo = ref.watch(siparisRepositoryProvider);
  return repo.streamActive();
}

@riverpod
Future<List<Siparis>> siparisListByMusteri(Ref ref, String musteriId) async {
  final repo = ref.watch(siparisRepositoryProvider);
  return repo.getByMusteriId(musteriId);
}
