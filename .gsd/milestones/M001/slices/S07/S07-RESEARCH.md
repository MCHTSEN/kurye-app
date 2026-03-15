# S07: Analytics Dashboard — Research

**Date:** 2026-03-15

## Summary

S07 replaces the placeholder dashboard in `operasyon_dashboard_page.dart` with live analytics. The spec (section 2-1) requires: 3-month/1-month/1-week revenue totals, current month daily average, courier monthly + daily job counts, and active couriers today.

The existing codebase has everything needed at the data layer. `SiparisRepository.getHistory()` already fetches completed + cancelled orders with date filters. `KuryeRepository.getAll()` returns all couriers including `isOnline` status. No new repository methods or DB migrations are needed — all aggregation can happen client-side via Riverpod providers that fetch once and compute multiple metrics from the same dataset.

The main work is: (1) create analytics-specific Riverpod providers that call `getHistory` for 3 months of data and compute all revenue/performance metrics client-side, (2) replace the 3 TODO cards with real widgets showing the computed metrics, (3) add widget tests with seeded fake data proving the calculations are correct.

## Recommendation

**Client-side aggregation from a single 3-month fetch.** One `getHistory(startDate: now - 90 days)` call returns all completed+cancelled orders. Filter to `tamamlandi` only, then compute all revenue buckets (3mo/1mo/1wk) and courier performance metrics from the same list. This avoids multiple network calls and is appropriate for the business scale (hundreds to low thousands of orders). No Supabase RPC functions needed.

Create a dedicated Riverpod provider (e.g. `dashboardStatsProvider`) that:
1. Fetches 3-month history via `siparisRepositoryProvider`
2. Fetches all couriers via `kuryeRepositoryProvider`
3. Returns a `DashboardStats` model with all computed metrics

This keeps the dashboard page thin — it just reads one async provider and renders cards.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Fetching completed orders | `SiparisRepository.getHistory()` | Already handles date filtering and durum filtering (tamamlandi + iptal). Filter client-side for tamamlandi-only revenue. |
| Courier list with online status | `KuryeRepository.getAll()` | Returns all couriers with `isOnline` field — no new method needed. |
| Revenue total pattern | `operasyon_gecmis_page.dart` lines 283-290 | Uses `orders.fold<double>(0, (sum, s) => sum + (s.ucret ?? 0))` — reuse this pattern. |
| Widget test harness | `test/helpers/widgets/test_app.dart` | `pumpApp` with provider overrides — follow operasyon_ekran_page_test pattern. |
| Fake repositories | `FakeSiparisRepository`, `FakeKuryeRepository` | Both already support seeded data — no changes needed. |
| Card styling | `AppSectionCard` | Consistent card wrapper used throughout operasyon screens. |

## Existing Code and Patterns

- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — Placeholder with 3 TODO cards (Ciro Analizi, Kurye Performansı, Aktif Kuryeler) + drawer navigation. Replace card children; keep drawer and welcome message.
- `lib/product/siparis/siparis_providers.dart` — `siparisHistoryProvider` exists but takes named params for filters. For dashboard, we need a simpler 3-month fetch. Can use `siparisRepositoryProvider` directly in a new dashboard-specific provider.
- `lib/product/kurye/kurye_providers.dart` — `kuryeListProvider` fetches all couriers. Reuse for active courier count.
- `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart` — Revenue total widget pattern: `fold<double>` over `ucret` fields. Follow the same formatting (`₺${total.toStringAsFixed(2)}`).
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — Provider override pattern: seed fakes, override repo providers + profile provider, call `pumpApp`. Follow exactly.
- `test/helpers/fakes/fake_siparis_repository.dart` — `FakeSiparisRepository(seed: [...])` with `getHistory()` supporting date + durum filters. Works out of the box for dashboard tests.
- `test/helpers/fakes/fake_kurye_repository.dart` — `FakeKuryeRepository(seed: [...])` with `getAll()`. Ready for courier stat tests.

## Constraints

- `getHistory()` returns both `tamamlandi` and `iptal` orders (D026). Revenue calculations must filter to `tamamlandi` only — cancelled orders don't generate revenue.
- `ucret` is `NUMERIC(10,2)` in DB, `double?` in Dart model. Null ucret means price wasn't set — treat as 0 in sums.
- Courier `isOnline` is a boolean toggle — it reflects whether the courier set themselves active today, not whether they actually delivered orders. The spec says "bugünkü çalışan aktif kuryeler" which maps to `isOnline == true`.
- Dashboard is operasyon-only. The existing page already has `currentUserProfileProvider` wired for the welcome message.
- `very_good_analysis` linting rules apply — avoid unused imports, prefer const, named booleans, etc.
- The dashboard page has a Drawer — keep it intact. Only replace card content.

