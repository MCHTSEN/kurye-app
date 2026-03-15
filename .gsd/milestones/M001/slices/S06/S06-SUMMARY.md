---
id: S06
parent: M001
milestone: M001
provides:
  - Server-side filtered history query (getHistory) on SiparisRepository
  - siparisHistoryProvider Riverpod family with 5 optional filter params
  - Full OperasyonGecmisPage with DataTable, filter bar, edit panel, revenue total
requires:
  - slice: S04
    provides: SiparisRepository with update() partial field map, Siparis domain model
affects:
  - S08
key_files:
  - packages/backend_core/lib/src/siparis_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_repository.dart
  - test/helpers/fakes/fake_siparis_repository.dart
  - lib/product/siparis/siparis_providers.dart
  - lib/feature/operasyon/presentation/operasyon_gecmis_page.dart
  - test/feature/operasyon/operasyon_gecmis_page_test.dart
key_decisions:
  - History query filters to tamamlandi + iptal orders only
  - Edit panel uses DB column names for partial update via SiparisRepository.update()
  - Revenue total computed as fold over filtered results, reactive to filter changes
  - Date range defaults to last 30 days with endDate at 23:59:59 for inclusive range
  - Filter müşteri change cascades to reset çıkış/uğrama selections
  - İptal button sets durum to iptal — no delete functionality (spec: "silemez, sadece iptal edebilir")
patterns_established:
  - Server-side PostgREST filter chaining for optional multi-field queries
  - ID-to-name resolution via musteriMap/ugramaMap/kuryeMap built from list providers
  - scrollUntilVisible with Scrollable.first finder for nested scroll views in widget tests
observability_surfaces:
  - AppLogger .i() in SupabaseSiparisRepository.getHistory logging filter params and row count
  - _log.e() in OperasyonGecmisPage for order update and cancel failures
drill_down_paths:
  - .gsd/milestones/M001/slices/S06/tasks/T01-SUMMARY.md
  - .gsd/milestones/M001/slices/S06/tasks/T02-SUMMARY.md
duration: ~30 minutes
verification_result: passed
completed_at: 2026-03-15
---

# S06: Order History & Editing

**Operations can view past orders in an Excel-like DataTable with name-resolved columns, filter by date/customer/çıkış/uğrama, edit orders via a top panel, and see a running revenue total — completing R014.**

## What Happened

**T01** added `getHistory()` to the `SiparisRepository` contract with 5 optional named params (startDate, endDate, musteriId, cikisId, ugramaId). The Supabase implementation chains `.inFilter('durum', [tamamlandi, iptal])` with optional `.gte`/`.lte`/`.eq` filters server-side. The fake implementation mirrors this with client-side filtering. A `siparisHistoryProvider` family provider was generated for UI consumption.

**T02** replaced the placeholder `OperasyonGecmisPage` with a full ConsumerStatefulWidget containing four sections: (1) revenue card showing sum of ücret from filtered results, (2) tap-to-edit panel with müşteri/çıkış/uğrama cascading dropdowns, ücret, durum, and not1 fields — save calls `SiparisRepository.update()` with DB column names then invalidates the history provider, (3) filter bar with date range picker and cascading dropdowns (müşteri selection resets stop dropdowns), and (4) DataTable with columns Tarih/Müşteri/Çıkış/Uğrama/Kurye/Ücret/Durum — all IDs resolved to human-readable names via maps built from existing list providers.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (30 info-level items, all pre-existing)
- `flutter test` — 97/97 tests pass, including 5 new widget tests:
  - Table renders with seeded order data showing resolved names
  - Revenue total shows correct sum
  - Tap row populates edit panel with order data
  - Edit panel save triggers update and refreshes list
  - Filter application changes displayed results

## Requirements Advanced

- R014 — Operations order history with filtering & editing: fully implemented with DataTable, multi-dimension filters, edit panel, revenue total

## Requirements Validated

- R014 — Widget tests prove table rendering with name resolution, filtering, tap-to-edit flow, save/refresh cycle, and revenue total calculation

## New Requirements Surfaced

- none

## Requirements Invalidated or Re-scoped

- none

## Deviations

None.

## Known Limitations

- `DropdownButtonFormField.value` is deprecated in Flutter 3.33+ (should use `initialValue`). This is a codebase-wide pattern across operasyon_ekran_page.dart and operasyon_gecmis_page.dart. Should be addressed in a separate cleanup task.

## Follow-ups

- Codebase-wide migration from `DropdownButtonFormField.value` to `initialValue` when controlled dropdown pattern is resolved upstream

## Files Created/Modified

- `packages/backend_core/lib/src/siparis_repository.dart` — added `getHistory()` abstract method
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — server-side filtered implementation
- `test/helpers/fakes/fake_siparis_repository.dart` — client-side filtered fake implementation
- `lib/product/siparis/siparis_providers.dart` — added `siparisHistory` provider
- `lib/product/siparis/siparis_providers.g.dart` — regenerated by build_runner
- `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart` — full history page replacing placeholder
- `test/feature/operasyon/operasyon_gecmis_page_test.dart` — 5 widget tests

## Forward Intelligence

### What the next slice should know
- S06 does not use realtime — it queries on-demand with `getHistory()`. S07 (analytics) will likely need similar aggregate queries but with SUM/COUNT, not row-level data.
- The ID-to-name map pattern (musteriMap, ugramaMap, kuryeMap) is now established in two pages (operasyon_ekran_page and operasyon_gecmis_page). If S07 needs it too, consider extracting to a shared provider.

### What's fragile
- The cascading dropdown state in the edit panel relies on `setState` resets when müşteri changes — if someone adds more cascading fields, the reset logic needs extension.

### Authoritative diagnostics
- `SupabaseSiparisRepository.getHistory` logs at `.i()` level with filter params and row count — grep `SupabaseSiparisRepo` in logs to verify query behavior.

### What assumptions changed
- None — slice executed as planned.
