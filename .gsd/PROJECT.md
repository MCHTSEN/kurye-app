# Project

## What This Is

Moto Kurye Sipariş & Takip Programı — a motorcycle courier dispatch application for a courier business in Bursa. Three user roles interact through a Flutter mobile app backed by Supabase:

- **Müşteri Personeli**: Company staff who place courier orders and track delivery status
- **Operasyon Personeli**: Dispatch staff who manage orders, assign couriers, handle customer/stop CRUD, and view analytics
- **Kurye**: Couriers who receive assignments, confirm pickups/deliveries with timestamps, and toggle active/passive status

## Core Value

The core dispatch loop: customer creates order → operations assigns courier → courier delivers → order completes with auto-pricing. All screens update in realtime.

## Current State

S01 (auth), S02 (master data CRUD), S03 (order creation & tracking), and S04 (operations dispatch) are complete:
- Supabase DB with 10 tables deployed + siparis_log audit table
- Auth with Supabase, role-based routing via AppAccessGuard
- Role request/approval flow with müşteri assignment for personel role
- 6 domain models (Musteri, Ugrama, MusteriPersonel, Kurye, Siparis, SiparisLog) with repositories and Supabase implementations
- 4 master-detail CRUD pages for operasyon (müşteri, uğrama, personel, kurye management)
- Customer order creation form with 4 cascading dropdowns + active orders realtime list
- Customer history page with date range filtering
- 3-panel operations dispatch screen: order creation, kurye bekleyenler (waiting queue), devam edenler (in-progress)
- Courier assignment flow with checkbox selection + courier dropdown
- Order finish flow with auto-pricing from historical orders + manual pricing fallback dialog
- SiparisLog audit trail on every status transition
- Supabase Realtime stream pattern: single stream feeds both dispatch panels, split client-side by status
- 86 tests passing, 0 analysis errors

Next: S05 (Courier workflow) — courier active/passive toggle, assigned order list, timestamp punching at stops.

## Architecture / Key Patterns

- **Layer separation**: `core/` (framework), `product/` (shared), `feature/` (screens)
- **Backend abstraction**: `backend_core` (contracts) → `backend_supabase` (implementation). Only Supabase backend is active.
- **State management**: Riverpod 3 with code generation
- **Routing**: auto_route with `AppAccessGuard` for role-based access control
- **DB access**: Supabase client via `SupabaseBackendModule`, service_role key for admin ops
- **CRUD pattern**: Master-detail pages (form top, list bottom, tap to edit) with ConsumerStatefulWidget
- **Realtime**: Supabase `stream(primaryKey: ['id'])` + filter + handleError, autoDispose providers
- **Logging**: AppLogger with LogTag.data for CRUD/stream operations, LogTag.auth for auth
- **Entry point**: `lib/main_supabase.dart` with `--dart-define-from-file=.env`

## Capability Contract

See `.gsd/REQUIREMENTS.md` for the explicit capability contract, requirement status, and coverage mapping.

## Milestone Sequence

- [ ] M001: Core dispatch app — All 3 roles functional with order lifecycle, CRUD, analytics, and realtime sync
