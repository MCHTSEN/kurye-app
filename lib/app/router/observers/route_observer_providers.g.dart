// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_observer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appNavigatorObserversBuilder)
const appNavigatorObserversBuilderProvider =
    AppNavigatorObserversBuilderProvider._();

final class AppNavigatorObserversBuilderProvider
    extends
        $FunctionalProvider<
          NavigatorObserversBuilder,
          NavigatorObserversBuilder,
          NavigatorObserversBuilder
        >
    with $Provider<NavigatorObserversBuilder> {
  const AppNavigatorObserversBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appNavigatorObserversBuilderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appNavigatorObserversBuilderHash();

  @$internal
  @override
  $ProviderElement<NavigatorObserversBuilder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NavigatorObserversBuilder create(Ref ref) {
    return appNavigatorObserversBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigatorObserversBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigatorObserversBuilder>(value),
    );
  }
}

String _$appNavigatorObserversBuilderHash() =>
    r'84ee73e6b8f0cafae034c03d0992a962191ef6ed';
