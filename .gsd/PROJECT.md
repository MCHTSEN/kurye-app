# Project

## What This Is

Moto Kurye Sipariş & Takip Programı — a motorcycle courier dispatch application for a courier business in Bursa. Three user roles interact through a Flutter mobile app backed by Supabase:

- **Müşteri Personeli**: Company staff who place courier orders and track delivery status
- **Operasyon Personeli**: Dispatch staff who manage orders, assign couriers, handle customer/stop CRUD, and view analytics
- **Kurye**: Couriers who receive assignments, confirm pickups/deliveries with timestamps, and toggle active/passive status

## Core Value

The core dispatch loop: customer creates order → operations assigns courier → courier delivers → order completes with auto-pricing. All screens update in realtime.

## Current State

Sprint 1 foundation is complete:
- Supabase DB with 10 tables deployed (musteriler, app_users, kuryeler, siparisler, ugramalar, musteri_personelleri, siparis_log, kurye_konum, role_requests)
- Auth with Supabase, role-based routing via AppAccessGuard
- Role request/approval flow (register → select role → ops approves)
- Placeholder pages for all 3 roles
- 53 tests passing, 0 analysis errors

All feature pages are still placeholders — no business logic, repositories, or domain models beyond auth/profile.

## Architecture / Key Patterns

- **Layer separation**: `core/` (framework), `product/` (shared), `feature/` (screens)
- **Backend abstraction**: `backend_core` (contracts) → `backend_supabase` (implementation). Only Supabase backend is active.
- **State management**: Riverpod 3 with code generation
- **Routing**: auto_route with `AppAccessGuard` for role-based access control
- **DB access**: Supabase client via `SupabaseBackendModule`, service_role key for admin ops
- **Entry point**: `lib/main_supabase.dart` with `--dart-define-from-file=.env`

## Capability Contract

See `.gsd/REQUIREMENTS.md` for the explicit capability contract, requirement status, and coverage mapping.

## Milestone Sequence

- [ ] M001: Core dispatch app — All 3 roles functional with order lifecycle, CRUD, analytics, and realtime sync
