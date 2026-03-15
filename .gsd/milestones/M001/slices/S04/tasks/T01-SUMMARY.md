---
id: T01
parent: S04
milestone: M001
provides:
  - SiparisRepository.update() and getRecentPricing() contract + Supabase impl
  - SiparisLog domain model with fromJson/toJson
  - SiparisLogRepository contract + SupabaseSiparisLogRepository impl
  - BackendModule.createSiparisLogRepository() wired
  - siparisLogRepositoryProvider Riverpod provider
  - FakeSiparisRepository updated with update() + getRecentPricing()
  - FakeKuryeRepository created
  - Composite index migration for auto-pricing
  - siparis_log_test.dart domain model tests
key_files:
  - packages/backend_core/lib/src/siparis_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_repository.dart
  - packages/backend_core/lib/src/domain/siparis_log.dart
  - packages/backend_core/lib/src/siparis_log_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_log_repository.dart
  - lib/product/siparis/siparis_log_providers.dart
  - test/helpers/fakes/fake_siparis_repository.dart
  - test/helpers/fakes/fake_kurye_repository.dart
  - test/domain/siparis_log_test.dart
  - supabase/migrations/20260315000200_pricing_index.sql
key_decisions:
  - update() takes raw Map<String, dynamic> fields for partial update — avoids overwriting courier-set timestamps; updated_at excluded from payload (BEFORE UPDATE trigger handles it)
  - getRecentPricing() filters by tamamlandi durum + musteri/cikis/ugrama match, ordered by created_at DESC, limit 1
  - FakeSiparisRepository.update() applies fields over existing toJson() then re-parses — mirrors partial update semantics
patterns_established:
  - SiparisLog follows same fromJson/toJson pattern as other domain models
  - SiparisLogRepository follows BackendModule factory pattern (null-default, override in Supabase)
  - FakeKuryeRepository follows same in-memory store pattern as FakeSiparisRepository
observability_surfaces:
  - "SupabaseSiparisLogRepo — .i() on create, .d() on getBySiparisId"
  - "SupabaseSiparisRepo — .i() on update(), .d() on getRecentPricing(), .w() when no pricing match"
duration: ~15min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Extend data layer with update, auto-pricing, and SiparisLog

**Extended SiparisRepository with partial update() and getRecentPricing(), created SiparisLog domain model + repository stack, and wired all fakes for dispatch screen testing.**

## What Happened

Added two methods to `SiparisRepository` contract: `update(id, fields)` for partial field updates (courier assignment, timestamps, ucret) and `getRecentPricing(musteriId, cikisId, ugramaId)` for auto-pricing lookup. Both implemented in `SupabaseSiparisRepository` with appropriate log levels.

Created `SiparisLog` domain model matching the `siparis_log` table schema — tracks status transitions with old/new durum, actor ID, and optional description. Created `SiparisLogRepository` contract and `SupabaseSiparisLogRepository` impl following the established BackendModule factory pattern.

Wired `createSiparisLogRepository()` into `BackendModule` (null default) and `SupabaseBackendModule` (override). Added `siparisLogRepositoryProvider` Riverpod provider. Updated barrel exports in both `backend_core` and `backend_supabase`.

Updated `FakeSiparisRepository` with `update()` (applies fields over existing JSON) and `getRecentPricing()` (in-memory filter+sort). Created `FakeKuryeRepository` with full CRUD + `updateOnlineStatus()`.

Created composite index migration `idx_siparisler_pricing` for auto-pricing query performance.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (13 pre-existing infos only)
- `flutter test` — 81/81 pass including 5 new `siparis_log_test.dart` tests
- `flutter build ios --simulator` — succeeds
- Supabase MCP not linked to project — index migration file written locally, will apply during `supabase db push`

### Slice-level verification status (intermediate task — partial passes expected):
- ✅ `flutter analyze` — 0 errors, 0 warnings
- ✅ `flutter test` — all pass including `test/domain/siparis_log_test.dart`
- ✅ `flutter build ios --simulator` — succeeds
- ✅ `FakeSiparisRepository` supports `update()` and `getRecentPricing()`
- ⬜ `test/feature/operasyon/operasyon_ekran_page_test.dart` — not yet created (later task)

## Diagnostics

- Grep `SupabaseSiparisLogRepo` in console to see log insert/query activity
- Grep `SupabaseSiparisRepo` for update() and getRecentPricing() calls
- Pricing miss logged at `.w()` with musteri/cikis/ugrama context
- Query `siparis_log` table via Supabase dashboard to see audit trail

## Deviations

- Composite index migration could not be applied via Supabase MCP (project not linked). Migration file written locally at `supabase/migrations/20260315000200_pricing_index.sql` — will be applied during next `supabase db push` or manual deploy. Not a blocker for the data layer work.

## Known Issues

None.

## Files Created/Modified

- `packages/backend_core/lib/src/siparis_repository.dart` — added `update()` and `getRecentPricing()` to contract
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — implemented both new methods
- `packages/backend_core/lib/src/domain/siparis_log.dart` — new SiparisLog domain model
- `packages/backend_core/lib/src/siparis_log_repository.dart` — new SiparisLogRepository contract
- `packages/backend_supabase/lib/src/supabase_siparis_log_repository.dart` — new Supabase implementation
- `packages/backend_core/lib/src/backend_module.dart` — added createSiparisLogRepository() factory
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — override with SupabaseSiparisLogRepository
- `packages/backend_core/lib/backend_core.dart` — added siparis_log and siparis_log_repository exports
- `packages/backend_supabase/lib/backend_supabase.dart` — added supabase_siparis_log_repository export
- `lib/product/siparis/siparis_log_providers.dart` — new Riverpod provider
- `lib/product/siparis/siparis_log_providers.g.dart` — generated code
- `test/helpers/fakes/fake_siparis_repository.dart` — added update() and getRecentPricing()
- `test/helpers/fakes/fake_kurye_repository.dart` — new in-memory fake
- `test/domain/siparis_log_test.dart` — 5 domain model tests
- `supabase/migrations/20260315000200_pricing_index.sql` — composite index migration
