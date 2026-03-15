import 'package:backend_core/backend_core.dart';

/// In-memory [SiparisLogRepository] for widget testing.
class FakeSiparisLogRepository implements SiparisLogRepository {
  FakeSiparisLogRepository({List<SiparisLog>? seed}) {
    if (seed != null) {
      for (final log in seed) {
        store[log.id] = log;
      }
    }
  }

  final store = <String, SiparisLog>{};
  int _nextId = 1;

  @override
  Future<SiparisLog> create(SiparisLog log) async {
    final id = 'fake-log-${_nextId++}';
    final created = SiparisLog(
      id: id,
      siparisId: log.siparisId,
      eskiDurum: log.eskiDurum,
      yeniDurum: log.yeniDurum,
      degistirenId: log.degistirenId,
      aciklama: log.aciklama,
      createdAt: DateTime.now(),
    );
    store[id] = created;
    return created;
  }

  @override
  Future<List<SiparisLog>> getBySiparisId(String siparisId) async {
    return store.values
        .where((log) => log.siparisId == siparisId)
        .toList();
  }
}
