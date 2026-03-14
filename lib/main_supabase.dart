import 'package:backend_supabase/backend_supabase.dart';

import 'app/bootstrap.dart';
import 'core/environment/app_environment.dart';
import 'core/environment/backend_provider.dart';

Future<void> main() async {
  final environment = AppEnvironment.fromDartDefine().copyWith(
    backendProvider: BackendProvider.supabase,
  );
  await bootstrap(
    module: SupabaseBackendModule(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    ),
    environment: environment,
  );
}
