// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_access_snapshot.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appAccessSnapshot)
const appAccessSnapshotProvider = AppAccessSnapshotProvider._();

final class AppAccessSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppAccessSnapshot>,
          AppAccessSnapshot,
          FutureOr<AppAccessSnapshot>
        >
    with
        $FutureModifier<AppAccessSnapshot>,
        $FutureProvider<AppAccessSnapshot> {
  const AppAccessSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appAccessSnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appAccessSnapshotHash();

  @$internal
  @override
  $FutureProviderElement<AppAccessSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppAccessSnapshot> create(Ref ref) {
    return appAccessSnapshot(ref);
  }
}

String _$appAccessSnapshotHash() => r'ffabfd8182d793812e8dd107ad40d27412eab488';
