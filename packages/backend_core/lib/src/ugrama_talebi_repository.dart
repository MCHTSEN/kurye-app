import 'domain/ugrama_talebi.dart';

/// Uğrama talebi CRUD kontratı.
abstract class UgramaTalebiRepository {
  /// Yeni talep oluşturur (müşteri personeli).
  Future<UgramaTalebi> create(UgramaTalebi talep);

  /// Bir müşterinin tüm taleplerini getirir.
  Future<List<UgramaTalebi>> getByMusteriId(String musteriId);

  /// Tüm talepleri getirir (operasyon).
  Future<List<UgramaTalebi>> getAll();

  /// Bekleyen talepleri getirir (operasyon).
  Future<List<UgramaTalebi>> getBekleyenler();

  /// Talebi onayla: ugramalar tablosuna insert + köprü tablosuna atama +
  /// talep durumunu güncelle.
  /// Döndürülen UgramaTalebi'nde onaylananUgramaId dolu olur.
  Future<UgramaTalebi> approve({
    required String talepId,
    required String islemYapanId,
  });

  /// Talebi reddet (not ile).
  Future<UgramaTalebi> reject({
    required String talepId,
    required String islemYapanId,
    required String redNotu,
  });
}
