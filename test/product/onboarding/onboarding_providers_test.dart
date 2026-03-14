import 'package:eipat/product/onboarding/onboarding_providers.dart';
import 'package:eipat/product/onboarding/onboarding_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  bool _completed = false;

  @override
  Future<bool> isCompleted() async => _completed;

  @override
  Future<void> complete() async {
    _completed = true;
  }
}

void main() {
  group('OnboardingStatusController', () {
    test('build returns false when onboarding is not completed', () async {
      final container = ProviderContainer(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            _FakeOnboardingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final status = await container.read(
        onboardingStatusControllerProvider.future,
      );

      expect(status, isFalse);
    });

    test('completeOnboarding updates state to true', () async {
      final container = ProviderContainer(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            _FakeOnboardingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        onboardingStatusControllerProvider.notifier,
      );
      await controller.completeOnboarding();

      final status = await container.read(
        onboardingStatusControllerProvider.future,
      );
      expect(status, isTrue);
    });
  });
}
