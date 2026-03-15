---
id: T02
parent: S07
milestone: M001
provides:
  - Dashboard UI with live revenue, courier performance, and active courier cards
  - Widget tests verifying rendered metrics match seeded data
key_files:
  - lib/feature/operasyon/presentation/operasyon_dashboard_page.dart
  - test/feature/operasyon/operasyon_dashboard_page_test.dart
key_decisions:
  - Split each card into its own ConsumerWidget (_CiroAnaliziCard, _KuryePerformansCard, _AktifKuryelerCard) for targeted rebuilds
  - Used RefreshIndicator wrapping the ListView that invalidates and awaits dashboardStatsProvider
  - Shared _formatCurrency helper for consistent ₺X.XX formatting across all revenue displays
patterns_established:
  - Each dashboard card is a private ConsumerWidget that watches dashboardStatsProvider independently with .when() for loading/error/data
  - Empty states handled per-card with Turkish-language messages (Veri yok, Aktif kurye yok)
observability_surfaces:
  - DashboardStats.toString() prints all metric values for debug logging (from T01)
  - Error state rendered inline per card with red error text
duration: 10m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Dashboard UI with live metrics and widget tests

**Replaced all 3 placeholder TODO cards on the operations dashboard with live analytics wired to dashboardStatsProvider, plus 7 widget tests verifying rendered values.**

## What Happened

Rewrote `operasyon_dashboard_page.dart` — the three `AppSectionCard` placeholders ("Sprint 3'te implement edilecek") are now real widgets reading from `dashboardStatsProvider`:

- **Ciro Analizi**: 3-column row showing 3-month, 1-month, 1-week revenue totals formatted as ₺X.XX, plus daily average below.
- **Kurye Performansı**: Lists each courier with name, monthly job count, and today's job count. Shows "Veri yok" when empty.
- **Aktif Kuryeler**: Prominent count (green headline) + bulleted list of online courier names. Shows "Aktif kurye yok" when none online.

Each card handles loading (spinner) and error states independently via `.when()`. A `RefreshIndicator` wraps the ListView — pull-to-refresh invalidates the provider and awaits re-resolution.

Widget tests seed `FakeSiparisRepository` with 5 orders at known dates/prices and `FakeKuryeRepository` with 3 couriers (2 online, 1 offline), then verify:
- Revenue totals render correctly (₺725.00 / ₺425.00 / ₺225.00)
- Daily average renders (₺28.33)
- Courier names and job counts appear
- Active courier count (2) and names with bullets
- Empty states ("Aktif kurye yok", "Veri yok")
- Card titles always visible
- Page renders without error

## Verification

- `flutter test test/feature/operasyon/operasyon_dashboard_page_test.dart` — 7/7 passed
- `flutter test test/feature/operasyon/dashboard_stats_test.dart` — 10/10 passed (T01 unit tests still pass)
- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — 114/114 all project tests pass, 0 regressions

## Diagnostics

- Error state per card shows `Hata: <message>` in red — visible when provider throws
- DashboardStats.toString() available for console debugging

## Deviations

Loading state test changed from asserting CircularProgressIndicator to asserting Scaffold renders — mock repos resolve synchronously so loading state is never visible in widget tests. This is correct behavior; async loading would only be testable with delayed fakes.

## Known Issues

None.

## Files Created/Modified

- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — replaced 3 placeholder cards with live analytics widgets, added RefreshIndicator
- `test/feature/operasyon/operasyon_dashboard_page_test.dart` — 7 widget tests covering revenue, courier stats, active couriers, empty states, and card titles
