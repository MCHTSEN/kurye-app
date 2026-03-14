---
estimated_steps: 8
estimated_files: 20
---

# T01: Data layer — domain models, repositories, Supabase implementations, and providers

**Slice:** S02 — Master Data CRUD
**Milestone:** M001

## Description

Create the complete data layer for the four master data entities: Musteri (customer), Ugrama (stop), MusteriPersonel (customer staff), and Kurye (courier). This includes plain Dart domain models, abstract repository contracts, Supabase CRUD implementations, BackendModule factory methods, barrel exports, and Riverpod providers. All follow the patterns established in S01.

## Steps

1. Create 4 domain models in `packages/backend_core/lib/src/domain/`:
   - `musteri.dart` — fields: id, firmaKisaAd, firmaTamAd?, telefon?, adres?, email?, vergiNo?, isActive, createdAt, updatedAt
   - `ugrama.dart` — fields: id, musteriId, ugramaAdi, adres?, isActive, createdAt (skip lokasyon — Geography deferred)
   - `musteri_personel.dart` — fields: id, musteriId, userId?, ad, telefon?, email?, isActive, createdAt
   - `kurye.dart` — fields: id, userId?, ad, telefon?, plaka?, isActive, isOnline, createdAt, updatedAt
   - Each with `fromJson` factory and `toJson()` method, following `AppUserProfile` pattern

2. Create 4 repository contracts in `packages/backend_core/lib/src/`:
   - `musteri_repository.dart` — abstract class with: `Future<List<Musteri>> getAll()`, `Future<Musteri?> getById(String id)`, `Future<Musteri> create(Musteri)`, `Future<Musteri> update(Musteri)`, `Future<void> delete(String id)`
   - `ugrama_repository.dart` — same pattern + `Future<List<Ugrama>> getByMusteriId(String musteriId)`
   - `musteri_personel_repository.dart` — same pattern + `Future<List<MusteriPersonel>> getByMusteriId(String musteriId)`
   - `kurye_repository.dart` — same pattern + `Future<void> updateOnlineStatus(String id, bool isOnline)`

3. Create 4 Supabase implementations in `packages/backend_supabase/lib/src/`:
   - Follow `SupabaseUserProfileRepository` pattern: constructor takes `SupabaseClient`, uses `AppLogger` with `LogTag.data`
   - For `ugramalar` queries, use explicit column selection: `.select('id, musteri_id, ugrama_adi, adres, is_active, created_at')` to avoid Geography hex issue
   - Don't include `updated_at` in update payloads for tables with `BEFORE UPDATE` triggers (`musteriler`, `kuryeler`)
   - Use `.select().single()` after insert to return the created record

4. Add 4 factory methods to `BackendModule`: `createMusteriRepository()`, `createUgramaRepository()`, `createMusteriPersonelRepository()`, `createKuryeRepository()` — all return null by default

5. Override all 4 factory methods in `SupabaseBackendModule` with `Supabase.instance.client`

6. Update barrel exports:
   - `packages/backend_core/lib/backend_core.dart` — add 4 domain models + 4 repository contracts
   - `packages/backend_supabase/lib/backend_supabase.dart` — add 4 Supabase implementations

7. Create 4 Riverpod provider files in `lib/product/`:
   - `lib/product/musteri/musteri_providers.dart` — `musteriRepository` (keepAlive) + `musteriList` (fetches all)
   - `lib/product/ugrama/ugrama_providers.dart` — `ugramaRepository` (keepAlive) + `ugramaListByMusteri(musteriId)` (family)
   - `lib/product/musteri_personel/musteri_personel_providers.dart` — same pattern
   - `lib/product/kurye/kurye_providers.dart` — `kuryeRepository` (keepAlive) + `kuryeList`
   - Run `dart run build_runner build --delete-conflicting-outputs` for codegen

8. Verify: `flutter analyze` clean on all packages

## Must-Haves

- [ ] 4 domain models with `fromJson`/`toJson` — no codegen, plain Dart
- [ ] 4 abstract repository contracts with CRUD methods
- [ ] 4 Supabase implementations with `AppLogger`, correct column selection for ugramalar
- [ ] `BackendModule` has 4 new optional factory methods
- [ ] `SupabaseBackendModule` overrides all 4
- [ ] Barrel exports updated in both packages
- [ ] 4 Riverpod provider files with generated `.g.dart`
- [ ] `flutter analyze` clean

## Verification

- `cd packages/backend_core && dart analyze` — 0 issues
- `cd packages/backend_supabase && dart analyze` — 0 issues
- `flutter analyze` — 0 issues (root project)
- `dart run build_runner build --delete-conflicting-outputs` — completes without errors
- All `.g.dart` files generated for new providers

## Observability Impact

- Signals added: `AppLogger` with `LogTag.data` in all 4 Supabase repository implementations — logs create/update/delete/list operations with entity context
- How a future agent inspects this: grep for `LogTag.data` in console output, or search for repository class names in logs
- Failure state exposed: Supabase exceptions propagate through Future failures, logged with operation context before rethrowing

## Inputs

- `packages/backend_core/lib/src/domain/app_user_profile.dart` — domain model pattern to follow
- `packages/backend_core/lib/src/user_profile_repository.dart` — repository contract pattern
- `packages/backend_supabase/lib/src/supabase_user_profile_repository.dart` — Supabase implementation pattern
- `packages/backend_supabase/lib/src/supabase_role_request_repository.dart` — more complete CRUD pattern with `.maybeSingle()`, `.order()`, `.eq()`
- `packages/backend_core/lib/src/backend_module.dart` — factory method pattern
- `lib/product/role_request/role_request_providers.dart` — Riverpod provider pattern
- `supabase/migrations/20260315000000_initial_schema.sql` — table schemas for field mapping

## Expected Output

- `packages/backend_core/lib/src/domain/musteri.dart` — Musteri domain model
- `packages/backend_core/lib/src/domain/ugrama.dart` — Ugrama domain model (no lokasyon field)
- `packages/backend_core/lib/src/domain/musteri_personel.dart` — MusteriPersonel domain model
- `packages/backend_core/lib/src/domain/kurye.dart` — Kurye domain model
- `packages/backend_core/lib/src/musteri_repository.dart` — abstract MusteriRepository
- `packages/backend_core/lib/src/ugrama_repository.dart` — abstract UgramaRepository
- `packages/backend_core/lib/src/musteri_personel_repository.dart` — abstract MusteriPersonelRepository
- `packages/backend_core/lib/src/kurye_repository.dart` — abstract KuryeRepository
- `packages/backend_supabase/lib/src/supabase_musteri_repository.dart` — Supabase CRUD for musteriler
- `packages/backend_supabase/lib/src/supabase_ugrama_repository.dart` — Supabase CRUD for ugramalar (explicit column selection)
- `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart` — Supabase CRUD for musteri_personelleri
- `packages/backend_supabase/lib/src/supabase_kurye_repository.dart` — Supabase CRUD for kuryeler
- `packages/backend_core/lib/src/backend_module.dart` — 4 new factory methods added
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — 4 factory method overrides
- `packages/backend_core/lib/backend_core.dart` — 8 new exports (4 models + 4 repos)
- `packages/backend_supabase/lib/backend_supabase.dart` — 4 new exports
- `lib/product/musteri/musteri_providers.dart` + `.g.dart`
- `lib/product/ugrama/ugrama_providers.dart` + `.g.dart`
- `lib/product/musteri_personel/musteri_personel_providers.dart` + `.g.dart`
- `lib/product/kurye/kurye_providers.dart` + `.g.dart`
