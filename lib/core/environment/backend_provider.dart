enum BackendProvider {
  mock,
  custom,
  supabase,
  firebase;

  static BackendProvider fromValue(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();

    for (final provider in BackendProvider.values) {
      if (provider.name == normalized) {
        return provider;
      }
    }

    return BackendProvider.mock;
  }
}
