import 'dart:convert';

import '../../../core/runtime/secure_storage_service.dart';
import '../domain/example_feed_item.dart';

class ExampleFeedCacheSnapshot {
  const ExampleFeedCacheSnapshot({
    required this.items,
    required this.cachedAt,
  });

  final List<ExampleFeedItem> items;
  final DateTime cachedAt;
}

class ExampleFeedLocalCache {
  ExampleFeedLocalCache({required SecureStorageService secureStorageService})
    : _secureStorageService = secureStorageService;

  static const _payloadKey = 'example_feed.payload';
  static const _cachedAtKey = 'example_feed.cached_at';

  final SecureStorageService _secureStorageService;

  Future<ExampleFeedCacheSnapshot?> read() async {
    final payload = await _secureStorageService.read(key: _payloadKey);
    final cachedAtRaw = await _secureStorageService.read(key: _cachedAtKey);

    if (payload == null || cachedAtRaw == null) {
      return null;
    }

    final decoded = jsonDecode(payload);
    if (decoded is! List<dynamic>) {
      return null;
    }

    final items = decoded
        .whereType<Map<String, dynamic>>()
        .map(ExampleFeedItem.fromJson)
        .toList(growable: false);

    return ExampleFeedCacheSnapshot(
      items: items,
      cachedAt: DateTime.parse(cachedAtRaw),
    );
  }

  Future<void> write({
    required List<ExampleFeedItem> items,
    required DateTime cachedAt,
  }) async {
    final payload = jsonEncode(items.map((item) => item.toJson()).toList());
    await _secureStorageService.write(key: _payloadKey, value: payload);
    await _secureStorageService.write(
      key: _cachedAtKey,
      value: cachedAt.toIso8601String(),
    );
  }
}
