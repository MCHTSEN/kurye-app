# Requirements

## Active

 Read this at the start of every session. These are always available.

## 1. mobile-mcp (iOS Simulator Automation)

- **Server:** `mobile-mcp`
- **Device ID:** `04E43A5F-2FD2-4405-A574-DA757E506951` (iPhone 15 Pro, iOS 18.4)
- **Key tools:**
  - `mobile_take_screenshot` — `{device: "<id>"}` — screenshot as base64
  - `mobile_save_screenshot` — `{device: "<id>", saveTo: "/abs/path.png"}` — save to file
  - `mobile_list_elements_on_screen` — `{device: "<id>"}` — accessibility tree with coordinates
  - `mobile_click_on_screen_at_coordinates` — `{device: "<id>", x: N, y: N}` — tap
  - `mobile_type_keys` — `{device: "<id>", text: "..."}` — type into focused element
  - `mobile_swipe_on_screen` — `{device: "<id>", direction: "up|down|left|right"}`
  - `mobile_launch_app` — `{device: "<id>", packageName: "com.example.bursamotokurye"}`
  - `mobile_list_apps` — `{device: "<id>"}`
- **Usage:** Use for UI testing after `flutter run`. Take screenshot, read elements, tap, type.

## 2. supabase (Database & Backend)

- **Server:** `supabase`
- **Project ref:** `ebxvkbhrxxplauhsntda` (bursa-moto-kurye)
- **Key tools:**
  - `list_tables` — list all tables
  - `execute_sql` — run SELECT/INSERT/UPDATE/DELETE queries
  - `apply_migration` — run DDL (CREATE TABLE, ALTER, etc.)
  - `get_logs` — get project logs by service
  - `list_migrations` — list applied migrations
- **Note:** Supabase MCP has wrong access token binding — use curl with service_role key as primary method:

  ```bash
  SUPABASE_URL=$(grep SUPABASE_URL .env | head -1 | cut -d= -f2)
  SERVICE_KEY=$(grep SUPABASE_SERVICE_ROLE_KEY .env | cut -d= -f2)
  curl -s "${SUPABASE_URL}/rest/v1/<table>?select=*" -H "apikey: ${SERVICE_KEY}" -H "Authorization: Bearer ${SERVICE_KEY}"
  ```

## 3. context7 (Library Documentation)  

- **Server:** `context7`
- **Tools:** `resolve-library-id`, `query-docs`
- **Usage:** Look up Flutter/Dart/Supabase/Riverpod docs

### R001 — Role-based auth & routing

- Class: core-capability
- Status: active
- Description: Users authenticate via Supabase Auth and are routed to role-specific screens (müşteri/operasyon/kurye)
- Why it matters: Foundation for all role-specific functionality
- Source: user
- Primary owning slice: M001/S01
- Supporting slices: none
- Validation: validated
- Notes: Already implemented and working

### R002 — Role request & approval flow

- Class: core-capability
- Status: active
- Description: New users select a role, submit a request, and wait for operasyon approval before accessing the app
- Why it matters: Controls who gets access to which role
- Source: user
- Primary owning slice: M001/S01
- Supporting slices: none
- Validation: validated
- Notes: Already implemented — role_requests table, RoleSelectionPage, approval creates app_users entry

### R003 — Customer (müşteri) CRUD management

- Class: primary-user-loop
- Status: active
- Description: Operasyon can create, edit, list customers (firms). Excel-like table view with inline editing panel.
- Why it matters: Customers are the source of all orders — must exist before orders can be placed
- Source: user
- Primary owning slice: M001/S02
- Supporting slices: none
- Validation: validated
- Notes: Domain model + Supabase repo + CRUD page implemented. Widget tests cover form render, validation, create, edit.

### R004 — Stop (uğrama) CRUD with location

- Class: primary-user-loop
- Status: active
- Description: Operasyon can create/edit stops per customer. Stops are pickup/delivery points used in order dropdowns. Location stored as PostGIS Geography.
- Why it matters: Stops populate the order creation dropdowns — no stops means no orders
- Source: user
- Primary owning slice: M001/S02
- Supporting slices: none
- Validation: validated
- Notes: Domain model + Supabase repo + CRUD page implemented. lokasyon Geography excluded from model (D010), deferred to M002.

### R005 — Customer staff (personel) CRUD

- Class: primary-user-loop
- Status: active
- Description: Operasyon can create/edit customer staff per customer. Staff are linked to app_users for login.
- Why it matters: Customer staff place orders on behalf of their company
- Source: user
- Primary owning slice: M001/S02
- Supporting slices: none
- Validation: validated
- Notes: Domain model + Supabase repo + CRUD page implemented. approveRequest sets musteri_id for personel role (D012).

### R006 — Courier (kurye) management

- Class: primary-user-loop
- Status: active
- Description: Operasyon can create/edit couriers. Couriers are linked to app_users for login. Have active/passive and online/offline states.
- Why it matters: Couriers are assigned to orders — must exist in system
- Source: user
- Primary owning slice: M001/S02
- Supporting slices: M001/S05
- Validation: validated
- Notes: Domain model + Supabase repo + CRUD page implemented. is_online toggle via updateOnlineStatus (D014).

