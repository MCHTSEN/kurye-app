---
id: T01
parent: S05
milestone: M001
provides:
  - KuryeRepository.getByUserId() contract + Supabase impl + fake
  - SiparisRepository.streamByKuryeId() contract + Supabase impl + fake
  - currentKuryeProvider (keepAlive, resolves courier from auth UID)
  - siparisStreamByKuryeProvider (family, streams orders by kurye_id)
key_files:
  - packages/backend_core/lib/src/kurye_repository.dart
  - packages/backend_supabase/lib/src/supabase_kurye_repository.dart
  - packages/backend_core/lib/src/siparis_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_repository.dart
  - lib/product/kurye/kurye_providers.dart
  - lib/product/siparis/siparis_providers.dart
  - test/helpers/fakes/fake_kurye_repository.dart
  - test/helpers/fakes/fake_siparis_repository.dart
key_decisions:
  - Used .select() (all columns) for getByUserId since kuryeler has no lokasyon Geography column — the column-exclusion pattern only applies to ugramalar/cikislar
  - currentKuryeProvider watches authStateProvider.future to get the current user's auth UID, returns null when no session or no matching kurye record
patterns_established:
  - kurye_ stream key prefix in FakeSiparisRepository for courier-scoped test streams (parallels musteri_ pattern)
observability_surfaces:
  - SupabaseKuryeRepo .i() log on getByUserId()
  - SupabaseSiparisRepo .d() log on streamByKuryeId() subscribe and data events
duration: 12m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Extend data layer with courier lookup and courier-scoped order stream

**Added `getByUserId()` and `streamByKuryeId()` across contract/Supabase/fake layers, wired `currentKuryeProvider` and `siparisStreamByKuryeProvider` into Riverpod.**

## What Happened

Six steps executed cleanly:
1. Added `getByUserId(String userId)` to `KuryeRepository` contract. Supabase impl uses `.eq('user_id', userId).maybeSingle()` with `.i()` log.
2. Added `streamByKuryeId(String kuryeId)` to `SiparisRepository` contract. Supabase impl copies `streamByMusteriId` pattern — `.stream(primaryKey: ['id']).eq('kurye_id', kuryeId)` with `.d()` log and `handleError`.
3. Added `currentKuryeProvider` — `@Riverpod(keepAlive: true)` that watches `authStateProvider.future`, calls `getByUserId(session.user.id)`. Returns `Kurye?` (null = no session or no matching record).
4. Added `siparisStreamByKuryeProvider(String kuryeId)` family provider following `siparisStreamByMusteri` pattern.
5. `FakeKuryeRepository.getByUserId()` searches store values by `userId` field.
6. `FakeSiparisRepository.streamByKuryeId()` follows `streamByMusteriId` pattern with `kurye_` key prefix. `_notifyStreams()` updated to propagate to courier-keyed controllers. `emitForKurye()` test helper added.

Codegen ran successfully, producing updated `.g.dart` files for both provider files.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (22 info-level lints, all pre-existing)
- `flutter test` — 86 tests, all passed, no regressions

### Slice-level verification (partial — T01 is intermediate):
- ✅ `flutter analyze` — clean
- ✅ `flutter test` — all pass
- ⏳ `test/feature/kurye/kurye_ana_page_test.dart` — does not exist yet (T02 deliverable)
- ⏳ Realtime stream integration — deferred to S08

## Diagnostics

- Grep for `SupabaseKuryeRepo` in console to see `getByUserId` calls
- Grep for `SupabaseSiparisRepo` + `streamByKuryeId` to see courier stream lifecycle
- `currentKuryeProvider` yields null → signals broken courier state (no kuryeler record for auth UID)

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `packages/backend_core/lib/src/kurye_repository.dart` — added `getByUserId()` to contract
- `packages/backend_supabase/lib/src/supabase_kurye_repository.dart` — Supabase implementation of `getByUserId()`
- `packages/backend_core/lib/src/siparis_repository.dart` — added `streamByKuryeId()` to contract
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — Supabase implementation of `streamByKuryeId()`
- `lib/product/kurye/kurye_providers.dart` — added `currentKuryeProvider`
- `lib/product/kurye/kurye_providers.g.dart` — codegen output
- `lib/product/siparis/siparis_providers.dart` — added `siparisStreamByKuryeProvider`
- `lib/product/siparis/siparis_providers.g.dart` — codegen output
- `test/helpers/fakes/fake_kurye_repository.dart` — implemented `getByUserId()`
- `test/helpers/fakes/fake_siparis_repository.dart` — implemented `streamByKuryeId()`, updated `_notifyStreams()`, added `emitForKurye()`
