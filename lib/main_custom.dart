import 'package:backend_custom/backend_custom.dart';

import 'app/bootstrap.dart';
import 'core/environment/app_environment.dart';
import 'core/environment/backend_provider.dart';

Future<void> main() async {
  final environment = AppEnvironment.fromDartDefine().copyWith(
    backendProvider: BackendProvider.custom,
  );
  await bootstrap(
    module: CustomBackendModule(
      baseUrl: const String.fromEnvironment(
        'CUSTOM_API_BASE_URL',
        defaultValue: 'https://api.example.com',
      ),
    ),
    environment: environment,
  );
}
