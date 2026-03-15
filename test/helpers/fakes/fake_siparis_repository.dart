import 'dart:async';

import 'package:backend_core/backend_core.dart';

/// In-memory [SiparisRepository] with stream support for widget testing.
class FakeSiparisRepository implements SiparisRepository {
  FakeSiparisRepository({List<Siparis>? seed}) {
    if (seed != null) {
      for (final s in seed) {
        store[s.id] = s;
      }
    }
  }

  final store = <String, Siparis>{};
  int _nextId = 1;

  /// Controllers for active stream subscriptions — keyed by musteriId or
  /// '_active' for the active stream.
  final _controllers = <String, StreamController<List<Siparis>>>{};

  @override
  Future<Siparis> create(Siparis siparis) async {
    final id = 'fake-siparis-${_nextId++}';
    final created = Siparis(
      id: id,
      musteriId: siparis.musteriId,
      personelId: siparis.personelId,
      kuryeId: siparis.kuryeId,
      cikisId: siparis.cikisId,
      ugramaId: siparis.ugramaId,
      ugrama1Id: siparis.ugrama1Id,
      notId: siparis.notId,
      not1: siparis.not1,
      durum: siparis.durum,
      ucret: siparis.ucret,
      olusturanId: siparis.olusturanId,
      createdAt: DateTime.now(),
    );
    store[id] = created;
    _notifyStreams();
    return created;
  }

  @override
  Future<List<Siparis>> getByMusteriId(String musteriId) async {
    return store.values
        .where((s) => s.musteriId == musteriId)
        .toList();
  }

  @override
  Future<List<Siparis>> getByDurum(SiparisDurum durum) async {
    return store.values.where((s) => s.durum == durum).toList();
  }

  @override
  Future<Siparis> updateDurum(String id, SiparisDurum durum) async {
    final existing = store[id];
    if (existing == null) {
      throw StateError('Siparis not found: $id');
    }
    final updated = Siparis(
      id: existing.id,
      musteriId: existing.musteriId,
      personelId: existing.personelId,
      kuryeId: existing.kuryeId,
      cikisId: existing.cikisId,
      ugramaId: existing.ugramaId,
      ugrama1Id: existing.ugrama1Id,
      notId: existing.notId,
      not1: existing.not1,
      durum: durum,
      ucret: existing.ucret,
      olusturanId: existing.olusturanId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    store[id] = updated;
    _notifyStreams();
    return updated;
  }

  @override
  Stream<List<Siparis>> streamByMusteriId(String musteriId) {
    final key = 'musteri_$musteriId';
    _controllers[key] ??= StreamController<List<Siparis>>.broadcast();
    final controller = _controllers[key]!;

    // Emit current state immediately, then stream updates.
    return controller.stream.transform(
      StreamTransformer<List<Siparis>, List<Siparis>>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
      ),
    ).startWithValue(
      store.values.where((s) => s.musteriId == musteriId).toList(),
    );
  }

  @override
  Stream<List<Siparis>> streamActive() {
    const key = '_active';
    _controllers[key] ??= StreamController<List<Siparis>>.broadcast();
    final controller = _controllers[key]!;

    return controller.stream.transform(
      StreamTransformer<List<Siparis>, List<Siparis>>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
      ),
    ).startWithValue(
      _activeOrders(),
    );
  }

  List<Siparis> _activeOrders() {
    return store.values
        .where(
          (s) =>
              s.durum == SiparisDurum.kuryeBekliyor ||
              s.durum == SiparisDurum.devamEdiyor,
        )
        .toList();
  }

  /// Notify all open stream controllers with current data.
  void _notifyStreams() {
    for (final entry in _controllers.entries) {
      if (entry.value.isClosed) continue;
      if (entry.key == '_active') {
        entry.value.add(_activeOrders());
      } else if (entry.key.startsWith('musteri_')) {
        final musteriId = entry.key.substring('musteri_'.length);
        entry.value.add(
          store.values.where((s) => s.musteriId == musteriId).toList(),
        );
      }
    }
  }

  /// Emit arbitrary data to a stream — for test scenarios.
  void emitForMusteri(String musteriId, List<Siparis> data) {
    final key = 'musteri_$musteriId';
    _controllers[key]?.add(data);
  }

  /// Emit arbitrary data to the active stream — for test scenarios.
  void emitActive(List<Siparis> data) {
    _controllers['_active']?.add(data);
  }

  Future<void> dispose() async {
    for (final c in _controllers.values) {
      await c.close();
    }
    _controllers.clear();
  }
}

/// Extension to start a stream with an initial value.
extension _StartWith<T> on Stream<T> {
  Stream<T> startWithValue(T value) async* {
    yield value;
    yield* this;
  }
}
