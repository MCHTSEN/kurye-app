import 'domain/musteri_personel.dart';

/// Müşteri personeli CRUD kontratı.
abstract class MusteriPersonelRepository {
  Future<List<MusteriPersonel>> getAll();
  Future<MusteriPersonel?> getById(String id);
  Future<MusteriPersonel> create(MusteriPersonel personel);
  Future<MusteriPersonel> update(MusteriPersonel personel);
  Future<void> delete(String id);
  Future<List<MusteriPersonel>> getByMusteriId(String musteriId);

  /// Auth user ID'sine göre personel kaydını bulur.
  Future<MusteriPersonel?> getByUserId(String userId);
}
