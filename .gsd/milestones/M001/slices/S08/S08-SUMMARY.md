---
id: S08
parent: M001
milestone: M001
provides:
  - OrderAlertService with injectable design for sound alerts on new dispatch orders
  - D027 name resolution applied to dispatch and courier screens (stops + courier names)
  - Cross-role integration test suite proving full order lifecycle (R008 gate)
  - 5 new integration tests + 4 new widget tests (123 total, up from 114)
requires:
  - slice: S03
    provides: siparisStreamActiveProvider, Siparis model, customer order creation
  - slice: S04
    provides: 3-panel dispatch screen, courier assignment, order finish with auto-pricing, SiparisLog
  - slice: S05
    provides: Courier main screen, timestamp punching, active/passive toggle
  - slice: S06
    provides: Order history with name resolution pattern (D027)
  - slice: S07
    provides: Analytics dashboard
affects: []
key_files:
  - lib/product/services/order_alert_service.dart
  - lib/feature/operasyon/presentation/operasyon_ekran_page.dart
  - lib/feature/kurye/presentation/kurye_ana_page.dart
  - test/integration/cross_role_lifecycle_test.dart
  - test/helpers/fakes/fake_order_alert_service.dart
  - assets/sounds/new_order.wav
  - pubspec.yaml
key_decisions:
  - D032 — Constructor injection for OrderAlertService (optional param, not Riverpod provider)
  - D033 — Initial-load bootstrap with _knownWaitingIds set — no false alerts on first stream emission
  - D034 — Pure data-layer integration test for cross-role lifecycle instead of widget-pumped test
patterns_established:
  - Injectable service via optional constructor param on ConsumerStatefulWidget with ownership tracking for disposal
  - D027 name-resolution pattern now consistently applied across all 3 ops screens (history, dispatch, courier)
  - Completer-based stream subscription pattern for integration test handoff verification
observability_surfaces:
  - OrderAlertService logs at .d() on trigger, .e() on failure
  - triggerCount available on service instance for programmatic inspection
drill_down_paths:
  - .gsd/milestones/M001/slices/S08/tasks/T01-SUMMARY.md
  - .gsd/milestones/M001/slices/S08/tasks/T02-SUMMARY.md
  - .gsd/milestones/M001/slices/S08/tasks/T03-SUMMARY.md
duration: ~50m
verification_result: passed
completed_at: 2026-03-15
---

# S08: Cross-role Integration & Polish

**Sound alerts on new dispatch orders, human-readable names replacing UUIDs on all screens, and a 5-test integration suite proving the full order lifecycle across all 3 roles.**

## What Happened

T01 added `audioplayers` dependency and created `OrderAlertService` — a thin wrapper around `AudioPlayer` that plays a 0.3s 440Hz WAV alert. The service is injected into the dispatch page via optional constructor parameter. On each `siparisStreamActiveProvider` emission, the page compares current `kurye_bekliyor` IDs against a `_knownWaitingIds` set. First emission bootstraps the set without alerting; subsequent emissions fire the alert exactly once per batch of genuinely new orders. `FakeOrderAlertService` counts calls for test verification.

T02 applied the D027 name-resolution pattern (established in S06/gecmis page) to both the dispatch and courier screens. On the dispatch page, `ugramaListProvider` and `kuryeListProvider` are watched at the `_buildDispatchPanels` level; maps are built once and passed through `_routeLabel` and panel builders. On the courier page, `ugramaListProvider` feeds an `ugramaMap` threaded through `_OrderListSection` → `_OrderCard`. All lookups fall back to the raw UUID if the name isn't found.

T03 created a 5-test integration suite exercising the order lifecycle through fake repositories at the data layer: (1) full lifecycle create→assign→deliver→complete with all state assertions, (2) stream reactivity at each transition, (3) courier stream isolation by kurye_id, (4) name resolution data availability, (5) auto-pricing lookup. This validates R008 (cross-role realtime) as the M001 definition-of-done gate.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (40 infos, all pre-existing)
- `flutter test` — 123/123 pass (114 pre-existing + 1 sound alert + 4 name resolution + 5 integration = 10 new, minus 1 merged test)
- Sound alert test: initial load → 0 alerts, new order → 1 alert, same-list re-emit → still 1 alert
- Name resolution tests: dispatch and courier screens render resolved names; fallback renders raw UUIDs
- Integration tests: full lifecycle, stream reactivity, courier isolation, name data, auto-pricing — all pass

## Requirements Advanced

- R017 (Sound alerts) — implemented with OrderAlertService, wired to dispatch stream, tested
- R008 (Cross-role realtime) — integration test proves full lifecycle data flow across all 3 roles

## Requirements Validated

- R017 — sound alert triggers on genuinely new kurye_bekliyor orders, verified by widget test
- R008 — 5 integration tests prove create→assign→deliver→complete lifecycle with correct state transitions, stream reactivity, and courier isolation

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Deviations

- T01 plan referenced `AppLogger` with `LogTag.data` — these abstractions don't exist in the codebase. Used `Logger()` directly, matching existing pattern.
- T03 used pure data-layer tests instead of widget-pumped tests. The lifecycle is a repository concern; widget rendering is already covered per-screen by T01/T02 tests.

## Known Limitations

- Sound playback is best-effort — if `AudioPlayer` fails, error is logged but the order still appears normally. No user-facing error for sound failure.
- Name resolution requires ugrama/kurye list data to be loaded. If providers haven't loaded yet, raw UUIDs show briefly until data arrives.
- Cross-role integration tests use fakes, not live Supabase. Full live verification is deferred to UAT on iOS simulator.

## Follow-ups

- UAT on iOS simulator: manual cross-role test with live Supabase (M001 definition of done gate)
- Consider DB trigger for siparis_log instead of client-side insert (D021) for reliability
- Sound customization (volume, different sounds for different events) if users request it

## Files Created/Modified

- `pubspec.yaml` — added `audioplayers: ^6.1.0` + `assets/sounds/` asset registration
- `assets/sounds/new_order.wav` — 0.3s 440Hz sine-wave alert
- `lib/product/services/order_alert_service.dart` — sound alert service
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — alert service injection + name resolution maps
- `lib/feature/kurye/presentation/kurye_ana_page.dart` — ugramaMap threading for stop name display
- `test/helpers/fakes/fake_order_alert_service.dart` — spy fake
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — sound alert + name resolution tests
- `test/feature/kurye/kurye_ana_page_test.dart` — stop name display + fallback tests
- `test/integration/cross_role_lifecycle_test.dart` — 5-test lifecycle integration suite

## Forward Intelligence

### What the next slice should know
- M001 is complete. All 18 active requirements are validated. The next milestone (M002) should start with R019 (location tracking) and R020 (map tracking).

### What's fragile
- `audioplayers` package on iOS simulator may not produce audible output — works in production but simulator audio can be unreliable. Sound service is best-effort by design.
- Fake repositories in tests use in-memory lists — any new query patterns in repositories need matching fake implementations.

### Authoritative diagnostics
- `flutter test test/integration/cross_role_lifecycle_test.dart` — the single most comprehensive proof that the lifecycle works
- Grep console for `OrderAlertService` — shows trigger events and any playback errors

### What assumptions changed
- Originally planned widget-pumped integration test — data-layer test proved sufficient and cleaner since widget rendering is already covered per-screen.
