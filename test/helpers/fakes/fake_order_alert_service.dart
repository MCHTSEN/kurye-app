import 'package:bursamotokurye/product/services/order_alert_service.dart';

/// Spy [OrderAlertService] that records triggers without playing real audio.
class FakeOrderAlertService extends OrderAlertService {
  FakeOrderAlertService() : super();

  int alertCallCount = 0;
  bool disposed = false;

  @override
  Future<void> playNewOrderAlert() async {
    alertCallCount++;
    // No actual audio playback.
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    // Don't call super — no real AudioPlayer to dispose.
  }
}
