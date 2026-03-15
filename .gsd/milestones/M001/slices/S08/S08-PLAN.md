# S08: Cross-role Integration & Polish

**Goal:** Full end-to-end order lifecycle verified across all 3 roles, with sound alerts for new orders and human-readable names replacing raw UUIDs on dispatch and courier screens.
**Demo:** Integration test proves: müşteri creates order → ops sees it in waiting panel → ops assigns courier → courier sees order → courier punches timestamps → ops finishes with auto-pricing. Dispatch screen plays sound on new `kurye_bekliyor` arrivals. All screens show stop and courier names, not UUIDs.

## Must-Haves

- Sound alert fires when new `kurye_bekliyor` orders arrive on the dispatch stream (R017)
- Sound detection compares previous vs current order lists — no false alerts on existing order state changes
- Dispatch panels show stop names and courier names instead of raw UUIDs
- Courier screen shows stop names instead of raw UUIDs
- Cross-role integration test exercises the full order lifecycle through all 3 role screens
- R008 (cross-role realtime) validation completed
- 114+ tests pass with zero regressions
- `flutter analyze` clean (0 errors, 0 warnings)

## Proof Level

- This slice proves: final-assembly
- Real runtime required: no (widget tests with fakes prove the wiring; live Supabase tested manually)
- Human/UAT required: yes (cross-role flow on iOS simulator is the milestone DoD gate)

## Verification

- `flutter test` — all tests pass (114 existing + new tests from T01/T02/T03)
- `flutter analyze` — 0 errors, 0 warnings
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — new tests for sound alert trigger and name resolution
- `test/feature/kurye/kurye_ana_page_test.dart` — new test for stop name display
- `test/integration/cross_role_lifecycle_test.dart` — full lifecycle integration test

## Observability / Diagnostics

- Runtime signals: `OrderAlertService` logs sound trigger events at `.d()` level via LogTag.data
- Inspection surfaces: console grep for `OrderAlertService` to verify sound triggers; existing `SupabaseSiparisRepo` logs for data flow
- Failure visibility: sound service errors logged at `.e()` level; null-safe name resolution falls back to raw ID (never crashes)

## Integration Closure

- Upstream surfaces consumed: `siparisStreamActiveProvider`, `ugramaListProvider`, `kuryeListProvider`, `currentKuryeProvider`, all fake repositories
- New wiring introduced in this slice: `OrderAlertService` injected into dispatch page; `ugramaListProvider` watched on dispatch and courier pages for name maps
- What remains before the milestone is truly usable end-to-end: UAT on iOS simulator (manual)

## Tasks

- [x] **T01: Add sound alert service for new dispatch orders** `est:25m`
  - Why: R017 — dispatch staff need audio notification when new orders arrive to prevent missed orders
  - Files: `pubspec.yaml`, `lib/product/services/order_alert_service.dart`, `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`, `test/feature/operasyon/operasyon_ekran_page_test.dart`, `assets/sounds/new_order.wav`
  - Do: Add `audioplayers` dependency. Create `OrderAlertService` with `playNewOrderAlert()` and `dispose()`. Generate or bundle a short alert WAV. Wire into the existing `ref.listen(siparisStreamActiveProvider, ...)` in the dispatch page — compare prev/next `kurye_bekliyor` IDs to detect genuinely new arrivals. Make the service injectable for testing. Register assets in pubspec.
  - Verify: `flutter analyze` clean, `flutter test` passes, new widget test verifies alert service is called when new `kurye_bekliyor` order appears in stream
  - Done when: Sound alert triggers exactly once per genuinely new `kurye_bekliyor` order, not on status changes of existing orders

- [x] **T02: Resolve raw UUIDs to names on dispatch and courier screens** `est:20m`
  - Why: Display polish — raw UUIDs are unreadable; the D027 name resolution pattern from gecmis page must be applied to dispatch panels and courier order cards
  - Files: `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`, `lib/feature/kurye/presentation/kurye_ana_page.dart`, `test/feature/operasyon/operasyon_ekran_page_test.dart`, `test/feature/kurye/kurye_ana_page_test.dart`
  - Do: On dispatch page — watch `ugramaListProvider` and `kuryeListProvider` at `_buildBody` level, build ugramaMap/kuryeMap, replace `_routeLabel` to use ugramaMap lookups, replace `Kurye: ${s.kuryeId}` with kuryeMap lookup. On courier page — watch `ugramaListProvider`, build ugramaMap, replace raw IDs in order card route text. All lookups fall back to raw ID if name not found.
  - Verify: `flutter analyze` clean, `flutter test` passes, widget tests verify resolved names appear in rendered output
  - Done when: Dispatch and courier screens show human-readable stop names and courier names in all order displays

- [x] **T03: Cross-role integration test for full order lifecycle** `est:25m`
  - Why: R008 final validation — proves the complete lifecycle works across all 3 roles, which is the M001 definition of done gate
  - Files: `test/integration/cross_role_lifecycle_test.dart`
  - Do: Write a widget test that wires fake repositories and drives an order through: (1) müşteri creates order → (2) order appears in ops waiting panel → (3) ops assigns courier → (4) courier sees order → (5) courier punches timestamps → (6) ops finishes with auto-pricing → (7) verify final order state is tamamlandi with all fields populated. Use existing fakes with stream emission. Test each handoff point as a separate assertion block.
  - Verify: `flutter test test/integration/cross_role_lifecycle_test.dart` passes, `flutter test` all pass
  - Done when: Integration test proves the full create→assign→deliver→complete lifecycle with correct state transitions at each step

## Files Likely Touched

- `pubspec.yaml`
- `assets/sounds/new_order.wav`
- `lib/product/services/order_alert_service.dart`
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
- `lib/feature/kurye/presentation/kurye_ana_page.dart`
- `test/feature/operasyon/operasyon_ekran_page_test.dart`
- `test/feature/kurye/kurye_ana_page_test.dart`
- `test/integration/cross_role_lifecycle_test.dart`
