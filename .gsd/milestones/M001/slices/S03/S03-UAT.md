# S03: Order Creation & Customer Tracking — UAT

**Milestone:** M001
**Written:** 2026-03-15

## UAT Type

- UAT mode: mixed
- Why this mode is sufficient: Core form logic and data flow verified by automated widget tests (4 cases). Realtime stream behavior and visual layout require live-runtime verification on simulator or device.

## Preconditions

- Supabase instance running with `siparisler`, `ugramalar`, `musteri_personeller` tables
- At least one müşteri with 2+ uğramalar created via operasyon CRUD
- A müşteri_personel user linked to that müşteri (approved, with `musteri_id` on `app_users`)
- App built and running on iOS simulator or device

## Smoke Test

Log in as müşteri_personel → navigate to Sipariş tab → verify order creation form shows 4 dropdowns and 1 text field → select Çıkış and Uğrama → tap "Sipariş Oluştur" → confirm order appears in active orders list below.

## Test Cases

### 1. Order creation with valid fields

1. Log in as müşteri_personel user
2. On Sipariş page, select a Çıkış stop from dropdown
3. Select a different Uğrama stop from dropdown
4. Optionally select Uğrama1 and Not
5. Type a note in Not1 text field
6. Tap "Sipariş Oluştur"
7. **Expected:** Success SnackBar appears, order shows in active orders list below with "Kurye Bekliyor" orange chip

### 2. Form validation rejects empty required fields

1. On Sipariş page, leave all dropdowns unselected
2. Tap "Sipariş Oluştur"
3. **Expected:** Validation errors appear on Çıkış and Uğrama fields ("Bu alan zorunludur" or similar)

### 3. Active orders update in realtime

1. Create an order as müşteri_personel (test case 1)
2. From another session or via Supabase dashboard, update the order's `durum` to `devam_ediyor`
3. **Expected:** The order card in the active list updates to show blue "Devam Ediyor" chip without page refresh

### 4. Completed orders appear in history

1. Create an order and update its `durum` to `tamamlandi` (via Supabase dashboard or operasyon)
2. Navigate to Geçmiş tab
3. **Expected:** The completed order appears in the history list with date and ücret info

### 5. Date range filtering on history page

1. Navigate to Geçmiş tab with some completed orders
2. Tap the date filter
3. Select a date range that includes some orders but not all
4. **Expected:** Only orders within the selected date range are shown

### 6. Null musteriId guard

1. Create an app_users entry without `musteri_id` and with role `musteri_personel`
2. Log in as that user
3. Navigate to Sipariş tab
4. **Expected:** Guard message displayed ("Müşteri bilgisi bulunamadı" or similar), form not rendered

## Edge Cases

### No stops exist for customer

1. Create a müşteri with zero uğramalar
2. Log in as personel linked to that müşteri
3. Navigate to Sipariş tab
4. **Expected:** Dropdowns are empty or show a "no stops" message. User cannot create an order.

### Rapid order creation

1. Submit 3 orders quickly in succession
2. **Expected:** All 3 appear in active orders list. No duplicate submissions, no stream disconnection.

## Failure Signals

- Form submits but no order appears in active list → stream subscription may be broken
- Dropdown shows stops from wrong customer → musteriId filtering issue
- "Müşteri bilgisi bulunamadı" for a valid personel → profile.musteriId is null, check app_users table
- Order created but durum chip missing → SiparisDurum enum mapping issue
- History page empty despite completed orders → client-side filter may be wrong or date range too narrow

## Requirements Proved By This UAT

- R007 — Order creation with cascading dropdowns (customer side)
- R008 — Realtime order flow (customer side — stream updates without refresh)
- R013 — Customer order tracking (active list + history with date filter)

## Not Proven By This UAT

- R007 operations-side order creation (S04)
- R008 cross-role realtime — operations seeing customer orders appear (S04)
- R008 courier-side realtime updates (S05)
- Order cancellation flow (not specified in S03 scope)

## Notes for Tester

- The 4 `DropdownButtonFormField.value` deprecation infos in analyze are cosmetic — Flutter 3.33+ deprecated `value` in favor of `initialValue`, but switching breaks the controlled form pattern. No functional impact.
- Realtime test (case 3) requires either a second session or direct DB update — the customer cannot change order status themselves.
- The form uses `musteriId` from the logged-in user's profile to scope dropdown data — test with a properly linked personel account.
