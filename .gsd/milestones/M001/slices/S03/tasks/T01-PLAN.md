---
estimated_steps: 8
estimated_files: 12
---

# T01: Siparis data layer with realtime stream support

**Slice:** S03 — Order Creation & Customer Tracking
**Milestone:** M001

## Description

Build the complete data layer for orders: `Siparis` domain model with `SiparisDurum` enum, `SiparisRepository` abstract contract with both Future-based and Stream-based methods, Supabase implementation using the `stream()` API for realtime subscriptions, BackendModule wiring, barrel exports, and Riverpod providers. Also extends `MusteriPersonelRepository` with `getByUserId()` needed for customer order creation. Includes domain model unit tests and a `FakeSiparisRepository` for widget testing.

This is the first slice to use Supabase `stream()` — the pattern established here will be reused in S04/S05/S08.

## Steps

1. Create `packages/backend_core/lib/src/domain/siparis.dart` — `SiparisDurum` enum (kurye_bekliyor, devam_ediyor, tamamlandi, iptal) with `fromValue`/`value` like `UserRole`. `Siparis` class following `Musteri` pattern: plain Dart, `fromJson`/`toJson`, all DB columns. Map `ucret` as `double?` (JSON comes as `num`). All timestamp fields as `DateTime?`. `not_id` is an ugrama reference (document in field comment).
2. Create `packages/backend_core/lib/src/siparis_repository.dart` — abstract contract with: `create(Siparis)`, `getByMusteriId(String)`, `getByDurum(SiparisDurum)`, `updateDurum(String id, SiparisDurum durum)`, `streamByMusteriId(String musteriId)` returning `Stream<List<Siparis>>`, `streamActive()` returning `Stream<List<Siparis>>` (durum in [kurye_bekliyor, devam_ediyor]).
3. Add `getByUserId(String userId)` to `MusteriPersonelRepository` abstract contract. Implement in `SupabaseMusteriPersonelRepository` — query `.eq('user_id', userId).maybeSingle()`.
4. Create `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — implement all contract methods. For `create()`: insert with explicit field list (not `toJson()` — exclude id, created_at, updated_at), use `.select().single()` to return created record. For streams: use `_client.from(_table).stream(primaryKey: ['id']).eq('musteri_id', musteriId)` for scoped stream; use `.inFilter('durum', ['kurye_bekliyor', 'devam_ediyor'])` for active stream. Map stream `List<Map>` to `List<Siparis>` via `.map()`. Log stream lifecycle at `.d()` level.
5. Add `createSiparisRepository() => null` to `BackendModule`. Override in `SupabaseBackendModule` to return `SupabaseSiparisRepository`.
6. Add barrel exports to `packages/backend_core/lib/backend_core.dart` (domain/siparis.dart, siparis_repository.dart) and `packages/backend_supabase/lib/backend_supabase.dart` (supabase_siparis_repository.dart).
7. Create `lib/product/siparis/siparis_providers.dart` — `siparisRepositoryProvider` (keepAlive), `siparisStreamByMusteriProvider(String musteriId)` (autoDispose StreamProvider), `siparisStreamActiveProvider` (autoDispose StreamProvider), `siparisListByMusteriProvider(String musteriId)` (autoDispose FutureProvider). Run `dart run build_runner build` to generate `.g.dart`.
8. Create `test/domain/siparis_test.dart` (fromJson/toJson roundtrip, nullable timestamp/ucret handling, SiparisDurum enum fromValue) and `test/helpers/fakes/fake_siparis_repository.dart` (in-memory store, stream via `StreamController`).

## Must-Haves

- [ ] `Siparis` model maps all `siparisler` columns correctly (ucret as double?, all timestamps as DateTime?)
- [ ] `SiparisDurum` enum values match DB enum exactly: kurye_bekliyor, devam_ediyor, tamamlandi, iptal
- [ ] `SiparisRepository` contract includes both Future and Stream methods
- [ ] `SupabaseSiparisRepository` uses `stream(primaryKey: ['id'])` for realtime
- [ ] `MusteriPersonelRepository.getByUserId()` exists in contract and Supabase impl
- [ ] BackendModule wired, barrel exports added
- [ ] Riverpod stream providers are autoDispose (not keepAlive)
- [ ] Domain model tests pass
- [ ] FakeSiparisRepository supports stream emission for widget tests

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test test/domain/siparis_test.dart` — all tests pass
- `flutter test` — all existing + new tests pass (no regressions)

## Observability Impact

- Signals added: `LogTag.data` logging in `SupabaseSiparisRepository` — `.i()` for mutations, `.d()` for reads and stream events
- How a future agent inspects this: grep `SupabaseSiparisRepo` in console output
- Failure state exposed: stream connection errors logged at `.e()`, Supabase exceptions propagate via AsyncValue.error

## Inputs

- `packages/backend_core/lib/src/domain/musteri.dart` — domain model pattern to follow
- `packages/backend_core/lib/src/musteri_repository.dart` — abstract contract pattern
- `packages/backend_supabase/lib/src/supabase_musteri_repository.dart` — Supabase CRUD implementation pattern
- `lib/product/ugrama/ugrama_providers.dart` — Riverpod provider pattern
- `test/domain/musteri_test.dart` — test pattern to follow
- `test/helpers/fakes/fake_musteri_repository.dart` — fake repo pattern
- S03-RESEARCH.md — schema reference, stream() API usage, constraints

## Expected Output

- `packages/backend_core/lib/src/domain/siparis.dart` — Siparis model + SiparisDurum enum
- `packages/backend_core/lib/src/siparis_repository.dart` — abstract SiparisRepository
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — Supabase implementation with stream()
- `packages/backend_core/lib/src/musteri_personel_repository.dart` — getByUserId added
- `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart` — getByUserId implemented
- `packages/backend_core/lib/src/backend_module.dart` — createSiparisRepository added
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — override added
- `lib/product/siparis/siparis_providers.dart` — all providers + generated .g.dart
- `test/domain/siparis_test.dart` — domain model tests
- `test/helpers/fakes/fake_siparis_repository.dart` — fake with stream support
