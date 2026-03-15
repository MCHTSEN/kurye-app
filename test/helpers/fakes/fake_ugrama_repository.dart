import 'package:backend_core/backend_core.dart';

/// In-memory [UgramaRepository] for widget testing.
class FakeUgramaRepository implements UgramaRepository {
  FakeUgramaRepository({List<Ugrama>? seed}) {
    if (seed != null) {
      for (final u in seed) {
        store[u.id] = u;
      }
    }
  }

  final store = <String, Ugrama>{};
  int _nextId = 1;

  @override
  Future<List<Ugrama>> getAll() async => store.values.toList();

  @override
  Future<Ugrama?> getById(String id) async => store[id];

  @override
  Future<Ugrama> create(Ugrama ugrama) async {
    final id = 'fake-ugrama-${_nextId++}';
    final created = Ugrama(
      id: id,
      ugramaAdi: ugrama.ugramaAdi,
      adres: ugrama.adres,
      isActive: ugrama.isActive,
      createdAt: DateTime.now(),
    );
    store[id] = created;
    return created;
  }

  @override
  Future<Ugrama> update(Ugrama ugrama) async {
    store[ugrama.id] = ugrama;
    return ugrama;
  }

  @override
  Future<void> delete(String id) async {
    store.remove(id);
  }
}

/// In-memory [MusteriUgramaRepository] for widget testing.
class FakeMusteriUgramaRepository implements MusteriUgramaRepository {
  final _assignments = <String, Set<String>>{}; // musteriId → Set<ugramaId>

  /// Provide a FakeUgramaRepository to resolve ugrama objects.
  FakeUgramaRepository? ugramaRepo;

  @override
  Future<void> assign(String musteriId, String ugramaId) async {
    _assignments.putIfAbsent(musteriId, () => {}).add(ugramaId);
  }

  @override
  Future<void> unassign(String musteriId, String ugramaId) async {
    _assignments[musteriId]?.remove(ugramaId);
  }

  @override
  Future<List<Ugrama>> getUgramaByMusteriId(String musteriId) async {
    final ids = _assignments[musteriId] ?? {};
    if (ugramaRepo == null) return [];
    return ugramaRepo!.store.values
        .where((u) => ids.contains(u.id))
        .toList();
  }

  @override
  Future<List<String>> getMusteriIdsByUgramaId(String ugramaId) async {
    return _assignments.entries
        .where((e) => e.value.contains(ugramaId))
        .map((e) => e.key)
        .toList();
  }

  @override
  Future<void> assignBatch(String musteriId, List<String> ugramaIds) async {
    for (final uid in ugramaIds) {
      await assign(musteriId, uid);
    }
  }

  @override
  Future<void> assignUgramaToBatch(
    String ugramaId,
    List<String> musteriIds,
  ) async {
    for (final mid in musteriIds) {
      await assign(mid, ugramaId);
    }
  }

  @override
  Future<void> syncMusterilerForUgrama(
    String ugramaId,
    List<String> musteriIds,
  ) async {
    // Remove from all
    for (final entry in _assignments.values) {
      entry.remove(ugramaId);
    }
    // Add to new
    for (final mid in musteriIds) {
      _assignments.putIfAbsent(mid, () => {}).add(ugramaId);
    }
  }
}
