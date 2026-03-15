import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUgramaTalebiRepository implements UgramaTalebiRepository {
  SupabaseUgramaTalebiRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log =
      AppLogger('SupabaseUgramaTalebiRepo', tag: LogTag.data);

  static const _table = 'ugrama_talepleri';
  static const _ugramaTable = 'ugramalar';
  static const _bridgeTable = 'musteri_ugrama';

  /// Explicit column selection for ugrama (no lokasyon).
  static const _ugramaColumns =
      'id, ugrama_adi, adres, is_active, created_at';

  @override
  Future<UgramaTalebi> create(UgramaTalebi talep) async {
    _log.i('create: ${talep.ugramaAdi} (musteri: ${talep.musteriId})');
    final data = await _client
        .from(_table)
        .insert({
          'musteri_id': talep.musteriId,
          'talep_eden_id': talep.talepEdenId,
          'ugrama_adi': talep.ugramaAdi,
          'adres': talep.adres,
        })
        .select()
        .single();
    _log.i('created talep: ${data['id']}');
    return UgramaTalebi.fromJson(data);
  }

  @override
  Future<List<UgramaTalebi>> getByMusteriId(String musteriId) async {
    _log.d('getByMusteriId: $musteriId');
    final data = await _client
        .from(_table)
        .select()
        .eq('musteri_id', musteriId)
        .order('created_at', ascending: false);
    return data.map(UgramaTalebi.fromJson).toList();
  }

  @override
  Future<List<UgramaTalebi>> getAll() async {
    _log.d('getAll');
    final data = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);
    return data.map(UgramaTalebi.fromJson).toList();
  }

  @override
  Future<List<UgramaTalebi>> getBekleyenler() async {
    _log.d('getBekleyenler');
    final data = await _client
        .from(_table)
        .select()
        .eq('durum', UgramaTalepDurum.beklemede.value)
        .order('created_at', ascending: false);
    return data.map(UgramaTalebi.fromJson).toList();
  }

  @override
  Future<UgramaTalebi> approve({
    required String talepId,
    required String islemYapanId,
  }) async {
    _log.i('approve: talepId=$talepId, islemYapan=$islemYapanId');

    // 1. Talebi oku
    final talepData = await _client
        .from(_table)
        .select()
        .eq('id', talepId)
        .single();
    final talep = UgramaTalebi.fromJson(talepData);

    // 2. Uğramalar tablosuna insert
    final ugramaData = await _client
        .from(_ugramaTable)
        .insert({
          'ugrama_adi': talep.ugramaAdi,
          'adres': talep.adres,
          'is_active': true,
        })
        .select(_ugramaColumns)
        .single();
    final ugramaId = ugramaData['id'] as String;

    // 3. Köprü tablosuna atama
    await _client.from(_bridgeTable).insert({
      'musteri_id': talep.musteriId,
      'ugrama_id': ugramaId,
    });

    // 4. Talep durumunu güncelle
    final updatedData = await _client
        .from(_table)
        .update({
          'durum': UgramaTalepDurum.onaylandi.value,
          'islem_yapan_id': islemYapanId,
          'onaylanan_ugrama_id': ugramaId,
        })
        .eq('id', talepId)
        .select()
        .single();

    _log.i('approved: talepId=$talepId → ugramaId=$ugramaId');
    return UgramaTalebi.fromJson(updatedData);
  }

  @override
  Future<UgramaTalebi> reject({
    required String talepId,
    required String islemYapanId,
    required String redNotu,
  }) async {
    _log.i('reject: talepId=$talepId, not=$redNotu');
    final data = await _client
        .from(_table)
        .update({
          'durum': UgramaTalepDurum.reddedildi.value,
          'islem_yapan_id': islemYapanId,
          'red_notu': redNotu,
        })
        .eq('id', talepId)
        .select()
        .single();
    _log.i('rejected: talepId=$talepId');
    return UgramaTalebi.fromJson(data);
  }
}
