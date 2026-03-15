---
id: S07
parent: M001
milestone: M001
provides:
  - DashboardStats and CourierStat immutable domain models with pure compute() factory
  - dashboardStatsProvider Riverpod FutureProvider (parallel fetch + compute)
  - Live dashboard UI with 3 analytics cards replacing placeholders
  - Pull-to-refresh via RefreshIndicator
requires:
  - slice: S04
    provides: SiparisRepository.getHistory() for order data, KuryeRepository.getAll() for courier data
affects:
  - S08
key_files:
  - lib/feature/operasyon/domain/dashboard_stats.dart
  - lib/feature/operasyon/providers/dashboard_providers.dart
  - lib/feature/operasyon/presentation/operasyon_dashboard_page.dart
  - test/feature/operasyon/dashboard_stats_test.dart
  - test/feature/operasyon/operasyon_dashboard_page_test.dart
key_decisions:
  - Pure computation via DashboardStats.compute() factory — takes raw data + now, returns all metrics with no side effects
  - Each card is an independent ConsumerWidget watching dashboardStatsProvider with .when() for isolated loading/error states
  - RefreshIndicator wraps ListView — invalidates and awaits provider re-resolution
patterns_established:
  - Domain models in feature/operasyon/domain/ separate from providers in providers/
  - Pure computation in factory constructor, provider is thin orchestration layer
  - Per-card ConsumerWidget pattern for targeted rebuilds with independent error handling
observability_surfaces:
  - DashboardStats.toString() and CourierStat.toString() output all metric values for debug logging
  - Error state rendered inline per card with red "Hata: <message>" text
drill_down_paths:
  - .gsd/milestones/M001/slices/S07/tasks/T01-SUMMARY.md
  - .gsd/milestones/M001/slices/S07/tasks/T02-SUMMARY.md
duration: ~25min
verification_result: passed
completed_at: 2026-03-15
---

# S07: Analytics Dashboard

**Live analytics dashboard with revenue totals (3mo/1mo/1wk), daily average, courier performance stats, and active courier count — all computed from order history and courier data.**

## What Happened

T01 built the data layer: `DashboardStats` and `CourierStat` immutable models with a pure `DashboardStats.compute()` factory that takes raw order + courier lists and a reference timestamp, then filters to `tamamlandi` orders, computes revenue for 90/30/7-day windows, calculates daily average (30d revenue / days elapsed in month, min 1), groups orders by courier for monthly/daily job counts, and counts online couriers. `dashboardStatsProvider` fetches history + couriers in parallel via `Future.wait`, then delegates to `compute()`. 10 unit tests cover all computation paths including empty state, iptal exclusion, null ucret, bucket boundaries, and divide-by-zero prevention.

T02 wired the computed stats into the dashboard page, replacing all 3 placeholder cards. Ciro Analizi shows a 3-column revenue grid + daily average. Kurye Performansı lists each courier with monthly and daily job counts. Aktif Kuryeler shows a count badge with online courier names. Each card handles loading/error independently. A RefreshIndicator enables pull-to-refresh. 7 widget tests verify rendered values match seeded data, empty states display correctly, and card titles are always visible.

## Verification

- `flutter test test/feature/operasyon/dashboard_stats_test.dart` — 10/10 passed
- `flutter test test/feature/operasyon/operasyon_dashboard_page_test.dart` — 7/7 passed
- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — 114/114 all project tests pass, 0 regressions

## Requirements Advanced

- R015 (Analytics dashboard) — fully implemented with revenue metrics, courier performance, active couriers

## Requirements Validated

- R015 — unit tests prove correct computation for all metric types; widget tests prove rendered values match expected data

## New Requirements Surfaced

- none

## Requirements Invalidated or Re-scoped

- none

## Deviations

None.

## Known Limitations

- Dashboard data is fetched on-demand (no caching beyond Riverpod's provider lifecycle) — acceptable for MVP volume
- Loading state not testable in widget tests because mock repos resolve synchronously — not a real gap, just a test limitation

## Follow-ups

- none

## Files Created/Modified

- `lib/feature/operasyon/domain/dashboard_stats.dart` — DashboardStats + CourierStat models with compute() factory
- `lib/feature/operasyon/providers/dashboard_providers.dart` — dashboardStatsProvider FutureProvider
- `lib/feature/operasyon/providers/dashboard_providers.g.dart` — generated provider code
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — replaced 3 placeholder cards with live analytics widgets + RefreshIndicator
- `test/feature/operasyon/dashboard_stats_test.dart` — 10 unit tests for compute() logic
- `test/feature/operasyon/operasyon_dashboard_page_test.dart` — 7 widget tests for rendered metrics

## Forward Intelligence

### What the next slice should know
- Dashboard provider reads from the same `SiparisRepository.getHistory()` and `KuryeRepository.getAll()` that S06 history page uses — no new query methods were needed.

### What's fragile
- nothing notable — pure computation + thin provider is straightforward

### Authoritative diagnostics
- `DashboardStats.toString()` prints all metric values — useful for debugging analytics discrepancies

### What assumptions changed
- none — slice executed exactly as planned
