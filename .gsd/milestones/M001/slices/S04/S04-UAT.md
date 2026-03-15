# S04: Operations Dispatch Screen — UAT

**Milestone:** M001
**Written:** 2026-03-15

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: All dispatch flows (assignment, finish, auto-pricing, manual pricing) are covered by widget tests with seeded fakes. Cross-role realtime proof deferred to S08.

## Preconditions

- `flutter test` passes (86/86)
- `flutter analyze` clean (0 errors, 0 warnings)
- `flutter build ios --simulator` succeeds
- All fakes (FakeSiparisRepository, FakeKuryeRepository, FakeSiparisLogRepository) operational

## Smoke Test

Run `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` — all 5 tests pass, proving 3-panel rendering, assignment, and finish flows work.

## Test Cases

### 1. 3-panel rendering with order data

1. Seed FakeSiparisRepository with orders in kurye_bekliyor and devam_ediyor statuses
2. Render OperasyonEkranPage with all required providers overridden
3. **Expected:** "Sipariş Oluştur" form section visible, "Kurye Bekleyenler" panel shows kurye_bekliyor orders, "Devam Edenler" panel shows devam_ediyor orders

### 2. Courier assignment flow

1. Seed one order with kurye_bekliyor status
2. Select order via checkbox, pick a courier from dropdown, tap "Ata"
3. **Expected:** Order updated with kurye_id, atanma_saat, and durum=devam_ediyor. SiparisLog created with eskiDurum=kuryeBekliyor, yeniDurum=devamEdiyor. Success SnackBar shown.

### 3. Finish with auto-pricing

1. Seed one order with devam_ediyor status
2. Seed a completed historical order with same musteri+cikis+ugrama and ucret=50.0
3. Select the devam_ediyor order, tap "Bitir"
4. **Expected:** Order completed with ucret=50.0 from auto-pricing, bitis_saat set, durum=tamamlandi. SiparisLog created.

### 4. Manual pricing fallback

1. Seed one order with devam_ediyor status
2. No matching historical order exists for getRecentPricing()
3. Select order, tap "Bitir"
4. **Expected:** Manual pricing dialog appears. Enter price → order completed with entered ucret. SiparisLog created.

### 5. Order creation form cascading

1. Render OperasyonEkranPage
2. Select a müşteri from dropdown
3. **Expected:** Stop dropdowns (Çıkış, Uğrama, Uğrama1) populated with that müşteri's stops. Changing müşteri resets all stop selections.

## Edge Cases

### No orders in either panel

1. Seed no orders
2. **Expected:** Both panels render empty (no crash, no loading spinner stuck)

### No active couriers for assignment

1. Seed orders in kurye_bekliyor but no active couriers
2. **Expected:** Courier dropdown empty, "Ata" button disabled

### Auto-pricing miss with dialog cancel

1. No matching historical order, dialog shown
2. User cancels dialog (dismisses without entering price)
3. **Expected:** Order is NOT completed — stays in devam_ediyor status

## Failure Signals

- Widget test failures in `operasyon_ekran_page_test.dart`
- SnackBar errors during assign/finish operations
- `Logger.e()` output for assignment or finish failures
- `Logger.w()` for auto-pricing misses (expected when no historical match)
- SiparisLog entries missing after status transitions

## Requirements Proved By This UAT

- R009 — 3-panel dispatch screen renders with correct panel split
- R010 — Courier assignment via checkbox + dropdown + Ata button
- R012 — Auto-pricing from historical match; manual fallback when no match
- R018 — SiparisLog audit trail on every status transition

## Not Proven By This UAT

- R008 cross-role realtime — customer creating order appears on ops screen without refresh (deferred to S08)
- Live Supabase integration — widget tests use fakes, not real DB
- Concurrent multi-operator scenarios — single-user dispatch tested only
- Composite index migration performance — migration file written but not yet applied to production DB

## Notes for Tester

- Route labels show raw ugrama IDs, not human-readable names — this is a known display limitation, not a bug.
- DropdownButtonFormField.value deprecation infos are codebase-wide and don't affect functionality.
- The manual pricing dialog returns null on cancel, skipping that order — this is intentional behavior.
