abstract class FeatureFlagService {
  bool isEnabled(String key);

  String? getString(String key);
}
