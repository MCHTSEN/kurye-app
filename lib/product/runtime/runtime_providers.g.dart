// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runtime_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureStorageService)
const secureStorageServiceProvider = SecureStorageServiceProvider._();

final class SecureStorageServiceProvider
    extends
        $FunctionalProvider<
          SecureStorageService,
          SecureStorageService,
          SecureStorageService
        >
    with $Provider<SecureStorageService> {
  const SecureStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageServiceHash();

  @$internal
  @override
  $ProviderElement<SecureStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureStorageService create(Ref ref) {
    return secureStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureStorageService>(value),
    );
  }
}

String _$secureStorageServiceHash() =>
    r'6694450d2c5a9bc6ebc5b9798ff0a3f961790095';

@ProviderFor(connectivityService)
const connectivityServiceProvider = ConnectivityServiceProvider._();

final class ConnectivityServiceProvider
    extends
        $FunctionalProvider<
          ConnectivityService,
          ConnectivityService,
          ConnectivityService
        >
    with $Provider<ConnectivityService> {
  const ConnectivityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceHash();

  @$internal
  @override
  $ProviderElement<ConnectivityService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectivityService create(Ref ref) {
    return connectivityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityService>(value),
    );
  }
}

String _$connectivityServiceHash() =>
    r'4b07b8d9fa3859e1b7e4e1ebc1ad06141d44c8be';

@ProviderFor(featureFlagService)
const featureFlagServiceProvider = FeatureFlagServiceProvider._();

final class FeatureFlagServiceProvider
    extends
        $FunctionalProvider<
          FeatureFlagService,
          FeatureFlagService,
          FeatureFlagService
        >
    with $Provider<FeatureFlagService> {
  const FeatureFlagServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featureFlagServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featureFlagServiceHash();

  @$internal
  @override
  $ProviderElement<FeatureFlagService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeatureFlagService create(Ref ref) {
    return featureFlagService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeatureFlagService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeatureFlagService>(value),
    );
  }
}

String _$featureFlagServiceHash() =>
    r'eb3e99042015ad8592d2beea9b015b3829a64c25';

@ProviderFor(crashReportingService)
const crashReportingServiceProvider = CrashReportingServiceProvider._();

final class CrashReportingServiceProvider
    extends
        $FunctionalProvider<
          CrashReportingService,
          CrashReportingService,
          CrashReportingService
        >
    with $Provider<CrashReportingService> {
  const CrashReportingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashReportingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashReportingServiceHash();

  @$internal
  @override
  $ProviderElement<CrashReportingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CrashReportingService create(Ref ref) {
    return crashReportingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrashReportingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrashReportingService>(value),
    );
  }
}

String _$crashReportingServiceHash() =>
    r'2ec5e1aaf0303116a9b2c7ce564a9a9242aed805';

@ProviderFor(permissionService)
const permissionServiceProvider = PermissionServiceProvider._();

final class PermissionServiceProvider
    extends
        $FunctionalProvider<
          PermissionService,
          PermissionService,
          PermissionService
        >
    with $Provider<PermissionService> {
  const PermissionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionServiceHash();

  @$internal
  @override
  $ProviderElement<PermissionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionService create(Ref ref) {
    return permissionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionService>(value),
    );
  }
}

String _$permissionServiceHash() => r'06bebf1c1dec8725c8d3e6f039d562226c96b412';

@ProviderFor(defaultCachePolicy)
const defaultCachePolicyProvider = DefaultCachePolicyProvider._();

final class DefaultCachePolicyProvider
    extends $FunctionalProvider<CachePolicy, CachePolicy, CachePolicy>
    with $Provider<CachePolicy> {
  const DefaultCachePolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultCachePolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultCachePolicyHash();

  @$internal
  @override
  $ProviderElement<CachePolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CachePolicy create(Ref ref) {
    return defaultCachePolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CachePolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CachePolicy>(value),
    );
  }
}

String _$defaultCachePolicyHash() =>
    r'5776699d39850a8defc3bbbefd3f27798747530e';

@ProviderFor(defaultRetryPolicy)
const defaultRetryPolicyProvider = DefaultRetryPolicyProvider._();

final class DefaultRetryPolicyProvider
    extends $FunctionalProvider<RetryPolicy, RetryPolicy, RetryPolicy>
    with $Provider<RetryPolicy> {
  const DefaultRetryPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultRetryPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultRetryPolicyHash();

  @$internal
  @override
  $ProviderElement<RetryPolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RetryPolicy create(Ref ref) {
    return defaultRetryPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RetryPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RetryPolicy>(value),
    );
  }
}

String _$defaultRetryPolicyHash() =>
    r'2b8c5eca3ccea16feee85ea89a08c96fa6b50996';
