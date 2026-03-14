import 'app/backend_module_factory.dart';
import 'app/bootstrap.dart';
import 'core/environment/app_environment.dart';

Future<void> main() async {
  final environment = AppEnvironment.fromDartDefine();
  await bootstrap(
    module: createBackendModule(environment),
    environment: environment,
  );
}
