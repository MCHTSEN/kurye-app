class RetryPolicy {
  const RetryPolicy({
    required this.maxAttempts,
    required this.initialDelay,
    this.backoffFactor = 1,
  }) : assert(maxAttempts > 0, 'maxAttempts must be positive');

  const RetryPolicy.networkDefault()
    : maxAttempts = 2,
      initialDelay = const Duration(milliseconds: 150),
      backoffFactor = 2;

  final int maxAttempts;
  final Duration initialDelay;
  final int backoffFactor;

  Duration delayForAttempt(int attempt) {
    if (attempt <= 1) {
      return initialDelay;
    }

    final multiplier = _pow(backoffFactor, attempt - 1);
    return Duration(milliseconds: initialDelay.inMilliseconds * multiplier);
  }

  int _pow(int base, int exponent) {
    var result = 1;
    for (var index = 0; index < exponent; index++) {
      result *= base;
    }
    return result;
  }
}
