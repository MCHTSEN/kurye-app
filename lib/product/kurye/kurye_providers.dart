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

/// Giriş yapan kullanıcının kurye kaydını auth UID ile çözer.
/// Null dönerse kullanıcı kuryeler tablosunda bulunamadı demektir.
@Riverpod(keepAlive: true)
Future<Kurye?> currentKurye(Ref ref) async {
  final session = await ref.watch(authStateProvider.future);
  if (session == null) return null;
  final repo = ref.watch(kuryeRepositoryProvider);
  return repo.getByUserId(session.user.id);
}
