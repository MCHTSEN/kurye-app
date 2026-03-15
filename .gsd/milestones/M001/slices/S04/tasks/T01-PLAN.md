---
estimated_steps: 8
estimated_files: 11
---

# T01: Extend data layer with update, auto-pricing, and SiparisLog

**Slice:** S04 — Operations Dispatch Screen
**Milestone:** M001

## Description

Extend the Siparis data layer with methods the dispatch UI needs: partial `update()` for courier assignment fields, `getRecentPricing()` for auto-pricing lookup, and a new `SiparisLog` model + repository for audit trail. Also create `FakeKuryeRepository` and apply a composite index migration for pricing query performance.

## Steps

1. **Add `update()` and `getRecentPricing()` to `SiparisRepository` contract.** `update()` takes `(String id, Map<String, dynamic> fields)` returning `Future<Siparis>` — partial update avoids overwriting courier-set timestamps. `getRecentPricing()` takes `(String musteriId, String cikisId, String ugramaId)` returning `Future<Siparis?>` — finds the most recent tamamlandi order with matching customer+route.

2. **Implement both methods in `SupabaseSiparisRepository`.** `update()`: merge fields map, call `.update(fields).eq('id', id).select().single()`. Do NOT include `updated_at` in the payload (BEFORE UPDATE trigger handles it). `getRecentPricing()`: `.select().eq('musteri_id', ...).eq('cikis_id', ...).eq('ugrama_id', ...).eq('durum', 'tamamlandi').order('created_at', ascending: false).limit(1)` — return first or null. Log at `.i()` for update, `.d()` for pricing lookup, `.w()` when pricing returns no match.

3. **Create `SiparisLog` domain model** at `packages/backend_core/lib/src/domain/siparis_log.dart`. Fields: `id`, `siparisId`, `eskiDurum` (nullable `SiparisDurum`), `yeniDurum` (`SiparisDurum`), `degistirenId` (nullable), `aciklama` (nullable), `createdAt`. Include `fromJson()` factory and `toJson()` method.

4. **Create `SiparisLogRepository` contract** at `packages/backend_core/lib/src/siparis_log_repository.dart`. Methods: `Future<SiparisLog> create(SiparisLog log)` and `Future<List<SiparisLog>> getBySiparisId(String siparisId)`.

5. **Implement `SupabaseSiparisLogRepository`** at `packages/backend_supabase/lib/src/supabase_siparis_log_repository.dart`. Standard pattern: constructor takes `SupabaseClient`, static `_log` with `LogTag.data`, `_table = 'siparis_log'`. Insert uses `.insert({...}).select().single()`. Query uses `.select().eq('siparis_id', ...).order('created_at')`.

6. **Wire into BackendModule.** Add `createSiparisLogRepository()` to `BackendModule` (returns null default) and override in `SupabaseBackendModule`. Update barrel exports in both `backend_core` and `backend_supabase`. Add `siparisLogRepositoryProvider` in a new `lib/product/siparis/siparis_log_providers.dart`.

7. **Create test fakes.** Update `FakeSiparisRepository` with `update()` and `getRecentPricing()` implementations. Create `FakeKuryeRepository` at `test/helpers/fakes/fake_kurye_repository.dart` — in-memory store with `getAll()`, `getById()`, `create()`, `update()`, `delete()`, `updateOnlineStatus()`.

8. **Apply composite index migration** for auto-pricing performance: `CREATE INDEX idx_siparisler_pricing ON siparisler(musteri_id, cikis_id, ugrama_id, durum, created_at DESC)`. File: `supabase/migrations/20260315000200_pricing_index.sql`. Apply via Supabase MCP or curl.

9. **Write domain model tests** at `test/domain/siparis_log_test.dart` — fromJson/toJson roundtrip, nullable eskiDurum handling, SiparisDurum enum values in JSON.

## Must-Haves

- [ ] `SiparisRepository.update(String id, Map<String, dynamic> fields)` contract + Supabase impl
- [ ] `SiparisRepository.getRecentPricing(musteriId, cikisId, ugramaId)` contract + Supabase impl
- [ ] `SiparisLog` domain model with fromJson/toJson
- [ ] `SiparisLogRepository` contract + Supabase impl
- [ ] `BackendModule.createSiparisLogRepository()` factory wired
- [ ] Barrel exports updated in both packages
- [ ] `siparisLogRepositoryProvider` Riverpod provider
- [ ] `FakeSiparisRepository` updated with `update()` + `getRecentPricing()`
- [ ] `FakeKuryeRepository` created
- [ ] Composite index migration applied
- [ ] `siparis_log_test.dart` passes

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all existing tests pass + new `siparis_log_test.dart` passes
- Index migration applied (verify via SQL: `SELECT indexname FROM pg_indexes WHERE tablename = 'siparisler' AND indexname = 'idx_siparisler_pricing'`)

## Observability Impact

- Signals added: `LogTag.data` on `SupabaseSiparisLogRepo` — `.i()` on create, `.d()` on query. `SupabaseSiparisRepo` — `.i()` on `update()`, `.d()` on `getRecentPricing()`, `.w()` when no pricing match found.
- How a future agent inspects this: grep `SupabaseSiparisLogRepo` or `SupabaseSiparisRepo` in console. Query `siparis_log` table via curl to see audit trail.
- Failure state exposed: pricing miss logged at warning level with musteri/cikis/ugrama context for debugging.

## Inputs

- `packages/backend_core/lib/src/siparis_repository.dart` — existing contract to extend
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — existing impl to extend
- `packages/backend_core/lib/src/backend_module.dart` — factory pattern to follow
- `test/helpers/fakes/fake_siparis_repository.dart` — existing fake to extend
- `supabase/migrations/20260315000000_initial_schema.sql` — `siparis_log` table schema
- S02 summary — `LogTag.data`, BEFORE UPDATE trigger constraint, barrel export pattern
- S03 summary — `SiparisRepository` contract, `FakeSiparisRepository` stream pattern

## Expected Output

- `packages/backend_core/lib/src/siparis_repository.dart` — 2 new methods
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — 2 new method implementations
- `packages/backend_core/lib/src/domain/siparis_log.dart` — new domain model
- `packages/backend_core/lib/src/siparis_log_repository.dart` — new contract
- `packages/backend_supabase/lib/src/supabase_siparis_log_repository.dart` — new Supabase impl
- `packages/backend_core/lib/src/backend_module.dart` — `createSiparisLogRepository()` added
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — override added
- `packages/backend_core/lib/backend_core.dart` — new exports
- `packages/backend_supabase/lib/backend_supabase.dart` — new export
- `lib/product/siparis/siparis_log_providers.dart` — Riverpod provider
- `test/helpers/fakes/fake_siparis_repository.dart` — updated with 2 methods
- `test/helpers/fakes/fake_kurye_repository.dart` — new fake
- `test/domain/siparis_log_test.dart` — domain model tests
- `supabase/migrations/20260315000200_pricing_index.sql` — index migration
