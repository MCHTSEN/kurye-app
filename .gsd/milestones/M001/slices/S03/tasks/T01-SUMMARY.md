---
id: T01
parent: S03
milestone: M001
provides:
  - Siparis domain model + SiparisDurum enum
  - SiparisRepository abstract contract with Future + Stream methods
  - SupabaseSiparisRepository with stream() realtime support
  - MusteriPersonelRepository.getByUserId() contract + Supabase impl
  - BackendModule wiring + barrel exports
  - Riverpod providers (repo keepAlive, streams autoDispose)
  - Domain model unit tests
  - FakeSiparisRepository with stream emission support
key_files:
  - packages/backend_core/lib/src/domain/siparis.dart
  - packages/backend_core/lib/src/siparis_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_repository.dart
  - lib/product/siparis/siparis_providers.dart
  - test/domain/siparis_test.dart
  - test/helpers/fakes/fake_siparis_repository.dart
key_decisions:
  - "D015: Established Supabase stream() pattern — stream(primaryKey: ['id']) + filter + handleError, autoDispose stream providers to prevent channel leaks"
patterns_established:
  - "Supabase stream() for realtime subscriptions — reuse in S04/S05/S08"
  - "FakeSiparisRepository with StreamController broadcast + startWithValue for widget test stream support"
observability_surfaces:
  - "LogTag.data logging in SupabaseSiparisRepo — .i() for mutations, .d() for reads/stream events, .e() for stream errors"
duration: 15m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Siparis data layer with realtime stream support

**Built complete order data layer: domain model, repository contract with stream methods, Supabase implementation using `stream()` API for realtime, providers, domain tests, and fake repo with stream emission support.**

## What Happened

Created `Siparis` model and `SiparisDurum` enum following the established `Musteri`/`UserRole` patterns. The enum maps 4 DB values exactly: `kurye_bekliyor`, `devam_ediyor`, `tamamlandi`, `iptal`. The model maps all 20 `siparisler` columns with `ucret` as `double?` (handles `num` from JSON) and all timestamps as `DateTime?`. `not_id` is documented as a uğrama reference.

`SiparisRepository` contract includes 4 Future methods (`create`, `getByMusteriId`, `getByDurum`, `updateDurum`) and 2 Stream methods (`streamByMusteriId`, `streamActive`).

`SupabaseSiparisRepository` uses `stream(primaryKey: ['id'])` for realtime — this is the first use of Supabase Realtime in the app. The `streamByMusteriId` uses `.eq('musteri_id', musteriId)`, and `streamActive` uses `.inFilter('durum', [...])` to scope to active statuses. Both streams have `handleError` for connection error logging. The `create()` method uses explicit field list (excludes `id`, `created_at`, `updated_at`) with `.select().single()` to return the created record.

Added `getByUserId(String userId)` to `MusteriPersonelRepository` contract and implemented in Supabase — uses `.eq('user_id', userId).maybeSingle()`.

Riverpod providers: `siparisRepositoryProvider` is `keepAlive`, all three data providers (`siparisStreamByMusteri`, `siparisStreamActive`, `siparisListByMusteri`) are `autoDispose` via `@riverpod`.

`FakeSiparisRepository` uses `StreamController.broadcast()` per stream key with a `startWithValue` extension to emit current state immediately then stream updates. Exposes `emitForMusteri()` and `emitActive()` for test-driven stream emission.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (8 infos, all pre-existing or trivial)
- `flutter test test/domain/siparis_test.dart` — 7/7 tests pass (enum roundtrip, fromJson/toJson, nullable fields, int→double ucret, null preservation)
- `flutter test` — 72/72 tests pass, 0 failures, no regressions
- `dart run build_runner build` — generated `siparis_providers.g.dart` with correct provider signatures

### Slice-level verification (partial — T01 of 2):
- ✅ `flutter analyze` — 0 errors, 0 warnings
- ✅ `flutter test` — all existing + new domain tests pass
- ⬜ `test/feature/musteri_siparis/musteri_siparis_page_test.dart` — not yet created (T02)
- ⬜ `flutter build ios --simulator` — deferred to T02 (final task)

## Diagnostics

- Grep `SupabaseSiparisRepo` in console output to see all order CRUD and stream lifecycle events
- Stream subscription logged at `.d()` level: "subscribing", row count on each emission
- Stream errors logged at `.e()` level via `handleError`
- Mutation events (`create`, `updateDurum`) logged at `.i()` level with IDs

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `packages/backend_core/lib/src/domain/siparis.dart` — **created** — Siparis model + SiparisDurum enum
- `packages/backend_core/lib/src/siparis_repository.dart` — **created** — abstract SiparisRepository contract
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — **created** — Supabase impl with stream() realtime
- `packages/backend_core/lib/src/musteri_personel_repository.dart` — **modified** — added getByUserId()
- `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart` — **modified** — implemented getByUserId()
- `packages/backend_core/lib/src/backend_module.dart` — **modified** — added createSiparisRepository()
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — **modified** — override createSiparisRepository()
- `packages/backend_core/lib/backend_core.dart` — **modified** — barrel exports for siparis.dart + siparis_repository.dart
- `packages/backend_supabase/lib/backend_supabase.dart` — **modified** — barrel export for supabase_siparis_repository.dart
- `lib/product/siparis/siparis_providers.dart` — **created** — Riverpod providers (repo + streams + list)
- `lib/product/siparis/siparis_providers.g.dart` — **generated** — build_runner output
- `test/domain/siparis_test.dart` — **created** — 7 domain model tests
- `test/helpers/fakes/fake_siparis_repository.dart` — **created** — in-memory fake with stream support
