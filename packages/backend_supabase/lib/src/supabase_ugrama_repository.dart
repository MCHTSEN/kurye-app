import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUgramaRepository implements UgramaRepository {
  SupabaseUgramaRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger('SupabaseUgramaRepo', tag: LogTag.data);

  static const _table = 'ugramalar';

  /// Explicit column selection to avoid Geography hex issue from `lokasyon`.
  static const _columns = 'id, ugrama_adi, adres, is_active, created_at';

  @override
  Future<List<Ugrama>> getAll() async {
    _log.d('getAll');
    final data = await _client
        .from(_table)
        .select(_columns)
        .order('ugrama_adi');
    return data.map(Ugrama.fromJson).toList();
  }

  @override
  Future<Ugrama?> getById(String id) async {
    _log.d('getById: $id');
    final data = await _client
        .from(_table)
        .select(_columns)
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Ugrama.fromJson(data);
  }

  @override
  Future<Ugrama> create(Ugrama ugrama) async {
    _log.i('create: ${ugrama.ugramaAdi}');
    final data = await _client
        .from(_table)
        .insert({
          'ugrama_adi': ugrama.ugramaAdi,
          'adres': ugrama.adres,
          'is_active': ugrama.isActive,
        })
        .select(_columns)
        .single();
    _log.i('created: ${data['id']}');
    return Ugrama.fromJson(data);
  }

  @override
  Future<Ugrama> update(Ugrama ugrama) async {
    _log.i('update: ${ugrama.id}');
    final data = await _client
        .from(_table)
        .update({
          'ugrama_adi': ugrama.ugramaAdi,
          'adres': ugrama.adres,
          'is_active': ugrama.isActive,
        })
        .eq('id', ugrama.id)
        .select(_columns)
        .single();
    _log.i('updated: ${ugrama.id}');
    return Ugrama.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    _log.i('delete: $id');
    await _client.from(_table).delete().eq('id', id);
  }

}
