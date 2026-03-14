import 'package:backend_core/backend_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  static final _log = AppLogger('ProviderObserver');

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _log.e(
      '${context.provider.name ?? context.provider.runtimeType}: $error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
