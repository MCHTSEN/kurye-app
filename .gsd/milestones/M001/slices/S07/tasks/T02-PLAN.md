---
estimated_steps: 4
estimated_files: 2
---

# T02: Dashboard UI with live metrics and widget tests

**Slice:** S07 — Analytics Dashboard
**Milestone:** M001

## Description

Replace the 3 placeholder TODO cards in `operasyon_dashboard_page.dart` with real widgets wired to `dashboardStatsProvider`. Add widget tests that seed known data and verify the rendered metrics match expectations.

## Steps

1. Replace the Ciro Analizi card content: show a 3-column grid/row with 3-month, 1-month, and 1-week revenue totals (₺ formatted to 2 decimals). Below, show daily average for the current month. Use `dashboardStatsProvider.when()` for loading/error/data states.
2. Replace the Kurye Performansı card content: list each courier with their name, monthly job count, and today's job count. Handle empty list with "Veri yok" message.
3. Replace the Aktif Kuryeler card content: show the count of online couriers prominently + list their names. Handle zero with "Aktif kurye yok" message.
4. Add a RefreshIndicator wrapping the ListView (or an AppBar refresh action) that invalidates `dashboardStatsProvider`. Write widget tests: create FakeSiparisRepository seeded with orders at known dates/prices, FakeKuryeRepository with online/offline couriers, override providers, pump the page, verify key text values appear (revenue amounts, courier names, counts).

## Must-Haves

- [ ] All 3 placeholder cards replaced with real data
- [ ] Revenue amounts formatted as ₺X.XX
- [ ] Loading and error states handled
- [ ] Refresh mechanism to re-fetch data
- [ ] Widget test verifies rendered revenue totals match seeded data
- [ ] Widget test verifies courier stats and active courier count

## Verification

- `flutter test test/feature/operasyon/operasyon_dashboard_page_test.dart` — widget tests pass
- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all project tests pass (no regressions)

## Inputs

- `lib/feature/operasyon/domain/dashboard_stats.dart` — DashboardStats model from T01
- `lib/feature/operasyon/providers/dashboard_providers.dart` — dashboardStatsProvider from T01
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — existing placeholder page
- `test/helpers/fakes/fake_siparis_repository.dart` — FakeSiparisRepository
- `test/helpers/fakes/fake_kurye_repository.dart` — FakeKuryeRepository
- `test/helpers/widgets/test_app.dart` — pumpApp helper

## Expected Output

- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — updated with real analytics cards
- `test/feature/operasyon/operasyon_dashboard_page_test.dart` — widget tests for dashboard rendering
