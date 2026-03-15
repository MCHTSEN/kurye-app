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
      musteriId: ugrama.musteriId,
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

  @override
  Future<List<Ugrama>> getByMusteriId(String musteriId) async {
    return store.values.where((u) => u.musteriId == musteriId).toList();
  }
}
