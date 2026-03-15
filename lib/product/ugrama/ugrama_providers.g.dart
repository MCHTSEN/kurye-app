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

@ProviderFor(musteriUgramaRepository)
const musteriUgramaRepositoryProvider = MusteriUgramaRepositoryProvider._();

final class MusteriUgramaRepositoryProvider
    extends
        $FunctionalProvider<
          MusteriUgramaRepository,
          MusteriUgramaRepository,
          MusteriUgramaRepository
        >
    with $Provider<MusteriUgramaRepository> {
  const MusteriUgramaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musteriUgramaRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musteriUgramaRepositoryHash();

  @$internal
  @override
  $ProviderElement<MusteriUgramaRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusteriUgramaRepository create(Ref ref) {
    return musteriUgramaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusteriUgramaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusteriUgramaRepository>(value),
    );
  }
}

String _$musteriUgramaRepositoryHash() =>
    r'74750b2bd7c7e6c84ff7aa0f69c165bd4689fc4f';

@ProviderFor(ugramaTalebiRepository)
const ugramaTalebiRepositoryProvider = UgramaTalebiRepositoryProvider._();

final class UgramaTalebiRepositoryProvider
    extends
        $FunctionalProvider<
          UgramaTalebiRepository,
          UgramaTalebiRepository,
          UgramaTalebiRepository
        >
    with $Provider<UgramaTalebiRepository> {
  const UgramaTalebiRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ugramaTalebiRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ugramaTalebiRepositoryHash();

  @$internal
  @override
  $ProviderElement<UgramaTalebiRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UgramaTalebiRepository create(Ref ref) {
    return ugramaTalebiRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UgramaTalebiRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UgramaTalebiRepository>(value),
    );
  }
}

String _$ugramaTalebiRepositoryHash() =>
    r'16203880b703ae585ad02b7e346ca1cebd05d11b';

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

/// Müşteriye atanmış uğramaları köprü tablosu üzerinden getirir.

@ProviderFor(ugramaListByMusteri)
const ugramaListByMusteriProvider = UgramaListByMusteriFamily._();

/// Müşteriye atanmış uğramaları köprü tablosu üzerinden getirir.

final class UgramaListByMusteriProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ugrama>>,
          List<Ugrama>,
          FutureOr<List<Ugrama>>
        >
    with $FutureModifier<List<Ugrama>>, $FutureProvider<List<Ugrama>> {
  /// Müşteriye atanmış uğramaları köprü tablosu üzerinden getirir.
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
    r'a54bdecf9aabe9fee24265a3e530333115819197';

/// Müşteriye atanmış uğramaları köprü tablosu üzerinden getirir.

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

  /// Müşteriye atanmış uğramaları köprü tablosu üzerinden getirir.

  UgramaListByMusteriProvider call(String musteriId) =>
      UgramaListByMusteriProvider._(argument: musteriId, from: this);

  @override
  String toString() => r'ugramaListByMusteriProvider';
}

/// Bir uğramaya atanmış müşteri ID'lerini getirir.

@ProviderFor(musteriIdsByUgrama)
const musteriIdsByUgramaProvider = MusteriIdsByUgramaFamily._();

/// Bir uğramaya atanmış müşteri ID'lerini getirir.

final class MusteriIdsByUgramaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Bir uğramaya atanmış müşteri ID'lerini getirir.
  const MusteriIdsByUgramaProvider._({
    required MusteriIdsByUgramaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'musteriIdsByUgramaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$musteriIdsByUgramaHash();

  @override
  String toString() {
    return r'musteriIdsByUgramaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return musteriIdsByUgrama(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MusteriIdsByUgramaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$musteriIdsByUgramaHash() =>
    r'd0ac68994824704334b1132bee2bf93d029ab555';

/// Bir uğramaya atanmış müşteri ID'lerini getirir.

final class MusteriIdsByUgramaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  const MusteriIdsByUgramaFamily._()
    : super(
        retry: null,
        name: r'musteriIdsByUgramaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Bir uğramaya atanmış müşteri ID'lerini getirir.

  MusteriIdsByUgramaProvider call(String ugramaId) =>
      MusteriIdsByUgramaProvider._(argument: ugramaId, from: this);

  @override
  String toString() => r'musteriIdsByUgramaProvider';
}

/// Bekleyen uğrama taleplerini getirir (operasyon).

@ProviderFor(bekleyenTalepler)
const bekleyenTaleplerProvider = BekleyenTaleplerProvider._();

/// Bekleyen uğrama taleplerini getirir (operasyon).

final class BekleyenTaleplerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UgramaTalebi>>,
          List<UgramaTalebi>,
          FutureOr<List<UgramaTalebi>>
        >
    with
        $FutureModifier<List<UgramaTalebi>>,
        $FutureProvider<List<UgramaTalebi>> {
  /// Bekleyen uğrama taleplerini getirir (operasyon).
  const BekleyenTaleplerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bekleyenTaleplerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bekleyenTaleplerHash();

  @$internal
  @override
  $FutureProviderElement<List<UgramaTalebi>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UgramaTalebi>> create(Ref ref) {
    return bekleyenTalepler(ref);
  }
}

String _$bekleyenTaleplerHash() => r'dbc0db0aef86343aa91b70f47fe8dddf98c46d3e';

/// Bir müşterinin uğrama taleplerini getirir.

@ProviderFor(taleplerByMusteri)
const taleplerByMusteriProvider = TaleplerByMusteriFamily._();

/// Bir müşterinin uğrama taleplerini getirir.

final class TaleplerByMusteriProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UgramaTalebi>>,
          List<UgramaTalebi>,
          FutureOr<List<UgramaTalebi>>
        >
    with
        $FutureModifier<List<UgramaTalebi>>,
        $FutureProvider<List<UgramaTalebi>> {
  /// Bir müşterinin uğrama taleplerini getirir.
  const TaleplerByMusteriProvider._({
    required TaleplerByMusteriFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taleplerByMusteriProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taleplerByMusteriHash();

  @override
  String toString() {
    return r'taleplerByMusteriProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UgramaTalebi>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UgramaTalebi>> create(Ref ref) {
    final argument = this.argument as String;
    return taleplerByMusteri(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaleplerByMusteriProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taleplerByMusteriHash() => r'8db5be6ab5e4e1d95a0cc8d99f9a853173fa5d3c';

/// Bir müşterinin uğrama taleplerini getirir.

final class TaleplerByMusteriFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UgramaTalebi>>, String> {
  const TaleplerByMusteriFamily._()
    : super(
        retry: null,
        name: r'taleplerByMusteriProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Bir müşterinin uğrama taleplerini getirir.

  TaleplerByMusteriProvider call(String musteriId) =>
      TaleplerByMusteriProvider._(argument: musteriId, from: this);

  @override
  String toString() => r'taleplerByMusteriProvider';
}
