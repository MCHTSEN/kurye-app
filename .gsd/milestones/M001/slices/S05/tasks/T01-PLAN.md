---
estimated_steps: 6
estimated_files: 8
---

# T01: Extend data layer with courier lookup and courier-scoped order stream

**Slice:** S05 — Courier Workflow
**Milestone:** M001

## Description

Add two data layer primitives needed by the courier screen: (1) `KuryeRepository.getByUserId(userId)` to resolve the logged-in courier's `Kurye` record from their auth UID, and (2) `SiparisRepository.streamByKuryeId(kuryeId)` to stream orders assigned to a specific courier in realtime. Wire both into Riverpod providers and update fake repositories for test isolation.

## Steps

1. Add `Future<Kurye?> getByUserId(String userId)` to `KuryeRepository` contract. Implement in `SupabaseKuryeRepository` using `.eq('user_id', userId).maybeSingle()` with the established column-selection pattern (exclude `lokasyon`). Add `.i()` log line.
2. Add `Stream<List<Siparis>> streamByKuryeId(String kuryeId)` to `SiparisRepository` contract. Implement in `SupabaseSiparisRepository` by copying the `streamByMusteriId` pattern — `.stream(primaryKey: ['id']).eq('kurye_id', kuryeId)` with `handleError`. Add `.d()` log line on stream setup.
3. Add `currentKuryeProvider` to `kurye_providers.dart` — an `AsyncNotifier` or `FutureProvider` with `keepAlive: true` that calls `getByUserId(currentUser.id)`. Returns `Kurye?` (null means broken state).
4. Add `siparisStreamByKuryeProvider(String kuryeId)` family provider to `siparis_providers.dart`, following the `siparisStreamByMusteriProvider` pattern.
5. Update `FakeKuryeRepository` — implement `getByUserId()` by searching the in-memory list for matching `userId`.
6. Update `FakeSiparisRepository` — implement `streamByKuryeId()` following the `streamByMusteriId()` pattern, filtering by `kuryeId`.

## Must-Haves

- [ ] `getByUserId` exists in contract, Supabase impl, and fake
- [ ] `streamByKuryeId` exists in contract, Supabase impl, and fake
- [ ] `currentKuryeProvider` resolves courier record with `keepAlive`
- [ ] `siparisStreamByKuryeProvider` streams orders filtered by `kurye_id`
- [ ] All existing tests still pass (no regressions)

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all existing tests pass

## Observability Impact

- Signals added: `.i()` on `getByUserId()`, `.d()` on `streamByKuryeId()` setup in Supabase implementations
- How a future agent inspects this: grep console for `SupabaseKuryeRepo` and `SupabaseSiparisRepo` log lines
- Failure state exposed: `getByUserId` returns null → `currentKuryeProvider` yields null → UI can show error

## Inputs

- `packages/backend_core/lib/src/kurye_repository.dart` — existing contract with `updateOnlineStatus`
- `packages/backend_core/lib/src/siparis_repository.dart` — existing contract with `streamByMusteriId` as template
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — `streamByMusteriId` implementation to copy
- `lib/product/kurye/kurye_providers.dart` — existing `kuryeRepositoryProvider` and `kuryeListProvider`
- `lib/product/siparis/siparis_providers.dart` — existing `siparisStreamByMusteriProvider` as template
- S04 forward intelligence: `update(id, fields)` uses raw `Map<String, dynamic>`, don't include `updated_at`

## Expected Output

- `packages/backend_core/lib/src/kurye_repository.dart` — `getByUserId()` added to contract
- `packages/backend_supabase/lib/src/supabase_kurye_repository.dart` — Supabase implementation
- `packages/backend_core/lib/src/siparis_repository.dart` — `streamByKuryeId()` added to contract
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — Supabase implementation
- `lib/product/kurye/kurye_providers.dart` — `currentKuryeProvider` added
- `lib/product/siparis/siparis_providers.dart` — `siparisStreamByKuryeProvider` added
- `test/helpers/fakes/fake_kurye_repository.dart` — `getByUserId()` implemented
- `test/helpers/fakes/fake_siparis_repository.dart` — `streamByKuryeId()` implemented
