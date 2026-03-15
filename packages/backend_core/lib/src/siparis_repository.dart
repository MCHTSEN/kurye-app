import 'domain/siparis.dart';

/// Sipariş CRUD + realtime stream kontratı.
abstract class SiparisRepository {
  Future<Siparis> create(Siparis siparis);
  Future<List<Siparis>> getByMusteriId(String musteriId);
  Future<List<Siparis>> getByDurum(SiparisDurum durum);
  Future<Siparis> updateDurum(String id, SiparisDurum durum);

  /// Belirli müşterinin siparişlerini realtime izler.
  Stream<List<Siparis>> streamByMusteriId(String musteriId);

  /// Aktif siparişleri realtime izler (kurye_bekliyor + devam_ediyor).
  Stream<List<Siparis>> streamActive();
}
