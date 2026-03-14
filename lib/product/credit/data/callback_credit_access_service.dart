import 'package:backend_core/backend_core.dart';

typedef CreditAvailabilityChecker = Future<bool> Function();

class CallbackCreditAccessService implements CreditAccessService {
  CallbackCreditAccessService({
    required CreditAvailabilityChecker checker,
  }) : _checker = checker;

  final CreditAvailabilityChecker _checker;

  @override
  Future<bool> hasSufficientCredit() async {
    return _checker();
  }
}
