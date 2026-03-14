import 'package:backend_core/backend_core.dart';
import 'package:backend_custom/backend_custom.dart';
import 'package:backend_firebase/backend_firebase.dart';
import 'package:backend_mock/backend_mock.dart';
import 'package:backend_supabase/backend_supabase.dart';

import '../core/environment/app_environment.dart';
import '../core/environment/backend_provider.dart';

BackendModule createBackendModule(AppEnvironment environment) {
  switch (environment.backendProvider) {
    case BackendProvider.mock:
      return MockBackendModule();
    case BackendProvider.custom:
      return CustomBackendModule(baseUrl: environment.customApiBaseUrl);
    case BackendProvider.supabase:
      return SupabaseBackendModule(
        url: environment.supabaseUrl,
        anonKey: environment.supabaseAnonKey,
      );
    case BackendProvider.firebase:
      return FirebaseBackendModule();
  }
}
