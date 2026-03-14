// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backendModule)
const backendModuleProvider = BackendModuleProvider._();

final class BackendModuleProvider
    extends $FunctionalProvider<BackendModule, BackendModule, BackendModule>
    with $Provider<BackendModule> {
  const BackendModuleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backendModuleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backendModuleHash();

  @$internal
  @override
  $ProviderElement<BackendModule> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackendModule create(Ref ref) {
    return backendModule(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackendModule value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackendModule>(value),
    );
  }
}

String _$backendModuleHash() => r'5e2f2186082437b1e2ffd857dea2ddc34f0f24d6';

@ProviderFor(authGateway)
const authGatewayProvider = AuthGatewayProvider._();

final class AuthGatewayProvider
    extends $FunctionalProvider<AuthGateway, AuthGateway, AuthGateway>
    with $Provider<AuthGateway> {
  const AuthGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authGatewayHash();

  @$internal
  @override
  $ProviderElement<AuthGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthGateway create(Ref ref) {
    return authGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthGateway>(value),
    );
  }
}

String _$authGatewayHash() => r'9ecb28931cda47dac67592cba2ac14333eecb26d';

@ProviderFor(tokenRefreshService)
const tokenRefreshServiceProvider = TokenRefreshServiceProvider._();

final class TokenRefreshServiceProvider
    extends
        $FunctionalProvider<
          TokenRefreshService,
          TokenRefreshService,
          TokenRefreshService
        >
    with $Provider<TokenRefreshService> {
  const TokenRefreshServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenRefreshServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenRefreshServiceHash();

  @$internal
  @override
  $ProviderElement<TokenRefreshService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TokenRefreshService create(Ref ref) {
    return tokenRefreshService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenRefreshService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenRefreshService>(value),
    );
  }
}

String _$tokenRefreshServiceHash() =>
    r'f07ac64427813d9369e54331b43f9170ea212fed';

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'6293e1921d2c637ffe3cc058347f60160f4f7a75';

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

final class AuthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthSession?>,
          AuthSession?,
          Stream<AuthSession?>
        >
    with $FutureModifier<AuthSession?>, $StreamProvider<AuthSession?> {
  const AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthSession?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AuthSession?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'a9023478f7fec752d3dc047adbc4e95a3a3602f0';

@ProviderFor(supportedSocialLogins)
const supportedSocialLoginsProvider = SupportedSocialLoginsProvider._();

final class SupportedSocialLoginsProvider
    extends
        $FunctionalProvider<
          Set<SocialLoginMethod>,
          Set<SocialLoginMethod>,
          Set<SocialLoginMethod>
        >
    with $Provider<Set<SocialLoginMethod>> {
  const SupportedSocialLoginsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportedSocialLoginsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportedSocialLoginsHash();

  @$internal
  @override
  $ProviderElement<Set<SocialLoginMethod>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Set<SocialLoginMethod> create(Ref ref) {
    return supportedSocialLogins(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<SocialLoginMethod> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<SocialLoginMethod>>(value),
    );
  }
}

String _$supportedSocialLoginsHash() =>
    r'95199e5b5e8770c837096457a7e978c09291ca63';
