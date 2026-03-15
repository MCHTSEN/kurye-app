import 'package:backend_core/backend_core.dart';

/// In-memory [MusteriPersonelRepository] for widget testing.
class FakeMusteriPersonelRepository implements MusteriPersonelRepository {
  FakeMusteriPersonelRepository({List<MusteriPersonel>? seed}) {
    if (seed != null) {
      for (final p in seed) {
        store[p.id] = p;
      }
    }
  }

  final store = <String, MusteriPersonel>{};
  int _nextId = 1;

  @override
  Future<List<MusteriPersonel>> getAll() async => store.values.toList();

  @override
  Future<MusteriPersonel?> getById(String id) async => store[id];

  @override
  Future<MusteriPersonel> create(MusteriPersonel personel) async {
    final id = 'fake-personel-${_nextId++}';
    final created = MusteriPersonel(
      id: id,
      musteriId: personel.musteriId,
      ad: personel.ad,
      userId: personel.userId,
      telefon: personel.telefon,
      email: personel.email,
      isActive: personel.isActive,
      createdAt: DateTime.now(),
    );
    store[id] = created;
    return created;
  }

  @override
  Future<MusteriPersonel> update(MusteriPersonel personel) async {
    store[personel.id] = personel;
    return personel;
  }

  @override
  Future<void> delete(String id) async {
    store.remove(id);
  }

  @override
  Future<List<MusteriPersonel>> getByMusteriId(String musteriId) async {
    return store.values.where((p) => p.musteriId == musteriId).toList();
  }

  @override
  Future<MusteriPersonel?> getByUserId(String userId) async {
    for (final p in store.values) {
      if (p.userId == userId) return p;
    }
    return null;
  }
}
