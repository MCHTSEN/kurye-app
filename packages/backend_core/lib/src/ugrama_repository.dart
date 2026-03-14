import 'domain/ugrama.dart';

/// Uğrama CRUD kontratı.
abstract class UgramaRepository {
  Future<List<Ugrama>> getAll();
  Future<Ugrama?> getById(String id);
  Future<Ugrama> create(Ugrama ugrama);
  Future<Ugrama> update(Ugrama ugrama);
  Future<void> delete(String id);
  Future<List<Ugrama>> getByMusteriId(String musteriId);
}
