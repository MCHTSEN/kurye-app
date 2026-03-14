import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseKuryeRepository implements KuryeRepository {
  SupabaseKuryeRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger('SupabaseKuryeRepo', tag: LogTag.data);

  static const _table = 'kuryeler';

  @override
  Future<List<Kurye>> getAll() async {
    _log.d('getAll');
    final data = await _client
        .from(_table)
        .select()
        .order('ad');
    return data.map(Kurye.fromJson).toList();
  }

  @override
  Future<Kurye?> getById(String id) async {
    _log.d('getById: $id');
    final data = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Kurye.fromJson(data);
  }

  @override
  Future<Kurye> create(Kurye kurye) async {
    _log.i('create: ${kurye.ad}');
    final data = await _client
        .from(_table)
        .insert({
          'user_id': kurye.userId,
          'ad': kurye.ad,
          'telefon': kurye.telefon,
          'plaka': kurye.plaka,
          'is_active': kurye.isActive,
          'is_online': kurye.isOnline,
        })
        .select()
        .single();
    _log.i('created: ${data['id']}');
    return Kurye.fromJson(data);
  }

  @override
  Future<Kurye> update(Kurye kurye) async {
    _log.i('update: ${kurye.id}');
    // Don't include updated_at — BEFORE UPDATE trigger handles it.
    final data = await _client
        .from(_table)
        .update({
          'user_id': kurye.userId,
          'ad': kurye.ad,
          'telefon': kurye.telefon,
          'plaka': kurye.plaka,
          'is_active': kurye.isActive,
          'is_online': kurye.isOnline,
        })
        .eq('id', kurye.id)
        .select()
        .single();
    _log.i('updated: ${kurye.id}');
    return Kurye.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    _log.i('delete: $id');
    await _client.from(_table).delete().eq('id', id);
  }

  @override
  Future<void> updateOnlineStatus(String id, {required bool isOnline}) async {
    _log.i('updateOnlineStatus: $id -> $isOnline');
    await _client
        .from(_table)
        .update({'is_online': isOnline})
        .eq('id', id);
  }
}
