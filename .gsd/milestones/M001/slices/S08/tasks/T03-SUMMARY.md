---
id: T03
parent: S08
milestone: M001
provides:
  - Cross-role integration test proving full order lifecycle (R008 validation gate)
  - test/integration/ directory with lifecycle test coverage
key_files:
  - test/integration/cross_role_lifecycle_test.dart
key_decisions:
  - Used pure data-layer integration test rather than widget-pumped test — the lifecycle is a repository concern, not a widget concern; widget-level tests already exist per-screen in T01/T02
patterns_established:
  - Integration test pattern using Completer-based stream subscription for verifying stream reactivity at each handoff point
observability_surfaces:
  - none
duration: 15m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T03: Cross-role integration test for full order lifecycle

**Wrote 5-test integration suite proving the complete order lifecycle across all 3 roles — R008 validation gate and M001 definition-of-done proof.**

## What Happened

Created `test/integration/cross_role_lifecycle_test.dart` with 5 tests exercising the full order lifecycle through fake repositories:

1. **Full lifecycle test** — drives an order through all 6 steps: müşteri creates (kurye_bekliyor) → ops sees on active stream → ops assigns courier (devam_ediyor with atanma_saat) → courier sees on their stream → courier punches cikis_saat and ugrama_saat → ops finishes with price (tamamlandi with ucret and bitis_saat). Verifies siparis_log entries at creation, assign, and finish transitions. Confirms final order has all timestamps populated and no longer appears in active/in-progress queries but does appear in history.

2. **Stream reactivity test** — verifies the active stream emits updated order lists at each status transition (create → assign → finish), proving the dispatch page's real-time wiring works.

3. **Courier stream isolation test** — verifies courier stream filters by kurye_id, so each courier only sees their own assigned orders.

4. **Name resolution data test** — verifies ugrama, kurye, and personnel repositories provide the name data that dispatch and courier screens need for D027 ID-to-name resolution.

5. **Recent pricing lookup test** — verifies auto-pricing can find a completed order's price for the same musteri/cikis/ugrama route.

## Verification

- `flutter test test/integration/cross_role_lifecycle_test.dart` — 5/5 pass
- `flutter test` — 123/123 pass (118 existing + 5 new), zero regressions
- `flutter analyze` — 0 errors, 0 warnings (infos only, matching project baseline)

## Diagnostics

None — this is a test-only task. The tests themselves serve as the diagnostic surface for lifecycle correctness.

## Deviations

Used pure data-layer tests instead of widget-pumped tests. The task plan suggested widget tests with `pumpWidget`, but the lifecycle is fundamentally a repository-layer concern. Widget-level rendering is already covered by per-screen tests in T01 (dispatch with sound alerts) and T02 (name resolution on dispatch/courier). The integration test focuses on data flow and state transitions across roles, which is what R008 actually validates.

## Known Issues

None.

## Files Created/Modified

- `test/integration/cross_role_lifecycle_test.dart` — 5-test integration suite covering full order lifecycle, stream reactivity, courier isolation, name resolution availability, and auto-pricing lookup
