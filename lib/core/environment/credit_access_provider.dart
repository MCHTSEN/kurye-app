enum CreditAccessProvider {
  navigationSignal,
  backend,
  revenueCat;

  static CreditAccessProvider fromValue(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();

    for (final provider in CreditAccessProvider.values) {
      if (provider.name.toLowerCase() == normalized) {
        return provider;
      }
    }

    return CreditAccessProvider.navigationSignal;
  }
}
