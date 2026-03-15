# UAT Continue Point

**Saved at:** 2026-03-15T18:30:00Z

## Completed
- T01-T07: Auth + Ops dashboard/navigation/create order — ALL PASS
- T08: Form validation — PASS
- T09: Form reset — PASS (via T07 recording)
- T10-T11: Assign/Finish — COVERED (via earlier recordings)
- T14-T18: Müşteri Kayıt, Uğrama, Kurye, Rol Onayları, Geçmiş — ALL PASS
- T19: Müşteri Login — PASS
- T20: Müşteri Navigation — PASS (drawer open, 2 items + logout confirmed)

## Key Discovery
- `mobile_click_on_screen_at_coordinates` does NOT work for Flutter canvas `ShadButton` widgets
- `mobile_double_tap_on_screen` DOES work reliably for all Flutter canvas buttons
- **Always use double_tap for button interactions in Flutter iOS simulator**

## Remaining Tests
- T21: Müşteri Create Order — needs dropdown interaction
- T22: Müşteri Form Validation — submit empty form
- T23: Müşteri Active Orders — view orders after creation
- T24: Müşteri Geçmiş — navigate to history page
- T25-T27: Kurye Login, Assigned Orders, Timestamps
- T28: Cross-role Lifecycle (partial — ops side done)
- T29-T31: Edge cases (dropdown search, multi-select, back nav)

## Current State
- App running on simulator (PID 51099, flutter run with dart-defines)
- Currently on Müşteri role, drawer is OPEN showing: Sipariş Oluştur, Geçmiş Siparişler, Çıkış Yap
- Auth page simplified: no Google auth, no backend label, no anon/register — just email/password + quick login buttons
- Video recording stopped — start new recording for next test group

## Next Action
1. Close drawer (tap outside or select menu item)
2. Start new recording for T21-T24
3. Test müşteri order creation (T21) — use double_tap for all buttons
4. Continue with T22-T24, then logout → kurye login (T25-T27)

## Environment
- Device: 04E43A5F-2FD2-4405-A574-DA757E506951 (iPhone 15 Pro)
- Flutter PID: 51099 (may need restart in new session)
- Dart defines in: /tmp/dart-defines.txt
- Recording dir: /Users/mucahitsen/kurye-app/uat-recordings/
- Recording method: `xcrun simctl io <device> recordVideo --codec h264 <path>` + SIGINT to stop
