import 'package:backend_core/backend_core.dart';

/// RevenueCat-based payment service.
///
/// To enable: add `purchases_flutter` to pubspec.yaml and
/// replace the stub logic with actual RevenueCat SDK calls.
class RevenueCatPaymentService implements PaymentService {
  RevenueCatPaymentService({required this.apiKey});

  final String apiKey;

  static final _log = AppLogger('RevenueCatPayment', tag: LogTag.credit);

  @override
  Future<void> initialize() async {
    _log.i('initialize called with apiKey: ${apiKey.substring(0, 4)}...');
    // TODO(dev): Purchases.configure(PurchasesConfiguration(apiKey));
  }

  @override
  Future<List<PaymentProduct>> getProducts(List<String> productIds) async {
    _log.i('getProducts called for: $productIds');
    // TODO(dev): final offerings = await Purchases.getOfferings();
    return const [];
  }

  @override
  Future<PaymentResult> purchase(String productId) async {
    _log.i('purchase called for: $productId');
    // TODO(dev): await Purchases.purchaseStoreProduct(product);
    return const PaymentResult.failure('RevenueCat not configured');
  }

  @override
  Future<PaymentResult> restorePurchases() async {
    _log.i('restorePurchases called');
    // TODO(dev): await Purchases.restorePurchases();
    return const PaymentResult.success();
  }

  @override
  Future<bool> hasActiveSubscription() async {
    _log.i('hasActiveSubscription called');
    // TODO(dev): final info = await Purchases.getCustomerInfo();
    return false;
  }

  @override
  Future<int> availableCredits() async {
    _log.i('availableCredits called');
    return 0;
  }
}
