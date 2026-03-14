import 'domain/musteri.dart';

/// Müşteri CRUD kontratı.
abstract class MusteriRepository {
  Future<List<Musteri>> getAll();
  Future<Musteri?> getById(String id);
  Future<Musteri> create(Musteri musteri);
  Future<Musteri> update(Musteri musteri);
  Future<void> delete(String id);
}
