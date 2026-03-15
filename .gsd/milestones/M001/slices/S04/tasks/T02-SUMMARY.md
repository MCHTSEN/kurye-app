---
id: T02
parent: S04
milestone: M001
provides:
  - 3-panel operasyon dispatch screen (order creation, kurye bekleyenler, devam edenler)
  - Courier assignment flow with SiparisLog audit trail
  - Finish flow with auto-pricing from getRecentPricing() and manual pricing fallback dialog
  - FakeSiparisLogRepository for testing
  - 5 widget tests covering all dispatch flows
key_files:
  - lib/feature/operasyon/presentation/operasyon_ekran_page.dart
  - test/feature/operasyon/operasyon_ekran_page_test.dart
  - test/helpers/fakes/fake_siparis_log_repository.dart
key_decisions:
  - Copy selection sets before iterating in assign/finish flows — stream listener clears selections on new data, causing ConcurrentModificationError if iterating the live set
  - Manual pricing dialog uses showDialog<double> with nullable return — null means user cancelled, order is skipped
  - Müşteri dropdown resets all stop dropdowns and hides form fields until müşteri selected — prevents stale stop references
patterns_established:
  - Snapshot selection state before async iteration to avoid concurrent modification from stream listeners
  - FakeSiparisLogRepository follows same in-memory store pattern as other fakes
observability_surfaces:
  - "SnackBar on assignment success (count + 'kurye atandı') and finish success (count + 'tamamlandı')"
  - "SnackBar on errors with exception message for assignment and finish failures"
  - "SiparisLog created on every status transition (kuryeBekliyor→devamEdiyor on assign, devamEdiyor→tamamlandi on finish)"
  - "Logger.w() on auto-pricing miss with musteri/cikis/ugrama context"
  - "Logger.e() on assignment and finish failures"
duration: ~20min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Build 3-panel dispatch screen with assignment and finish flows

**Replaced placeholder OperasyonEkranPage with a fully functional 3-panel dispatch screen supporting order creation, courier assignment with status logging, and finish with auto-pricing/manual pricing fallback.**

## What Happened

Built the 3-panel operations dispatch screen:

**Panel 1 — Order Creation:** Added müşteri dropdown (from `musteriListProvider`) that cascades into stop dropdowns (from `ugramaListByMusteriProvider`). Changing müşteri resets all stop selections. Form fields only appear after müşteri is selected. Submit creates order via `SiparisRepository.create()` with `olusturanId` from current user profile.

**Panel 2 — Kurye Bekleyenler:** Subscribes to `siparisStreamActiveProvider`, filters to `durum == kuryeBekliyor`. Displays as `CheckboxListTile` items with route labels. Bottom section has courier dropdown (active couriers only from `kuryeListProvider`) and "Ata" button. Button disabled when no orders selected or no courier chosen.

**Panel 3 — Devam Edenler:** Same stream, filters to `durum == devamEdiyor`. Displays with courier ID in subtitle. "Bitir" button disabled when no orders selected.

**Assign flow:** Updates order with `kurye_id`, `atanma_saat`, `durum: devam_ediyor`. Creates `SiparisLog` with `eskiDurum: kuryeBekliyor` → `yeniDurum: devamEdiyor`.

**Finish flow:** Calls `getRecentPricing()` for auto-pricing. If match found, uses its `ucret`. If no match, shows manual pricing dialog. Updates order with `ucret`, `bitis_saat`, `durum: tamamlandi`. Creates `SiparisLog`.

**Stream-driven selection clearing:** `ref.listen` on the stream clears both selection sets when new data arrives. Selection sets are snapshot-copied before async iteration to avoid `ConcurrentModificationError`.

Created `FakeSiparisLogRepository` for test infrastructure. Wrote 5 widget tests covering all flows.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (21 pre-existing infos only)
- `flutter test` — 86/86 pass (5 new in `operasyon_ekran_page_test.dart`)
- `flutter build ios --simulator` — succeeds

### Slice-level verification status (final task — all pass):
- ✅ `flutter analyze` — 0 errors, 0 warnings
- ✅ `flutter test` — all 86 pass including:
  - `test/domain/siparis_log_test.dart` — SiparisLog fromJson/toJson roundtrip
  - `test/feature/operasyon/operasyon_ekran_page_test.dart` — 5 tests: 3-panel rendering, courier assignment, auto-pricing finish, manual pricing fallback
- ✅ `flutter build ios --simulator` — succeeds
- ✅ `FakeSiparisRepository` supports `update()` and `getRecentPricing()`

## Diagnostics

- SnackBars on assignment/finish success and errors
- Query `siparis_log` table to see all status transitions with timestamps and actor IDs
- Grep `Logger` output for auto-pricing miss warnings (musteri/cikis/ugrama context)
- Assignment and finish failures logged at `.e()` level with exception details

## Deviations

None.

## Known Issues

- Route labels in the dispatch panels display raw ugrama IDs (`ugrama-1 → ugrama-2`) instead of human-readable stop names. A future improvement would resolve ugrama names from the provider. This doesn't affect functionality.
- The `DropdownButtonFormField.value` parameter shows deprecation infos (Flutter 3.33+ renamed to `initialValue`). This is consistent with the existing codebase pattern in `musteri_siparis_page.dart` — a codebase-wide migration task, not specific to this screen.

## Files Created/Modified

- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — fully replaced placeholder with 3-panel dispatch screen (~400 lines)
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — 5 widget tests covering all dispatch flows
- `test/helpers/fakes/fake_siparis_log_repository.dart` — new in-memory fake for SiparisLogRepository
