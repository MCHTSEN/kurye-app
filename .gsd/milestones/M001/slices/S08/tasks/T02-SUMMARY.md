---
id: T02
parent: S08
milestone: M001
provides:
  - Name resolution on dispatch page (waiting + active panels) via ugramaMap/kuryeMap
  - Name resolution on courier page order cards via ugramaMap
  - Graceful fallback to raw UUIDs when lookup misses
key_files:
  - lib/feature/operasyon/presentation/operasyon_ekran_page.dart
  - lib/feature/kurye/presentation/kurye_ana_page.dart
  - test/feature/operasyon/operasyon_ekran_page_test.dart
  - test/feature/kurye/kurye_ana_page_test.dart
key_decisions:
  - Built ugramaMap/kuryeMap at _buildDispatchPanels level and passed as named params to panel builders and _routeLabel — avoids watching the same providers in multiple child methods
  - Passed ugramaMap down through _OrderListSection → _OrderCard constructor chain rather than watching provider in each widget — single source of truth, no duplicate fetches
patterns_established:
  - D027 name-resolution pattern now applied consistently across all three ops screens (history, dispatch, courier)
observability_surfaces:
  - none — name resolution is pure map lookup with null-safe fallback; no runtime failure path to instrument
duration: ~15 min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Resolve raw UUIDs to names on dispatch and courier screens

**Applied D027 ID-to-name resolution pattern to dispatch and courier pages — stop names and courier names replace raw UUIDs, with graceful fallback.**

## What Happened

Added `ugramaListProvider` and `kuryeListProvider` watches in `_buildDispatchPanels` to build name-resolution maps. Updated `_routeLabel` to accept `ugramaMap` and resolve `cikisId`/`ugramaId` to human-readable stop names. Updated active panel subtitle to resolve `kuryeId` to courier name via `kuryeMap`. Both fall back to the raw ID string when the name isn't found.

On the courier page, added `ugramaListProvider` watch in `_KuryeBody`, built `ugramaMap`, and threaded it through `_OrderListSection` → `_OrderCard`. The order card now resolves `cikisId`, `ugramaId`, and `ugrama1Id` to stop names.

Updated existing tests to expect resolved names and added 4 new tests: dispatch active panel name resolution (g), dispatch fallback to raw IDs (h), courier resolved names (b updated), and courier fallback (g).

## Verification

- `flutter analyze` — 0 errors, 0 warnings (40 infos, all pre-existing)
- `flutter test` — 118/118 pass, 0 failures
- Test (g) dispatch: confirms `'Merkez Ofis → Şube B'` and `'Kurye: Ali Kurye'` rendered
- Test (h) dispatch: confirms `'unknown-stop-x → unknown-stop-y'` fallback
- Test (b) courier: confirms `'Depo A → Şube B → Şube C'` rendered from resolved names
- Test (g) courier: confirms `'unknown-x → unknown-y'` fallback

### Slice-level verification status

- ✅ `flutter test` — all 118 tests pass
- ✅ `flutter analyze` — 0 errors, 0 warnings
- ✅ `operasyon_ekran_page_test.dart` — name resolution + sound alert tests present
- ✅ `kurye_ana_page_test.dart` — stop name display tests present
- ⬜ `test/integration/cross_role_lifecycle_test.dart` — T03 deliverable

## Diagnostics

None — name resolution is a pure synchronous map lookup with null-safe fallback (`ugramaMap[id] ?? id`). No failure path to instrument.

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — added ugramaMap/kuryeMap construction in _buildDispatchPanels, updated _routeLabel and panel builders to resolve names
- `lib/feature/kurye/presentation/kurye_ana_page.dart` — added ugramaListProvider watch, threaded ugramaMap through _OrderListSection → _OrderCard, resolved stop names in route label
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — updated test (b) for resolved names, added tests (g) active panel names and (h) fallback
- `test/feature/kurye/kurye_ana_page_test.dart` — added ugrama test seed + repository override, updated test (b) for resolved names, added test (g) fallback
