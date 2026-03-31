import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/product/navigation/app_navigation_state.dart';

void main() {
  group('AppNavigationState', () {
    test('require and clear flags update state', () {
      final state = AppNavigationState();

      expect(state.requiresLogin, isFalse);
      expect(state.requiresCreditPurchase, isFalse);

      state
        ..requireLogin()
        ..requireCreditPurchase();

      expect(state.requiresLogin, isTrue);
      expect(state.requiresCreditPurchase, isTrue);

      state.clearAll();

      expect(state.requiresLogin, isFalse);
      expect(state.requiresCreditPurchase, isFalse);
    });

    test('listeners are notified on changes', () {
      final state = AppNavigationState();
      var notifyCount = 0;

      state
        ..addListener(() {
          notifyCount++;
        })
        ..requireLogin()
        ..clearLoginRequirement();

      expect(notifyCount, 2);
    });
  });
}
