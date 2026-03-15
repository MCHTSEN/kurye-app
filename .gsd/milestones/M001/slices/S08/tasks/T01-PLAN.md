---
estimated_steps: 6
estimated_files: 6
---

# T01: Add sound alert service for new dispatch orders

**Slice:** S08 — Cross-role integration & polish
**Milestone:** M001

## Description

Implement R017 (sound alerts for new orders). Create an `OrderAlertService` backed by `audioplayers` that plays a short WAV when genuinely new `kurye_bekliyor` orders arrive on the dispatch stream. The service must be injectable so widget tests can verify trigger behavior without real audio. Wire into the existing `ref.listen` in `operasyon_ekran_page.dart` with prev/next comparison to avoid false alerts.

## Steps

1. Add `audioplayers: ^6.1.0` to `pubspec.yaml` dependencies. Create `assets/sounds/` directory and generate a minimal alert WAV file (use `python3` or `sox` to create a short sine-wave beep). Register `assets/sounds/` in `pubspec.yaml` under `flutter.assets`.
2. Create `lib/product/services/order_alert_service.dart` — a class with `AudioPlayer` instance, `playNewOrderAlert()` method using `AssetSource('sounds/new_order.wav')` with `PlayerMode.lowLatency`, and `dispose()`. Use `AppLogger` with `LogTag.data` for trigger logging.
3. Extend the `ref.listen(siparisStreamActiveProvider, ...)` block in `operasyon_ekran_page.dart`. Extract `kurye_bekliyor` order IDs from prev and next. If next contains IDs not in prev, call `_alertService.playNewOrderAlert()`. Track a `Set<String> _knownWaitingIds` in the stateful widget to bootstrap correctly on first load.
4. Make the alert service injectable — accept an optional `OrderAlertService?` or use a Riverpod provider so tests can override. Initialize in `initState`, dispose in `dispose()`.
5. Add a widget test: seed an initial stream emission → then emit a second list with one new `kurye_bekliyor` order → verify the alert service was triggered. Use a mock/spy `OrderAlertService`.
6. Run `flutter analyze` and `flutter test` — verify zero regressions.

## Must-Haves

- [ ] `audioplayers` added to pubspec with asset registered
- [ ] `OrderAlertService` class with `playNewOrderAlert()` and `dispose()`
- [ ] Sound triggers only on genuinely new `kurye_bekliyor` arrivals, not existing order status changes
- [ ] Alert service is injectable/mockable for testing
- [ ] Widget test proves alert fires on new order arrival
- [ ] Zero regressions — all 114+ existing tests pass

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all pass including new sound alert test
- Manual: review the `ref.listen` logic to confirm prev/next comparison is correct

## Observability Impact

- Signals added: `OrderAlertService` logs at `.d()` when sound is triggered, `.e()` on playback failure
- How a future agent inspects: grep console for `OrderAlertService` to see trigger events
- Failure state exposed: playback errors logged but do not crash the app — sound is best-effort

## Inputs

- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — existing `ref.listen` at line 319
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — existing 5 widget tests
- `test/helpers/fakes/fake_siparis_repository.dart` — `emit()` for driving stream updates

## Expected Output

- `pubspec.yaml` — audioplayers dependency + assets/sounds/ registration
- `assets/sounds/new_order.wav` — short alert sound file
- `lib/product/services/order_alert_service.dart` — alert service class
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — modified with alert detection logic
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — 1+ new test for sound alert
