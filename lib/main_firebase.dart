import 'package:backend_firebase/backend_firebase.dart';

import 'app/bootstrap.dart';
import 'core/environment/app_environment.dart';
import 'core/environment/backend_provider.dart';

Future<void> main() async {
  final environment = AppEnvironment.fromDartDefine().copyWith(
    backendProvider: BackendProvider.firebase,
  );
  await bootstrap(
    module: FirebaseBackendModule(),
    environment: environment,
  );
}
