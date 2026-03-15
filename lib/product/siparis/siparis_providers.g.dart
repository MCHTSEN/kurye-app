// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siparis_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(siparisRepository)
const siparisRepositoryProvider = SiparisRepositoryProvider._();

final class SiparisRepositoryProvider
    extends
        $FunctionalProvider<
          SiparisRepository,
          SiparisRepository,
          SiparisRepository
        >
    with $Provider<SiparisRepository> {
  const SiparisRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siparisRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siparisRepositoryHash();

  @$internal
  @override
  $ProviderElement<SiparisRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SiparisRepository create(Ref ref) {
    return siparisRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SiparisRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SiparisRepository>(value),
    );
  }
}

String _$siparisRepositoryHash() => r'47e60243ec1ef11e05f85fabc925defca80ba806';

@ProviderFor(siparisStreamByMusteri)
const siparisStreamByMusteriProvider = SiparisStreamByMusteriFamily._();

final class SiparisStreamByMusteriProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Siparis>>,
          List<Siparis>,
          Stream<List<Siparis>>
        >
    with $FutureModifier<List<Siparis>>, $StreamProvider<List<Siparis>> {
  const SiparisStreamByMusteriProvider._({
    required SiparisStreamByMusteriFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siparisStreamByMusteriProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siparisStreamByMusteriHash();

  @override
  String toString() {
    return r'siparisStreamByMusteriProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Siparis>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Siparis>> create(Ref ref) {
    final argument = this.argument as String;
    return siparisStreamByMusteri(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SiparisStreamByMusteriProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siparisStreamByMusteriHash() =>
    r'8697b07bb69674c76e3fe373105914fe371578c5';

final class SiparisStreamByMusteriFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Siparis>>, String> {
  const SiparisStreamByMusteriFamily._()
    : super(
        retry: null,
        name: r'siparisStreamByMusteriProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SiparisStreamByMusteriProvider call(String musteriId) =>
      SiparisStreamByMusteriProvider._(argument: musteriId, from: this);

  @override
  String toString() => r'siparisStreamByMusteriProvider';
}

@ProviderFor(siparisStreamActive)
const siparisStreamActiveProvider = SiparisStreamActiveProvider._();

final class SiparisStreamActiveProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Siparis>>,
          List<Siparis>,
          Stream<List<Siparis>>
        >
    with $FutureModifier<List<Siparis>>, $StreamProvider<List<Siparis>> {
  const SiparisStreamActiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siparisStreamActiveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siparisStreamActiveHash();

  @$internal
  @override
  $StreamProviderElement<List<Siparis>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Siparis>> create(Ref ref) {
    return siparisStreamActive(ref);
  }
}

String _$siparisStreamActiveHash() =>
    r'cabc7837ff1a1b3e98fdd9fdaa67b569642c8bae';

@ProviderFor(siparisStreamByKurye)
const siparisStreamByKuryeProvider = SiparisStreamByKuryeFamily._();

final class SiparisStreamByKuryeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Siparis>>,
          List<Siparis>,
          Stream<List<Siparis>>
        >
    with $FutureModifier<List<Siparis>>, $StreamProvider<List<Siparis>> {
  const SiparisStreamByKuryeProvider._({
    required SiparisStreamByKuryeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siparisStreamByKuryeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siparisStreamByKuryeHash();

  @override
  String toString() {
    return r'siparisStreamByKuryeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Siparis>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Siparis>> create(Ref ref) {
    final argument = this.argument as String;
    return siparisStreamByKurye(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SiparisStreamByKuryeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siparisStreamByKuryeHash() =>
    r'f269a0ccc284454d39e68ca390f05f25ece404d9';

final class SiparisStreamByKuryeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Siparis>>, String> {
  const SiparisStreamByKuryeFamily._()
    : super(
        retry: null,
        name: r'siparisStreamByKuryeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SiparisStreamByKuryeProvider call(String kuryeId) =>
      SiparisStreamByKuryeProvider._(argument: kuryeId, from: this);

  @override
  String toString() => r'siparisStreamByKuryeProvider';
}

@ProviderFor(siparisListByMusteri)
const siparisListByMusteriProvider = SiparisListByMusteriFamily._();

final class SiparisListByMusteriProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Siparis>>,
          List<Siparis>,
          FutureOr<List<Siparis>>
        >
    with $FutureModifier<List<Siparis>>, $FutureProvider<List<Siparis>> {
  const SiparisListByMusteriProvider._({
    required SiparisListByMusteriFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siparisListByMusteriProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siparisListByMusteriHash();

  @override
  String toString() {
    return r'siparisListByMusteriProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Siparis>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Siparis>> create(Ref ref) {
    final argument = this.argument as String;
    return siparisListByMusteri(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SiparisListByMusteriProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siparisListByMusteriHash() =>
    r'3da6b65dd897f415efae576a8bd6c502244919b7';

final class SiparisListByMusteriFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Siparis>>, String> {
  const SiparisListByMusteriFamily._()
    : super(
        retry: null,
        name: r'siparisListByMusteriProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SiparisListByMusteriProvider call(String musteriId) =>
      SiparisListByMusteriProvider._(argument: musteriId, from: this);

  @override
  String toString() => r'siparisListByMusteriProvider';
}
