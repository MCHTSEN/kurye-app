---
id: S02
parent: M001
milestone: M001
provides:
  - 4 domain models (Musteri, Ugrama, MusteriPersonel, Kurye) with fromJson/toJson
  - 4 abstract repository contracts with CRUD methods
  - 4 Supabase CRUD implementations with AppLogger(LogTag.data)
  - BackendModule + SupabaseBackendModule factory methods for all 4 repos
  - Barrel exports in backend_core and backend_supabase
  - Riverpod providers for all entity data (repo + list + byMusteri variants)
  - 4 master-detail CRUD pages replacing placeholders
  - kuryeYonetim route registered in CustomRoute and app_router
  - Drawer navigation wired to all CRUD routes
  - RolOnayPage — approval screen with müşteri dropdown for personel role
  - approveRequest extended with optional musteriId parameter
  - FakeMusteriRepository shared test helper
  - 8 domain model tests + 4 widget tests for MusteriKayitPage
requires:
  - slice: S01
    provides: BackendModule factory pattern, SupabaseClient, CustomRoute enum, drawer handlers, AppAccessGuard, RoleRequestRepository.approveRequest(), Supabase DB schema
affects:
  - S03
  - S04
  - S05
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
  - lib/feature/operasyon/presentation/musteri_kayit_page.dart
  - lib/feature/operasyon/presentation/ugrama_yonetim_page.dart
  - lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart
  - lib/feature/operasyon/presentation/kurye_yonetim_page.dart
  - lib/feature/operasyon/presentation/rol_onay_page.dart
  - lib/feature/operasyon/presentation/operasyon_dashboard_page.dart
  - test/feature/operasyon/musteri_kayit_page_test.dart
  - test/helpers/fakes/fake_musteri_repository.dart
key_decisions:
  - "D010: Skip lokasyon Geography in domain model — use explicit column selection in Supabase queries"
  - "D011: CRUD page pattern — master-detail with form top, list bottom, tap to edit"
  - "D012: approveRequest extended with optional musteriId for müşteri_personel role"
  - "D013: LogTag.data added for master data CRUD logging"
  - "D014: Named bool in KuryeRepository.updateOnlineStatus"
patterns_established:
  - "Supabase CRUD repos: constructor takes SupabaseClient, static _log with LogTag.data, _table constant, insert uses .select().single() to return created record"
  - "Ugramalar queries use explicit column selection to avoid Geography hex from lokasyon"
  - "Tables with BEFORE UPDATE triggers (musteriler, kuryeler) omit updated_at from update payloads"
  - "Riverpod providers: keepAlive repository provider + autoDispose list/family provider"
  - "CRUD page pattern: ConsumerStatefulWidget, _formKey + controllers, _editingId for edit/create mode, _populateForm on tap, _clearForm for cancel, _onSubmit calls repo then invalidates list"
  - "Müşteri dropdown: DropdownButtonFormField inside musteriAsync.when, validator requires non-null"
observability_surfaces:
  - "LogTag.data in all 4 Supabase repos — grep for LogTag.data in console output"
  - "Form validation errors shown inline via TextFormField validators"
  - "SnackBar feedback on CRUD success/failure and approval outcomes"
  - "AsyncValue.error surfaces Supabase exceptions in UI"
drill_down_paths:
  - .gsd/milestones/M001/slices/S02/tasks/T01-SUMMARY.md
  - .gsd/milestones/M001/slices/S02/tasks/T02-SUMMARY.md
  - .gsd/milestones/M001/slices/S02/tasks/T03-SUMMARY.md
duration: ~1.5h
verification_result: passed
completed_at: 2026-03-15
---

# S02: Master Data CRUD

**Operations can create, edit, and list all 4 master data entities (müşteri, uğrama, personel, kurye) through real CRUD pages, and approve role requests with müşteri assignment — all backed by Supabase with domain model tests and widget tests.**

## What Happened

Built the complete data layer first (T01): 4 domain models following AppUserProfile's plain-Dart pattern, 4 abstract repository contracts, and 4 Supabase implementations. Key patterns: ugramalar queries use explicit column selection to skip the Geography `lokasyon` field (returns hex WKB otherwise), and tables with BEFORE UPDATE triggers omit `updated_at` from payloads. Added `LogTag.data` to the logging system. Created Riverpod providers following the existing keepAlive-repo + autoDispose-list pattern.

Then replaced all 4 placeholder operasyon pages with real master-detail CRUD interfaces (T02): form in AppSectionCard at top, entity list at bottom. Each page manages create/edit mode through an `_editingId` variable. Added `kuryeYonetim` route to CustomRoute and app_router. Wired all drawer navigation items. UgramaYonetim and MusteriPersonelKayit pages include müşteri dropdowns for filtering. Added `ugramaList` and `musteriPersonelList` getAll providers alongside the existing byMusteri variants.

Finally (T03), built the RolOnayPage for approving pending role requests. Extended `approveRequest()` contract with optional `musteriId` — when approving a müşteri_personel request, operasyon must select a müşteri from a dropdown so the user's `musteri_id` gets set on `app_users` (required for RLS). Added route and drawer item. Extracted FakeMusteriRepository to shared test helpers.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (6 infos all pre-existing in other files)
- `flutter test` — 65/65 pass
- `test/domain/musteri_test.dart` — 2 tests pass (fromJson/toJson roundtrip, nullable fields)
- `test/domain/ugrama_test.dart` — 2 tests pass (roundtrip, lokasyon null handling)
- `test/domain/musteri_personel_test.dart` — 2 tests pass (roundtrip, nullable fields)
- `test/domain/kurye_test.dart` — 2 tests pass (roundtrip, is_online default)
- `test/feature/operasyon/musteri_kayit_page_test.dart` — 4 tests pass (form render, validation, create, edit)
- `flutter build ios --simulator` — builds successfully

