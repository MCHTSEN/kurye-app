import 'package:backend_core/backend_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';
import '../onboarding/onboarding_providers.dart';
import '../role_request/role_request_providers.dart';
import '../user_profile/user_profile_providers.dart';

part 'app_access_snapshot.g.dart';

final _log = AppLogger('AppAccessSnapshot', tag: LogTag.router);

class AppAccessSnapshot {
  const AppAccessSnapshot({
    required this.onboardingCompleted,
    required this.session,
    required this.profile,
    required this.hasPendingRoleRequest,
    required this.timings,
  });

  final bool onboardingCompleted;
  final AuthSession? session;
  final AppUserProfile? profile;
  final bool hasPendingRoleRequest;
  final AppAccessSnapshotTimings timings;
}

class AppAccessSnapshotTimings {
  const AppAccessSnapshotTimings({
    required this.onboarding,
    required this.session,
    required this.profile,
    required this.pendingRoleRequest,
    required this.total,
  });

  final Duration onboarding;
  final Duration session;
  final Duration profile;
  final Duration pendingRoleRequest;
  final Duration total;

  String toLogFields() {
    return 'snapshot_total=${total.inMilliseconds}ms '
        'onboarding=${onboarding.inMilliseconds}ms '
        'session=${session.inMilliseconds}ms '
        'profile=${profile.inMilliseconds}ms '
        'pending_role=${pendingRoleRequest.inMilliseconds}ms';
  }
}

class _AppAccessTimingBuilder {
  final _total = Stopwatch()..start();
  Duration onboarding = Duration.zero;
  Duration session = Duration.zero;
  Duration profile = Duration.zero;
  Duration pendingRoleRequest = Duration.zero;

  Future<T> measure<T>(
    Future<T> Function() action,
    void Function(Duration elapsed) record,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      record(stopwatch.elapsed);
    }
  }

  AppAccessSnapshotTimings finish() {
    _total.stop();
    return AppAccessSnapshotTimings(
      onboarding: onboarding,
      session: session,
      profile: profile,
      pendingRoleRequest: pendingRoleRequest,
      total: _total.elapsed,
    );
  }
}

@Riverpod(keepAlive: true)
Future<AppAccessSnapshot> appAccessSnapshot(Ref ref) async {
  final timings = _AppAccessTimingBuilder();

  final onboardingCompleted = await timings.measure(
    () => ref.read(onboardingRepositoryProvider).isCompleted(),
    (elapsed) => timings.onboarding = elapsed,
  );
  final session = await timings.measure(
    () => ref.read(authRepositoryProvider).currentSession(),
    (elapsed) => timings.session = elapsed,
  );

  AppUserProfile? profile;
  var hasPendingRoleRequest = false;

  if (session != null) {
    profile = await timings.measure(
      () async {
        try {
          return await ref
              .read(userProfileRepositoryProvider)
              .getProfile(session.user.id);
        } on Object catch (error, stackTrace) {
          _log.e(
            'Failed to get user profile for app access snapshot',
            error: error,
            stackTrace: stackTrace,
          );
          return null;
        }
      },
      (elapsed) => timings.profile = elapsed,
    );

    if (profile == null) {
      final request = await timings.measure(
        () async {
          try {
            return await ref
                .read(roleRequestRepositoryProvider)
                .getMyPendingRequest(session.user.id);
          } on Object catch (error, stackTrace) {
            _log.e(
              'Failed to get pending role request for app access snapshot',
              error: error,
              stackTrace: stackTrace,
            );
            return null;
          }
        },
        (elapsed) => timings.pendingRoleRequest = elapsed,
      );
      hasPendingRoleRequest = request != null;
    }
  }

  return AppAccessSnapshot(
    onboardingCompleted: onboardingCompleted,
    session: session,
    profile: profile,
    hasPendingRoleRequest: hasPendingRoleRequest,
    timings: timings.finish(),
  );
}

void invalidateAppAccessCaches(WidgetRef ref) {
  ref
    ..invalidate(appAccessSnapshotProvider)
    ..invalidate(currentUserProfileProvider)
    ..invalidate(myRoleRequestProvider);
}

void invalidateAppAccessCachesForProvider(Ref ref) {
  ref
    ..invalidate(appAccessSnapshotProvider)
    ..invalidate(currentUserProfileProvider)
    ..invalidate(myRoleRequestProvider);
}
