// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'musteri_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(musteriRepository)
const musteriRepositoryProvider = MusteriRepositoryProvider._();

final class MusteriRepositoryProvider
    extends
        $FunctionalProvider<
          MusteriRepository,
          MusteriRepository,
          MusteriRepository
        >
    with $Provider<MusteriRepository> {
  const MusteriRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musteriRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musteriRepositoryHash();

  @$internal
  @override
  $ProviderElement<MusteriRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusteriRepository create(Ref ref) {
    return musteriRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusteriRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusteriRepository>(value),
    );
  }
}

String _$musteriRepositoryHash() => r'c403300ad7a645b54858ea42b72cdf2bc0935bb3';

@ProviderFor(musteriList)
const musteriListProvider = MusteriListProvider._();

final class MusteriListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Musteri>>,
          List<Musteri>,
          FutureOr<List<Musteri>>
        >
    with $FutureModifier<List<Musteri>>, $FutureProvider<List<Musteri>> {
  const MusteriListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musteriListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musteriListHash();

  @$internal
  @override
  $FutureProviderElement<List<Musteri>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Musteri>> create(Ref ref) {
    return musteriList(ref);
  }
}

String _$musteriListHash() => r'e5500ab86a5af2f1a6e291c5dce6eae5425be4a0';
