# M001: Core Dispatch App

**Vision:** A fully functional motorcycle courier dispatch application where customers place orders, operations dispatches couriers, and couriers deliver — all in realtime. Three roles, one Supabase backend, complete order lifecycle with auto-pricing.

## Success Criteria

- Customer can create an order and see live status updates until completion
- Operations can manage customers/stops/couriers, dispatch orders via 3-panel screen, and finish orders with auto-pricing
- Courier can go active, receive orders, punch timestamps, and complete deliveries
- All order state changes propagate in realtime to all connected screens
- Operations can view order history with filtering, editing, and revenue totals
- Analytics dashboard shows revenue and courier performance metrics

## Key Risks / Unknowns

- Realtime sync across 3 roles — Supabase Realtime must reliably push order changes to all connected clients
- RLS policy interaction — new repositories must work within existing RLS policies; operasyon has full access, müşteri sees own company, kurye sees own orders
- 3-panel operations screen complexity — three live-updating panels on one page with checkbox selection and courier assignment
- Auto-pricing query — finding the most recent matching historical order must be correct and fast

## Proof Strategy

- Realtime sync → retire in S03 by proving customer order appears on ops screen without refresh
- RLS policies → retire in S02 by proving CRUD operations work with correct role tokens
- 3-panel screen → retire in S04 by proving order flows through all 3 panels with realtime updates
- Auto-pricing → retire in S04 by proving price is auto-populated from matching historical order

## Verification Classes

- Contract verification: flutter analyze clean, flutter test pass, domain model unit tests
- Integration verification: Supabase CRUD operations work with real DB, realtime subscriptions fire correctly
- Operational verification: Full order lifecycle on iOS simulator with mobile-mcp for automated UI checks
- UAT / human verification: Cross-role testing — create orders as customer, dispatch as ops, deliver as courier

## Milestone Definition of Done

This milestone is complete only when all are true:

- All 8 slice deliverables are complete
- Full order lifecycle works end-to-end: create → assign → deliver → complete with price
- Realtime updates verified across all 3 role screens
- Master data CRUD fully operational (customers, stops, staff, couriers)
- Analytics dashboard shows accurate metrics
- Order history with filtering, editing, revenue totals works
- flutter analyze has 0 errors/warnings
- flutter test passes all tests
- Cross-role integration test passes on iOS simulator

## Requirement Coverage

- Covers: R001-R018
- Partially covers: none
- Leaves for later: R019 (location tracking), R020 (map tracking), R021 (auto assignment), R022 (web responsive)
- Orphan risks: none

## Slices

- [x] **S01: Auth foundation & role routing** `risk:low` `depends:[]`
  > After this: Users can register, request a role, get approved, and are routed to their role-specific placeholder screens. Verified on iOS simulator.

- [x] **S02: Master data CRUD** `risk:low` `depends:[S01]`
  > After this: Operations can create/edit/list customers, stops, customer staff, and couriers. Role request approval screen works. All CRUD verified against live Supabase.

- [x] **S03: Order creation & customer tracking** `risk:medium` `depends:[S02]`
  > After this: Customer can create orders with cascading dropdowns and see live status. Operations sees new orders arrive in realtime. Order creation verified from both roles.

- [x] **S04: Operations dispatch screen** `risk:high` `depends:[S02,S03]`
  > After this: 3-panel operations screen works — create orders, assign couriers from waiting queue, finish orders with auto-pricing. Realtime panel updates verified.

- [x] **S05: Courier workflow** `risk:medium` `depends:[S04]`
  > After this: Courier can go active/passive, see assigned orders, punch timestamps at each stop. Order lifecycle complete from courier perspective.

- [x] **S06: Order history & editing** `risk:low` `depends:[S04]`
  > After this: Operations can view past orders in table format, filter by date/customer/route, edit orders, see running revenue totals.

- [x] **S07: Analytics dashboard** `risk:low` `depends:[S04]`
  > After this: Operations dashboard shows revenue totals (3mo/1mo/1wk), daily average, courier job counts, and active couriers today.

- [ ] **S08: Cross-role integration & polish** `risk:low` `depends:[S03,S04,S05,S06,S07]`
  > After this: Full end-to-end flow verified across all 3 roles with sound alerts, order logging, and edge case handling. All acceptance scenarios pass.

## Boundary Map

### S01 (done) → S02
Produces:
- `AppUserProfile` model with role, musteriId
- `UserProfileRepository` contract + Supabase implementation
- `RoleRequestRepository` contract + Supabase implementation
- `AppAccessGuard` with role-based routing
- `CustomRoute` enum with all route paths
- Supabase DB schema with all tables and RLS policies
- `get_my_role()` SECURITY DEFINER function for RLS

Consumes: nothing (foundation)

### S02 → S03
Produces:
- `Musteri` domain model + `MusteriRepository` (CRUD)
- `Ugrama` domain model + `UgramaRepository` (CRUD)
- `MusteriPersonel` domain model + `MusteriPersonelRepository` (CRUD)
- `Kurye` domain model + `KuryeRepository` (CRUD)
- Role request approval screen in operasyon
- Riverpod providers for all master data

Consumes from S01:
- `BackendModule` pattern for adding new repositories
- `AppUserProfile` for role checking
- Supabase DB tables

### S03 → S04
Produces:
- `Siparis` domain model + `SiparisRepository` (create, read, update status)
- `SiparisDurum` enum (kurye_bekliyor, devam_ediyor, tamamlandi, iptal)
- Customer order creation form with cascading dropdowns
- Active orders list with realtime updates (customer side)
- Realtime sipariş stream provider
- Supabase Realtime subscription pattern

Consumes from S02:
- `Musteri`, `Ugrama` models and repositories (for dropdowns)
- `MusteriPersonel` for personel selection

### S04 → S05, S06, S07
Produces:
- 3-panel operations screen (create + waiting + in-progress)
- Courier assignment flow (checkbox select + assign)
- Order completion with auto-pricing
- `SiparisLog` creation on status changes
- Operations-side order creation form

Consumes from S02:
- All master data repositories (müşteri, uğrama, kurye, personel)
Consumes from S03:
- `Siparis` model, `SiparisRepository`, realtime stream

### S05 → S08
Produces:
- Courier main screen with active/passive toggle
- Courier order list (assigned orders)
- Timestamp punching for çıkış/uğrama/uğrama1
- Courier status update (is_online)

Consumes from S04:
- `SiparisRepository.update()` for timestamp fields
- `KuryeRepository.updateOnlineStatus()`

### S06 → S08
Produces:
- Operations order history page with excel-like table
- Filters: date range, customer, çıkış, uğrama
- Inline editing panel
- Running revenue total

Consumes from S04:
- `SiparisRepository` query methods with filters

### S07 → S08
Produces:
- Analytics dashboard with revenue metrics
- Courier performance stats
- Active couriers today widget

Consumes from S04:
- `SiparisRepository` aggregate queries
- `KuryeRepository` status queries

### S08 (final)
Produces:
- Sound alerts for new orders (operations)
- Cross-role integration verification
- Edge case handling and polish

Consumes from S03, S04, S05, S06, S07:
- All screens and repositories
- Realtime streams
