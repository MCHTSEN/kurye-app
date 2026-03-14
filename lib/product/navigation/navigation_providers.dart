import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';
import 'app_navigation_state.dart';
import 'route_reevaluation_notifier.dart';

part 'navigation_providers.g.dart';

@Riverpod(keepAlive: true)
AppNavigationState appNavigationState(Ref ref) {
  final state = AppNavigationState();
  ref.onDispose(state.dispose);
  return state;
}

@Riverpod(keepAlive: true)
RouteReevaluationNotifier appRouteReevaluationNotifier(Ref ref) {
  final notifier = RouteReevaluationNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    navigationState: ref.watch(appNavigationStateProvider),
  );
  ref.onDispose(notifier.dispose);
  return notifier;
}
