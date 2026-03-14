class CachePolicy {
  const CachePolicy({
    required this.timeToLive,
    this.allowStaleFallback = true,
  });

  const CachePolicy.standard()
    : timeToLive = const Duration(minutes: 10),
      allowStaleFallback = true;

  final Duration timeToLive;
  final bool allowStaleFallback;

  bool isFresh(DateTime cachedAt, DateTime now) {
    return now.difference(cachedAt) <= timeToLive;
  }
}
