# S02: Master Data CRUD — UAT

**Milestone:** M001
**Written:** 2026-03-15

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: All CRUD logic is covered by domain model unit tests (8 tests) and widget tests (4 tests for MusteriKayitPage). Supabase implementations follow established patterns from S01. Live runtime testing deferred to S08 cross-role integration.

## Preconditions

- `flutter analyze` passes with 0 errors/warnings
- `flutter test` passes all 65 tests
- `dart run build_runner build` completes with all `.g.dart` files generated

## Smoke Test

Run `flutter test test/feature/operasyon/musteri_kayit_page_test.dart` — all 4 widget tests pass confirming form render, validation, create, and edit modes work.

## Test Cases

### 1. Domain model roundtrip (all 4 entities)

1. Run `flutter test test/domain/`
2. **Expected:** 8 tests pass — fromJson/toJson roundtrip and nullable field handling for Musteri, Ugrama, MusteriPersonel, Kurye

### 2. MusteriKayitPage form rendering

1. Run `flutter test test/feature/operasyon/musteri_kayit_page_test.dart`
2. **Expected:** Form fields (Ad, Telefon, Adres) render, submit button visible, empty list state shown

### 3. MusteriKayitPage validation

1. Test attempts submit with empty required field (Ad)
2. **Expected:** Validation error shown, no repository call made

### 4. MusteriKayitPage create flow

1. Test fills form fields and taps submit
2. **Expected:** Record created via repository, list refreshes showing new müşteri

### 5. MusteriKayitPage edit flow

1. Test taps existing list item
2. **Expected:** Form populated with entity data, _editingId set, submit updates instead of creates

### 6. Drawer navigation

1. Build app for iOS simulator
2. Navigate operasyon dashboard drawer items
3. **Expected:** Müşteri Kayıt, Uğrama Yönetim, Personel Kayıt, Kurye Yönetim, Rol Onayları all navigate to correct pages

### 7. Role approval with müşteri assignment

1. Open Rol Onayları page with pending müşteri_personel request
2. Attempt approve without selecting müşteri
3. **Expected:** SnackBar warns müşteri selection required, approval blocked

## Edge Cases

### Ugrama lokasyon null handling

1. Run `flutter test test/domain/ugrama_test.dart`
2. **Expected:** Ugrama model handles missing lokasyon field — field excluded from domain model per D010

### Kurye is_online default

1. Run `flutter test test/domain/kurye_test.dart`
2. **Expected:** Kurye model defaults `is_online` to false when field not present in JSON

## Failure Signals

- `flutter analyze` reports errors in new files — indicates syntax or type issues in CRUD pages
- Domain model tests fail — fromJson/toJson contract broken
- Widget tests fail — form rendering, validation, or repository integration broken
- Build fails for iOS simulator — router or import issues
- SnackBar not showing after CRUD operations — error handling chain broken

## Requirements Proved By This UAT

- R003 — Customer CRUD: domain model tests + CRUD page widget tests prove create/edit/list works
- R004 — Stop CRUD: domain model tests prove model correctness, Supabase impl follows verified pattern
- R005 — Customer staff CRUD: domain model tests prove model correctness
- R006 — Courier management: domain model tests prove model + is_online handling

## Not Proven By This UAT

- Live Supabase CRUD with RLS policies — requires running app against real DB (covered in S08)
- Drawer navigation end-to-end — requires iOS simulator runtime
- Role approval flow against real Supabase — requires real pending requests and auth tokens
- CRUD operations under concurrent use — no concurrency testing

## Notes for Tester

- All 6 `flutter analyze` infos are pre-existing in auth/role_selection files, not from S02 code
- Geography `lokasyon` is intentionally excluded from Ugrama — this is by design (D010), not a bug
- CRUD pages have no pagination or delete confirmation — functional but not polished, polish deferred
