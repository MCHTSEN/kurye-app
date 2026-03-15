# S05: Courier Workflow — UAT

**Milestone:** M001
**Written:** 2026-03-15

## UAT Type

- UAT mode: mixed (artifact-driven for unit verification, live-runtime deferred to S08)
- Why this mode is sufficient: Widget tests cover all must-haves (toggle, order list, timestamp punch, disabled state, null kurye). Cross-role realtime integration requires all three role screens and is explicitly scoped to S08.

## Preconditions

- `flutter analyze` — 0 errors
- `flutter test` — 92/92 pass
- Supabase project running with `kuryeler` and `siparisler` tables
- At least one kurye record linked to an auth user
- At least one sipariş with `durum = devam_ediyor` and `kurye_id` set

## Smoke Test

Log in as a kurye user → courier main screen loads → active/passive toggle visible → at least one assigned order shown with timestamp buttons.

## Test Cases

### 1. Active/passive toggle

1. Log in as kurye
2. Observe toggle shows current `is_online` state (Aktif/Pasif)
3. Tap toggle
4. **Expected:** Toggle flips, `kuryeler.is_online` updates in DB. Text changes between "Aktif" and "Pasif".

### 2. Assigned order list

1. As operasyon, assign an order to the courier
2. Switch to courier screen
3. **Expected:** Order appears in list with route info (Çıkış → Uğrama). Only `devam_ediyor` orders shown.

### 3. Çıkış timestamp punch

1. View an assigned order with no timestamps set
2. Tap "Çıkış" button
3. **Expected:** Button becomes disabled, shows current time in HH:mm format. `siparisler.cikis_saat` populated in DB.

### 4. Uğrama timestamp punch

1. On same order, tap "Uğrama" button
2. **Expected:** Button becomes disabled, shows current time. `siparisler.ugrama_saat` populated in DB.

### 5. Uğrama1 timestamp (conditional)

1. View an order that has `ugrama1_id` set
2. **Expected:** Uğrama1 button visible and tappable
3. View an order without `ugrama1_id`
4. **Expected:** Uğrama1 button not visible

### 6. Order drops off after completion

1. As operasyon, finish (Bitir) an order that the courier has timestamps on
2. Switch to courier screen
3. **Expected:** Completed order no longer appears in courier's list (filtered out as `tamamlandi`)

## Edge Cases

### No kurye record

1. Log in as a user with `kurye` role but no matching `kuryeler` table entry
2. **Expected:** Screen shows "Kurye kaydı bulunamadı" instead of crashing

### All timestamps already set

1. View an order where çıkış, uğrama, and uğrama1 are all set
2. **Expected:** All three buttons disabled, showing formatted times. No tap action available.

### No assigned orders

1. Log in as courier with no `devam_ediyor` orders
2. **Expected:** Empty list state (no crash, toggle still functional)

## Failure Signals

- Courier screen shows loading spinner indefinitely → `currentKuryeProvider` not resolving
- Toggle doesn't persist → `updateOnlineStatus` failing silently
- Timestamp tap has no effect → `SiparisRepository.update()` not called or failing
- Completed orders still showing → client-side `devamEdiyor` filter not applied
- Crash on screen load → null kurye handling broken

## Requirements Proved By This UAT

- R011 — Courier sees assigned orders and punches timestamps at each stop
- R016 — Courier can toggle active/passive status

## Not Proven By This UAT

- R008 (Realtime order flow across all roles) — courier-side realtime not tested against live Supabase yet; deferred to S08
- Cross-role flow (create → assign → punch → finish) — deferred to S08

## Notes for Tester

- Live runtime testing requires coordinating across 3 role accounts — easier to batch with S08 cross-role UAT
- Route info on order cards shows IDs not names — this is expected for MVP
- Uğrama1 only appears when the order has a second stop (`ugrama1_id` not null)
