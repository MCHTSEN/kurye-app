// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(revenueCatCreditAvailabilityChecker)
const revenueCatCreditAvailabilityCheckerProvider =
    RevenueCatCreditAvailabilityCheckerProvider._();

final class RevenueCatCreditAvailabilityCheckerProvider
    extends
        $FunctionalProvider<
          CreditAvailabilityChecker,
          CreditAvailabilityChecker,
          CreditAvailabilityChecker
        >
    with $Provider<CreditAvailabilityChecker> {
  const RevenueCatCreditAvailabilityCheckerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revenueCatCreditAvailabilityCheckerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$revenueCatCreditAvailabilityCheckerHash();

  @$internal
  @override
  $ProviderElement<CreditAvailabilityChecker> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreditAvailabilityChecker create(Ref ref) {
    return revenueCatCreditAvailabilityChecker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditAvailabilityChecker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditAvailabilityChecker>(value),
    );
  }
}

String _$revenueCatCreditAvailabilityCheckerHash() =>
    r'f916d0b7a4fc58428940befb2dbf1dc6dfa49f82';

@ProviderFor(creditAccessService)
const creditAccessServiceProvider = CreditAccessServiceProvider._();

final class CreditAccessServiceProvider
    extends
        $FunctionalProvider<
          CreditAccessService,
          CreditAccessService,
          CreditAccessService
        >
    with $Provider<CreditAccessService> {
  const CreditAccessServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditAccessServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditAccessServiceHash();

  @$internal
  @override
  $ProviderElement<CreditAccessService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreditAccessService create(Ref ref) {
    return creditAccessService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditAccessService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditAccessService>(value),
    );
  }
}

String _$creditAccessServiceHash() =>
    r'0876d82d5e58b5b825a79c5ac9f7504fd88d3335';

@ProviderFor(isNetworkCreditSignalEnabled)
const isNetworkCreditSignalEnabledProvider =
    IsNetworkCreditSignalEnabledProvider._();

final class IsNetworkCreditSignalEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const IsNetworkCreditSignalEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isNetworkCreditSignalEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isNetworkCreditSignalEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isNetworkCreditSignalEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isNetworkCreditSignalEnabledHash() =>
    r'bccfde0b69aa50ce1779eec97ccc1ce0405b19da';
