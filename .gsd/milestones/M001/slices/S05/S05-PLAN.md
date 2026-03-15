# S05: Courier Workflow

**Goal:** Courier can go active/passive, see their assigned orders in realtime, and punch timestamps at each stop — completing the order lifecycle from the courier's perspective.
**Demo:** Courier logs in → toggles active → sees orders assigned by ops → taps çıkış/uğrama/uğrama1 timestamps → timestamps persist and order updates in realtime.

## Must-Haves

- Courier can toggle active/passive status (updates `is_online` on `kuryeler`)
- Courier sees only their assigned `devam_ediyor` orders in realtime
- Courier can punch çıkış_saat, ugrama_saat, ugrama1_saat timestamps with one tap each
- Already-set timestamps are displayed and disabled (no re-tap)
- Orders completed by ops (`tamamlandi`) drop off the courier's list automatically
- Graceful handling when courier has no `kuryeler` record

## Proof Level

- This slice proves: integration (courier data flow from assignment through timestamp punching)
- Real runtime required: yes (Supabase Realtime stream by `kurye_id`)
- Human/UAT required: no (cross-role UAT deferred to S08)

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all pass, including:
  - `test/feature/kurye/kurye_ana_page_test.dart` — widget tests: toggle rendering + state change, order list rendering, timestamp punch action, disabled button for already-set timestamps
- Realtime stream integration verified against live Supabase during S08

## Observability / Diagnostics

- Runtime signals: `SupabaseKuryeRepo` logs on `getByUserId()`; `SupabaseSiparisRepo` logs on `streamByKuryeId()` setup and `update()` for timestamp writes
- Inspection surfaces: Query `kuryeler` table for `is_online` state; query `siparisler` for `*_saat` timestamp fields
- Failure visibility: Null return from `getByUserId()` → UI shows "Kurye kaydı bulunamadı" error state; stream errors surface via `handleError` pattern from S03

## Integration Closure

- Upstream surfaces consumed: `SiparisRepository.update(id, fields)` from S04, `KuryeRepository.updateOnlineStatus(id, isOnline:)` from S02, `siparisStreamActiveProvider` pattern from S03
- New wiring introduced: `currentKuryeProvider`, `siparisStreamByKuryeProvider`, `getByUserId()` contract + impl, `streamByKuryeId()` contract + impl
- What remains before milestone is truly usable end-to-end: S06 (history), S07 (analytics), S08 (cross-role integration + polish)

## Tasks

- [x] **T01: Extend data layer with courier lookup and courier-scoped order stream** `est:25m`
  - Why: The courier screen needs two data primitives that don't exist yet — resolving `kuryeId` from auth UID and streaming orders filtered by `kurye_id`. These must be in place before the UI can be built.
  - Files: `packages/backend_core/lib/src/kurye_repository.dart`, `packages/backend_supabase/lib/src/supabase_kurye_repository.dart`, `packages/backend_core/lib/src/siparis_repository.dart`, `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`, `lib/product/kurye/kurye_providers.dart`, `lib/product/siparis/siparis_providers.dart`, `test/helpers/fakes/fake_kurye_repository.dart`, `test/helpers/fakes/fake_siparis_repository.dart`
  - Do: Add `getByUserId(String userId)` to `KuryeRepository` contract + Supabase impl (`.eq('user_id', userId).maybeSingle()`). Add `streamByKuryeId(String kuryeId)` to `SiparisRepository` contract + Supabase impl (copy `streamByMusteriId` pattern with `.eq('kurye_id', kuryeId)`). Add `currentKuryeProvider` (keepAlive, resolves courier's `Kurye` record once). Add `siparisStreamByKuryeProvider(kuryeId)` family provider. Update both fake repositories with the new methods.
  - Verify: `flutter analyze` clean, `flutter test` — all existing tests still pass
  - Done when: Both new repository methods exist in contract + Supabase + fake, both providers are wired, no regressions

- [x] **T02: Build courier main screen with active/passive toggle and timestamp punching** `est:30m`
  - Why: Delivers R011 and R016 — the courier-facing UI that replaces the placeholder `KuryeAnaPage`. This is the user-visible deliverable of the slice.
  - Files: `lib/feature/kurye/presentation/kurye_ana_page.dart`, `test/feature/kurye/kurye_ana_page_test.dart`
  - Do: Replace placeholder with real screen. Top section: `Switch` for active/passive backed by `updateOnlineStatus()`. Body: list of `devam_ediyor` orders from `siparisStreamByKuryeProvider`, client-side filtered. Each order card shows route info and three timestamp buttons (Çıkış, Uğrama, Uğrama1). Each button: if `*_saat` is null, tap sets `DateTime.now()` via `SiparisRepository.update(id, {field: timestamp})`; if already set, show formatted time and disable. Handle null `currentKuryeProvider` with error message. Widget tests: (1) toggle renders and fires updateOnlineStatus, (2) order list renders with order data, (3) timestamp button tap calls update with correct field, (4) already-set timestamp shows time and button is disabled.
  - Verify: `flutter analyze` clean, `flutter test` — all pass including new widget tests
  - Done when: Courier screen shows toggle + order list + working timestamp buttons, 4+ widget tests pass

## Files Likely Touched

- `packages/backend_core/lib/src/kurye_repository.dart`
- `packages/backend_supabase/lib/src/supabase_kurye_repository.dart`
- `packages/backend_core/lib/src/siparis_repository.dart`
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`
- `lib/product/kurye/kurye_providers.dart`
- `lib/product/siparis/siparis_providers.dart`
- `test/helpers/fakes/fake_kurye_repository.dart`
- `test/helpers/fakes/fake_siparis_repository.dart`
- `lib/feature/kurye/presentation/kurye_ana_page.dart`
- `test/feature/kurye/kurye_ana_page_test.dart`
