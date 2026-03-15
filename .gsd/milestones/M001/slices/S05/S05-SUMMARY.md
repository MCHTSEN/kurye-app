---
id: S05
parent: M001
milestone: M001
provides:
  - KuryeRepository.getByUserId() — resolve courier record from auth UID
  - SiparisRepository.streamByKuryeId() — realtime order stream filtered by courier
  - currentKuryeProvider (keepAlive) + siparisStreamByKuryeProvider (family)
  - Full courier main screen with active/passive toggle and timestamp punching
  - 6 widget tests covering toggle, order list, timestamp punch, disabled state, ugrama1 hidden, null kurye
requires:
  - slice: S04
    provides: SiparisRepository.update(id, fields) for timestamp writes
  - slice: S02
    provides: KuryeRepository.updateOnlineStatus(id, isOnline:)
  - slice: S03
    provides: siparisStreamActiveProvider pattern (copied for courier stream)
affects:
  - S08
key_files:
  - packages/backend_core/lib/src/kurye_repository.dart
  - packages/backend_supabase/lib/src/supabase_kurye_repository.dart
  - packages/backend_core/lib/src/siparis_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_repository.dart
  - lib/product/kurye/kurye_providers.dart
  - lib/product/siparis/siparis_providers.dart
  - lib/feature/kurye/presentation/kurye_ana_page.dart
  - test/feature/kurye/kurye_ana_page_test.dart
  - test/helpers/fakes/fake_kurye_repository.dart
  - test/helpers/fakes/fake_siparis_repository.dart
key_decisions:
  - Optimistic local state for toggle — ConsumerStatefulWidget with local _isOnline, revert on failure, avoids extra provider
  - Client-side devamEdiyor filter on courier stream — keeps stream setup simple, matches ops panel pattern from D019
  - currentKuryeProvider.overrideWith in tests — simpler than wiring full auth+fake repo chain
patterns_established:
  - _TimestampButton widget — reusable punch-style button with enabled/disabled + formatted time display
  - Kurye screen test pattern using currentKuryeProvider.overrideWith + repository overrideWithValue
  - kurye_ stream key prefix in FakeSiparisRepository for courier-scoped test streams
observability_surfaces:
  - SupabaseKuryeRepo .i() log on getByUserId()
  - SupabaseSiparisRepo .d() log on streamByKuryeId() subscribe and data events
  - SupabaseSiparisRepo update logs on timestamp writes
  - Null kurye record renders "Kurye kaydı bulunamadı" — visible error state, no crash
drill_down_paths:
  - .gsd/milestones/M001/slices/S05/tasks/T01-SUMMARY.md
  - .gsd/milestones/M001/slices/S05/tasks/T02-SUMMARY.md
duration: 27m
verification_result: passed
completed_at: 2026-03-15
---

# S05: Courier Workflow

**Courier can toggle active/passive, see assigned devam_ediyor orders in realtime, and punch çıkış/uğrama/uğrama1 timestamps — completing the order lifecycle from the courier's perspective.**

## What Happened

Two tasks, both clean:

**T01 (data layer):** Added `getByUserId(String userId)` to `KuryeRepository` contract + Supabase impl (`.eq('user_id', userId).maybeSingle()`). Added `streamByKuryeId(String kuryeId)` to `SiparisRepository` following the established `streamByMusteriId` pattern. Wired `currentKuryeProvider` (keepAlive, resolves courier from auth UID) and `siparisStreamByKuryeProvider` (family). Updated both fake repositories with the new methods including `emitForKurye()` test helper.

**T02 (UI):** Replaced placeholder `KuryeAnaPage` with full courier screen. Top section: `_OnlineToggleCard` with optimistic local state — toggles `is_online` via `updateOnlineStatus()`, reverts on exception. Body: order list from `siparisStreamByKuryeProvider`, client-side filtered to `devamEdiyor`. Each order card shows route info and three `_TimestampButton` widgets. Each button: if null → tap sets `DateTime.now()` via `SiparisRepository.update(id, {field: timestamp})`; if set → disabled, shows formatted time (HH:mm). Uğrama1 button hidden when `ugrama1Id` is null. Null `currentKuryeProvider` renders "Kurye kaydı bulunamadı" error state.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (23 info-level, all pre-existing)
- `flutter test` — 92/92 pass, including 6 new widget tests:
  1. Toggle renders and fires `updateOnlineStatus`
  2. Order list renders with client-side devamEdiyor filter
  3. Timestamp button tap calls `update` with correct field
  4. Already-set timestamp shows formatted time and button is disabled
  5. Uğrama1 button hidden when `ugrama1Id` is null
  6. Null kurye record shows error message
