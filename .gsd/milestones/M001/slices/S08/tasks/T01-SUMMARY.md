---
id: T01
parent: S08
milestone: M001
provides:
  - OrderAlertService class with injectable design
  - Sound alert wiring in dispatch page via prev/next comparison
  - FakeOrderAlertService for test infrastructure
  - Asset pipeline for audio files (assets/sounds/)
key_files:
  - lib/product/services/order_alert_service.dart
  - lib/feature/operasyon/presentation/operasyon_ekran_page.dart
  - test/feature/operasyon/operasyon_ekran_page_test.dart
  - test/helpers/fakes/fake_order_alert_service.dart
  - assets/sounds/new_order.wav
  - pubspec.yaml
key_decisions:
  - Used constructor injection (optional alertService param) instead of Riverpod provider for the alert service — simpler, widget-local lifecycle, avoids provider proliferation for a UI-only concern
  - Used _knownWaitingIds set with _initialLoadDone flag to bootstrap correctly on first stream emission without false alerts
  - Used Logger() directly (project pattern) instead of AppLogger/LogTag which don't exist in this codebase
patterns_established:
  - Injectable service via optional constructor param on ConsumerStatefulWidget — _ownsAlertService tracks disposal responsibility
  - FakeOrderAlertService pattern — override playNewOrderAlert() to count calls without audio
observability_surfaces:
  - Logger .d() on every alert trigger: "OrderAlertService: playing new order alert"
  - Logger .e() on playback failure with error and stack trace
duration: 20m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Add sound alert service for new dispatch orders

**Added `OrderAlertService` backed by `audioplayers` that fires a WAV alert on genuinely new `kurye_bekliyor` stream arrivals, with injectable design for testing.**

## What Happened

1. Added `audioplayers: ^6.1.0` dependency to pubspec. Created `assets/sounds/` directory with a generated 0.3s 440Hz sine-wave WAV file. Registered the asset directory in pubspec flutter assets.

2. Created `lib/product/services/order_alert_service.dart` — wraps `AudioPlayer`, exposes `playNewOrderAlert()` using `AssetSource('sounds/new_order.wav')` with `PlayerMode.lowLatency`. Playback errors are caught and logged at `.e()` level (best-effort, never crashes). Includes `@visibleForTesting` `triggerCount` and a `withPlayer` constructor for full testability.

3. Extended the `ref.listen(siparisStreamActiveProvider, ...)` block in `operasyon_ekran_page.dart`. On each emission, extracts the set of `kurye_bekliyor` order IDs. On first load (`_initialLoadDone == false`), populates `_knownWaitingIds` without alerting. On subsequent emissions, computes the set difference — if new IDs appear, fires `playNewOrderAlert()` exactly once per emission batch.

4. Made the service injectable via an optional `alertService` constructor parameter on `OperasyonEkranPage`. When null (production), creates a real instance and tracks ownership for disposal. When provided (tests), uses the injected instance without disposing it.

5. Created `FakeOrderAlertService` that counts calls without audio. Added test (f) that seeds one waiting order, verifies no alert on initial load, emits a new order into the stream, verifies exactly one alert, then re-emits the same list and confirms no additional alert.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (40 info-level pre-existing)
- `flutter test` — 115/115 pass (114 existing + 1 new sound alert test)
- Test (f) confirms: initial load → 0 alerts, new order emission → 1 alert, same-list re-emission → still 1 alert
- Manual review of ref.listen logic confirms prev/next comparison is correct

### Slice-level verification (partial — T01 of 3):
- ✅ `flutter test` — all pass (115 total, 114 existing + 1 new)
- ✅ `flutter analyze` — 0 errors, 0 warnings
- ✅ `test/feature/operasyon/operasyon_ekran_page_test.dart` — new sound alert test passes
- ⬜ `test/feature/operasyon/operasyon_ekran_page_test.dart` — name resolution tests (T02)
- ⬜ `test/feature/kurye/kurye_ana_page_test.dart` — stop name display test (T02)
- ⬜ `test/integration/cross_role_lifecycle_test.dart` — full lifecycle test (T03)

## Diagnostics

- Grep console for `OrderAlertService` to see trigger and error events
- `_alertService.triggerCount` available in debug builds for programmatic inspection
- Playback failures logged at `.e()` level but never crash the app

## Deviations

- Task plan referenced `AppLogger` with `LogTag.data` — these abstractions don't exist in the codebase. Used `Logger()` directly, matching the existing pattern in `operasyon_ekran_page.dart` and `operasyon_gecmis_page.dart`.

## Known Issues

None.

## Files Created/Modified

- `pubspec.yaml` — added `audioplayers: ^6.1.0` dependency + `assets/sounds/` asset registration
- `assets/sounds/new_order.wav` — generated 0.3s 440Hz sine-wave alert sound
- `lib/product/services/order_alert_service.dart` — new alert service class
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — added alert service injection, `_knownWaitingIds` tracking, new-order detection in `ref.listen`
- `test/helpers/fakes/fake_order_alert_service.dart` — spy fake for testing
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — added test (f) for sound alert trigger behavior, updated `pumpPage` to accept optional `alertService`
