import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'onboarding_repository.dart';
import 'shared_preferences_onboarding_repository.dart';

part 'onboarding_providers.g.dart';

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  return SharedPreferencesOnboardingRepository();
}

@Riverpod(keepAlive: true)
class OnboardingStatusController extends _$OnboardingStatusController {
  static final _log = AppLogger(
    'OnboardingStatus',
    tag: LogTag.onboarding,
  );

  @override
  Future<bool> build() async {
    return ref.watch(onboardingRepositoryProvider).isCompleted();
  }

  Future<void> completeOnboarding() async {
    _log.i('Completing onboarding');
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      await ref.read(onboardingRepositoryProvider).complete();
      return true;
    });
    if (!ref.mounted) {
      return;
    }

    state = nextState;
    _log.i('Onboarding completed: ${!nextState.hasError}');
  }
}
