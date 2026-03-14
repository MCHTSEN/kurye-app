import 'package:backend_core/backend_core.dart';

import '../../navigation/app_navigation_state.dart';

class NavigationSignalCreditAccessService implements CreditAccessService {
  NavigationSignalCreditAccessService({
    required AppNavigationState navigationState,
  }) : _navigationState = navigationState;

  final AppNavigationState _navigationState;

  @override
  Future<bool> hasSufficientCredit() async {
    return !_navigationState.requiresCreditPurchase;
  }
}
