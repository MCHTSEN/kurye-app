import 'app_environment_keys.dart';
import 'backend_provider.dart';
import 'credit_access_provider.dart';

enum AppFlavor {
  dev,
  staging,
  prod;

  static AppFlavor fromValue(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();

    for (final flavor in AppFlavor.values) {
      if (flavor.name == normalized) {
        return flavor;
      }
    }

    return AppFlavor.dev;
  }
}

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.backendProvider,
    required this.creditAccessProvider,
    required this.customApiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.mixpanelToken,
    required this.analyticsEnabled,
    required this.sentryDsn,
  });

  factory AppEnvironment.fromDartDefine() {
    const flavorRaw = String.fromEnvironment(
      AppEnvironmentKeys.appEnv,
      defaultValue: 'dev',
    );
    const backendRaw = String.fromEnvironment(
      AppEnvironmentKeys.backendProvider,
      defaultValue: 'mock',
    );
    const creditAccessRaw = String.fromEnvironment(
      AppEnvironmentKeys.creditAccessProvider,
      defaultValue: 'navigationSignal',
    );
    const analyticsRaw = String.fromEnvironment(
      AppEnvironmentKeys.analyticsEnabled,
      defaultValue: 'true',
    );

    return AppEnvironment(
      flavor: AppFlavor.fromValue(flavorRaw),
      backendProvider: BackendProvider.fromValue(backendRaw),
      creditAccessProvider: CreditAccessProvider.fromValue(creditAccessRaw),
      customApiBaseUrl: const String.fromEnvironment(
        AppEnvironmentKeys.customApiBaseUrl,
        defaultValue: 'https://api.example.com',
      ),
      supabaseUrl: const String.fromEnvironment(AppEnvironmentKeys.supabaseUrl),
      supabaseAnonKey: const String.fromEnvironment(
        AppEnvironmentKeys.supabaseAnonKey,
      ),
      mixpanelToken: const String.fromEnvironment(
        AppEnvironmentKeys.mixpanelToken,
      ),
      analyticsEnabled: analyticsRaw.toLowerCase() != 'false',
      sentryDsn: const String.fromEnvironment(AppEnvironmentKeys.sentryDsn),
    );
  }

  final AppFlavor flavor;
  final BackendProvider backendProvider;
  final CreditAccessProvider creditAccessProvider;
  final String customApiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String mixpanelToken;
  final bool analyticsEnabled;
  final String sentryDsn;

  AppEnvironment copyWith({
    AppFlavor? flavor,
    BackendProvider? backendProvider,
    CreditAccessProvider? creditAccessProvider,
    String? customApiBaseUrl,
    String? supabaseUrl,
    String? supabaseAnonKey,
    String? mixpanelToken,
    bool? analyticsEnabled,
    String? sentryDsn,
  }) {
    return AppEnvironment(
      flavor: flavor ?? this.flavor,
      backendProvider: backendProvider ?? this.backendProvider,
      creditAccessProvider: creditAccessProvider ?? this.creditAccessProvider,
      customApiBaseUrl: customApiBaseUrl ?? this.customApiBaseUrl,
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      mixpanelToken: mixpanelToken ?? this.mixpanelToken,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      sentryDsn: sentryDsn ?? this.sentryDsn,
    );
  }
}
