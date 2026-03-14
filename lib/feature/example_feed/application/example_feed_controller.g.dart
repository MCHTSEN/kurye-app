// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_feed_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExampleFeedController)
const exampleFeedControllerProvider = ExampleFeedControllerProvider._();

final class ExampleFeedControllerProvider
    extends
        $AsyncNotifierProvider<ExampleFeedController, List<ExampleFeedItem>> {
  const ExampleFeedControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exampleFeedControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exampleFeedControllerHash();

  @$internal
  @override
  ExampleFeedController create() => ExampleFeedController();
}

String _$exampleFeedControllerHash() =>
    r'd13eeaf007969ac44b5c5d68addae01bc5c41419';

abstract class _$ExampleFeedController
    extends $AsyncNotifier<List<ExampleFeedItem>> {
  FutureOr<List<ExampleFeedItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ExampleFeedItem>>, List<ExampleFeedItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ExampleFeedItem>>,
                List<ExampleFeedItem>
              >,
              AsyncValue<List<ExampleFeedItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
