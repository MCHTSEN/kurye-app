import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_providers.dart';

part 'payment_providers.g.dart';

@Riverpod(keepAlive: true)
PaymentService paymentService(Ref ref) {
  return ref.watch(backendModuleProvider).createPaymentService();
}