- Realtime stream integration against live Supabase — deferred to S08

## Requirements Advanced

- R011 (Courier order acceptance & timestamp punching) — courier sees assigned orders and can punch çıkış/uğrama/uğrama1 timestamps
- R016 (Courier active/passive toggle) — courier can toggle `is_online` from the main screen

## Requirements Validated

- R011 — widget tests prove timestamp buttons call update with correct fields, disabled state for already-set timestamps, order list rendering with devamEdiyor filter
- R016 — widget test proves toggle calls `updateOnlineStatus` with correct parameter

## New Requirements Surfaced

- None

## Requirements Invalidated or Re-scoped

- None

## Deviations

- 6 widget tests written instead of the planned 4 — added coverage for ugrama1 hidden condition and null kurye error state, both explicit must-haves in the plan

## Known Limitations

- Realtime stream integration against live Supabase not yet tested — deferred to S08 cross-role integration
- Route info on order cards shows raw IDs (cikisId, ugramaId) rather than stop names — acceptable for MVP, could be enriched with joined data later
- No pull-to-refresh on the courier order list — stream handles live updates, but manual refresh not available

## Follow-ups

- S08: Cross-role integration test — create order as müşteri → assign as operasyon → punch timestamps as kurye → finish as operasyon
- S08: Verify realtime stream works end-to-end with live Supabase for courier-scoped orders

## Files Created/Modified

- `packages/backend_core/lib/src/kurye_repository.dart` — added `getByUserId()` to contract
- `packages/backend_supabase/lib/src/supabase_kurye_repository.dart` — Supabase implementation of `getByUserId()`
- `packages/backend_core/lib/src/siparis_repository.dart` — added `streamByKuryeId()` to contract
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — Supabase implementation of `streamByKuryeId()`
- `lib/product/kurye/kurye_providers.dart` — added `currentKuryeProvider`
- `lib/product/kurye/kurye_providers.g.dart` — codegen output
- `lib/product/siparis/siparis_providers.dart` — added `siparisStreamByKuryeProvider`
- `lib/product/siparis/siparis_providers.g.dart` — codegen output
- `lib/feature/kurye/presentation/kurye_ana_page.dart` — full rewrite replacing placeholder
- `test/feature/kurye/kurye_ana_page_test.dart` — 6 widget tests
- `test/helpers/fakes/fake_kurye_repository.dart` — implemented `getByUserId()`
- `test/helpers/fakes/fake_siparis_repository.dart` — implemented `streamByKuryeId()`, `emitForKurye()`

## Forward Intelligence

### What the next slice should know
- Courier screen consumes `currentKuryeProvider` which depends on auth session — any test touching courier features needs to override this provider or wire auth+fake repo chain
- `siparisStreamByKuryeProvider` uses the same `stream()` pattern as müşteri — any Supabase Realtime changes affect both

### What's fragile
- Order cards display raw IDs not stop names — if S06/S08 needs rich order display, a joined query or eager-loaded stop names will be needed
- Optimistic toggle has no retry logic — if `updateOnlineStatus` fails, UI reverts but there's no automatic retry

### Authoritative diagnostics
- Grep `SupabaseKuryeRepo` for `getByUserId` to trace courier resolution
- Grep `SupabaseSiparisRepo` + `streamByKuryeId` to see courier stream lifecycle
- Query `kuryeler.is_online` to verify toggle persistence
- Query `siparisler.cikis_saat / ugrama_saat / ugrama1_saat` to verify timestamp writes

### What assumptions changed
- No assumptions changed — all upstream contracts consumed as designed
