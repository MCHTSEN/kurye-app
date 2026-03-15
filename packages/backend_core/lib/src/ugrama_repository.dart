import 'domain/ugrama.dart';

/// Uğrama CRUD kontratı.
/// Not: Müşteri bazlı uğrama erişimi artık `MusteriUgramaRepository`
/// üzerinden sağlanır (many-to-many köprü tablosu).
abstract class UgramaRepository {
  Future<List<Ugrama>> getAll();
  Future<Ugrama?> getById(String id);
  Future<Ugrama> create(Ugrama ugrama);
  Future<Ugrama> update(Ugrama ugrama);
  Future<void> delete(String id);
}
