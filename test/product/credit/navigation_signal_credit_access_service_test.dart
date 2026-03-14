import 'package:bursamotokurye/product/credit/data/navigation_signal_credit_access_service.dart';
import 'package:bursamotokurye/product/navigation/app_navigation_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationSignalCreditAccessService', () {
    test('returns true when credit purchase is not required', () async {
      final state = AppNavigationState();
      final service = NavigationSignalCreditAccessService(
        navigationState: state,
      );

      expect(await service.hasSufficientCredit(), isTrue);
    });

    test('returns false when credit purchase is required', () async {
      final state = AppNavigationState()..requireCreditPurchase();
      final service = NavigationSignalCreditAccessService(
        navigationState: state,
      );

      expect(await service.hasSufficientCredit(), isFalse);
    });
  });
}
