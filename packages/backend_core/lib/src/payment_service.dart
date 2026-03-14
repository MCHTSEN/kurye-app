/// Payment service interface for in-app purchases and subscriptions.
///
/// Implementations: RevenueCat, StoreKit/Play Billing (IAP), or custom.
abstract class PaymentService {
  Future<void> initialize();

  Future<List<PaymentProduct>> getProducts(List<String> productIds);

  Future<PaymentResult> purchase(String productId);

  Future<PaymentResult> restorePurchases();

  Future<bool> hasActiveSubscription();

  Future<int> availableCredits();
}

class PaymentProduct {
  const PaymentProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    this.type = PaymentProductType.consumable,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final String currencyCode;
  final PaymentProductType type;
}

enum PaymentProductType { consumable, nonConsumable, subscription }

class PaymentResult {
  const PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
  });

  const PaymentResult.success({this.transactionId})
      : success = true,
        errorMessage = null;

  const PaymentResult.failure(this.errorMessage)
      : success = false,
        transactionId = null;

  final bool success;
  final String? transactionId;
  final String? errorMessage;
}
