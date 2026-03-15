import 'package:backend_core/backend_core.dart';

/// In-memory [KuryeRepository] for widget and unit testing.
class FakeKuryeRepository implements KuryeRepository {
  FakeKuryeRepository({List<Kurye>? seed}) {
    if (seed != null) {
      for (final k in seed) {
        store[k.id] = k;
      }
    }
  }

  final store = <String, Kurye>{};
  int _nextId = 1;

  @override
  Future<List<Kurye>> getAll() async {
    return store.values.toList();
  }

  @override
  Future<Kurye?> getById(String id) async {
    return store[id];
  }

  @override
  Future<Kurye> create(Kurye kurye) async {
    final id = 'fake-kurye-${_nextId++}';
    final created = Kurye(
      id: id,
      userId: kurye.userId,
      ad: kurye.ad,
      telefon: kurye.telefon,
      plaka: kurye.plaka,
      isActive: kurye.isActive,
      isOnline: kurye.isOnline,
      createdAt: DateTime.now(),
    );
    store[id] = created;
    return created;
  }

  @override
  Future<Kurye> update(Kurye kurye) async {
    final existing = store[kurye.id];
    if (existing == null) {
      throw StateError('Kurye not found: ${kurye.id}');
    }
    final updated = Kurye(
      id: kurye.id,
      userId: kurye.userId,
      ad: kurye.ad,
      telefon: kurye.telefon,
      plaka: kurye.plaka,
      isActive: kurye.isActive,
      isOnline: kurye.isOnline,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    store[kurye.id] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    if (!store.containsKey(id)) {
      throw StateError('Kurye not found: $id');
    }
    store.remove(id);
  }

  @override
  Future<void> updateOnlineStatus(String id, {required bool isOnline}) async {
    final existing = store[id];
    if (existing == null) {
      throw StateError('Kurye not found: $id');
    }
    store[id] = Kurye(
      id: existing.id,
      userId: existing.userId,
      ad: existing.ad,
      telefon: existing.telefon,
      plaka: existing.plaka,
      isActive: existing.isActive,
      isOnline: isOnline,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
