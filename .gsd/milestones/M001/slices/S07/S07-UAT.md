# S07: Analytics Dashboard — UAT

**Milestone:** M001
**Written:** 2026-03-15

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: All metrics are computed from seeded data in unit tests (10 scenarios) and rendered values verified in widget tests (7 scenarios). No live runtime needed — computation is pure and deterministic.

## Preconditions

- `flutter test` passes all 114 tests
- `flutter analyze` reports 0 errors, 0 warnings

## Smoke Test

Run `flutter test test/feature/operasyon/dashboard_stats_test.dart test/feature/operasyon/operasyon_dashboard_page_test.dart` — 17 tests pass.

## Test Cases

### 1. Revenue totals compute correctly

1. Seed 5 orders across different dates within 90-day window with known prices
2. Call `DashboardStats.compute()` with reference `now`
3. **Expected:** 3-month, 1-month, 1-week revenue totals match expected sums from seeded data

### 2. Cancelled orders excluded from revenue

1. Seed orders with `durum: iptal`
2. Compute stats
3. **Expected:** İptal orders contribute ₺0 to all revenue buckets

### 3. Daily average calculation

1. Seed orders in the current 30-day window
2. Compute with a known day-of-month
3. **Expected:** Daily average = 30-day revenue / days elapsed in month (minimum 1 day)

### 4. Courier performance stats

1. Seed orders assigned to different couriers
2. Compute stats
3. **Expected:** Each courier has correct monthly and daily job counts, sorted by monthly jobs descending

### 5. Active courier count

1. Seed couriers with mixed `isOnline` states
2. Compute stats
3. **Expected:** `activeCourierCount` equals count of `isOnline == true` couriers, names listed

### 6. Dashboard renders revenue cards

1. Pump `OperasyonDashboardPage` with seeded fake repositories
2. **Expected:** ₺ values for 3mo/1mo/1wk revenue and daily average visible on screen

### 7. Dashboard renders courier cards

1. Pump with seeded data
2. **Expected:** Courier names, job counts, active courier count, and bullet list all visible

## Edge Cases

### Empty state — no orders

1. Compute stats with empty order list
2. **Expected:** All revenues ₺0.00, all counts 0, "Veri yok" / "Aktif kurye yok" shown

### Null ucret handling

1. Seed orders with `ucret: null`
2. **Expected:** Null treated as 0 — no errors, revenue sums remain correct

### Null createdAt

1. Seed orders with `createdAt: null`
2. **Expected:** Orders skipped from revenue calculation, no crash

### First day of month (divide-by-zero)

1. Compute with `now` on day 1 of a month
2. **Expected:** Daily average uses minimum divisor of 1, no divide-by-zero

## Failure Signals

- Revenue values show ₺0.00 when orders exist in the database
- Courier names missing from performance or active lists
- "Hata:" error text visible in any card
- Test failures in `dashboard_stats_test.dart` or `operasyon_dashboard_page_test.dart`

## Requirements Proved By This UAT

- R015 (Analytics dashboard) — revenue totals for 3 periods, daily average, courier job counts, and active courier display all verified through unit + widget tests

## Not Proven By This UAT

- Live Supabase data fetching (tested with fakes, not real DB)
- Visual layout/spacing (widget tests verify text presence, not visual design)
- Pull-to-refresh behavior in real app (would need runtime verification)

## Notes for Tester

- All computation is pure — `DashboardStats.compute()` takes explicit inputs and returns deterministic output. Seeded data covers the critical boundary cases.
- Widget tests use `FakeSiparisRepository` and `FakeKuryeRepository` — same fakes used across the project.
