import 'domain/ugrama.dart';

/// Müşteri-Uğrama köprü (many-to-many) kontratı.
abstract class MusteriUgramaRepository {
  /// Bir müşteriye bir uğrama atar.
  Future<void> assign(String musteriId, String ugramaId);

  /// Bir müşteriden bir uğrama atamasını kaldırır.
  Future<void> unassign(String musteriId, String ugramaId);

  /// Bir müşteriye atanmış tüm uğramaları getirir.
  Future<List<Ugrama>> getUgramaByMusteriId(String musteriId);

  /// Bir uğramaya atanmış tüm müşteri ID'lerini getirir.
  Future<List<String>> getMusteriIdsByUgramaId(String ugramaId);

  /// Bir müşteriye birden fazla uğrama atar (toplu atama).
  Future<void> assignBatch(String musteriId, List<String> ugramaIds);

  /// Bir uğramayı birden fazla müşteriye atar (toplu atama).
  Future<void> assignUgramaToBatch(
    String ugramaId,
    List<String> musteriIds,
  );

  /// Bir uğramanın müşteri atamalarını tamamen değiştirir.
  /// Önceki atamalar kaldırılır, yenileri eklenir.
  Future<void> syncMusterilerForUgrama(
    String ugramaId,
    List<String> musteriIds,
  );
}
