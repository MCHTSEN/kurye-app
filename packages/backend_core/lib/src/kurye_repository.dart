import 'domain/kurye.dart';

/// Kurye CRUD kontratı.
abstract class KuryeRepository {
  Future<List<Kurye>> getAll();
  Future<Kurye?> getById(String id);
  Future<Kurye> create(Kurye kurye);
  Future<Kurye> update(Kurye kurye);
  Future<void> delete(String id);
  Future<void> updateOnlineStatus(String id, {required bool isOnline});
}
