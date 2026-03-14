// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appRouter)
const appRouterProvider = AppRouterProvider._();

final class AppRouterProvider
    extends
        $FunctionalProvider<RootStackRouter, RootStackRouter, RootStackRouter>
    with $Provider<RootStackRouter> {
  const AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<RootStackRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RootStackRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RootStackRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RootStackRouter>(value),
    );
  }
}

String _$appRouterHash() => r'7bd4f04adcc0d088ca43ebec4aa2ef4225050950';
