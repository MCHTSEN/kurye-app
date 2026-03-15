import 'domain/siparis_log.dart';

/// Sipariş log CRUD kontratı — durum değişiklik kayıtları.
abstract class SiparisLogRepository {
  Future<SiparisLog> create(SiparisLog log);
  Future<List<SiparisLog>> getBySiparisId(String siparisId);
}
