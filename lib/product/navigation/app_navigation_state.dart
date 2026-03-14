import 'package:flutter/foundation.dart';

class AppNavigationState extends ChangeNotifier {
  bool _requiresLogin = false;
  bool _requiresCreditPurchase = false;

  bool get requiresLogin => _requiresLogin;
  bool get requiresCreditPurchase => _requiresCreditPurchase;

  void requireLogin() {
    if (_requiresLogin) {
      return;
    }

    _requiresLogin = true;
    notifyListeners();
  }

  void clearLoginRequirement() {
    if (!_requiresLogin) {
      return;
    }

    _requiresLogin = false;
    notifyListeners();
  }

  void requireCreditPurchase() {
    if (_requiresCreditPurchase) {
      return;
    }

    _requiresCreditPurchase = true;
    notifyListeners();
  }

  void clearCreditRequirement() {
    if (!_requiresCreditPurchase) {
      return;
    }

    _requiresCreditPurchase = false;
    notifyListeners();
  }

  void clearAll() {
    final hadState = _requiresLogin || _requiresCreditPurchase;

    _requiresLogin = false;
    _requiresCreditPurchase = false;

    if (hadState) {
      notifyListeners();
    }
  }
}
