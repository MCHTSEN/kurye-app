import '../../../core/runtime/feature_flag_service.dart';

class InMemoryFeatureFlagService implements FeatureFlagService {
  InMemoryFeatureFlagService({
    Map<String, bool>? flags,
    Map<String, String>? values,
  }) : _flags = flags ?? const <String, bool>{},
       _values = values ?? const <String, String>{};

  final Map<String, bool> _flags;
  final Map<String, String> _values;

  @override
  String? getString(String key) => _values[key];

  @override
  bool isEnabled(String key) => _flags[key] ?? false;
}
