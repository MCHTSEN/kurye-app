import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUgramaTalebiRepository implements UgramaTalebiRepository {
  SupabaseUgramaTalebiRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log =
      AppLogger('SupabaseUgramaTalebiRepo', tag: LogTag.data);

  static const _table = 'ugrama_talepleri';

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

    // Single RPC call wraps ugrama insert + bridge insert + talep update
    // in a database transaction — no partial state on failure.
    final result = await _client.rpc(
      'approve_ugrama_talebi',
      params: {
        'p_talep_id': talepId,
        'p_islem_yapan_id': islemYapanId,
      },
    );

    final data = result as Map<String, dynamic>;
    _log.i('approved: talepId=$talepId → ugramaId=${data['onaylanan_ugrama_id']}');
    return UgramaTalebi.fromJson(data);
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
