import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/runtime/runtime.dart';
import '../../../product/runtime/runtime_providers.dart';
import '../domain/example_feed_item.dart';
import '../domain/example_feed_repository.dart';
import 'example_feed_local_cache.dart';
import 'example_feed_remote_data_source.dart';

part 'example_feed_repository_impl.g.dart';

class ExampleFeedRepositoryImpl implements ExampleFeedRepository {
  ExampleFeedRepositoryImpl({
    required ExampleFeedRemoteDataSource remoteDataSource,
    required ExampleFeedLocalCache localCache,
    required ConnectivityService connectivityService,
    required CrashReportingService crashReportingService,
    required CachePolicy cachePolicy,
    required RetryPolicy retryPolicy,
    DateTime Function()? now,
  }) : _remoteDataSource = remoteDataSource,
       _localCache = localCache,
       _connectivityService = connectivityService,
       _crashReportingService = crashReportingService,
       _cachePolicy = cachePolicy,
       _retryPolicy = retryPolicy,
       _now = now ?? DateTime.now;

  final ExampleFeedRemoteDataSource _remoteDataSource;
  final ExampleFeedLocalCache _localCache;
  final ConnectivityService _connectivityService;
  final CrashReportingService _crashReportingService;
  final CachePolicy _cachePolicy;
  final RetryPolicy _retryPolicy;
  final DateTime Function() _now;

  @override
  Future<List<ExampleFeedItem>> load({bool forceRefresh = false}) async {
    final now = _now();
    final cached = await _localCache.read();

    if (!forceRefresh &&
        cached != null &&
        _cachePolicy.isFresh(cached.cachedAt, now)) {
      return cached.items;
    }

    final connectivityStatus = await _connectivityService.currentStatus();
    if (connectivityStatus == ConnectivityStatus.offline) {
      if (cached != null && _cachePolicy.allowStaleFallback) {
        return cached.items;
      }
      throw StateError(
        'Device is offline and no cached example feed is available.',
      );
    }

    try {
      final items = await _loadRemoteWithRetry();
      await _localCache.write(items: items, cachedAt: now);
      return items;
    } on Object catch (error, stackTrace) {
      await _crashReportingService.recordError(
        error,
        stackTrace,
        context: <String, Object?>{
          'feature': 'example_feed',
          'force_refresh': forceRefresh,
        },
      );

      if (cached != null && _cachePolicy.allowStaleFallback) {
        return cached.items;
      }

      rethrow;
    }
  }

  Future<List<ExampleFeedItem>> _loadRemoteWithRetry() async {
    var attempt = 0;
    Object? lastError;
    StackTrace? lastStackTrace;

    while (attempt < _retryPolicy.maxAttempts) {
      attempt++;
      try {
        return await _remoteDataSource.fetchItems();
      } on Object catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;

        if (attempt >= _retryPolicy.maxAttempts) {
          break;
        }

        await Future<void>.delayed(_retryPolicy.delayForAttempt(attempt));
      }
    }

    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  }
}

@Riverpod(keepAlive: true)
ExampleFeedLocalCache exampleFeedLocalCache(Ref ref) {
  return ExampleFeedLocalCache(
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
}

@Riverpod(keepAlive: true)
ExampleFeedRepository exampleFeedRepository(Ref ref) {
  return ExampleFeedRepositoryImpl(
    remoteDataSource: ref.watch(exampleFeedRemoteDataSourceProvider),
    localCache: ref.watch(exampleFeedLocalCacheProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    crashReportingService: ref.watch(crashReportingServiceProvider),
    cachePolicy: ref.watch(defaultCachePolicyProvider),
    retryPolicy: ref.watch(defaultRetryPolicyProvider),
  );
}
