import 'dart:async';

import 'package:backend_core/backend_core.dart';
import 'package:flutter/foundation.dart';

import 'app_navigation_state.dart';

class RouteReevaluationNotifier extends ChangeNotifier {
  RouteReevaluationNotifier({
    required AuthRepository authRepository,
    required AppNavigationState navigationState,
    required VoidCallback onAuthChanged,
  }) : _authRepository = authRepository,
       _navigationState = navigationState,
       _onAuthChanged = onAuthChanged {
    _navigationState.addListener(_handleNavigationStateUpdated);
    _subscription = _authRepository.authStateChanges().listen(
      _handleAuthChanged,
    );
  }

  final AuthRepository _authRepository;
  final AppNavigationState _navigationState;
  final VoidCallback _onAuthChanged;
  late final StreamSubscription<AuthSession?> _subscription;

  static final _log = AppLogger(
    'RouteReevaluation',
    tag: LogTag.router,
  );

  void _handleNavigationStateUpdated() {
    _log.d('Navigation state changed, re-evaluating routes');
    notifyListeners();
  }

  void _handleAuthChanged(AuthSession? session) {
    _onAuthChanged();
    if (session != null) {
      _log.i('Auth state changed: user=${session.user.id}');
      _navigationState.clearLoginRequirement();
    } else {
      _log.i('Auth state changed: signed out');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    _navigationState.removeListener(_handleNavigationStateUpdated);
    super.dispose();
  }
}
