import 'package:eipat/core/runtime/cache_policy.dart';
import 'package:eipat/core/runtime/connectivity_service.dart';
import 'package:eipat/core/runtime/retry_policy.dart';
import 'package:eipat/feature/example_feed/data/example_feed_local_cache.dart';
import 'package:eipat/feature/example_feed/data/example_feed_remote_data_source.dart';
import 'package:eipat/feature/example_feed/data/example_feed_repository_impl.dart';
import 'package:eipat/feature/example_feed/domain/example_feed_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_api_client.dart';
import '../../helpers/fakes/fake_connectivity_service.dart';
import '../../helpers/fakes/fake_crash_reporting_service.dart';
import '../../helpers/fakes/fake_secure_storage_service.dart';

void main() {
  group('ExampleFeedRepositoryImpl', () {
    test('returns remote items and stores them in cache', () async {
      final storage = FakeSecureStorageService();
      final repository = ExampleFeedRepositoryImpl(
        remoteDataSource: ExampleFeedRemoteDataSource(
          apiClient: FakeApiClient(
            getResponses: <String, dynamic>{
              '/example-feed': <String, dynamic>{
                'items': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'alpha',
                    'title': 'Alpha item',
                    'subtitle': 'Loaded from fake api',
                    'category': 'template',
                  },
                ],
              },
            },
          ),
        ),
        localCache: ExampleFeedLocalCache(secureStorageService: storage),
        connectivityService: FakeConnectivityService(),
        crashReportingService: FakeCrashReportingService(),
        cachePolicy: const CachePolicy.standard(),
        retryPolicy: const RetryPolicy.networkDefault(),
        now: () => DateTime(2026, 3, 8, 12),
      );

      final items = await repository.load();

      expect(items, hasLength(1));
      expect(items.first.title, 'Alpha item');
      expect(
        await storage.read(key: 'example_feed.payload'),
        contains('Alpha item'),
      );
    });

    test('falls back to cached items while offline', () async {
      final storage = FakeSecureStorageService();
      final cache = ExampleFeedLocalCache(secureStorageService: storage);
      await cache.write(
        items: const <ExampleFeedItem>[
          ExampleFeedItem(
            id: 'cached',
            title: 'Cached item',
            subtitle: 'Stored locally',
            category: 'cache',
          ),
        ],
        cachedAt: DateTime(2026, 3, 8, 11, 55),
      );

      final repository = ExampleFeedRepositoryImpl(
        remoteDataSource: ExampleFeedRemoteDataSource(
          apiClient: FakeApiClient(),
        ),
        localCache: cache,
        connectivityService: FakeConnectivityService(
          initialStatus: ConnectivityStatus.offline,
        ),
        crashReportingService: FakeCrashReportingService(),
        cachePolicy: const CachePolicy.standard(),
        retryPolicy: const RetryPolicy.networkDefault(),
        now: () => DateTime(2026, 3, 8, 12),
      );

      final items = await repository.load(forceRefresh: true);

      expect(items.single.title, 'Cached item');
    });
  });
}
