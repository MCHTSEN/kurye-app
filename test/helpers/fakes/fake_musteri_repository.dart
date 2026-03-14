import 'package:backend_core/backend_core.dart';

/// In-memory [MusteriRepository] for testing.
class FakeMusteriRepository implements MusteriRepository {
  FakeMusteriRepository({List<Musteri>? seed}) {
    if (seed != null) {
      for (final m in seed) {
        store[m.id] = m;
      }
    }
  }

  final store = <String, Musteri>{};
  int _nextId = 1;

  @override
  Future<List<Musteri>> getAll() async => store.values.toList();

  @override
  Future<Musteri?> getById(String id) async => store[id];

  @override
  Future<Musteri> create(Musteri musteri) async {
    final id = 'fake-${_nextId++}';
    final created = Musteri(
      id: id,
      firmaKisaAd: musteri.firmaKisaAd,
      firmaTamAd: musteri.firmaTamAd,
      telefon: musteri.telefon,
      adres: musteri.adres,
      email: musteri.email,
      vergiNo: musteri.vergiNo,
    );
    store[id] = created;
    return created;
  }

  @override
  Future<Musteri> update(Musteri musteri) async {
    store[musteri.id] = musteri;
    return musteri;
  }

  @override
  Future<void> delete(String id) async {
    store.remove(id);
  }
}
