# M001: Core Dispatch App — Context

**Gathered:** 2026-03-15
**Status:** Ready for planning

## Project Description

Motorcycle courier dispatch app for a Bursa-based courier business. Three roles (müşteri personeli, operasyon, kurye) interact through a Flutter app backed by Supabase. The core loop: customer creates order → operations assigns courier → courier delivers → order completes with auto-pricing.

## Why This Milestone

This is the first and primary milestone — it builds the entire functional dispatch application. Without this, there is no product. The deferred items (location tracking, maps, auto-assignment) are enhancements that build on top of a working dispatch system.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Register, request a role, get approved by operations, and access role-specific screens
- (Müşteri) Create orders with cascading dropdowns, see live status, view history
- (Operasyon) Manage customers/stops/couriers, dispatch orders via 3-panel screen, finish orders with auto-pricing, view history and analytics
- (Kurye) Go active/passive, receive orders, punch timestamps at each stop

### Entry point / environment

- Entry point: `flutter run -d <device> --dart-define-from-file=.env lib/main_supabase.dart`
- Environment: iOS Simulator (iPhone 15 Pro) for development, mobile for production
- Live dependencies: Supabase (PostgreSQL + Auth + Realtime)

## Completion Class

- Contract complete means: All domain models, repositories, and controllers have unit tests. All screens render correctly.
- Integration complete means: Orders flow through the full lifecycle across all 3 roles via Supabase Realtime.
- Operational complete means: App can be run on simulator, all roles can complete their primary workflows end-to-end.

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- A customer can create an order and see it appear on the operations screen in realtime
- Operations can assign a courier and the courier sees the order on their screen
- The courier can punch timestamps and operations can finish the order with auto-pricing
- Operations can view order history, filter, edit, and see revenue totals
- Analytics dashboard shows accurate revenue and courier performance data

## Risks and Unknowns

- **Realtime sync reliability** — Supabase Realtime needs to work reliably for order status changes across all 3 roles
- **RLS policy complexity** — Role-based data access is enforced at DB level; policies must not block legitimate access or leak data
- **Auto-pricing query performance** — Finding the most recent matching order for pricing needs to be fast
- **Cascading dropdown state** — Managing dependent dropdown state (customer → stops) in Riverpod needs careful design

## Existing Codebase / Prior Art

- `packages/backend_core/` — Abstract contracts for auth, profiles, role requests
- `packages/backend_supabase/` — Supabase implementations of the contracts
- `lib/app/router/` — auto_route setup with AppAccessGuard for role-based routing
- `lib/feature/auth/` — Auth controller and page (login, register, friendly errors)
- `lib/feature/role_selection/` — Role request flow (select role → submit → pending → approved)
- `lib/product/user_profile/` — CurrentUserProfile Riverpod provider
- `lib/product/role_request/` — Role request providers
- `supabase/migrations/` — 3 migration files (initial schema, RLS fix, role_requests)

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions.

## Relevant Requirements

- R001-R002: Already validated (auth + role request)
- R003-R006: Master data CRUD (S02)
- R007-R008, R013: Order creation + customer tracking + realtime (S03)
- R009-R010, R012, R017-R018: Operations dispatch (S04)
- R011, R016: Courier workflow (S05)
- R014: Order history (S06)
- R015: Analytics (S07)
- R017: Sound alerts + integration polish (S08)

## Scope

### In Scope

- All 3 role workflows end-to-end
- Master data CRUD (customers, stops, staff, couriers)
- Order lifecycle (create → assign → deliver → complete)
- Realtime order status updates
- Auto-pricing from order history
- Analytics dashboard
- Sound alerts for new orders
- Order status log tracking

### Out of Scope / Non-Goals

- Background location tracking (M002)
- Map-based courier visualization (M002)
- Auto courier assignment algorithm (M002)
- Web responsive layout optimization (M002)
- Note-taking web app (separate product)
- Push notifications (not in spec)
- Payment/billing integration

## Technical Constraints

- Supabase is the only backend — no mock/custom/firebase implementations needed for new features
- RLS policies already deployed — new features must work within existing policies or add new ones
- Email confirmation is ON in Supabase Auth (can be disabled for testing)
- PostGIS extension enabled but location features deferred to M002
- App runs on iOS simulator for development/testing

## Integration Points

- **Supabase Auth** — Login, register, session management
- **Supabase Realtime** — Order status changes, courier status changes (siparisler, kuryeler tables already published)
- **Supabase PostgREST** — All CRUD operations via REST API
- **mobile-mcp** — iOS simulator automation for UI testing

## Open Questions

- **Operasyon role request approval UI** — Not yet built. Operasyon needs a screen to approve/reject role requests. Should be part of S02 or separate? → Include in S02 as part of user management.
- **Email confirmation for testing** — User said we can disable it. → Disable for faster testing iteration.

## Per-Slice Documentation Reading Guide

Before implementing each slice, read:

### S02 (Master Data CRUD)
- `supabase/migrations/20260315000000_initial_schema.sql` — table definitions for musteriler, ugramalar, musteri_personelleri, kuryeler
- `packages/backend_core/lib/src/backend_module.dart` — pattern for adding new repository factory methods
- `packages/backend_supabase/lib/src/supabase_user_profile_repository.dart` — pattern for Supabase repository implementation

### S03 (Order Creation & Customer Tracking)
- `siparisler` table schema in the migration
- Existing `role_selection_page.dart` — pattern for form pages with Riverpod state

### S04 (Operations Dispatch)
- `moto-kurye.md` spec sections 2-2-a, 2-2-b, 2-3 — the 3-panel layout specification
- Auto-pricing rule: find most recent completed order with same musteri+cikis+ugrama

### S05 (Courier Workflow)
- `moto-kurye.md` spec sections 3-1, 3-2, 3-3 — courier screen specification
- `kuryeler` table (is_online field for active/passive)

### S06 (Order History)
- `moto-kurye.md` — "Geçmiş Siparişler Ekranı" section
- Excel-like table requirement

### S07 (Analytics Dashboard)
- `moto-kurye.md` — section 2-1 dashboard specification
- Revenue calculations: 3-month, 1-month, 1-week totals + daily average
