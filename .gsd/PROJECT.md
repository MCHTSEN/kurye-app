# Project

## What This Is

Moto Kurye Sipariş & Takip Programı — a motorcycle courier dispatch application for a courier business in Bursa. Three user roles interact through a Flutter mobile app backed by Supabase:

- **Müşteri Personeli**: Company staff who place courier orders and track delivery status
- **Operasyon Personeli**: Dispatch staff who manage orders, assign couriers, handle customer/stop CRUD, and view analytics
- **Kurye**: Couriers who receive assignments, confirm pickups/deliveries with timestamps, and toggle active/passive status

## Core Value

The core dispatch loop: customer creates order → operations assigns courier → courier delivers → order completes with auto-pricing. All screens update in realtime.

## Current State

M001 complete — all 8 slices done. All 18 active requirements validated. 123 tests passing, 0 analysis errors.

What's built:
- Supabase DB with 10 tables deployed + siparis_log audit table
- Auth with Supabase, role-based routing via AppAccessGuard
- Role request/approval flow with müşteri assignment for personel role
- 6 domain models (Musteri, Ugrama, MusteriPersonel, Kurye, Siparis, SiparisLog) with repositories and Supabase implementations
- 4 master-detail CRUD pages for operasyon (müşteri, uğrama, personel, kurye management)
- Customer order creation form with 4 cascading dropdowns + active orders realtime list + history page with date filtering
- 3-panel operations dispatch screen: order creation, kurye bekleyenler (waiting queue), devam edenler (in-progress)
- Courier assignment flow with checkbox selection + courier dropdown
- Order finish flow with auto-pricing from historical orders + manual pricing fallback dialog
- SiparisLog audit trail on every status transition
- Courier main screen with active/passive toggle, realtime order list, and çıkış/uğrama/uğrama1 timestamp punching
- Operations order history page with Excel-like DataTable, multi-dimension filters, tap-to-edit panel, and running revenue total
- Analytics dashboard with live revenue metrics (3mo/1mo/1wk + daily avg), courier performance stats, active courier count
- Sound alerts on new dispatch orders via OrderAlertService (audioplayers)
- Human-readable name resolution on all screens (stops and courier names replace UUIDs)
- Cross-role integration test proving full order lifecycle
- Supabase Realtime stream pattern: single stream feeds panels, split client-side by status

M002 complete — uğrama modeli many-to-many'ye geçirildi, talep sistemi eklendi:
- Uğramalar bağımsız havuzda, müşterilerle `musteri_ugrama` köprü tablosu üzerinden many-to-many ilişki
- Operasyon bir uğramayı birden fazla müşteriye atayabilir (FilterChip multi-select)
- Müşteri personeli yeni uğrama talebi gönderebilir (ugrama_adi + adres)
- Operasyon talepleri kabul (→ otomatik ugrama + köprü insert) veya red (not ile) edebilir
- RLS politikaları köprü tablosu üzerinden çalışıyor

Remaining before production: UAT on iOS simulator (manual cross-role test), deferred features (location tracking, map tracking, auto-assignment, web responsive, Access DB import).

## Architecture / Key Patterns

- **Layer separation**: `core/` (framework), `product/` (shared), `feature/` (screens)
- **Backend abstraction**: `backend_core` (contracts) → `backend_supabase` (implementation). Only Supabase backend is active.
- **State management**: Riverpod 3 with code generation
- **Routing**: auto_route with `AppAccessGuard` for role-based access control
- **DB access**: Supabase client via `SupabaseBackendModule`, service_role key for admin ops
- **CRUD pattern**: Master-detail pages (form top, list bottom, tap to edit) with ConsumerStatefulWidget
- **Realtime**: Supabase `stream(primaryKey: ['id'])` + filter + handleError, autoDispose providers
- **Analytics**: Pure computation via DashboardStats.compute() factory, per-card ConsumerWidget with independent .when()
- **Sound alerts**: OrderAlertService with constructor injection, _knownWaitingIds bootstrap pattern
- **Name resolution**: D027 pattern — build maps from list providers, look up by ID, fall back to raw UUID
- **Entry point**: `lib/main_supabase.dart` with `--dart-define-from-file=.env`

## Capability Contract

See `.gsd/REQUIREMENTS.md` for the explicit capability contract, requirement status, and coverage mapping.

## Milestone Sequence

- [x] M001: Core dispatch app — All 3 roles functional with order lifecycle, CRUD, analytics, and realtime sync (8/8 slices done, all 18 requirements validated)
- [x] M002: Many-to-many uğrama modeli ve talep sistemi — Uğramalar bağımsız havuz, müşteri bazlı atama, talep sistemi (4/4 slices done, 128 tests passing)
