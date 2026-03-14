// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'musteri_personel_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(musteriPersonelRepository)
const musteriPersonelRepositoryProvider = MusteriPersonelRepositoryProvider._();

final class MusteriPersonelRepositoryProvider
    extends
        $FunctionalProvider<
          MusteriPersonelRepository,
          MusteriPersonelRepository,
          MusteriPersonelRepository
        >
    with $Provider<MusteriPersonelRepository> {
  const MusteriPersonelRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musteriPersonelRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musteriPersonelRepositoryHash();

  @$internal
  @override
  $ProviderElement<MusteriPersonelRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusteriPersonelRepository create(Ref ref) {
    return musteriPersonelRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusteriPersonelRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusteriPersonelRepository>(value),
    );
  }
}

String _$musteriPersonelRepositoryHash() =>
    r'b0abfa092df1def11c2e2976a887d2cc671a9338';

@ProviderFor(musteriPersonelList)
const musteriPersonelListProvider = MusteriPersonelListProvider._();

final class MusteriPersonelListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MusteriPersonel>>,
          List<MusteriPersonel>,
          FutureOr<List<MusteriPersonel>>
        >
    with
        $FutureModifier<List<MusteriPersonel>>,
        $FutureProvider<List<MusteriPersonel>> {
  const MusteriPersonelListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musteriPersonelListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musteriPersonelListHash();

  @$internal
  @override
  $FutureProviderElement<List<MusteriPersonel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MusteriPersonel>> create(Ref ref) {
    return musteriPersonelList(ref);
  }
}

String _$musteriPersonelListHash() =>
    r'b81b827af93d7a0964969cb3ae06499bbbd36aef';

@ProviderFor(musteriPersonelListByMusteri)
const musteriPersonelListByMusteriProvider =
    MusteriPersonelListByMusteriFamily._();

final class MusteriPersonelListByMusteriProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MusteriPersonel>>,
          List<MusteriPersonel>,
          FutureOr<List<MusteriPersonel>>
        >
    with
        $FutureModifier<List<MusteriPersonel>>,
        $FutureProvider<List<MusteriPersonel>> {
  const MusteriPersonelListByMusteriProvider._({
    required MusteriPersonelListByMusteriFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'musteriPersonelListByMusteriProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$musteriPersonelListByMusteriHash();

  @override
  String toString() {
    return r'musteriPersonelListByMusteriProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MusteriPersonel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MusteriPersonel>> create(Ref ref) {
    final argument = this.argument as String;
    return musteriPersonelListByMusteri(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MusteriPersonelListByMusteriProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$musteriPersonelListByMusteriHash() =>
    r'7a2714562e6d8608b57c4274e8ca29db23769cbb';

final class MusteriPersonelListByMusteriFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MusteriPersonel>>, String> {
  const MusteriPersonelListByMusteriFamily._()
    : super(
        retry: null,
        name: r'musteriPersonelListByMusteriProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MusteriPersonelListByMusteriProvider call(String musteriId) =>
      MusteriPersonelListByMusteriProvider._(argument: musteriId, from: this);

  @override
  String toString() => r'musteriPersonelListByMusteriProvider';
}
