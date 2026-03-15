---
estimated_steps: 4
estimated_files: 3
---

# T01: Dashboard stats model, provider, and unit tests

**Slice:** S07 — Analytics Dashboard
**Milestone:** M001

## Description

Create the data layer for the analytics dashboard: immutable `DashboardStats` and `CourierStat` models, a Riverpod `dashboardStatsProvider` that fetches 3-month order history and all couriers then computes all metrics, and unit tests proving the computation logic handles period bucketing, null values, and edge cases correctly.

## Steps

1. Create `DashboardStats` immutable model with fields: `revenue3mo`, `revenue1mo`, `revenue1wk`, `dailyAvg` (all double), `courierStats` (List<CourierStat>), `activeCourierCount` (int), `activeCourierNames` (List<String>). Create `CourierStat` with `kuryeId`, `ad` (name), `monthlyJobs`, `dailyJobs` (int). Add a static `compute()` factory that takes `List<Siparis>` + `List<Kurye>` + `DateTime now` and returns `DashboardStats`. This keeps computation pure and testable.
2. Implement `compute()`: filter orders to `tamamlandi` only. Sum `ucret ?? 0` for orders within 90/30/7 days of `now`. Daily average = 30-day revenue / `now.day` (days elapsed in current month, min 1). Group orders by `kuryeId` to build `CourierStat` list with 30-day and today counts. Count couriers where `isOnline == true` for active count, collect their `ad` for names.
3. Create `dashboardStatsProvider` as a `FutureProvider.autoDispose` that reads `siparisRepositoryProvider` and `kuryeRepositoryProvider`, calls `getHistory(startDate: now - 90 days)` and `getAll()`, then delegates to `DashboardStats.compute()`.
4. Write unit tests in `test/feature/operasyon/dashboard_stats_test.dart`: seed orders at dates spanning 3mo/1mo/1wk/today, include both tamamlandi and iptal, include null ucret. Assert each revenue bucket, daily average, courier job counts, active courier count. Test empty list → all zeros.

## Must-Haves

- [ ] `DashboardStats.compute()` filters to `tamamlandi` only — iptal orders excluded from revenue
- [ ] Null `ucret` treated as 0 in fold
- [ ] Daily average uses days elapsed in current month (not 30), minimum 1 to avoid divide-by-zero
- [ ] Empty order list returns all-zero stats
- [ ] Courier stats group by `kuryeId` with correct monthly and daily counts
- [ ] Active courier count uses `isOnline == true`

## Verification

- `flutter test test/feature/operasyon/dashboard_stats_test.dart` — all unit tests pass
- `flutter analyze` — 0 errors, 0 warnings

## Inputs

- `packages/backend_core/lib/src/siparis_repository.dart` — `getHistory()` contract
- `packages/backend_core/lib/src/domain/siparis.dart` — Siparis model with `ucret`, `durum`, `createdAt`, `kuryeId`
- `packages/backend_core/lib/src/domain/kurye.dart` — Kurye model with `isOnline`, `ad`
- `lib/product/siparis/siparis_providers.dart` — existing provider patterns
- `lib/product/kurye/kurye_providers.dart` — `kuryeListProvider`
- `test/helpers/fakes/fake_siparis_repository.dart` — FakeSiparisRepository for unit tests
- `test/helpers/fakes/fake_kurye_repository.dart` — FakeKuryeRepository for unit tests

## Expected Output

- `lib/feature/operasyon/domain/dashboard_stats.dart` — DashboardStats + CourierStat models with `compute()` factory
- `lib/feature/operasyon/providers/dashboard_providers.dart` — `dashboardStatsProvider` FutureProvider
- `test/feature/operasyon/dashboard_stats_test.dart` — unit tests covering all computation scenarios
