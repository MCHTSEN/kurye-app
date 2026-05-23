// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationService)
const notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  const NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'445de4d12e27916d07943435c5c5a66cb7fc0205';

/// Backend'den FCM token repository sağlar — backend desteklemiyorsa null.

@ProviderFor(pushTokenRepository)
const pushTokenRepositoryProvider = PushTokenRepositoryProvider._();

/// Backend'den FCM token repository sağlar — backend desteklemiyorsa null.

final class PushTokenRepositoryProvider
    extends
        $FunctionalProvider<
          PushTokenRepository?,
          PushTokenRepository?,
          PushTokenRepository?
        >
    with $Provider<PushTokenRepository?> {
  /// Backend'den FCM token repository sağlar — backend desteklemiyorsa null.
  const PushTokenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushTokenRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushTokenRepositoryHash();

  @$internal
  @override
  $ProviderElement<PushTokenRepository?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushTokenRepository? create(Ref ref) {
    return pushTokenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushTokenRepository? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushTokenRepository?>(value),
    );
  }
}

String _$pushTokenRepositoryHash() =>
    r'5b46572ba6f64f3aa3fbff7dc7b4a655d788e4af';

/// Push notification (FCM) servisi — sadece supabase backend'de aktif.
/// Bootstrap sonrası ilk `read` çağrısında lazy oluşturulur; `init()` ayrıca
/// çağrılmalı (bootstrap'te yapılıyor).

@ProviderFor(pushNotificationService)
const pushNotificationServiceProvider = PushNotificationServiceProvider._();

/// Push notification (FCM) servisi — sadece supabase backend'de aktif.
/// Bootstrap sonrası ilk `read` çağrısında lazy oluşturulur; `init()` ayrıca
/// çağrılmalı (bootstrap'te yapılıyor).

final class PushNotificationServiceProvider
    extends
        $FunctionalProvider<
          PushNotificationService?,
          PushNotificationService?,
          PushNotificationService?
        >
    with $Provider<PushNotificationService?> {
  /// Push notification (FCM) servisi — sadece supabase backend'de aktif.
  /// Bootstrap sonrası ilk `read` çağrısında lazy oluşturulur; `init()` ayrıca
  /// çağrılmalı (bootstrap'te yapılıyor).
  const PushNotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushNotificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<PushNotificationService?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushNotificationService? create(Ref ref) {
    return pushNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushNotificationService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushNotificationService?>(value),
    );
  }
}

String _$pushNotificationServiceHash() =>
    r'82fa38bf0b387b833bdc7b700e0f7aa582a8e3b7';
