// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurye_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kuryeRepository)
const kuryeRepositoryProvider = KuryeRepositoryProvider._();

final class KuryeRepositoryProvider
    extends
        $FunctionalProvider<KuryeRepository, KuryeRepository, KuryeRepository>
    with $Provider<KuryeRepository> {
  const KuryeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kuryeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kuryeRepositoryHash();

  @$internal
  @override
  $ProviderElement<KuryeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KuryeRepository create(Ref ref) {
    return kuryeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KuryeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KuryeRepository>(value),
    );
  }
}

String _$kuryeRepositoryHash() => r'b09764f61d6992468c091ec52ef757b9118147bf';

@ProviderFor(kuryeList)
const kuryeListProvider = KuryeListProvider._();

final class KuryeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Kurye>>,
          List<Kurye>,
          FutureOr<List<Kurye>>
        >
    with $FutureModifier<List<Kurye>>, $FutureProvider<List<Kurye>> {
  const KuryeListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kuryeListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kuryeListHash();

  @$internal
  @override
  $FutureProviderElement<List<Kurye>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Kurye>> create(Ref ref) {
    return kuryeList(ref);
  }
}

String _$kuryeListHash() => r'1586056e19d1c46792dca6fe61c59f7144efbcdb';

/// Giriş yapan kullanıcının kurye kaydını auth UID ile çözer.
/// Null dönerse kullanıcı kuryeler tablosunda bulunamadı demektir.

@ProviderFor(currentKurye)
const currentKuryeProvider = CurrentKuryeProvider._();

/// Giriş yapan kullanıcının kurye kaydını auth UID ile çözer.
/// Null dönerse kullanıcı kuryeler tablosunda bulunamadı demektir.

final class CurrentKuryeProvider
    extends $FunctionalProvider<AsyncValue<Kurye?>, Kurye?, FutureOr<Kurye?>>
    with $FutureModifier<Kurye?>, $FutureProvider<Kurye?> {
  /// Giriş yapan kullanıcının kurye kaydını auth UID ile çözer.
  /// Null dönerse kullanıcı kuryeler tablosunda bulunamadı demektir.
  const CurrentKuryeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentKuryeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentKuryeHash();

  @$internal
  @override
  $FutureProviderElement<Kurye?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Kurye?> create(Ref ref) {
    return currentKurye(ref);
  }
}

String _$currentKuryeHash() => r'0d60ec2c6b90353669586ab6c703e3cb9eb94592';
