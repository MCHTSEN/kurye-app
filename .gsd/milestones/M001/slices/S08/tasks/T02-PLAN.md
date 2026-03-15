---
estimated_steps: 5
estimated_files: 4
---

# T02: Resolve raw UUIDs to names on dispatch and courier screens

**Slice:** S08 — Cross-role integration & polish
**Milestone:** M001

## Description

Apply the D027 ID-to-name resolution pattern (established in `operasyon_gecmis_page.dart`) to the dispatch page and courier page. Replace raw UUID strings with human-readable stop names and courier names. All lookups fall back gracefully to the raw ID when the name isn't found.

## Steps

1. In `operasyon_ekran_page.dart` `_buildBody` — add `ref.watch(ugramaListProvider)` (currently not watched on this page). The `kuryeListProvider` is already watched inside `_buildWaitingPanel` — move it up to `_buildBody` level so both panels can use it. Build `ugramaMap` and `kuryeMap` using the same pattern as `operasyon_gecmis_page.dart`.
2. Update `_routeLabel(Siparis s)` to accept the maps and resolve `cikisId`/`ugramaId` to names: `ugramaMap[s.cikisId] ?? s.cikisId`. Update `subtitle` in active panel from `Kurye: ${s.kuryeId ?? '-'}` to `Kurye: ${kuryeMap[s.kuryeId] ?? s.kuryeId ?? '-'}`. Pass maps through to helper methods or make them available via widget state.
3. In `kurye_ana_page.dart` — add `ref.watch(ugramaListProvider)` and build `ugramaMap`. Replace `'${order.cikisId} → ${order.ugramaId}'` with resolved names. Also resolve `ugrama1Id` if present.
4. Add/update widget tests: in `operasyon_ekran_page_test.dart`, verify that rendered text shows stop names (from fake ugramalar) instead of raw IDs. In `kurye_ana_page_test.dart`, verify resolved names appear in order card text.
5. Run `flutter analyze` and `flutter test` — verify zero regressions.

## Must-Haves

- [ ] Dispatch waiting panel shows stop names in route labels
- [ ] Dispatch active panel shows stop names and courier names
- [ ] Courier order cards show stop names instead of UUIDs
- [ ] Fallback to raw ID when name lookup fails — no crashes
- [ ] Widget tests verify name resolution on both screens
- [ ] Zero regressions — all tests pass

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all pass including updated display tests
- Inspect test assertions for resolved names (e.g. fake ugrama name appearing in rendered widgets)

## Inputs

- `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart:232-249` — D027 pattern to replicate
- `lib/product/ugrama/ugrama_providers.dart` — `ugramaListProvider` (all stops)
- `lib/product/kurye/kurye_providers.dart` — `kuryeListProvider` (all couriers)
- `test/helpers/fakes/fake_ugrama_repository.dart` — provides fake stop data for tests

## Expected Output

- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — name resolution in dispatch panels
- `lib/feature/kurye/presentation/kurye_ana_page.dart` — name resolution in courier order cards
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — updated/new test verifying names
- `test/feature/kurye/kurye_ana_page_test.dart` — updated/new test verifying names