### R007 — Order creation with cascading dropdowns

- Class: primary-user-loop
- Status: active
- Description: Both müşteri and operasyon can create orders. Dropdowns cascade: select customer → stops load for that customer. Fields: Çıkış, Uğrama, Uğrama1 (optional), Not (dropdown), Not1 (text).
- Why it matters: Core order creation flow — the primary user action
- Source: user
- Primary owning slice: M001/S03
- Supporting slices: M001/S04
- Validation: validated
- Notes: Customer-side validated in S03 with widget tests (form render, validation, submit). Operations-side creation in S04.

### R008 — Realtime order flow across all roles

- Class: core-capability
- Status: active
- Description: Order status changes are visible in realtime across all connected screens. No page refresh needed.
- Why it matters: Dispatch operations require instant visibility of order state changes
- Source: user
- Primary owning slice: M001/S03
- Supporting slices: M001/S04, M001/S05, M001/S08
- Validation: validated
- Notes: Supabase stream() pattern established in S03 — customer sees live updates. S04 adds ops-side realtime panels fed from siparisStreamActiveProvider. S08 integration test proves full cross-role lifecycle: create→assign→deliver→complete with stream reactivity and courier isolation.

### R009 — Operations 3-panel dispatch screen

- Class: primary-user-loop
- Status: active
- Description: Single page with 3 panels: (A) order creation form, (B) kurye bekleyenler (waiting for courier), (C) devam edenler (in progress). Panels update in realtime.
- Why it matters: The central operations screen — where all dispatch happens
- Source: user
- Primary owning slice: M001/S04
- Supporting slices: none
- Validation: validated
- Notes: Fully implemented in S04. Widget tests prove 3-panel rendering with correct status-based split.

### R010 — Courier assignment (manual)

- Class: primary-user-loop
- Status: active
- Description: Operasyon selects orders via checkboxes in "kurye bekleyenler" panel, picks a courier, and assigns. Order moves to "devam ediyor" status.
- Why it matters: Core dispatch action — connecting orders to couriers
- Source: user
- Primary owning slice: M001/S04
- Supporting slices: none
- Validation: validated
- Notes: Implemented in S04. Widget test proves checkbox select + courier dropdown + Ata → order updated with kurye_id, atanma_saat, durum=devam_ediyor.

### R011 — Courier order acceptance & timestamp punching

- Class: primary-user-loop
- Status: active
- Description: Courier sees assigned orders, confirms acceptance, and punches timestamps at each stop (çıkış, uğrama, uğrama1).
- Why it matters: Completes the courier side of the dispatch loop
- Source: user
- Primary owning slice: M001/S05
- Supporting slices: none
- Validation: validated
- Notes: Implemented in S05. Widget tests prove timestamp buttons call update with correct fields, disabled state for already-set timestamps, order list rendering with devamEdiyor filter. Uğrama1 conditionally hidden.

### R012 — Order completion with auto-pricing

- Class: primary-user-loop
- Status: active
- Description: Operasyon finishes orders via "bitir" button. System auto-finds the most recent completed order with same customer+route and copies its price. If no match, warns operasyon to set price manually.
- Why it matters: Automates pricing based on historical data — saves time and ensures consistency
- Source: user
- Primary owning slice: M001/S04
- Supporting slices: none
- Validation: validated
- Notes: Implemented in S04. getRecentPricing() queries matching musteri+cikis+ugrama with tamamlandi status. Widget tests prove auto-pricing and manual fallback dialog.

### R013 — Customer order tracking (active + history)

- Class: primary-user-loop
- Status: active
- Description: Müşteri sees active orders with live status updates below the order form. Completed orders drop off. Separate history page with date filtering.
- Why it matters: Customers need visibility into their order status
- Source: user
- Primary owning slice: M001/S03
- Supporting slices: none
- Validation: validated
- Notes: Implemented in S03 — active orders with realtime stream, history page with date range filtering. Widget tests cover form + submit flow.

### R014 — Operations order history with filtering & editing

- Class: primary-user-loop
- Status: active
- Description: Excel-like table of past orders. Filter by date, customer, çıkış, uğrama. Click to edit in top panel. Running revenue total displayed.
- Why it matters: Operations needs to review, correct, and analyze past orders
- Source: user
- Primary owning slice: M001/S06
- Supporting slices: none
- Validation: validated
- Notes: Editing updates the order record, not creates a new one. Widget tests cover table rendering with name resolution, filtering, tap-to-edit, save/refresh, revenue total. İptal sets durum only — no delete.

### R015 — Analytics dashboard

- Class: differentiator
- Status: active
- Description: Dashboard showing 3-month/1-month/1-week revenue totals, current month daily average, courier performance (monthly + daily job counts), and active couriers today.
- Why it matters: Business intelligence for the dispatch operation
- Source: user
- Primary owning slice: M001/S07
- Supporting slices: none
- Validation: validated
- Notes: Implemented via DashboardStats.compute() pure factory + dashboardStatsProvider. 10 unit tests + 7 widget tests. No RPC functions needed — client-side computation from getHistory() data.

