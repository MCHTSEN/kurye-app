import 'payment_service.dart';

/// No-op payment service for development and testing.
class NoopPaymentService implements PaymentService {
  const NoopPaymentService();

  @override
  Future<void> initialize() async {}

  @override
  Future<List<PaymentProduct>> getProducts(List<String> productIds) async {
    return const [];
  }

  @override
  Future<PaymentResult> purchase(String productId) async {
    return const PaymentResult.success(transactionId: 'noop_txn');
  }

  @override
  Future<PaymentResult> restorePurchases() async {
    return const PaymentResult.success();
  }

  @override
  Future<bool> hasActiveSubscription() async => false;

  @override
  Future<int> availableCredits() async => 0;
}
