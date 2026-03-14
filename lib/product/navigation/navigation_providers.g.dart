// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appNavigationState)
const appNavigationStateProvider = AppNavigationStateProvider._();

final class AppNavigationStateProvider
    extends
        $FunctionalProvider<
          AppNavigationState,
          AppNavigationState,
          AppNavigationState
        >
    with $Provider<AppNavigationState> {
  const AppNavigationStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appNavigationStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appNavigationStateHash();

  @$internal
  @override
  $ProviderElement<AppNavigationState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppNavigationState create(Ref ref) {
    return appNavigationState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppNavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppNavigationState>(value),
    );
  }
}

String _$appNavigationStateHash() =>
    r'69ec8ed18311522fd23a5e9a0521acc2884ba01e';

@ProviderFor(appRouteReevaluationNotifier)
const appRouteReevaluationProvider = AppRouteReevaluationNotifierProvider._();

final class AppRouteReevaluationNotifierProvider
    extends
        $FunctionalProvider<
          RouteReevaluationNotifier,
          RouteReevaluationNotifier,
          RouteReevaluationNotifier
        >
    with $Provider<RouteReevaluationNotifier> {
  const AppRouteReevaluationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouteReevaluationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouteReevaluationNotifierHash();

  @$internal
  @override
  $ProviderElement<RouteReevaluationNotifier> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RouteReevaluationNotifier create(Ref ref) {
    return appRouteReevaluationNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteReevaluationNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteReevaluationNotifier>(value),
    );
  }
}

String _$appRouteReevaluationNotifierHash() =>
    r'7ffb431315caed873285548813809275686caee3';
