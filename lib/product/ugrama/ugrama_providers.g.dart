// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ugrama_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ugramaRepository)
const ugramaRepositoryProvider = UgramaRepositoryProvider._();

final class UgramaRepositoryProvider
    extends
        $FunctionalProvider<
          UgramaRepository,
          UgramaRepository,
          UgramaRepository
        >
    with $Provider<UgramaRepository> {
  const UgramaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ugramaRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ugramaRepositoryHash();

  @$internal
  @override
  $ProviderElement<UgramaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UgramaRepository create(Ref ref) {
    return ugramaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UgramaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UgramaRepository>(value),
    );
  }
}

String _$ugramaRepositoryHash() => r'f51754779c937ace757c3ee31c72c69ad3dfd7cf';

@ProviderFor(ugramaList)
const ugramaListProvider = UgramaListProvider._();

final class UgramaListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ugrama>>,
          List<Ugrama>,
          FutureOr<List<Ugrama>>
        >
    with $FutureModifier<List<Ugrama>>, $FutureProvider<List<Ugrama>> {
  const UgramaListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ugramaListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ugramaListHash();

  @$internal
  @override
  $FutureProviderElement<List<Ugrama>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Ugrama>> create(Ref ref) {
    return ugramaList(ref);
  }
}

String _$ugramaListHash() => r'5a84260933d9bf37c0a24873f7737c6a73de14e0';

@ProviderFor(ugramaListByMusteri)
const ugramaListByMusteriProvider = UgramaListByMusteriFamily._();

final class UgramaListByMusteriProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ugrama>>,
          List<Ugrama>,
          FutureOr<List<Ugrama>>
        >
    with $FutureModifier<List<Ugrama>>, $FutureProvider<List<Ugrama>> {
  const UgramaListByMusteriProvider._({
    required UgramaListByMusteriFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ugramaListByMusteriProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ugramaListByMusteriHash();

  @override
  String toString() {
    return r'ugramaListByMusteriProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Ugrama>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Ugrama>> create(Ref ref) {
    final argument = this.argument as String;
    return ugramaListByMusteri(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UgramaListByMusteriProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ugramaListByMusteriHash() =>
    r'8596029371aea5a97cfab34aae54ca1c5093ebe2';

final class UgramaListByMusteriFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Ugrama>>, String> {
  const UgramaListByMusteriFamily._()
    : super(
        retry: null,
        name: r'ugramaListByMusteriProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UgramaListByMusteriProvider call(String musteriId) =>
      UgramaListByMusteriProvider._(argument: musteriId, from: this);

  @override
  String toString() => r'ugramaListByMusteriProvider';
}
