import 'package:backend_core/backend_core.dart';
import 'package:backend_mock/backend_mock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuryem/core/environment/app_environment.dart';
import 'package:kuryem/core/environment/backend_provider.dart';
import 'package:kuryem/core/environment/credit_access_provider.dart';
import 'package:kuryem/product/analytics/analytics_provider.dart';
import 'package:kuryem/product/auth/auth_providers.dart';
import 'package:kuryem/product/environment/environment_provider.dart';
import 'package:kuryem/product/runtime/runtime_providers.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../fakes/fake_analytics_service.dart';
import '../fakes/fake_connectivity_service.dart';
import '../fakes/fake_crash_reporting_service.dart';
import '../fakes/fake_permission_service.dart';
import '../fakes/fake_secure_storage_service.dart';

ProviderContainer createTestProviderContainer({
  List<Override> overrides = const <Override>[],
  AppEnvironment? environment,
  AnalyticsService? analyticsService,
  BackendModule? backendModule,
}) {
  final resolvedOverrides = <Override>[
    appEnvironmentProvider.overrideWithValue(
      environment ??
          const AppEnvironment(
            flavor: AppFlavor.dev,
            backendProvider: BackendProvider.mock,
            creditAccessProvider: CreditAccessProvider.navigationSignal,
            customApiBaseUrl: 'https://api.example.com',
            supabaseUrl: '',
            supabaseAnonKey: '',
            mixpanelToken: '',
            analyticsEnabled: false,
            sentryDsn: '',
            operasyonReportsPassword: '',
          ),
    ),
    backendModuleProvider.overrideWithValue(
      backendModule ?? MockBackendModule(),
    ),
    analyticsServiceProvider.overrideWithValue(
      analyticsService ?? FakeAnalyticsService(),
    ),
    secureStorageServiceProvider.overrideWithValue(FakeSecureStorageService()),
    connectivityServiceProvider.overrideWithValue(FakeConnectivityService()),
    crashReportingServiceProvider.overrideWithValue(
      FakeCrashReportingService(),
    ),
    permissionServiceProvider.overrideWithValue(FakePermissionService()),
    ...overrides,
  ];

  return ProviderContainer(
    overrides: resolvedOverrides,
  );
}
