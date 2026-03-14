// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfileRepository)
const userProfileRepositoryProvider = UserProfileRepositoryProvider._();

final class UserProfileRepositoryProvider
    extends
        $FunctionalProvider<
          UserProfileRepository,
          UserProfileRepository,
          UserProfileRepository
        >
    with $Provider<UserProfileRepository> {
  const UserProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProfileRepository create(Ref ref) {
    return userProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileRepository>(value),
    );
  }
}

String _$userProfileRepositoryHash() =>
    r'83c7237fb4165e2bb6fc31c2e2abc697ab464e0a';

/// Login olan kullanıcının profili.
/// Auth state değiştiğinde yeniden sorgulanır.

@ProviderFor(CurrentUserProfile)
const currentUserProfileProvider = CurrentUserProfileProvider._();

/// Login olan kullanıcının profili.
/// Auth state değiştiğinde yeniden sorgulanır.
final class CurrentUserProfileProvider
    extends $AsyncNotifierProvider<CurrentUserProfile, AppUserProfile?> {
  /// Login olan kullanıcının profili.
  /// Auth state değiştiğinde yeniden sorgulanır.
  const CurrentUserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserProfileHash();

  @$internal
  @override
  CurrentUserProfile create() => CurrentUserProfile();
}

String _$currentUserProfileHash() =>
    r'016e9e74311e77f28916a6a29ad4e248a9a1d442';

/// Login olan kullanıcının profili.
/// Auth state değiştiğinde yeniden sorgulanır.

abstract class _$CurrentUserProfile extends $AsyncNotifier<AppUserProfile?> {
  FutureOr<AppUserProfile?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AppUserProfile?>, AppUserProfile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppUserProfile?>, AppUserProfile?>,
              AsyncValue<AppUserProfile?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
