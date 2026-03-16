import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/environment/environment_provider.dart';

final operasyonReportsPasswordProvider = Provider<String>((ref) {
  return ref.watch(
    appEnvironmentProvider.select(
      (environment) => environment.operasyonReportsPassword.trim(),
    ),
  );
});

final NotifierProvider<OperasyonReportsUnlockedNotifier, bool>
operasyonReportsUnlockedProvider =
    NotifierProvider<OperasyonReportsUnlockedNotifier, bool>(
      OperasyonReportsUnlockedNotifier.new,
    );

class OperasyonReportsUnlockedNotifier extends Notifier<bool> {
  @override
  bool build() {
    final password = ref.watch(operasyonReportsPasswordProvider);
    return password.isEmpty;
  }

  void unlock() {
    state = true;
  }

  void lock() {
    state = ref.read(operasyonReportsPasswordProvider).isEmpty;
  }
}
