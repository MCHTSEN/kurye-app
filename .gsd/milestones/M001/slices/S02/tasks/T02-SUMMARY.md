---
id: T02
parent: S02
milestone: M001
provides:
  - 4 real master-detail CRUD pages replacing placeholders (MusteriKayit, UgramaYonetim, MusteriPersonelKayit, KuryeYonetim)
  - kuryeYonetim route registered in CustomRoute and app_router
  - All drawer navigation items wired to correct routes
  - ugramaList and musteriPersonelList providers (getAll variants)
  - 4 widget tests for MusteriKayitPage
key_files:
  - lib/feature/operasyon/presentation/musteri_kayit_page.dart
  - lib/feature/operasyon/presentation/ugrama_yonetim_page.dart
  - lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart
  - lib/feature/operasyon/presentation/kurye_yonetim_page.dart
  - lib/feature/operasyon/presentation/operasyon_dashboard_page.dart
  - lib/app/router/custom_route.dart
  - lib/app/router/app_router.dart
  - test/feature/operasyon/musteri_kayit_page_test.dart
key_decisions:
  - Pulled widget test forward from T03 into T02 — natural to test alongside CRUD page implementation
  - Used Navigator.pushNamed for drawer navigation (matches existing app pattern) with unawaited() wrapper
  - Used DropdownButtonFormField.initialValue instead of deprecated .value parameter (Flutter 3.41+)
patterns_established:
  - "CRUD page pattern: ConsumerStatefulWidget, _formKey + controllers, _editingId for edit/create mode, _populateForm(entity) on list tap, _clearForm for cancel, _onSubmit calls repo.create/update then invalidates list provider"
  - "Entity list display: AsyncValue.when with AppSectionCard wrapping Column of ListTiles, active status shown as colored circle icon"
  - "Müşteri dropdown pattern: DropdownButtonFormField inside musteriAsync.when, validator requires non-null selection"
observability_surfaces:
  - Supabase exceptions surface through AsyncValue.error in UI (from T01 repo layer)
  - Form validation errors shown inline via TextFormField validator
  - SnackBar feedback on successful create/update and on errors
duration: ~45min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: CRUD UI pages, drawer wiring, and kurye route

**Built 4 real master-detail CRUD pages, added kurye management route, wired all drawer navigation, and added widget tests for MusteriKayitPage.**

## What Happened

Replaced all 4 placeholder operasyon pages with real CRUD interfaces following a consistent master-detail pattern: form in AppSectionCard at top, entity list at bottom. Each page is a ConsumerStatefulWidget managing form state through controllers and an `_editingId` variable that switches between create and edit modes.

Added `kuryeYonetim('/operasyon/kurye')` to CustomRoute enum and registered it in app_router. Created KuryeYonetimPage with ad/telefon/plaka fields and online status indicator.

UgramaYonetim and MusteriPersonelKayit pages include a müşteri dropdown (DropdownButtonFormField) that loads from musteriListProvider. Added `ugramaList` and `musteriPersonelList` providers calling `getAll()` since only the byMusteri variants existed from T01.

Wired all drawer navigation items with `Navigator.pushNamed(context, CustomRoute.xxx.path)` wrapped in `unawaited()` to satisfy the analyzer. Added kurye management drawer item with `Icons.two_wheeler`.

Created 4 widget tests for MusteriKayitPage covering: form rendering, required field validation, record creation with list refresh, and edit mode population on list item tap.

## Verification

- `flutter analyze` — 6 infos (all pre-existing in other files, 0 from T02 code)
- `flutter test` — 65 tests pass (61 prior + 4 new widget tests)
- `flutter build ios --simulator` — builds successfully
- Widget tests verify: form fields render, validation blocks empty submit, create adds to list, tap populates edit form

### Slice-level verification status (intermediate — T03 remains):
- ✅ `flutter analyze` — 0 errors, 0 warnings
- ✅ `flutter test` — all pass
- ✅ `test/domain/musteri_test.dart` — passes
- ✅ `test/domain/ugrama_test.dart` — passes
- ✅ `test/domain/musteri_personel_test.dart` — passes
- ✅ `test/domain/kurye_test.dart` — passes
- ✅ At least one widget test for a CRUD page primary state — 4 tests

## Diagnostics

- Form errors visible inline via TextFormField validators
- CRUD operation success/failure shown via SnackBar
- Repository-level logging via AppLogger with LogTag.data (from T01) traces all Supabase operations
- AsyncValue.error surfaces repository exceptions directly in UI

## Deviations

- Added `ugramaList` and `musteriPersonelList` providers — T01 only created `getByMusteriId` variants, management pages need `getAll()`
- Widget test was scoped to T03 in the plan but pulled forward — makes more sense alongside the page implementation
- Fixed pre-existing import ordering in app_router.dart (directives_ordering lint)

## Known Issues

None.

## Files Created/Modified

- `lib/app/router/custom_route.dart` — added `kuryeYonetim` enum value with routeName
- `lib/app/router/app_router.dart` — registered kurye yönetim route, fixed import ordering
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart` — real CRUD page replacing placeholder
- `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart` — real CRUD page with müşteri dropdown
- `lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart` — real CRUD page with müşteri dropdown
- `lib/feature/operasyon/presentation/kurye_yonetim_page.dart` — new CRUD page for kurye management
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — drawer wired to all routes + kurye item
- `lib/product/ugrama/ugrama_providers.dart` — added `ugramaList` provider
- `lib/product/musteri_personel/musteri_personel_providers.dart` — added `musteriPersonelList` provider
- `lib/product/ugrama/ugrama_providers.g.dart` — generated
- `lib/product/musteri_personel/musteri_personel_providers.g.dart` — generated
- `test/feature/operasyon/musteri_kayit_page_test.dart` — 4 widget tests for CRUD page
