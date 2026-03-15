# S07: Analytics Dashboard

**Goal:** Replace the 3 placeholder cards on the operasyon dashboard with live analytics — revenue totals (3mo/1mo/1wk), daily average, courier job counts, and active couriers today.
**Demo:** Open the operasyon dashboard → see real revenue metrics, courier performance stats, and active courier count computed from order history and courier data.

## Must-Haves

- `DashboardStats` immutable model with revenue buckets (3mo, 1mo, 1wk), daily average, courier stats, active courier count
- `dashboardStatsProvider` Riverpod provider that fetches 3-month order history + courier list and computes all metrics
- Revenue calculations filter to `tamamlandi` orders only (not `iptal`)
- Null `ucret` treated as 0 in sums
- Daily average = current month revenue / days elapsed in month (no divide-by-zero)
- Empty state shows ₺0.00 and 0 counts
- Dashboard cards replaced: Ciro Analizi (3 period totals + daily avg), Kurye Performansı (courier job counts), Aktif Kuryeler (online count + names)
- Unit tests for computation logic with seeded data at different dates
- Widget tests proving rendered metrics match expected values

## Verification

- `flutter test test/feature/operasyon/dashboard_stats_test.dart` — unit tests for DashboardStats computation
- `flutter test test/feature/operasyon/operasyon_dashboard_page_test.dart` — widget tests for rendered cards
- `flutter analyze` — 0 errors, 0 warnings

## Tasks

- [x] **T01: Dashboard stats model, provider, and unit tests** `est:15m`
  - Why: Data layer for all dashboard metrics — model + provider + tested computation logic
  - Files: `lib/feature/operasyon/domain/dashboard_stats.dart`, `lib/feature/operasyon/providers/dashboard_providers.dart`, `test/feature/operasyon/dashboard_stats_test.dart`
  - Do: Create `DashboardStats` and `CourierStat` immutable models. Create `dashboardStatsProvider` that calls `siparisRepositoryProvider.getHistory(startDate: now-90d)` and `kuryeRepositoryProvider.getAll()`, filters to tamamlandi, computes all revenue buckets and courier stats. Extract computation into a static/factory method for testability. Unit test with seeded orders at varied dates covering: correct period bucketing, null ucret handling, daily average, courier grouping, empty state.
  - Verify: `flutter test test/feature/operasyon/dashboard_stats_test.dart` passes
  - Done when: All computation unit tests pass and `flutter analyze` is clean

- [x] **T02: Dashboard UI with live metrics and widget tests** `est:15m`
  - Why: Wire computed stats into the dashboard page, replacing all 3 TODO cards
  - Files: `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`, `test/feature/operasyon/operasyon_dashboard_page_test.dart`
  - Do: Replace 3 placeholder `AppSectionCard` children with real widgets reading `dashboardStatsProvider`. Ciro Analizi: grid showing 3mo/1mo/1wk totals + daily average. Kurye Performansı: list of couriers with monthly/daily job counts. Aktif Kuryeler: count badge + online courier names. Add refresh capability (RefreshIndicator or AppBar action). Widget tests: seed FakeSiparisRepository + FakeKuryeRepository with known data, override providers, verify rendered text matches expected values.
  - Verify: `flutter test test/feature/operasyon/operasyon_dashboard_page_test.dart` passes, `flutter analyze` clean
  - Done when: Dashboard shows live metrics, widget tests verify rendered values, all tests pass

## Files Likely Touched

- `lib/feature/operasyon/domain/dashboard_stats.dart`
- `lib/feature/operasyon/providers/dashboard_providers.dart`
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`
- `test/feature/operasyon/dashboard_stats_test.dart`
- `test/feature/operasyon/operasyon_dashboard_page_test.dart`
