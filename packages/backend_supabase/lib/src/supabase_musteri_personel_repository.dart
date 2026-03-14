import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMusteriPersonelRepository implements MusteriPersonelRepository {
  SupabaseMusteriPersonelRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log =
      AppLogger('SupabaseMusteriPersonelRepo', tag: LogTag.data);

  static const _table = 'musteri_personelleri';

  @override
  Future<List<MusteriPersonel>> getAll() async {
    _log.d('getAll');
    final data = await _client
        .from(_table)
        .select()
        .order('ad');
    return data.map(MusteriPersonel.fromJson).toList();
  }

  @override
  Future<MusteriPersonel?> getById(String id) async {
    _log.d('getById: $id');
    final data = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return MusteriPersonel.fromJson(data);
  }

  @override
  Future<MusteriPersonel> create(MusteriPersonel personel) async {
    _log.i('create: ${personel.ad} (musteri: ${personel.musteriId})');
    final data = await _client
        .from(_table)
        .insert({
          'musteri_id': personel.musteriId,
          'user_id': personel.userId,
          'ad': personel.ad,
          'telefon': personel.telefon,
          'email': personel.email,
          'is_active': personel.isActive,
        })
        .select()
        .single();
    _log.i('created: ${data['id']}');
    return MusteriPersonel.fromJson(data);
  }

  @override
  Future<MusteriPersonel> update(MusteriPersonel personel) async {
    _log.i('update: ${personel.id}');
    final data = await _client
        .from(_table)
        .update({
          'user_id': personel.userId,
          'ad': personel.ad,
          'telefon': personel.telefon,
          'email': personel.email,
          'is_active': personel.isActive,
        })
        .eq('id', personel.id)
        .select()
        .single();
    _log.i('updated: ${personel.id}');
    return MusteriPersonel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    _log.i('delete: $id');
    await _client.from(_table).delete().eq('id', id);
  }

  @override
  Future<List<MusteriPersonel>> getByMusteriId(String musteriId) async {
    _log.d('getByMusteriId: $musteriId');
    final data = await _client
        .from(_table)
        .select()
        .eq('musteri_id', musteriId)
        .order('ad');
    return data.map(MusteriPersonel.fromJson).toList();
  }

  @override
  Future<MusteriPersonel?> getByUserId(String userId) async {
    _log.d('getByUserId: $userId');
    final data = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return MusteriPersonel.fromJson(data);
  }
}
