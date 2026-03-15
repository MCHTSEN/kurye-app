---
id: T01
parent: S07
milestone: M001
provides:
  - DashboardStats and CourierStat immutable domain models
  - DashboardStats.compute() pure factory for all dashboard metrics
  - dashboardStatsProvider Riverpod FutureProvider
  - Unit tests covering all computation scenarios
key_files:
  - lib/feature/operasyon/domain/dashboard_stats.dart
  - lib/feature/operasyon/providers/dashboard_providers.dart
  - lib/feature/operasyon/providers/dashboard_providers.g.dart
  - test/feature/operasyon/dashboard_stats_test.dart
key_decisions:
  - Used factory constructor DashboardStats.compute() instead of static method to satisfy prefer_constructors_over_static_methods lint
  - Kept compute() pure — takes orders + couriers + now, returns stats with no side effects
  - Provider uses Future.wait for parallel fetch of orders and couriers
  - Courier stats sorted by monthlyJobs descending for display priority
patterns_established:
  - Domain models in lib/feature/operasyon/domain/ separate from providers in providers/
  - Pure computation in factory constructor, provider is thin orchestration layer
observability_surfaces:
  - DashboardStats.toString() outputs all metric values for debug logging
duration: ~15min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Dashboard stats model, provider, and unit tests

**Built DashboardStats/CourierStat domain models with pure compute() factory and 10 unit tests covering all revenue bucketing, courier grouping, and edge cases.**

## What Happened

Created `DashboardStats` and `CourierStat` immutable value objects in `lib/feature/operasyon/domain/dashboard_stats.dart`. The `DashboardStats.compute()` factory takes raw order + courier lists and a reference `now` timestamp, then:

- Filters to `tamamlandi` orders only (iptal excluded)
- Computes revenue for 90-day, 30-day, and 7-day windows using `createdAt`
- Calculates daily average as 30-day revenue / days elapsed in current month (min 1)
- Groups orders by `kuryeId` for monthly (30d) and daily job counts
- Counts online couriers via `isOnline == true`

Created `dashboardStatsProvider` as a code-generated `@riverpod` FutureProvider that fetches 90-day history + all couriers in parallel, then delegates to `compute()`.

Wrote 10 unit tests covering: empty list → zeros, iptal exclusion, null ucret → 0, revenue bucket boundaries, daily average with day-of-month, divide-by-zero prevention, courier stat grouping, active courier counting, null createdAt skip, null kuryeId revenue inclusion.

## Verification

- `flutter test test/feature/operasyon/dashboard_stats_test.dart` → 10/10 passed ✓
- `flutter analyze` → 0 errors, 0 warnings (34 infos project-wide, 4 from this task's `avoid_equals_and_hash_code_on_mutable_classes` — consistent with existing domain model pattern) ✓

### Slice-level verification status (intermediate — T01 of 2):
- `flutter test test/feature/operasyon/dashboard_stats_test.dart` → ✓ PASS
- `flutter test test/feature/operasyon/operasyon_dashboard_page_test.dart` → file does not exist yet (T02)
- `flutter analyze` → ✓ PASS (0 errors, 0 warnings)

## Diagnostics

- `DashboardStats.toString()` prints all metric values — useful for debug logging
- `CourierStat.toString()` prints per-courier detail
- Both classes implement `==` and `hashCode` for value comparison in tests

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `lib/feature/operasyon/domain/dashboard_stats.dart` — DashboardStats + CourierStat models with compute() factory
- `lib/feature/operasyon/providers/dashboard_providers.dart` — dashboardStatsProvider Riverpod FutureProvider
- `lib/feature/operasyon/providers/dashboard_providers.g.dart` — generated provider code
- `test/feature/operasyon/dashboard_stats_test.dart` — 10 unit tests for compute() logic
