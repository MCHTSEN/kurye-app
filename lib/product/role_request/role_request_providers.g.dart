// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(roleRequestRepository)
const roleRequestRepositoryProvider = RoleRequestRepositoryProvider._();

final class RoleRequestRepositoryProvider
    extends
        $FunctionalProvider<
          RoleRequestRepository,
          RoleRequestRepository,
          RoleRequestRepository
        >
    with $Provider<RoleRequestRepository> {
  const RoleRequestRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roleRequestRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roleRequestRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoleRequestRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoleRequestRepository create(Ref ref) {
    return roleRequestRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoleRequestRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoleRequestRepository>(value),
    );
  }
}

String _$roleRequestRepositoryHash() =>
    r'd357ed6a50a9db70b22f33c3367a7997495b50c2';

/// Kullanıcının en son rol talebini dinler.

@ProviderFor(MyRoleRequest)
const myRoleRequestProvider = MyRoleRequestProvider._();

/// Kullanıcının en son rol talebini dinler.
final class MyRoleRequestProvider
    extends $AsyncNotifierProvider<MyRoleRequest, RoleRequest?> {
  /// Kullanıcının en son rol talebini dinler.
  const MyRoleRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myRoleRequestProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myRoleRequestHash();

  @$internal
  @override
  MyRoleRequest create() => MyRoleRequest();
}

String _$myRoleRequestHash() => r'04b8351668be09b985b31f2e055436b9f11d7eb3';

/// Kullanıcının en son rol talebini dinler.

abstract class _$MyRoleRequest extends $AsyncNotifier<RoleRequest?> {
  FutureOr<RoleRequest?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<RoleRequest?>, RoleRequest?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RoleRequest?>, RoleRequest?>,
              AsyncValue<RoleRequest?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Beklemedeki tüm talepler (operasyon ekranı için).
/// Uses one-shot fetch instead of realtime stream because Supabase Realtime
/// streams evaluate RLS with limited auth context, causing empty results
/// for custom `get_my_role()` policies.

@ProviderFor(pendingRoleRequests)
const pendingRoleRequestsProvider = PendingRoleRequestsProvider._();

/// Beklemedeki tüm talepler (operasyon ekranı için).
/// Uses one-shot fetch instead of realtime stream because Supabase Realtime
/// streams evaluate RLS with limited auth context, causing empty results
/// for custom `get_my_role()` policies.

final class PendingRoleRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RoleRequest>>,
          List<RoleRequest>,
          FutureOr<List<RoleRequest>>
        >
    with
        $FutureModifier<List<RoleRequest>>,
        $FutureProvider<List<RoleRequest>> {
  /// Beklemedeki tüm talepler (operasyon ekranı için).
  /// Uses one-shot fetch instead of realtime stream because Supabase Realtime
  /// streams evaluate RLS with limited auth context, causing empty results
  /// for custom `get_my_role()` policies.
  const PendingRoleRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRoleRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRoleRequestsHash();

  @$internal
  @override
  $FutureProviderElement<List<RoleRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RoleRequest>> create(Ref ref) {
    return pendingRoleRequests(ref);
  }
}

String _$pendingRoleRequestsHash() =>
    r'54cc15727ff5bfc63aee953d475e22e5049dc579';
