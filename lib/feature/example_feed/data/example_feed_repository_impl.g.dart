// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_feed_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exampleFeedLocalCache)
const exampleFeedLocalCacheProvider = ExampleFeedLocalCacheProvider._();

final class ExampleFeedLocalCacheProvider
    extends
        $FunctionalProvider<
          ExampleFeedLocalCache,
          ExampleFeedLocalCache,
          ExampleFeedLocalCache
        >
    with $Provider<ExampleFeedLocalCache> {
  const ExampleFeedLocalCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exampleFeedLocalCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exampleFeedLocalCacheHash();

  @$internal
  @override
  $ProviderElement<ExampleFeedLocalCache> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExampleFeedLocalCache create(Ref ref) {
    return exampleFeedLocalCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExampleFeedLocalCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExampleFeedLocalCache>(value),
    );
  }
}

String _$exampleFeedLocalCacheHash() =>
    r'34723e44426be52e08fcc8baea72d7317e2d3de8';

@ProviderFor(exampleFeedRepository)
const exampleFeedRepositoryProvider = ExampleFeedRepositoryProvider._();

final class ExampleFeedRepositoryProvider
    extends
        $FunctionalProvider<
          ExampleFeedRepository,
          ExampleFeedRepository,
          ExampleFeedRepository
        >
    with $Provider<ExampleFeedRepository> {
  const ExampleFeedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exampleFeedRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exampleFeedRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExampleFeedRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExampleFeedRepository create(Ref ref) {
    return exampleFeedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExampleFeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExampleFeedRepository>(value),
    );
  }
}

String _$exampleFeedRepositoryHash() =>
    r'c7cc1b5db8bb4a7c22fdc7f409f219c0efd24dae';
