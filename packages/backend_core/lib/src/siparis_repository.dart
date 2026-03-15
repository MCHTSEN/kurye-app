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

  /// Belirtilen alanları günceller (partial update).
  /// `updated_at` payload'a dahil edilmez — BEFORE UPDATE trigger halleder.
  Future<Siparis> update(String id, Map<String, dynamic> fields);

  /// Otomatik fiyatlandırma için en son tamamlanmış eşleşen siparişi bulur.
  Future<Siparis?> getRecentPricing({
    required String musteriId,
    required String cikisId,
    required String ugramaId,
  });
}
