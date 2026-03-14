import 'package:backend_core/backend_core.dart';

class MockCreditAccessService implements CreditAccessService {
  const MockCreditAccessService();

  @override
  Future<bool> hasSufficientCredit() async => true;
}
