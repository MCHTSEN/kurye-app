import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMusteriRepository implements MusteriRepository {
  SupabaseMusteriRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger('SupabaseMusteriRepo', tag: LogTag.data);

  static const _table = 'musteriler';

  @override
  Future<List<Musteri>> getAll() async {
    _log.d('getAll');
    final data = await _client
        .from(_table)
        .select()
        .order('firma_kisa_ad');
    return data.map(Musteri.fromJson).toList();
  }

  @override
  Future<Musteri?> getById(String id) async {
    _log.d('getById: $id');
    final data = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Musteri.fromJson(data);
  }

  @override
  Future<Musteri> create(Musteri musteri) async {
    _log.i('create: ${musteri.firmaKisaAd}');
    final data = await _client
        .from(_table)
        .insert({
          'firma_kisa_ad': musteri.firmaKisaAd,
          'firma_tam_ad': musteri.firmaTamAd,
          'telefon': musteri.telefon,
          'adres': musteri.adres,
          'email': musteri.email,
          'vergi_no': musteri.vergiNo,
          'is_active': musteri.isActive,
        })
        .select()
        .single();
    _log.i('created: ${data['id']}');
    return Musteri.fromJson(data);
  }

  @override
  Future<Musteri> update(Musteri musteri) async {
    _log.i('update: ${musteri.id}');
    // Don't include updated_at — BEFORE UPDATE trigger handles it.
    final data = await _client
        .from(_table)
        .update({
          'firma_kisa_ad': musteri.firmaKisaAd,
          'firma_tam_ad': musteri.firmaTamAd,
          'telefon': musteri.telefon,
          'adres': musteri.adres,
          'email': musteri.email,
          'vergi_no': musteri.vergiNo,
          'is_active': musteri.isActive,
        })
        .eq('id', musteri.id)
        .select()
        .single();
    _log.i('updated: ${musteri.id}');
    return Musteri.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    _log.i('delete: $id');
    await _client.from(_table).delete().eq('id', id);
  }
}
