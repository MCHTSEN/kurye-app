---
id: T01
parent: S02
milestone: M001
provides:
  - 4 domain models (Musteri, Ugrama, MusteriPersonel, Kurye)
  - 4 abstract repository contracts with CRUD methods
  - 4 Supabase CRUD implementations with AppLogger
  - BackendModule + SupabaseBackendModule factory methods
  - Barrel exports in both packages
  - 4 Riverpod provider files with generated .g.dart
  - 4 domain model test files
  - LogTag.data enum value
key_files:
  - packages/backend_core/lib/src/domain/musteri.dart
  - packages/backend_core/lib/src/domain/ugrama.dart
  - packages/backend_core/lib/src/domain/musteri_personel.dart
  - packages/backend_core/lib/src/domain/kurye.dart
  - packages/backend_core/lib/src/musteri_repository.dart
  - packages/backend_core/lib/src/ugrama_repository.dart
  - packages/backend_core/lib/src/musteri_personel_repository.dart
  - packages/backend_core/lib/src/kurye_repository.dart
  - packages/backend_supabase/lib/src/supabase_musteri_repository.dart
  - packages/backend_supabase/lib/src/supabase_ugrama_repository.dart
  - packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart
  - packages/backend_supabase/lib/src/supabase_kurye_repository.dart
  - lib/product/musteri/musteri_providers.dart
  - lib/product/ugrama/ugrama_providers.dart
  - lib/product/musteri_personel/musteri_personel_providers.dart
  - lib/product/kurye/kurye_providers.dart
key_decisions:
  - "D013: Added LogTag.data for master data CRUD logging"
  - "D014: Named bool parameter for updateOnlineStatus"
patterns_established:
  - "Supabase CRUD repos: constructor takes SupabaseClient, static _log with LogTag.data, _table constant, insert uses .select().single() to return created record"
  - "Ugramalar queries use explicit column selection to avoid Geography hex from lokasyon"
  - "Tables with BEFORE UPDATE triggers (musteriler, kuryeler) omit updated_at from update payloads"
  - "Riverpod providers: keepAlive repository provider + autoDispose list/family provider"
observability_surfaces:
  - "LogTag.data in all 4 Supabase repos — grep for LogTag.data or repo class names in console output"
duration: ~15min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Data layer — domain models, repositories, Supabase implementations, and providers

**Built complete data layer for 4 master data entities with domain models, repository contracts, Supabase CRUD implementations, Riverpod providers, and domain model tests.**

## What Happened

Created 4 domain models following AppUserProfile pattern (plain Dart, fromJson/toJson, no codegen). Created 4 abstract repository contracts with standard CRUD + entity-specific methods (getByMusteriId for ugrama/personel, updateOnlineStatus for kurye). Built 4 Supabase implementations following existing patterns — SupabaseUgramaRepository uses explicit column selection to skip Geography lokasyon field; SupabaseMusteriRepository and SupabaseKuryeRepository omit updated_at from update payloads since those tables have BEFORE UPDATE triggers.

Added `LogTag.data` to the logging system (enum + config field + switch case) since existing tags didn't cover data layer logging.

Added 4 factory methods to BackendModule (return null by default) and overrode all 4 in SupabaseBackendModule. Updated barrel exports in both packages. Created 4 Riverpod provider files and ran build_runner to generate .g.dart files.

Created 4 domain model test files covering fromJson/toJson roundtrip, nullable field handling, and lokasyon exclusion.

## Verification

- `cd packages/backend_core && dart analyze` — 0 issues ✅
- `cd packages/backend_supabase && dart analyze` — 0 issues ✅
- `flutter analyze` — 7 infos (all pre-existing, none from new code) ✅
- `dart run build_runner build --delete-conflicting-outputs` — 40 outputs, no errors ✅
- All 4 `.g.dart` files generated ✅
- `flutter test` — 61 tests, all passed ✅
- `flutter test test/domain/` — 14 tests (8 new + 6 existing), all passed ✅

### Slice-level verification (T01 progress):
- `flutter analyze` — ✅ 0 errors, 0 warnings
- `flutter test` — ✅ all pass
- `test/domain/musteri_test.dart` — ✅ passes
- `test/domain/ugrama_test.dart` — ✅ passes
- `test/domain/musteri_personel_test.dart` — ✅ passes
- `test/domain/kurye_test.dart` — ✅ passes
- Widget test for CRUD page — ⏳ not yet (later task)

## Diagnostics

- Grep for `LogTag.data` in console output to see CRUD operation logs
- Each Supabase repo logs create/update/delete at `.i()` level and list/get at `.d()` level
- Supabase exceptions propagate through Future failures — logged with operation context before bubbling up

## Deviations

- Added `LogTag.data` enum value and config field — not explicitly in plan but required since `LogTag` had no data-layer tag
- Changed `updateOnlineStatus` from positional bool to named parameter `{required bool isOnline}` to satisfy `very_good_analysis` linting

## Known Issues

None.

## Files Created/Modified

- `packages/backend_core/lib/src/domain/musteri.dart` — Musteri domain model
- `packages/backend_core/lib/src/domain/ugrama.dart` — Ugrama domain model (no lokasyon)
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
- `packages/backend_core/lib/src/backend_module.dart` — added 4 factory methods
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — 4 factory method overrides
- `packages/backend_core/lib/backend_core.dart` — 8 new exports (4 models + 4 repos)
- `packages/backend_supabase/lib/backend_supabase.dart` — 4 new exports
- `packages/backend_core/lib/src/logging/app_log_config.dart` — added LogTag.data enum + config field
- `lib/product/musteri/musteri_providers.dart` — Riverpod providers for Musteri
- `lib/product/ugrama/ugrama_providers.dart` — Riverpod providers for Ugrama
- `lib/product/musteri_personel/musteri_personel_providers.dart` — Riverpod providers for MusteriPersonel
- `lib/product/kurye/kurye_providers.dart` — Riverpod providers for Kurye
- `lib/product/musteri/musteri_providers.g.dart` — generated
- `lib/product/ugrama/ugrama_providers.g.dart` — generated
- `lib/product/musteri_personel/musteri_personel_providers.g.dart` — generated
- `lib/product/kurye/kurye_providers.g.dart` — generated
- `test/domain/musteri_test.dart` — Musteri fromJson/toJson tests
- `test/domain/ugrama_test.dart` — Ugrama fromJson/toJson + lokasyon null tests
- `test/domain/musteri_personel_test.dart` — MusteriPersonel fromJson/toJson tests
- `test/domain/kurye_test.dart` — Kurye fromJson/toJson tests
