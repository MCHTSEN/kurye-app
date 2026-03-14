import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/environment/app_environment.dart';

part 'environment_provider.g.dart';

@Riverpod(keepAlive: true)
AppEnvironment appEnvironment(Ref ref) {
  throw UnimplementedError(
    'appEnvironmentProvider must be overridden in bootstrap',
  );
}
