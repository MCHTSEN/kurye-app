# S06: Order History & Editing — UAT

**Milestone:** M001
**Written:** 2026-03-15

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: The page is a CRUD data table with filters — widget tests cover rendering, filtering, editing, and revenue calculation. No realtime behavior or cross-role interaction to verify.

## Preconditions

- App running on iOS simulator or device with operasyon role user logged in
- At least 3 completed/cancelled orders in the database with different müşteri, çıkış, uğrama values and non-zero ücret
- Müşteri, uğrama, and kurye master data populated

## Smoke Test

Navigate to Geçmiş Siparişler tab → confirm DataTable renders with order rows showing human-readable names (not UUIDs) and a revenue total card at the top.

## Test Cases

### 1. Table renders with name-resolved columns

1. Open Geçmiş Siparişler page
2. Observe the DataTable columns: Tarih, Müşteri, Çıkış, Uğrama, Kurye, Ücret, Durum
3. **Expected:** All columns show human-readable names. Müşteri shows firm name, Çıkış/Uğrama show stop names, Kurye shows courier name. No raw UUID values visible.

### 2. Revenue total reflects filtered data

1. Note the revenue total in the card at top
2. Sum the Ücret column values manually
3. **Expected:** Revenue total matches the sum of visible order ücret values

### 3. Date range filter

1. Tap the date range picker in the filter bar
2. Select a narrow range that excludes some orders
3. **Expected:** Table updates to show only orders within the selected date range. Revenue total updates accordingly.

### 4. Müşteri filter with cascading stops

1. Select a specific müşteri from the filter dropdown
2. Observe çıkış and uğrama filter dropdowns
3. **Expected:** Çıkış and uğrama dropdowns show only stops belonging to the selected müşteri. Table filters to show only that müşteri's orders.

### 5. Tap row to edit

1. Tap any order row in the DataTable
2. **Expected:** Edit panel appears at the top of the page, populated with the tapped order's data (müşteri, çıkış, uğrama, ücret, durum, not1).

### 6. Edit and save

1. With edit panel open, change the ücret value
2. Tap Kaydet (Save)
3. **Expected:** Edit panel closes, table refreshes, the modified order shows the new ücret value. Revenue total updates to reflect the change.

### 7. Cancel order via İptal

1. Tap an order row to open the edit panel
2. Tap İptal Et button
3. **Expected:** Order's durum changes to "iptal" in the table. No delete occurs — the order remains visible.

## Edge Cases

### No matching orders for filter

1. Set filters that match no orders (e.g., very narrow date range with no orders)
2. **Expected:** Table shows empty state. Revenue total shows ₺0.00.

### Default date range

1. Open the page fresh without changing any filters
2. **Expected:** Date range defaults to last 30 days. Only orders within that range are shown.

## Failure Signals

- Raw UUIDs visible in table columns instead of names
- Revenue total doesn't update when filters change
- Tap on row doesn't populate edit panel
- Save doesn't refresh the table
- İptal deletes the order instead of changing status

## Requirements Proved By This UAT

- R014 — Operations order history with filtering & editing: table rendering, multi-dimension filtering, inline editing, revenue total, no-delete policy

## Not Proven By This UAT

- Cross-role interaction (e.g., courier completes order and it appears in history) — deferred to S08
- Performance with large datasets (hundreds of orders)
- Concurrent editing by multiple operasyon users

## Notes for Tester

- The edit panel cascading dropdowns follow the same pattern as the dispatch page — müşteri change resets çıkış/uğrama.
- DropdownButtonFormField shows a deprecation warning in analyze (info level) — this is a known codebase-wide pattern, not a bug.
