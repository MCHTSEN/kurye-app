import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_repository.dart';

class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  static const _onboardingCompletedKey = 'onboarding_completed';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  @override
  Future<void> complete() async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  @override
  Future<bool> isCompleted() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }
}
