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

@Riverpod(keepAlive: true)
MusteriUgramaRepository musteriUgramaRepository(Ref ref) {
  final repo =
      ref.watch(backendModuleProvider).createMusteriUgramaRepository();
  if (repo == null) {
    throw StateError(
      'MusteriUgramaRepository is not available for the current backend.',
    );
  }
  return repo;
}

@Riverpod(keepAlive: true)
UgramaTalebiRepository ugramaTalebiRepository(Ref ref) {
  final repo =
      ref.watch(backendModuleProvider).createUgramaTalebiRepository();
  if (repo == null) {
    throw StateError(
      'UgramaTalebiRepository is not available for the current backend.',
    );
  }
  return repo;
}

@riverpod
Future<List<Ugrama>> ugramaList(Ref ref) async {
  final repo = ref.watch(ugramaRepositoryProvider);
  return repo.getAll();
}

/// Müşteriye atanmış uğramaları köprü tablosu üzerinden getirir.
@riverpod
Future<List<Ugrama>> ugramaListByMusteri(Ref ref, String musteriId) async {
  final repo = ref.watch(musteriUgramaRepositoryProvider);
  return repo.getUgramaByMusteriId(musteriId);
}

/// Bir uğramaya atanmış müşteri ID'lerini getirir.
@riverpod
Future<List<String>> musteriIdsByUgrama(Ref ref, String ugramaId) async {
  final repo = ref.watch(musteriUgramaRepositoryProvider);
  return repo.getMusteriIdsByUgramaId(ugramaId);
}

/// Bekleyen uğrama taleplerini getirir (operasyon).
@riverpod
Future<List<UgramaTalebi>> bekleyenTalepler(Ref ref) async {
  final repo = ref.watch(ugramaTalebiRepositoryProvider);
  return repo.getBekleyenler();
}

/// Bir müşterinin uğrama taleplerini getirir.
@riverpod
Future<List<UgramaTalebi>> taleplerByMusteri(
  Ref ref,
  String musteriId,
) async {
  final repo = ref.watch(ugramaTalebiRepositoryProvider);
  return repo.getByMusteriId(musteriId);
}
