import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSiparisRepository implements SiparisRepository {
  SupabaseSiparisRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger('SupabaseSiparisRepo', tag: LogTag.data);

  static const _table = 'siparisler';

  @override
  Future<Siparis> create(Siparis siparis) async {
    _log.i('create: musteri=${siparis.musteriId}, '
        'cikis=${siparis.cikisId}, ugrama=${siparis.ugramaId}');
    final data = await _client
        .from(_table)
        .insert({
          'musteri_id': siparis.musteriId,
          'personel_id': siparis.personelId,
          'kurye_id': siparis.kuryeId,
          'cikis_id': siparis.cikisId,
          'ugrama_id': siparis.ugramaId,
          'ugrama1_id': siparis.ugrama1Id,
          'not_id': siparis.notId,
          'not1': siparis.not1,
          'durum': siparis.durum.value,
          'ucret': siparis.ucret,
          'olusturan_id': siparis.olusturanId,
        })
        .select()
        .single();
    _log.i('created: ${data['id']}');
    return Siparis.fromJson(data);
  }

  @override
  Future<List<Siparis>> getByMusteriId(String musteriId) async {
    _log.d('getByMusteriId: $musteriId');
    final data = await _client
        .from(_table)
        .select()
        .eq('musteri_id', musteriId)
        .order('created_at', ascending: false);
    return data.map(Siparis.fromJson).toList();
  }

  @override
  Future<List<Siparis>> getByDurum(SiparisDurum durum) async {
    _log.d('getByDurum: ${durum.value}');
    final data = await _client
        .from(_table)
        .select()
        .eq('durum', durum.value)
        .order('created_at', ascending: false);
    return data.map(Siparis.fromJson).toList();
  }

  @override
  Future<Siparis> updateDurum(String id, SiparisDurum durum) async {
    _log.i('updateDurum: $id -> ${durum.value}');
    final data = await _client
        .from(_table)
        .update({'durum': durum.value})
        .eq('id', id)
        .select()
        .single();
    _log.i('durumUpdated: $id');
    return Siparis.fromJson(data);
  }

  @override
  Stream<List<Siparis>> streamByMusteriId(String musteriId) {
    _log.d('streamByMusteriId: $musteriId — subscribing');
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('musteri_id', musteriId)
        .order('created_at')
        .map((rows) {
          _log.d('streamByMusteriId: $musteriId — ${rows.length} rows');
          return rows.map(Siparis.fromJson).toList();
        })
        .handleError((Object error) {
          _log.e('streamByMusteriId error: $error');
        });
  }

  @override
  Future<Siparis> update(String id, Map<String, dynamic> fields) async {
    _log.i('update: $id — fields=${fields.keys.toList()}');
    final data = await _client
        .from(_table)
        .update(fields)
        .eq('id', id)
        .select()
        .single();
    _log.i('updated: $id');
    return Siparis.fromJson(data);
  }

  @override
  Future<List<Siparis>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? musteriId,
    String? kuryeId,
    String? cikisId,
    String? ugramaId,
  }) async {
    _log.i('getHistory: startDate=$startDate, endDate=$endDate, '
        'musteri=$musteriId, kurye=$kuryeId, cikis=$cikisId, ugrama=$ugramaId');
    var query = _client
        .from(_table)
        .select()
        .inFilter('durum', [
      SiparisDurum.tamamlandi.value,
      SiparisDurum.iptal.value,
    ]);
    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toIso8601String());
    }
    if (musteriId != null) {
      query = query.eq('musteri_id', musteriId);
    }
    if (kuryeId != null) {
      query = query.eq('kurye_id', kuryeId);
    }
    if (cikisId != null) {
      query = query.eq('cikis_id', cikisId);
    }
    if (ugramaId != null) {
      query = query.eq('ugrama_id', ugramaId);
    }
    final data =
        await query.order('created_at', ascending: false);
    _log.i('getHistory: ${data.length} rows returned');
    return data.map(Siparis.fromJson).toList();
  }

  @override
  Future<Siparis?> getRecentPricing({
    required String musteriId,
    required String cikisId,
    required String ugramaId,
  }) async {
    _log.d('getRecentPricing: musteri=$musteriId, '
        'cikis=$cikisId, ugrama=$ugramaId');
    final data = await _client
        .from(_table)
        .select()
        .eq('musteri_id', musteriId)
        .eq('cikis_id', cikisId)
        .eq('ugrama_id', ugramaId)
        .eq('durum', SiparisDurum.tamamlandi.value)
        .order('created_at', ascending: false)
        .limit(1);
    if (data.isEmpty) {
      _log.w('getRecentPricing: no match — '
          'musteri=$musteriId, cikis=$cikisId, ugrama=$ugramaId');
      return null;
    }
    return Siparis.fromJson(data.first);
  }

  @override
  Stream<List<Siparis>> streamByKuryeId(String kuryeId) {
    _log.d('streamByKuryeId: $kuryeId — subscribing');
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('kurye_id', kuryeId)
        .order('created_at')
        .map((rows) {
          _log.d('streamByKuryeId: $kuryeId — ${rows.length} rows');
          return rows.map(Siparis.fromJson).toList();
        })
        .handleError((Object error) {
          _log.e('streamByKuryeId error: $error');
        });
  }

  @override
  Stream<List<Siparis>> streamActive() {
    _log.d('streamActive — subscribing');
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .inFilter('durum', [
          SiparisDurum.kuryeBekliyor.value,
          SiparisDurum.devamEdiyor.value,
        ])
        .order('created_at')
        .map((rows) {
          _log.d('streamActive — ${rows.length} rows');
          return rows.map(Siparis.fromJson).toList();
        })
        .handleError((Object error) {
          _log.e('streamActive error: $error');
        });
  }
}
