---
estimated_steps: 7
estimated_files: 2
---

# T02: Build order history page with table, filters, edit panel, and revenue total

**Slice:** S06 — Order History & Editing
**Milestone:** M001

## Description

Replace the placeholder `OperasyonGecmisPage` with the full R014 implementation. Excel-like data table of past orders, multi-dimension filter bar (date range, müşteri, çıkış, uğrama), tap-to-edit panel at top, and running revenue total. All ID columns resolved to human-readable names via existing list providers.

## Steps

1. Replace `OperasyonGecmisPage` with a `ConsumerStatefulWidget`. Add local state for filter values (`DateTimeRange?`, `String?` müşteriId, `String?` cikisId, `String?` ugramaId) and selected order for editing (`Siparis?`). Default date range to last 30 days.
2. Build the revenue total card at top — `AppSectionCard` showing `Toplam Ciro: ₺X.XX` computed as sum of `ucret` from the filtered results list. Updates reactively when filters change.
3. Build the edit panel — visible only when a row is tapped. `AppSectionCard` with editable fields (müşteri dropdown, çıkış/uğrama dropdowns, ücret text field, durum dropdown, not1 text). Save button calls `SiparisRepository.update()` with partial field map (DB column names per D018), then `ref.invalidate()` on the history provider. İptal button sets durum to `iptal`. No delete button.
4. Build the filter bar — `AppSectionCard` with: date range picker (using `showDateRangePicker()`), müşteri dropdown (from `musteriListProvider`), çıkış dropdown (from `ugramaListProvider` or filtered by müşteri), uğrama dropdown (same). When müşteri changes, reset çıkış/uğrama selections. Clear button resets all filters to defaults.
5. Build the data table — `SingleChildScrollView` wrapping `DataTable` with columns: Tarih, Müşteri, Çıkış, Uğrama, Kurye, Ücret, Durum. Build ID→name maps from `musteriListProvider`, `ugramaListProvider`, `kuryeListProvider`. Tap row → set selected order → populate edit panel. Watch `siparisHistoryProvider` with current filter values.
6. Write widget tests in `test/feature/operasyon/operasyon_gecmis_page_test.dart`:
   - Table renders with seeded order data showing resolved names
   - Revenue total shows correct sum
   - Tap row populates edit panel with order data
   - Edit panel save triggers update and refreshes list
   - Filter application changes displayed results
7. Verify: `flutter analyze` clean, `flutter test` — all tests pass including new ones.

## Must-Haves

- [ ] Data table with all required columns, name-resolved from IDs
- [ ] Filter bar with date range, müşteri, çıkış, uğrama — cascading where müşteri affects stop dropdowns
- [ ] Tap-to-edit panel following master-detail pattern (D011)
- [ ] Edit panel uses `SiparisRepository.update()` with DB column names (D018)
- [ ] Revenue total reflects currently filtered results
- [ ] No delete button — only edit fields and iptal
- [ ] Default 30-day date range on initial load
- [ ] Widget tests covering table render, filter, edit, revenue total

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all pass, including 5 new widget tests in `operasyon_gecmis_page_test.dart`

## Inputs

- `lib/product/siparis/siparis_providers.dart` — `siparisHistoryProvider` from T01
- `lib/product/musteri/musteri_providers.dart` — `musteriListProvider` for müşteri dropdown and name map
- `lib/product/ugrama/ugrama_providers.dart` — `ugramaListProvider` for çıkış/uğrama dropdowns and name map
- `lib/product/kurye/kurye_providers.dart` — `kuryeListProvider` for kurye name map
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — reference for `SiparisRepository.update()` usage pattern
- `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart` — reference for date range picker and ugrama name map pattern
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — reference for test setup with fake repos and provider overrides

## Expected Output

- `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart` — full history page replacing placeholder
- `test/feature/operasyon/operasyon_gecmis_page_test.dart` — 5 widget tests proving table, filters, edit, revenue
