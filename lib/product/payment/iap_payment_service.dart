import 'package:backend_core/backend_core.dart';

/// Native StoreKit/Play Billing payment service.
///
/// To enable: add `in_app_purchase` to pubspec.yaml and
/// replace the stub logic with actual IAP SDK calls.
class IapPaymentService implements PaymentService {
  static final _log = AppLogger('IapPayment', tag: LogTag.credit);

  @override
  Future<void> initialize() async {
    _log.i('initialize called');
    // TODO(dev): InAppPurchase.instance.isAvailable();
  }

  @override
  Future<List<PaymentProduct>> getProducts(List<String> productIds) async {
    _log.i('getProducts called for: $productIds');
    // TODO(dev): InAppPurchase.instance.queryProductDetails(productIds.toSet());
    return const [];
  }

  @override
  Future<PaymentResult> purchase(String productId) async {
    _log.i('purchase called for: $productId');
    // TODO(dev): InAppPurchase.instance.buyConsumable(purchaseParam: ...);
    return const PaymentResult.failure('IAP not configured');
  }

  @override
  Future<PaymentResult> restorePurchases() async {
    _log.i('restorePurchases called');
    // TODO(dev): InAppPurchase.instance.restorePurchases();
    return const PaymentResult.success();
  }

  @override
  Future<bool> hasActiveSubscription() async {
    _log.i('hasActiveSubscription called');
    return false;
  }

  @override
  Future<int> availableCredits() async {
    _log.i('availableCredits called');
    return 0;
  }
}
