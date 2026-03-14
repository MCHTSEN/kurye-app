# S02: Master Data CRUD

**Goal:** Operations can create, edit, and list all four master data entities (müşteri, uğrama, personel, kurye) and approve role requests — all verified against live Supabase.
**Demo:** Operasyon user navigates via drawer to each CRUD page, creates a new record, sees it in the list, edits it. Approves a pending role request from the dashboard.

## Must-Haves

- `Musteri`, `Ugrama`, `MusteriPersonel`, `Kurye` domain models with `fromJson`/`toJson`
- Repository contracts for all 4 entities (list, create, update, getById)
- Supabase implementations for all 4 repositories
- Riverpod providers exposing repository + entity lists
- 4 CRUD pages with master-detail layout (form top, list bottom) replacing placeholders
- Drawer navigation wired to all CRUD routes
- Kurye management route added to `CustomRoute` and router
- Role request approval screen for operasyon
- `approveRequest()` extended to set `musteri_id` for müşteri_personel role
- Unit tests for domain models and repository contract fakes
- `flutter analyze` clean, `flutter test` passes

## Proof Level

- This slice proves: contract + integration (CRUD against Supabase RLS)
- Real runtime required: yes (Supabase CRUD with operasyon RLS)
- Human/UAT required: no (automated tests + analyze sufficient)

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all pass (including new domain model + repository tests)
- `test/domain/musteri_test.dart` — Musteri fromJson/toJson roundtrip
- `test/domain/ugrama_test.dart` — Ugrama fromJson/toJson, lokasyon null handling
- `test/domain/musteri_personel_test.dart` — MusteriPersonel fromJson/toJson
- `test/domain/kurye_test.dart` — Kurye fromJson/toJson
- At least one widget test for a CRUD page primary state

## Observability / Diagnostics

- Runtime signals: `AppLogger` with `LogTag.data` on all Supabase CRUD operations (create/update/delete/list)
- Inspection surfaces: Supabase Dashboard for DB state, `AppLogger` console output
- Failure visibility: Supabase exceptions surfaced through `AsyncValue.error` in UI, logged with context
- Redaction constraints: none (no secrets in master data)

## Integration Closure

- Upstream surfaces consumed: `BackendModule` factory pattern, `SupabaseClient`, `CustomRoute` enum, drawer `ListTile` handlers, `AppAccessGuard` role routing, `RoleRequestRepository.approveRequest()`
- New wiring introduced: 4 repository factory methods on `BackendModule`, 4 Supabase impl registrations, Riverpod providers for entity data, `kuryeYonetim` route in router
- What remains before milestone is truly usable end-to-end: S03 (order creation), S04 (dispatch), S05 (courier workflow), S06 (history), S07 (analytics), S08 (integration)

## Tasks

- [x] **T01: Data layer — domain models, repositories, Supabase implementations, and providers** `est:2h`
  - Why: Foundation for all CRUD UI — models, contracts, and data access must exist before pages can consume them
  - Files: `packages/backend_core/lib/src/domain/musteri.dart`, `packages/backend_core/lib/src/domain/ugrama.dart`, `packages/backend_core/lib/src/domain/musteri_personel.dart`, `packages/backend_core/lib/src/domain/kurye.dart`, `packages/backend_core/lib/src/musteri_repository.dart`, `packages/backend_core/lib/src/ugrama_repository.dart`, `packages/backend_core/lib/src/musteri_personel_repository.dart`, `packages/backend_core/lib/src/kurye_repository.dart`, `packages/backend_supabase/lib/src/supabase_musteri_repository.dart`, `packages/backend_supabase/lib/src/supabase_ugrama_repository.dart`, `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart`, `packages/backend_supabase/lib/src/supabase_kurye_repository.dart`, `packages/backend_core/lib/src/backend_module.dart`, `packages/backend_core/lib/backend_core.dart`, `packages/backend_supabase/lib/src/supabase_backend_module.dart`, `packages/backend_supabase/lib/backend_supabase.dart`, `lib/product/musteri/musteri_providers.dart`, `lib/product/ugrama/ugrama_providers.dart`, `lib/product/musteri_personel/musteri_personel_providers.dart`, `lib/product/kurye/kurye_providers.dart`
  - Do: Create 4 domain models following `AppUserProfile` pattern (plain dart, hand-written JSON, no codegen). Create 4 abstract repository contracts with `getAll()`, `getById()`, `create()`, `update()`, `delete()` methods. Create 4 Supabase implementations following `SupabaseUserProfileRepository` pattern with `AppLogger(tag: LogTag.data)`. Add factory methods to `BackendModule`, override in `SupabaseBackendModule`. Update barrel exports. Create Riverpod providers following `role_request_providers.dart` pattern. For `ugramalar` select, explicitly list columns excluding `lokasyon` to avoid Geography hex issue. Don't include `updated_at` in update payloads (trigger handles it). Run `dart run build_runner build --delete-conflicting-outputs` for provider codegen.
  - Verify: `flutter analyze` clean, `dart run build_runner build` succeeds with no errors
  - Done when: All 4 models, 4 repo contracts, 4 Supabase impls, 4 provider files exist with generated `.g.dart`, barrel exports updated, `flutter analyze` clean