## Common Pitfalls

- **Counting iptal orders in revenue** — `getHistory` returns both tamamlandi and iptal. Must filter to `tamamlandi` before summing `ucret`. Easy to miss since the history page sums all results (including iptal with ucret=null).
- **Null ucret in completed orders** — Some completed orders may have null ucret (auto-pricing miss + manual entry skipped). Use `(s.ucret ?? 0)` in fold — already the established pattern.
- **Date boundary off-by-one** — "3-month" means 90 days back from now, "1-month" means 30 days, "1-week" means 7 days. Use `DateTime.now().subtract(Duration(days: N))` for consistency. For daily average, divide month revenue by `DateTime.now().day` (days elapsed in current month).
- **Empty state handling** — If no completed orders exist (new installation), all metrics should show ₺0.00 and 0 counts. Don't divide by zero for daily average.
- **Provider refresh** — Dashboard data is a snapshot, not realtime. Use `ref.invalidate()` or pull-to-refresh pattern to re-fetch. Don't use stream providers for aggregation — one-shot fetch is sufficient.

## Open Risks

- **Date calculation edge cases** — "3-month" in the spec could mean calendar months or 90 days. Using 90/30/7 days is simpler and close enough. If the user wants exact calendar month boundaries, the provider logic would need adjustment — but the spec language ("3 aylık", "1 aylık", "bir haftalık") is casual enough to justify day-based intervals.
- **Performance if order volume grows** — Fetching 3 months of orders client-side is fine for current scale (~hundreds of orders/month). If volume reaches thousands/month, consider Supabase RPC aggregate functions. Not a concern for MVP.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| Flutter | `flutter/skills@flutter-layout` | available (1.2K installs) — not needed, layout is straightforward cards |
| Flutter | `flutter/skills@flutter-theming` | available (1.1K installs) — not needed, using existing AppSectionCard |
| Supabase | `supabase/agent-skills@supabase-postgres-best-practices` | available (34.2K installs) — not needed, no DB changes required |
| Mobile Design | `mobile-design` | installed — not needed for this slice, standard dashboard layout |

No skill installation recommended — the work is straightforward data aggregation + card rendering following established codebase patterns.

## Sources

- `moto-kurye.md` section 2-1 — spec for analytics dashboard requirements
- `operasyon_dashboard_page.dart` — existing placeholder to replace
- `operasyon_gecmis_page.dart` — revenue calculation pattern
- `siparis_repository.dart` — `getHistory()` contract with date filters
- `kurye_repository.dart` — `getAll()` contract with `isOnline` field
- `fake_siparis_repository.dart` / `fake_kurye_repository.dart` — test infrastructure ready
- `DECISIONS.md` — D026 (history query filters), D027 (ID-to-name resolution pattern)

## Implementation Sketch

### Task breakdown estimate

**T01 — Dashboard stats provider + model** (~15 min)
- Create `DashboardStats` immutable model (revenue3mo, revenue1mo, revenue1wk, dailyAvg, courierStats list, activeCourierCount)
- Create `CourierStat` model (kuryeId, ad, monthlyJobs, dailyJobs)
- Create `dashboardStatsProvider` Riverpod provider that:
  - Fetches `getHistory(startDate: now - 90 days)` 
  - Fetches `getAll()` from kurye repo
  - Computes all metrics from the two lists
  - Returns `DashboardStats`
- Unit test the computation logic

**T02 — Dashboard UI** (~15 min)
- Replace 3 TODO cards in `operasyon_dashboard_page.dart`:
  - **Ciro Analizi**: 3mo / 1mo / 1wk totals in a grid, daily average below
  - **Kurye Performansı**: Table/list of couriers with monthly + daily job counts
  - **Aktif Kuryeler**: Count badge + list of currently online courier names
- Wire to `dashboardStatsProvider`
- Add refresh action (pull-to-refresh or AppBar action)
- Widget tests: seed orders + couriers → verify rendered totals and courier stats

### Key test scenarios
1. Revenue cards show correct sums for each period (seed orders at different dates)
2. Daily average = current month revenue / days elapsed
3. Courier job counts group correctly by kurye_id
4. Active couriers shows only isOnline == true couriers
5. Empty state (no orders) shows ₺0.00 everywhere
