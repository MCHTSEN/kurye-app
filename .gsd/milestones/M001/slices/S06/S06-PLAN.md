# S06: Order History & Editing

**Goal:** Operations can view past orders in an Excel-like table, filter by date/customer/çıkış/uğrama, edit orders via a top panel, and see a running revenue total.
**Demo:** Open the Geçmiş Siparişler page → see completed orders in a data table with name-resolved columns → filter by date range and customer → tap an order → edit panel populates at top → update a field → table refreshes with new value. Revenue total reflects filtered results.

## Must-Haves

- Server-side filtered history query on `SiparisRepository` (date range, müşteri, çıkış, uğrama)
- Excel-like data table with human-readable names (not raw IDs)
- Filter bar with date range picker, müşteri/çıkış/uğrama dropdowns
- Tap-to-edit panel at top of page (master-detail pattern D011)
- Running revenue total computed from filtered results
- No delete — only edit/cancel (spec: "silemez, sadece iptal edebilir")
- Default date range (last 30 days) to prevent unbounded queries

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all tests pass, including:
  - `test/feature/operasyon/operasyon_gecmis_page_test.dart` — widget tests covering: table renders with name-resolved columns, filter bar filters results, tap row populates edit panel, edit submits update and refreshes list, revenue total reflects filtered data

## Tasks

- [x] **T01: Add getHistory() to SiparisRepository with server-side filtering** `est:25m`
  - Why: The history page needs a filtered query for completed/cancelled orders. No existing method returns all orders with filter support — `getByMusteriId` and `getByDurum` are single-dimension only.
  - Files: `packages/backend_core/lib/src/siparis_repository.dart`, `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`, `test/helpers/fakes/fake_siparis_repository.dart`, `lib/product/siparis/siparis_providers.dart`, `lib/product/siparis/siparis_providers.g.dart`
  - Do: Add `getHistory()` method to contract with optional named params (startDate, endDate, musteriId, cikisId, ugramaId). Implement in Supabase repo using `.gte()`/`.lte()`/`.eq()` chaining. Implement in fake repo with client-side filtering. Add `siparisHistoryProvider` family provider. Run `dart run build_runner build`.
  - Verify: `flutter analyze` clean, `flutter test` passes (existing tests unbroken)
  - Done when: `siparisHistoryProvider` returns filtered order list from both Supabase and fake implementations

- [x] **T02: Build order history page with table, filters, edit panel, and revenue total** `est:45m`
  - Why: Replaces the placeholder `OperasyonGecmisPage` with full R014 implementation — the main deliverable of this slice.
  - Files: `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`, `test/feature/operasyon/operasyon_gecmis_page_test.dart`
  - Do: Replace stub with ConsumerStatefulWidget. Build: (1) revenue total card at top showing sum of `ucret` from filtered results, (2) filter bar with date range picker + müşteri/çıkış/uğrama dropdowns in AppSectionCard, (3) data table with columns: tarih, müşteri, çıkış, uğrama, kurye, ücret, durum — all name-resolved via ID→name maps from existing list providers, (4) tap row → populate edit panel at top with editable fields, (5) save button calls `SiparisRepository.update()` with partial field map then `ref.invalidate()` on history provider. Çıkış/uğrama filter dropdowns cascade from müşteri selection. Default date range: last 30 days. Widget tests: table rendering with seeded data, filter application, edit panel population, update flow, revenue total calculation.
  - Verify: `flutter analyze` clean, `flutter test` passes including new widget tests
  - Done when: History page renders filtered orders with names, edit panel works, revenue total updates on filter change, widget tests pass

## Files Likely Touched

- `packages/backend_core/lib/src/siparis_repository.dart`
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`
- `test/helpers/fakes/fake_siparis_repository.dart`
- `lib/product/siparis/siparis_providers.dart`
- `lib/product/siparis/siparis_providers.g.dart`
- `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`
- `test/feature/operasyon/operasyon_gecmis_page_test.dart`
