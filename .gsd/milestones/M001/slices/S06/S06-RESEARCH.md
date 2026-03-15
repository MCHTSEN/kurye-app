# S06: Order History & Editing — Research

**Date:** 2026-03-15

## Summary

S06 delivers R014 — an operations-facing order history page with Excel-like table view, multi-dimension filtering (date, customer, çıkış, uğrama), inline editing via a top panel, and a running revenue total. The spec is explicit: "Excell görünümü gibi olsun. Tarihe-Müşteriye-Cikis-Ugrama diye Süzme yapabilelim. Üst tarafta toplam ciro aktif alarak görünsün. Siparişe tıkladığımızda yukarıya bir panel koyalım düzenleme ve güncelleme yapabilelim."

The existing codebase is well-prepared. The `OperasyonGecmisPage` stub already exists with routing wired (`/operasyon/gecmis`), navigation from the dashboard drawer works, and `SiparisRepository` already has `update(id, fields)` for partial updates (D018). The main gap is a **filtered history query** — `SiparisRepository` has no `getAll()` or filtered query for completed/cancelled orders. We need to add a `getHistory()` method with optional date range, customer, çıkış, and uğrama filters. The UI follows the established master-detail CRUD pattern (D011) — form/edit panel at top, data table at bottom.

Name resolution is the other key concern. The `Siparis` model stores IDs for müşteri, çıkış, uğrama, and kurye. The history table must display human-readable names, requiring lookup maps from the existing `musteriListProvider`, `ugramaListProvider`, and `kuryeListProvider`. The customer history page (`MusteriGecmisPage`) already demonstrates this pattern with ugrama name maps.

## Recommendation

Two tasks:
1. **T01 — Data layer**: Add `getHistory()` to `SiparisRepository` contract + Supabase implementation with server-side filtering (date range, musteriId, cikisId, ugramaId). Add matching `FakeSiparisRepository` implementation. Add a Riverpod provider. No DB migration needed — existing table and indexes suffice.
2. **T02 — History page UI**: Replace the placeholder `OperasyonGecmisPage` with the full implementation. Top: revenue total card (running sum of `ucret` from filtered results). Middle: filter bar (date range picker, müşteri dropdown, çıkış dropdown, uğrama dropdown). Bottom: data table (Flutter `DataTable` or `SingleChildScrollView` + `Table` for Excel feel). Tap a row → populate edit panel at top. Edit panel uses `SiparisRepository.update()` for partial field updates.

Server-side filtering is preferred over client-side for scalability — order history will grow unbounded. The Supabase PostgREST query builder supports `.gte()`, `.lte()`, `.eq()` chaining cleanly.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Partial order update | `SiparisRepository.update(id, Map<String, dynamic>)` (D018) | Already handles concurrent multi-role writes safely |
| Date range picker | Flutter's `showDateRangePicker()` | Already used in `MusteriGecmisPage` — proven pattern |
| Section layout | `AppSectionCard` widget | Consistent card styling across all ops pages |
| Name resolution | `musteriListProvider`, `ugramaListProvider`, `kuryeListProvider` | Build ID→name maps from existing providers |
| Test scaffolding | `TestApp.pumpApp()` + all fake repositories | All fakes exist: `FakeSiparisRepository`, `FakeMusteriRepository`, `FakeUgramaRepository`, `FakeKuryeRepository` |

## Existing Code and Patterns

