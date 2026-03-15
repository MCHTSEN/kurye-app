// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siparis_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(siparisLogRepository)
const siparisLogRepositoryProvider = SiparisLogRepositoryProvider._();

final class SiparisLogRepositoryProvider
    extends
        $FunctionalProvider<
          SiparisLogRepository,
          SiparisLogRepository,
          SiparisLogRepository
        >
    with $Provider<SiparisLogRepository> {
  const SiparisLogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siparisLogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siparisLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<SiparisLogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SiparisLogRepository create(Ref ref) {
    return siparisLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SiparisLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SiparisLogRepository>(value),
    );
  }
}

String _$siparisLogRepositoryHash() =>
    r'cd8da8f3f96085b466a57a10120bd7b243995535';
