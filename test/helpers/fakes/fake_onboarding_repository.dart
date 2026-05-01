import 'package:kuryem/product/onboarding/onboarding_repository.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({this.completed = true});

  bool completed;

  @override
  Future<void> complete() async {
    completed = true;
  }

  @override
  Future<bool> isCompleted() async => completed;
}
