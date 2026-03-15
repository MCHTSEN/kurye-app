---
id: T02
parent: S06
milestone: M001
provides:
  - Full OperasyonGecmisPage with data table, filter bar, edit panel, and revenue total
key_files:
  - lib/feature/operasyon/presentation/operasyon_gecmis_page.dart
  - test/feature/operasyon/operasyon_gecmis_page_test.dart
key_decisions:
  - Edit panel uses DB column names (musteri_id, cikis_id, ugrama_id, durum, ucret, not1) per D018 for partial update via SiparisRepository.update()
  - Revenue total computed as fold over filtered results (reactive to filter changes)
  - Date range defaults to last 30 days; endDate passed as 23:59:59 for inclusive range
  - Filter müşteri change cascades to reset çıkış/uğrama selections
  - DataTable with showCheckboxColumn:false — tap row triggers edit panel population
  - İptal button sets durum to iptal via update(), no delete functionality
patterns_established:
  - ID-to-name resolution via musteriMap/ugramaMap/kuryeMap built from list providers
  - scrollUntilVisible with Scrollable.first finder for reliable widget test scrolling in pages with nested scroll views
observability_surfaces:
  - Logger at module level (_log) for order update and cancel failures
duration: ~25 minutes
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Built order history page with table, filters, edit panel, and revenue total

**Replaced placeholder OperasyonGecmisPage with full R014 implementation — Excel-like DataTable, multi-dimension filter bar, tap-to-edit panel, and running revenue total with name-resolved columns.**

## What Happened

Replaced the placeholder `OperasyonGecmisPage` (ConsumerWidget with a TODO) with a `ConsumerStatefulWidget` containing four sections:

1. **Revenue card** — `AppSectionCard` showing `₺X.XX` computed as sum of `ucret` from filtered results. Updates reactively when filters change.

2. **Edit panel** — Visible only when a DataTable row is tapped. Contains müşteri/çıkış/uğrama dropdowns (cascading — müşteri change resets stops), ücret text field, durum dropdown (tamamlandi/iptal), not1 text field. Save calls `SiparisRepository.update()` with DB column names, then invalidates `siparisHistoryProvider`. İptal button sets durum to iptal. No delete button.

3. **Filter bar** — Date range picker (default 30 days), müşteri dropdown, çıkış/uğrama dropdowns filtered by selected müşteri. Clear button resets all to defaults.

4. **Data table** — `SingleChildScrollView` wrapping `DataTable` with columns: Tarih, Müşteri, Çıkış, Uğrama, Kurye, Ücret, Durum. All ID columns resolved to human-readable names via musteriMap, ugramaMap, kuryeMap built from list providers. Tap row populates edit panel.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (30 info-level items, all pre-existing deprecation/style)
- `flutter test` — 97 tests pass, including 5 new:
  - (a) table renders with seeded order data showing resolved names ✅
  - (b) revenue total shows correct sum ✅
  - (c) tap row populates edit panel with order data ✅
  - (d) edit panel save triggers update and refreshes list ✅
  - (e) filter application changes displayed results ✅

### Slice-level verification:
- `flutter analyze` — ✅ 0 errors, 0 warnings
- `flutter test` — ✅ all pass including operasyon_gecmis_page_test.dart

## Diagnostics

`_log.e()` captures order update and cancel failures with the exception. Snackbar surfaces errors to the user. Provider invalidation ensures table refresh after edits.

## Deviations

None.

## Known Issues

- `DropdownButtonFormField.value` is deprecated in Flutter 3.33+ (should use `initialValue`). This is a codebase-wide pattern — 6 instances in operasyon_ekran_page.dart, 7 in this file. Should be addressed in a separate cleanup task.

## Files Created/Modified

- `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart` — Full history page replacing placeholder (ConsumerStatefulWidget with revenue card, edit panel, filter bar, data table)
- `test/feature/operasyon/operasyon_gecmis_page_test.dart` — 5 widget tests covering table render, revenue total, tap-to-edit, save flow, filter application
