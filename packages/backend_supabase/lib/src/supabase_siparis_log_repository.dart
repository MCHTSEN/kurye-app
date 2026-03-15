import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSiparisLogRepository implements SiparisLogRepository {
  SupabaseSiparisLogRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger('SupabaseSiparisLogRepo', tag: LogTag.data);

  static const _table = 'siparis_log';

  @override
  Future<SiparisLog> create(SiparisLog log) async {
    _log.i('create: siparis=${log.siparisId}, '
        '${log.eskiDurum?.value} -> ${log.yeniDurum.value}');
    final data = await _client
        .from(_table)
        .insert({
          'siparis_id': log.siparisId,
          'eski_durum': log.eskiDurum?.value,
          'yeni_durum': log.yeniDurum.value,
          'degistiren_id': log.degistirenId,
          'aciklama': log.aciklama,
        })
        .select()
        .single();
    _log.i('created: ${data['id']}');
    return SiparisLog.fromJson(data);
  }

  @override
  Future<List<SiparisLog>> getBySiparisId(String siparisId) async {
    _log.d('getBySiparisId: $siparisId');
    final data = await _client
        .from(_table)
        .select()
        .eq('siparis_id', siparisId)
        .order('created_at');
    return data.map(SiparisLog.fromJson).toList();
  }
}