- [x] **T02: CRUD UI pages, drawer wiring, and kurye route** `est:2h`
  - Why: Replace 4 placeholder pages with real master-detail CRUD forms, wire drawer navigation, and add kurye management route so operasyon can actually manage data
  - Files: `lib/feature/operasyon/presentation/musteri_kayit_page.dart`, `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart`, `lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart`, `lib/feature/operasyon/presentation/kurye_yonetim_page.dart`, `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`, `lib/app/router/custom_route.dart`, `lib/app/router/app_router.dart`
  - Do: Add `kuryeYonetim('/operasyon/kurye')` to `CustomRoute` enum with routeName. Add route definition in `app_router.dart`. Create `kurye_yonetim_page.dart`. Replace all 4 placeholder pages with master-detail layout: form in `AppSectionCard` at top (TextFormField for each column, dropdown for müşteri_id on uğrama/personel pages), entity list at bottom using `AsyncValue` pattern. Wire drawer `ListTile.onTap` with `context.router.pushNamed(CustomRoute.xxx.path)`. Add kurye management drawer item. Each page uses `ConsumerStatefulWidget` with form controllers, validates on submit, calls repository via provider, and refreshes list. Use `AppPrimaryButton` for submit with loading state.
  - Verify: `flutter analyze` clean, app builds for iOS simulator, drawer navigation works between all pages
  - Done when: All 4 CRUD pages show form + list, drawer navigates to each, kurye route registered, `flutter analyze` clean

- [x] **T03: Role approval screen, approval flow fix, and test coverage** `est:1.5h`
  - Why: Completes the slice — role approval screen is a slice deliverable, `approveRequest` needs `musteri_id` for müşteri_personel role, and domain model tests prove contract correctness
  - Files: `lib/feature/operasyon/presentation/rol_onay_page.dart`, `packages/backend_core/lib/src/role_request_repository.dart`, `packages/backend_supabase/lib/src/supabase_role_request_repository.dart`, `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`, `test/domain/musteri_test.dart`, `test/domain/ugrama_test.dart`, `test/domain/musteri_personel_test.dart`, `test/domain/kurye_test.dart`, `test/helpers/fakes/fake_musteri_repository.dart`, `test/feature/operasyon/musteri_kayit_page_test.dart`
  - Do: Create `RolOnayPage` showing pending role requests with approve/reject buttons. For müşteri_personel requests, show a müşteri dropdown so operasyon can assign a customer. Extend `RoleRequestRepository.approveRequest()` signature to accept optional `musteriId`. Update Supabase implementation to set `musteri_id` on `app_users` when provided. Add drawer item for role approval (or embed in dashboard). Write domain model unit tests — `fromJson`/`toJson` roundtrip for all 4 models, null field handling, Geography null for Ugrama. Create `FakeMusteriRepository` for test infra. Write one widget test for `MusteriKayitPage` showing list state.
  - Verify: `flutter analyze` clean, `flutter test` all pass
  - Done when: Role approval screen works, `approveRequest` handles `musteri_id`, all domain model tests pass, at least one widget test for CRUD page exists

## Files Likely Touched

- `packages/backend_core/lib/src/domain/musteri.dart`
- `packages/backend_core/lib/src/domain/ugrama.dart`
- `packages/backend_core/lib/src/domain/musteri_personel.dart`
- `packages/backend_core/lib/src/domain/kurye.dart`
- `packages/backend_core/lib/src/musteri_repository.dart`
- `packages/backend_core/lib/src/ugrama_repository.dart`
- `packages/backend_core/lib/src/musteri_personel_repository.dart`
- `packages/backend_core/lib/src/kurye_repository.dart`
- `packages/backend_core/lib/src/backend_module.dart`
- `packages/backend_core/lib/backend_core.dart`
- `packages/backend_supabase/lib/src/supabase_musteri_repository.dart`
- `packages/backend_supabase/lib/src/supabase_ugrama_repository.dart`
- `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart`
- `packages/backend_supabase/lib/src/supabase_kurye_repository.dart`
- `packages/backend_supabase/lib/src/supabase_backend_module.dart`
- `packages/backend_supabase/lib/backend_supabase.dart`
- `lib/product/musteri/musteri_providers.dart`
- `lib/product/ugrama/ugrama_providers.dart`
- `lib/product/musteri_personel/musteri_personel_providers.dart`
- `lib/product/kurye/kurye_providers.dart`
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart`
- `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart`
- `lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart`
- `lib/feature/operasyon/presentation/kurye_yonetim_page.dart`
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`
- `lib/feature/operasyon/presentation/rol_onay_page.dart`
- `lib/app/router/custom_route.dart`
- `lib/app/router/app_router.dart`
- `packages/backend_core/lib/src/role_request_repository.dart`
- `packages/backend_supabase/lib/src/supabase_role_request_repository.dart`
- `test/domain/musteri_test.dart`
- `test/domain/ugrama_test.dart`
- `test/domain/musteri_personel_test.dart`
- `test/domain/kurye_test.dart`
- `test/helpers/fakes/fake_musteri_repository.dart`
- `test/feature/operasyon/musteri_kayit_page_test.dart`
