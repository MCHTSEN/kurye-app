import 'package:bursamotokurye/core/runtime/cache_policy.dart';
import 'package:bursamotokurye/core/runtime/retry_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CachePolicy', () {
    test('isFresh returns true within ttl', () {
      const policy = CachePolicy.standard();
      final cachedAt = DateTime(2026, 3, 8, 12);
      final now = cachedAt.add(const Duration(minutes: 5));

      expect(policy.isFresh(cachedAt, now), isTrue);
    });
  });

  group('RetryPolicy', () {
    test('delay grows with attempts', () {
      const policy = RetryPolicy.networkDefault();

      expect(policy.delayForAttempt(1), const Duration(milliseconds: 150));
      expect(policy.delayForAttempt(2), const Duration(milliseconds: 300));
    });
  });
}