## Requirements Advanced

- R003 — Customer CRUD implemented: domain model, repository, Supabase impl, CRUD page with form + list
- R004 — Stop CRUD implemented: domain model (lokasyon excluded per D010), repository with byMusteri, CRUD page with müşteri dropdown
- R005 — Customer staff CRUD implemented: domain model, repository with byMusteri, CRUD page with müşteri dropdown
- R006 — Courier management implemented: domain model with is_online, repository with updateOnlineStatus, CRUD page with status indicator

## Requirements Validated

- R003 — Domain model unit tests + widget test for CRUD page + Supabase implementation verified by analyze/test
- R004 — Domain model unit tests with lokasyon null handling + Supabase implementation verified
- R005 — Domain model unit tests + Supabase implementation verified
- R006 — Domain model unit tests + Supabase implementation verified

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Deviations

- Widget tests pulled forward from T03 to T02 — made more sense to test alongside page implementation
- Added `ugramaList` and `musteriPersonelList` providers — T01 only created byMusteri variants, management pages need getAll
- Domain model tests in T03 were already done in T01 — only verified passing, no new test files

## Known Limitations

- Geography `lokasyon` field excluded from Ugrama domain model (D010) — deferred to M002 (R019)
- CRUD pages are functional but not polished — no pagination, no search/filter, no confirmation dialogs on delete
- RolOnayPage reject flow uses simple dialog — no reason tracking persisted server-side

## Follow-ups

None — all planned deliverables complete.

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
- `packages/backend_supabase/lib/src/supabase_ugrama_repository.dart` — Supabase CRUD for ugramalar
- `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart` — Supabase CRUD for musteri_personelleri
- `packages/backend_supabase/lib/src/supabase_kurye_repository.dart` — Supabase CRUD for kuryeler
- `packages/backend_core/lib/src/backend_module.dart` — 4 factory methods added
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — 4 overrides
- `packages/backend_core/lib/backend_core.dart` — 8 new exports
- `packages/backend_supabase/lib/backend_supabase.dart` — 4 new exports
- `packages/backend_core/lib/src/logging/app_log_config.dart` — LogTag.data added
- `packages/backend_core/lib/src/role_request_repository.dart` — approveRequest + musteriId
- `packages/backend_supabase/lib/src/supabase_role_request_repository.dart` — musteriId in upsert
- `lib/product/musteri/musteri_providers.dart` — Musteri Riverpod providers
- `lib/product/ugrama/ugrama_providers.dart` — Ugrama providers + ugramaList
- `lib/product/musteri_personel/musteri_personel_providers.dart` — MusteriPersonel providers + list
- `lib/product/kurye/kurye_providers.dart` — Kurye Riverpod providers
- `lib/app/router/custom_route.dart` — kuryeYonetim + rolOnay routes
- `lib/app/router/app_router.dart` — route registrations
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart` — real CRUD page
- `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart` — real CRUD page
- `lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart` — real CRUD page
- `lib/feature/operasyon/presentation/kurye_yonetim_page.dart` — new CRUD page
- `lib/feature/operasyon/presentation/rol_onay_page.dart` — role approval screen
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — drawer wiring + items
- `test/domain/musteri_test.dart` — domain model tests
- `test/domain/ugrama_test.dart` — domain model tests
- `test/domain/musteri_personel_test.dart` — domain model tests
- `test/domain/kurye_test.dart` — domain model tests
- `test/feature/operasyon/musteri_kayit_page_test.dart` — 4 widget tests
- `test/helpers/fakes/fake_musteri_repository.dart` — shared test fake

## Forward Intelligence

### What the next slice should know
- All 4 master data repos are registered on BackendModule and available via Riverpod providers — S03 needs `musteriListProvider`, `ugramasByMusteriProvider(musteriId)`, and `musteriPersonelsByMusteriProvider(musteriId)` for cascading order creation dropdowns
- The `Ugrama` model deliberately excludes the `lokasyon` Geography field — queries use explicit column selection. If S03+ needs location, this pattern must be extended.
- `approveRequest()` now sets `musteri_id` on `app_users` — müşteri_personel users will have `musteriId` on their `AppUserProfile`, which is needed for S03's customer-scoped order creation

### What's fragile
- Explicit column selection in `SupabaseUgramaRepository` — any new column added to `ugramalar` table must be added to the SELECT list manually, or it won't appear in results
- `updated_at` omission in update payloads for `musteriler` and `kuryeler` — relies on BEFORE UPDATE triggers existing; if triggers are dropped, timestamps stop updating

### Authoritative diagnostics
- Grep `LogTag.data` in console output to see all CRUD operations across 4 repos
- Each repo logs at `.i()` for mutations and `.d()` for reads — filter by repo class name for entity-specific traces

### What assumptions changed
- Widget tests were assumed to be T03 work but naturally fit T02 — future slices should plan tests alongside the UI they cover
