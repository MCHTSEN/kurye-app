// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_feed_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exampleFeedRemoteDataSource)
const exampleFeedRemoteDataSourceProvider =
    ExampleFeedRemoteDataSourceProvider._();

final class ExampleFeedRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ExampleFeedRemoteDataSource,
          ExampleFeedRemoteDataSource,
          ExampleFeedRemoteDataSource
        >
    with $Provider<ExampleFeedRemoteDataSource> {
  const ExampleFeedRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exampleFeedRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exampleFeedRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ExampleFeedRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExampleFeedRemoteDataSource create(Ref ref) {
    return exampleFeedRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExampleFeedRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExampleFeedRemoteDataSource>(value),
    );
  }
}

String _$exampleFeedRemoteDataSourceHash() =>
    r'91e20314987581ff2b122ed6c4ca6e14b225a8ad';
