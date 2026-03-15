import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMusteriUgramaRepository implements MusteriUgramaRepository {
  SupabaseMusteriUgramaRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger('SupabaseMusteriUgramaRepo', tag: LogTag.data);

  static const _bridgeTable = 'musteri_ugrama';

  /// Explicit column selection to avoid Geography hex issue from `lokasyon`.
  static const _ugramaColumns =
      'id, ugrama_adi, adres, is_active, created_at';

  @override
  Future<void> assign(String musteriId, String ugramaId) async {
    _log.i('assign: musteri=$musteriId, ugrama=$ugramaId');
    await _client.from(_bridgeTable).upsert(
      {'musteri_id': musteriId, 'ugrama_id': ugramaId},
      onConflict: 'musteri_id,ugrama_id',
    );
  }

  @override
  Future<void> unassign(String musteriId, String ugramaId) async {
    _log.i('unassign: musteri=$musteriId, ugrama=$ugramaId');
    await _client
        .from(_bridgeTable)
        .delete()
        .eq('musteri_id', musteriId)
        .eq('ugrama_id', ugramaId);
  }

  @override
  Future<List<Ugrama>> getUgramaByMusteriId(String musteriId) async {
    _log.d('getUgramaByMusteriId: $musteriId');
    // Join through bridge table to get ugrama details
    final data = await _client
        .from(_bridgeTable)
        .select('ugrama_id, ugramalar($_ugramaColumns)')
        .eq('musteri_id', musteriId)
        .order('created_at');

    return data
        .where((row) => row['ugramalar'] != null)
        .map(
          (row) =>
              Ugrama.fromJson(row['ugramalar'] as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<String>> getMusteriIdsByUgramaId(String ugramaId) async {
    _log.d('getMusteriIdsByUgramaId: $ugramaId');
    final data = await _client
        .from(_bridgeTable)
        .select('musteri_id')
        .eq('ugrama_id', ugramaId);
    return data.map((row) => row['musteri_id'] as String).toList();
  }

  @override
  Future<void> assignBatch(String musteriId, List<String> ugramaIds) async {
    _log.i('assignBatch: musteri=$musteriId, count=${ugramaIds.length}');
    if (ugramaIds.isEmpty) return;

    final rows = ugramaIds
        .map((uid) => {'musteri_id': musteriId, 'ugrama_id': uid})
        .toList();
    await _client.from(_bridgeTable).upsert(
      rows,
      onConflict: 'musteri_id,ugrama_id',
    );
  }

  @override
  Future<void> assignUgramaToBatch(
    String ugramaId,
    List<String> musteriIds,
  ) async {
    _log.i(
      'assignUgramaToBatch: ugrama=$ugramaId, count=${musteriIds.length}',
    );
    if (musteriIds.isEmpty) return;

    final rows = musteriIds
        .map((mid) => {'musteri_id': mid, 'ugrama_id': ugramaId})
        .toList();
    await _client.from(_bridgeTable).upsert(
      rows,
      onConflict: 'musteri_id,ugrama_id',
    );
  }

  @override
  Future<void> syncMusterilerForUgrama(
    String ugramaId,
    List<String> musteriIds,
  ) async {
    _log.i(
      'syncMusterilerForUgrama: ugrama=$ugramaId, '
      'newCount=${musteriIds.length}',
    );

    // Mevcut atamaları kaldır
    await _client.from(_bridgeTable).delete().eq('ugrama_id', ugramaId);

    // Yeni atamaları ekle
    if (musteriIds.isNotEmpty) {
      final rows = musteriIds
          .map((mid) => {'musteri_id': mid, 'ugrama_id': ugramaId})
          .toList();
      await _client.from(_bridgeTable).insert(rows);
    }
  }
}
