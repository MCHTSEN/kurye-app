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
Stream<List<Siparis>> siparisStreamByKurye(Ref ref, String kuryeId) {
  final repo = ref.watch(siparisRepositoryProvider);
  return repo.streamByKuryeId(kuryeId);
}

@riverpod
Future<List<Siparis>> siparisListByMusteri(Ref ref, String musteriId) async {
  final repo = ref.watch(siparisRepositoryProvider);
  return repo.getByMusteriId(musteriId);
}

@riverpod
Future<List<Siparis>> siparisHistory(
  Ref ref, {
  DateTime? startDate,
  DateTime? endDate,
  String? musteriId,
  String? kuryeId,
  String? cikisId,
  String? ugramaId,
}) async {
  final repo = ref.watch(siparisRepositoryProvider);
  return repo.getHistory(
    startDate: startDate,
    endDate: endDate,
    musteriId: musteriId,
    kuryeId: kuryeId,
    cikisId: cikisId,
    ugramaId: ugramaId,
  );
}