- `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart` — Placeholder stub to replace. Route already wired at `/operasyon/gecmis`.
- `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart` — Reference pattern for date filtering, ugrama name maps, and history list layout. Client-side filtering (fine for customer's own orders), but S06 needs server-side.
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart` — Master-detail CRUD pattern (D011): form at top in AppSectionCard, list at bottom. Tap to populate form for editing. Use same pattern for order editing.
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — `SiparisRepository.update()` usage with partial field maps. Lines 129 and 212 show the pattern.
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — All existing query patterns (`.eq()`, `.order()`, `.limit()`, `.select()`). Extend with `.gte()/.lte()` for date filtering.
- `lib/product/siparis/siparis_providers.dart` — Add new `siparisHistoryProvider` here for the filtered query.
- `test/helpers/fakes/fake_siparis_repository.dart` — In-memory fake with store. Add `getHistory()` implementation with client-side filtering.
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — Test setup pattern: fake repos + provider overrides. Follow for the history page test.

## Constraints

- **RLS allows operasyon full access** — `siparisler_operasyon` policy grants FOR ALL to operasyon role. No RLS issues for querying all orders.
- **No getAll on SiparisRepository** — Must add a new query method. Existing methods are `getByMusteriId`, `getByDurum`, `getRecentPricing`, and the stream methods. None returns all completed orders with filters.
- **Name resolution requires 3 extra provider watches** — müşteri, uğrama, kurye lists must all load for the name map. These are cached Riverpod providers so no extra DB calls after first load.
- **Siparis.update() uses raw field map** — Caller must use DB column names (`musteri_id`, not `musteriId`). Don't include `updated_at` (BEFORE UPDATE trigger).
- **DropdownButtonFormField.value deprecation** — Known codebase-wide issue (D016). Use the same pattern as other pages for consistency.
- **Spec says "silemez, sadece iptal edebilir"** — Operasyon cannot delete orders, only cancel. The edit panel should allow editing fields and potentially cancelling, but no delete button.
- **Cascading dropdown dependency in filter** — Uğrama dropdown values depend on selected müşteri. Same pattern as order creation form. When müşteri filter changes, çıkış/uğrama dropdowns must reload.

## Common Pitfalls

- **Unbounded query without date filter** — A bare `SELECT * FROM siparisler` with no date filter could return thousands of rows. Default to last 30 days on initial load. Make the date range required or provide a sensible default.
- **Revenue total calculated from wrong set** — The running total must reflect the *filtered* results, not all orders. Compute from the returned list, not a separate query.
- **Edit panel state after update** — After editing an order, the list must refresh to show updated values. Use `ref.invalidate()` on the history provider after a successful update.
- **Ugrama dropdown cascade in filter bar** — If müşteri filter is null (all customers), uğrama dropdown should show all uğramalar or be disabled. Different from order creation where müşteri is required.
- **ID display in table** — S04 known limitation: "Route labels display raw ugrama IDs instead of human-readable stop names." Must solve this for the history table — build ID→name maps.

## Open Risks

- **DataTable performance with many rows** — Flutter's `DataTable` can get slow with hundreds of rows. If history grows large, may need paginated loading or `PaginatedDataTable`. For MVP with server-side filtering + date range defaults, standard `DataTable` should be fine.
- **Filter combination explosion** — 4 filter dimensions could produce empty results frequently. Need clear "no results" state and easy filter clearing.
- **Editing fields during concurrent access** — If two operasyon users edit the same order, last-write-wins via partial update (D018). Acceptable for MVP but worth noting.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| Flutter | `flutter/skills@flutter-layout` | available (1.2K installs) — could help with DataTable/Excel layout |
| Flutter | `flutter/skills@flutter-performance` | available (1.2K installs) — relevant if DataTable perf becomes an issue |
| Supabase | `supabase/agent-skills@supabase-postgres-best-practices` | available (34.2K installs) — not needed, queries are straightforward |
| Mobile design | `mobile-design` | installed — general mobile patterns |
| Senior mobile | `senior-mobile` | installed — expert mobile dev |

None are critical for this slice. The work is standard CRUD + table UI following established patterns.

## Sources

- Spec line 139: "Geçmiş Siparişler Ekranı" section defines Excel-like table, filters, revenue total, edit panel
- Spec line 13: "Siparişi silemez, sadece iptal edebilir" — no delete, only cancel
- D011: Master-detail CRUD page pattern
- D018: Partial update via `Map<String, dynamic>`
- S04 Summary: `SiparisRepository.update()` and `getRecentPricing()` patterns
- S04 Forward Intelligence: field map uses DB column names, omit `updated_at`