### R016 — Courier active/passive toggle

- Class: primary-user-loop
- Status: active
- Description: Courier can toggle themselves active/passive. Only active couriers can receive order assignments.
- Why it matters: Controls courier availability for dispatch
- Source: user
- Primary owning slice: M001/S05
- Supporting slices: M001/S04
- Validation: validated
- Notes: Implemented in S05. Widget test proves toggle calls updateOnlineStatus with correct parameter. Optimistic local state with revert on failure.

### R017 — Sound alerts for new orders

- Class: launchability
- Status: active
- Description: When a new order arrives at the operations screen, play a sound alert
- Why it matters: Dispatch staff may not be watching the screen — audio notification prevents missed orders
- Source: inferred
- Primary owning slice: M001/S08
- Supporting slices: none
- Validation: validated
- Notes: Implemented in S08 with OrderAlertService (audioplayers). Compares prev/next kurye_bekliyor ID sets — fires alert only on genuinely new arrivals, not existing order state changes. Widget test verifies trigger behavior.

### R018 — Order status log tracking

- Class: continuity
- Status: active
- Description: Every order status change is logged in siparis_log with old/new status, who changed it, and when
- Why it matters: Audit trail for dispute resolution and operational review
- Source: user
- Primary owning slice: M001/S04
- Supporting slices: none
- Validation: validated
- Notes: Implemented in S04. SiparisLog domain model + repository. Created on assign (kuryeBekliyor→devamEdiyor) and finish (devamEdiyor→tamamlandi). Widget tests verify log creation.

## Deferred

### R019 — Courier background location tracking

- Class: differentiator
- Status: deferred
- Description: Track courier location in background, store daily in kurye_konum table
- Why it matters: Enables map-based tracking and distance-based auto-assignment
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: unmapped
- Notes: Deferred to M002 — requires background service, permissions, battery optimization

### R020 — Map-based courier tracking

- Class: differentiator
- Status: deferred
- Description: Show courier positions on map. Hover over courier shows their active orders.
- Why it matters: Visual dispatch intelligence
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: unmapped
- Notes: Deferred to M002 — depends on R019 location tracking

### R021 — Auto courier assignment (distance-based)

- Class: differentiator
- Status: deferred
- Description: Auto/manual toggle. When auto, system assigns nearest courier or courier already on the same route.
- Why it matters: Reduces dispatch workload and optimizes routing
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: unmapped
- Notes: Deferred to M002 — depends on R019 location data and PostGIS distance calculations

### R022 — Web responsive for operations

- Class: quality-attribute
- Status: deferred
- Description: Operations screens work well on both web and mobile form factors
- Why it matters: Spec says operations should work on web + mobile
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: unmapped
- Notes: Deferred — focus on mobile-first, web responsive can follow

## Out of Scope

### R023 — Note-taking web app

- Class: anti-feature
- Status: out-of-scope
- Description: Simple note-taking web app with React/Node mentioned at end of spec
- Why it matters: Prevents scope confusion — this is a separate product, not part of the courier app
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: n/a
- Notes: Mentioned in spec but unrelated to courier dispatch

## Traceability

| ID | Class | Status | Primary owner | Supporting | Proof |
|---|---|---|---|---|---|
| R001 | core-capability | active | M001/S01 | none | validated |
| R002 | core-capability | active | M001/S01 | none | validated |
| R003 | primary-user-loop | active | M001/S02 | none | validated |
| R004 | primary-user-loop | active | M001/S02 | none | validated |
| R005 | primary-user-loop | active | M001/S02 | none | validated |
| R006 | primary-user-loop | active | M001/S02 | none | validated |
| R007 | primary-user-loop | active | M001/S03 | M001/S04 | validated |
| R008 | core-capability | active | M001/S03 | M001/S04,S05,S08 | validated |
| R009 | primary-user-loop | active | M001/S04 | none | validated |
| R010 | primary-user-loop | active | M001/S04 | none | validated |
| R011 | primary-user-loop | active | M001/S05 | none | validated |
| R012 | primary-user-loop | active | M001/S04 | none | validated |
| R013 | primary-user-loop | active | M001/S03 | none | validated |
| R014 | primary-user-loop | active | M001/S06 | none | validated |
| R015 | differentiator | active | M001/S07 | none | validated |
| R016 | primary-user-loop | active | M001/S05 | M001/S04 | validated |
| R017 | launchability | active | M001/S08 | none | validated |
| R018 | continuity | active | M001/S04 | none | validated |
| R019 | differentiator | deferred | none | none | unmapped |
| R020 | differentiator | deferred | none | none | unmapped |
| R021 | differentiator | deferred | none | none | unmapped |
| R022 | quality-attribute | deferred | none | none | unmapped |
| R023 | anti-feature | out-of-scope | none | none | n/a |

## Coverage Summary

- Active requirements: 18
- Mapped to slices: 18
- Validated: 18 (R001, R002, R003, R004, R005, R006, R007, R008, R009, R010, R011, R012, R013, R014, R015, R016, R017, R018)
- Partially validated: 0
- Unmapped active requirements: 0
